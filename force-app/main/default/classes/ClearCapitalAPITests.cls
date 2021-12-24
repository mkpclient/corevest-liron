@isTest
private with sharing class ClearCapitalAPITests {
  @TestSetup
  static void setupTestData() {
    RecordType rt = [
      SELECT Id, DeveloperName
      FROM RecordType
      WHERE DeveloperName = 'Vendor' AND sobjectType = 'Account'
      LIMIT 1
    ];
    insert new Account(Name = 'Clear Capital', RecordTypeId = rt.Id);

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
    prop.Interior_Access_POC__c = 'Test Person';

    insert prop;
  }

  static testMethod void unittest() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1];

    Test.startTest();
    System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Clear Capital');
    arguments.put('productType', 'Interior Appraisal');
    arguments.put('rushOrder', false);
    arguments.put('turnTime', '48');
    arguments.put('dueDate', String.valueOf(System.today().addDays(10)));
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Appraisal__c app = [SELECT Id FROM Appraisal__c LIMIT 1];

    AppraisalMergeController.checkStatus(app.Id);

    Database.executeBatch(new ClearCapitalBatch(), 1);
    AppraisalMergeController.retrieveOrderClearCapital(app.Id);

    Test.stopTest();
  }

  static testMethod void bpoPushTest() {
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    Property__c property = [SELECT Id FROM Property__c LIMIT 1];

    Appraisal__c app = new Appraisal__c();
    app.Property__c = property.Id;
    app.Deal__c = opp.Id;
    app.Appraisal_Firm_Transaction_ID__c = '30078381';
    insert app;

    StaticResource sr = [
      SELECT Id, NamespacePrefix, SystemModstamp, Body
      FROM StaticResource
      WHERE Name = 'ClearCapitalPushBPOTest'
      LIMIT 1
    ];

    String body = sr.Body.toString();

    Test.startTest();
    ClearCapitalPushAPI.parseBPO(body);
    Test.stopTest();
  }

  static testMethod void appraisalPushTest() {
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    Property__c property = [SELECT Id FROM Property__c LIMIT 1];

    Appraisal__c app = new Appraisal__c();
    app.Property__c = property.Id;
    app.Deal__c = opp.Id;
    app.Appraisal_Firm_Transaction_ID__c = '30078370';
    insert app;
    ClearCapitalPushAPI.createSuccessAck();
    StaticResource sr = [
      SELECT Id, NamespacePrefix, SystemModstamp, Body
      FROM StaticResource
      WHERE Name = 'ClearCapitalPushAppraisalTest'
      LIMIT 1
    ];

    String body = sr.Body.toString();

    Test.startTest();
    ClearCapitalPushAPI.parseAppraisal(body);
    Test.stopTest();
  }

  static testMethod void clearvalPushTest() {
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    Property__c property = [SELECT Id FROM Property__c LIMIT 1];

    Appraisal__c app = new Appraisal__c();
    app.Property__c = property.Id;
    app.Deal__c = opp.Id;
    app.Appraisal_Firm_Transaction_ID__c = '30078377';
    insert app;

    StaticResource sr = [
      SELECT Id, NamespacePrefix, SystemModstamp, Body
      FROM StaticResource
      WHERE Name = 'ClearCapitalPushClearValTest'
      LIMIT 1
    ];

    String body = sr.Body.toString();

    Test.startTest();
    ClearCapitalPushAPI.parseClearVal(body);
    Test.stopTest();
  }
}