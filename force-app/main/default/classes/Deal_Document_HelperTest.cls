@isTest
private class Deal_Document_HelperTest {
  static testMethod void Deal_Document_Helper_UnitTest() {
      

test_Helper.createDealLoanNumber();
    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
    Opportunity opp = test_Helper.createOpportunity(acc, cont);
    Id termLoanRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
      .get('Term Loan')
      .getRecordTypeId();
    opp.RecordTypeId = termLoanRecordTypeId;
    opp.LOC_Program_Type__c = 'Custom';
    opp.Approved_Term_Sheet_Name__c = null;
    update opp;

    Deal_Document__c doc = new Deal_Document__c(Deal__c = opp.Id);
    insert doc;

    List<Deal_Document__c> listDealDocument = new List<Deal_Document__c>();
    listDealDocument.add(doc);

    Test.startTest();
    doc.Document_Loaded__c = true;
    doc.Reviewed__c = true;
    doc.Type__c = 'Loan Document';
    doc.Section__c = 'Assignments';
    doc.Document_Type__c = 'Executed Assignments';
    update doc;

    doc.Reviewed__c = false;
    update doc;

    doc.Document_Loaded__c = false;
    doc.Reviewed__c = true;
    update doc;

    Deal_Document__c ldra = new Deal_Document__c(
      Deal__c = opp.Id,
      type__c = 'Loan Document',
      section__c = 'LDR',
      Document_Type__c = 'LDR Part A'
    );
    insert ldra;

    Deal_Document__c ldrb = new Deal_Document__c(
      Deal__c = opp.Id,
      type__c = 'Loan Document',
      section__c = 'LDR',
      Document_Type__c = 'LDR Part B'
    );
    insert ldrb;

    Deal_Document__c la = new Deal_Document__c(
      Deal__c = opp.Id,
      type__c = 'Loan Document',
      section__c = 'Principle Loan Documents',
      Document_Type__c = 'Loan Agreement'
    );
    insert la;

    Deal_Document__c sg = new Deal_Document__c(
      Deal__c = opp.Id,
      type__c = 'Loan Document',
      section__c = 'Principle Loan Documents',
      Document_Type__c = 'Sponsor Guaranty'
    );
    insert sg;

    Deal_Document__c icm = new Deal_Document__c(
      Deal__c = opp.Id,
      type__c = 'IC Memo',
      Document_Type__c = 'Final IC Memo'
    );
    insert icm;

    deal_Document_Helper.afterInsert(listDealDocument);
    Test.stopTest();
  }

  static testMethod void Deal_Document_Helper_UnitTest2() {

test_Helper.createDealLoanNumber();
    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
    Opportunity opp = test_Helper.createBridgeDeal(acc, cont);
    // Id termLoanRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
    //   .get('Bridge Loan')
    //   .getRecordTypeId();
    // opp.RecordTypeId = termLoanRecordTypeId;
    opp.LOC_Program_Type__c = 'Custom';
    opp.Approved_Term_Sheet_Name__c = null;
    update opp;

    Document_Structure__mdt docStruct = [
      SELECT Id
      FROM Document_Structure__mdt
      LIMIT 1
    ];
    Advance__c adv = new Advance__c(Deal__c = opp.Id);
    insert adv;

    Property__c testProp = new Property__c(
      Deal__c = opp.Id,
      Name = 'Test',
      Property_Name__c = 'Test',
      Property_Type__c = 'SFR',
      Number_of_Units__c = 1,
      Interior_Access_POC_Email__c = 'test@test.com',
      Security_Deposit__c = 800,
      Status__c = 'Active'
    );

    insert testProp;

    Deal_Document__c doc = new Deal_Document__c(
      Deal__c = opp.Id,
      Document_Structure_Id__c = docStruct.Id,
      Type__c = 'Draft IC Memo',
      Section__c = 'IC Memo'
    );

    Deal_Document__c doc2 = new Deal_Document__c(
      Document_Structure_Id__c = docStruct.Id,
      Advance__c = adv.Id,
      Property__c = testProp.Id
    );

    insert new List<Deal_Document__c>{ doc, doc2 };

    doc.Recorded_Date__c = system.today();
    doc.Type__c = 'Final IC Memo';
    update doc;

    doc.Recorded_Date__c = null;
    update doc;
  }
}