@isTest
private  class ClearBaseTest {
    @isTest static void testMethod1() {
        test_Helper.createDealLoanNumber();

        Account a = new Account();
        a.Name = 'test';
        a.BillingCountry = 'United States';
        a.BillingState = 'California';
        a.Introductions_Source__c = 'Hotline';
        a.Introduction_Subsource__c = 'Main';
        a.Alternate_Phone__c = '5555555555';
        insert a;
        
        Contact c = new Contact();
        c.FirstName = 'Daniel';
        c.LastName = 'Galli';
        c.MailingCountry = 'United States';
        c.MailingState = 'California';
        c.AccountId = a.Id;
        c.MobilePhone = '5555555555';
        c.Phone = '7777777777';
        c.SponsorHomeAddress__c = '1024 Washington Ave';
        c.SponsorState__c = 'Maine';
        c.SponsorCity__c = 'Portland';
        c.SponsorZipCode__c = '04103-2779';
        insert c;
        
        Opportunity o = new Opportunity();
        o.Name = 'test';
        o.CloseDate = System.today();
        o.StageName = 'Initial Review';
        o.Loan_Size__c = 2000000;
        o.AccountId = a.Id;
        o.Contact__c = c.Id;
        o.Deal_Intro_Source__c = 'Hotline';
        o.Deal_Intro_Sub_Source__c = 'Main';
        o.Apex_Context__c = true;
        o.RecordTypeId = [
          SELECT Id
          FROM RecordType
          WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
        ]
        .Id;
        insert o;
        
        Deal_Contact__c dealContact = new Deal_Contact__c();
        dealContact.Deal__c = o.id;
        dealContact.Contact__c = c.id;
        insert dealContact;
        
        Clear_Result__c cr = new Clear_Result__c();
        cr.akaFirstName__c = 'DANIEL';
        cr.akaLastName__c = 'GALLI';
        cr.EntityId__c = 'P1__NDExNjYyNTQ4';
        cr.Contact__c = c.id;
        cr.Group_ID_for_Person_Search__c = '01852a301b8a47428b36ad4979d6e921';
        cr.Group_ID_for_Risk_search__c = '9dda314682dd43a5a682b6d45bcf247c';
        insert cr;
        
        ClearBase.getContactDetailforPersonSearch(c.id,false,false,false,false,false);
        ClearBase.getContactDetailforRiskSearch(dealContact.id);
        ClearBase.GetReport(dealContact.id,'PersonSearchReport',o.id);
    }
    
    @isTest static void testMethod2() {
      test_Helper.createDealLoanNumber();

        Account a = new Account();
        a.Name = 'test';
        a.BillingCountry = 'United States';
        a.BillingState = 'California';
        a.Introductions_Source__c = 'Hotline';
        a.Introduction_Subsource__c = 'Main';
        a.Alternate_Phone__c = '5555555555';
        insert a;
        
        Contact c = new Contact();
        c.FirstName = 'Daniel';
        c.LastName = 'Galli';
        c.MailingCountry = 'United States';
        c.MailingState = 'California';
        c.AccountId = a.Id;
        c.MobilePhone = '5555555555';
        c.Phone = '7777777777';
        c.SponsorHomeAddress__c = '1024 Washington Ave';
        c.SponsorState__c = 'Maine';
        c.SponsorCity__c = 'Portland';
        c.SponsorZipCode__c = '04103-2779';
        insert c;
        
        Opportunity o = new Opportunity();
        o.Name = 'test';
        o.CloseDate = System.today();
        o.StageName = 'Initial Review';
        o.Loan_Size__c = 2000000;
        o.AccountId = a.Id;
        o.Contact__c = c.Id;
        o.Deal_Intro_Source__c = 'Hotline';
        o.Deal_Intro_Sub_Source__c = 'Main';
        o.Apex_Context__c = true;
        o.RecordTypeId = [
          SELECT Id
          FROM RecordType
          WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
        ]
        .Id;
        insert o;
        
        Deal_Contact__c dealContact = new Deal_Contact__c();
        dealContact.Deal__c = o.id;
        dealContact.Contact__c = c.id;
        insert dealContact;
        
        Clear_Result__c cr = new Clear_Result__c();
        cr.akaFirstName__c = 'DANIEL';
        cr.akaLastName__c = 'GALLI';
        cr.EntityId__c = 'P1__NDExNjYyNTQ4';
        cr.Contact__c = c.id;
        cr.Group_ID_for_Person_Search__c = '01852a301b8a47428b36ad4979d6e921';
        cr.Group_ID_for_Risk_search__c = '9dda314682dd43a5a682b6d45bcf247c';
        insert cr;
        
        list<string> conIdList = new list<string>();
        conIdList.add(c.id);
        
        ClearBase.getEntityId(conIdList);
        ClearBase.getContactDetailforRiskSearch(dealContact.id);
        ClearBase.riskReport(c.id);
    }
    
