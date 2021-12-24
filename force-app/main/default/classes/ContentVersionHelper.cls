public without sharing class ContentVersionHelper {
  public static Set<String> groupNames = new Set<String>{ 'System Admins' };

  public static void afterInsert(List<ContentVersion> newList) {
    Set<Id> contentNotes = new Set<Id>();

    system.debug('in after insert');

    Map<Id, ContentVersion> contentDocumentIdMap = new Map<Id, ContentVersion>();
    Map<Id, List<Id>> documentApplicationMap = new Map<Id, List<Id>>();
    for (ContentVersion document : newList) {
      system.debug(document);
      if (document.FileType == 'SNOTE') {
        contentNotes.add(document.ContentDocumentId);
      }

      if (String.isNotBlank(document.ContentDocumentId)) {
        contentDocumentIdMap.put(document.ContentDocumentId, document);
      }

      if (document.Application__c != null) {
        if (!documentApplicationMap.containsKey(document.ContentDocumentId)) {
          documentApplicationMap.put(
            document.ContentDocumentId,
            new List<Id>()
          );
        }

        documentAPplicationMap.get(document.ContentDocumentId)
          .add(document.Application__c);
      }
    }

    if (contentDocumentIdMap.size() > 0) {
      List<Deal_Document__c> docs = new List<Deal_Document__c>();
      for (Deal_Document__c dealDoc : [
        SELECT Id, Attachment_Id__c, ContentVersion_Id__c
        FROM Deal_Document__c
        WHERE Attachment_Id__c IN :contentDOcumentIdMap.keySet()
      ]) {
        if (
          dealDoc.ContentVersion_Id__c !=
          contentDocumentIdMap.get(dealDoc.Attachment_Id__c).Id
        ) {
          dealDoc.ContentVersion_Id__c = contentDocumentIdMap.get(
              dealDoc.Attachment_Id__c
            )
            .Id;
          dealDoc.File_Name__c = contentDocumentIdMap.get(
              dealDoc.Attachment_Id__c
            )
            .PathOnClient;
          docs.add(dealDoc);
        }

        if (docs.size() > 0) {
          update docs;
        }
      }
    }

    if (contentDocumentIdMap.size() > 0) {
      List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();

      for (Id contentDocumentId : documentApplicationMap.keySet()) {
        for (Id applicationId : documentApplicationMap.get(contentDocumentId)) {
          ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = applicationId,
            ShareType = 'V',
            Visibility = 'AllUsers'
          );
          cdls.add(cdl);
        }
      }

      insert cdls;
    }

    //system.debug('documents');
    //system.debug(contentNOtes);
    // if(contentNotes.size() > 0){
    //     List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();

    //     for(CollaborationGroup g : [SELECT Id FROM CollaborationGroup WHERE Name IN : groupNames]){
    //         for(Id noteId : contentNotes){
    //             cdls.add(new ContentDocumentLink(ContentDocumentId = noteId, LinkedEntityId = g.Id,  ShareType = 'V', Visibility = 'AllUsers'));
    //         }
    //     }

    //     system.debug(cdls);

    //     insert cdls;

    //     system.debug(cdls);
    //     system.debug(cdls[0].Id);

    //     system.debug([SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE Id =: cdls[0].Id]);

    // }
  }
}