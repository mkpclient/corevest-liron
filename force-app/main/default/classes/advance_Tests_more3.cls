@isTest
public class advance_Tests_more3 {

    @testsetup static void datasetup()
    {
    Account acc = test_Helper.createAccount();
    System.debug('RS999-1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
	System.debug('RS999-2.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
	System.debug('RS999-3. Number of script statements used so far : ' + Limits.getDmlStatements());         
    Contact cont = test_Helper.createContact(acc);
    System.debug('RS999-4.Number of Queries used in this apex code so far: ' + Limits.getQueries());
	System.debug('RS999-5.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
	System.debug('RS999-6. Number of script statements used so far : ' + Limits.getDmlStatements());         
    Opportunity opp = test_Helper.createOpportunity(acc, cont);
    System.debug('RS999-7.Number of Queries used in this apex code so far: ' + Limits.getQueries());
	System.debug('RS999-8.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
	System.debug('RS999-9. Number of script statements used so far : ' + Limits.getDmlStatements()); 
        
    opp.Apex_Context__c = true;
    opp.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Single_Asset_Bridge_Loan'
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
    opp.Internal_Referral__c = UserInfo.getUserId();
    opp.Internal_Referral_Fee__c = '20%';
    opp.Commission_Type__c = 'Internal';
    opp.Index_Floor__c = '1.00%';
    opp.Index_Margin__c = 1.50;
    opp.Deal_Intro_Source__c = 'Hotline';
    opp.Deal_Intro_Sub_source__c = 'Direct Mail';
    opp.Fee__c = 2;

    update opp;
    System.debug('RS999-13.Number of Queries used in this apex code so far: ' + Limits.getQueries());
	System.debug('RS999-14.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
	System.debug('RS999-15. Number of script statements used so far : ' + Limits.getDmlStatements());
    Property__c property = new Property__c();
    property.Name = 'Test1';
    property.Deal__c = opp.Id;
    property.Escrow_Company_text__c = 'ESCROW';
    property.Insurance_Company_text__c = 'INSURANCE';
    property.Status__c = 'Pending';
    property.Override_Origination_Fee__c = 1000;
    property.Acquisition_Price__c = 800000;
    property.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE
        sobjecttype = 'Property__c'
        AND DeveloperName = 'Bridge_No_Renovation'
    ]
    .Id;
    insert property;
    System.debug('RS999-16.Number of Queries used in this apex code so far: ' + Limits.getQueries());
	System.debug('RS999-17.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
	System.debug('RS999-18. Number of script statements used so far : ' + Limits.getDmlStatements());
    
           
    }
    
 /*   static testMethod void advance_Tests_method1()
    {
   // Opportunity opp = [select id from Opportunity];
   Test.startTest();
    Property__c property = [Select id from Property__c Limit 1];  
    Advance__c adv = [Select id from Advance__c Limit 1];
    System.debug('RS999 - adv : ' +adv);
    System.debug('RS999 - apropertydv : ' +property);
    Property_Advance__c padv = new Property_Advance__c();
    padv.Property__c = property.Id;
    padv.Advance__c = adv.Id;
    padv.Advance_Fee__c = 1000;
    padv.Initial_Disbursement__c = 500000;
    padv.Renovation_Reserve__c = 500000;
    padv.Origination_Fee__c = 1000;
    insert padv;
    Test.stopTest();
    System.debug('RS999-13.Number of Queries used in this apex code so far: ' + Limits.getQueries());
	System.debug('RS999-14.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
	System.debug('RS999-15. Number of script statements used so far : ' + Limits.getDmlStatements());   
    }*/
    
    static testMethod void advance_Tests_method2() {
    //direct
    //Advance__c adv = [Select id from Advance__c Limit 1];
    Opportunity opp = [select id from Opportunity Limit 1];
    Property__c property = [Select id from Property__c Limit 1];    
    System.debug('RS999-19.Number of Queries used in this apex code so far: ' + Limits.getQueries());
	System.debug('RS999-20.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
	System.debug('RS999-21. Number of script statements used so far : ' + Limits.getDmlStatements());
    System.debug('RS999 property : ' +opp);
    System.debug('RS999 property : ' +opp);
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
        adv.Manager_Approved__c = True;
        update adv;
    System.debug('RS999-22.Number of Queries used in this apex code so far: ' + Limits.getQueries());
	System.debug('RS999-23.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
	System.debug('RS999-24. Number of script statements used so far : ' + Limits.getDmlStatements());
   /*  Property_Advance__c padv = new Property_Advance__c();
    padv.Property__c = property.Id;
    padv.Advance__c = adv.Id;
    padv.Advance_Fee__c = 1000;
    padv.Initial_Disbursement__c = 500000;
    padv.Renovation_Reserve__c = 500000;
    padv.Origination_Fee__c = 1000;

    insert padv;
    System.debug('RS999 - adv : ' +adv);
    System.debug('RS999-25.Number of Queries used in this apex code so far: ' + Limits.getQueries());
	System.debug('RS999-26.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
	System.debug('RS999-27. Number of script statements used so far : ' + Limits.getDmlStatements());*/
	Test.startTest();
    adv.Wire_Date__c = system.today();
    adv.Status__c = 'Completed';
    system.debug('subtotal adv' + adv.Advance_and_Origination_Fee_Subtotal__c);
    update adv;
    //system.debug('Deal Amount' + opp.Amount);
    Test.stopTest();
  }

}