@isTest
private class UpdateDocusignActiveStatus_UT {

    @TestSetup
    static void makeData(){
        dsfs__DocuSign_Status__c oneStatus = new dsfs__DocuSign_Status__c(dsfs__Sender_Email__c = 'standarduser@testorg.com');
        insert oneStatus;
    }

    public static testMethod void testRunAs() {
        Profile profileDetail = [SELECT Id FROM Profile WHERE Name='Standard User'];
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId;
        User oneUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = profileDetail.Id, IsActive = true,
            TimeZoneSidKey='America/Los_Angeles', UserName=uniqueName + '@test' + orgId + '.org');
        insert oneUser;
        oneUser.IsActive = false;
        update oneUser;
    }
}