public class trade_Helper {

    public static Map<String, Schema.SObjectField> FIELD_MAP = Schema.SObjectType.Trade__c.fields.getMap();

    /**
    * @name beforeInsert
    * @description
    * @param
    **/
    public static void beforeInsert(List<Trade__c> newList){
        Map<Id, List<Trade__c>> tradeMap = new Map<Id, List<Trade__c>>();
        for(Trade__c trade : newList){
            if(String.isBlank(trade.Name)){
                //tradeMap.put(trade.Correspondent__c, trade);
                if(!tradeMap.containsKey(trade.Correspondent__c)){
                    tradeMap.put(trade.Correspondent__c, new List<Trade__c>());
                }

                tradeMap.get(trade.Correspondent__c).add(trade);
            }
            
        }

        for(Account a : [SELECT Id, Name, (Select Id FROM Trades__r) FROM Account WHERE Id IN : tradeMap.keySet()]){
            if(a.Trades__r.size() > 0){
                
                for(Integer i = 0; i < tradeMap.get(a.Id).size(); i++){
                    tradeMap.get(a.Id)[i].Name = String.valueOf(a.Trades__r.size() + 1 + i); 
                }
            }else{
               
                for(Integer i = 0; i < tradeMap.get(a.Id).size(); i++){
                    tradeMap.get(a.Id)[i].Name = String.valueOf(1+i);
                }
            }


            String abbr = '';

            for(String name : a.Name.split(' ')){
                if(String.isNotBlank(name)){
                    abbr += name.substring(0,1);
                }
            }

            for(Trade__c trade : tradeMap.get(a.Id)){
                trade.Account_Abbreviation__c = abbr;

                for(Integer i = trade.Name.length(); i < 4; i++ ){
                    trade.Name = '0' + trade.Name;
                }

                trade.Name = abbr + '-' + trade.Name;

            }




        }
    }

    /**
    * @name afterInsert
    * @description
    * @param
    **/
    /*
    public static void afterInsert(List<Trade__c> newList){
        for ( Integer i=0;i<newList.size();i++ ){

        }
    }
    */
    /**
    * @name beforeUpdate
    * @description
    * @param
    **/
    /*
    public static void beforeUpdate(List<Trade__c> newList, List<Trade__c> oldList){
        for ( Integer i=0;i<newList.size();i++ ){

        }
    }
    */

    /**
    * @name afterUpdate
    * @description
    * @param
    **/
    /*
    public static void afterUpdate(List<Trade__c> newList, List<Trade__c> oldList){
        for ( Integer i=0;i<newList.size();i++ ){

        }
    }
    */

    /**
    * @name beforeDelete
    * @description
    * @param
    **/
    /*
    public static void beforeDelete(List<Trade__c> newList){
        for ( Integer i=0;i<newList.size();i++ ){

        }
    }
    */
    /**
    * @name afterDelete
    * @description
    * @param
    **/
    /*
    public static void afterDelete(List<Trade__c> newList, List<Trade__c> oldList){
        for ( Integer i=0;i<newList.size();i++ ){

        }
    }
    */

    /**
    * @name afterUndelete
    * @description
    * @param
    **/
    /*
    public static void afterUndelete(List<Trade__c> oldList){
        for ( Integer i=0;i<oldList.size();i++ ){

        }
    }
    */
}