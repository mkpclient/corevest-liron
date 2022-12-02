@isTest
private class LoanVersionTests {
  
  @TestSetup
  static void makeData(){
    Test_Helper.createRate();
    Test_Helper.createDealLoanNumber();
    Test_Helper.setupProduct2();
    Test_Helper.createBridgeOperationsUser();

    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
    Opportunity opp = test_Helper.createTermDeal(acc, cont);
    opp.Underwriter__c = UserInfo.getUserId();
    opp.Closer__c = UserInfo.getUserId();
    update opp;
    insert new Deal_Contact__c(
      Vendor_Type__c = 'Lender Legal Counsel',
      Contact__c = cont.Id,
      Deal__c = opp.Id
    );
    List<Property__c> property = new List<Property__c>();
    Id recTypeId = [
      SELECT Id
      FROM RecordType
      WHERE
        sobjecttype = 'Property__c'
        AND DeveloperName = 'Term_Loan'
    ]
    .Id;
    for (Integer i = 0; i < 20; i++) {
      property.add(
        new Property__c(
          Name = 'Test + ' + i,
          Deal__c = opp.Id,
          Escrow_Company_text__c = 'ESCROW',
          Insurance_Company_text__c = 'INSURANCE',
          RecordTypeId = recTypeId
        )
      );
    }
    insert property;


  }

  static testMethod void triggerTest() {

    Id opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;

    Test.startTest();
    Loan_Version__c vers = new Loan_Version__c(
      Deal__c = opportunityId,
      Loan_FEEs_JSON__c = JSON.serialize(new List<Loan_Fee__c>())
    );

    insert vers;

    PageReference pageRef = Page.ScheduleOfLenderCostsPDF;
    Test.setCurrentPage(pageRef);

    scheduleOfLenderCostsPDFExtension controller = new scheduleOfLenderCostsPDFExtension(
      new ApexPages.StandardController(vers)
    );

    //scheduleOfLenderCostsPDFExtension.getPDFContent(vers.Id);

    Test.stopTest();
  }

  static testMethod void validatorTest() {
    Id docStructureId = [
      SELECT Id, Document_Structure__c
      FROM Document_Validation__mdt
      WHERE Document_Structure__c != NULL
      LIMIT 1
    ]
    .Document_Structure__c;
    Opportunity deal = [SELECT Id,Contact__c,Underwriter__c,Closer__c FROM Opportunity LIMIT 1];

    Test.startTest();
    
    
    insert new EmailTemplate(DeveloperName = 'Red_Line_Loan_Validation',
    Body = '',
    TemplateType = 'Text',
    FolderId = UserInfo.getUserId(),
    Name = 'Red_Line_Loan_Validation'
);
    
    LoanVersionValidatorController.initScreen(docStructureId);
    LoanVersionValidatorController.emailLegalCounsel(deal.Id);
    Test.stopTest();
  }
}