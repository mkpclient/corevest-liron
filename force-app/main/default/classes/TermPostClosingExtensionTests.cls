@isTest
public class TermPostClosingExtensionTests {
  @TestSetup
  static void makeData(){
    Test_Helper.createDealLoanNumber();
    Account testAcct = Test_Helper.createAccount();
    Contact testContact = Test_Helper.createContact(testAcct);
    Opportunity testOpp = Test_Helper.createTermDeal(testAcct, testContact);
    List<Property__c> props = Test_Helper.createProperties(testOpp);
    CLO_Asset_Details__c cad = new CLO_Asset_Details__c(
      Deal_ID__c = testOpp.Id,
      Related_Property__c = props[0].Id,
      Interest_Rate_Cap_Reserve__c = 1000,
      Reserve_Cap_Ex__c = 2000,
      Reserve_Insurance__c = 3000,
      Reserve_Tax__c = 4000
    );
    insert cad;

    // Loan_Version__c vers = new Loan_Version__c(
    //   Deal__c = testOpp.Id,
    //   Loan_FEEs_JSON__c = JSON.serialize(new List<Loan_Fee__c>())
    // );
    // insert vers;
  }
  @isTest
  public static void testMethod1() {
    Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
    test.startTest();
    String emailInfo = TermPostClosingEmailController.getEmailInfo(testOpp.Id);
    Loan_Version__c testLv = TermPostClosingEmailController.getLoanVersion(
      testOpp.Id
    );
    Map<String, String> testDd = TermPostClosingEmailController.saveDocument(
      testOpp.Id
    );
    
    Map<String, String> testEmailData = new Map<String, String>{
      'recipients' => 'test@test.com',
      'cc' => 'test@test.com',
      'emailBody' => 'TESTBODY',
      'subject' => 'TESTSUBJ'
    };
    String emailRes = TermPostClosingEmailController.sendEmail(
      JSON.serialize(testEmailData)
    );
    ApexPages.currentPage()
      .getParameters()
      .put('id', String.valueOf(testOpp.Id));
    ApexPages.StandardController sc = new ApexPages.StandardController(testOpp);
    TermPostClosingBerkadiaExtension tpController = new TermPostClosingBerkadiaExtension(
      sc
    );
    System.assertEquals(testOpp.Id, tpController.recId, 'Ids are matching.');
    test.stopTest();
  }
  
}