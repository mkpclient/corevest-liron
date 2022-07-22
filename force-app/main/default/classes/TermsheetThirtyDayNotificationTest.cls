@isTest

private class TermsheetThirtyDayNotificationTest {
    @isTest static void TermsheetThirtyDayNotificationTestMethod(){
Profile profileDetail = [SELECT Id FROM Profile WHERE Name='Standard User'];
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId;
        String uniqueName1=orgId+dateString+RandomId+'1';
        String uniqueName2=orgId+dateString+RandomId+'2';

            
        User oneUser = new User(Alias = 'standt', Email='standarduser@cvest.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = profileDetail.Id, IsActive = true,
        TimeZoneSidKey='America/New_York', UserName=uniqueName + '@test' + orgId + '.org');
        insert oneUser;
        
        User twoUser = new User(Alias = 'standt', Email='standarduser1@cvest.com', 
        EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = profileDetail.Id, IsActive = false,
        TimeZoneSidKey='America/New_York', UserName=uniqueName1 + '@test' + orgId + '.org');
        insert twoUser;
        
        User threeUser = new User(Alias = 'standt', Email='standarduser2@cvest.com', 
        EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = profileDetail.Id, IsActive = true,
        TimeZoneSidKey='America/New_York', UserName=uniqueName2 + '@test' + orgId + '.org');
        insert threeUser;
        
test_Helper.createDealLoanNumber();


	Account a = new Account();
    a.Name = 'Alston & Bird';
    a.BillingCountry = 'United States';
    a.BillingState = 'California';
    a.Introductions_Source__c = 'Hotline';
    a.Introduction_Subsource__c = 'Main';
    a.Alternate_Phone__c = '55555555355';
    a.OwnerId = oneUser.id;
	a.In_Litigation__c = false;
	a.Do_Not_Lend__c = false;
	a.In_Foreclosure__c = false;
        
    insert a;

Contact cont = test_Helper.createContact(a); 
        
       
       
 Opportunity bridgedeal = new opportunity();
    bridgedeal.Pres_Deal_Id__c = '123';
    bridgedeal.name = 'test opp';
    bridgedeal.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'LOC_Loan'
    ]
    .Id;
    bridgedeal.LOC_Loan_Type__c = 'Credit Line';
     bridgedeal.Type = 'Bridge Loan';
    bridgedeal.Product_Sub_Type__c = 'Renovation';
    bridgedeal.LOC_Commitment__c = 3000000;
    bridgedeal.StageName = 'Closed Won';
    bridgedeal.Maturity_Date_Calculation_Type__c = 'Fixed at Closing';
    bridgedeal.LOC_Term__c = '12 Months';
    bridgedeal.CloseDate = Date.newInstance(2014, 4, 17);
    bridgedeal.Loan_Effective_Date__c = Date.newInstance(2014, 4, 17);
    bridgedeal.AccountId = a.Id;
    bridgedeal.Contact__c = cont.Id;
    bridgedeal.Underwriter__c = twoUser.Id;
    bridgedeal.Requested_ARV_LTV__c = 75;
    bridgedeal.Requested_Max_Reno_Cost_Reimbursement__c = 70;
    bridgedeal.Requested_Reno_Limit__c = 90;
    bridgedeal.Requested_Total_Loan_LTC__c = 80;
    bridgedeal.Term_Sheet_Signed__c = System.today().addDays(-30);
    bridgedeal.OwnerId = oneUser.id;
        bridgedeal.Loan_Coordinator__c=oneUser.id;
 bridgedeal.Closer__c= threeUser.id;
    insert bridgedeal;
        
        
         test.startTest();
         TermsheetThirtyDayNotification myClass = new TermsheetThirtyDayNotification();   
         String chron = '0 0 21 * * ?';        
         system.schedule('Test Sched', chron, myClass);
         System.debug(myClass);
         test.stopTest();        
        
    }
        @isTest static void TermsheetThirtyDayNotificationTestMethod1(){
Profile profileDetail = [SELECT Id FROM Profile WHERE Name='Standard User'];
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId;
        String uniqueName1=orgId+dateString+RandomId+'1';
        String uniqueName2=orgId+dateString+RandomId+'2';

            
        User oneUser = new User(Alias = 'standt', Email='standarduser@cvest.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = profileDetail.Id, IsActive = true,
        TimeZoneSidKey='America/New_York', UserName=uniqueName + '@test' + orgId + '.org');
        insert oneUser;
        
        User twoUser = new User(Alias = 'standt', Email='standarduser1@cvest.com', 
        EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = profileDetail.Id, IsActive = false,
        TimeZoneSidKey='America/New_York', UserName=uniqueName1 + '@test' + orgId + '.org');
        insert twoUser;
        
        User threeUser = new User(Alias = 'standt', Email='standarduser2@cvest.com', 
        EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = profileDetail.Id, IsActive = true,
        TimeZoneSidKey='America/New_York', UserName=uniqueName2 + '@test' + orgId + '.org');
        insert threeUser;
        
test_Helper.createDealLoanNumber();


	Account a = new Account();
    a.Name = 'Alston & Bird';
    a.BillingCountry = 'United States';
    a.BillingState = 'California';
    a.Introductions_Source__c = 'Hotline';
    a.Introduction_Subsource__c = 'Main';
    a.Alternate_Phone__c = '55555555355';
    a.OwnerId = oneUser.id;
	a.In_Litigation__c = false;
	a.Do_Not_Lend__c = false;
	a.In_Foreclosure__c = false;
        
    insert a;

Contact cont = test_Helper.createContact(a); 
        
       
       
    Opportunity topp1 = new Opportunity();
    topp1.Name = 'TERM TEST 123';
    topp1.CloseDate = System.today();
    topp1.StageName = 'Initial Review';
    topp1.Loan_Size__c = 2000000;
    topp1.AccountId = a.Id;
    topp1.Contact__c = cont.Id;
    topp1.Final_Loan_Amount__c = 100;
    topp1.Deal_Intro_Source__c = 'Hotline';
    topp1.Deal_Intro_Sub_Source__c = 'Main';
    topp1.Apex_Context__c = true;
    topp1.Term_Loan_Type__c = '5 Year';
    topp1.YM_Prepayment_Penalty__c = '48 Months';
    topp1.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
    ]
    .Id;
    topp1.Term_Sheet_Signed__c = System.today().addDays(-30);

    insert topp1;
        
        
         test.startTest();
         TermsheetThirtyDayNotification myClass = new TermsheetThirtyDayNotification();   
         String chron = '0 0 21 * * ?';        
         system.schedule('Test Sched', chron, myClass);
         System.debug(myClass);
         test.stopTest();        
        
    }
}