@istest
public class Opportunity_Tests_Additional2 {
@testsetup
static void datasetup()
{
    List<Account> al = new List<Account>();
    Account a = new Account();
    a.Name = 'Berkadia Commercial Mortgage';
    a.BillingCountry = 'United States';
    a.BillingState = 'California';
    a.Introductions_Source__c = 'Hotline';
    a.Introduction_Subsource__c = 'Main';
    a.Alternate_Phone__c = '5555555555';
    al.add(a);
    Contact cont0 = test_Helper.createContact(a);
    
    Opportunity opp = new Opportunity();
    opp.Name = 'TERM TEST 1';
    opp.CloseDate = System.today();
    opp.Rate_Locked__c = false;
    opp.Term_Loan_Type__c = '5 Year';
    opp.StageName = 'Initial Review';
    opp.Loan_Size__c = 2000000;
    opp.AccountId = al[0].Id;
    opp.Contact__c = cont0.Id;
    opp.Final_Loan_Amount__c = 100;
    opp.Apex_Context__c = true;
    Id id1 = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
    ]
    .Id;
    opp.RecordTypeId = id1;
    
///////////////////////////////////////////////////////    
    
    Account a1 = new Account();
    a1.Name = 'Statebridge Company, LLC';
    a1.BillingCountry = 'United States';
    a1.BillingState = 'California';
    a1.Introductions_Source__c = 'Hotline';
    a1.Introduction_Subsource__c = 'Main';
    a1.Alternate_Phone__c = '5555555555';
    al.add(a1);
    Contact cont1 = test_Helper.createContact(a1);
    
     Opportunity opp1 = new Opportunity();
    opp1.Name = 'TERM TEST 2';
    opp1.CloseDate = System.today();
    opp1.Rate_Locked__c = false;
    opp1.Term_Loan_Type__c = '7 Year';
    opp1.StageName = 'Initial Review';
    opp1.Loan_Size__c = 2000000;
    opp1.AccountId = al[1].Id;
    opp1.Contact__c = cont1.Id;
    opp1.Final_Loan_Amount__c = 100;
    opp1.Apex_Context__c = true;
 	Id id2 = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Bridge'
    ].Id;    
    opp1.RecordTypeId = id2;
    
//////////////////////////////////////////////////////////////    
    
Account a3 = new Account();
    a3.Name = 'Churchill Real Estate';
    a3.BillingCountry = 'United States';
    a3.BillingState = 'California';
    a3.Introductions_Source__c = 'Hotline';
    a3.Introduction_Subsource__c = 'Main';
    a3.Alternate_Phone__c = '5555555555';
    al.add(a3);
    insert al;
    Contact cont3 = test_Helper.createContact(a3);  
    
    Account a2 = new Account();
    a2.Name = 'FCI Lender Services';
    a2.BillingCountry = 'United States';
    a2.BillingState = 'California';
    a2.Introductions_Source__c = 'Hotline';
    a2.Introduction_Subsource__c = 'Main';
    a2.Alternate_Phone__c = '5555555555';
    al.add(a2);
    insert al;
    Contact cont2 = test_Helper.createContact(a2);
    
    Opportunity opp2 = new Opportunity();
    opp2.Name = 'TERM TEST 3';
    opp2.CloseDate = System.today();
    opp2.Rate_Locked__c = false;
    opp2.Term_Loan_Type__c = '10 Year';
    opp2.StageName = 'Initial Review';
    opp2.Loan_Size__c = 2000000;
    opp2.AccountId = al[4].Id;
    opp2.Contact__c = cont3.Id;
    opp2.Final_Loan_Amount__c = 100;
    opp2.Apex_Context__c = true;
	Id id3 = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Investor DSCR'
    ].Id;     
    opp2.RecordTypeId = id3;

///////////////////////////////////////////////    
	  

    Opportunity opp3 = new Opportunity();
    opp3.Name = 'TERM TEST 4';
    opp3.CloseDate = System.today();
    opp3.Rate_Locked__c = false;
    opp3.Term_Loan_Type__c = '30 Year';
    opp3.StageName = 'Initial Review';
    opp3.Loan_Size__c = 2000000;
    opp3.AccountId = al[3].Id;
    opp3.Contact__c = cont2.Id;
    opp3.Final_Loan_Amount__c = 100;
    opp3.Apex_Context__c = true;
    opp3.RecordTypeId = id3;

    Opportunity opp4 = new Opportunity();
    opp4.Name = 'TERM TEST 5';
    opp4.CloseDate = System.today();
    opp4.Rate_Locked__c = false;
    opp4.Term_Loan_Type__c = '5 Year';
    opp4.StageName = 'Initial Review';
    opp4.Loan_Size__c = 2000000;
    opp4.AccountId = al[4].Id;
    opp4.Contact__c = cont1.Id;
    opp4.Final_Loan_Amount__c = 100;
    opp4.Apex_Context__c = true;
    opp4.Floor__c = 10;
    opp4.RecordTypeId = id1;

    List<Opportunity> oppLst = new List<Opportunity>();
    oppLst.add(opp);
    oppLst.add(opp1);
    oppLst.add(opp2);
    oppLst.add(opp3);
    oppLst.add(opp4);
    insert oppLst;    
}        
}