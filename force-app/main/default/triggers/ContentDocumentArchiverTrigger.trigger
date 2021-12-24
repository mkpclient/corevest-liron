trigger ContentDocumentArchiverTrigger on ContentDocument (before delete) {

    if (Trigger.isBefore) {
        if (Trigger.isDelete) {
            List<Id> dealDocumentsId = new List<Id>();
            List<Id> documentIds = new List<Id>();

            for (ContentDocument d : Trigger.old) {
                documentIds.add(d.id);
                
            }
            List<ContentDocumentLink> cdls = [Select LinkedEntityId From ContentDocumentLink Where ContentDocumentId in : documentIds];
             for (ContentDocumentLink c : cdls) {
                if(c.LinkedEntityId.getsobjecttype().getDescribe().getName() == 'Deal_Document__c'){
                    dealDocumentsId.add(c.LinkedEntityId);
                    
                }
             }
            List<Deal_Document__c> deals = [Select Id, Document_Archived_By_OwnBackup__c From  Deal_Document__c where id IN: dealDocumentsId];
            for(Deal_Document__c deal : deals){
                deal.Document_Archived_By_OwnBackup__c = true;

            }
            update deals;
        }


        
    }

}