public class UpdateDocusignActiveStatusHelper {
   
    public static void UpdateDocusignUserStatus(List<User> userList, Map<Id, User> oldUserMap){
        List<String> userEmailList = new List<String>();
        for(user oneUser : userList){
            if(oneUser.IsActive == false && (oneUser.IsActive != oldUserMap.get(oneUser.Id).IsActive)){
                userEmailList.add(oneUser.Email);
            }
        }
        System.debug('email list' + userEmailList.size());
        if(!userEmailList.isEmpty()){
            UpdateDocusignActiveStatusHelper.UpdateDocusignStatus(userEmailList);
        }
    }
    
    @future
    public static void UpdateDocusignStatus(List<String> userEmailList){
        List<dsfs__DocuSign_Status__c> updateDocuSigns = new List<dsfs__DocuSign_Status__c>();
        for(dsfs__DocuSign_Status__c status : [SELECT Id, Sender_Inactive__c FROM dsfs__DocuSign_Status__c WHERE dsfs__Sender_Email__c IN :userEmailList LIMIT 50000]){
            dsfs__DocuSign_Status__c oneDocuSign = new dsfs__DocuSign_Status__c();
            oneDocuSign.Id = status.Id;
            oneDocuSign.Sender_Inactive__c = true;
            updateDocuSigns.add(oneDocuSign);
            system.debug('inactive' + status.Sender_Inactive__c);
        }

        if(!updateDocuSigns.isEmpty()){
            List<Database.saveResult> resultsDocuSigns = Database.update(updateDocuSigns, false);
            for(Integer i=0;i<resultsDocuSigns.size();i++){
                if (!resultsDocuSigns.get(i).isSuccess()){
                    // DML operation failed
                    Database.Error error = resultsDocuSigns.get(i).getErrors().get(0);
                    String failedUpdate = error.getMessage();
                    System.debug('failedUpdate:'+failedUpdate);
                }
            }
        }
    }
}