    @isTest static void testMethod3() {
      test_Helper.createDealLoanNumber();
  
        Account a = new Account();
        a.Name = 'test';
        a.BillingCountry = 'United States';
        a.BillingState = 'California';
        a.Introductions_Source__c = 'Hotline';
        a.Introduction_Subsource__c = 'Main';
        a.Alternate_Phone__c = '5555555555';
        insert a;
        
        Contact c = new Contact();
        c.FirstName = 'Daniel';
        c.LastName = 'Galli';
        c.MailingCountry = 'United States';
        c.MailingState = 'California';
        c.AccountId = a.Id;
        c.MobilePhone = '5555555555';
        c.Phone = '7777777777';
        c.SponsorHomeAddress__c = '1024 Washington Ave';
        c.SponsorState__c = 'Maine';
        c.SponsorCity__c = 'Portland';
        c.SponsorZipCode__c = '04103-2779';
        insert c;
        
        Opportunity o = new Opportunity();
        o.Name = 'test';
        o.CloseDate = System.today();
        o.StageName = 'Initial Review';
        o.Loan_Size__c = 2000000;
        o.AccountId = a.Id;
        o.Contact__c = c.Id;
        o.Deal_Intro_Source__c = 'Hotline';
        o.Deal_Intro_Sub_Source__c = 'Main';
        o.Apex_Context__c = true;
        o.RecordTypeId = [
          SELECT Id
          FROM RecordType
          WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
        ]
        .Id;
        insert o;
        
        Deal_Contact__c dealContact = new Deal_Contact__c();
        dealContact.Deal__c = o.id;
        dealContact.Contact__c = c.id;
        insert dealContact;
        
        Clear_Result__c cr = new Clear_Result__c();
        cr.akaFirstName__c = 'DANIEL';
        cr.akaLastName__c = 'GALLI';
        cr.EntityId__c = 'P1__NDExNjYyNTQ4';
        cr.Contact__c = c.id;
        cr.Group_ID_for_Person_Search__c = '01852a301b8a47428b36ad4979d6e921';
        cr.Group_ID_for_Risk_search__c = '9dda314682dd43a5a682b6d45bcf247c';
        insert cr;
        
        list<string> conIdList = new list<string>();
        conIdList.add(c.id);
        
        ClearBase.GetReport(dealContact.id,'RiskSearchReport',o.id);
    }
    
    @isTest static void testMethod4() {
      test_Helper.createDealLoanNumber();
   
        Account a = new Account();
        a.Name = 'test';
        a.BillingCountry = 'United States';
        a.BillingState = 'California';
        a.Introductions_Source__c = 'Hotline';
        a.Introduction_Subsource__c = 'Main';
        a.Alternate_Phone__c = '5555555555';
        insert a;
        
        Contact c = new Contact();
        c.FirstName = 'Daniel';
        c.LastName = 'Galli';
        c.MailingCountry = 'United States';
        c.MailingState = 'California';
        c.AccountId = a.Id;
        c.MobilePhone = '5555555555';
        c.Phone = '7777777777';
        c.SponsorHomeAddress__c = '1024 Washington Ave';
        c.SponsorState__c = 'Maine';
        c.SponsorCity__c = 'Portland';
        c.SponsorZipCode__c = '04103-2779';
        insert c;
        
        Opportunity o = new Opportunity();
        o.Name = 'test';
        o.CloseDate = System.today();
        o.StageName = 'Initial Review';
        o.Loan_Size__c = 2000000;
        o.AccountId = a.Id;
        o.Contact__c = c.Id;
        o.Deal_Intro_Source__c = 'Hotline';
        o.Deal_Intro_Sub_Source__c = 'Main';
        o.Apex_Context__c = true;
        o.RecordTypeId = [
          SELECT Id
          FROM RecordType
          WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
        ]
        .Id;
        insert o;
        
        Deal_Contact__c dealContact = new Deal_Contact__c();
        dealContact.Deal__c = o.id;
        dealContact.Contact__c = c.id;
        insert dealContact;
        
        Clear_Result__c cr = new Clear_Result__c();
        cr.akaFirstName__c = 'DANIEL';
        cr.akaLastName__c = 'GALLI';
        cr.EntityId__c = 'P1__NDExNjYyNTQ4';
        cr.Contact__c = c.id;
        cr.Group_ID_for_Person_Search__c = '01852a301b8a47428b36ad4979d6e921';
        cr.Group_ID_for_Risk_search__c = '9dda314682dd43a5a682b6d45bcf247c';
        insert cr;
        
        Deal_Document__c dealDoc = new Deal_Document__c();
        dealDoc.Contact__c = c.id;
        dealDoc.Clear_Result_Report_Type__c = 'PersonSearchReport';
        insert dealDoc;
        
        ClearBase.GetReport(dealContact.id,'PersonSearchReport',o.id);
        
    }
}