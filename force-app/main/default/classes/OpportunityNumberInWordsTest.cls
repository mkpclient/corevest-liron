@isTest
public with sharing class OpportunityNumberInWordsTest {
  @TestSetup
  static void makeData() {
    Test_Helper.createDealLoanNumber();
    Test_Helper.setupProduct2();
    Test_Helper.createRate();
    Account a = Test_Helper.createAccount();
    Contact c = Test_Helper.createContact(a);
    List<Opportunity> deals = new List<Opportunity>();
    for (Integer i = 0; i < 5; i++) {
      Opportunity bridgedeal = new Opportunity();
      bridgedeal.Name = 'test' + (i + 1);
      bridgedeal.CloseDate = System.today();
      bridgedeal.StageName = 'Initial Review';
      bridgedeal.Loan_Size__c = 2000000;
      bridgedeal.AccountId = a.Id;
      bridgedeal.Contact__c = c.Id;
      bridgedeal.Deal_Intro_Source__c = 'Hotline';
      bridgedeal.Deal_Intro_Sub_Source__c = 'Main';
      bridgedeal.Apex_Context__c = true;
      bridgedeal.Commission_Type__c = 'Internal';
      bridgedeal.LOC_Loan_Type__c = 'Credit Line';
      bridgedeal.Product_Sub_Type__c = 'No Renovation';
      bridgedeal.Maturity_Date_Calculation_Type__c = 'Fixed at Closing';
      bridgedeal.Exit_Fee__c = 0;
      bridgedeal.RecordTypeId = [
        SELECT Id
        FROM RecordType
        WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'LOC_Loan'
      ]
      .Id;
      deals.add(bridgedeal);
    }

    insert deals;
  }

  @isTest
  public static void testNumbersToText() {
    Map<Id, Opportunity> opps = new Map<Id, Opportunity>(
      [
        SELECT
          Id,
          Rate__c,
          Broker_Fees__c,
          CAF_Upfront_Fee__c,
          Loan_Documents_Received__c,
          Custodial_File_Sent_to_Custodian__c,
          Assignments_Sent_to_Title__c,
          Onboarding_File_Sent_to_Servicer__c,
          Onboarded_at_Servicer__c
        FROM Opportunity
      ]
    );

    List<Decimal> nums = new List<Decimal>{ 1, 1.25, 1.5, 1.75, 1.99 };

    for (Integer i = 0; i < 5; i++) {
      Opportunity o = opps.values()[i];
      Decimal n = nums[i];
      Date d = System.today();
      o.Rate__c = n;
      o.Broker_Fees__c = n;
      o.CAF_Upfront_Fee__c = n;
      o.Loan_Documents_Received__c = d;
      o.Custodial_File_Sent_to_Custodian__c = d;
      o.Assignments_Sent_to_Title__c = d;
      o.Onboarding_File_Sent_to_Servicer__c = d;
      o.Onboarded_at_Servicer__c = d;
      opps.put(o.Id, o);
    }

    Test.startTest();
        update opps.values();
    Test.stopTest();
  }
}