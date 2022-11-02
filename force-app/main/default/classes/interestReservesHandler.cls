public class interestReservesHandler {
    public static void beforeInsert(List<Interest_Reserves__c> newList){
        
        List<id> iRId = new List<id>();
        MAP<id, id> myMap = new MAP<id,id>();
        
        for(integer i = 0; i < newList.size(); i++){
            iRId.add(newList[i].Property__c);
        }
        
        for(Property__c prop : [SELECT id, Deal__r.id FROM Property__c WHERE id in: iRId]){
            myMap.put(prop.id, prop.Deal__r.id);
            system.debug('myMap'+myMap);
            system.debug('mapsize'+myMap.size());
        }
        
        for(integer i = 0; i < newList.size(); i++){
        	Date monthDate = newList[i].Date__c == null? System.today().toStartOfMonth():newList[i].Date__c;

            newList[i].Deal__c = myMap.get(newList[i].Property__c);
            newList[i].Date__c = monthDate;

            system.debug('value'+ myMap.get(newList[i].Property__c));
        }
        
    }
    public static void beforeUpdate(List<Interest_Reserves__c> newList, List<Interest_Reserves__c> oldList){
        List<id> iRId = new List<id>();
        MAP<id, id> myMap = new MAP<id,id>();
        
        
        for(integer i = 0; i < newList.size(); i++){
            system.debug (newList[i].Property__c );
                        system.debug (oldList[i].Property__c );

            iRId.add(newList[i].Property__c);
        }
        
        for(Property__c prop : [SELECT id, Deal__r.id FROM Property__c WHERE id in: iRId]){
            myMap.put(prop.id, prop.Deal__r.id);
            system.debug('myMap2'+myMap);
            system.debug('mapsize2'+myMap.size());
        }
        
        for(integer i = 0; i < newList.size(); i++){
            newList[i].Deal__c = myMap.get(newList[i].Property__c);
            system.debug('value2'+ myMap.get(newList[i].Property__c));
        }
    
    
    }   
}