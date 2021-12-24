public class wire_Helper {

    public static Map<String, Schema.SObjectField> FIELD_MAP = Schema.SObjectType.Wire__c.fields.getMap();

    /**
    * @name beforeInsert
    * @description
    * @param
    **/
    public static void beforeInsert(List<Wire__c> newList){
        Map<Id, List<Wire__c>> wireMap = new Map<Id, List<Wire__c>>();
        for ( Integer i=0;i<newList.size();i++ ){
            if(!wireMap.containsKey(newList[i].Advance__c)){
                wireMap.put(newList[i].Advance__c, new List<Wire__c>());
            }
            wireMap.get(newList[i].Advance__c).add(newList[i]);
        }

        List<Advance__c> advUpdates = new List<Advance__c>();
        for(Advance__c adv : [SELECT Id, (Select Id, Wire_Number__c FROM Wires__r where Wire_Number__c != null Order By Wire_Number__c desc LIMIT 1) FROM Advance__c WHERE ID IN : wireMap.keySet()]){
            Decimal wireNum;
            for(Wire__c wire : wireMap.get(adv.Id)){
                //wire.Wire_Number__c = adv.Number_of_Wires__c == null ? 1 : adv.Number_of_Wires__c;
                //adv.Number_of_Wires__c = adv.Number_of_Wires__c == null ? 2 : (adv.Number_of_Wires__c + 1);

                if(wireNum == null){
                   if(adv.Wires__r.size() > 0 ){
                        wire.Wire_Number__c = adv.Wires__r[0].Wire_Number__c + 1;
                    }else{
                        wire.Wire_Number__c = 1;

                    }

                    wireNum = wire.Wire_Number__c + 1; 
                }else{
                    wire.Wire_Number__c = wireNum;
                    wireNum++;
                }
                

            }

            //advUpdates.add(adv);
        }

        //if(advUpdates.size() > 0){
        //    update advUpdates;
        //}
    }

    /**
    * @name afterInsert
    * @description
    * @param
    **/
    //public static void afterInsert(List<Wire__c> newList){
    //    for ( Integer i=0;i<newList.size();i++ ){

    //    }
    //}

    /**
    * @name beforeUpdate
    * @description
    * @param
    **/
    //public static void beforeUpdate(List<Wire__c> newList, List<Wire__c> oldList){
    //    for ( Integer i=0;i<newList.size();i++ ){

    //    }
    //}

    /**
    * @name afterUpdate
    * @description
    * @param
    **/
    //public static void afterUpdate(List<Wire__c> newList, List<Wire__c> oldList){
    //    for ( Integer i=0;i<newList.size();i++ ){

    //    }
    //}

    /**
    * @name beforeDelete
    * @description
    * @param
    **/
    //public static void beforeDelete(List<Wire__c> newList){
    //    for ( Integer i=0;i<newList.size();i++ ){

    //    }
    //}

    /**
    * @name afterDelete
    * @description
    * @param
    **/
    public static void afterDelete(List<Wire__c> newList, List<Wire__c> oldList){
        Set<Id> advIds = new Set<Id>();
        for ( Integer i=0;i<oldList.size();i++ ){
            advIds.add(oldList[i].Advance__c);
        }

        List<Wire__c> wireUpdates = new List<Wire__c>();
        for(Advance__c adv : [SELECT Id, (Select Id, Wire_Number__c FROM Wires__r where Wire_Number__c != null Order By CreatedDate Asc) FROM Advance__c WHERE ID IN : advIds]){
            for(Integer i = 0; i < adv.wires__r.size(); i++){
                adv.Wires__r[i].Wire_Number__c = i + 1;

                wireUpdates.add(adv.Wires__r[i]);
            }

            //advUpdates.add(adv);
        }

        if(wireUpdates.size() > 0){
            update wireUpdates;
        }

    }

    /**
    * @name afterUndelete
    * @description
    * @param
    **/
    //public static void afterUndelete(List<Wire__c> oldList){
    //    for ( Integer i=0;i<oldList.size();i++ ){

    //    }
    //}

}