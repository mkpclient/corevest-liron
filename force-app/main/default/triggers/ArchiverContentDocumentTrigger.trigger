trigger ArchiverContentDocumentTrigger on ContentDocument (before delete) {

    if (Trigger.isbefore) {
        if (Trigger.isDelete ) { //add the integration user id  && UserInfo.getUserId() == '0055C000002AjfNQAS'
            List<Id> dealDocumentsId = new List<Id>(); // list of deal documents id related to documents that gonna be deleted
            List<Id> documentIds = new List<Id>(); // list of documents that gonna be deleted
            
            for (ContentDocument d : Trigger.old) {
                documentIds.add(d.id);
            }
            
            //recognize deal documents object
            List<ContentDocumentLink> cdls = [Select LinkedEntityId From ContentDocumentLink Where ContentDocumentId in : documentIds];
            for (ContentDocumentLink cdl : cdls) {
                if(cdl.LinkedEntityId.getsobjecttype().getDescribe().getName() == 'Deal_Document__c'){
                    dealDocumentsId.add(cdl.LinkedEntityId);
                    
                }
            }
            
            //update the document deal records
            List<Deal_Document__c> deals = [Select Id, Document_Archived_By_OwnBackup__c From  Deal_Document__c where id IN: dealDocumentsId];
            for(Deal_Document__c deal : deals){
                deal.Document_Archived_By_OwnBackup__c = true;

            }
            update deals;
        }
        
    }

}