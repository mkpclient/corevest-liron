@isTest
private class ApplicationTests {
  @testSetup
  static void setup() {
    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
    test_Helper.createDealLoanNumber();
    Application__c app = new Application__c(
      Contact__c = cont.Id,
      Alchemy_User_Id__c = 'af-sdba',
      Loan_Type__c = 'Single Asset Bridge Loan'
    );
    insert app;

    cont.Alchemy_Portal_Id__c = 'af-sdba';
    cont.Email = 'portalapitest@example.com';
    update cont;
  }

  static testMethod void applicationAPITest() {
    Application__c app = [SELECT Id FROM Application__c LIMIT 1];

    Map<String, String> params = new Map<String, String>();

    params.put('recordId', app.Id);
    params.put('Name', 'Test');

    Application_Property__c prop = new APplication_Property__c();
    prop.Application__c = app.Id;
    prop.Property_Type__c = 'Townhome';
    prop.Address__c = 'Test Property';
    insert prop;

    ApplicationHelper.convertApplication(params, null);

  }
}