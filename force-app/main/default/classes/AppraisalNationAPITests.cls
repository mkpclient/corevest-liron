@isTest
private with sharing class AppraisalNationAPITests {
  @TestSetup
  static void setupTestData() {
    RecordType rt = [
      SELECT Id, DeveloperName
      FROM RecordType
      WHERE DeveloperName = 'Vendor' AND sobjectType = 'Account'
      LIMIT 1
    ];
    insert new Account(Name = 'Appraisal Nation', RecordTypeId = rt.Id);

    test_Helper.createDealLoanNumber();
    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
    Opportunity opp = test_Helper.createOpportunity(acc, cont);
    opp.StageName = 'Submitted to Underwriting';
    opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
      .get('Bridge Loan')
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
    prop.Interior_Access_POC__c = 'test person';
    prop.Interior_Access_POC_Email__c = 'test@test.com';
    prop.Interior_Access_POC_Phone__c = '555-555-5555';
    insert prop;
  }

  static testMethod void unittest() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];

    Test.startTest();
    System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put('productType', 'Interior Appraisal');
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Appraisal__c app = [SELECT Id FROM Appraisal__c LIMIT 1 FOR UPDATE];

    AppraisalMergeController.checkStatus(app.Id);

    Database.executeBatch(new AppraisalNationBatch(), 1);
    AppraisalMergeController.retrieveOrderAppraisalNation(app.Id);

    Test.stopTest();
  }

  static testMethod void unittest2() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];

    Test.startTest();
    System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put('productType', 'Exterior Appraisal');
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Appraisal__c app = [SELECT Id FROM Appraisal__c LIMIT 1 FOR UPDATE];

    AppraisalMergeController.checkStatus(app.Id);

    // Database.executeBatch(new ClearCapitalBatch(), 1);
    AppraisalMergeController.retrieveOrderAppraisalNation(app.Id);

    Test.stopTest();
  }

  static testMethod void unittest3() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];

    Test.startTest();
    System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put('productType', 'Final Inspection');
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Test.stopTest();
  }

  static testMethod void unittest4() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];

    Test.startTest();
    // System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put('productType', 'Recert. of Value');
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Appraisal__c app = [SELECT Id FROM Appraisal__c LIMIT 1 FOR UPDATE];

    AppraisalMergeController.checkStatus(app.Id);

    // Database.executeBatch(new ClearCapitalBatch(), 1);
    AppraisalMergeController.retrieveOrderAppraisalNation(app.Id);

    Test.stopTest();
  }

  static testMethod void unittest5() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];

    Test.startTest();
    // System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put(
      'productType',
      'CDAIR Exterior Disaster Area Inspection Report'
    );
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Appraisal__c app = [SELECT Id FROM Appraisal__c LIMIT 1 FOR UPDATE];

    AppraisalMergeController.checkStatus(app.Id);

    // Database.executeBatch(new ClearCapitalBatch(), 1);
    AppraisalMergeController.retrieveOrderAppraisalNation(app.Id);

    Test.stopTest();
  }

  static testMethod void unittest6() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];

    Test.startTest();
    // System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put(
      'productType',
      'CDAIR Interior Disaster Area Inspection Report'
    );
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Appraisal__c app = [SELECT Id FROM Appraisal__c LIMIT 1 FOR UPDATE];

    AppraisalMergeController.checkStatus(app.Id);

    // Database.executeBatch(new ClearCapitalBatch(), 1);
    AppraisalMergeController.retrieveOrderAppraisalNation(app.Id);

    Test.stopTest();
  }

  static testMethod void unittest7() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];

    Test.startTest();
    // System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put('productType', 'CoreVal+');
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Appraisal__c app = [SELECT Id FROM Appraisal__c LIMIT 1 FOR UPDATE];

    AppraisalMergeController.checkStatus(app.Id);

    // Database.executeBatch(new ClearCapitalBatch(), 1);
    AppraisalMergeController.retrieveOrderAppraisalNation(app.Id);

    Test.stopTest();
  }

  static testMethod void unittest9() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];
    p.Property_Type__c = '2-4 Unit';
    p.Number_of_Units__c = 2;
    update p;
    Test.startTest();
    // System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put('productType', 'CoreVal+');
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Appraisal__c app = [SELECT Id FROM Appraisal__c LIMIT 1 FOR UPDATE];

    AppraisalMergeController.checkStatus(app.Id);

    // Database.executeBatch(new ClearCapitalBatch(), 1);
    AppraisalMergeController.retrieveOrderAppraisalNation(app.Id);

    Test.stopTest();
  }

  static testMethod void unittest10() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];
    p.Property_Type__c = '2-4 Unit';
    p.Number_of_Units__c = 2;
    update p;
    Test.startTest();
    // System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put('productType', 'Interior Appraisal');
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Appraisal__c app = [SELECT Id FROM Appraisal__c LIMIT 1 FOR UPDATE];

    AppraisalMergeController.checkStatus(app.Id);

    // Database.executeBatch(new ClearCapitalBatch(), 1);
    AppraisalMergeController.retrieveOrderAppraisalNation(app.Id);

    Test.stopTest();
  }

  static testMethod void unittest11() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];
    p.Property_Type__c = '2-4 Unit';
    p.Number_of_Units__c = 2;
    update p;
    Test.startTest();
    // System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put('productType', 'Exterior Appraisal');
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Appraisal__c app = [SELECT Id FROM Appraisal__c LIMIT 1 FOR UPDATE];

    AppraisalMergeController.checkStatus(app.Id);

    // Database.executeBatch(new ClearCapitalBatch(), 1);
    AppraisalMergeController.retrieveOrderAppraisalNation(app.Id);

    Test.stopTest();
  }

  static testMethod void unittest12() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];
    p.Property_Type__c = '2-4 Unit';
    p.Number_of_Units__c = 2;
    update p;
    Test.startTest();
    // System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put('productType', 'Final Inspection');
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Appraisal__c app = [SELECT Id FROM Appraisal__c LIMIT 1 FOR UPDATE];

    AppraisalMergeController.checkStatus(app.Id);

    // Database.executeBatch(new ClearCapitalBatch(), 1);
    AppraisalMergeController.retrieveOrderAppraisalNation(app.Id);

    Test.stopTest();
  }

  static testMethod void unittest13() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];
    p.Property_Type__c = '2-4 Unit';
    p.Number_of_Units__c = 2;
    update p;
    Test.startTest();
    // System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put(
      'productType',
      'CDAIR Exterior Disaster Area Inspection Report'
    );
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Appraisal__c app = [SELECT Id FROM Appraisal__c LIMIT 1 FOR UPDATE];

    AppraisalMergeController.checkStatus(app.Id);

    // Database.executeBatch(new ClearCapitalBatch(), 1);
    AppraisalMergeController.retrieveOrderAppraisalNation(app.Id);

    Test.stopTest();
  }

  static testMethod void unittest14() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];
    p.Property_Type__c = '2-4 Unit';
    p.Number_of_Units__c = 2;
    update p;
    Test.startTest();
    // System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put(
      'productType',
      'CDAIR Interior Disaster Area Inspection Report'
    );
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Appraisal__c app = [SELECT Id FROM Appraisal__c LIMIT 1 FOR UPDATE];

    AppraisalMergeController.checkStatus(app.Id);

    // Database.executeBatch(new ClearCapitalBatch(), 1);
    AppraisalMergeController.retrieveOrderAppraisalNation(app.Id);

    Test.stopTest();
  }

  static testMethod void unittest15() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];
    p.Property_Type__c = 'Multifamily';
    update p;

    Test.startTest();
    System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put('productType', 'Interior Appraisal');
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Test.stopTest();
  }

  static testMethod void unittest16() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];
    p.Property_Type__c = 'Condo';
    update p;
    Test.startTest();
    System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put('productType', 'Interior Appraisal');
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Test.stopTest();
  }

  static testMethod void unittest17() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];
    p.Property_Type__c = '2-4 Unit';
    p.Number_of_Units__c = 4;
    update p;
    Test.startTest();
    // System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put('productType', 'Interior Appraisal');
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Appraisal__c app = [SELECT Id FROM Appraisal__c LIMIT 1 FOR UPDATE];

    AppraisalMergeController.checkStatus(app.Id);

    // Database.executeBatch(new ClearCapitalBatch(), 1);
    AppraisalMergeController.retrieveOrderAppraisalNation(app.Id);

    Test.stopTest();
  }

  static testMethod void unittest18() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];
    p.Property_Type__c = '2-4 Unit';
    p.Number_of_Units__c = 20;
    update p;
    Test.startTest();
    // System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put('productType', 'Interior Appraisal');
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Appraisal__c app = [SELECT Id FROM Appraisal__c LIMIT 1 FOR UPDATE];

    AppraisalMergeController.checkStatus(app.Id);

    // Database.executeBatch(new ClearCapitalBatch(), 1);
    AppraisalMergeController.retrieveOrderAppraisalNation(app.Id);

    Test.stopTest();
  }

  static testMethod void unittest19() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];
    p.Property_Type__c = 'Multifamily';
    update p;

    Test.startTest();
    System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put('productType', 'Final Inspection');
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Test.stopTest();
  }

  static testMethod void unittest20() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];
    p.Property_Type__c = 'Condo';
    update p;
    Test.startTest();
    System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put('productType', 'Final Inspection');
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Test.stopTest();
  }

  static testMethod void unittest21() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];
    p.Property_Type__c = '2-4 Unit';
    p.Number_of_Units__c = 4;
    update p;
    Test.startTest();
    // System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put('productType', 'Final Inspection');
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Appraisal__c app = [SELECT Id FROM Appraisal__c LIMIT 1 FOR UPDATE];

    AppraisalMergeController.checkStatus(app.Id);

    // Database.executeBatch(new ClearCapitalBatch(), 1);
    AppraisalMergeController.retrieveOrderAppraisalNation(app.Id);

    Test.stopTest();
  }

  static testMethod void unittest22() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];
    p.Property_Type__c = '2-4 Unit';
    p.Number_of_Units__c = 20;
    update p;
    Test.startTest();
    // System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put('productType', 'Final Inspection');
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Appraisal__c app = [SELECT Id FROM Appraisal__c LIMIT 1 FOR UPDATE];

    AppraisalMergeController.checkStatus(app.Id);

    // Database.executeBatch(new ClearCapitalBatch(), 1);
    AppraisalMergeController.retrieveOrderAppraisalNation(app.Id);

    Test.stopTest();
  }

  static testMethod void unittest23() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];
    p.Property_Type__c = 'Multifamily';
    update p;

    Test.startTest();
    System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put('productType', ' ICDAIR Exterior Disaster Areanspection Report');
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Test.stopTest();
  }

  static testMethod void unittest24() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];
    p.Property_Type__c = 'Condo';
    update p;
    Test.startTest();
    System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put('productType', 'CDAIR Exterior Disaster Area Inspection Report');
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Test.stopTest();
  }

  static testMethod void unittest25() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];
    p.Property_Type__c = '2-4 Unit';
    p.Number_of_Units__c = 4;
    update p;
    Test.startTest();
    // System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put('productType', 'CDAIR Exterior Disaster Area Inspection Report');
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Appraisal__c app = [SELECT Id FROM Appraisal__c LIMIT 1 FOR UPDATE];

    AppraisalMergeController.checkStatus(app.Id);

    // Database.executeBatch(new ClearCapitalBatch(), 1);
    AppraisalMergeController.retrieveOrderAppraisalNation(app.Id);

    Test.stopTest();
  }

  static testMethod void unittest26() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];
    p.Property_Type__c = '2-4 Unit';
    p.Number_of_Units__c = 20;
    update p;
    Test.startTest();
    // System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put('productType', 'CDAIR Exterior Disaster Area Inspection Report');
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Appraisal__c app = [SELECT Id FROM Appraisal__c LIMIT 1 FOR UPDATE];

    AppraisalMergeController.checkStatus(app.Id);

    // Database.executeBatch(new ClearCapitalBatch(), 1);
    AppraisalMergeController.retrieveOrderAppraisalNation(app.Id);

    Test.stopTest();
  }

  static testMethod void unittest27() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];
    p.Property_Type__c = 'Multifamily';
    update p;

    Test.startTest();
    System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put('productType', 'Recert. of Value');
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Test.stopTest();
  }

  static testMethod void unittest28() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];
    p.Property_Type__c = 'Condo';
    update p;
    Test.startTest();
    System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put('productType', 'Recert. of Value');
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Test.stopTest();
  }

  static testMethod void unittest29() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];
    p.Property_Type__c = '2-4 Unit';
    p.Number_of_Units__c = 4;
    update p;
    Test.startTest();
    // System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put('productType', 'Recert. of Value');
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Appraisal__c app = [SELECT Id FROM Appraisal__c LIMIT 1 FOR UPDATE];

    AppraisalMergeController.checkStatus(app.Id);

    // Database.executeBatch(new ClearCapitalBatch(), 1);
    AppraisalMergeController.retrieveOrderAppraisalNation(app.Id);

    Test.stopTest();
  }

  static testMethod void unittest30() {
    Property__c p = [SELECT Id FROM Property__c LIMIT 1 FOR UPDATE];
    p.Property_Type__c = '2-4 Unit';
    p.Number_of_Units__c = 20;
    update p;
    Test.startTest();
    // System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{ p.Id }));

    Map<String, Object> arguments = new Map<String, Object>();
    arguments.put('appraisalFirm', 'Appraisal Nation');
    arguments.put('productType', 'Recert. of Value');
    arguments.put('rushOrder', false);
    // arguments.put('turnTime', '48');
    arguments.put('dueDate', '');
    arguments.put('vendorComments', 'adsfa');
    arguments.put('', '');
    AppraisalMergeController.submitOrder(p.Id, arguments);

    Appraisal__c app = [SELECT Id FROM Appraisal__c LIMIT 1 FOR UPDATE];

    AppraisalMergeController.checkStatus(app.Id);

    // Database.executeBatch(new ClearCapitalBatch(), 1);
    AppraisalMergeController.retrieveOrderAppraisalNation(app.Id);

    Test.stopTest();
  }
}