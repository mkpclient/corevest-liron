@isTest

public class Lightning_Tests_more {
    
static testMethod void lightning_Tests_UnitTest3() {

    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
    Opportunity opp = test_Helper.createOpportunity(acc, cont);
    List<Property__c> properties = test_Helper.createProperties(opp);

    insert new Attachment(
      ParentId = opp.Id,
      Body = Blob.valueOf('saadsf'),
      Name = 'Test'
    );
    insert new Attachment(
      ParentId = opp.Id,
      Body = Blob.valueOf('saadsf'),
      Name = 'Test'
    );
    insert new Attachment(
      ParentId = opp.Id,
      Body = Blob.valueOf('saadsf'),
      Name = 'Test'
    );
    insert new Attachment(
      ParentId = opp.Id,
      Body = Blob.valueOf('saadsf'),
      Name = 'Test'
    );

    List<documentUploader_Controller.AttachmentWrapper> wrapper = (List<documentUploader_Controller.AttachmentWrapper>) JSON.deserialize(
      documentUploader_Controller.getAttachments(opp.Id),
      List<documentUploader_Controller.AttachmentWrapper>.class
    );
    documentUploader_Controller.getPicklists(
      'Opportunity',
      'Term_Loan',
      'standard',
      null,
      null
    );
    documentUploader_Controller.getPicklists(
      'Opportunity',
      'Term_Loan',
      'borrower',
      null,
      null
    );
    documentUploader_Controller.getPicklists(
      'Opportunity',
      'Term_Loan',
      'vendor',
      null,
      'Legal Counsel'
    );
    wrapper[0].section = 'Due Diligence Document - Submission Documents';
    wrapper[0].documentType = 'Wire Confirmation';

    wrapper[1].section = 'Due Diligence Document - Submission Documents';
    wrapper[1].documentType = 'Wire Confirmation';

    wrapper[2].section = 'Due Diligence Document - Submission Documents';
    wrapper[2].documentType = 'Wire Confirmation';

    wrapper[3].section = 'Due Diligence Document - Submission Documents';
    wrapper[3].documentType = 'Wire Confirmation';

    documentUploader_Controller.saveFile(
      JSON.serialize(wrapper[0]),
      opp.Id,
      'Opportunity',
      'Term_Loan'
    );
    Test.startTest();    
    documentUploader_Controller.saveFile(
      JSON.serialize(wrapper[1]),
      opp.Id,
      'Opportunity',
      'Term_Loan'
    );
    documentUploader_Controller.saveFile(
      JSON.serialize(wrapper[2]),
      properties[0].Id,
      'Property__c',
      'Term_Loan'
    );
    documentUploader_Controller.saveFile(
      JSON.serialize(wrapper[3]),
      properties[0].Id,
      'Property__c',
      'Term_Loan'
    );
    
    lightning_Controller.getDocuments(
      String.valueOf(opp.Id),
      'borrower',
      String.valueOf(acc.Id),
      'Title and Escrow'
    );
    lightning_Controller.getDocuments(
      String.valueOf(opp.Id),
      'vendor',
      String.valueOf(acc.Id),
      'Title and Escrow'
    );
Test.stopTest();

    //lightning_Controller.getDocuments(String.valueOf(opp.Id), 'internal', String.valueOf(acc.Id), 'Title and Escrow');
    //contentVersion cv = [SELECT Id FROM ContentVersion LIMIT 1];
    //lightning_Controller.getDOcumentData(cv.Id);

    //delete [SELECT Id FROM ContentDocument];

    //documentUploader_Controller.saveFile(JSON.)
  }

/*    static testMethod void lightning_Tests_UnitTest4() {

	Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
    Opportunity opp = test_Helper.createOpportunity(acc, cont);
    List<Property__c> properties = test_Helper.createProperties(opp);

    insert new Attachment(
      ParentId = opp.Id,
      Body = Blob.valueOf('saadsf'),
      Name = 'Test'
    );
    insert new Attachment(
      ParentId = opp.Id,
      Body = Blob.valueOf('saadsf'),
      Name = 'Test'
    );
    insert new Attachment(
      ParentId = opp.Id,
      Body = Blob.valueOf('saadsf'),
      Name = 'Test'
    );
    insert new Attachment(
      ParentId = opp.Id,
      Body = Blob.valueOf('saadsf'),
      Name = 'Test'
    );

    List<documentUploader_Controller.AttachmentWrapper> wrapper = (List<documentUploader_Controller.AttachmentWrapper>) JSON.deserialize(
      documentUploader_Controller.getAttachments(opp.Id),
      List<documentUploader_Controller.AttachmentWrapper>.class
    );
    documentUploader_Controller.getPicklists(
      'Opportunity',
      'Term_Loan',
      'standard',
      null,
      null
    );
    documentUploader_Controller.getPicklists(
      'Opportunity',
      'Term_Loan',
      'borrower',
      null,
      null
    );
    documentUploader_Controller.getPicklists(
      'Opportunity',
      'Term_Loan',
      'vendor',
      null,
      'Legal Counsel'
    );
    wrapper[0].section = 'Due Diligence Document - Submission Documents';
    wrapper[0].documentType = 'Wire Confirmation';

    wrapper[1].section = 'Due Diligence Document - Submission Documents';
    wrapper[1].documentType = 'Wire Confirmation';

    wrapper[2].section = 'Due Diligence Document - Submission Documents';
    wrapper[2].documentType = 'Wire Confirmation';

    wrapper[3].section = 'Due Diligence Document - Submission Documents';
    wrapper[3].documentType = 'Wire Confirmation';
     Test.startTest();
    lightning_Controller.getDocuments(
      String.valueOf(opp.Id),
      'borrower',
      String.valueOf(acc.Id),
      'Title and Escrow'
    );
    lightning_Controller.getDocuments(
      String.valueOf(opp.Id),
      'vendor',
      String.valueOf(acc.Id),
      'Title and Escrow'
    );
    Test.stopTest();
}*/
    }