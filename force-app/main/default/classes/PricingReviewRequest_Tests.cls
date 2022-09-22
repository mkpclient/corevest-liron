@isTest
private class PricingReviewRequest_Tests {
  @isTest(SeeAllData=true)
  static void PricingReviewRequest_UnitTest() {
    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
    Opportunity opp = test_Helper.createOpportunity(acc, cont);

    Test.startTest();
    PricingReviewRequest_LightningController.validateRecord(opp.Id);
    opp.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'LOC_Loan'
    ]
    .Id;

    update opp;
    PricingReviewRequest_LightningController.bypassApproval(opp.Id, 'testname');
    // PricingReviewRequest_LightningController.validateRecord(opp.Id);
    PricingReviewRequest_LightningController.startApproval(
      opp.Id,
      'Opportunity',
      'comments',
      'Test Resolution',
      'LOC_Loan'
    );

    Test.stopTest();
  }


    
  @isTest(SeeAllData=true)
  static void PricingReviewRequest_UnitTest2() {
    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
    Opportunity opp = test_Helper.createOpportunity(acc, cont);
    Test.startTest();
    PricingReviewRequest_LightningController.startApproval(
      opp.Id,
      'Opportunity',
      'comments',
      'Test Resolution',
      'Term_Loan'
    );
    PricingReviewRequest_LightningController.sendRepricingEmail(opp.Id);
    Test.stopTest();
  }
    @isTest(SeeAllData=true)  
  static void PricingReviewRequest_UnitTest3() {
    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
	Opportunity opp = new Opportunity();
    opp.Name = 'test';
    opp.CloseDate = System.today() + 10;
    opp.StageName = 'Initial Review';
    opp.Loan_Size__c = 2000000;
    opp.AccountId = acc.Id;
    opp.Contact__c = cont.Id;
    opp.Deal_Intro_Source__c = 'Hotline';
    opp.Deal_Intro_Sub_Source__c = 'Main';
    opp.Apex_Context__c = true;
    opp.Commission_Type__c = 'Internal';
    opp.Project_Strategy__c = 'Multifamily Heavy Lift/CLO';
    opp.LOC_Loan_Type__c = 'Term Loan';
    opp.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
    ]
    .Id;
    insert opp;      
    id propRecordTypeId = [ SELECT Id FROM RecordType WHERE sobjecttype = 'property__c' AND DeveloperName = 'Bridge_Renovation'].Id;      
    List<Property__c> properties = new List<Property__c>();
      properties.add(
        new Property__c(
          Deal__c = opp.Id,
          Name = ' Test123',
          Property_Name__c = ' Test123',
          Property_Type__c = 'SFR',
          Number_of_Units__c = 1,
          Interior_Access_POC_Email__c = 'test@test.com',
          Security_Deposit__c = 800,
          Status__c = 'Active',
          BlackSquare_Fee__c = null,
          Yardi_Id__c = '123456789',
          Is_Sub_Unit__c = False,
          RecordTypeId = propRecordTypeId
        )
      );      
	insert properties;  
    id oid = opp.Id;      
    PricingReviewRequest_LightningController.returnItem ri = new PricingReviewRequest_LightningController.returnItem();
    List<String> listMessages = new List<String>();
    Test.startTest();
    PricingReviewRequest_LightningController.validateRecord(opp.Id);      
    Test.stopTest();
  }

}