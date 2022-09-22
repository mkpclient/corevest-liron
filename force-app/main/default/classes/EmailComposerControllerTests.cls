@isTest
private class EmailComposerControllerTests {
  static void setup() {
    test_Helper.createDealLoanNumber();
    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
    Opportunity opp = test_Helper.createOpportunity(acc, cont);
    opp.Apex_Context__c = true;
    opp.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'LOC_Loan'
    ]
    .Id;
    opp.StageName = 'Hold';
    opp.Draw_Period__c = '12 Months';
    opp.Repayment_Period__c = '9 Months';
    opp.LOC_Loan_Type__c = 'Credit Line';
    opp.Loan_Size__c = 3000000;
    opp.Line_Expiration__c = '18 Months';
    opp.Requested_LTC_Max__c = 70;
    opp.Requested_LTV_Max__c = 80;
    opp.Requested_Origination_Fee__c = 0;
    opp.Requested_Draw_Fee__c = 2;
    opp.Requested_Exit_Fee__c = 0;
    opp.Requested_Interest_Type__c = 'Fixed';
    opp.Requested_Rate_1_9_Months__c = 10;
    opp.Requested_Revolving__c = 'Yes';
    opp.Requested_Draw_Fee_Cap__c = 'None';
    opp.Product_Sub_Type__c = 'Renovation';
    opp.Interest_Rate_Type__c = 'Floating';
    opp.Index__c = '1M LIBOR';
    opp.Index_Margin__c = 1.50;
    opp.Deal_Intro_Source__c = 'Hotline';
    opp.Deal_Intro_Sub_source__c = 'Direct Mail';
    update opp;

    List<Property__c> property = new List<Property__c>();
    for (Integer i = 0; i < 20; i++) {
      property.add(
        new Property__c(
          Name = 'Test + ' + i,
          Deal__c = opp.Id,
          Escrow_Company_text__c = 'ESCROW',
          Insurance_Company_text__c = 'INSURANCE',
          Status__c = 'Pending',
          RecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE
              sobjecttype = 'Property__c'
              AND DeveloperName = 'Bridge_No_Renovation'
          ]
          .Id
        )
      );
    }

    property[0].Status__c = 'Due Diligence';
    property[1].Status__c = 'Active';
    property[2].Payoff_Received_Date__c = system.today();
    insert property;
  }

  static testMethod void sendEmailTest() {
    setup();
    Id opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;

    Test.startTest();
    Map<String, Object> inputs = new Map<String, Object>();

    inputs.put('to', new List<String>{ 'test@example.com' });
    inputs.put('cc', new List<String>{ 'test1@example.com' });
    inputs.put('bcc', new List<String>{ 'test2@example.com' });
    inputs.put('fileIds', new List<String>());
    inputs.put('from', 'test4@example.com');
    inputs.put('subject', 'Test');
    inputs.put('body', 'Testing');
    inputs.put('recordId', opportunityId);

    EmailComposerController.SendEmail(inputs);

    Test.stopTest();
  }

  static testMethod void getFromEmails() {
    Test.startTest();
    EmailComposerController.GetOrgWideEmailAddresses();

    EmailComposerController.GetUserEmailAddress(null);
    Test.stopTest();
  }
}