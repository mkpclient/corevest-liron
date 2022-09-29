public without sharing class REOHelper {
    public static void afterInsert(List<REO__c> newList) {
        Map<Id, REO__c> propIdToREOMap = new Map<Id, REO__c>();

        for(REO__c reo : newList) {
            if(reo.Property__c != null) {
                propIdToREOMap.put(reo.Property__c, reo);
            }
        }

        if(propIdToREOMap.size() > 0) {
            updateProperties(propIdToREOMap);
        }
    }

    public static void updateProperties(Map<Id, REO__c>  propIdToReoMap) {
        List<Property__c> props = new List<Property__c>();

        for(Id propId : propIdToReoMap.keySet()) {
            props.add(new Property__c(
                Id = propId,
                REO__c = propIdToReoMap.get(propId).Id
            ));
        }

        update props;
    }
}