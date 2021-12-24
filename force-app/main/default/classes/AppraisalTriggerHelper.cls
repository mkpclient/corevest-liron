public with sharing class AppraisalTriggerHelper {
    public static void afterUpdate(List<Appraisal__c> oldList, List<Appraisal__c> newList) {
        List<Property__c> props = new List<Property__c>();
        for(Integer i = 0; i < newList.size(); i++) {
            Property__c prop = new Property__c();
            Boolean shouldUpdate = false;
            if(oldList[i].Appraisal_Fee__c != newList[i].Appraisal_Fee__c && newList[i].Property__c != null) {
                prop.BPO_Appraisal_Fee__c = newList[i].Appraisal_Fee__c;
                shouldUpdate = true;
            }
            if(oldList[i].Estimated_Completion_Date__c != newList[i].Estimated_Completion_Date__c && newList[i].Property__c != null) {
                prop.Appraisal_Due_Date__c = newList[i].Estimated_Completion_Date__c.date();
                shouldUpdate = true;
            }

            if(shouldUpdate) {
                prop.Id = newList[i].Property__c;
                props.add(prop);
            }
        }

        if(props.size() > 0) {
            updatePropertyFields(props);
        }
        //Property__c
    }

    public static void updatePropertyFields(List<Property__c> props) {
        Database.update(props, false);
    }
}