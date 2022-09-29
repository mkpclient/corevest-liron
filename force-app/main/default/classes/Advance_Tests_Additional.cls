@isTest
public class Advance_Tests_Additional {
  @testsetup
  static void datasetup() {
    test_Helper.createDealLoanNumber();
    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
    List<Opportunity> oppList = new List<Opportunity>();
    Opportunity opp = new Opportunity();
    Opportunity opp1 = new Opportunity();
    opp.Name = 'test';
    opp.CloseDate = System.today();
    opp.StageName = 'Initial Review';
    opp.Loan_Size__c = 2000000;
    opp.AccountId = acc.Id;
    opp.Contact__c = cont.Id;
    opp.Deal_Intro_Source__c = 'Hotline';
    opp.Deal_Intro_Sub_Source__c = 'Main';
    opp.Apex_Context__c = true;
    opp.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
    ]
    .Id;
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
    opp.Maturity_Date_Calculation_Type__c = 'Fixed at Closing';
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
    opp.Product_Sub_Type__c = 'No Renovation';
    opp.Interest_Rate_Type__c = 'Floating';
    opp.Index__c = '1M LIBOR';
    opp.Commission_Type__c = 'Internal';
    opp.Index_Floor__c = '1.00%';
    opp.Index_Margin__c = 1.50;
    opp.Deal_Intro_Source__c = 'Hotline';
    opp.Deal_Intro_Sub_source__c = 'Direct Mail';
    opp.Fee__c = 2;
    opp.Warehouse_Line__c = 'MS3';
    opp1.Name = 'test1';
    opp1.CloseDate = System.today();
    opp1.StageName = 'Initial Review';
    opp1.Loan_Size__c = 2000000;
    opp1.AccountId = acc.Id;
    opp1.Contact__c = cont.Id;
    opp1.Deal_Intro_Source__c = 'Hotline';
    opp1.Deal_Intro_Sub_Source__c = 'Main';
    opp1.Apex_Context__c = true;
    opp1.AccountId = acc.id;
    opp1.Contact__c = cont.id;
    opp1.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'LOC_Loan'
    ]
    .Id;
    opp1.StageName = 'Closed Won';
    opp1.Draw_Period__c = '12 Months';
    opp1.Repayment_Period__c = '9 Months';
    opp1.LOC_Loan_Type__c = 'Credit Line';
    opp1.Loan_Size__c = 3000000;
    opp1.Maturity_Date_Calculation_Type__c = 'Fixed at Closing';
    opp1.Line_Expiration__c = '18 Months';
    opp1.Requested_LTC_Max__c = 70;
    opp1.Requested_LTV_Max__c = 80;
    opp1.Requested_Origination_Fee__c = 0;
    opp1.Requested_Draw_Fee__c = 2;
    opp1.Requested_Exit_Fee__c = 0;
    opp1.Requested_Interest_Type__c = 'Fixed';
    opp1.Requested_Rate_1_9_Months__c = 10;
    opp1.Requested_Revolving__c = 'Yes';
    opp1.Requested_Draw_Fee_Cap__c = 'None';
    opp1.Product_Sub_Type__c = 'No Renovation';
    opp1.Interest_Rate_Type__c = 'Floating';
    opp1.Index__c = '1M LIBOR';
    opp1.Warehouse_Line__c = 'MS3';
    opp1.Commission_Type__c = 'Internal';
    opp1.Index_Floor__c = '1.00%';
    opp1.Index_Margin__c = 1.50;
    opp1.Deal_Intro_Source__c = 'Hotline';
    opp1.Deal_Intro_Sub_source__c = 'Direct Mail';
    opp1.Fee__c = 2;
    opp1.Aggregate_Funding__c = 55000000;
    opp1.Loan_Effective_Date__c = system.today().addDays(-3);
    opp1.CloseDate = system.today().addDays(-3);
    oppList.add(opp);
    oppList.add(opp1);
    insert oppList;
    property__c property = new Property__c();
    property.Name = 'Test1';
    property.Deal__c = oppList[0].Id;
    property.Escrow_Company_text__c = 'ESCROW';
    property.Insurance_Company_text__c = 'INSURANCE';
    property.Status__c = 'Closing';
    property.Override_Origination_Fee__c = 1000;
    property.Acquisition_Price__c = 600000;
    property.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE
        sobjecttype = 'Property__c'
        AND DeveloperName = 'Bridge_No_Renovation'
    ]
    .Id;
    insert property;
  }

  static testMethod void advance_Tests_method2() {
    Opportunity opp = [
      SELECT id
      FROM Opportunity
      WHERE StageName = 'Hold'
      LIMIT 1
    ];
    Property__c property = [SELECT id FROM Property__c LIMIT 1];
    Advance__c adv = new Advance__c(
      Deal__c = opp.Id,
      Status__c = 'Pending',
      Closing_Funds_Checklist__c = true,
      Manager_Approved__c = true,
      Evidence_of_Insurance_Approved__c = true,
      Flood_Certificate_Approved__c = true
    );
    insert adv;
    adv.Closing_Funds_Checklist__c = false;
    adv.Manager_Approved__c = false;
    adv.Evidence_of_Insurance_Approved__c = false;
    adv.Flood_Certificate_Approved__c = false;

    // update adv;

    Test.startTest();
    Profile prof = [select id from profile where name = 'System Administrator'];
    User u = new User(alias = 'standt', email = 'testFeedItemDelete@testorg.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = prof.Id, timezonesidkey = 'America/Los_Angeles', username = 'testFeedItemDelete@testorg.com');
    System.runAs(u) {
      try {
        adv.Wire_Date__c = system.today();
        adv.Status__c = 'Completed';
        system.debug('subtotal adv' + adv.Advance_and_Origination_Fee_Subtotal__c);
        update adv;
      } catch (Exception err) {
        //
      }
    }
    adv.Wire_Date__c = system.today();
    adv.Status__c = 'Completed';
    system.debug('subtotal adv' + adv.Advance_and_Origination_Fee_Subtotal__c);
    update adv;
    //system.debug('Deal Amount' + opp.Amount);
    Test.stopTest();
  }

  static testMethod void advance_Tests_method3() {
    Opportunity opp = [
      SELECT id
      FROM Opportunity
      WHERE StageName = 'Hold'
      LIMIT 1
    ];
    Property__c property = [SELECT id FROM Property__c LIMIT 1];
    Advance__c adv = new Advance__c(
      Deal__c = opp.Id,
      Status__c = 'Pending',
      Closing_Funds_Checklist__c = true,
      Manager_Approved__c = true,
      Evidence_of_Insurance_Approved__c = true,
      Flood_Certificate_Approved__c = true
    );
    insert adv;

    Test.startTest();
    adv.Advance_Group_Name__c = 'Another Group Test';
    update adv;
    //system.debug('Deal Amount' + opp.Amount);
    Test.stopTest();
  }
}