@isTest
public class TermPostClosingExtensionTests {
  @isTest
  public static void testMethod1() {
      test_Helper.createDealLoanNumber();
    Account testAcct = Test_Helper.createAccount();
    Contact testContact = Test_Helper.createContact(testAcct);
    Opportunity testOpp = Test_Helper.createTermDeal(testAcct, testContact);
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