public class tradeDeal_Helper {

	public static void afterInsert(List<Trade_Deal__c> newList){
		Set<Id> tradeIds = new Set<Id>();
		for(Trade_Deal__c deal : newList){
			tradeIds.add(deal.Trade__c);
		}

		if(tradeIds.size() > 0){
			rollupTrades(tradeIds);
		}
	}

	public static void afterUpdate(List<Trade_Deal__c> newList, List<Trade_Deal__c> oldList){
		Set<Id> tradeIds = new Set<Id>();
		Set<Id> acctIds = new Set<Id>();
		for(Integer i = 0; i < newList.size(); i++){
			tradeIds.add(newList[i].Trade__c);
			acctIds.add(newList[i].Correspondent_Id__c);
		}

		//for(Trade__c tr : [SELECT Id, Correspondent__c])

		if(tradeIds.size() > 0){
			rollupTrades(tradeIds);
			calculateStatePercentages(acctIds);
		}
	}

	public static void afterDelete(List<Trade_Deal__c> newList){
		Set<Id> tradeIds = new Set<Id>();

		for(Integer i = 0; i < newList.size(); i++){
			tradeIds.add(newList[i].Trade__c);
		}

		if(tradeIds.size() > 0){
			rollupTrades(tradeIds);
		}

	}

	public static void beforeDelete(List<Trade_Deal__c> newList){
		for(Integer i = 0; i < newList.size(); i++){
			if(newList[i].Trade_Status__c == 'Completed'){
				newList[i].addError('Can\'t delete a deal from a completed trade');
			}
		}
	}

	public static void rollupTrades(Set<Id> tradeIds){
		Map<Id, Trade__c> tradeMap = new Map<Id, Trade__c>();

		for(Id i : tradeIds){
			Trade__c trade = new Trade__c(Id = i);
			trade.Accrued_Interest__c = 0;
			trade.Principal_Proceeds__c = 0;
			trade.Proceed_to_Wire__c = 0;
			tradeMap.put(i, trade);
		}

		for(AggregateResult ar : [SELECT Trade__c pnt, SUM(Accrued_Interest__c) int, SUM(Effective_Loan_Amount__c) prp, SUM(Net_Proceeds__c) net FROM Trade_Deal__c WHERE Trade__c IN : tradeIds GROUP BY Trade__c]){
			Id tradeId = (Id)ar.get('pnt');
			Decimal accruedInterest = (Decimal)ar.get('int');
			Decimal principalProceeds = (Decimal)ar.get('prp');
			Decimal proceedWire = (Decimal)ar.get('net');
			tradeMap.get(tradeId).Accrued_Interest__c = accruedInterest;
			tradeMap.get(tradeId).Principal_Proceeds__c = principalProceeds;
			tradeMap.get(tradeId).Proceed_to_Wire__c = proceedWire;

		}

		update tradeMap.values();

	}

	public static void calculateStatePercentages(Set<Id> tradeIds){
		system.debug(tradeIds);
		system.debug('calculating state percent');
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, State_Concentration__c, State_Concentration_Percent__c, Completed_Trade_deals__c  FROM Account WHERE Id IN : tradeIds]);

        for(Id opId : accMap.keySet()){
            accMap.get(opId).State_Concentration__c = '';
            accMap.get(opId).State_Concentration_Percent__c = '';
            accMap.get(opId).Completed_Trade_Deals__c = 0;
        }
        system.debug(accMap);

        for(AggregateResult ar : [SELECT count(id) cnt, Trade__r.Correspondent__c prnt
                                    FROM trade_deal__c
                                    WHERE Trade__r.Status__c = 'Completed' AND Trade__r.Correspondent__c IN : tradeIds
                                    Group BY Trade__r.Correspondent__c]){
            Integer cnt = (Integer)ar.get('cnt');
            Id acctId = (Id)ar.get('prnt');
            system.debug(cnt);
            accMap.get(acctId).Completed_Trade_Deals__c = cnt;
        }

        for(AggregateResult ar : [select count(id) cnt, state__c state, trade__r.correspondent__c parent
                                    from trade_deal__c 
                                    where trade__r.status__c = 'Completed' AND Trade__r.Correspondent__c IN : tradeIds
                                    group by state__c, trade__r.correspondent__c]){

            Integer stateCount = (Integer)ar.get('cnt');
            String state = (String)ar.get('state');
            Id dealId = (Id)ar.get('parent');

            Decimal propertyCount = accMap.get(dealId).Completed_Trade_Deals__c;

            if(propertyCount != null && propertyCount > 0){
                Decimal val = stateCount/util.fixNull(propertyCount)*100;
                val = val.setScale(2);

                accMap.get(dealId).State_Concentration__c += state + ', ';
                accMap.get(dealId).State_Concentration_Percent__c += state + ' ' + val + '%, ';
            }

        }

        for(Id i : accMap.keySet()){
            if(String.isNotBlank(accMap.get(i).State_Concentration__c) ){
                  accMap.get(i).State_Concentration__c = accMap.get(i).State_Concentration__c.subStringBeforeLast(',');
            }
            
            if(String.isNotBlank(accMap.get(i).State_Concentration_Percent__c) ){
                  accMap.get(i).State_Concentration_Percent__c = accMap.get(i).State_Concentration_Percent__c.subStringBeforeLast(',');
            }
        }

        system.debug(accMap.values());
        update accMap.values();
    }

}