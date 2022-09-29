global with sharing class FileMoveBatch implements Database.Batchable<sObject> {
  global Database.QueryLocator start(Database.BatchableContext BC) {
    String queryString = 'SELECT';
    queryString += ' Id, latestpublishedversion.firstpublishlocationid, LatestPublishedVersionId, LatestPublishedVersion.Title, LatestPublishedVersion.FileExtension FROM ContentDocument';
    queryString += ' WHERE LatestPublishedVersion.Migrated_File__c = TRUE AND LatestPublishedVersion.Linked_To_Record__c = FALSE';
    return Database.getQueryLocator(queryString);
  }

  global void execute(Database.BatchableContext bc, List<sObject> scope) {
    List<Deal_Document__c> dealDocs = new List<Deal_Document__c>();

    //Id docStructureId = 'm005b0000010wJK';
    List<ContentVersion> contentVersions = new List<ContentVersion>();

    Set<Id> advanceIds = new Set<Id>();
    for (ContentDocument contentDoc : (List<ContentDocument>) scope) {
      if (
        contentDoc.LatestPublishedVersion.FirstPublishLocationId.getSObjectType()
          .getDescribe()
          .getName() == 'Account' ||
        contentDoc.LatestPublishedVersion.FirstPublishLocationId.getSObjectType()
          .getDescribe()
          .getName() == 'Contact'
      ) {
        contentVersions.add(
          new ContentVersion(
            Id = contentDoc.LatestPublishedVersionId,
            Linked_To_Record__c = true
          )
        );
        Deal_Document__c dealDocument = new Deal_Document__c();
        //dealDocument.Advance__c = contentDoc.LatestPublishedVersion.FirstPublishLocationId;
        if (
          contentDoc.LatestPublishedVersion.FirstPublishLocationId.getSObjectType()
            .getDescribe()
            .getName() == 'Account'
        ) {
          dealDocument.Account__c = contentDoc.LatestPublishedVersion.FirstPublishLocationId;
        } else if (
          contentDoc.LatestPublishedVersion.FirstPublishLocationId.getSObjectType()
            .getDescribe()
            .getName() == 'Contact'
        ) {
          dealDocument.Contact__c = contentDoc.LatestPublishedVersion.FirstPublishLocationId;
        }
        dealDocument.File_Name__c =
          contentDoc.LatestPublishedVersion.Title +
          '.' +
          contentDoc.LatestPublishedVersion.FileExtension;
        dealDocument.COntentVersion_Id__c = contentDoc.LatestPublishedVersionId;
        dealDocument.Attachment_Id__c = contentDoc.Id;
        dealDocument.Document_Loaded__c = true;
        //dealDocument.Document_Structure_Id__c = docStructureId;
        dealDocument.Type__c = 'Miscellaneous';
        dealDocument.Document_Type__c = 'Miscellaneous';
        dealDocs.add(dealDocument);
      }
    }

    insert dealDocs;
    update contentVersions;
    Set<Id> ids = new Set<Id>();

    List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
    for (Deal_Document__c dealDoc : dealDOcs) {
      ContentDocumentLink cdl = new ContentDocumentLink();
      cdl.ContentDocumentId = dealDoc.Attachment_Id__c;
      cdl.LinkedEntityId = dealDoc.Id;
      cdl.ShareType = 'V';
      cdl.Visibility = 'AllUsers';
      contentDOcumentLinks.add(cdl);

      ids.add(dealDoc.Account__c);
      ids.add(dealDoc.Contact__c);
      ids.add(dealDoc.Attachment_Id__c);
    }

    delete [
      SELECT Id
      FROM COntentDocumentLInk
      WHERE LinkedEntityId IN :ids AND ContentDocumentId IN :ids
    ];

    insert contentDocumentLinks;
  }

  global void finish(Database.BatchableContext bc) {
  }
}