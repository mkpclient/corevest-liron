@isTest
private class DealFieldValidationTests {
  static testMethod void test1() {
    Test_Helper.createRate();
    Test_Helper.createDealLoanNumber();
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
    opp.Floor__c = 1.00;
    opp.Index_Margin__c = 1.50;
    opp.Deal_Intro_Source__c = 'Hotline';
    opp.Deal_Intro_Sub_source__c = 'Main';

    update opp;

    List<Property__c> property = new List<Property__c>();
    for (Integer i = 0; i < 20; i++) {
      property.add(
        new Property__c(
          Name = 'Test + ' + i,
          Property_Name__c = 'Test + ' + i,
          Deal__c = opp.Id,
          Escrow_Company_text__c = 'ESCROW',
          Insurance_Company_text__c = 'INSURANCE',
          Status__c = 'Active'
        )
      );
    }

    property[0].Status__c = 'Inactive';
    property[1].Status__c = 'Inactive';
    property[2].Payoff_Received_Date__c = system.today();
    insert property;

    // update opp;

    // opp.Record_Type_Name__c = 'LOC_Loan';

    Opportunity queriedOpp = (Opportunity) util.queryRecordAllFields(opp.Id);
    queriedOpp.StageName = 'Underwriting';

    Opportunity opp2 = queriedOpp.clone(true, false, false, false);
    opp2.StageName = 'Approved by Committee';

    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>(
      new List<Opportunity>{ queriedOpp }
    );

    Map<Id, Opportunity> newMap = new Map<Id, Opportunity>(
      new List<Opportunity>{ opp2 }
    );

    Map<Id, List<Property__c>> dealPropertyMap = new Map<Id, List<Property__c>>();
    dealPropertyMap.put(queriedOpp.Id, property);
    Map<Id, List<Business_Entity__c>> businessEntityMap = new Map<Id, List<Business_Entity__c>>();
    Map<Id, List<Deal_Document__c>> dealDocumentMap = new Map<Id, List<Deal_Document__c>>();

    Test.startTest();
    String errorMessage = DealFieldValidationHelper.validateDeals(
      oldMap,
      newMap,
      dealPropertyMap,
      businessEntityMap,
      dealDocumentMap
    );
    Test.stopTest();
  }

  static testMethod void test2() {
    Test_Helper.createRate();
    Test_Helper.createDealLoanNumber();
    Account acc = test_Helper.createAccount();
    acc.Alternate_Phone__c = '7777777777';
    update acc;
    Contact cont = test_Helper.createContact(acc);
    cont.MobilePhone = '2222222222';
    cont.Phone = '9999999999';
    Opportunity topp1 = test_Helper.createOpportunity(acc, cont);
    topp1.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
    ]
    .Id;
    topp1.StageName = 'Underwriting';
    topp1.Deal_Intro_Source__c = 'Email';
    topp1.Bridge_Borrower__c = 'No';
    topp1.Are_Assets_Coming_Off_Bridge_Line__c = 'No';
    topp1.Term_Sheet_Signed__c = system.today();
    topp1.Term_Sheet_Issued__c = system.today();
    update topp1;

    Opportunity queriedOpp = (Opportunity) util.queryRecordAllFields(topp1.Id);
    queriedOpp.StageName = 'Underwriting';

    Opportunity opp2 = queriedOpp.clone(true, false, false, false);
    opp2.StageName = 'Approved by Committee';

    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>(
      new List<Opportunity>{ queriedOpp }
    );

    Map<Id, Opportunity> newMap = new Map<Id, Opportunity>(
      new List<Opportunity>{ opp2 }
    );

    Map<Id, List<Property__c>> dealPropertyMap = new Map<Id, List<Property__c>>();
    Map<Id, List<Business_Entity__c>> businessEntityMap = new Map<Id, List<Business_Entity__c>>();
    Map<Id, List<Deal_Document__c>> dealDocumentMap = new Map<Id, List<Deal_Document__c>>();

    Test.startTest();
    String errorMessage = DealFieldValidationHelper.validateDeals(
      oldMap,
      newMap,
      dealPropertyMap,
      businessEntityMap,
      dealDocumentMap
    );
    Test.stopTest();
  }
}