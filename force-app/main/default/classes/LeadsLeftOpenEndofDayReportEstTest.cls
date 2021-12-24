@isTest

private class LeadsLeftOpenEndofDayReportEstTest {
    @isTest static void LeadsLeftOpenEndofDayReportAlertEst(){
                Profile profileDetail = [SELECT Id FROM Profile WHERE Name='Standard User'];
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId;
        User oneUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = profileDetail.Id, IsActive = true,
            TimeZoneSidKey='America/New_York', UserName=uniqueName + '@test' + orgId + '.org');
        insert oneUser;
        
        list<id> leadList = new list<id>();
        lead l = new lead();
        l.FirstName = 'test1';
        l.LastName = 'test1lastname';
        l.Company = 'test1company';
        l.Introduction_Source__c = 'Email Blast';
        l.Status = 'Open';
        l.ownerId = oneUser.id;
 
        insert l;
        
        
         test.starttest();
         LeadsLeftOpenEndofDayReportEst myClass = new LeadsLeftOpenEndofDayReportEst ();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Sched', chron, myClass);
         System.debug(myClass);
         test.stopTest();
    }

}