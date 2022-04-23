@isTest
private  class CommissionDetail_Test {
    //Term Section no referrals 
    @isTest static void termCommissiontest1() {
        commissionAutomationSetting__c  settings = new commissionAutomationSetting__c (SetupOwnerId=UserInfo.getOrganizationId(), SkipProcessBuilder__c= true);
        insert settings;
        CommissionDetail_TestSkip.setDoNotRunTrigger();
        //Total Borrowed on term (account) under 5 million no split;Final Loan Amount under 5 million
        User origU = new User(
            Alias = 'orig',
            Email = 'standarduser@cvest.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Relationship Manager']
            .Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'originator@teada.com'
        );
        
        insert origU;
        
        User origU2 = new User(
            Alias = 'orig',
            Email = 'standarduser@cvest.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Relationship Manager']
            .Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'originator2@teada.com'
        );
        insert origU2;
        
        Account acc = test_Helper.createAccount();
        acc.Alternate_Phone__c = '7777777777';
        update acc;
        Contact cont = test_Helper.createContact(acc);
        cont.MobilePhone = '2222222222';
        cont.Phone = '9999999999';
        
        Opportunity topp1 = new Opportunity();
        topp1.Name = 'test';
        topp1.CloseDate = System.today();
        topp1.StageName = 'Initial Review';
        topp1.Loan_Size__c = 2000000;
        topp1.AccountId = acc.Id;
        topp1.Contact__c = cont.Id;
        topp1.OwnerId = origU.id;
        topp1.CAF_YSP__c= null;
        topp1.CAF_Upfront_Fee__c = 2;
        topp1.Final_Loan_Amount__c = 1000000;
        topp1.Deal_Intro_Source__c = 'Hotline';
        topp1.Deal_Intro_Sub_Source__c = 'Main';
        topp1.Apex_Context__c = true;
        topp1.RecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
        ]
            .Id;
        insert topp1;
        topp1.CAF_Upfront_Fee__c = 2;
        update topp1;
        //Final Loan amount under 5 million
        
        Commission_Detail__c commDetail = new Commission_Detail__c();
        commDetail.Deal__c = topp1.Id;
        commDetail.Commission_Type__c = 'Direct';
        commDetail.OwnerId = origU.Id;
        commDetail.Approval_Status__c = 'Pending';
        
        insert commDetail;
        
        test.startTest();
        
        Commission_Detail__c commDetailUpdate = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail.Id];  
        
        commDetailUpdate.Approval_Status__c = 'Approved';
        
        update commDetailUpdate;
        
        
        Commission_Detail__c commDetail1 = new Commission_Detail__c();
        commDetail1.Deal__c = topp1.Id;
        commDetail1.Commission_Type__c = 'Internal';
        commDetail1.OwnerId = origU.Id;
        commDetail1.Approval_Status__c = 'Pending';
        
        insert commDetail1;
        
        Commission_Detail__c commDetail1Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail1.Id];  
        
        commDetail1Update.Approval_Status__c = 'Approved';
        
        update commDetail1Update;
        
        
        
        //CAF YSP Section 
        
        topp1.CAF_YSP__c = '0 BPS in Spread';
        update topp1;
        
        Commission_Detail__c commDetail2 = new Commission_Detail__c();
        commDetail2.Deal__c = topp1.Id;
        commDetail2.Commission_Type__c = 'Direct';
        commDetail2.OwnerId = origU.Id;
        commDetail2.Approval_Status__c = 'Pending';
        
        insert commDetail2;
        
        Commission_Detail__c commDetail2Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail2.Id];  
        
        commDetail2Update.Approval_Status__c = 'Approved';
        
        update commDetail2Update;
        
        topp1.CAF_YSP__c = '+5 BPS in Spread / +25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail3 = new Commission_Detail__c();
        commDetail3.Deal__c = topp1.Id;
        commDetail3.Commission_Type__c = 'Direct';
        commDetail3.OwnerId = origU.Id;
        commDetail3.Approval_Status__c = 'Pending';
        
        insert commDetail3;
        
        commDetail3.Approval_Status__c = 'Approved';
        update commDetail3;
        
        topp1.CAF_YSP__c = '-5 BPS in Spread / -25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail4 = new Commission_Detail__c();
        commDetail4.Deal__c = topp1.Id;
        commDetail4.Commission_Type__c = 'Direct';
        commDetail4.OwnerId = origU.Id;
        commDetail4.Approval_Status__c = 'Pending';
        
        insert commDetail4;
        
        commDetail4.Approval_Status__c = 'Approved';
        update commDetail4;
        
        
        topp1.CAF_YSP__c = '+10 BPS in Spread / +25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail5 = new Commission_Detail__c();
        commDetail5.Deal__c = topp1.Id;
        commDetail5.Commission_Type__c = 'Direct';
        commDetail5.OwnerId = origU.Id;
        commDetail5.Approval_Status__c = 'Pending';
        
        insert commDetail5;
        
        commDetail5.Approval_Status__c = 'Approved';
        update commDetail5;
        
        
        topp1.CAF_YSP__c = '-10 BPS in Spread / -25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail6 = new Commission_Detail__c();
        commDetail6.Deal__c = topp1.Id;
        commDetail6.Commission_Type__c = 'Direct';
        commDetail6.OwnerId = origU.Id;
        commDetail6.Approval_Status__c = 'Pending';
        
        insert commDetail6;
        
        commDetail6.Approval_Status__c = 'Approved';
        update commDetail6;
        
        
        topp1.CAF_YSP__c = '+10 BPS in spread / +50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail7 = new Commission_Detail__c();
        commDetail7.Deal__c = topp1.Id;
        commDetail7.Commission_Type__c = 'Direct';
        commDetail7.OwnerId = origU.Id;
        commDetail7.Approval_Status__c = 'Pending';
        
        insert commDetail7;
                commDetail7.Approval_Status__c = 'Approved';
        update commDetail7;
        
        topp1.CAF_YSP__c = '-10 BPS in spread / -50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail8 = new Commission_Detail__c();
        commDetail8.Deal__c = topp1.Id;
        commDetail8.Commission_Type__c = 'Direct';
        commDetail8.OwnerId = origU.Id;
        commDetail8.Approval_Status__c = 'Pending';
        
        insert commDetail8;
                commDetail8.Approval_Status__c = 'Approved';
        update commDetail8;
        
        topp1.CAF_YSP__c = '+15 BPS in Spread / +50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail9 = new Commission_Detail__c();
        commDetail9.Deal__c = topp1.Id;
        commDetail9.Commission_Type__c = 'Direct';
        commDetail9.OwnerId = origU.Id;
        commDetail9.Approval_Status__c = 'Pending';
        
        insert commDetail9;
        commDetail9.Approval_Status__c = 'Approved';
        update commDetail9;
        
        topp1.CAF_YSP__c = '-15 BPS in Spread / -50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail10 = new Commission_Detail__c();
        commDetail10.Deal__c = topp1.Id;
        commDetail10.Commission_Type__c = 'Direct';
        commDetail10.OwnerId = origU.Id;
        commDetail10.Approval_Status__c = 'Pending';
        
        insert commDetail10;
        
        commDetail10.Approval_Status__c = 'Approved';
        update commDetail10;
        Test.stopTest();
        
    } 
    
    @isTest static void termCommissiontest2() {
        commissionAutomationSetting__c  settings = new commissionAutomationSetting__c (SetupOwnerId=UserInfo.getOrganizationId(), SkipProcessBuilder__c= true);
        insert settings;
        CommissionDetail_TestSkip.setDoNotRunTrigger();
        //Total Borrowed on term (account) under 5 million no split;Final Loan Amount under 5 million
        User origU = new User(
            Alias = 'orig',
            Email = 'standarduser@cvest.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Relationship Manager']
            .Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'originator@teada.com'
        );
        
        insert origU;
        
        User origU2 = new User(
            Alias = 'orig',
            Email = 'standarduser@cvest.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Relationship Manager']
            .Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'originator2@teada.com'
        );
        insert origU2;
        
        Account acc = test_Helper.createAccount();
        acc.Alternate_Phone__c = '7777777777';
        update acc;
        Contact cont = test_Helper.createContact(acc);
        cont.MobilePhone = '2222222222';
        cont.Phone = '9999999999';
        
        Opportunity topp1 = new Opportunity();
        topp1.Name = 'test';
        topp1.CloseDate = System.today();
        topp1.StageName = 'Initial Review';
        topp1.Loan_Size__c = 2000000;
        topp1.AccountId = acc.Id;
        topp1.Contact__c = cont.Id;
        topp1.OwnerId = origU.id;
        topp1.CAF_YSP__c= null;
        topp1.CAF_Upfront_Fee__c = 2;
        topp1.Final_Loan_Amount__c = 1000000;
        topp1.Deal_Intro_Source__c = 'Hotline';
        topp1.Deal_Intro_Sub_Source__c = 'Main';
        topp1.Apex_Context__c = true;
        topp1.RecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
        ]
            .Id;
        insert topp1;
        topp1.CAF_Upfront_Fee__c = 2;
        update topp1;
        //Final Loan amount under 5 million
        
        Commission_Detail__c commDetail = new Commission_Detail__c();
        commDetail.Deal__c = topp1.Id;
        commDetail.Commission_Type__c = 'Internal';
        commDetail.OwnerId = origU.Id;
        commDetail.Approval_Status__c = 'Pending';
        
        insert commDetail;
        
        test.startTest();
        
        Commission_Detail__c commDetailUpdate = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail.Id];  
        
        commDetailUpdate.Approval_Status__c = 'Approved';
        
        update commDetailUpdate;
        
        
        Commission_Detail__c commDetail1 = new Commission_Detail__c();
        commDetail1.Deal__c = topp1.Id;
        commDetail1.Commission_Type__c = 'Internal';
        commDetail1.OwnerId = origU.Id;
        commDetail1.Approval_Status__c = 'Pending';
        
        insert commDetail1;
        
        Commission_Detail__c commDetail1Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail1.Id];  
        
        commDetail1Update.Approval_Status__c = 'Approved';
        
        update commDetail1Update;
        
        
        
        //CAF YSP Section 
        
        topp1.CAF_YSP__c = '0 BPS in Spread';
        update topp1;
        
        Commission_Detail__c commDetail2 = new Commission_Detail__c();
        commDetail2.Deal__c = topp1.Id;
        commDetail2.Commission_Type__c = 'Internal';
        commDetail2.OwnerId = origU.Id;
        commDetail2.Approval_Status__c = 'Pending';
        
        insert commDetail2;
        
        Commission_Detail__c commDetail2Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail2.Id];  
        
        commDetail2Update.Approval_Status__c = 'Approved';
        
        update commDetail2Update;
        
        topp1.CAF_YSP__c = '+5 BPS in Spread / +25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail3 = new Commission_Detail__c();
        commDetail3.Deal__c = topp1.Id;
        commDetail3.Commission_Type__c = 'Internal';
        commDetail3.OwnerId = origU.Id;
        commDetail3.Approval_Status__c = 'Pending';
        
        insert commDetail3;
        
        commDetail3.Approval_Status__c = 'Approved';
        update commDetail3;
        
        topp1.CAF_YSP__c = '-5 BPS in Spread / -25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail4 = new Commission_Detail__c();
        commDetail4.Deal__c = topp1.Id;
        commDetail4.Commission_Type__c = 'Internal';
        commDetail4.OwnerId = origU.Id;
        commDetail4.Approval_Status__c = 'Pending';
        
        insert commDetail4;
        
        commDetail4.Approval_Status__c = 'Approved';
        update commDetail4;
        
        
        topp1.CAF_YSP__c = '+10 BPS in Spread / +25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail5 = new Commission_Detail__c();
        commDetail5.Deal__c = topp1.Id;
        commDetail5.Commission_Type__c = 'Internal';
        commDetail5.OwnerId = origU.Id;
        commDetail5.Approval_Status__c = 'Pending';
        
        insert commDetail5;
        
        commDetail5.Approval_Status__c = 'Approved';
        update commDetail5;
        
        
        topp1.CAF_YSP__c = '-10 BPS in Spread / -25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail6 = new Commission_Detail__c();
        commDetail6.Deal__c = topp1.Id;
        commDetail6.Commission_Type__c = 'Internal';
        commDetail6.OwnerId = origU.Id;
        commDetail6.Approval_Status__c = 'Pending';
        
        insert commDetail6;
        
        commDetail6.Approval_Status__c = 'Approved';
        update commDetail6;
        
        
        topp1.CAF_YSP__c = '+10 BPS in spread / +50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail7 = new Commission_Detail__c();
        commDetail7.Deal__c = topp1.Id;
        commDetail7.Commission_Type__c = 'Internal';
        commDetail7.OwnerId = origU.Id;
        commDetail7.Approval_Status__c = 'Pending';
        
        insert commDetail7;
                commDetail7.Approval_Status__c = 'Approved';
        update commDetail7;
        
        topp1.CAF_YSP__c = '-10 BPS in spread / -50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail8 = new Commission_Detail__c();
        commDetail8.Deal__c = topp1.Id;
        commDetail8.Commission_Type__c = 'Internal';
        commDetail8.OwnerId = origU.Id;
        commDetail8.Approval_Status__c = 'Pending';
        
        insert commDetail8;
                commDetail8.Approval_Status__c = 'Approved';
        update commDetail8;
        
        topp1.CAF_YSP__c = '+15 BPS in Spread / +50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail9 = new Commission_Detail__c();
        commDetail9.Deal__c = topp1.Id;
        commDetail9.Commission_Type__c = 'Internal';
        commDetail9.OwnerId = origU.Id;
        commDetail9.Approval_Status__c = 'Pending';
        
        insert commDetail9;
                commDetail9.Approval_Status__c = 'Approved';
        update commDetail9;
        
        topp1.CAF_YSP__c = '-15 BPS in Spread / -50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail10 = new Commission_Detail__c();
        commDetail10.Deal__c = topp1.Id;
        commDetail10.Commission_Type__c = 'Internal';
        commDetail10.OwnerId = origU.Id;
        commDetail10.Approval_Status__c = 'Pending';
        
        insert commDetail10;
        
        commDetail10.Approval_Status__c = 'Approved';
        update commDetail10;
        Test.stopTest();
        
    } 
    
    @isTest static void termCommissiontest3() {
        commissionAutomationSetting__c  settings = new commissionAutomationSetting__c (SetupOwnerId=UserInfo.getOrganizationId(), SkipProcessBuilder__c= true);
        insert settings;
        CommissionDetail_TestSkip.setDoNotRunTrigger();
        //Total Borrowed on term (account) under 5 million no split;Final Loan Amount under 5 million
        User origU = new User(
            Alias = 'orig',
            Email = 'standarduser@cvest.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Relationship Manager']
            .Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'originator@teada.com'
        );
        
        insert origU;
        
        User origU2 = new User(
            Alias = 'orig',
            Email = 'standarduser@cvest.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Relationship Manager']
            .Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'originator2@teada.com'
        );
        insert origU2;
        
        Account acc = test_Helper.createAccount();
        acc.Alternate_Phone__c = '7777777777';
        update acc;
        Contact cont = test_Helper.createContact(acc);
        cont.MobilePhone = '2222222222';
        cont.Phone = '9999999999';
        
        Opportunity topp1 = new Opportunity();
        topp1.Name = 'test';
        topp1.CloseDate = System.today();
        topp1.StageName = 'Initial Review';
        topp1.Loan_Size__c = 2000000;
        topp1.AccountId = acc.Id;
        topp1.Contact__c = cont.Id;
        topp1.OwnerId = origU.id;
        topp1.CAF_YSP__c= null;
        topp1.CAF_Upfront_Fee__c = 2;
        topp1.Final_Loan_Amount__c = 50000000;
        topp1.Deal_Intro_Source__c = 'Hotline';
        topp1.Deal_Intro_Sub_Source__c = 'Main';
        topp1.Apex_Context__c = true;
        topp1.RecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
        ]
            .Id;
        insert topp1;
        topp1.CAF_Upfront_Fee__c = 2;
        update topp1;
        //Final Loan amount under 5 million
        
        Commission_Detail__c commDetail = new Commission_Detail__c();
        commDetail.Deal__c = topp1.Id;
        commDetail.Commission_Type__c = 'Direct';
        commDetail.OwnerId = origU.Id;
        commDetail.Approval_Status__c = 'Pending';
        
        insert commDetail;
        
        test.startTest();
        
        Commission_Detail__c commDetailUpdate = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail.Id];  
        
        commDetailUpdate.Approval_Status__c = 'Approved';
        
        update commDetailUpdate;
        
        
        Commission_Detail__c commDetail1 = new Commission_Detail__c();
        commDetail1.Deal__c = topp1.Id;
        commDetail1.Commission_Type__c = 'Internal';
        commDetail1.OwnerId = origU.Id;
        commDetail1.Approval_Status__c = 'Pending';
        
        insert commDetail1;
        
        Commission_Detail__c commDetail1Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail1.Id];  
        
        commDetail1Update.Approval_Status__c = 'Approved';
        
        update commDetail1Update;
        
        
        
        //CAF YSP Section 
        
        topp1.CAF_YSP__c = '0 BPS in Spread';
        update topp1;
        
        Commission_Detail__c commDetail2 = new Commission_Detail__c();
        commDetail2.Deal__c = topp1.Id;
        commDetail2.Commission_Type__c = 'Direct';
        commDetail2.OwnerId = origU.Id;
        commDetail2.Approval_Status__c = 'Pending';
        
        insert commDetail2;
        
        Commission_Detail__c commDetail2Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail2.Id];  
        
        commDetail2Update.Approval_Status__c = 'Approved';
        
        update commDetail2Update;
        
        topp1.CAF_YSP__c = '+5 BPS in Spread / +25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail3 = new Commission_Detail__c();
        commDetail3.Deal__c = topp1.Id;
        commDetail3.Commission_Type__c = 'Direct';
        commDetail3.OwnerId = origU.Id;
        commDetail3.Approval_Status__c = 'Pending';
        
        insert commDetail3;
        
        commDetail3.Approval_Status__c = 'Approved';
        update commDetail3;
        
        topp1.CAF_YSP__c = '-5 BPS in Spread / -25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail4 = new Commission_Detail__c();
        commDetail4.Deal__c = topp1.Id;
        commDetail4.Commission_Type__c = 'Direct';
        commDetail4.OwnerId = origU.Id;
        commDetail4.Approval_Status__c = 'Pending';
        
        insert commDetail4;
        
        commDetail4.Approval_Status__c = 'Approved';
        update commDetail4;
        
        
        topp1.CAF_YSP__c = '+10 BPS in Spread / +25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail5 = new Commission_Detail__c();
        commDetail5.Deal__c = topp1.Id;
        commDetail5.Commission_Type__c = 'Direct';
        commDetail5.OwnerId = origU.Id;
        commDetail5.Approval_Status__c = 'Pending';
        
        insert commDetail5;
        
        commDetail5.Approval_Status__c = 'Approved';
        update commDetail5;
        
        
        topp1.CAF_YSP__c = '-10 BPS in Spread / -25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail6 = new Commission_Detail__c();
        commDetail6.Deal__c = topp1.Id;
        commDetail6.Commission_Type__c = 'Direct';
        commDetail6.OwnerId = origU.Id;
        commDetail6.Approval_Status__c = 'Pending';
        
        insert commDetail6;
        
        commDetail6.Approval_Status__c = 'Approved';
        update commDetail6;
        
        
        topp1.CAF_YSP__c = '+10 BPS in spread / +50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail7 = new Commission_Detail__c();
        commDetail7.Deal__c = topp1.Id;
        commDetail7.Commission_Type__c = 'Direct';
        commDetail7.OwnerId = origU.Id;
        commDetail7.Approval_Status__c = 'Pending';
        
        insert commDetail7;
                commDetail7.Approval_Status__c = 'Approved';
        update commDetail7;
        
        topp1.CAF_YSP__c = '-10 BPS in spread / -50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail8 = new Commission_Detail__c();
        commDetail8.Deal__c = topp1.Id;
        commDetail8.Commission_Type__c = 'Direct';
        commDetail8.OwnerId = origU.Id;
        commDetail8.Approval_Status__c = 'Pending';
        
        insert commDetail8;
                commDetail8.Approval_Status__c = 'Approved';
        update commDetail8;
        
        topp1.CAF_YSP__c = '+15 BPS in Spread / +50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail9 = new Commission_Detail__c();
        commDetail9.Deal__c = topp1.Id;
        commDetail9.Commission_Type__c = 'Direct';
        commDetail9.OwnerId = origU.Id;
        commDetail9.Approval_Status__c = 'Pending';
        
        insert commDetail9;
                commDetail9.Approval_Status__c = 'Approved';
        update commDetail9;
        topp1.CAF_YSP__c = '-15 BPS in Spread / -50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail10 = new Commission_Detail__c();
        commDetail10.Deal__c = topp1.Id;
        commDetail10.Commission_Type__c = 'Direct';
        commDetail10.OwnerId = origU.Id;
        commDetail10.Approval_Status__c = 'Pending';
        
        insert commDetail10;
        
        commDetail10.Approval_Status__c = 'Approved';
        update commDetail10;
        Test.stopTest();
        
    } 
    
    @isTest static void termCommissiontest4() {
        commissionAutomationSetting__c  settings = new commissionAutomationSetting__c (SetupOwnerId=UserInfo.getOrganizationId(), SkipProcessBuilder__c= true);
        insert settings;
        CommissionDetail_TestSkip.setDoNotRunTrigger();
        //Total Borrowed on term (account) under 5 million no split;Final Loan Amount under 5 million
        User origU = new User(
            Alias = 'orig',
            Email = 'standarduser@cvest.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Relationship Manager']
            .Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'originator@teada.com'
        );
        
        insert origU;
        
        User origU2 = new User(
            Alias = 'orig',
            Email = 'standarduser@cvest.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Relationship Manager']
            .Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'originator2@teada.com'
        );
        insert origU2;
        
        Account acc = test_Helper.createAccount();
        acc.Alternate_Phone__c = '7777777777';
        update acc;
        Contact cont = test_Helper.createContact(acc);
        cont.MobilePhone = '2222222222';
        cont.Phone = '9999999999';
        
        Opportunity topp1 = new Opportunity();
        topp1.Name = 'test';
        topp1.CloseDate = System.today();
        topp1.StageName = 'Initial Review';
        topp1.Loan_Size__c = 2000000;
        topp1.AccountId = acc.Id;
        topp1.Contact__c = cont.Id;
        topp1.OwnerId = origU.id;
        topp1.CAF_YSP__c= null;
        topp1.CAF_Upfront_Fee__c = 2;
        topp1.Final_Loan_Amount__c = 50000000;
        topp1.Deal_Intro_Source__c = 'Hotline';
        topp1.Deal_Intro_Sub_Source__c = 'Main';
        topp1.Apex_Context__c = true;
        topp1.RecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
        ]
            .Id;
        insert topp1;
        topp1.CAF_Upfront_Fee__c = 2;
        update topp1;
        //Final Loan amount under 5 million
        
        Commission_Detail__c commDetail = new Commission_Detail__c();
        commDetail.Deal__c = topp1.Id;
        commDetail.Commission_Type__c = 'Internal';
        commDetail.OwnerId = origU.Id;
        commDetail.Approval_Status__c = 'Pending';
        
        insert commDetail;
        
        test.startTest();
        
        Commission_Detail__c commDetailUpdate = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail.Id];  
        
        commDetailUpdate.Approval_Status__c = 'Approved';
        
        update commDetailUpdate;
        
        
        Commission_Detail__c commDetail1 = new Commission_Detail__c();
        commDetail1.Deal__c = topp1.Id;
        commDetail1.Commission_Type__c = 'Internal';
        commDetail1.OwnerId = origU.Id;
        commDetail1.Approval_Status__c = 'Pending';
        
        insert commDetail1;
        
        Commission_Detail__c commDetail1Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail1.Id];  
        
        commDetail1Update.Approval_Status__c = 'Approved';
        
        update commDetail1Update;
        
        
        
        //CAF YSP Section 
        
        topp1.CAF_YSP__c = '0 BPS in Spread';
        update topp1;
        
        Commission_Detail__c commDetail2 = new Commission_Detail__c();
        commDetail2.Deal__c = topp1.Id;
        commDetail2.Commission_Type__c = 'Internal';
        commDetail2.OwnerId = origU.Id;
        commDetail2.Approval_Status__c = 'Pending';
        
        insert commDetail2;
        
        Commission_Detail__c commDetail2Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail2.Id];  
        
        commDetail2Update.Approval_Status__c = 'Approved';
        
        update commDetail2Update;
        
        topp1.CAF_YSP__c = '+5 BPS in Spread / +25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail3 = new Commission_Detail__c();
        commDetail3.Deal__c = topp1.Id;
        commDetail3.Commission_Type__c = 'Internal';
        commDetail3.OwnerId = origU.Id;
        commDetail3.Approval_Status__c = 'Pending';
        
        insert commDetail3;
        
        commDetail3.Approval_Status__c = 'Approved';
        update commDetail3;
        
        topp1.CAF_YSP__c = '-5 BPS in Spread / -25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail4 = new Commission_Detail__c();
        commDetail4.Deal__c = topp1.Id;
        commDetail4.Commission_Type__c = 'Internal';
        commDetail4.OwnerId = origU.Id;
        commDetail4.Approval_Status__c = 'Pending';
        
        insert commDetail4;
        
        commDetail4.Approval_Status__c = 'Approved';
        update commDetail4;
        
        
        topp1.CAF_YSP__c = '+10 BPS in Spread / +25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail5 = new Commission_Detail__c();
        commDetail5.Deal__c = topp1.Id;
        commDetail5.Commission_Type__c = 'Internal';
        commDetail5.OwnerId = origU.Id;
        commDetail5.Approval_Status__c = 'Pending';
        
        insert commDetail5;
        
        commDetail5.Approval_Status__c = 'Approved';
        update commDetail5;
        
        
        topp1.CAF_YSP__c = '-10 BPS in Spread / -25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail6 = new Commission_Detail__c();
        commDetail6.Deal__c = topp1.Id;
        commDetail6.Commission_Type__c = 'Internal';
        commDetail6.OwnerId = origU.Id;
        commDetail6.Approval_Status__c = 'Pending';
        
        insert commDetail6;
        
        commDetail6.Approval_Status__c = 'Approved';
        update commDetail6;
        
        
        topp1.CAF_YSP__c = '+10 BPS in spread / +50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail7 = new Commission_Detail__c();
        commDetail7.Deal__c = topp1.Id;
        commDetail7.Commission_Type__c = 'Internal';
        commDetail7.OwnerId = origU.Id;
        commDetail7.Approval_Status__c = 'Pending';
        
        insert commDetail7;
        
        commDetail7.Approval_Status__c = 'Approved';
        update commDetail7;
        
        topp1.CAF_YSP__c = '-10 BPS in spread / -50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail8 = new Commission_Detail__c();
        commDetail8.Deal__c = topp1.Id;
        commDetail8.Commission_Type__c = 'Internal';
        commDetail8.OwnerId = origU.Id;
        commDetail8.Approval_Status__c = 'Pending';
        
        insert commDetail8;
        commDetail8.Approval_Status__c = 'Approved';
        update commDetail8;
        
        topp1.CAF_YSP__c = '+15 BPS in Spread / +50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail9 = new Commission_Detail__c();
        commDetail9.Deal__c = topp1.Id;
        commDetail9.Commission_Type__c = 'Internal';
        commDetail9.OwnerId = origU.Id;
        commDetail9.Approval_Status__c = 'Pending';
        
        insert commDetail9;
        commDetail9.Approval_Status__c = 'Approved';
        update commDetail9;
        
        topp1.CAF_YSP__c = '-15 BPS in Spread / -50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail10 = new Commission_Detail__c();
        commDetail10.Deal__c = topp1.Id;
        commDetail10.Commission_Type__c = 'Internal';
        commDetail10.OwnerId = origU.Id;
        commDetail10.Approval_Status__c = 'Pending';
        
        insert commDetail10;
        
        commDetail10.Approval_Status__c = 'Approved';
        update commDetail10;
        Test.stopTest();
        
    }
    
    // with referrals
    @isTest static void termCommissiontest5() {
        commissionAutomationSetting__c  settings = new commissionAutomationSetting__c (SetupOwnerId=UserInfo.getOrganizationId(), SkipProcessBuilder__c= true);
        insert settings;
        CommissionDetail_TestSkip.setDoNotRunTrigger();
        //Total Borrowed on term (account) under 5 million no split;Final Loan Amount under 5 million
        User origU = new User(
            Alias = 'orig',
            Email = 'standarduser@cvest.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Relationship Manager']
            .Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'originator@teada.com'
        );
        
        insert origU;
        
        User origU2 = new User(
            Alias = 'orig',
            Email = 'standarduser@cvest.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Relationship Manager']
            .Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'originator2@teada.com'
        );
        insert origU2;
        
        Account acc = test_Helper.createAccount();
        acc.Alternate_Phone__c = '7777777777';
        update acc;
        Contact cont = test_Helper.createContact(acc);
        cont.MobilePhone = '2222222222';
        cont.Phone = '9999999999';
        
        Opportunity topp1 = new Opportunity();
        topp1.Name = 'test';
        topp1.CloseDate = System.today();
        topp1.StageName = 'Initial Review';
        topp1.Loan_Size__c = 2000000;
        topp1.AccountId = acc.Id;
        topp1.Internal_Referral__c = origU2.id;
        topp1.Internal_Referral_Fee__c = '50%';
        topp1.Contact__c = cont.Id;
        topp1.OwnerId = origU.id;
        topp1.CAF_YSP__c= null;
        topp1.CAF_Upfront_Fee__c = 2;
        topp1.Final_Loan_Amount__c = 1000000;
        topp1.Deal_Intro_Source__c = 'Hotline';
        topp1.Deal_Intro_Sub_Source__c = 'Main';
        topp1.Apex_Context__c = true;
        topp1.RecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
        ]
            .Id;
        insert topp1;
        topp1.CAF_Upfront_Fee__c = 2;
        update topp1;
        //Final Loan amount under 5 million
        
        Commission_Detail__c commDetail = new Commission_Detail__c();
        commDetail.Deal__c = topp1.Id;
        commDetail.Commission_Type__c = 'Direct';
        commDetail.OwnerId = origU.Id;
        commDetail.Internal_Referral__c=origU2.Id;
        commDetail.Internal_Referral_Fee__c = '50%';
        commDetail.Approval_Status__c = 'Pending';
        
        insert commDetail;
        
        test.startTest();
        
        Commission_Detail__c commDetailUpdate = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail.Id];  
        
        commDetailUpdate.Approval_Status__c = 'Approved';
        
        update commDetailUpdate;
        
        
        Commission_Detail__c commDetail1 = new Commission_Detail__c();
        commDetail1.Deal__c = topp1.Id;
        commDetail1.Commission_Type__c = 'Internal';
        commDetail1.OwnerId = origU.Id;
        commDetail1.Internal_Referral__c=origU2.Id;
        commDetail1.Internal_Referral_Fee__c = '50%';
        commDetail1.Approval_Status__c = 'Pending';
        
        insert commDetail1;
        
        Commission_Detail__c commDetail1Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail1.Id];  
        
        commDetail1Update.Approval_Status__c = 'Approved';
        
        update commDetail1Update;
        
        
        
        //CAF YSP Section 
        
        topp1.CAF_YSP__c = '0 BPS in Spread';
        update topp1;
        
        Commission_Detail__c commDetail2 = new Commission_Detail__c();
        commDetail2.Deal__c = topp1.Id;
        commDetail2.Commission_Type__c = 'Direct';
        commDetail2.OwnerId = origU.Id;
        commDetail2.Internal_Referral__c=origU2.Id;
        commDetail2.Internal_Referral_Fee__c = '50%';
        commDetail2.Approval_Status__c = 'Pending';
        
        insert commDetail2;
        
        Commission_Detail__c commDetail2Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail2.Id];  
        
        commDetail2Update.Approval_Status__c = 'Approved';
        
        update commDetail2Update;
        
        topp1.CAF_YSP__c = '+5 BPS in Spread / +25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail3 = new Commission_Detail__c();
        commDetail3.Deal__c = topp1.Id;
        commDetail3.Commission_Type__c = 'Direct';
        commDetail3.OwnerId = origU.Id;
        commDetail3.Internal_Referral__c=origU2.Id;
        commDetail3.Internal_Referral_Fee__c = '50%';
        commDetail3.Approval_Status__c = 'Pending';
        
        insert commDetail3;
        
        commDetail3.Approval_Status__c = 'Approved';
        update commDetail3;
        
        topp1.CAF_YSP__c = '-5 BPS in Spread / -25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail4 = new Commission_Detail__c();
        commDetail4.Deal__c = topp1.Id;
        commDetail4.Commission_Type__c = 'Direct';
        commDetail4.OwnerId = origU.Id;
        commDetail4.Internal_Referral__c=origU2.Id;
        commDetail4.Internal_Referral_Fee__c = '50%';
        commDetail4.Approval_Status__c = 'Pending';
        
        insert commDetail4;
        
        commDetail4.Approval_Status__c = 'Approved';
        update commDetail4;
        
        
        topp1.CAF_YSP__c = '+10 BPS in Spread / +25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail5 = new Commission_Detail__c();
        commDetail5.Deal__c = topp1.Id;
        commDetail5.Commission_Type__c = 'Direct';
        commDetail5.OwnerId = origU.Id;
        commDetail5.Internal_Referral__c=origU2.Id;
        commDetail5.Internal_Referral_Fee__c = '50%';
        commDetail5.Approval_Status__c = 'Pending';
        
        insert commDetail5;
        
        commDetail5.Approval_Status__c = 'Approved';
        update commDetail5;
        
        
        topp1.CAF_YSP__c = '-10 BPS in Spread / -25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail6 = new Commission_Detail__c();
        commDetail6.Deal__c = topp1.Id;
        commDetail6.Commission_Type__c = 'Direct';
        commDetail6.OwnerId = origU.Id;
        commDetail6.Internal_Referral__c=origU2.Id;
        commDetail6.Internal_Referral_Fee__c = '50%';
        commDetail6.Approval_Status__c = 'Pending';
        
        insert commDetail6;
        
        commDetail6.Approval_Status__c = 'Approved';
        update commDetail6;
        
        
        topp1.CAF_YSP__c = '+10 BPS in spread / +50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail7 = new Commission_Detail__c();
        commDetail7.Deal__c = topp1.Id;
        commDetail7.Commission_Type__c = 'Direct';
        commDetail7.OwnerId = origU.Id;
        commDetail7.Internal_Referral__c=origU2.Id;
        commDetail7.Internal_Referral_Fee__c = '50%';
        commDetail7.Approval_Status__c = 'Pending';
        
        insert commDetail7;
                commDetail7.Approval_Status__c = 'Approved';

                update commDetail7;

        
        topp1.CAF_YSP__c = '-10 BPS in spread / -50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail8 = new Commission_Detail__c();
        commDetail8.Deal__c = topp1.Id;
        commDetail8.Commission_Type__c = 'Direct';
        commDetail8.OwnerId = origU.Id;
        commDetail8.Internal_Referral__c=origU2.Id;
        commDetail8.Internal_Referral_Fee__c = '50%';
        commDetail8.Approval_Status__c = 'Pending';
        
        insert commDetail8;
                commDetail8.Approval_Status__c = 'Approved';
        update commDetail8;

        
        topp1.CAF_YSP__c = '+15 BPS in Spread / +50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail9 = new Commission_Detail__c();
        commDetail9.Deal__c = topp1.Id;
        commDetail9.Commission_Type__c = 'Direct';
        commDetail9.OwnerId = origU.Id;
        commDetail9.Internal_Referral__c=origU2.Id;
        commDetail9.Internal_Referral_Fee__c = '50%';
        commDetail9.Approval_Status__c = 'Pending';
        
        insert commDetail9;
        
                commDetail9.Approval_Status__c = 'Approved';
        update commDetail9;

        topp1.CAF_YSP__c = '-15 BPS in Spread / -50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail10 = new Commission_Detail__c();
        commDetail10.Deal__c = topp1.Id;
        commDetail10.Commission_Type__c = 'Direct';
        commDetail10.OwnerId = origU.Id;
        commDetail10.Internal_Referral__c=origU2.Id;
        commDetail10.Internal_Referral_Fee__c = '50%';
        commDetail10.Approval_Status__c = 'Pending';
        
        insert commDetail10;
        
        commDetail10.Approval_Status__c = 'Approved';
        update commDetail10;
        Test.stopTest();
        
    } 
    
    @isTest static void termCommissiontest6() {
        commissionAutomationSetting__c  settings = new commissionAutomationSetting__c (SetupOwnerId=UserInfo.getOrganizationId(), SkipProcessBuilder__c= true);
        insert settings;
        CommissionDetail_TestSkip.setDoNotRunTrigger();
        //Total Borrowed on term (account) under 5 million no split;Final Loan Amount under 5 million
        User origU = new User(
            Alias = 'orig',
            Email = 'standarduser@cvest.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Relationship Manager']
            .Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'originator@teada.com'
        );
        
        insert origU;
        
        User origU2 = new User(
            Alias = 'orig',
            Email = 'standarduser@cvest.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Relationship Manager']
            .Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'originator2@teada.com'
        );
        insert origU2;
        
        Account acc = test_Helper.createAccount();
        acc.Alternate_Phone__c = '7777777777';
        update acc;
        Contact cont = test_Helper.createContact(acc);
        cont.MobilePhone = '2222222222';
        cont.Phone = '9999999999';
        
        Opportunity topp1 = new Opportunity();
        topp1.Name = 'test';
        topp1.CloseDate = System.today();
        topp1.StageName = 'Initial Review';
        topp1.Loan_Size__c = 2000000;
        topp1.AccountId = acc.Id;
        topp1.Contact__c = cont.Id;
        topp1.OwnerId = origU.id;
        topp1.Internal_Referral__c = origU2.id;
        topp1.Internal_Referral_Fee__c = '50%';
        topp1.CAF_YSP__c= null;
        topp1.CAF_Upfront_Fee__c = 2;
        topp1.Final_Loan_Amount__c = 1000000;
        topp1.Deal_Intro_Source__c = 'Hotline';
        topp1.Deal_Intro_Sub_Source__c = 'Main';
        topp1.Apex_Context__c = true;
        topp1.RecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
        ]
            .Id;
        insert topp1;
        topp1.CAF_Upfront_Fee__c = 2;
        update topp1;
        //Final Loan amount under 5 million
        
        Commission_Detail__c commDetail = new Commission_Detail__c();
        commDetail.Deal__c = topp1.Id;
        commDetail.Commission_Type__c = 'Internal';
        commDetail.OwnerId = origU.Id;
        commDetail.Internal_Referral__c=origU2.Id;
        commDetail.Internal_Referral_Fee__c = '50%';
        commDetail.Approval_Status__c = 'Pending';
        
        insert commDetail;
        
        test.startTest();
        
        Commission_Detail__c commDetailUpdate = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail.Id];  
        
        commDetailUpdate.Approval_Status__c = 'Approved';
        
        update commDetailUpdate;
        
        
        Commission_Detail__c commDetail1 = new Commission_Detail__c();
        commDetail1.Deal__c = topp1.Id;
        commDetail1.Commission_Type__c = 'Internal';
        commDetail1.OwnerId = origU.Id;
        commDetail1.Internal_Referral__c=origU2.Id;
        commDetail1.Internal_Referral_Fee__c = '50%';
        commDetail1.Approval_Status__c = 'Pending';
        
        insert commDetail1;
        
        Commission_Detail__c commDetail1Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail1.Id];  
        
        commDetail1Update.Approval_Status__c = 'Approved';
        
        update commDetail1Update;
        
        
        
        //CAF YSP Section 
        
        topp1.CAF_YSP__c = '0 BPS in Spread';
        update topp1;
        
        Commission_Detail__c commDetail2 = new Commission_Detail__c();
        commDetail2.Deal__c = topp1.Id;
        commDetail2.Commission_Type__c = 'Internal';
        commDetail2.OwnerId = origU.Id;
        commDetail2.Internal_Referral__c=origU2.Id;
        commDetail2.Internal_Referral_Fee__c = '50%';
        commDetail2.Approval_Status__c = 'Pending';
        
        insert commDetail2;
        
        Commission_Detail__c commDetail2Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail2.Id];  
        
        commDetail2Update.Approval_Status__c = 'Approved';
        
        update commDetail2Update;
        
        topp1.CAF_YSP__c = '+5 BPS in Spread / +25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail3 = new Commission_Detail__c();
        commDetail3.Deal__c = topp1.Id;
        commDetail3.Commission_Type__c = 'Internal';
        commDetail3.OwnerId = origU.Id;
        commDetail3.Internal_Referral__c=origU2.Id;
        commDetail3.Internal_Referral_Fee__c = '50%';
        commDetail3.Approval_Status__c = 'Pending';
        
        insert commDetail3;
        
        commDetail3.Approval_Status__c = 'Approved';
        update commDetail3;
        
        topp1.CAF_YSP__c = '-5 BPS in Spread / -25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail4 = new Commission_Detail__c();
        commDetail4.Deal__c = topp1.Id;
        commDetail4.Commission_Type__c = 'Internal';
        commDetail4.OwnerId = origU.Id;
        commDetail4.Internal_Referral__c=origU2.Id;
        commDetail4.Internal_Referral_Fee__c = '50%';
        commDetail4.Approval_Status__c = 'Pending';
        
        insert commDetail4;
        
        commDetail4.Approval_Status__c = 'Approved';
        update commDetail4;
        
        
        topp1.CAF_YSP__c = '+10 BPS in Spread / +25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail5 = new Commission_Detail__c();
        commDetail5.Deal__c = topp1.Id;
        commDetail5.Commission_Type__c = 'Internal';
        commDetail5.OwnerId = origU.Id;
        commDetail5.Internal_Referral__c=origU2.Id;
        commDetail5.Internal_Referral_Fee__c = '50%';
        commDetail5.Approval_Status__c = 'Pending';
        
        insert commDetail5;
        
        commDetail5.Approval_Status__c = 'Approved';
        update commDetail5;
        
        
        topp1.CAF_YSP__c = '-10 BPS in Spread / -25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail6 = new Commission_Detail__c();
        commDetail6.Deal__c = topp1.Id;
        commDetail6.Commission_Type__c = 'Internal';
        commDetail6.OwnerId = origU.Id;
        commDetail6.Internal_Referral__c=origU2.Id;
        commDetail6.Internal_Referral_Fee__c = '50%';
        commDetail6.Approval_Status__c = 'Pending';
        
        insert commDetail6;
        
        commDetail6.Approval_Status__c = 'Approved';
        update commDetail6;
        
        
        topp1.CAF_YSP__c = '+10 BPS in spread / +50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail7 = new Commission_Detail__c();
        commDetail7.Deal__c = topp1.Id;
        commDetail7.Commission_Type__c = 'Internal';
        commDetail7.OwnerId = origU.Id;
        commDetail7.Internal_Referral__c=origU2.Id;
        commDetail7.Internal_Referral_Fee__c = '50%';
        commDetail7.Approval_Status__c = 'Pending';
        
        insert commDetail7;
                commDetail7.Approval_Status__c = 'Pending';
        update commDetail7;

        
        
        topp1.CAF_YSP__c = '-10 BPS in spread / -50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail8 = new Commission_Detail__c();
        commDetail8.Deal__c = topp1.Id;
        commDetail8.Commission_Type__c = 'Internal';
        commDetail8.OwnerId = origU.Id;
        commDetail8.Internal_Referral__c=origU2.Id;
        commDetail8.Internal_Referral_Fee__c = '50%';
        commDetail8.Approval_Status__c = 'Pending';
        
        insert commDetail8;
                        commDetail8.Approval_Status__c = 'Approved';

        update commDetail8;
        topp1.CAF_YSP__c = '+15 BPS in Spread / +50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail9 = new Commission_Detail__c();
        commDetail9.Deal__c = topp1.Id;
        commDetail9.Commission_Type__c = 'Internal';
        commDetail9.OwnerId = origU.Id;
        commDetail9.Internal_Referral__c=origU2.Id;
        commDetail9.Internal_Referral_Fee__c = '50%';
        commDetail9.Approval_Status__c = 'Pending';
        
        insert commDetail9;
                commDetail9.Approval_Status__c = 'Approved';

        update commDetail9;

        topp1.CAF_YSP__c = '-15 BPS in Spread / -50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail10 = new Commission_Detail__c();
        commDetail10.Deal__c = topp1.Id;
        commDetail10.Commission_Type__c = 'Internal';
        commDetail10.OwnerId = origU.Id;
        commDetail10.Internal_Referral__c=origU2.Id;
        commDetail10.Internal_Referral_Fee__c = '50%';
        commDetail10.Approval_Status__c = 'Pending';
        
        insert commDetail10;
        
        commDetail10.Approval_Status__c = 'Approved';
        update commDetail10;
        Test.stopTest();
        
    } 
    
    @isTest static void termCommissiontest7() {
        commissionAutomationSetting__c  settings = new commissionAutomationSetting__c (SetupOwnerId=UserInfo.getOrganizationId(), SkipProcessBuilder__c= true);
        insert settings;
        CommissionDetail_TestSkip.setDoNotRunTrigger();
        //Total Borrowed on term (account) under 5 million no split;Final Loan Amount under 5 million
        User origU = new User(
            Alias = 'orig',
            Email = 'standarduser@cvest.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Relationship Manager']
            .Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'originator@teada.com'
        );
        
        insert origU;
        
        User origU2 = new User(
            Alias = 'orig',
            Email = 'standarduser@cvest.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Relationship Manager']
            .Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'originator2@teada.com'
        );
        insert origU2;
        
        Account acc = test_Helper.createAccount();
        acc.Alternate_Phone__c = '7777777777';
        update acc;
        Contact cont = test_Helper.createContact(acc);
        cont.MobilePhone = '2222222222';
        cont.Phone = '9999999999';
        
        Opportunity topp1 = new Opportunity();
        topp1.Name = 'test';
        topp1.CloseDate = System.today();
        topp1.StageName = 'Initial Review';
        topp1.Loan_Size__c = 2000000;
        topp1.AccountId = acc.Id;
        topp1.Contact__c = cont.Id;
        topp1.OwnerId = origU.id;
        topp1.CAF_YSP__c= null;
        topp1.Internal_Referral__c = origU2.id;
        topp1.Internal_Referral_Fee__c = '50%';
        topp1.CAF_Upfront_Fee__c = 2;
        topp1.Final_Loan_Amount__c = 50000000;
        topp1.Deal_Intro_Source__c = 'Hotline';
        topp1.Deal_Intro_Sub_Source__c = 'Main';
        topp1.Apex_Context__c = true;
        topp1.RecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
        ]
            .Id;
        insert topp1;
        topp1.CAF_Upfront_Fee__c = 2;
        update topp1;
        //Final Loan amount under 5 million
        
        Commission_Detail__c commDetail = new Commission_Detail__c();
        commDetail.Deal__c = topp1.Id;
        commDetail.Commission_Type__c = 'Direct';
        commDetail.OwnerId = origU.Id;
        commDetail.Internal_Referral__c=origU2.Id;
        commDetail.Internal_Referral_Fee__c = '50%';
        commDetail.Approval_Status__c = 'Pending';
        
        insert commDetail;
        
        test.startTest();
        
        Commission_Detail__c commDetailUpdate = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail.Id];  
        
        commDetailUpdate.Approval_Status__c = 'Approved';
        
        update commDetailUpdate;
        
        
        Commission_Detail__c commDetail1 = new Commission_Detail__c();
        commDetail1.Deal__c = topp1.Id;
        commDetail1.Commission_Type__c = 'Internal';
        commDetail1.OwnerId = origU.Id;
        commDetail1.Internal_Referral__c=origU2.Id;
        commDetail1.Internal_Referral_Fee__c = '50%';
        commDetail1.Approval_Status__c = 'Pending';
        
        insert commDetail1;
        
        Commission_Detail__c commDetail1Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail1.Id];  
        
        commDetail1Update.Approval_Status__c = 'Approved';
        
        update commDetail1Update;
        
        
        
        //CAF YSP Section 
        
        topp1.CAF_YSP__c = '0 BPS in Spread';
        update topp1;
        
        Commission_Detail__c commDetail2 = new Commission_Detail__c();
        commDetail2.Deal__c = topp1.Id;
        commDetail2.Commission_Type__c = 'Direct';
        commDetail2.OwnerId = origU.Id;
        commDetail2.Internal_Referral__c=origU2.Id;
        commDetail2.Internal_Referral_Fee__c = '50%';
        commDetail2.Approval_Status__c = 'Pending';
        
        insert commDetail2;
        
        Commission_Detail__c commDetail2Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail2.Id];  
        
        commDetail2Update.Approval_Status__c = 'Approved';
        
        update commDetail2Update;
        
        topp1.CAF_YSP__c = '+5 BPS in Spread / +25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail3 = new Commission_Detail__c();
        commDetail3.Deal__c = topp1.Id;
        commDetail3.Commission_Type__c = 'Direct';
        commDetail3.OwnerId = origU.Id;
        commDetail3.Internal_Referral__c=origU2.Id;
        commDetail3.Internal_Referral_Fee__c = '50%';
        commDetail3.Approval_Status__c = 'Pending';
        
        insert commDetail3;
        
        commDetail3.Approval_Status__c = 'Approved';
        update commDetail3;
        
        topp1.CAF_YSP__c = '-5 BPS in Spread / -25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail4 = new Commission_Detail__c();
        commDetail4.Deal__c = topp1.Id;
        commDetail4.Commission_Type__c = 'Direct';
        commDetail4.OwnerId = origU.Id;
        commDetail4.Internal_Referral__c=origU2.Id;
        commDetail4.Internal_Referral_Fee__c = '50%';
        commDetail4.Approval_Status__c = 'Pending';
        
        insert commDetail4;
        
        commDetail4.Approval_Status__c = 'Approved';
        update commDetail4;
        
        
        topp1.CAF_YSP__c = '+10 BPS in Spread / +25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail5 = new Commission_Detail__c();
        commDetail5.Deal__c = topp1.Id;
        commDetail5.Commission_Type__c = 'Direct';
        commDetail5.OwnerId = origU.Id;
        commDetail5.Internal_Referral__c=origU2.Id;
        commDetail5.Internal_Referral_Fee__c = '50%';
        commDetail5.Approval_Status__c = 'Pending';
        
        insert commDetail5;
        
        commDetail5.Approval_Status__c = 'Approved';
        update commDetail5;
        
        
        topp1.CAF_YSP__c = '-10 BPS in Spread / -25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail6 = new Commission_Detail__c();
        commDetail6.Deal__c = topp1.Id;
        commDetail6.Commission_Type__c = 'Direct';
        commDetail6.OwnerId = origU.Id;
        commDetail6.Internal_Referral__c=origU2.Id;
        commDetail6.Internal_Referral_Fee__c = '50%';
        commDetail6.Approval_Status__c = 'Pending';
        
        insert commDetail6;
        
        commDetail6.Approval_Status__c = 'Approved';
        update commDetail6;
        
        
        topp1.CAF_YSP__c = '+10 BPS in spread / +50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail7 = new Commission_Detail__c();
        commDetail7.Deal__c = topp1.Id;
        commDetail7.Commission_Type__c = 'Direct';
        commDetail7.OwnerId = origU.Id;
        commDetail7.Internal_Referral__c=origU2.Id;
        commDetail7.Internal_Referral_Fee__c = '50%';
        commDetail7.Approval_Status__c = 'Pending';
        
        insert commDetail7;
                commDetail7.Approval_Status__c = 'Approved';
        update commDetail7;

        topp1.CAF_YSP__c = '-10 BPS in spread / -50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail8 = new Commission_Detail__c();
        commDetail8.Deal__c = topp1.Id;
        commDetail8.Commission_Type__c = 'Direct';
        commDetail8.OwnerId = origU.Id;
        commDetail8.Internal_Referral__c=origU2.Id;
        commDetail8.Internal_Referral_Fee__c = '50%';
        commDetail8.Approval_Status__c = 'Pending';

        insert commDetail8;
                  commDetail8.Approval_Status__c = 'Approved';
        update commDetail8;
        
        topp1.CAF_YSP__c = '+15 BPS in Spread / +50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail9 = new Commission_Detail__c();
        commDetail9.Deal__c = topp1.Id;
        commDetail9.Commission_Type__c = 'Direct';
        commDetail9.OwnerId = origU.Id;
        commDetail9.Internal_Referral__c=origU2.Id;
        commDetail9.Internal_Referral_Fee__c = '50%';
        commDetail9.Approval_Status__c = 'Pending';
        
        insert commDetail9;
                  commDetail9.Approval_Status__c = 'Approved';
        update commDetail9;
        
        topp1.CAF_YSP__c = '-15 BPS in Spread / -50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail10 = new Commission_Detail__c();
        commDetail10.Deal__c = topp1.Id;
        commDetail10.Commission_Type__c = 'Direct';
        commDetail10.OwnerId = origU.Id;
        commDetail10.Internal_Referral__c=origU2.Id;
        commDetail10.Internal_Referral_Fee__c = '50%';
        commDetail10.Approval_Status__c = 'Pending';
        
        insert commDetail10;
        
        commDetail10.Approval_Status__c = 'Approved';
        update commDetail10;
        Test.stopTest();
        
    } 
    
    @isTest static void termCommissiontest8() {
        commissionAutomationSetting__c  settings = new commissionAutomationSetting__c (SetupOwnerId=UserInfo.getOrganizationId(), SkipProcessBuilder__c= true);
        insert settings;
        CommissionDetail_TestSkip.setDoNotRunTrigger();
        //Total Borrowed on term (account) under 5 million no split;Final Loan Amount under 5 million
        User origU = new User(
            Alias = 'orig',
            Email = 'standarduser@cvest.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Relationship Manager']
            .Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'originator@teada.com'
        );
        
        insert origU;
        
        User origU2 = new User(
            Alias = 'orig',
            Email = 'standarduser@cvest.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Relationship Manager']
            .Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'originator2@teada.com'
        );
        insert origU2;
        
        Account acc = test_Helper.createAccount();
        acc.Alternate_Phone__c = '7777777777';
        update acc;
        Contact cont = test_Helper.createContact(acc);
        cont.MobilePhone = '2222222222';
        cont.Phone = '9999999999';
        
        Opportunity topp1 = new Opportunity();
        topp1.Name = 'test';
        topp1.CloseDate = System.today();
        topp1.StageName = 'Initial Review';
        topp1.Loan_Size__c = 2000000;
        topp1.AccountId = acc.Id;
        topp1.Contact__c = cont.Id;
        topp1.Internal_Referral__c = origU2.id;
        topp1.Internal_Referral_Fee__c = '50%';
        topp1.OwnerId = origU.id;
        topp1.CAF_YSP__c= null;
        topp1.CAF_Upfront_Fee__c = 2;
        topp1.Final_Loan_Amount__c = 50000000;
        topp1.Deal_Intro_Source__c = 'Hotline';
        topp1.Deal_Intro_Sub_Source__c = 'Main';
        topp1.Apex_Context__c = true;
        topp1.RecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
        ]
            .Id;
        insert topp1;
        topp1.CAF_Upfront_Fee__c = 2;
        update topp1;
        //Final Loan amount under 5 million
        
        Commission_Detail__c commDetail = new Commission_Detail__c();
        commDetail.Deal__c = topp1.Id;
        commDetail.Commission_Type__c = 'Internal';
        commDetail.OwnerId = origU.Id;
        commDetail.Approval_Status__c = 'Pending';
        
        insert commDetail;
        
        test.startTest();
        
        Commission_Detail__c commDetailUpdate = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail.Id];  
        
        commDetailUpdate.Approval_Status__c = 'Approved';
        
        update commDetailUpdate;
        
        
        Commission_Detail__c commDetail1 = new Commission_Detail__c();
        commDetail1.Deal__c = topp1.Id;
        commDetail1.Commission_Type__c = 'Internal';
        commDetail1.OwnerId = origU.Id;
        commDetail1.Internal_Referral__c=origU2.Id;
        commDetail1.Internal_Referral_Fee__c = '50%';
        commDetail1.Approval_Status__c = 'Pending';
        
        insert commDetail1;
        
        Commission_Detail__c commDetail1Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail1.Id];  
        
        commDetail1Update.Approval_Status__c = 'Approved';
        
        update commDetail1Update;
        
        
        
        //CAF YSP Section 
        
        topp1.CAF_YSP__c = '0 BPS in Spread';
        update topp1;
        
        Commission_Detail__c commDetail2 = new Commission_Detail__c();
        commDetail2.Deal__c = topp1.Id;
        commDetail2.Commission_Type__c = 'Internal';
        commDetail2.OwnerId = origU.Id;
                commDetail2.Internal_Referral__c=origU2.Id;
        commDetail2.Internal_Referral_Fee__c = '50%';
        commDetail2.Approval_Status__c = 'Pending';
        
        insert commDetail2;
        
        Commission_Detail__c commDetail2Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail2.Id];  
        
        commDetail2Update.Approval_Status__c = 'Approved';
        
        update commDetail2Update;
        
        topp1.CAF_YSP__c = '+5 BPS in Spread / +25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail3 = new Commission_Detail__c();
        commDetail3.Deal__c = topp1.Id;
        commDetail3.Commission_Type__c = 'Internal';
        commDetail3.OwnerId = origU.Id;        
        commDetail3.Internal_Referral__c=origU2.Id;
        commDetail3.Internal_Referral_Fee__c = '50%';
        commDetail3.Approval_Status__c = 'Pending';
        
        insert commDetail3;
        
        commDetail3.Approval_Status__c = 'Approved';
        update commDetail3;
        
        topp1.CAF_YSP__c = '-5 BPS in Spread / -25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail4 = new Commission_Detail__c();
        commDetail4.Deal__c = topp1.Id;
        commDetail4.Commission_Type__c = 'Internal';
        commDetail4.OwnerId = origU.Id;
        commDetail4.Internal_Referral__c=origU2.Id;
        commDetail4.Internal_Referral_Fee__c = '50%';
        commDetail4.Approval_Status__c = 'Pending';
        
        insert commDetail4;
        
        commDetail4.Approval_Status__c = 'Approved';
        update commDetail4;
        
        
        topp1.CAF_YSP__c = '+10 BPS in Spread / +25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail5 = new Commission_Detail__c();
        commDetail5.Deal__c = topp1.Id;
        commDetail5.Commission_Type__c = 'Internal';
        commDetail5.OwnerId = origU.Id;
                commDetail5.Internal_Referral__c=origU2.Id;
        commDetail5.Internal_Referral_Fee__c = '50%';
        commDetail5.Approval_Status__c = 'Pending';
        
        insert commDetail5;
        
        commDetail5.Approval_Status__c = 'Approved';
        update commDetail5;
        
        
        topp1.CAF_YSP__c = '-10 BPS in Spread / -25 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail6 = new Commission_Detail__c();
        commDetail6.Deal__c = topp1.Id;
        commDetail6.Commission_Type__c = 'Internal';
        commDetail6.OwnerId = origU.Id;
        commDetail6.Internal_Referral__c=origU2.Id;
        commDetail6.Internal_Referral_Fee__c = '50%';
        commDetail6.Approval_Status__c = 'Pending';
        
        insert commDetail6;
        
        commDetail6.Approval_Status__c = 'Approved';
        update commDetail6;
        
        
        topp1.CAF_YSP__c = '+10 BPS in spread / +50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail7 = new Commission_Detail__c();
        commDetail7.Deal__c = topp1.Id;
        commDetail7.Commission_Type__c = 'Internal';
        commDetail7.OwnerId = origU.Id;
               commDetail7.Internal_Referral__c=origU2.Id;
        commDetail7.Internal_Referral_Fee__c = '50%';
        commDetail7.Approval_Status__c = 'Pending';
        
        insert commDetail7;
        
                commDetail7.Approval_Status__c = 'Approved';
        update commDetail7;

        
        topp1.CAF_YSP__c = '-10 BPS in spread / -50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail8 = new Commission_Detail__c();
        commDetail8.Deal__c = topp1.Id;
        commDetail8.Commission_Type__c = 'Internal';
        commDetail8.OwnerId = origU.Id;
        commDetail8.Internal_Referral__c=origU2.Id;
        commDetail8.Internal_Referral_Fee__c = '50%';
        commDetail8.Approval_Status__c = 'Pending';
        
        insert commDetail8;
                commDetail8.Approval_Status__c = 'Approved';
        update commDetail8;

        
        topp1.CAF_YSP__c = '+15 BPS in Spread / +50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail9 = new Commission_Detail__c();
        commDetail9.Deal__c = topp1.Id;
        commDetail9.Commission_Type__c = 'Internal';
        commDetail9.OwnerId = origU.Id;
        commDetail9.Internal_Referral__c=origU2.Id;
        commDetail9.Internal_Referral_Fee__c = '50%';
        commDetail9.Approval_Status__c = 'Pending';
        
        insert commDetail9;
        
                commDetail9.Approval_Status__c = 'Approved';
        update commDetail9;

        
        topp1.CAF_YSP__c = '-15 BPS in Spread / -50 BPS in Commissionable Fee';
        update topp1;
        
        
        Commission_Detail__c commDetail10 = new Commission_Detail__c();
        commDetail10.Deal__c = topp1.Id;
        commDetail10.Commission_Type__c = 'Internal';
        commDetail10.OwnerId = origU.Id;
               commDetail10.Internal_Referral__c=origU2.Id;
        commDetail10.Internal_Referral_Fee__c = '50%';
        commDetail10.Approval_Status__c = 'Pending';
        
        insert commDetail10;
        
        commDetail10.Approval_Status__c = 'Approved';
        update commDetail10;
        Test.stopTest();
        
    }
    
    //Bridge Section
    @isTest static void termCommissiontestBridge2() {
        commissionAutomationSetting__c  settings = new commissionAutomationSetting__c (SetupOwnerId=UserInfo.getOrganizationId(), SkipProcessBuilder__c= true);
        insert settings;
        CommissionDetail_TestSkip.setDoNotRunTrigger();
        
        //Total Borrowed on term (account) under 5 million no split;Final Loan Amount under 5 million
        User origU = new User(
            Alias = 'orig',
            Email = 'standarduser@cvest.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Relationship Manager']
            .Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'originator@teada.com'
        );
        
        insert origU;
        
        User origU2 = new User(
            Alias = 'orig',
            Email = 'standarduser@cvest.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Relationship Manager']
            .Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'originator2@teada.com'
        );
        insert origU2;
        
        Account acc = test_Helper.createAccount();
        acc.Alternate_Phone__c = '7777777777';
        update acc;
        Contact cont = test_Helper.createContact(acc);
        cont.MobilePhone = '2222222222';
        cont.Phone = '9999999999';
        
        Opportunity topp1 = new Opportunity();
        topp1.Name = 'test';
        topp1.CloseDate = System.today();
        topp1.StageName = 'Initial Review';
        topp1.Loan_Size__c = 2000000;
        topp1.AccountId = acc.Id;
        topp1.Contact__c = cont.Id;
        topp1.OwnerId = origU.id;
        topp1.CAF_YSP__c= null;
        topp1.CAF_Upfront_Fee__c = 2;
        topp1.Final_Loan_Amount__c = 1000000;
        topp1.Deal_Intro_Source__c = 'Hotline';
        topp1.Deal_Intro_Sub_Source__c = 'Main';
        topp1.Apex_Context__c = true;
        topp1.RecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'LOC_Loan'
        ]
            .Id;
        insert topp1;
        
        
        Commission__c comm = new Commission__c();
        
        comm.Owner__c = origU.id;
        comm.Deal__c = topp1.Id;
        
        insert comm;
        
        Commission_Detail__c commDetail1 = new Commission_Detail__c();
        commDetail1.Deal__c = topp1.Id;
        commDetail1.Commission_Type__c = 'Internal';
        commDetail1.OwnerId = origU.Id;
        commDetail1.Internal_Referral__c = origU.Id;
        commDetail1.Internal_Referral_Fee__c = '50%';
        commDetail1.Approval_Status__c = 'Pending';
        
        test.startTest();
        
        insert commDetail1;
        
        commDetail1.Approval_Status__c = 'Approved';
        
        Commission__c comm2 = new Commission__c();
        
        comm2.Owner__c = origU.id;
        comm2.Deal__c = topp1.Id;
        insert comm2;
        
        update commDetail1;
        
        test.stopTest();
        
    } 
    

}