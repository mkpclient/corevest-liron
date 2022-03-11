public without sharing class CustomChatterController {
    @AuraEnabled
    public static String getRelatedChatterObject(String parentId)
    {
        List<Custom_Chatter_Mapping__c> records = new List<Custom_Chatter_Mapping__c>([SELECT Id,Parent_Id__c,Deal__c FROM Custom_Chatter_Mapping__c where Parent_Id__c=:parentId limit 1]);
        if(records!=null && !records.isEmpty())
        {
             return records[0].Id;
            //return records[0].Deal__c;
        }else{
            ProcessInstanceWorkItem piw = [SELECT ProcessInstance.TargetObjectId FROM ProcessInstanceWorkItem WHERE Id = :parentId LIMIT 1];
            String Deal_c_return = piw.ProcessInstance.TargetObjectId;
            Custom_Chatter_Mapping__c record=new Custom_Chatter_Mapping__c(
                Parent_Id__c=parentId,
                Deal__c=piw.ProcessInstance.TargetObjectId
            );
            insert record;
            
            return record.Id;
           //return Deal_c_return;
            
        }
    }
}