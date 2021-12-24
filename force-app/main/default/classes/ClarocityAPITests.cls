@isTest
private with sharing class ClarocityAPITests {
  @TestSetup
  static void setupTestData() {
    RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Vendor' AND sobjectType = 'Account' LIMIT 1];
    insert new Account(Name = 'Clarocity Valuation Services', RecordTypeId = rt.Id);


    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
    Opportunity opp = test_Helper.createOpportunity(acc, cont);
    opp.StageName = 'Submitted to Underwriting';
    opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
      .get('Term Loan')
      .getRecordTypeId();

    Property__c prop = new Property__c();
    prop.Property_Type__c = 'SFR';
    prop.Deal__c = opp.Id;
    prop.Calc_AveValue__c = 100000;
    prop.Name = 'test';
    prop.Property_Name__c = 'test Street';
    prop.City__c = 'test';
    prop.State__c = 'test';
    prop.ZipCode__c = '90802';

    insert prop;
  }

  static testMethod void unittest() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1];

    Test.startTest();

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Clarocity Valuation Services');
    arguments.put('productType', 'Market Value Pro Interior');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('username', 'test');
    arguments.put('password', 'test');
    AppraisalMergeController.submitOrder(
      p.Id,
      arguments
    );

    Appraisal__c app = [SELECT Id FROM Appraisal__c LIMIT 1];

    AppraisalMergeController.checkStatus(app.Id);

    ClarocityAPI.retrieveOrderFuture(app.Id, 'Term_Loan');
    Database.executeBatch(new ClarocityBatch(), 1);

    Test.stopTest();
  }
}