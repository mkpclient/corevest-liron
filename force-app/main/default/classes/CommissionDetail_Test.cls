@isTest
private class CommissionDetail_Test {
    
  @testSetup
  static void makeData(){ 
    Test_Helper.createDealLoanNumber();
  }

  @isTest
  static void termCommissiontest1() {
    commissionAutomationSetting__c settings = new commissionAutomationSetting__c(
      SetupOwnerId = UserInfo.getOrganizationId(),
      SkipProcessBuilder__c = true
    );
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
    topp1.CAF_YSP__c = null;
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

    Commission_Detail__c commDetailUpdate = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail.Id
    ];

    commDetailUpdate.Approval_Status__c = 'Approved';

    update commDetailUpdate;

    Commission_Detail__c commDetail1 = new Commission_Detail__c();
    commDetail1.Deal__c = topp1.Id;
    commDetail1.Commission_Type__c = 'Internal';
    commDetail1.OwnerId = origU.Id;
    commDetail1.Approval_Status__c = 'Pending';

    insert commDetail1;

    Commission_Detail__c commDetail1Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail1.Id
    ];

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

    Commission_Detail__c commDetail2Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail2.Id
    ];

    commDetail2Update.Approval_Status__c = 'Approved';

    update commDetail2Update;

    Commission_Detail__c commDetail3 = new Commission_Detail__c();
    commDetail3.Deal__c = topp1.Id;
    commDetail3.Commission_Type__c = 'Internal';
    commDetail3.OwnerId = origU.Id;
    commDetail3.Approval_Status__c = 'Pending';

    insert commDetail3;

    Commission_Detail__c commDetail3Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail3.Id
    ];

    commDetail3Update.Approval_Status__c = 'Approved';

    update commDetail3Update;

    //+5 BPS in Spread / +25 BPS in Commissionable Fee

    topp1.CAF_YSP__c = '+5 BPS in Spread / +25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail4 = new Commission_Detail__c();
    commDetail4.Deal__c = topp1.Id;
    commDetail4.Commission_Type__c = 'Direct';
    commDetail4.OwnerId = origU.Id;
    commDetail4.Approval_Status__c = 'Pending';

    insert commDetail4;

    Commission_Detail__c commDetail4Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail4.Id
    ];

    commDetail4Update.Approval_Status__c = 'Approved';

    update commDetail4Update;

    Commission_Detail__c commDetail5 = new Commission_Detail__c();
    commDetail5.Deal__c = topp1.Id;
    commDetail5.Commission_Type__c = 'Internal';
    commDetail5.OwnerId = origU.Id;
    commDetail5.Approval_Status__c = 'Pending';

    insert commDetail5;

    Commission_Detail__c commDetail5Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail5.Id
    ];

    commDetail5Update.Approval_Status__c = 'Approved';

    update commDetail5Update;

    //-5 BPS in Spread / -25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-5 BPS in Spread / -25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail6 = new Commission_Detail__c();
    commDetail6.Deal__c = topp1.Id;
    commDetail6.Commission_Type__c = 'Direct';
    commDetail6.OwnerId = origU.Id;
    commDetail6.Approval_Status__c = 'Pending';

    insert commDetail6;

    Commission_Detail__c commDetail6Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail6.Id
    ];

    commDetail6Update.Approval_Status__c = 'Approved';

    update commDetail6Update;

    Commission_Detail__c commDetail7 = new Commission_Detail__c();
    commDetail7.Deal__c = topp1.Id;
    commDetail7.Commission_Type__c = 'Internal';
    commDetail7.OwnerId = origU.Id;
    commDetail7.Approval_Status__c = 'Pending';

    insert commDetail7;

    Commission_Detail__c commDetail7Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail7.Id
    ];

    commDetail7Update.Approval_Status__c = 'Approved';

    update commDetail7Update;

    //+10 BPS in Spread / +25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+10 BPS in Spread / +25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail8 = new Commission_Detail__c();
    commDetail8.Deal__c = topp1.Id;
    commDetail8.Commission_Type__c = 'Direct';
    commDetail8.OwnerId = origU.Id;
    commDetail8.Approval_Status__c = 'Pending';

    insert commDetail8;

    Commission_Detail__c commDetail8Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail8.Id
    ];

    commDetail8Update.Approval_Status__c = 'Approved';

    update commDetail8Update;

    Commission_Detail__c commDetail9 = new Commission_Detail__c();
    commDetail9.Deal__c = topp1.Id;
    commDetail9.Commission_Type__c = 'Internal';
    commDetail9.OwnerId = origU.Id;
    commDetail9.Approval_Status__c = 'Pending';

    insert commDetail9;

    Commission_Detail__c commDetail9Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail9.Id
    ];

    commDetail9Update.Approval_Status__c = 'Approved';

    update commDetail9Update;

    //-10 BPS in Spread / -25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-10 BPS in Spread / -25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail10 = new Commission_Detail__c();
    commDetail10.Deal__c = topp1.Id;
    commDetail10.Commission_Type__c = 'Direct';
    commDetail10.OwnerId = origU.Id;
    commDetail10.Approval_Status__c = 'Pending';

    insert commDetail10;

    Commission_Detail__c commDetail10Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail10.Id
    ];

    commDetail10Update.Approval_Status__c = 'Approved';

    update commDetail10Update;

    Commission_Detail__c commDetail11 = new Commission_Detail__c();
    commDetail11.Deal__c = topp1.Id;
    commDetail11.Commission_Type__c = 'Internal';
    commDetail11.OwnerId = origU.Id;
    commDetail11.Approval_Status__c = 'Pending';

    insert commDetail11;

    Commission_Detail__c commDetail11Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail11.Id
    ];

    commDetail11Update.Approval_Status__c = 'Approved';

    update commDetail11Update;

    //+10 BPS in spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+10 BPS in spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail12 = new Commission_Detail__c();
    commDetail12.Deal__c = topp1.Id;
    commDetail12.Commission_Type__c = 'Direct';
    commDetail12.OwnerId = origU.Id;
    commDetail12.Approval_Status__c = 'Pending';

    insert commDetail12;

    Commission_Detail__c commDetail12Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail12.Id
    ];

    commDetail12Update.Approval_Status__c = 'Approved';

    update commDetail12Update;

    Commission_Detail__c commDetail13 = new Commission_Detail__c();
    commDetail13.Deal__c = topp1.Id;
    commDetail13.Commission_Type__c = 'Internal';
    commDetail13.OwnerId = origU.Id;
    commDetail13.Approval_Status__c = 'Pending';

    insert commDetail13;

    Commission_Detail__c commDetail13Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail13.Id
    ];

    commDetail13Update.Approval_Status__c = 'Approved';

    update commDetail13Update;

    //-10 BPS in spread / -50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-10 BPS in spread / -50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail14 = new Commission_Detail__c();
    commDetail14.Deal__c = topp1.Id;
    commDetail14.Commission_Type__c = 'Direct';
    commDetail14.OwnerId = origU.Id;
    commDetail14.Approval_Status__c = 'Pending';

    insert commDetail14;

    Commission_Detail__c commDetail14Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail14.Id
    ];

    commDetail14Update.Approval_Status__c = 'Approved';

    update commDetail14Update;

    Commission_Detail__c commDetail15 = new Commission_Detail__c();
    commDetail15.Deal__c = topp1.Id;
    commDetail15.Commission_Type__c = 'Internal';
    commDetail15.OwnerId = origU.Id;
    commDetail15.Approval_Status__c = 'Pending';

    insert commDetail15;

    Commission_Detail__c commDetail15Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail15.Id
    ];

    commDetail15Update.Approval_Status__c = 'Approved';

    update commDetail15Update;

    //+15 BPS in Spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+15 BPS in Spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail16 = new Commission_Detail__c();
    commDetail16.Deal__c = topp1.Id;
    commDetail16.Commission_Type__c = 'Direct';
    commDetail16.OwnerId = origU.Id;
    commDetail16.Approval_Status__c = 'Pending';

    insert commDetail16;

    Commission_Detail__c commDetail16Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail16.Id
    ];

    commDetail16Update.Approval_Status__c = 'Approved';

    update commDetail16Update;

    Commission_Detail__c commDetail17 = new Commission_Detail__c();
    commDetail17.Deal__c = topp1.Id;
    commDetail17.Commission_Type__c = 'Internal';
    commDetail17.OwnerId = origU.Id;
    commDetail17.Approval_Status__c = 'Pending';

    insert commDetail17;

    Commission_Detail__c commDetail17Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail17.Id
    ];

    commDetail17Update.Approval_Status__c = 'Approved';

    update commDetail17Update;

    //-15 BPS in Spread / -50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-15 BPS in Spread / -50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail18 = new Commission_Detail__c();
    commDetail18.Deal__c = topp1.Id;
    commDetail18.Commission_Type__c = 'Direct';
    commDetail18.OwnerId = origU.Id;
    commDetail18.Approval_Status__c = 'Pending';

    insert commDetail18;

    Commission_Detail__c commDetail18Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail18.Id
    ];

    commDetail18Update.Approval_Status__c = 'Approved';

    update commDetail18Update;

    Commission_Detail__c commDetail19 = new Commission_Detail__c();
    commDetail19.Deal__c = topp1.Id;
    commDetail19.Commission_Type__c = 'Internal';
    commDetail19.OwnerId = origU.Id;
    commDetail19.Approval_Status__c = 'Pending';

    insert commDetail19;

    Commission_Detail__c commDetail19Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail19.Id
    ];

    commDetail19Update.Approval_Status__c = 'Approved';

    update commDetail19Update;

    /*        //+20 BPS in Spread / +50 BPS in Commissionable Fee
topp1.CAF_YSP__c = '+20 BPS in Spread / +50 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail20 = new Commission_Detail__c();
    commDetail20.Deal__c = topp1.Id;
    commDetail20.Commission_Type__c = 'Direct';
    commDetail20.OwnerId = origU.Id;
    commDetail20.Approval_Status__c = 'Pending';
     
    insert commDetail20;
        
         Commission_Detail__c commDetail20Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail20.Id limit 1];  
              
    commDetail20Update.Approval_Status__c = 'Approved';
        
        update commDetail20Update; */

    /* 
        
    Commission_Detail__c commDetail21 = new Commission_Detail__c();
    commDetail21.Deal__c = topp1.Id;
    commDetail21.Commission_Type__c = 'Internal';
    commDetail21.OwnerId = origU.Id;
    commDetail21.Approval_Status__c = 'Pending';
     
    insert commDetail21;
        
            
         Commission_Detail__c commDetail21Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail21.Id];  
              
    commDetail21Update.Approval_Status__c = 'Approved';
        
        update commDetail21Update;

      

        
        //-20 BPS in Spread / -50 BPS in Commissionable Fee
        topp1.CAF_YSP__c = '-20 BPS in Spread / -50 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail22 = new Commission_Detail__c();
    commDetail22.Deal__c = topp1.Id;
    commDetail22.Commission_Type__c = 'Direct';
    commDetail22.OwnerId = origU.Id;
    commDetail22.Approval_Status__c = 'Pending';
     
    insert commDetail22;
        
         Commission_Detail__c commDetail22Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail22.Id];  
              
    commDetail22Update.Approval_Status__c = 'Approved';
        
        update commDetail22Update;

        

        

    Commission_Detail__c commDetail23 = new Commission_Detail__c();
    commDetail23.Deal__c = topp1.Id;
    commDetail23.Commission_Type__c = 'Internal';
    commDetail23.OwnerId = origU.Id;
    commDetail23.Approval_Status__c = 'Pending';
     
    insert commDetail23;
        
          Commission_Detail__c commDetail23Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail23.Id];  
              
    commDetail23Update.Approval_Status__c = 'Approved';
        
        update commDetail23Update; */

    Test.stopTest();
  }
  /* @isTest static void termCommissiontest2() {
        commissionAutomationSetting__c  settings = new commissionAutomationSetting__c (SetupOwnerId=UserInfo.getOrganizationId(), SkipProcessBuilder__c= true);
insert settings;
                CommissionDetail_TestSkip.setDoNotRunTrigger();
        //Total Borrowed on term (account) under 5 million split ‘50%’;Final Loan Amount under 5 million
        
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
        
    //Final Loan amount under 5 million
    
    Commission_Detail__c commDetail = new Commission_Detail__c();
    commDetail.Deal__c = topp1.Id;
    commDetail.Commission_Type__c = 'Direct';
    commDetail.OwnerId = origU.Id;
    commDetail.Internal_Referral__c = origU2.Id;
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
    commDetail1.Internal_Referral__c = origU2.Id;
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
    commDetail2.Internal_Referral__c = origU2.Id;
    commDetail2.Internal_Referral_Fee__c = '50%';
    commDetail2.Approval_Status__c = 'Pending';
     
    insert commDetail2;
        
         Commission_Detail__c commDetail2Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail2.Id];  
              
    commDetail2Update.Approval_Status__c = 'Approved';
        
        update commDetail2Update;

        
    Commission_Detail__c commDetail3 = new Commission_Detail__c();
    commDetail3.Deal__c = topp1.Id;
    commDetail3.Commission_Type__c = 'Internal';
    commDetail3.OwnerId = origU.Id;
    commDetail3.Internal_Referral__c = origU2.Id;
    commDetail3.Internal_Referral_Fee__c = '50%';
    commDetail3.Approval_Status__c = 'Pending';
     
    insert commDetail3;
        
            
  Commission_Detail__c commDetail3Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail3.Id];  
              
    commDetail3Update.Approval_Status__c = 'Approved';
        
        update commDetail3Update;

        
        //+5 BPS in Spread / +25 BPS in Commissionable Fee
        
      topp1.CAF_YSP__c = '+5 BPS in Spread / +25 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail4 = new Commission_Detail__c();
    commDetail4.Deal__c = topp1.Id;
    commDetail4.Commission_Type__c = 'Direct';
    commDetail4.OwnerId = origU.Id;
    commDetail4.Internal_Referral__c = origU2.Id;
    commDetail4.Internal_Referral_Fee__c = '50%';
    commDetail4.Approval_Status__c = 'Pending';
     
    insert commDetail4;
        
         Commission_Detail__c commDetail4Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail4.Id];  
              
    commDetail4Update.Approval_Status__c = 'Approved';
        
        update commDetail4Update;

        
    Commission_Detail__c commDetail5 = new Commission_Detail__c();
    commDetail5.Deal__c = topp1.Id;
    commDetail5.Commission_Type__c = 'Internal';
    commDetail5.OwnerId = origU.Id;
    commDetail5.Internal_Referral__c = origU2.Id;
    commDetail5.Internal_Referral_Fee__c = '50%';
    commDetail5.Approval_Status__c = 'Pending';
     
    insert commDetail5;
        
            
         Commission_Detail__c commDetail5Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail5.Id];  
              
    commDetail5Update.Approval_Status__c = 'Approved';
        
        update commDetail5Update; 

        
        //-5 BPS in Spread / -25 BPS in Commissionable Fee
      topp1.CAF_YSP__c = '-5 BPS in Spread / -25 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail6 = new Commission_Detail__c();
    commDetail6.Deal__c = topp1.Id;
    commDetail6.Commission_Type__c = 'Direct';
    commDetail6.OwnerId = origU.Id;
    commDetail6.Internal_Referral__c = origU2.Id;
    commDetail6.Internal_Referral_Fee__c = '50%';
    commDetail6.Approval_Status__c = 'Pending';
     
    insert commDetail6;
        
         Commission_Detail__c commDetail6Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail6.Id];  
              
    commDetail6Update.Approval_Status__c = 'Approved';
        
        update commDetail6Update;

        
    Commission_Detail__c commDetail7 = new Commission_Detail__c();
    commDetail7.Deal__c = topp1.Id;
    commDetail7.Commission_Type__c = 'Internal';
    commDetail7.OwnerId = origU.Id;
    commDetail7.Internal_Referral__c = origU2.Id;
    commDetail7.Internal_Referral_Fee__c = '50%';
    commDetail7.Approval_Status__c = 'Pending';
     
    insert commDetail7;
        
            
         Commission_Detail__c commDetail7Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail7.Id];  
              
    commDetail7Update.Approval_Status__c = 'Approved';
        
        update commDetail7Update; 
        

        
        //+10 BPS in Spread / +25 BPS in Commissionable Fee
      topp1.CAF_YSP__c = '+10 BPS in Spread / +25 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail8 = new Commission_Detail__c();
    commDetail8.Deal__c = topp1.Id;
    commDetail8.Commission_Type__c = 'Direct';
    commDetail8.OwnerId = origU.Id;
    commDetail8.Internal_Referral__c = origU2.Id;
    commDetail8.Internal_Referral_Fee__c = '50%';
    commDetail8.Approval_Status__c = 'Pending';
     
    insert commDetail8;
        
         Commission_Detail__c commDetail8Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail8.Id];  
              
    commDetail8Update.Approval_Status__c = 'Approved';
        
        update commDetail8Update;
        

        
    Commission_Detail__c commDetail9 = new Commission_Detail__c();
    commDetail9.Deal__c = topp1.Id;
    commDetail9.Commission_Type__c = 'Internal';
    commDetail9.OwnerId = origU.Id;
    commDetail9.Internal_Referral__c = origU2.Id;
    commDetail9.Internal_Referral_Fee__c = '50%';
    commDetail9.Approval_Status__c = 'Pending';
     
    insert commDetail9;
        
            
          Commission_Detail__c commDetail9Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail9.Id];  
              
    commDetail9Update.Approval_Status__c = 'Approved';
        
        update commDetail9Update;
 
        
        //-10 BPS in Spread / -25 BPS in Commissionable Fee
      topp1.CAF_YSP__c = '-10 BPS in Spread / -25 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail10 = new Commission_Detail__c();
    commDetail10.Deal__c = topp1.Id;
    commDetail10.Commission_Type__c = 'Direct';
    commDetail10.OwnerId = origU.Id;
    commDetail10.Internal_Referral__c = origU2.Id;
    commDetail10.Internal_Referral_Fee__c = '50%';
    commDetail10.Approval_Status__c = 'Pending';
     
    insert commDetail10;
        
         Commission_Detail__c commDetail10Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail10.Id];  
              
    commDetail10Update.Approval_Status__c = 'Approved';
        
        update commDetail10Update;

        
    Commission_Detail__c commDetail11 = new Commission_Detail__c();
    commDetail11.Deal__c = topp1.Id;
    commDetail11.Commission_Type__c = 'Internal';
    commDetail11.OwnerId = origU.Id;
    commDetail11.Internal_Referral__c = origU2.Id;
    commDetail11.Internal_Referral_Fee__c = '50%';
    commDetail11.Approval_Status__c = 'Pending';
     
    insert commDetail11;
        
            
          Commission_Detail__c commDetail11Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail11.Id];  
              
    commDetail11Update.Approval_Status__c = 'Approved';
      
        
        //+10 BPS in spread / +50 BPS in Commissionable Fee
      topp1.CAF_YSP__c = '+10 BPS in spread / +50 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail12 = new Commission_Detail__c();
    commDetail12.Deal__c = topp1.Id;
    commDetail12.Commission_Type__c = 'Direct';
    commDetail12.OwnerId = origU.Id;
    commDetail12.Internal_Referral__c = origU2.Id;
    commDetail12.Internal_Referral_Fee__c = '50%';
    commDetail12.Approval_Status__c = 'Pending';
     
    insert commDetail12;
        
          Commission_Detail__c commDetail12Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail12.Id];  
              
    commDetail12Update.Approval_Status__c = 'Approved';
        
        update commDetail12Update;

        
    Commission_Detail__c commDetail13 = new Commission_Detail__c();
    commDetail13.Deal__c = topp1.Id;
    commDetail13.Commission_Type__c = 'Internal';
    commDetail13.OwnerId = origU.Id;
    commDetail13.Internal_Referral__c = origU2.Id;
    commDetail13.Internal_Referral_Fee__c = '50%';
    commDetail13.Approval_Status__c = 'Pending';
     
    insert commDetail13;
        
            
         Commission_Detail__c commDetail13Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail13.Id];  
              
    commDetail13Update.Approval_Status__c = 'Approved';
        
        update commDetail13Update;

        
        
        
                //-10 BPS in spread / -50 BPS in Commissionable Fee
      topp1.CAF_YSP__c = '-10 BPS in spread / -50 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail14 = new Commission_Detail__c();
    commDetail14.Deal__c = topp1.Id;
    commDetail14.Commission_Type__c = 'Direct';
    commDetail14.OwnerId = origU.Id;
    commDetail14.Internal_Referral__c = origU2.Id;
    commDetail14.Internal_Referral_Fee__c = '50%';
    commDetail14.Approval_Status__c = 'Pending';
     
    insert commDetail14;
        
         Commission_Detail__c commDetail14Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail14.Id];  
              
    commDetail14Update.Approval_Status__c = 'Approved';
        
        update commDetail14Update;

        
    Commission_Detail__c commDetail15 = new Commission_Detail__c();
    commDetail15.Deal__c = topp1.Id;
    commDetail15.Commission_Type__c = 'Internal';
    commDetail15.OwnerId = origU.Id;
    commDetail15.Internal_Referral__c = origU2.Id;
    commDetail15.Internal_Referral_Fee__c = '50%';
    commDetail15.Approval_Status__c = 'Pending';
     
    insert commDetail15;
        
            
         Commission_Detail__c commDetail15Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail15.Id];  
              
    commDetail15Update.Approval_Status__c = 'Approved';
        
        update commDetail15Update;

        
        //+15 BPS in Spread / +50 BPS in Commissionable Fee
topp1.CAF_YSP__c = '+15 BPS in Spread / +50 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail16 = new Commission_Detail__c();
    commDetail16.Deal__c = topp1.Id;
    commDetail16.Commission_Type__c = 'Direct';
    commDetail16.OwnerId = origU.Id;
    commDetail16.Internal_Referral__c = origU2.Id;
    commDetail16.Internal_Referral_Fee__c = '50%';
    commDetail16.Approval_Status__c = 'Pending';
     
    insert commDetail16;
        
         Commission_Detail__c commDetail16Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail16.Id];  
              
    commDetail16Update.Approval_Status__c = 'Approved';
        
        update commDetail16Update;

        
    Commission_Detail__c commDetail17 = new Commission_Detail__c();
    commDetail17.Deal__c = topp1.Id;
    commDetail17.Commission_Type__c = 'Internal';
    commDetail17.OwnerId = origU.Id;
    commDetail17.Internal_Referral__c = origU2.Id;
    commDetail17.Internal_Referral_Fee__c = '50%';
    commDetail17.Approval_Status__c = 'Pending';
     
    insert commDetail17;
        
            
         Commission_Detail__c commDetail17Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail17.Id];  
              
    commDetail17Update.Approval_Status__c = 'Approved';
        
        update commDetail17Update;
    

        //-15 BPS in Spread / -50 BPS in Commissionable Fee
 topp1.CAF_YSP__c = '-15 BPS in Spread / -50 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail18 = new Commission_Detail__c();
    commDetail18.Deal__c = topp1.Id;
    commDetail18.Commission_Type__c = 'Direct';
    commDetail18.OwnerId = origU.Id;
    commDetail18.Internal_Referral__c = origU2.Id;
    commDetail18.Internal_Referral_Fee__c = '50%';
    commDetail18.Approval_Status__c = 'Pending';
     
    insert commDetail18;
        
         Commission_Detail__c commDetail18Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail18.Id];  
              
    commDetail18Update.Approval_Status__c = 'Approved';
        
        update commDetail18Update;

        
    Commission_Detail__c commDetail19 = new Commission_Detail__c();
    commDetail19.Deal__c = topp1.Id;
    commDetail19.Commission_Type__c = 'Internal';
    commDetail19.OwnerId = origU.Id;
    commDetail19.Internal_Referral__c = origU2.Id;
    commDetail19.Internal_Referral_Fee__c = '50%';
    commDetail19.Approval_Status__c = 'Pending';
     
    insert commDetail19;
        
          Commission_Detail__c commDetail19Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail19.Id];  
              
    commDetail19Update.Approval_Status__c = 'Approved';
        
        update commDetail19Update;
        
        
        //+20 BPS in Spread / +50 BPS in Commissionable Fee
topp1.CAF_YSP__c = '+20 BPS in Spread / +50 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail20 = new Commission_Detail__c();
    commDetail20.Deal__c = topp1.Id;
    commDetail20.Commission_Type__c = 'Direct';
    commDetail20.OwnerId = origU.Id;
    commDetail20.Internal_Referral__c = origU2.Id;
    commDetail20.Internal_Referral_Fee__c = '50%';
    commDetail20.Approval_Status__c = 'Pending';
     
    insert commDetail20;
        
         Commission_Detail__c commDetail20Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail20.Id];  
              
    commDetail20Update.Approval_Status__c = 'Approved';
        
        update commDetail20Update;

        
    Commission_Detail__c commDetail21 = new Commission_Detail__c();
    commDetail21.Deal__c = topp1.Id;
    commDetail21.Commission_Type__c = 'Internal';
    commDetail21.OwnerId = origU.Id;
    commDetail21.Internal_Referral__c = origU2.Id;
    commDetail21.Internal_Referral_Fee__c = '50%';
    commDetail21.Approval_Status__c = 'Pending';
     
    insert commDetail21;
        
            
         Commission_Detail__c commDetail21Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail21.Id];  
              
    commDetail21Update.Approval_Status__c = 'Approved';
        
        update commDetail21Update;

        
        
        //-20 BPS in Spread / -50 BPS in Commissionable Fee
        topp1.CAF_YSP__c = '-20 BPS in Spread / -50 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail22 = new Commission_Detail__c();
    commDetail22.Deal__c = topp1.Id;
    commDetail22.Commission_Type__c = 'Direct';
    commDetail22.OwnerId = origU.Id;
    commDetail22.Internal_Referral__c = origU2.Id;
    commDetail22.Internal_Referral_Fee__c = '50%';
    commDetail22.Approval_Status__c = 'Pending';
     
    insert commDetail22;
        
         Commission_Detail__c commDetail22Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail22.Id];  
              
    commDetail22Update.Approval_Status__c = 'Approved';
        
        update commDetail22Update;

        
    Commission_Detail__c commDetail23 = new Commission_Detail__c();
    commDetail23.Deal__c = topp1.Id;
    commDetail23.Commission_Type__c = 'Internal';
    commDetail23.OwnerId = origU.Id;
    commDetail23.Internal_Referral__c = origU2.Id;
    commDetail23.Internal_Referral_Fee__c = '50%';
    commDetail23.Approval_Status__c = 'Pending';
     
    insert commDetail23;
        
          Commission_Detail__c commDetail23Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail23.Id];  
              
    commDetail23Update.Approval_Status__c = 'Approved';
        
        update commDetail23Update;

        
        Test.stopTest();

    }  */
  @isTest
  static void termCommissiontest3() {
    commissionAutomationSetting__c settings = new commissionAutomationSetting__c(
      SetupOwnerId = UserInfo.getOrganizationId(),
      SkipProcessBuilder__c = true
    );
    insert settings;
    CommissionDetail_TestSkip.setDoNotRunTrigger();
    //Total Borrowed on term (account) Over 5 million no split;Final Loan Amount under 5 million
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
    topp1.CAF_YSP__c = null;
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

    Opportunity topp2 = new Opportunity();
    topp2.Name = 'test';
    topp2.CloseDate = System.today();
    topp2.StageName = 'Initial Review';
    topp2.Loan_Size__c = 20000000;
    topp2.AccountId = acc.Id;
    topp2.Contact__c = cont.Id;
    topp2.OwnerId = origU.id;
    topp2.CAF_YSP__c = null;
    topp2.CAF_Upfront_Fee__c = 2;
    topp2.Final_Loan_Amount__c = 20000000;
    topp2.Deal_Intro_Source__c = 'Hotline';
    topp2.Deal_Intro_Sub_Source__c = 'Main';
    topp2.Apex_Context__c = true;
    topp2.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
    ]
    .Id;
    insert topp2;

    topp2.CAF_Upfront_Fee__c = 2;
    update topp2;

    //Final Loan amount under 5 million

    Commission_Detail__c commDetail = new Commission_Detail__c();
    commDetail.Deal__c = topp1.Id;
    commDetail.Commission_Type__c = 'Direct';
    commDetail.OwnerId = origU.Id;
    commDetail.Approval_Status__c = 'Pending';

    insert commDetail;

    test.startTest();

    Commission_Detail__c commDetailUpdate = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail.Id
    ];

    commDetailUpdate.Approval_Status__c = 'Approved';

    update commDetailUpdate;

    Commission_Detail__c commDetail1 = new Commission_Detail__c();
    commDetail1.Deal__c = topp1.Id;
    commDetail1.Commission_Type__c = 'Internal';
    commDetail1.OwnerId = origU.Id;
    commDetail1.Approval_Status__c = 'Pending';

    insert commDetail1;

    Commission_Detail__c commDetail1Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail1.Id
    ];

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

    Commission_Detail__c commDetail2Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail2.Id
    ];

    commDetail2Update.Approval_Status__c = 'Approved';

    update commDetail2Update;

    Commission_Detail__c commDetail3 = new Commission_Detail__c();
    commDetail3.Deal__c = topp1.Id;
    commDetail3.Commission_Type__c = 'Internal';
    commDetail3.OwnerId = origU.Id;
    commDetail3.Approval_Status__c = 'Pending';

    insert commDetail3;

    Commission_Detail__c commDetail3Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail3.Id
    ];

    commDetail3Update.Approval_Status__c = 'Approved';

    update commDetail3Update;

    //+5 BPS in Spread / +25 BPS in Commissionable Fee

    topp1.CAF_YSP__c = '+5 BPS in Spread / +25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail4 = new Commission_Detail__c();
    commDetail4.Deal__c = topp1.Id;
    commDetail4.Commission_Type__c = 'Direct';
    commDetail4.OwnerId = origU.Id;
    commDetail4.Approval_Status__c = 'Pending';

    insert commDetail4;

    Commission_Detail__c commDetail4Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail4.Id
    ];

    commDetail4Update.Approval_Status__c = 'Approved';

    update commDetail4Update;

    Commission_Detail__c commDetail5 = new Commission_Detail__c();
    commDetail5.Deal__c = topp1.Id;
    commDetail5.Commission_Type__c = 'Internal';
    commDetail5.OwnerId = origU.Id;
    commDetail5.Approval_Status__c = 'Pending';

    insert commDetail5;

    Commission_Detail__c commDetail5Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail5.Id
    ];

    commDetail5Update.Approval_Status__c = 'Approved';

    update commDetail5Update;

    //-5 BPS in Spread / -25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-5 BPS in Spread / -25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail6 = new Commission_Detail__c();
    commDetail6.Deal__c = topp1.Id;
    commDetail6.Commission_Type__c = 'Direct';
    commDetail6.OwnerId = origU.Id;
    commDetail6.Approval_Status__c = 'Pending';

    insert commDetail6;

    Commission_Detail__c commDetail6Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail6.Id
    ];

    commDetail6Update.Approval_Status__c = 'Approved';

    update commDetail6Update;

    Commission_Detail__c commDetail7 = new Commission_Detail__c();
    commDetail7.Deal__c = topp1.Id;
    commDetail7.Commission_Type__c = 'Internal';
    commDetail7.OwnerId = origU.Id;
    commDetail7.Approval_Status__c = 'Pending';

    insert commDetail7;

    Commission_Detail__c commDetail7Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail7.Id
    ];

    commDetail7Update.Approval_Status__c = 'Approved';

    update commDetail7Update;

    //+10 BPS in Spread / +25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+10 BPS in Spread / +25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail8 = new Commission_Detail__c();
    commDetail8.Deal__c = topp1.Id;
    commDetail8.Commission_Type__c = 'Direct';
    commDetail8.OwnerId = origU.Id;
    commDetail8.Approval_Status__c = 'Pending';

    insert commDetail8;

    Commission_Detail__c commDetail8Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail8.Id
    ];

    commDetail8Update.Approval_Status__c = 'Approved';

    update commDetail8Update;

    Commission_Detail__c commDetail9 = new Commission_Detail__c();
    commDetail9.Deal__c = topp1.Id;
    commDetail9.Commission_Type__c = 'Internal';
    commDetail9.OwnerId = origU.Id;
    commDetail9.Approval_Status__c = 'Pending';

    insert commDetail9;

    Commission_Detail__c commDetail9Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail9.Id
    ];

    commDetail9Update.Approval_Status__c = 'Approved';

    update commDetail9Update;

    //-10 BPS in Spread / -25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-10 BPS in Spread / -25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail10 = new Commission_Detail__c();
    commDetail10.Deal__c = topp1.Id;
    commDetail10.Commission_Type__c = 'Direct';
    commDetail10.OwnerId = origU.Id;
    commDetail10.Approval_Status__c = 'Pending';

    insert commDetail10;

    Commission_Detail__c commDetail10Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail10.Id
    ];

    commDetail10Update.Approval_Status__c = 'Approved';

    update commDetail10Update;

    Commission_Detail__c commDetail11 = new Commission_Detail__c();
    commDetail11.Deal__c = topp1.Id;
    commDetail11.Commission_Type__c = 'Internal';
    commDetail11.OwnerId = origU.Id;
    commDetail11.Approval_Status__c = 'Pending';

    insert commDetail11;

    Commission_Detail__c commDetail11Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail11.Id
    ];

    commDetail11Update.Approval_Status__c = 'Approved';

    update commDetail11Update;

    //+10 BPS in spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+10 BPS in spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail12 = new Commission_Detail__c();
    commDetail12.Deal__c = topp1.Id;
    commDetail12.Commission_Type__c = 'Direct';
    commDetail12.OwnerId = origU.Id;
    commDetail12.Approval_Status__c = 'Pending';

    insert commDetail12;

    Commission_Detail__c commDetail12Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail12.Id
    ];

    commDetail12Update.Approval_Status__c = 'Approved';

    update commDetail12Update;

    Commission_Detail__c commDetail13 = new Commission_Detail__c();
    commDetail13.Deal__c = topp1.Id;
    commDetail13.Commission_Type__c = 'Internal';
    commDetail13.OwnerId = origU.Id;
    commDetail13.Approval_Status__c = 'Pending';

    insert commDetail13;

    Commission_Detail__c commDetail13Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail13.Id
    ];

    commDetail13Update.Approval_Status__c = 'Approved';

    update commDetail13Update;

    //-10 BPS in spread / -50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-10 BPS in spread / -50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail14 = new Commission_Detail__c();
    commDetail14.Deal__c = topp1.Id;
    commDetail14.Commission_Type__c = 'Direct';
    commDetail14.OwnerId = origU.Id;
    commDetail14.Approval_Status__c = 'Pending';

    insert commDetail14;

    Commission_Detail__c commDetail14Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail14.Id
    ];

    commDetail14Update.Approval_Status__c = 'Approved';

    update commDetail14Update;

    Commission_Detail__c commDetail15 = new Commission_Detail__c();
    commDetail15.Deal__c = topp1.Id;
    commDetail15.Commission_Type__c = 'Internal';
    commDetail15.OwnerId = origU.Id;
    commDetail15.Approval_Status__c = 'Pending';

    insert commDetail15;

    Commission_Detail__c commDetail15Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail15.Id
    ];

    commDetail15Update.Approval_Status__c = 'Approved';

    update commDetail15Update;

    //+15 BPS in Spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+15 BPS in Spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail16 = new Commission_Detail__c();
    commDetail16.Deal__c = topp1.Id;
    commDetail16.Commission_Type__c = 'Direct';
    commDetail16.OwnerId = origU.Id;
    commDetail16.Approval_Status__c = 'Pending';

    insert commDetail16;

    Commission_Detail__c commDetail16Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail16.Id
    ];

    commDetail16Update.Approval_Status__c = 'Approved';

    update commDetail16Update;

    Commission_Detail__c commDetail17 = new Commission_Detail__c();
    commDetail17.Deal__c = topp1.Id;
    commDetail17.Commission_Type__c = 'Internal';
    commDetail17.OwnerId = origU.Id;
    commDetail17.Approval_Status__c = 'Pending';

    insert commDetail17;

    Commission_Detail__c commDetail17Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail17.Id
    ];

    commDetail17Update.Approval_Status__c = 'Approved';

    update commDetail17Update;

    //-15 BPS in Spread / -50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-15 BPS in Spread / -50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail18 = new Commission_Detail__c();
    commDetail18.Deal__c = topp1.Id;
    commDetail18.Commission_Type__c = 'Direct';
    commDetail18.OwnerId = origU.Id;
    commDetail18.Approval_Status__c = 'Pending';

    insert commDetail18;

    Commission_Detail__c commDetail18Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail18.Id
    ];

    commDetail18Update.Approval_Status__c = 'Approved';

    update commDetail18Update;

    Commission_Detail__c commDetail19 = new Commission_Detail__c();
    commDetail19.Deal__c = topp1.Id;
    commDetail19.Commission_Type__c = 'Internal';
    commDetail19.OwnerId = origU.Id;
    commDetail19.Approval_Status__c = 'Pending';

    insert commDetail19;

    Commission_Detail__c commDetail19Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail19.Id
    ];

    commDetail19Update.Approval_Status__c = 'Approved';

    update commDetail19Update;

    //+20 BPS in Spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+20 BPS in Spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail20 = new Commission_Detail__c();
    commDetail20.Deal__c = topp1.Id;
    commDetail20.Commission_Type__c = 'Direct';
    commDetail20.OwnerId = origU.Id;
    commDetail20.Approval_Status__c = 'Pending';

    insert commDetail20;

    /* Commission_Detail__c commDetail20Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail20.Id];  
              
    commDetail20Update.Approval_Status__c = 'Approved';
        
        update commDetail20Update;

        
    Commission_Detail__c commDetail21 = new Commission_Detail__c();
    commDetail21.Deal__c = topp1.Id;
    commDetail21.Commission_Type__c = 'Internal';
    commDetail21.OwnerId = origU.Id;
    commDetail21.Approval_Status__c = 'Pending';
     
    insert commDetail21;
        
            
         Commission_Detail__c commDetail21Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail21.Id];  
              
    commDetail21Update.Approval_Status__c = 'Approved';
        
        update commDetail21Update;
 
        
        
        //-20 BPS in Spread / -50 BPS in Commissionable Fee
        topp1.CAF_YSP__c = '-20 BPS in Spread / -50 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail22 = new Commission_Detail__c();
    commDetail22.Deal__c = topp1.Id;
    commDetail22.Commission_Type__c = 'Direct';
    commDetail22.OwnerId = origU.Id;
    commDetail22.Approval_Status__c = 'Pending';
     
    insert commDetail22;
        
         Commission_Detail__c commDetail22Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail22.Id];  
              
    commDetail22Update.Approval_Status__c = 'Approved';
        
        update commDetail22Update;

        
    Commission_Detail__c commDetail23 = new Commission_Detail__c();
    commDetail23.Deal__c = topp1.Id;
    commDetail23.Commission_Type__c = 'Internal';
    commDetail23.OwnerId = origU.Id;
    commDetail23.Approval_Status__c = 'Pending';
     
    insert commDetail23;
        
    Commission_Detail__c commDetail23Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail23.Id];  
              
    commDetail23Update.Approval_Status__c = 'Approved';
        
        update commDetail23Update; */

    Test.stopTest();
  }
  @isTest
  static void termCommissiontest4() {
    commissionAutomationSetting__c settings = new commissionAutomationSetting__c(
      SetupOwnerId = UserInfo.getOrganizationId(),
      SkipProcessBuilder__c = true
    );
    insert settings;
    CommissionDetail_TestSkip.setDoNotRunTrigger();
    //Total Borrowed on term (account) Over 5 million split ‘20%’;Final Loan Amount under 5 million

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
    topp1.CAF_YSP__c = null;
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

    Opportunity topp2 = new Opportunity();
    topp2.Name = 'test';
    topp2.CloseDate = System.today();
    topp2.StageName = 'Initial Review';
    topp2.Loan_Size__c = 20000000;
    topp2.AccountId = acc.Id;
    topp2.Contact__c = cont.Id;
    topp2.OwnerId = origU.id;
    topp2.CAF_YSP__c = null;
    topp2.CAF_Upfront_Fee__c = 2;
    topp2.Final_Loan_Amount__c = 20000000;
    topp2.Deal_Intro_Source__c = 'Hotline';
    topp2.Deal_Intro_Sub_Source__c = 'Main';
    topp2.Apex_Context__c = true;
    topp2.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
    ]
    .Id;
    insert topp2;

    topp2.CAF_Upfront_Fee__c = 2;
    update topp2;
    //Final Loan amount under 5 million

    Commission_Detail__c commDetail = new Commission_Detail__c();
    commDetail.Deal__c = topp1.Id;
    commDetail.Commission_Type__c = 'Direct';
    commDetail.OwnerId = origU.Id;
    commDetail.Internal_Referral__c = origU2.Id;
    commDetail.Internal_Referral_Fee__c = '20%';
    commDetail.Approval_Status__c = 'Pending';

    insert commDetail;

    test.startTest();

    Commission_Detail__c commDetailUpdate = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail.Id
    ];

    commDetailUpdate.Approval_Status__c = 'Approved';

    update commDetailUpdate;

    Commission_Detail__c commDetail1 = new Commission_Detail__c();
    commDetail1.Deal__c = topp1.Id;
    commDetail1.Commission_Type__c = 'Internal';
    commDetail1.OwnerId = origU.Id;
    commDetail1.Internal_Referral__c = origU2.Id;
    commDetail1.Internal_Referral_Fee__c = '20%';
    commDetail1.Approval_Status__c = 'Pending';

    insert commDetail1;

    Commission_Detail__c commDetail1Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail1.Id
    ];

    commDetail1Update.Approval_Status__c = 'Approved';

    update commDetail1Update;

    //CAF YSP Section

    topp1.CAF_YSP__c = '0 BPS in Spread';
    update topp1;

    Commission_Detail__c commDetail2 = new Commission_Detail__c();
    commDetail2.Deal__c = topp1.Id;
    commDetail2.Commission_Type__c = 'Direct';
    commDetail2.OwnerId = origU.Id;
    commDetail2.Internal_Referral__c = origU2.Id;
    commDetail2.Internal_Referral_Fee__c = '20%';
    commDetail2.Approval_Status__c = 'Pending';

    insert commDetail2;

    Commission_Detail__c commDetail2Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail2.Id
    ];

    commDetail2Update.Approval_Status__c = 'Approved';

    update commDetail2Update;

    Commission_Detail__c commDetail3 = new Commission_Detail__c();
    commDetail3.Deal__c = topp1.Id;
    commDetail3.Commission_Type__c = 'Internal';
    commDetail3.OwnerId = origU.Id;
    commDetail3.Internal_Referral__c = origU2.Id;
    commDetail3.Internal_Referral_Fee__c = '20%';
    commDetail3.Approval_Status__c = 'Pending';

    insert commDetail3;

    Commission_Detail__c commDetail3Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail3.Id
    ];

    commDetail3Update.Approval_Status__c = 'Approved';

    update commDetail3Update;

    //+5 BPS in Spread / +25 BPS in Commissionable Fee

    topp1.CAF_YSP__c = '+5 BPS in Spread / +25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail4 = new Commission_Detail__c();
    commDetail4.Deal__c = topp1.Id;
    commDetail4.Commission_Type__c = 'Direct';
    commDetail4.OwnerId = origU.Id;
    commDetail4.Internal_Referral__c = origU2.Id;
    commDetail4.Internal_Referral_Fee__c = '20%';
    commDetail4.Approval_Status__c = 'Pending';

    insert commDetail4;

    Commission_Detail__c commDetail4Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail4.Id
    ];

    commDetail4Update.Approval_Status__c = 'Approved';

    update commDetail4Update;

    Commission_Detail__c commDetail5 = new Commission_Detail__c();
    commDetail5.Deal__c = topp1.Id;
    commDetail5.Commission_Type__c = 'Internal';
    commDetail5.OwnerId = origU.Id;
    commDetail5.Internal_Referral__c = origU2.Id;
    commDetail5.Internal_Referral_Fee__c = '20%';
    commDetail5.Approval_Status__c = 'Pending';

    insert commDetail5;

    Commission_Detail__c commDetail5Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail5.Id
    ];

    commDetail5Update.Approval_Status__c = 'Approved';

    update commDetail5Update;

    //-5 BPS in Spread / -25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-5 BPS in Spread / -25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail6 = new Commission_Detail__c();
    commDetail6.Deal__c = topp1.Id;
    commDetail6.Commission_Type__c = 'Direct';
    commDetail6.OwnerId = origU.Id;
    commDetail6.Internal_Referral__c = origU2.Id;
    commDetail6.Internal_Referral_Fee__c = '20%';
    commDetail6.Approval_Status__c = 'Pending';

    insert commDetail6;

    Commission_Detail__c commDetail6Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail6.Id
    ];

    commDetail6Update.Approval_Status__c = 'Approved';

    update commDetail6Update;

    Commission_Detail__c commDetail7 = new Commission_Detail__c();
    commDetail7.Deal__c = topp1.Id;
    commDetail7.Commission_Type__c = 'Internal';
    commDetail7.OwnerId = origU.Id;
    commDetail7.Internal_Referral__c = origU2.Id;
    commDetail7.Internal_Referral_Fee__c = '20%';
    commDetail7.Approval_Status__c = 'Pending';

    insert commDetail7;

    Commission_Detail__c commDetail7Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail7.Id
    ];

    commDetail7Update.Approval_Status__c = 'Approved';

    update commDetail7Update;

    //+10 BPS in Spread / +25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+10 BPS in Spread / +25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail8 = new Commission_Detail__c();
    commDetail8.Deal__c = topp1.Id;
    commDetail8.Commission_Type__c = 'Direct';
    commDetail8.OwnerId = origU.Id;
    commDetail8.Internal_Referral__c = origU2.Id;
    commDetail8.Internal_Referral_Fee__c = '20%';
    commDetail8.Approval_Status__c = 'Pending';

    insert commDetail8;

    Commission_Detail__c commDetail8Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail8.Id
    ];

    commDetail8Update.Approval_Status__c = 'Approved';

    update commDetail8Update;

    Commission_Detail__c commDetail9 = new Commission_Detail__c();
    commDetail9.Deal__c = topp1.Id;
    commDetail9.Commission_Type__c = 'Internal';
    commDetail9.OwnerId = origU.Id;
    commDetail9.Internal_Referral__c = origU2.Id;
    commDetail9.Internal_Referral_Fee__c = '20%';
    commDetail9.Approval_Status__c = 'Pending';

    insert commDetail9;

    Commission_Detail__c commDetail9Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail9.Id
    ];

    commDetail9Update.Approval_Status__c = 'Approved';

    update commDetail9Update;

    //-10 BPS in Spread / -25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-10 BPS in Spread / -25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail10 = new Commission_Detail__c();
    commDetail10.Deal__c = topp1.Id;
    commDetail10.Commission_Type__c = 'Direct';
    commDetail10.OwnerId = origU.Id;
    commDetail10.Internal_Referral__c = origU2.Id;
    commDetail10.Internal_Referral_Fee__c = '20%';
    commDetail10.Approval_Status__c = 'Pending';

    insert commDetail10;

    Commission_Detail__c commDetail10Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail10.Id
    ];

    commDetail10Update.Approval_Status__c = 'Approved';

    update commDetail10Update;

    Commission_Detail__c commDetail11 = new Commission_Detail__c();
    commDetail11.Deal__c = topp1.Id;
    commDetail11.Commission_Type__c = 'Internal';
    commDetail11.OwnerId = origU.Id;
    commDetail11.Internal_Referral__c = origU2.Id;
    commDetail11.Internal_Referral_Fee__c = '20%';
    commDetail11.Approval_Status__c = 'Pending';

    insert commDetail11;

    Commission_Detail__c commDetail11Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail11.Id
    ];

    commDetail11Update.Approval_Status__c = 'Approved';

    update commDetail11Update;

    //+10 BPS in spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+10 BPS in spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail12 = new Commission_Detail__c();
    commDetail12.Deal__c = topp1.Id;
    commDetail12.Commission_Type__c = 'Direct';
    commDetail12.OwnerId = origU.Id;
    commDetail12.Internal_Referral__c = origU2.Id;
    commDetail12.Internal_Referral_Fee__c = '20%';
    commDetail12.Approval_Status__c = 'Pending';

    insert commDetail12;

    Commission_Detail__c commDetail12Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail12.Id
    ];

    commDetail12Update.Approval_Status__c = 'Approved';

    update commDetail12Update;

    Commission_Detail__c commDetail13 = new Commission_Detail__c();
    commDetail13.Deal__c = topp1.Id;
    commDetail13.Commission_Type__c = 'Internal';
    commDetail13.OwnerId = origU.Id;
    commDetail13.Internal_Referral__c = origU2.Id;
    commDetail13.Internal_Referral_Fee__c = '20%';
    commDetail13.Approval_Status__c = 'Pending';

    insert commDetail13;

    Commission_Detail__c commDetail13Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail13.Id
    ];

    commDetail13Update.Approval_Status__c = 'Approved';

    update commDetail13Update;

    //-10 BPS in spread / -50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-10 BPS in spread / -50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail14 = new Commission_Detail__c();
    commDetail14.Deal__c = topp1.Id;
    commDetail14.Commission_Type__c = 'Direct';
    commDetail14.OwnerId = origU.Id;
    commDetail14.Internal_Referral__c = origU2.Id;
    commDetail14.Internal_Referral_Fee__c = '20%';
    commDetail14.Approval_Status__c = 'Pending';

    insert commDetail14;

    Commission_Detail__c commDetail14Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail14.Id
    ];

    commDetail14Update.Approval_Status__c = 'Approved';

    update commDetail14Update;

    Commission_Detail__c commDetail15 = new Commission_Detail__c();
    commDetail15.Deal__c = topp1.Id;
    commDetail15.Commission_Type__c = 'Internal';
    commDetail15.OwnerId = origU.Id;
    commDetail15.Internal_Referral__c = origU2.Id;
    commDetail15.Internal_Referral_Fee__c = '20%';
    commDetail15.Approval_Status__c = 'Pending';

    insert commDetail15;

    Commission_Detail__c commDetail15Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail15.Id
    ];

    commDetail15Update.Approval_Status__c = 'Approved';

    update commDetail15Update;

    //+15 BPS in Spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+15 BPS in Spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail16 = new Commission_Detail__c();
    commDetail16.Deal__c = topp1.Id;
    commDetail16.Commission_Type__c = 'Direct';
    commDetail16.OwnerId = origU.Id;
    commDetail16.Internal_Referral__c = origU2.Id;
    commDetail16.Internal_Referral_Fee__c = '20%';
    commDetail16.Approval_Status__c = 'Pending';

    insert commDetail16;

    Commission_Detail__c commDetail16Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail16.Id
    ];

    commDetail16Update.Approval_Status__c = 'Approved';

    update commDetail16Update;

    Commission_Detail__c commDetail17 = new Commission_Detail__c();
    commDetail17.Deal__c = topp1.Id;
    commDetail17.Commission_Type__c = 'Internal';
    commDetail17.OwnerId = origU.Id;
    commDetail17.Internal_Referral__c = origU2.Id;
    commDetail17.Internal_Referral_Fee__c = '20%';
    commDetail17.Approval_Status__c = 'Pending';

    insert commDetail17;

    Commission_Detail__c commDetail17Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail17.Id
    ];

    commDetail17Update.Approval_Status__c = 'Approved';

    update commDetail17Update;

    //-15 BPS in Spread / -50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-15 BPS in Spread / -50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail18 = new Commission_Detail__c();
    commDetail18.Deal__c = topp1.Id;
    commDetail18.Commission_Type__c = 'Direct';
    commDetail18.OwnerId = origU.Id;
    commDetail18.Internal_Referral__c = origU2.Id;
    commDetail18.Internal_Referral_Fee__c = '20%';
    commDetail18.Approval_Status__c = 'Pending';

    insert commDetail18;

    Commission_Detail__c commDetail18Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail18.Id
    ];

    commDetail18Update.Approval_Status__c = 'Approved';

    update commDetail18Update;

    Commission_Detail__c commDetail19 = new Commission_Detail__c();
    commDetail19.Deal__c = topp1.Id;
    commDetail19.Commission_Type__c = 'Internal';
    commDetail19.OwnerId = origU.Id;
    commDetail19.Internal_Referral__c = origU2.Id;
    commDetail19.Internal_Referral_Fee__c = '20%';
    commDetail19.Approval_Status__c = 'Pending';

    insert commDetail19;

    Commission_Detail__c commDetail19Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail19.Id
    ];

    commDetail19Update.Approval_Status__c = 'Approved';

    update commDetail19Update;

    //+20 BPS in Spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+20 BPS in Spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail20 = new Commission_Detail__c();
    commDetail20.Deal__c = topp1.Id;
    commDetail20.Commission_Type__c = 'Direct';
    commDetail20.OwnerId = origU.Id;
    commDetail20.Internal_Referral__c = origU2.Id;
    commDetail20.Internal_Referral_Fee__c = '20%';
    commDetail20.Approval_Status__c = 'Pending';

    insert commDetail20;

    /*          Commission_Detail__c commDetail20Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail20.Id];  
              
    commDetail20Update.Approval_Status__c = 'Approved';
        
        update commDetail20Update;

        
    Commission_Detail__c commDetail21 = new Commission_Detail__c();
    commDetail21.Deal__c = topp1.Id;
    commDetail21.Commission_Type__c = 'Internal';
    commDetail21.OwnerId = origU.Id;
    commDetail21.Internal_Referral__c = origU2.Id;
    commDetail21.Internal_Referral_Fee__c = '20%';
    commDetail21.Approval_Status__c = 'Pending';
     
    insert commDetail21;
        
            
         Commission_Detail__c commDetail21Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail21.Id];  
              
    commDetail21Update.Approval_Status__c = 'Approved';
        
        update commDetail21Update;

        
        
        //-20 BPS in Spread / -50 BPS in Commissionable Fee
        topp1.CAF_YSP__c = '-20 BPS in Spread / -50 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail22 = new Commission_Detail__c();
    commDetail22.Deal__c = topp1.Id;
    commDetail22.Commission_Type__c = 'Direct';
    commDetail22.OwnerId = origU.Id;
    commDetail22.Internal_Referral__c = origU2.Id;
    commDetail22.Internal_Referral_Fee__c = '20%';
    commDetail22.Approval_Status__c = 'Pending';
     
    insert commDetail22;
        
Commission_Detail__c commDetail22Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail22.Id];  
              
    commDetail22Update.Approval_Status__c = 'Approved';
        
        update commDetail22Update;

        
    Commission_Detail__c commDetail23 = new Commission_Detail__c();
    commDetail23.Deal__c = topp1.Id;
    commDetail23.Commission_Type__c = 'Internal';
    commDetail23.OwnerId = origU.Id;
    commDetail23.Internal_Referral__c = origU2.Id;
    commDetail23.Internal_Referral_Fee__c = '20%';
    commDetail23.Approval_Status__c = 'Pending';
     
    insert commDetail23;
        
            
          Commission_Detail__c commDetail23Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail23.Id];  
              
    commDetail23Update.Approval_Status__c = 'Approved';
        
        update commDetail23Update; */

    Test.stopTest();
  }
  @isTest
  static void termCommissiontest5() {
    commissionAutomationSetting__c settings = new commissionAutomationSetting__c(
      SetupOwnerId = UserInfo.getOrganizationId(),
      SkipProcessBuilder__c = true
    );
    insert settings;
    CommissionDetail_TestSkip.setDoNotRunTrigger();
    //Total Borrowed on term (account) under 5 million split ‘20%’;Final Loan Amount under 5 million

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
    topp1.CAF_YSP__c = null;
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
    commDetail.Internal_Referral__c = origU2.Id;
    commDetail.Internal_Referral_Fee__c = '20%';
    commDetail.Approval_Status__c = 'Pending';

    insert commDetail;

    test.startTest();

    Commission_Detail__c commDetailUpdate = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail.Id
    ];

    commDetailUpdate.Approval_Status__c = 'Approved';

    update commDetailUpdate;

    Commission_Detail__c commDetail1 = new Commission_Detail__c();
    commDetail1.Deal__c = topp1.Id;
    commDetail1.Commission_Type__c = 'Internal';
    commDetail1.OwnerId = origU.Id;
    commDetail1.Internal_Referral__c = origU2.Id;
    commDetail1.Internal_Referral_Fee__c = '20%';
    commDetail1.Approval_Status__c = 'Pending';

    insert commDetail1;

    Commission_Detail__c commDetail1Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail1.Id
    ];

    commDetail1Update.Approval_Status__c = 'Approved';

    update commDetail1Update;

    //CAF YSP Section

    topp1.CAF_YSP__c = '0 BPS in Spread';
    update topp1;

    Commission_Detail__c commDetail2 = new Commission_Detail__c();
    commDetail2.Deal__c = topp1.Id;
    commDetail2.Commission_Type__c = 'Direct';
    commDetail2.OwnerId = origU.Id;
    commDetail2.Internal_Referral__c = origU2.Id;
    commDetail2.Internal_Referral_Fee__c = '20%';
    commDetail2.Approval_Status__c = 'Pending';

    insert commDetail2;

    Commission_Detail__c commDetail2Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail2.Id
    ];

    commDetail2Update.Approval_Status__c = 'Approved';

    update commDetail2Update;

    Commission_Detail__c commDetail3 = new Commission_Detail__c();
    commDetail3.Deal__c = topp1.Id;
    commDetail3.Commission_Type__c = 'Internal';
    commDetail3.OwnerId = origU.Id;
    commDetail3.Internal_Referral__c = origU2.Id;
    commDetail3.Internal_Referral_Fee__c = '20%';
    commDetail3.Approval_Status__c = 'Pending';

    insert commDetail3;

    Commission_Detail__c commDetail3Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail3.Id
    ];

    commDetail3Update.Approval_Status__c = 'Approved';

    update commDetail3Update;

    //+5 BPS in Spread / +25 BPS in Commissionable Fee

    topp1.CAF_YSP__c = '+5 BPS in Spread / +25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail4 = new Commission_Detail__c();
    commDetail4.Deal__c = topp1.Id;
    commDetail4.Commission_Type__c = 'Direct';
    commDetail4.OwnerId = origU.Id;
    commDetail4.Internal_Referral__c = origU2.Id;
    commDetail4.Internal_Referral_Fee__c = '20%';
    commDetail4.Approval_Status__c = 'Pending';

    insert commDetail4;

    Commission_Detail__c commDetail4Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail4.Id
    ];

    commDetail4Update.Approval_Status__c = 'Approved';

    update commDetail4Update;

    Commission_Detail__c commDetail5 = new Commission_Detail__c();
    commDetail5.Deal__c = topp1.Id;
    commDetail5.Commission_Type__c = 'Internal';
    commDetail5.OwnerId = origU.Id;
    commDetail5.Internal_Referral__c = origU2.Id;
    commDetail5.Internal_Referral_Fee__c = '20%';
    commDetail5.Approval_Status__c = 'Pending';

    insert commDetail5;

    Commission_Detail__c commDetail5Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail5.Id
    ];

    commDetail5Update.Approval_Status__c = 'Approved';

    update commDetail5Update;

    //-5 BPS in Spread / -25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-5 BPS in Spread / -25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail6 = new Commission_Detail__c();
    commDetail6.Deal__c = topp1.Id;
    commDetail6.Commission_Type__c = 'Direct';
    commDetail6.OwnerId = origU.Id;
    commDetail6.Internal_Referral__c = origU2.Id;
    commDetail6.Internal_Referral_Fee__c = '20%';
    commDetail6.Approval_Status__c = 'Pending';

    insert commDetail6;

    Commission_Detail__c commDetail6Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail6.Id
    ];

    commDetail6Update.Approval_Status__c = 'Approved';

    update commDetail6Update;

    Commission_Detail__c commDetail7 = new Commission_Detail__c();
    commDetail7.Deal__c = topp1.Id;
    commDetail7.Commission_Type__c = 'Internal';
    commDetail7.OwnerId = origU.Id;
    commDetail7.Internal_Referral__c = origU2.Id;
    commDetail7.Internal_Referral_Fee__c = '20%';
    commDetail7.Approval_Status__c = 'Pending';

    insert commDetail7;

    Commission_Detail__c commDetail7Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail7.Id
    ];

    commDetail7Update.Approval_Status__c = 'Approved';

    update commDetail7Update;

    //+10 BPS in Spread / +25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+10 BPS in Spread / +25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail8 = new Commission_Detail__c();
    commDetail8.Deal__c = topp1.Id;
    commDetail8.Commission_Type__c = 'Direct';
    commDetail8.OwnerId = origU.Id;
    commDetail8.Internal_Referral__c = origU2.Id;
    commDetail8.Internal_Referral_Fee__c = '20%';
    commDetail8.Approval_Status__c = 'Pending';

    insert commDetail8;

    Commission_Detail__c commDetail8Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail8.Id
    ];

    commDetail8Update.Approval_Status__c = 'Approved';

    update commDetail8Update;

    Commission_Detail__c commDetail9 = new Commission_Detail__c();
    commDetail9.Deal__c = topp1.Id;
    commDetail9.Commission_Type__c = 'Internal';
    commDetail9.OwnerId = origU.Id;
    commDetail9.Internal_Referral__c = origU2.Id;
    commDetail9.Internal_Referral_Fee__c = '20%';
    commDetail9.Approval_Status__c = 'Pending';

    insert commDetail9;

    Commission_Detail__c commDetail9Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail9.Id
    ];

    commDetail9Update.Approval_Status__c = 'Approved';

    update commDetail9Update;

    //-10 BPS in Spread / -25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-10 BPS in Spread / -25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail10 = new Commission_Detail__c();
    commDetail10.Deal__c = topp1.Id;
    commDetail10.Commission_Type__c = 'Direct';
    commDetail10.OwnerId = origU.Id;
    commDetail10.Internal_Referral__c = origU2.Id;
    commDetail10.Internal_Referral_Fee__c = '20%';
    commDetail10.Approval_Status__c = 'Pending';

    insert commDetail10;

    Commission_Detail__c commDetail10Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail10.Id
    ];

    commDetail10Update.Approval_Status__c = 'Approved';

    update commDetail10Update;

    Commission_Detail__c commDetail11 = new Commission_Detail__c();
    commDetail11.Deal__c = topp1.Id;
    commDetail11.Commission_Type__c = 'Internal';
    commDetail11.OwnerId = origU.Id;
    commDetail11.Internal_Referral__c = origU2.Id;
    commDetail11.Internal_Referral_Fee__c = '20%';
    commDetail11.Approval_Status__c = 'Pending';

    insert commDetail11;

    Commission_Detail__c commDetail11Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail11.Id
    ];

    commDetail11Update.Approval_Status__c = 'Approved';

    update commDetail11Update;

    //+10 BPS in spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+10 BPS in spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail12 = new Commission_Detail__c();
    commDetail12.Deal__c = topp1.Id;
    commDetail12.Commission_Type__c = 'Direct';
    commDetail12.OwnerId = origU.Id;
    commDetail12.Internal_Referral__c = origU2.Id;
    commDetail12.Internal_Referral_Fee__c = '20%';
    commDetail12.Approval_Status__c = 'Pending';

    insert commDetail12;

    Commission_Detail__c commDetail12Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail12.Id
    ];

    commDetail12Update.Approval_Status__c = 'Approved';

    update commDetail12Update;

    Commission_Detail__c commDetail13 = new Commission_Detail__c();
    commDetail13.Deal__c = topp1.Id;
    commDetail13.Commission_Type__c = 'Internal';
    commDetail13.OwnerId = origU.Id;
    commDetail13.Internal_Referral__c = origU2.Id;
    commDetail13.Internal_Referral_Fee__c = '20%';
    commDetail13.Approval_Status__c = 'Pending';

    insert commDetail13;

    Commission_Detail__c commDetail13Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail13.Id
    ];

    commDetail13Update.Approval_Status__c = 'Approved';

    update commDetail13Update;

    //-10 BPS in spread / -50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-10 BPS in spread / -50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail14 = new Commission_Detail__c();
    commDetail14.Deal__c = topp1.Id;
    commDetail14.Commission_Type__c = 'Direct';
    commDetail14.OwnerId = origU.Id;
    commDetail14.Internal_Referral__c = origU2.Id;
    commDetail14.Internal_Referral_Fee__c = '20%';
    commDetail14.Approval_Status__c = 'Pending';

    insert commDetail14;

    Commission_Detail__c commDetail14Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail14.Id
    ];

    commDetail14Update.Approval_Status__c = 'Approved';

    update commDetail14Update;

    Commission_Detail__c commDetail15 = new Commission_Detail__c();
    commDetail15.Deal__c = topp1.Id;
    commDetail15.Commission_Type__c = 'Internal';
    commDetail15.OwnerId = origU.Id;
    commDetail15.Internal_Referral__c = origU2.Id;
    commDetail15.Internal_Referral_Fee__c = '20%';
    commDetail15.Approval_Status__c = 'Pending';

    insert commDetail15;

    Commission_Detail__c commDetail15Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail15.Id
    ];

    commDetail15Update.Approval_Status__c = 'Approved';

    update commDetail15Update;

    //+15 BPS in Spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+15 BPS in Spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail16 = new Commission_Detail__c();
    commDetail16.Deal__c = topp1.Id;
    commDetail16.Commission_Type__c = 'Direct';
    commDetail16.OwnerId = origU.Id;
    commDetail16.Internal_Referral__c = origU2.Id;
    commDetail16.Internal_Referral_Fee__c = '20%';
    commDetail16.Approval_Status__c = 'Pending';

    insert commDetail16;

    Commission_Detail__c commDetail16Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail16.Id
    ];

    commDetail16Update.Approval_Status__c = 'Approved';

    update commDetail16Update;

    Commission_Detail__c commDetail17 = new Commission_Detail__c();
    commDetail17.Deal__c = topp1.Id;
    commDetail17.Commission_Type__c = 'Internal';
    commDetail17.OwnerId = origU.Id;
    commDetail17.Internal_Referral__c = origU2.Id;
    commDetail17.Internal_Referral_Fee__c = '20%';
    commDetail17.Approval_Status__c = 'Pending';

    insert commDetail17;

    Commission_Detail__c commDetail17Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail17.Id
    ];

    commDetail17Update.Approval_Status__c = 'Approved';

    update commDetail17Update;

    //-15 BPS in Spread / -50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-15 BPS in Spread / -50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail18 = new Commission_Detail__c();
    commDetail18.Deal__c = topp1.Id;
    commDetail18.Commission_Type__c = 'Direct';
    commDetail18.OwnerId = origU.Id;
    commDetail18.Internal_Referral__c = origU2.Id;
    commDetail18.Internal_Referral_Fee__c = '20%';
    commDetail18.Approval_Status__c = 'Pending';

    insert commDetail18;

    Commission_Detail__c commDetail18Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail18.Id
    ];

    commDetail18Update.Approval_Status__c = 'Approved';

    update commDetail18Update;

    Commission_Detail__c commDetail19 = new Commission_Detail__c();
    commDetail19.Deal__c = topp1.Id;
    commDetail19.Commission_Type__c = 'Internal';
    commDetail19.OwnerId = origU.Id;
    commDetail19.Internal_Referral__c = origU2.Id;
    commDetail19.Internal_Referral_Fee__c = '20%';
    commDetail19.Approval_Status__c = 'Pending';

    insert commDetail19;

    Commission_Detail__c commDetail19Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail19.Id
    ];

    commDetail19Update.Approval_Status__c = 'Approved';

    update commDetail19Update;

    //+20 BPS in Spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+20 BPS in Spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail20 = new Commission_Detail__c();
    commDetail20.Deal__c = topp1.Id;
    commDetail20.Commission_Type__c = 'Direct';
    commDetail20.OwnerId = origU.Id;
    commDetail20.Internal_Referral__c = origU2.Id;
    commDetail20.Internal_Referral_Fee__c = '20%';
    commDetail20.Approval_Status__c = 'Pending';

    insert commDetail20;

    /*          Commission_Detail__c commDetail20Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail20.Id];  
              
    commDetail20Update.Approval_Status__c = 'Approved';
        
        update commDetail20Update;

        
    Commission_Detail__c commDetail21 = new Commission_Detail__c();
    commDetail21.Deal__c = topp1.Id;
    commDetail21.Commission_Type__c = 'Internal';
    commDetail21.OwnerId = origU.Id;
    commDetail21.Internal_Referral__c = origU2.Id;
    commDetail21.Internal_Referral_Fee__c = '20%';
    commDetail21.Approval_Status__c = 'Pending';
     
    insert commDetail21;
        
            
         Commission_Detail__c commDetail21Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail21.Id];  
              
    commDetail21Update.Approval_Status__c = 'Approved';
        
        update commDetail21Update;

        
        
        //-20 BPS in Spread / -50 BPS in Commissionable Fee
        topp1.CAF_YSP__c = '-20 BPS in Spread / -50 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail22 = new Commission_Detail__c();
    commDetail22.Deal__c = topp1.Id;
    commDetail22.Commission_Type__c = 'Direct';
    commDetail22.OwnerId = origU.Id;
    commDetail22.Internal_Referral__c = origU2.Id;
    commDetail22.Internal_Referral_Fee__c = '20%';
    commDetail22.Approval_Status__c = 'Pending';
     
    insert commDetail22;
        
         Commission_Detail__c commDetail22Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail22.Id];  
              
    commDetail22Update.Approval_Status__c = 'Approved';
        
        update commDetail22Update;

        
    Commission_Detail__c commDetail23 = new Commission_Detail__c();
    commDetail23.Deal__c = topp1.Id;
    commDetail23.Commission_Type__c = 'Internal';
    commDetail23.OwnerId = origU.Id;
    commDetail23.Internal_Referral__c = origU2.Id;
    commDetail23.Internal_Referral_Fee__c = '20%';
    commDetail23.Approval_Status__c = 'Pending';
     
    insert commDetail23;
        
            
           Commission_Detail__c commDetail23Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail23.Id];  
              
    commDetail23Update.Approval_Status__c = 'Approved';
        
        update commDetail23Update; */

    Test.stopTest();
  }
  @isTest
  static void termCommissiontest6() {
    commissionAutomationSetting__c settings = new commissionAutomationSetting__c(
      SetupOwnerId = UserInfo.getOrganizationId(),
      SkipProcessBuilder__c = true
    );
    insert settings;
    CommissionDetail_TestSkip.setDoNotRunTrigger();

    //Total Borrowed on term (account) Over 5 million split ‘50%’;Final Loan Amount under 5 million

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
    topp1.CAF_YSP__c = null;
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

    Opportunity topp2 = new Opportunity();
    topp2.Name = 'test';
    topp2.CloseDate = System.today();
    topp2.StageName = 'Initial Review';
    topp2.Loan_Size__c = 20000000;
    topp2.AccountId = acc.Id;
    topp2.Contact__c = cont.Id;
    topp2.OwnerId = origU.id;
    topp2.CAF_YSP__c = null;
    topp2.CAF_Upfront_Fee__c = 2;
    topp2.Final_Loan_Amount__c = 20000000;
    topp2.Deal_Intro_Source__c = 'Hotline';
    topp2.Deal_Intro_Sub_Source__c = 'Main';
    topp2.Apex_Context__c = true;
    topp2.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
    ]
    .Id;
    insert topp2;

    topp1.CAF_Upfront_Fee__c = 2;
    update topp1;
    //Final Loan amount under 5 million

    Commission_Detail__c commDetail = new Commission_Detail__c();
    commDetail.Deal__c = topp1.Id;
    commDetail.Commission_Type__c = 'Direct';
    commDetail.OwnerId = origU.Id;
    commDetail.Internal_Referral__c = origU2.Id;
    commDetail.Internal_Referral_Fee__c = '50%';
    commDetail.Approval_Status__c = 'Pending';

    insert commDetail;

    test.startTest();

    Commission_Detail__c commDetailUpdate = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail.Id
    ];

    commDetailUpdate.Approval_Status__c = 'Approved';

    update commDetailUpdate;

    Commission_Detail__c commDetail1 = new Commission_Detail__c();
    commDetail1.Deal__c = topp1.Id;
    commDetail1.Commission_Type__c = 'Internal';
    commDetail1.OwnerId = origU.Id;
    commDetail1.Internal_Referral__c = origU2.Id;
    commDetail1.Internal_Referral_Fee__c = '50%';
    commDetail1.Approval_Status__c = 'Pending';

    insert commDetail1;

    Commission_Detail__c commDetail1Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail1.Id
    ];

    commDetail1Update.Approval_Status__c = 'Approved';

    update commDetail1Update;

    //CAF YSP Section

    topp1.CAF_YSP__c = '0 BPS in Spread';
    update topp1;

    Commission_Detail__c commDetail2 = new Commission_Detail__c();
    commDetail2.Deal__c = topp1.Id;
    commDetail2.Commission_Type__c = 'Direct';
    commDetail2.OwnerId = origU.Id;
    commDetail2.Internal_Referral__c = origU2.Id;
    commDetail2.Internal_Referral_Fee__c = '50%';
    commDetail2.Approval_Status__c = 'Pending';

    insert commDetail2;

    Commission_Detail__c commDetail2Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail2.Id
    ];

    commDetail2Update.Approval_Status__c = 'Approved';

    update commDetail2Update;

    Commission_Detail__c commDetail3 = new Commission_Detail__c();
    commDetail3.Deal__c = topp1.Id;
    commDetail3.Commission_Type__c = 'Internal';
    commDetail3.OwnerId = origU.Id;
    commDetail3.Internal_Referral__c = origU2.Id;
    commDetail3.Internal_Referral_Fee__c = '50%';
    commDetail3.Approval_Status__c = 'Pending';

    insert commDetail3;

    Commission_Detail__c commDetail3Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail3.Id
    ];

    commDetail3Update.Approval_Status__c = 'Approved';

    update commDetail3Update;

    //+5 BPS in Spread / +25 BPS in Commissionable Fee

    topp1.CAF_YSP__c = '+5 BPS in Spread / +25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail4 = new Commission_Detail__c();
    commDetail4.Deal__c = topp1.Id;
    commDetail4.Commission_Type__c = 'Direct';
    commDetail4.OwnerId = origU.Id;
    commDetail4.Internal_Referral__c = origU2.Id;
    commDetail4.Internal_Referral_Fee__c = '50%';
    commDetail4.Approval_Status__c = 'Pending';

    insert commDetail4;

    Commission_Detail__c commDetail4Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail4.Id
    ];

    commDetail4Update.Approval_Status__c = 'Approved';

    update commDetail4Update;

    Commission_Detail__c commDetail5 = new Commission_Detail__c();
    commDetail5.Deal__c = topp1.Id;
    commDetail5.Commission_Type__c = 'Internal';
    commDetail5.OwnerId = origU.Id;
    commDetail5.Internal_Referral__c = origU2.Id;
    commDetail5.Internal_Referral_Fee__c = '50%';
    commDetail5.Approval_Status__c = 'Pending';

    insert commDetail5;

    Commission_Detail__c commDetail5Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail5.Id
    ];

    commDetail5Update.Approval_Status__c = 'Approved';

    update commDetail5Update;

    //-5 BPS in Spread / -25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-5 BPS in Spread / -25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail6 = new Commission_Detail__c();
    commDetail6.Deal__c = topp1.Id;
    commDetail6.Commission_Type__c = 'Direct';
    commDetail6.OwnerId = origU.Id;
    commDetail6.Internal_Referral__c = origU2.Id;
    commDetail6.Internal_Referral_Fee__c = '50%';
    commDetail6.Approval_Status__c = 'Pending';

    insert commDetail6;

    Commission_Detail__c commDetail6Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail6.Id
    ];

    commDetail6Update.Approval_Status__c = 'Approved';

    update commDetail6Update;

    Commission_Detail__c commDetail7 = new Commission_Detail__c();
    commDetail7.Deal__c = topp1.Id;
    commDetail7.Commission_Type__c = 'Internal';
    commDetail7.OwnerId = origU.Id;
    commDetail7.Internal_Referral__c = origU2.Id;
    commDetail7.Internal_Referral_Fee__c = '50%';
    commDetail7.Approval_Status__c = 'Pending';

    insert commDetail7;

    Commission_Detail__c commDetail7Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail7.Id
    ];

    commDetail7Update.Approval_Status__c = 'Approved';

    update commDetail7Update;

    //+10 BPS in Spread / +25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+10 BPS in Spread / +25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail8 = new Commission_Detail__c();
    commDetail8.Deal__c = topp1.Id;
    commDetail8.Commission_Type__c = 'Direct';
    commDetail8.OwnerId = origU.Id;
    commDetail8.Internal_Referral__c = origU2.Id;
    commDetail8.Internal_Referral_Fee__c = '50%';
    commDetail8.Approval_Status__c = 'Pending';

    insert commDetail8;

    Commission_Detail__c commDetail8Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail8.Id
    ];

    commDetail8Update.Approval_Status__c = 'Approved';

    update commDetail8Update;

    Commission_Detail__c commDetail9 = new Commission_Detail__c();
    commDetail9.Deal__c = topp1.Id;
    commDetail9.Commission_Type__c = 'Internal';
    commDetail9.OwnerId = origU.Id;
    commDetail9.Internal_Referral__c = origU2.Id;
    commDetail9.Internal_Referral_Fee__c = '50%';
    commDetail9.Approval_Status__c = 'Pending';

    insert commDetail9;

    Commission_Detail__c commDetail9Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail9.Id
    ];

    commDetail9Update.Approval_Status__c = 'Approved';

    update commDetail9Update;

    //-10 BPS in Spread / -25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-10 BPS in Spread / -25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail10 = new Commission_Detail__c();
    commDetail10.Deal__c = topp1.Id;
    commDetail10.Commission_Type__c = 'Direct';
    commDetail10.OwnerId = origU.Id;
    commDetail10.Internal_Referral__c = origU2.Id;
    commDetail10.Internal_Referral_Fee__c = '50%';
    commDetail10.Approval_Status__c = 'Pending';

    insert commDetail10;

    Commission_Detail__c commDetail10Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail10.Id
    ];

    commDetail10Update.Approval_Status__c = 'Approved';

    update commDetail10Update;

    Commission_Detail__c commDetail11 = new Commission_Detail__c();
    commDetail11.Deal__c = topp1.Id;
    commDetail11.Commission_Type__c = 'Internal';
    commDetail11.OwnerId = origU.Id;
    commDetail11.Internal_Referral__c = origU2.Id;
    commDetail11.Internal_Referral_Fee__c = '50%';
    commDetail11.Approval_Status__c = 'Pending';

    insert commDetail11;

    Commission_Detail__c commDetail11Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail11.Id
    ];

    commDetail11Update.Approval_Status__c = 'Approved';

    update commDetail11Update;

    //+10 BPS in spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+10 BPS in spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail12 = new Commission_Detail__c();
    commDetail12.Deal__c = topp1.Id;
    commDetail12.Commission_Type__c = 'Direct';
    commDetail12.OwnerId = origU.Id;
    commDetail12.Internal_Referral__c = origU2.Id;
    commDetail12.Internal_Referral_Fee__c = '50%';
    commDetail12.Approval_Status__c = 'Pending';

    insert commDetail12;

    Commission_Detail__c commDetail12Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail12.Id
    ];

    commDetail12Update.Approval_Status__c = 'Approved';

    update commDetail12Update;

    Commission_Detail__c commDetail13 = new Commission_Detail__c();
    commDetail13.Deal__c = topp1.Id;
    commDetail13.Commission_Type__c = 'Internal';
    commDetail13.OwnerId = origU.Id;
    commDetail13.Internal_Referral__c = origU2.Id;
    commDetail13.Internal_Referral_Fee__c = '50%';
    commDetail13.Approval_Status__c = 'Pending';

    insert commDetail13;

    Commission_Detail__c commDetail13Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail13.Id
    ];

    commDetail13Update.Approval_Status__c = 'Approved';

    update commDetail13Update;

    //-10 BPS in spread / -50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-10 BPS in spread / -50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail14 = new Commission_Detail__c();
    commDetail14.Deal__c = topp1.Id;
    commDetail14.Commission_Type__c = 'Direct';
    commDetail14.OwnerId = origU.Id;
    commDetail14.Internal_Referral__c = origU2.Id;
    commDetail14.Internal_Referral_Fee__c = '50%';
    commDetail14.Approval_Status__c = 'Pending';

    insert commDetail14;

    Commission_Detail__c commDetail14Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail14.Id
    ];

    commDetail14Update.Approval_Status__c = 'Approved';

    update commDetail14Update;

    Commission_Detail__c commDetail15 = new Commission_Detail__c();
    commDetail15.Deal__c = topp1.Id;
    commDetail15.Commission_Type__c = 'Internal';
    commDetail15.OwnerId = origU.Id;
    commDetail15.Internal_Referral__c = origU2.Id;
    commDetail15.Internal_Referral_Fee__c = '50%';
    commDetail15.Approval_Status__c = 'Pending';

    insert commDetail15;

    Commission_Detail__c commDetail15Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail15.Id
    ];

    commDetail15Update.Approval_Status__c = 'Approved';

    update commDetail15Update;

    //+15 BPS in Spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+15 BPS in Spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail16 = new Commission_Detail__c();
    commDetail16.Deal__c = topp1.Id;
    commDetail16.Commission_Type__c = 'Direct';
    commDetail16.OwnerId = origU.Id;
    commDetail16.Internal_Referral__c = origU2.Id;
    commDetail16.Internal_Referral_Fee__c = '50%';
    commDetail16.Approval_Status__c = 'Pending';

    insert commDetail16;

    Commission_Detail__c commDetail16Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail16.Id
    ];

    commDetail16Update.Approval_Status__c = 'Approved';

    update commDetail16Update;

    Commission_Detail__c commDetail17 = new Commission_Detail__c();
    commDetail17.Deal__c = topp1.Id;
    commDetail17.Commission_Type__c = 'Internal';
    commDetail17.OwnerId = origU.Id;
    commDetail17.Internal_Referral__c = origU2.Id;
    commDetail17.Internal_Referral_Fee__c = '50%';
    commDetail17.Approval_Status__c = 'Pending';

    insert commDetail17;

    Commission_Detail__c commDetail17Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail17.Id
    ];

    commDetail17Update.Approval_Status__c = 'Approved';

    update commDetail17Update;

    //-15 BPS in Spread / -50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-15 BPS in Spread / -50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail18 = new Commission_Detail__c();
    commDetail18.Deal__c = topp1.Id;
    commDetail18.Commission_Type__c = 'Direct';
    commDetail18.OwnerId = origU.Id;
    commDetail18.Internal_Referral__c = origU2.Id;
    commDetail18.Internal_Referral_Fee__c = '50%';
    commDetail18.Approval_Status__c = 'Pending';

    insert commDetail18;

    Commission_Detail__c commDetail18Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail18.Id
    ];

    commDetail18Update.Approval_Status__c = 'Approved';

    update commDetail18Update;

    Commission_Detail__c commDetail19 = new Commission_Detail__c();
    commDetail19.Deal__c = topp1.Id;
    commDetail19.Commission_Type__c = 'Internal';
    commDetail19.OwnerId = origU.Id;
    commDetail19.Internal_Referral__c = origU2.Id;
    commDetail19.Internal_Referral_Fee__c = '50%';
    commDetail19.Approval_Status__c = 'Pending';

    insert commDetail19;

    Commission_Detail__c commDetail19Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail19.Id
    ];

    commDetail19Update.Approval_Status__c = 'Approved';

    update commDetail19Update;

    //+20 BPS in Spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+20 BPS in Spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail20 = new Commission_Detail__c();
    commDetail20.Deal__c = topp1.Id;
    commDetail20.Commission_Type__c = 'Direct';
    commDetail20.OwnerId = origU.Id;
    commDetail20.Internal_Referral__c = origU2.Id;
    commDetail20.Internal_Referral_Fee__c = '50%';
    commDetail20.Approval_Status__c = 'Pending';

    insert commDetail20;

    /*          Commission_Detail__c commDetail20Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail20.Id];  
              
    commDetail20Update.Approval_Status__c = 'Approved';
        
        update commDetail20Update;

        
    Commission_Detail__c commDetail21 = new Commission_Detail__c();
    commDetail21.Deal__c = topp1.Id;
    commDetail21.Commission_Type__c = 'Internal';
    commDetail21.OwnerId = origU.Id;
    commDetail21.Internal_Referral__c = origU2.Id;
    commDetail21.Internal_Referral_Fee__c = '50%';
    commDetail21.Approval_Status__c = 'Pending';
     
    insert commDetail21;
        
            
         Commission_Detail__c commDetail21Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail21.Id];  
              
    commDetail21Update.Approval_Status__c = 'Approved';
        
        update commDetail21Update;
 
        
        
        //-20 BPS in Spread / -50 BPS in Commissionable Fee
        topp1.CAF_YSP__c = '-20 BPS in Spread / -50 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail22 = new Commission_Detail__c();
    commDetail22.Deal__c = topp1.Id;
    commDetail22.Commission_Type__c = 'Direct';
    commDetail22.OwnerId = origU.Id;
    commDetail22.Internal_Referral__c = origU2.Id;
    commDetail22.Internal_Referral_Fee__c = '50%';
    commDetail22.Approval_Status__c = 'Pending';
     
    insert commDetail22;
        
Commission_Detail__c commDetail22Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail22.Id];  
              
    commDetail22Update.Approval_Status__c = 'Approved';
        
        update commDetail22Update;

        
    Commission_Detail__c commDetail23 = new Commission_Detail__c();
    commDetail23.Deal__c = topp1.Id;
    commDetail23.Commission_Type__c = 'Internal';
    commDetail23.OwnerId = origU.Id;
    commDetail23.Internal_Referral__c = origU2.Id;
    commDetail23.Internal_Referral_Fee__c = '50%';
    commDetail23.Approval_Status__c = 'Pending';
     
    insert commDetail23;
        
            
          Commission_Detail__c commDetail23Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail23.Id];  
              
    commDetail23Update.Approval_Status__c = 'Approved';
        
        update commDetail23Update; */

    Test.stopTest();
  }

  @isTest
  static void termCommissiontest7() {
    //Total Borrowed on term (account) under 5 million no split;Final Loan Amount under 5 million
    commissionAutomationSetting__c settings = new commissionAutomationSetting__c(
      SetupOwnerId = UserInfo.getOrganizationId(),
      SkipProcessBuilder__c = true
    );
    insert settings;
    CommissionDetail_TestSkip.setDoNotRunTrigger();

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
    topp1.CAF_YSP__c = null;
    topp1.CAF_Upfront_Fee__c = 2;
    topp1.Final_Loan_Amount__c = 7000000;
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

    Commission_Detail__c commDetailUpdate = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail.Id
    ];

    commDetailUpdate.Approval_Status__c = 'Approved';

    update commDetailUpdate;

    Commission_Detail__c commDetail1 = new Commission_Detail__c();
    commDetail1.Deal__c = topp1.Id;
    commDetail1.Commission_Type__c = 'Internal';
    commDetail1.OwnerId = origU.Id;
    commDetail1.Approval_Status__c = 'Pending';

    insert commDetail1;

    Commission_Detail__c commDetail1Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail1.Id
    ];

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

    Commission_Detail__c commDetail2Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail2.Id
    ];

    commDetail2Update.Approval_Status__c = 'Approved';

    update commDetail2Update;

    Commission_Detail__c commDetail3 = new Commission_Detail__c();
    commDetail3.Deal__c = topp1.Id;
    commDetail3.Commission_Type__c = 'Internal';
    commDetail3.OwnerId = origU.Id;
    commDetail3.Approval_Status__c = 'Pending';

    insert commDetail3;

    Commission_Detail__c commDetail3Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail3.Id
    ];

    commDetail3Update.Approval_Status__c = 'Approved';

    update commDetail3Update;

    //+5 BPS in Spread / +25 BPS in Commissionable Fee

    topp1.CAF_YSP__c = '+5 BPS in Spread / +25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail4 = new Commission_Detail__c();
    commDetail4.Deal__c = topp1.Id;
    commDetail4.Commission_Type__c = 'Direct';
    commDetail4.OwnerId = origU.Id;
    commDetail4.Approval_Status__c = 'Pending';

    insert commDetail4;

    Commission_Detail__c commDetail4Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail4.Id
    ];

    commDetail4Update.Approval_Status__c = 'Approved';

    update commDetail4Update;

    Commission_Detail__c commDetail5 = new Commission_Detail__c();
    commDetail5.Deal__c = topp1.Id;
    commDetail5.Commission_Type__c = 'Internal';
    commDetail5.OwnerId = origU.Id;
    commDetail5.Approval_Status__c = 'Pending';

    insert commDetail5;

    Commission_Detail__c commDetail5Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail5.Id
    ];

    commDetail5Update.Approval_Status__c = 'Approved';

    update commDetail5Update;

    //-5 BPS in Spread / -25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-5 BPS in Spread / -25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail6 = new Commission_Detail__c();
    commDetail6.Deal__c = topp1.Id;
    commDetail6.Commission_Type__c = 'Direct';
    commDetail6.OwnerId = origU.Id;
    commDetail6.Approval_Status__c = 'Pending';

    insert commDetail6;

    Commission_Detail__c commDetail6Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail6.Id
    ];

    commDetail6Update.Approval_Status__c = 'Approved';

    update commDetail6Update;

    Commission_Detail__c commDetail7 = new Commission_Detail__c();
    commDetail7.Deal__c = topp1.Id;
    commDetail7.Commission_Type__c = 'Internal';
    commDetail7.OwnerId = origU.Id;
    commDetail7.Approval_Status__c = 'Pending';

    insert commDetail7;

    Commission_Detail__c commDetail7Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail7.Id
    ];

    commDetail7Update.Approval_Status__c = 'Approved';

    update commDetail7Update;

    //+10 BPS in Spread / +25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+10 BPS in Spread / +25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail8 = new Commission_Detail__c();
    commDetail8.Deal__c = topp1.Id;
    commDetail8.Commission_Type__c = 'Direct';
    commDetail8.OwnerId = origU.Id;
    commDetail8.Approval_Status__c = 'Pending';

    insert commDetail8;

    Commission_Detail__c commDetail8Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail8.Id
    ];

    commDetail8Update.Approval_Status__c = 'Approved';

    update commDetail8Update;

    Commission_Detail__c commDetail9 = new Commission_Detail__c();
    commDetail9.Deal__c = topp1.Id;
    commDetail9.Commission_Type__c = 'Internal';
    commDetail9.OwnerId = origU.Id;
    commDetail9.Approval_Status__c = 'Pending';

    insert commDetail9;

    Commission_Detail__c commDetail9Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail9.Id
    ];

    commDetail9Update.Approval_Status__c = 'Approved';

    update commDetail9Update;

    //-10 BPS in Spread / -25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-10 BPS in Spread / -25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail10 = new Commission_Detail__c();
    commDetail10.Deal__c = topp1.Id;
    commDetail10.Commission_Type__c = 'Direct';
    commDetail10.OwnerId = origU.Id;
    commDetail10.Approval_Status__c = 'Pending';

    insert commDetail10;

    Commission_Detail__c commDetail10Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail10.Id
    ];

    commDetail10Update.Approval_Status__c = 'Approved';

    update commDetail10Update;

    Commission_Detail__c commDetail11 = new Commission_Detail__c();
    commDetail11.Deal__c = topp1.Id;
    commDetail11.Commission_Type__c = 'Internal';
    commDetail11.OwnerId = origU.Id;
    commDetail11.Approval_Status__c = 'Pending';

    insert commDetail11;

    Commission_Detail__c commDetail11Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail11.Id
    ];

    commDetail11Update.Approval_Status__c = 'Approved';

    update commDetail11Update;

    //+10 BPS in spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+10 BPS in spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail12 = new Commission_Detail__c();
    commDetail12.Deal__c = topp1.Id;
    commDetail12.Commission_Type__c = 'Direct';
    commDetail12.OwnerId = origU.Id;
    commDetail12.Approval_Status__c = 'Pending';

    insert commDetail12;

    Commission_Detail__c commDetail12Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail12.Id
    ];

    commDetail12Update.Approval_Status__c = 'Approved';

    update commDetail12Update;

    Commission_Detail__c commDetail13 = new Commission_Detail__c();
    commDetail13.Deal__c = topp1.Id;
    commDetail13.Commission_Type__c = 'Internal';
    commDetail13.OwnerId = origU.Id;
    commDetail13.Approval_Status__c = 'Pending';

    insert commDetail13;

    Commission_Detail__c commDetail13Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail13.Id
    ];

    commDetail13Update.Approval_Status__c = 'Approved';

    update commDetail13Update;

    //-10 BPS in spread / -50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-10 BPS in spread / -50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail14 = new Commission_Detail__c();
    commDetail14.Deal__c = topp1.Id;
    commDetail14.Commission_Type__c = 'Direct';
    commDetail14.OwnerId = origU.Id;
    commDetail14.Approval_Status__c = 'Pending';

    insert commDetail14;

    Commission_Detail__c commDetail14Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail14.Id
    ];

    commDetail14Update.Approval_Status__c = 'Approved';

    update commDetail14Update;

    Commission_Detail__c commDetail15 = new Commission_Detail__c();
    commDetail15.Deal__c = topp1.Id;
    commDetail15.Commission_Type__c = 'Internal';
    commDetail15.OwnerId = origU.Id;
    commDetail15.Approval_Status__c = 'Pending';

    insert commDetail15;

    Commission_Detail__c commDetail15Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail15.Id
    ];

    commDetail15Update.Approval_Status__c = 'Approved';

    update commDetail15Update;

    //+15 BPS in Spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+15 BPS in Spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail16 = new Commission_Detail__c();
    commDetail16.Deal__c = topp1.Id;
    commDetail16.Commission_Type__c = 'Direct';
    commDetail16.OwnerId = origU.Id;
    commDetail16.Approval_Status__c = 'Pending';

    insert commDetail16;

    Commission_Detail__c commDetail16Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail16.Id
    ];

    commDetail16Update.Approval_Status__c = 'Approved';

    update commDetail16Update;

    Commission_Detail__c commDetail17 = new Commission_Detail__c();
    commDetail17.Deal__c = topp1.Id;
    commDetail17.Commission_Type__c = 'Internal';
    commDetail17.OwnerId = origU.Id;
    commDetail17.Approval_Status__c = 'Pending';

    insert commDetail17;

    Commission_Detail__c commDetail17Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail17.Id
    ];

    commDetail17Update.Approval_Status__c = 'Approved';

    update commDetail17Update;

    //-15 BPS in Spread / -50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-15 BPS in Spread / -50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail18 = new Commission_Detail__c();
    commDetail18.Deal__c = topp1.Id;
    commDetail18.Commission_Type__c = 'Direct';
    commDetail18.OwnerId = origU.Id;
    commDetail18.Approval_Status__c = 'Pending';

    insert commDetail18;
    Commission_Detail__c commDetail18Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail18.Id
    ];

    commDetail18Update.Approval_Status__c = 'Approved';

    update commDetail18Update;

    Commission_Detail__c commDetail19 = new Commission_Detail__c();
    commDetail19.Deal__c = topp1.Id;
    commDetail19.Commission_Type__c = 'Internal';
    commDetail19.OwnerId = origU.Id;
    commDetail19.Approval_Status__c = 'Pending';

    insert commDetail19;

    Commission_Detail__c commDetail19Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail19.Id
    ];

    commDetail19Update.Approval_Status__c = 'Approved';

    update commDetail19Update;

    //+20 BPS in Spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+20 BPS in Spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail20 = new Commission_Detail__c();
    commDetail20.Deal__c = topp1.Id;
    commDetail20.Commission_Type__c = 'Direct';
    commDetail20.OwnerId = origU.Id;
    commDetail20.Approval_Status__c = 'Pending';

    insert commDetail20;

    /*          Commission_Detail__c commDetail20Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail20.Id];  
              
    commDetail20Update.Approval_Status__c = 'Approved';
        
        update commDetail20Update;

        
    Commission_Detail__c commDetail21 = new Commission_Detail__c();
    commDetail21.Deal__c = topp1.Id;
    commDetail21.Commission_Type__c = 'Internal';
    commDetail21.OwnerId = origU.Id;
    commDetail21.Approval_Status__c = 'Pending';
     
    insert commDetail21;
        
            
Commission_Detail__c commDetail21Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail21.Id];  
              
    commDetail21Update.Approval_Status__c = 'Approved';
        
        update commDetail21Update;

        
        
        //-20 BPS in Spread / -50 BPS in Commissionable Fee
        topp1.CAF_YSP__c = '-20 BPS in Spread / -50 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail22 = new Commission_Detail__c();
    commDetail22.Deal__c = topp1.Id;
    commDetail22.Commission_Type__c = 'Direct';
    commDetail22.OwnerId = origU.Id;
    commDetail22.Approval_Status__c = 'Pending';
     
    insert commDetail22;
        
         Commission_Detail__c commDetail22Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail22.Id];  
              
    commDetail22Update.Approval_Status__c = 'Approved';
        
        update commDetail22Update;

        
    Commission_Detail__c commDetail23 = new Commission_Detail__c();
    commDetail23.Deal__c = topp1.Id;
    commDetail23.Commission_Type__c = 'Internal';
    commDetail23.OwnerId = origU.Id;
    commDetail23.Approval_Status__c = 'Pending';
     
    insert commDetail23;
        
            
       Commission_Detail__c commDetail23Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail23.Id];  
              
    commDetail23Update.Approval_Status__c = 'Approved';
        
        update commDetail23Update; */

    Test.stopTest();
  }
  @isTest
  static void termCommissiontest8() {
    commissionAutomationSetting__c settings = new commissionAutomationSetting__c(
      SetupOwnerId = UserInfo.getOrganizationId(),
      SkipProcessBuilder__c = true
    );
    insert settings;
    CommissionDetail_TestSkip.setDoNotRunTrigger();

    //Total Borrowed on term (account) under 5 million split ‘50%’;Final Loan Amount under 5 million

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
    topp1.CAF_YSP__c = null;
    topp1.CAF_Upfront_Fee__c = 2;
    topp1.Final_Loan_Amount__c = 7000000;
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
    commDetail.Internal_Referral__c = origU2.Id;
    commDetail.Internal_Referral_Fee__c = '50%';
    commDetail.Approval_Status__c = 'Pending';

    insert commDetail;

    test.startTest();

    Commission_Detail__c commDetailUpdate = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail.Id
    ];

    commDetailUpdate.Approval_Status__c = 'Approved';

    update commDetailUpdate;

    Commission_Detail__c commDetail1 = new Commission_Detail__c();
    commDetail1.Deal__c = topp1.Id;
    commDetail1.Commission_Type__c = 'Internal';
    commDetail1.OwnerId = origU.Id;
    commDetail1.Internal_Referral__c = origU2.Id;
    commDetail1.Internal_Referral_Fee__c = '50%';
    commDetail1.Approval_Status__c = 'Pending';

    insert commDetail1;

    Commission_Detail__c commDetail1Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail1.Id
    ];

    commDetail1Update.Approval_Status__c = 'Approved';

    update commDetail1Update;

    //CAF YSP Section

    topp1.CAF_YSP__c = '0 BPS in Spread';
    update topp1;

    Commission_Detail__c commDetail2 = new Commission_Detail__c();
    commDetail2.Deal__c = topp1.Id;
    commDetail2.Commission_Type__c = 'Direct';
    commDetail2.OwnerId = origU.Id;
    commDetail2.Internal_Referral__c = origU2.Id;
    commDetail2.Internal_Referral_Fee__c = '50%';
    commDetail2.Approval_Status__c = 'Pending';

    insert commDetail2;

    Commission_Detail__c commDetail2Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail2.Id
    ];

    commDetail2Update.Approval_Status__c = 'Approved';

    update commDetail2Update;

    Commission_Detail__c commDetail3 = new Commission_Detail__c();
    commDetail3.Deal__c = topp1.Id;
    commDetail3.Commission_Type__c = 'Internal';
    commDetail3.OwnerId = origU.Id;
    commDetail3.Internal_Referral__c = origU2.Id;
    commDetail3.Internal_Referral_Fee__c = '50%';
    commDetail3.Approval_Status__c = 'Pending';

    insert commDetail3;

    Commission_Detail__c commDetail3Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail3.Id
    ];

    commDetail3Update.Approval_Status__c = 'Approved';

    update commDetail3Update;

    //+5 BPS in Spread / +25 BPS in Commissionable Fee

    topp1.CAF_YSP__c = '+5 BPS in Spread / +25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail4 = new Commission_Detail__c();
    commDetail4.Deal__c = topp1.Id;
    commDetail4.Commission_Type__c = 'Direct';
    commDetail4.OwnerId = origU.Id;
    commDetail4.Internal_Referral__c = origU2.Id;
    commDetail4.Internal_Referral_Fee__c = '50%';
    commDetail4.Approval_Status__c = 'Pending';

    insert commDetail4;

    Commission_Detail__c commDetail4Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail4.Id
    ];

    commDetail4Update.Approval_Status__c = 'Approved';

    update commDetail4Update;

    Commission_Detail__c commDetail5 = new Commission_Detail__c();
    commDetail5.Deal__c = topp1.Id;
    commDetail5.Commission_Type__c = 'Internal';
    commDetail5.OwnerId = origU.Id;
    commDetail5.Internal_Referral__c = origU2.Id;
    commDetail5.Internal_Referral_Fee__c = '50%';
    commDetail5.Approval_Status__c = 'Pending';

    insert commDetail5;

    Commission_Detail__c commDetail5Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail5.Id
    ];

    commDetail5Update.Approval_Status__c = 'Approved';

    update commDetail5Update;

    //-5 BPS in Spread / -25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-5 BPS in Spread / -25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail6 = new Commission_Detail__c();
    commDetail6.Deal__c = topp1.Id;
    commDetail6.Commission_Type__c = 'Direct';
    commDetail6.OwnerId = origU.Id;
    commDetail6.Internal_Referral__c = origU2.Id;
    commDetail6.Internal_Referral_Fee__c = '50%';
    commDetail6.Approval_Status__c = 'Pending';

    insert commDetail6;

    Commission_Detail__c commDetail6Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail6.Id
    ];

    commDetail6Update.Approval_Status__c = 'Approved';

    update commDetail6Update;

    Commission_Detail__c commDetail7 = new Commission_Detail__c();
    commDetail7.Deal__c = topp1.Id;
    commDetail7.Commission_Type__c = 'Internal';
    commDetail7.OwnerId = origU.Id;
    commDetail7.Internal_Referral__c = origU2.Id;
    commDetail7.Internal_Referral_Fee__c = '50%';
    commDetail7.Approval_Status__c = 'Pending';

    insert commDetail7;

    Commission_Detail__c commDetail7Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail7.Id
    ];

    commDetail7Update.Approval_Status__c = 'Approved';

    update commDetail7Update;

    //+10 BPS in Spread / +25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+10 BPS in Spread / +25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail8 = new Commission_Detail__c();
    commDetail8.Deal__c = topp1.Id;
    commDetail8.Commission_Type__c = 'Direct';
    commDetail8.OwnerId = origU.Id;
    commDetail8.Internal_Referral__c = origU2.Id;
    commDetail8.Internal_Referral_Fee__c = '50%';
    commDetail8.Approval_Status__c = 'Pending';

    insert commDetail8;

    Commission_Detail__c commDetail8Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail8.Id
    ];

    commDetail8Update.Approval_Status__c = 'Approved';

    update commDetail8Update;

    Commission_Detail__c commDetail9 = new Commission_Detail__c();
    commDetail9.Deal__c = topp1.Id;
    commDetail9.Commission_Type__c = 'Internal';
    commDetail9.OwnerId = origU.Id;
    commDetail9.Internal_Referral__c = origU2.Id;
    commDetail9.Internal_Referral_Fee__c = '50%';
    commDetail9.Approval_Status__c = 'Pending';

    insert commDetail9;

    Commission_Detail__c commDetail9Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail9.Id
    ];

    commDetail9Update.Approval_Status__c = 'Approved';

    update commDetail9Update;

    //-10 BPS in Spread / -25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-10 BPS in Spread / -25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail10 = new Commission_Detail__c();
    commDetail10.Deal__c = topp1.Id;
    commDetail10.Commission_Type__c = 'Direct';
    commDetail10.OwnerId = origU.Id;
    commDetail10.Internal_Referral__c = origU2.Id;
    commDetail10.Internal_Referral_Fee__c = '50%';
    commDetail10.Approval_Status__c = 'Pending';

    insert commDetail10;

    Commission_Detail__c commDetail10Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail10.Id
    ];

    commDetail10Update.Approval_Status__c = 'Approved';

    update commDetail10Update;

    Commission_Detail__c commDetail11 = new Commission_Detail__c();
    commDetail11.Deal__c = topp1.Id;
    commDetail11.Commission_Type__c = 'Internal';
    commDetail11.OwnerId = origU.Id;
    commDetail11.Internal_Referral__c = origU2.Id;
    commDetail11.Internal_Referral_Fee__c = '50%';
    commDetail11.Approval_Status__c = 'Pending';

    insert commDetail11;

    Commission_Detail__c commDetail11Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail11.Id
    ];

    commDetail11Update.Approval_Status__c = 'Approved';

    update commDetail11Update;

    //+10 BPS in spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+10 BPS in spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail12 = new Commission_Detail__c();
    commDetail12.Deal__c = topp1.Id;
    commDetail12.Commission_Type__c = 'Direct';
    commDetail12.OwnerId = origU.Id;
    commDetail12.Internal_Referral__c = origU2.Id;
    commDetail12.Internal_Referral_Fee__c = '50%';
    commDetail12.Approval_Status__c = 'Pending';

    insert commDetail12;

    Commission_Detail__c commDetail12Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail12.Id
    ];

    commDetail12Update.Approval_Status__c = 'Approved';

    update commDetail12Update;

    Commission_Detail__c commDetail13 = new Commission_Detail__c();
    commDetail13.Deal__c = topp1.Id;
    commDetail13.Commission_Type__c = 'Internal';
    commDetail13.OwnerId = origU.Id;
    commDetail13.Internal_Referral__c = origU2.Id;
    commDetail13.Internal_Referral_Fee__c = '50%';
    commDetail13.Approval_Status__c = 'Pending';

    insert commDetail13;

    Commission_Detail__c commDetail13Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail13.Id
    ];

    commDetail13Update.Approval_Status__c = 'Approved';

    update commDetail13Update;

    //-10 BPS in spread / -50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-10 BPS in spread / -50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail14 = new Commission_Detail__c();
    commDetail14.Deal__c = topp1.Id;
    commDetail14.Commission_Type__c = 'Direct';
    commDetail14.OwnerId = origU.Id;
    commDetail14.Internal_Referral__c = origU2.Id;
    commDetail14.Internal_Referral_Fee__c = '50%';
    commDetail14.Approval_Status__c = 'Pending';

    insert commDetail14;

    Commission_Detail__c commDetail14Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail14.Id
    ];

    commDetail14Update.Approval_Status__c = 'Approved';

    update commDetail14Update;

    Commission_Detail__c commDetail15 = new Commission_Detail__c();
    commDetail15.Deal__c = topp1.Id;
    commDetail15.Commission_Type__c = 'Internal';
    commDetail15.OwnerId = origU.Id;
    commDetail15.Internal_Referral__c = origU2.Id;
    commDetail15.Internal_Referral_Fee__c = '50%';
    commDetail15.Approval_Status__c = 'Pending';

    insert commDetail15;

    Commission_Detail__c commDetail15Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail15.Id
    ];

    commDetail15Update.Approval_Status__c = 'Approved';

    update commDetail15Update;

    //+15 BPS in Spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+15 BPS in Spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail16 = new Commission_Detail__c();
    commDetail16.Deal__c = topp1.Id;
    commDetail16.Commission_Type__c = 'Direct';
    commDetail16.OwnerId = origU.Id;
    commDetail16.Internal_Referral__c = origU2.Id;
    commDetail16.Internal_Referral_Fee__c = '50%';
    commDetail16.Approval_Status__c = 'Pending';

    insert commDetail16;

    Commission_Detail__c commDetail16Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail16.Id
    ];

    commDetail16Update.Approval_Status__c = 'Approved';

    update commDetail16Update;

    Commission_Detail__c commDetail17 = new Commission_Detail__c();
    commDetail17.Deal__c = topp1.Id;
    commDetail17.Commission_Type__c = 'Internal';
    commDetail17.OwnerId = origU.Id;
    commDetail17.Internal_Referral__c = origU2.Id;
    commDetail17.Internal_Referral_Fee__c = '50%';
    commDetail17.Approval_Status__c = 'Pending';

    insert commDetail17;

    Commission_Detail__c commDetail17Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail17.Id
    ];

    commDetail17Update.Approval_Status__c = 'Approved';

    update commDetail17Update;

    //-15 BPS in Spread / -50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-15 BPS in Spread / -50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail18 = new Commission_Detail__c();
    commDetail18.Deal__c = topp1.Id;
    commDetail18.Commission_Type__c = 'Direct';
    commDetail18.OwnerId = origU.Id;
    commDetail18.Internal_Referral__c = origU2.Id;
    commDetail18.Internal_Referral_Fee__c = '50%';
    commDetail18.Approval_Status__c = 'Pending';

    insert commDetail18;

    Commission_Detail__c commDetail18Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail18.Id
    ];

    commDetail18Update.Approval_Status__c = 'Approved';

    update commDetail18Update;

    Commission_Detail__c commDetail19 = new Commission_Detail__c();
    commDetail19.Deal__c = topp1.Id;
    commDetail19.Commission_Type__c = 'Internal';
    commDetail19.OwnerId = origU.Id;
    commDetail19.Internal_Referral__c = origU2.Id;
    commDetail19.Internal_Referral_Fee__c = '50%';
    commDetail19.Approval_Status__c = 'Pending';

    insert commDetail19;

    Commission_Detail__c commDetail19Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail19.Id
    ];

    commDetail19Update.Approval_Status__c = 'Approved';

    update commDetail19Update;

    //+20 BPS in Spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+20 BPS in Spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail20 = new Commission_Detail__c();
    commDetail20.Deal__c = topp1.Id;
    commDetail20.Commission_Type__c = 'Direct';
    commDetail20.OwnerId = origU.Id;
    commDetail20.Internal_Referral__c = origU2.Id;
    commDetail20.Internal_Referral_Fee__c = '50%';
    commDetail20.Approval_Status__c = 'Pending';

    insert commDetail20;

    /*          Commission_Detail__c commDetail20Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail20.Id];  
              
    commDetail20Update.Approval_Status__c = 'Approved';
        
        update commDetail20Update;

        
    Commission_Detail__c commDetail21 = new Commission_Detail__c();
    commDetail21.Deal__c = topp1.Id;
    commDetail21.Commission_Type__c = 'Internal';
    commDetail21.OwnerId = origU.Id;
    commDetail21.Internal_Referral__c = origU2.Id;
    commDetail21.Internal_Referral_Fee__c = '50%';
    commDetail21.Approval_Status__c = 'Pending';
     
    insert commDetail21;
        
            
         Commission_Detail__c commDetail21Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail21.Id];  
              
    commDetail21Update.Approval_Status__c = 'Approved';
        
        update commDetail21Update;

        
        
        //-20 BPS in Spread / -50 BPS in Commissionable Fee
        topp1.CAF_YSP__c = '-20 BPS in Spread / -50 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail22 = new Commission_Detail__c();
    commDetail22.Deal__c = topp1.Id;
    commDetail22.Commission_Type__c = 'Direct';
    commDetail22.OwnerId = origU.Id;
    commDetail22.Internal_Referral__c = origU2.Id;
    commDetail22.Internal_Referral_Fee__c = '50%';
    commDetail22.Approval_Status__c = 'Pending';
     
    insert commDetail22;
        
Commission_Detail__c commDetail22Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail22.Id];  
              
    commDetail22Update.Approval_Status__c = 'Approved';
        
        update commDetail22Update;

        
    Commission_Detail__c commDetail23 = new Commission_Detail__c();
    commDetail23.Deal__c = topp1.Id;
    commDetail23.Commission_Type__c = 'Internal';
    commDetail23.OwnerId = origU.Id;
    commDetail23.Internal_Referral__c = origU2.Id;
    commDetail23.Internal_Referral_Fee__c = '50%';
    commDetail23.Approval_Status__c = 'Pending';
     
    insert commDetail23;
        
          Commission_Detail__c commDetail23Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail23.Id];  
              
    commDetail23Update.Approval_Status__c = 'Approved';
        
        update commDetail23Update; */

    Test.stopTest();
  }
  @isTest
  static void termCommissiontest9() {
    commissionAutomationSetting__c settings = new commissionAutomationSetting__c(
      SetupOwnerId = UserInfo.getOrganizationId(),
      SkipProcessBuilder__c = true
    );
    insert settings;
    CommissionDetail_TestSkip.setDoNotRunTrigger();

    //Total Borrowed on term (account) Over 5 million no split;Final Loan Amount under 5 million
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
    topp1.CAF_YSP__c = null;
    topp1.CAF_Upfront_Fee__c = 2;
    topp1.Final_Loan_Amount__c = 7000000;
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

    Opportunity topp2 = new Opportunity();
    topp2.Name = 'test';
    topp2.CloseDate = System.today();
    topp2.StageName = 'Initial Review';
    topp2.Loan_Size__c = 20000000;
    topp2.AccountId = acc.Id;
    topp2.Contact__c = cont.Id;
    topp2.OwnerId = origU.id;
    topp2.CAF_YSP__c = null;
    topp2.CAF_Upfront_Fee__c = 2;
    topp2.Final_Loan_Amount__c = 20000000;
    topp2.Deal_Intro_Source__c = 'Hotline';
    topp2.Deal_Intro_Sub_Source__c = 'Main';
    topp2.Apex_Context__c = true;
    topp2.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
    ]
    .Id;
    insert topp2;

    topp2.CAF_Upfront_Fee__c = 2;
    update topp2;

    //Final Loan amount under 5 million

    Commission_Detail__c commDetail = new Commission_Detail__c();
    commDetail.Deal__c = topp1.Id;
    commDetail.Commission_Type__c = 'Direct';
    commDetail.OwnerId = origU.Id;
    commDetail.Approval_Status__c = 'Pending';

    insert commDetail;

    test.startTest();

    Commission_Detail__c commDetailUpdate = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail.Id
    ];

    commDetailUpdate.Approval_Status__c = 'Approved';

    update commDetailUpdate;

    Commission_Detail__c commDetail1 = new Commission_Detail__c();
    commDetail1.Deal__c = topp1.Id;
    commDetail1.Commission_Type__c = 'Internal';
    commDetail1.OwnerId = origU.Id;
    commDetail1.Approval_Status__c = 'Pending';

    insert commDetail1;

    Commission_Detail__c commDetail1Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail1.Id
    ];

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

    Commission_Detail__c commDetail2Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail2.Id
    ];

    commDetail2Update.Approval_Status__c = 'Approved';

    update commDetail2Update;

    Commission_Detail__c commDetail3 = new Commission_Detail__c();
    commDetail3.Deal__c = topp1.Id;
    commDetail3.Commission_Type__c = 'Internal';
    commDetail3.OwnerId = origU.Id;
    commDetail3.Approval_Status__c = 'Pending';

    insert commDetail3;

    Commission_Detail__c commDetail3Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail3.Id
    ];

    commDetail3Update.Approval_Status__c = 'Approved';

    update commDetail3Update;

    //+5 BPS in Spread / +25 BPS in Commissionable Fee

    topp1.CAF_YSP__c = '+5 BPS in Spread / +25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail4 = new Commission_Detail__c();
    commDetail4.Deal__c = topp1.Id;
    commDetail4.Commission_Type__c = 'Direct';
    commDetail4.OwnerId = origU.Id;
    commDetail4.Approval_Status__c = 'Pending';

    insert commDetail4;

    Commission_Detail__c commDetail4Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail4.Id
    ];

    commDetail4Update.Approval_Status__c = 'Approved';

    update commDetail4Update;

    Commission_Detail__c commDetail5 = new Commission_Detail__c();
    commDetail5.Deal__c = topp1.Id;
    commDetail5.Commission_Type__c = 'Internal';
    commDetail5.OwnerId = origU.Id;
    commDetail5.Approval_Status__c = 'Pending';

    insert commDetail5;

    Commission_Detail__c commDetail5Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail5.Id
    ];

    commDetail5Update.Approval_Status__c = 'Approved';

    update commDetail5Update;

    //-5 BPS in Spread / -25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-5 BPS in Spread / -25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail6 = new Commission_Detail__c();
    commDetail6.Deal__c = topp1.Id;
    commDetail6.Commission_Type__c = 'Direct';
    commDetail6.OwnerId = origU.Id;
    commDetail6.Approval_Status__c = 'Pending';

    insert commDetail6;

    Commission_Detail__c commDetail6Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail6.Id
    ];

    commDetail6Update.Approval_Status__c = 'Approved';

    update commDetail6Update;

    Commission_Detail__c commDetail7 = new Commission_Detail__c();
    commDetail7.Deal__c = topp1.Id;
    commDetail7.Commission_Type__c = 'Internal';
    commDetail7.OwnerId = origU.Id;
    commDetail7.Approval_Status__c = 'Pending';

    insert commDetail7;

    Commission_Detail__c commDetail7Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail7.Id
    ];

    commDetail7Update.Approval_Status__c = 'Approved';

    update commDetail7Update;

    //+10 BPS in Spread / +25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+10 BPS in Spread / +25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail8 = new Commission_Detail__c();
    commDetail8.Deal__c = topp1.Id;
    commDetail8.Commission_Type__c = 'Direct';
    commDetail8.OwnerId = origU.Id;
    commDetail8.Approval_Status__c = 'Pending';

    insert commDetail8;

    Commission_Detail__c commDetail8Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail8.Id
    ];

    commDetail8Update.Approval_Status__c = 'Approved';

    update commDetail8Update;

    Commission_Detail__c commDetail9 = new Commission_Detail__c();
    commDetail9.Deal__c = topp1.Id;
    commDetail9.Commission_Type__c = 'Internal';
    commDetail9.OwnerId = origU.Id;
    commDetail9.Approval_Status__c = 'Pending';

    insert commDetail9;

    Commission_Detail__c commDetail9Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail9.Id
    ];

    commDetail9Update.Approval_Status__c = 'Approved';

    update commDetail9Update;

    //-10 BPS in Spread / -25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-10 BPS in Spread / -25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail10 = new Commission_Detail__c();
    commDetail10.Deal__c = topp1.Id;
    commDetail10.Commission_Type__c = 'Direct';
    commDetail10.OwnerId = origU.Id;
    commDetail10.Approval_Status__c = 'Pending';

    insert commDetail10;

    Commission_Detail__c commDetail10Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail10.Id
    ];

    commDetail10Update.Approval_Status__c = 'Approved';

    update commDetail10Update;

    Commission_Detail__c commDetail11 = new Commission_Detail__c();
    commDetail11.Deal__c = topp1.Id;
    commDetail11.Commission_Type__c = 'Internal';
    commDetail11.OwnerId = origU.Id;
    commDetail11.Approval_Status__c = 'Pending';

    insert commDetail11;

    Commission_Detail__c commDetail11Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail11.Id
    ];

    commDetail11Update.Approval_Status__c = 'Approved';

    update commDetail11Update;

    //+10 BPS in spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+10 BPS in spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail12 = new Commission_Detail__c();
    commDetail12.Deal__c = topp1.Id;
    commDetail12.Commission_Type__c = 'Direct';
    commDetail12.OwnerId = origU.Id;
    commDetail12.Approval_Status__c = 'Pending';

    insert commDetail12;

    Commission_Detail__c commDetail12Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail12.Id
    ];

    commDetail12Update.Approval_Status__c = 'Approved';

    update commDetail12Update;

    Commission_Detail__c commDetail13 = new Commission_Detail__c();
    commDetail13.Deal__c = topp1.Id;
    commDetail13.Commission_Type__c = 'Internal';
    commDetail13.OwnerId = origU.Id;
    commDetail13.Approval_Status__c = 'Pending';

    insert commDetail13;

    Commission_Detail__c commDetail13Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail13.Id
    ];

    commDetail13Update.Approval_Status__c = 'Approved';

    update commDetail13Update;

    //-10 BPS in spread / -50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-10 BPS in spread / -50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail14 = new Commission_Detail__c();
    commDetail14.Deal__c = topp1.Id;
    commDetail14.Commission_Type__c = 'Direct';
    commDetail14.OwnerId = origU.Id;
    commDetail14.Approval_Status__c = 'Pending';

    insert commDetail14;

    Commission_Detail__c commDetail14Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail14.Id
    ];

    commDetail14Update.Approval_Status__c = 'Approved';

    update commDetail14Update;

    Commission_Detail__c commDetail15 = new Commission_Detail__c();
    commDetail15.Deal__c = topp1.Id;
    commDetail15.Commission_Type__c = 'Internal';
    commDetail15.OwnerId = origU.Id;
    commDetail15.Approval_Status__c = 'Pending';

    insert commDetail15;

    Commission_Detail__c commDetail15Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail15.Id
    ];

    commDetail15Update.Approval_Status__c = 'Approved';

    update commDetail15Update;

    //+15 BPS in Spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+15 BPS in Spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail16 = new Commission_Detail__c();
    commDetail16.Deal__c = topp1.Id;
    commDetail16.Commission_Type__c = 'Direct';
    commDetail16.OwnerId = origU.Id;
    commDetail16.Approval_Status__c = 'Pending';

    insert commDetail16;

    Commission_Detail__c commDetail16Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail16.Id
    ];

    commDetail16Update.Approval_Status__c = 'Approved';

    update commDetail16Update;

    Commission_Detail__c commDetail17 = new Commission_Detail__c();
    commDetail17.Deal__c = topp1.Id;
    commDetail17.Commission_Type__c = 'Internal';
    commDetail17.OwnerId = origU.Id;
    commDetail17.Approval_Status__c = 'Pending';

    insert commDetail17;

    Commission_Detail__c commDetail17Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail17.Id
    ];

    commDetail17Update.Approval_Status__c = 'Approved';

    update commDetail17Update;

    //-15 BPS in Spread / -50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-15 BPS in Spread / -50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail18 = new Commission_Detail__c();
    commDetail18.Deal__c = topp1.Id;
    commDetail18.Commission_Type__c = 'Direct';
    commDetail18.OwnerId = origU.Id;
    commDetail18.Approval_Status__c = 'Pending';

    insert commDetail18;

    Commission_Detail__c commDetail18Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail18.Id
    ];

    commDetail18Update.Approval_Status__c = 'Approved';

    update commDetail18Update;

    Commission_Detail__c commDetail19 = new Commission_Detail__c();
    commDetail19.Deal__c = topp1.Id;
    commDetail19.Commission_Type__c = 'Internal';
    commDetail19.OwnerId = origU.Id;
    commDetail19.Approval_Status__c = 'Pending';

    insert commDetail19;

    Commission_Detail__c commDetail19Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail19.Id
    ];

    commDetail19Update.Approval_Status__c = 'Approved';

    update commDetail19Update;

    //+20 BPS in Spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+20 BPS in Spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail20 = new Commission_Detail__c();
    commDetail20.Deal__c = topp1.Id;
    commDetail20.Commission_Type__c = 'Direct';
    commDetail20.OwnerId = origU.Id;
    commDetail20.Approval_Status__c = 'Pending';

    insert commDetail20;

    /* Commission_Detail__c commDetail20Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail20.Id];  
              
    commDetail20Update.Approval_Status__c = 'Approved';
        
        update commDetail20Update;

        
    Commission_Detail__c commDetail21 = new Commission_Detail__c();
    commDetail21.Deal__c = topp1.Id;
    commDetail21.Commission_Type__c = 'Internal';
    commDetail21.OwnerId = origU.Id;
    commDetail21.Approval_Status__c = 'Pending';
     
    insert commDetail21;
        
            
     Commission_Detail__c commDetail21Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail21.Id];  
              
    commDetail21Update.Approval_Status__c = 'Approved';
        
        update commDetail21Update;

        
        
        //-20 BPS in Spread / -50 BPS in Commissionable Fee
        topp1.CAF_YSP__c = '-20 BPS in Spread / -50 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail22 = new Commission_Detail__c();
    commDetail22.Deal__c = topp1.Id;
    commDetail22.Commission_Type__c = 'Direct';
    commDetail22.OwnerId = origU.Id;
    commDetail22.Approval_Status__c = 'Pending';
     
    insert commDetail22;
        
Commission_Detail__c commDetail22Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail22.Id];  
              
    commDetail22Update.Approval_Status__c = 'Approved';
        
        update commDetail22Update;

        
    Commission_Detail__c commDetail23 = new Commission_Detail__c();
    commDetail23.Deal__c = topp1.Id;
    commDetail23.Commission_Type__c = 'Internal';
    commDetail23.OwnerId = origU.Id;
    commDetail23.Approval_Status__c = 'Pending';
     
    insert commDetail23;
        
          Commission_Detail__c commDetail23Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail23.Id];  
              
    commDetail23Update.Approval_Status__c = 'Approved';
        
        update commDetail23Update; */

    Test.stopTest();
  }
  /*  @isTest static void termCommissiontest10() {
        commissionAutomationSetting__c  settings = new commissionAutomationSetting__c (SetupOwnerId=UserInfo.getOrganizationId(), SkipProcessBuilder__c= true);
insert settings;
                CommissionDetail_TestSkip.setDoNotRunTrigger();

        //Total Borrowed on term (account) Over 5 million split ‘50%’;Final Loan Amount under 5 million
        
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
    topp1.Final_Loan_Amount__c = 7000000;
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
        
    Opportunity topp2 = new Opportunity();
    topp2.Name = 'test';
    topp2.CloseDate = System.today();
    topp2.StageName = 'Initial Review';
    topp2.Loan_Size__c = 20000000;
    topp2.AccountId = acc.Id;
    topp2.Contact__c = cont.Id;
    topp2.OwnerId = origU.id;
    topp2.CAF_YSP__c= null;
    topp2.CAF_Upfront_Fee__c = 2;
    topp2.Final_Loan_Amount__c = 20000000;
    topp2.Deal_Intro_Source__c = 'Hotline';
    topp2.Deal_Intro_Sub_Source__c = 'Main';
    topp2.Apex_Context__c = true;
    topp2.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
    ]
    .Id;
    insert topp2;
        
    //Final Loan amount under 5 million
    
    Commission_Detail__c commDetail = new Commission_Detail__c();
    commDetail.Deal__c = topp1.Id;
    commDetail.Commission_Type__c = 'Direct';
    commDetail.OwnerId = origU.Id;
    commDetail.Internal_Referral__c = origU2.Id;
    commDetail.Internal_Referral_Fee__c = '20%';
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
    commDetail1.Internal_Referral__c = origU2.Id;
    commDetail1.Internal_Referral_Fee__c = '20%';
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
    commDetail2.Internal_Referral__c = origU2.Id;
    commDetail2.Internal_Referral_Fee__c = '20%';
    commDetail2.Approval_Status__c = 'Pending';
     
    insert commDetail2;
        
Commission_Detail__c commDetail2Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail2.Id];  
              
    commDetail2Update.Approval_Status__c = 'Approved';
        
        update commDetail2Update;

        
    Commission_Detail__c commDetail3 = new Commission_Detail__c();
    commDetail3.Deal__c = topp1.Id;
    commDetail3.Commission_Type__c = 'Internal';
    commDetail3.OwnerId = origU.Id;
    commDetail3.Internal_Referral__c = origU2.Id;
    commDetail3.Internal_Referral_Fee__c = '20%';
    commDetail3.Approval_Status__c = 'Pending';
     
    insert commDetail3;
        
            
  Commission_Detail__c commDetail3Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail3.Id];  
              
    commDetail3Update.Approval_Status__c = 'Approved';
        
        update commDetail3Update;

        
        //+5 BPS in Spread / +25 BPS in Commissionable Fee
        
      topp1.CAF_YSP__c = '+5 BPS in Spread / +25 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail4 = new Commission_Detail__c();
    commDetail4.Deal__c = topp1.Id;
    commDetail4.Commission_Type__c = 'Direct';
    commDetail4.OwnerId = origU.Id;
    commDetail4.Internal_Referral__c = origU2.Id;
    commDetail4.Internal_Referral_Fee__c = '20%';
    commDetail4.Approval_Status__c = 'Pending';
     
    insert commDetail4;
        
         Commission_Detail__c commDetail4Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail4.Id];  
              
    commDetail4Update.Approval_Status__c = 'Approved';
        
        update commDetail4Update;

        
    Commission_Detail__c commDetail5 = new Commission_Detail__c();
    commDetail5.Deal__c = topp1.Id;
    commDetail5.Commission_Type__c = 'Internal';
    commDetail5.OwnerId = origU.Id;
    commDetail5.Internal_Referral__c = origU2.Id;
    commDetail5.Internal_Referral_Fee__c = '20%';
    commDetail5.Approval_Status__c = 'Pending';
     
    insert commDetail5;
        
            
         Commission_Detail__c commDetail5Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail5.Id];  
              
    commDetail5Update.Approval_Status__c = 'Approved';
        
        update commDetail5Update; 

        
        //-5 BPS in Spread / -25 BPS in Commissionable Fee
      topp1.CAF_YSP__c = '-5 BPS in Spread / -25 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail6 = new Commission_Detail__c();
    commDetail6.Deal__c = topp1.Id;
    commDetail6.Commission_Type__c = 'Direct';
    commDetail6.OwnerId = origU.Id;
    commDetail6.Internal_Referral__c = origU2.Id;
    commDetail6.Internal_Referral_Fee__c = '20%';
    commDetail6.Approval_Status__c = 'Pending';
     
    insert commDetail6;
        
    commDetail6.Approval_Status__c = 'Approved';
        
        update commDetail6;
        
    Commission_Detail__c commDetail7 = new Commission_Detail__c();
    commDetail7.Deal__c = topp1.Id;
    commDetail7.Commission_Type__c = 'Internal';
    commDetail7.OwnerId = origU.Id;
    commDetail7.Internal_Referral__c = origU2.Id;
    commDetail7.Internal_Referral_Fee__c = '20%';
    commDetail7.Approval_Status__c = 'Pending';
     
    insert commDetail7;
        
            
    commDetail7.Approval_Status__c = 'Approved';
        
        update commDetail7; 
        
        //+10 BPS in Spread / +25 BPS in Commissionable Fee
      topp1.CAF_YSP__c = '+10 BPS in Spread / +25 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail8 = new Commission_Detail__c();
    commDetail8.Deal__c = topp1.Id;
    commDetail8.Commission_Type__c = 'Direct';
    commDetail8.OwnerId = origU.Id;
    commDetail8.Internal_Referral__c = origU2.Id;
    commDetail8.Internal_Referral_Fee__c = '20%';
    commDetail8.Approval_Status__c = 'Pending';
     
    insert commDetail8;
        
    commDetail8.Approval_Status__c = 'Approved';
        
        update commDetail8;
        
    Commission_Detail__c commDetail9 = new Commission_Detail__c();
    commDetail9.Deal__c = topp1.Id;
    commDetail9.Commission_Type__c = 'Internal';
    commDetail9.OwnerId = origU.Id;
    commDetail9.Internal_Referral__c = origU2.Id;
    commDetail9.Internal_Referral_Fee__c = '20%';
    commDetail9.Approval_Status__c = 'Pending';
     
    insert commDetail9;
        
            
    commDetail9.Approval_Status__c = 'Approved';
        
        update commDetail9;  
        
        //-10 BPS in Spread / -25 BPS in Commissionable Fee
      topp1.CAF_YSP__c = '-10 BPS in Spread / -25 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail10 = new Commission_Detail__c();
    commDetail10.Deal__c = topp1.Id;
    commDetail10.Commission_Type__c = 'Direct';
    commDetail10.OwnerId = origU.Id;
    commDetail10.Internal_Referral__c = origU2.Id;
    commDetail10.Internal_Referral_Fee__c = '20%';
    commDetail10.Approval_Status__c = 'Pending';
     
    insert commDetail10;
        
    commDetail10.Approval_Status__c = 'Approved';
        
        update commDetail8;
        
    Commission_Detail__c commDetail11 = new Commission_Detail__c();
    commDetail11.Deal__c = topp1.Id;
    commDetail11.Commission_Type__c = 'Internal';
    commDetail11.OwnerId = origU.Id;
    commDetail11.Internal_Referral__c = origU2.Id;
    commDetail11.Internal_Referral_Fee__c = '20%';
    commDetail11.Approval_Status__c = 'Pending';
     
    insert commDetail11;
        
            
    commDetail11.Approval_Status__c = 'Approved';
        
        update commDetail11;        
        
        //+10 BPS in spread / +50 BPS in Commissionable Fee
      topp1.CAF_YSP__c = '+10 BPS in spread / +50 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail12 = new Commission_Detail__c();
    commDetail12.Deal__c = topp1.Id;
    commDetail12.Commission_Type__c = 'Direct';
    commDetail12.OwnerId = origU.Id;
    commDetail12.Internal_Referral__c = origU2.Id;
    commDetail12.Internal_Referral_Fee__c = '20%';
    commDetail12.Approval_Status__c = 'Pending';
     
    insert commDetail12;
        
    commDetail12.Approval_Status__c = 'Approved';
        
        update commDetail12;
        
    Commission_Detail__c commDetail13 = new Commission_Detail__c();
    commDetail13.Deal__c = topp1.Id;
    commDetail13.Commission_Type__c = 'Internal';
    commDetail13.OwnerId = origU.Id;
    commDetail13.Internal_Referral__c = origU2.Id;
    commDetail13.Internal_Referral_Fee__c = '20%';
    commDetail13.Approval_Status__c = 'Pending';
     
    insert commDetail13;
        
            
    commDetail13.Approval_Status__c = 'Approved';
        
        update commDetail13;   
        
        
        
        
                //-10 BPS in spread / -50 BPS in Commissionable Fee
      topp1.CAF_YSP__c = '-10 BPS in spread / -50 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail14 = new Commission_Detail__c();
    commDetail14.Deal__c = topp1.Id;
    commDetail14.Commission_Type__c = 'Direct';
    commDetail14.OwnerId = origU.Id;
    commDetail14.Internal_Referral__c = origU2.Id;
    commDetail14.Internal_Referral_Fee__c = '20%';
    commDetail14.Approval_Status__c = 'Pending';
     
    insert commDetail14;
        
    commDetail14.Approval_Status__c = 'Approved';
        
        update commDetail14;
        
    Commission_Detail__c commDetail15 = new Commission_Detail__c();
    commDetail15.Deal__c = topp1.Id;
    commDetail15.Commission_Type__c = 'Internal';
    commDetail15.OwnerId = origU.Id;
    commDetail15.Internal_Referral__c = origU2.Id;
    commDetail15.Internal_Referral_Fee__c = '20%';
    commDetail15.Approval_Status__c = 'Pending';
     
    insert commDetail15;
        
            
    commDetail15.Approval_Status__c = 'Approved';
        
        update commDetail15;
        
        //+15 BPS in Spread / +50 BPS in Commissionable Fee
topp1.CAF_YSP__c = '+15 BPS in Spread / +50 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail16 = new Commission_Detail__c();
    commDetail16.Deal__c = topp1.Id;
    commDetail16.Commission_Type__c = 'Direct';
    commDetail16.OwnerId = origU.Id;
    commDetail16.Internal_Referral__c = origU2.Id;
    commDetail16.Internal_Referral_Fee__c = '20%';
    commDetail16.Approval_Status__c = 'Pending';
     
    insert commDetail16;
        
    commDetail16.Approval_Status__c = 'Approved';
        
        update commDetail16;
        
    Commission_Detail__c commDetail17 = new Commission_Detail__c();
    commDetail17.Deal__c = topp1.Id;
    commDetail17.Commission_Type__c = 'Internal';
    commDetail17.OwnerId = origU.Id;
    commDetail17.Internal_Referral__c = origU2.Id;
    commDetail17.Internal_Referral_Fee__c = '20%';
    commDetail17.Approval_Status__c = 'Pending';
     
    insert commDetail17;
        
            
    commDetail17.Approval_Status__c = 'Approved';
        
        update commDetail17;        

        //-15 BPS in Spread / -50 BPS in Commissionable Fee
 topp1.CAF_YSP__c = '-15 BPS in Spread / -50 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail18 = new Commission_Detail__c();
    commDetail18.Deal__c = topp1.Id;
    commDetail18.Commission_Type__c = 'Direct';
    commDetail18.OwnerId = origU.Id;
    commDetail18.Internal_Referral__c = origU2.Id;
    commDetail18.Internal_Referral_Fee__c = '20%';
    commDetail18.Approval_Status__c = 'Pending';
     
    insert commDetail18;
        
    commDetail18.Approval_Status__c = 'Approved';
        
        update commDetail18;
        
    Commission_Detail__c commDetail19 = new Commission_Detail__c();
    commDetail19.Deal__c = topp1.Id;
    commDetail19.Commission_Type__c = 'Internal';
    commDetail19.OwnerId = origU.Id;
    commDetail19.Internal_Referral__c = origU2.Id;
    commDetail19.Internal_Referral_Fee__c = '20%';
    commDetail19.Approval_Status__c = 'Pending';
     
    insert commDetail19;
        
            
    commDetail19.Approval_Status__c = 'Approved';
        
        update commDetail19;    
        
        
        //+20 BPS in Spread / +50 BPS in Commissionable Fee
topp1.CAF_YSP__c = '+20 BPS in Spread / +50 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail20 = new Commission_Detail__c();
    commDetail20.Deal__c = topp1.Id;
    commDetail20.Commission_Type__c = 'Direct';
    commDetail20.OwnerId = origU.Id;
    commDetail20.Internal_Referral__c = origU2.Id;
    commDetail20.Internal_Referral_Fee__c = '20%';
    commDetail20.Approval_Status__c = 'Pending';
     
    insert commDetail20;
        
    commDetail20.Approval_Status__c = 'Approved';
        
        update commDetail20;
        
    Commission_Detail__c commDetail21 = new Commission_Detail__c();
    commDetail21.Deal__c = topp1.Id;
    commDetail21.Commission_Type__c = 'Internal';
    commDetail21.OwnerId = origU.Id;
    commDetail21.Internal_Referral__c = origU2.Id;
    commDetail21.Internal_Referral_Fee__c = '20%';
    commDetail21.Approval_Status__c = 'Pending';
     
    insert commDetail21;
        
            
    commDetail21.Approval_Status__c = 'Approved';
        
        update commDetail21; 
        
        
        //-20 BPS in Spread / -50 BPS in Commissionable Fee
        topp1.CAF_YSP__c = '-20 BPS in Spread / -50 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail22 = new Commission_Detail__c();
    commDetail22.Deal__c = topp1.Id;
    commDetail22.Commission_Type__c = 'Direct';
    commDetail22.OwnerId = origU.Id;
    commDetail22.Internal_Referral__c = origU2.Id;
    commDetail22.Internal_Referral_Fee__c = '20%';
    commDetail22.Approval_Status__c = 'Pending';
     
    insert commDetail22;
        
    commDetail22.Approval_Status__c = 'Approved';
        
        update commDetail22;
        
    Commission_Detail__c commDetail23 = new Commission_Detail__c();
    commDetail23.Deal__c = topp1.Id;
    commDetail23.Commission_Type__c = 'Internal';
    commDetail23.OwnerId = origU.Id;
    commDetail23.Internal_Referral__c = origU2.Id;
    commDetail23.Internal_Referral_Fee__c = '20%';
    commDetail23.Approval_Status__c = 'Pending';
     
    insert commDetail23;
        
            
    commDetail23.Approval_Status__c = 'Approved';
        
        update commDetail23;
        
        Test.stopTest();

    } */
  @isTest
  static void termCommissiontest11() {
    commissionAutomationSetting__c settings = new commissionAutomationSetting__c(
      SetupOwnerId = UserInfo.getOrganizationId(),
      SkipProcessBuilder__c = true
    );
    insert settings;
    CommissionDetail_TestSkip.setDoNotRunTrigger();

    //Total Borrowed on term (account) under 5 million split ‘20%’;Final Loan Amount under 5 million

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
    topp1.CAF_YSP__c = null;
    topp1.CAF_Upfront_Fee__c = 2;
    topp1.Final_Loan_Amount__c = 7000000;
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
    commDetail.Internal_Referral__c = origU2.Id;
    commDetail.Internal_Referral_Fee__c = '20%';
    commDetail.Approval_Status__c = 'Pending';

    insert commDetail;

    test.startTest();

    commDetail.Approval_Status__c = 'Approved';

    update commDetail;

    Commission_Detail__c commDetail1 = new Commission_Detail__c();
    commDetail1.Deal__c = topp1.Id;
    commDetail1.Commission_Type__c = 'Internal';
    commDetail1.OwnerId = origU.Id;
    commDetail1.Internal_Referral__c = origU2.Id;
    commDetail1.Internal_Referral_Fee__c = '20%';
    commDetail1.Approval_Status__c = 'Pending';

    insert commDetail1;

    commDetail1.Approval_Status__c = 'Approved';

    update commDetail1;

    //CAF YSP Section

    topp1.CAF_YSP__c = '0 BPS in Spread';
    update topp1;

    Commission_Detail__c commDetail2 = new Commission_Detail__c();
    commDetail2.Deal__c = topp1.Id;
    commDetail2.Commission_Type__c = 'Direct';
    commDetail2.OwnerId = origU.Id;
    commDetail2.Internal_Referral__c = origU2.Id;
    commDetail2.Internal_Referral_Fee__c = '20%';
    commDetail2.Approval_Status__c = 'Pending';

    insert commDetail2;

    commDetail2.Approval_Status__c = 'Approved';

    update commDetail2;

    Commission_Detail__c commDetail3 = new Commission_Detail__c();
    commDetail3.Deal__c = topp1.Id;
    commDetail3.Commission_Type__c = 'Internal';
    commDetail3.OwnerId = origU.Id;
    commDetail3.Internal_Referral__c = origU2.Id;
    commDetail3.Internal_Referral_Fee__c = '20%';
    commDetail3.Approval_Status__c = 'Pending';

    insert commDetail3;

    commDetail3.Approval_Status__c = 'Approved';

    update commDetail3;

    //+5 BPS in Spread / +25 BPS in Commissionable Fee

    topp1.CAF_YSP__c = '+5 BPS in Spread / +25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail4 = new Commission_Detail__c();
    commDetail4.Deal__c = topp1.Id;
    commDetail4.Commission_Type__c = 'Direct';
    commDetail4.OwnerId = origU.Id;
    commDetail4.Internal_Referral__c = origU2.Id;
    commDetail4.Internal_Referral_Fee__c = '20%';
    commDetail4.Approval_Status__c = 'Pending';

    insert commDetail4;

    commDetail4.Approval_Status__c = 'Approved';

    update commDetail4;

    Commission_Detail__c commDetail5 = new Commission_Detail__c();
    commDetail5.Deal__c = topp1.Id;
    commDetail5.Commission_Type__c = 'Internal';
    commDetail5.OwnerId = origU.Id;
    commDetail5.Internal_Referral__c = origU2.Id;
    commDetail5.Internal_Referral_Fee__c = '20%';
    commDetail5.Approval_Status__c = 'Pending';

    insert commDetail5;

    commDetail5.Approval_Status__c = 'Approved';

    update commDetail5;

    //-5 BPS in Spread / -25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-5 BPS in Spread / -25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail6 = new Commission_Detail__c();
    commDetail6.Deal__c = topp1.Id;
    commDetail6.Commission_Type__c = 'Direct';
    commDetail6.OwnerId = origU.Id;
    commDetail6.Internal_Referral__c = origU2.Id;
    commDetail6.Internal_Referral_Fee__c = '20%';
    commDetail6.Approval_Status__c = 'Pending';

    insert commDetail6;

    commDetail6.Approval_Status__c = 'Approved';

    update commDetail6;

    Commission_Detail__c commDetail7 = new Commission_Detail__c();
    commDetail7.Deal__c = topp1.Id;
    commDetail7.Commission_Type__c = 'Internal';
    commDetail7.OwnerId = origU.Id;
    commDetail7.Internal_Referral__c = origU2.Id;
    commDetail7.Internal_Referral_Fee__c = '20%';
    commDetail7.Approval_Status__c = 'Pending';

    insert commDetail7;

    commDetail7.Approval_Status__c = 'Approved';

    update commDetail7;

    //+10 BPS in Spread / +25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+10 BPS in Spread / +25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail8 = new Commission_Detail__c();
    commDetail8.Deal__c = topp1.Id;
    commDetail8.Commission_Type__c = 'Direct';
    commDetail8.OwnerId = origU.Id;
    commDetail8.Internal_Referral__c = origU2.Id;
    commDetail8.Internal_Referral_Fee__c = '20%';
    commDetail8.Approval_Status__c = 'Pending';

    insert commDetail8;

    commDetail8.Approval_Status__c = 'Approved';

    update commDetail8;

    Commission_Detail__c commDetail9 = new Commission_Detail__c();
    commDetail9.Deal__c = topp1.Id;
    commDetail9.Commission_Type__c = 'Internal';
    commDetail9.OwnerId = origU.Id;
    commDetail9.Internal_Referral__c = origU2.Id;
    commDetail9.Internal_Referral_Fee__c = '20%';
    commDetail9.Approval_Status__c = 'Pending';

    insert commDetail9;

    commDetail9.Approval_Status__c = 'Approved';

    update commDetail9;

    //-10 BPS in Spread / -25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-10 BPS in Spread / -25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail10 = new Commission_Detail__c();
    commDetail10.Deal__c = topp1.Id;
    commDetail10.Commission_Type__c = 'Direct';
    commDetail10.OwnerId = origU.Id;
    commDetail10.Internal_Referral__c = origU2.Id;
    commDetail10.Internal_Referral_Fee__c = '20%';
    commDetail10.Approval_Status__c = 'Pending';

    insert commDetail10;

    commDetail10.Approval_Status__c = 'Approved';

    update commDetail8;

    Commission_Detail__c commDetail11 = new Commission_Detail__c();
    commDetail11.Deal__c = topp1.Id;
    commDetail11.Commission_Type__c = 'Internal';
    commDetail11.OwnerId = origU.Id;
    commDetail11.Internal_Referral__c = origU2.Id;
    commDetail11.Internal_Referral_Fee__c = '20%';
    commDetail11.Approval_Status__c = 'Pending';

    insert commDetail11;

    commDetail11.Approval_Status__c = 'Approved';

    update commDetail11;

    //+10 BPS in spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+10 BPS in spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail12 = new Commission_Detail__c();
    commDetail12.Deal__c = topp1.Id;
    commDetail12.Commission_Type__c = 'Direct';
    commDetail12.OwnerId = origU.Id;
    commDetail12.Internal_Referral__c = origU2.Id;
    commDetail12.Internal_Referral_Fee__c = '20%';
    commDetail12.Approval_Status__c = 'Pending';

    insert commDetail12;

    commDetail12.Approval_Status__c = 'Approved';

    update commDetail12;

    Commission_Detail__c commDetail13 = new Commission_Detail__c();
    commDetail13.Deal__c = topp1.Id;
    commDetail13.Commission_Type__c = 'Internal';
    commDetail13.OwnerId = origU.Id;
    commDetail13.Internal_Referral__c = origU2.Id;
    commDetail13.Internal_Referral_Fee__c = '20%';
    commDetail13.Approval_Status__c = 'Pending';

    insert commDetail13;

    commDetail13.Approval_Status__c = 'Approved';

    update commDetail13;

    //-10 BPS in spread / -50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-10 BPS in spread / -50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail14 = new Commission_Detail__c();
    commDetail14.Deal__c = topp1.Id;
    commDetail14.Commission_Type__c = 'Direct';
    commDetail14.OwnerId = origU.Id;
    commDetail14.Internal_Referral__c = origU2.Id;
    commDetail14.Internal_Referral_Fee__c = '20%';
    commDetail14.Approval_Status__c = 'Pending';

    insert commDetail14;

    commDetail14.Approval_Status__c = 'Approved';

    update commDetail14;

    Commission_Detail__c commDetail15 = new Commission_Detail__c();
    commDetail15.Deal__c = topp1.Id;
    commDetail15.Commission_Type__c = 'Internal';
    commDetail15.OwnerId = origU.Id;
    commDetail15.Internal_Referral__c = origU2.Id;
    commDetail15.Internal_Referral_Fee__c = '20%';
    commDetail15.Approval_Status__c = 'Pending';

    insert commDetail15;

    commDetail15.Approval_Status__c = 'Approved';

    update commDetail15;

    //+15 BPS in Spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+15 BPS in Spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail16 = new Commission_Detail__c();
    commDetail16.Deal__c = topp1.Id;
    commDetail16.Commission_Type__c = 'Direct';
    commDetail16.OwnerId = origU.Id;
    commDetail16.Internal_Referral__c = origU2.Id;
    commDetail16.Internal_Referral_Fee__c = '20%';
    commDetail16.Approval_Status__c = 'Pending';

    insert commDetail16;

    commDetail16.Approval_Status__c = 'Approved';

    update commDetail16;

    Commission_Detail__c commDetail17 = new Commission_Detail__c();
    commDetail17.Deal__c = topp1.Id;
    commDetail17.Commission_Type__c = 'Internal';
    commDetail17.OwnerId = origU.Id;
    commDetail17.Internal_Referral__c = origU2.Id;
    commDetail17.Internal_Referral_Fee__c = '20%';
    commDetail17.Approval_Status__c = 'Pending';

    insert commDetail17;

    commDetail17.Approval_Status__c = 'Approved';

    update commDetail17;

    //-15 BPS in Spread / -50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-15 BPS in Spread / -50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail18 = new Commission_Detail__c();
    commDetail18.Deal__c = topp1.Id;
    commDetail18.Commission_Type__c = 'Direct';
    commDetail18.OwnerId = origU.Id;
    commDetail18.Internal_Referral__c = origU2.Id;
    commDetail18.Internal_Referral_Fee__c = '20%';
    commDetail18.Approval_Status__c = 'Pending';

    insert commDetail18;

    commDetail18.Approval_Status__c = 'Approved';

    update commDetail18;

    Commission_Detail__c commDetail19 = new Commission_Detail__c();
    commDetail19.Deal__c = topp1.Id;
    commDetail19.Commission_Type__c = 'Internal';
    commDetail19.OwnerId = origU.Id;
    commDetail19.Internal_Referral__c = origU2.Id;
    commDetail19.Internal_Referral_Fee__c = '20%';
    commDetail19.Approval_Status__c = 'Pending';

    insert commDetail19;

    commDetail19.Approval_Status__c = 'Approved';

    update commDetail19;

    //+20 BPS in Spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+20 BPS in Spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail20 = new Commission_Detail__c();
    commDetail20.Deal__c = topp1.Id;
    commDetail20.Commission_Type__c = 'Direct';
    commDetail20.OwnerId = origU.Id;
    commDetail20.Internal_Referral__c = origU2.Id;
    commDetail20.Internal_Referral_Fee__c = '20%';
    commDetail20.Approval_Status__c = 'Pending';

    insert commDetail20;

    commDetail20.Approval_Status__c = 'Approved';

    update commDetail20;

    Commission_Detail__c commDetail21 = new Commission_Detail__c();
    commDetail21.Deal__c = topp1.Id;
    commDetail21.Commission_Type__c = 'Internal';
    commDetail21.OwnerId = origU.Id;
    commDetail21.Internal_Referral__c = origU2.Id;
    commDetail21.Internal_Referral_Fee__c = '20%';
    commDetail21.Approval_Status__c = 'Pending';

    insert commDetail21;

    commDetail21.Approval_Status__c = 'Approved';

    update commDetail21;

    //-20 BPS in Spread / -50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-20 BPS in Spread / -50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail22 = new Commission_Detail__c();
    commDetail22.Deal__c = topp1.Id;
    commDetail22.Commission_Type__c = 'Direct';
    commDetail22.OwnerId = origU.Id;
    commDetail22.Internal_Referral__c = origU2.Id;
    commDetail22.Internal_Referral_Fee__c = '20%';
    commDetail22.Approval_Status__c = 'Pending';

    insert commDetail22;

    commDetail22.Approval_Status__c = 'Approved';

    update commDetail22;

    Commission_Detail__c commDetail23 = new Commission_Detail__c();
    commDetail23.Deal__c = topp1.Id;
    commDetail23.Commission_Type__c = 'Internal';
    commDetail23.OwnerId = origU.Id;
    commDetail23.Internal_Referral__c = origU2.Id;
    commDetail23.Internal_Referral_Fee__c = '20%';
    commDetail23.Approval_Status__c = 'Pending';

    insert commDetail23;

    commDetail23.Approval_Status__c = 'Approved';

    update commDetail23;

    Test.stopTest();
  }
  @isTest
  static void termCommissiontest12() {
    commissionAutomationSetting__c settings = new commissionAutomationSetting__c(
      SetupOwnerId = UserInfo.getOrganizationId(),
      SkipProcessBuilder__c = true
    );
    insert settings;
    CommissionDetail_TestSkip.setDoNotRunTrigger();

    //Total Borrowed on term (account) Over 5 million split ‘50%’;Final Loan Amount under 5 million

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
    topp1.CAF_YSP__c = null;
    topp1.CAF_Upfront_Fee__c = 2;
    topp1.Final_Loan_Amount__c = 7000000;
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

    Opportunity topp2 = new Opportunity();
    topp2.Name = 'test';
    topp2.CloseDate = System.today();
    topp2.StageName = 'Initial Review';
    topp2.Loan_Size__c = 20000000;
    topp2.AccountId = acc.Id;
    topp2.Contact__c = cont.Id;
    topp2.OwnerId = origU.id;
    topp2.CAF_YSP__c = null;
    topp2.CAF_Upfront_Fee__c = 2;
    topp2.Final_Loan_Amount__c = 20000000;
    topp2.Deal_Intro_Source__c = 'Hotline';
    topp2.Deal_Intro_Sub_Source__c = 'Main';
    topp2.Apex_Context__c = true;
    topp2.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
    ]
    .Id;
    insert topp2;

    topp2.CAF_Upfront_Fee__c = 2;
    update topp2;

    //Final Loan amount under 5 million

    Commission_Detail__c commDetail = new Commission_Detail__c();
    commDetail.Deal__c = topp1.Id;
    commDetail.Commission_Type__c = 'Direct';
    commDetail.OwnerId = origU.Id;
    commDetail.Internal_Referral__c = origU2.Id;
    commDetail.Internal_Referral_Fee__c = '50%';
    commDetail.Approval_Status__c = 'Pending';

    insert commDetail;

    test.startTest();

    commDetail.Approval_Status__c = 'Approved';

    update commDetail;

    Commission_Detail__c commDetail1 = new Commission_Detail__c();
    commDetail1.Deal__c = topp1.Id;
    commDetail1.Commission_Type__c = 'Internal';
    commDetail1.OwnerId = origU.Id;
    commDetail1.Internal_Referral__c = origU2.Id;
    commDetail1.Internal_Referral_Fee__c = '50%';
    commDetail1.Approval_Status__c = 'Pending';

    insert commDetail1;

    commDetail1.Approval_Status__c = 'Approved';

    update commDetail1;

    //CAF YSP Section

    topp1.CAF_YSP__c = '0 BPS in Spread';
    update topp1;

    Commission_Detail__c commDetail2 = new Commission_Detail__c();
    commDetail2.Deal__c = topp1.Id;
    commDetail2.Commission_Type__c = 'Direct';
    commDetail2.OwnerId = origU.Id;
    commDetail2.Internal_Referral__c = origU2.Id;
    commDetail2.Internal_Referral_Fee__c = '50%';
    commDetail2.Approval_Status__c = 'Pending';

    insert commDetail2;

    commDetail2.Approval_Status__c = 'Approved';

    update commDetail2;

    Commission_Detail__c commDetail3 = new Commission_Detail__c();
    commDetail3.Deal__c = topp1.Id;
    commDetail3.Commission_Type__c = 'Internal';
    commDetail3.OwnerId = origU.Id;
    commDetail3.Internal_Referral__c = origU2.Id;
    commDetail3.Internal_Referral_Fee__c = '50%';
    commDetail3.Approval_Status__c = 'Pending';

    insert commDetail3;

    commDetail3.Approval_Status__c = 'Approved';

    update commDetail3;

    //+5 BPS in Spread / +25 BPS in Commissionable Fee

    topp1.CAF_YSP__c = '+5 BPS in Spread / +25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail4 = new Commission_Detail__c();
    commDetail4.Deal__c = topp1.Id;
    commDetail4.Commission_Type__c = 'Direct';
    commDetail4.OwnerId = origU.Id;
    commDetail4.Internal_Referral__c = origU2.Id;
    commDetail4.Internal_Referral_Fee__c = '50%';
    commDetail4.Approval_Status__c = 'Pending';

    insert commDetail4;

    commDetail4.Approval_Status__c = 'Approved';

    update commDetail4;

    Commission_Detail__c commDetail5 = new Commission_Detail__c();
    commDetail5.Deal__c = topp1.Id;
    commDetail5.Commission_Type__c = 'Internal';
    commDetail5.OwnerId = origU.Id;
    commDetail5.Internal_Referral__c = origU2.Id;
    commDetail5.Internal_Referral_Fee__c = '50%';
    commDetail5.Approval_Status__c = 'Pending';

    insert commDetail5;

    commDetail5.Approval_Status__c = 'Approved';

    update commDetail5;

    //-5 BPS in Spread / -25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-5 BPS in Spread / -25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail6 = new Commission_Detail__c();
    commDetail6.Deal__c = topp1.Id;
    commDetail6.Commission_Type__c = 'Direct';
    commDetail6.OwnerId = origU.Id;
    commDetail6.Internal_Referral__c = origU2.Id;
    commDetail6.Internal_Referral_Fee__c = '50%';
    commDetail6.Approval_Status__c = 'Pending';

    insert commDetail6;

    commDetail6.Approval_Status__c = 'Approved';

    update commDetail6;

    Commission_Detail__c commDetail7 = new Commission_Detail__c();
    commDetail7.Deal__c = topp1.Id;
    commDetail7.Commission_Type__c = 'Internal';
    commDetail7.OwnerId = origU.Id;
    commDetail7.Internal_Referral__c = origU2.Id;
    commDetail7.Internal_Referral_Fee__c = '50%';
    commDetail7.Approval_Status__c = 'Pending';

    insert commDetail7;

    commDetail7.Approval_Status__c = 'Approved';

    update commDetail7;

    //+10 BPS in Spread / +25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+10 BPS in Spread / +25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail8 = new Commission_Detail__c();
    commDetail8.Deal__c = topp1.Id;
    commDetail8.Commission_Type__c = 'Direct';
    commDetail8.OwnerId = origU.Id;
    commDetail8.Internal_Referral__c = origU2.Id;
    commDetail8.Internal_Referral_Fee__c = '50%';
    commDetail8.Approval_Status__c = 'Pending';

    insert commDetail8;

    commDetail8.Approval_Status__c = 'Approved';

    update commDetail8;

    Commission_Detail__c commDetail9 = new Commission_Detail__c();
    commDetail9.Deal__c = topp1.Id;
    commDetail9.Commission_Type__c = 'Internal';
    commDetail9.OwnerId = origU.Id;
    commDetail9.Internal_Referral__c = origU2.Id;
    commDetail9.Internal_Referral_Fee__c = '50%';
    commDetail9.Approval_Status__c = 'Pending';

    insert commDetail9;

    commDetail9.Approval_Status__c = 'Approved';

    update commDetail9;

    //-10 BPS in Spread / -25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-10 BPS in Spread / -25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail10 = new Commission_Detail__c();
    commDetail10.Deal__c = topp1.Id;
    commDetail10.Commission_Type__c = 'Direct';
    commDetail10.OwnerId = origU.Id;
    commDetail10.Internal_Referral__c = origU2.Id;
    commDetail10.Internal_Referral_Fee__c = '50%';
    commDetail10.Approval_Status__c = 'Pending';

    insert commDetail10;

    commDetail10.Approval_Status__c = 'Approved';

    update commDetail8;

    Commission_Detail__c commDetail11 = new Commission_Detail__c();
    commDetail11.Deal__c = topp1.Id;
    commDetail11.Commission_Type__c = 'Internal';
    commDetail11.OwnerId = origU.Id;
    commDetail11.Internal_Referral__c = origU2.Id;
    commDetail11.Internal_Referral_Fee__c = '50%';
    commDetail11.Approval_Status__c = 'Pending';

    insert commDetail11;

    commDetail11.Approval_Status__c = 'Approved';

    update commDetail11;

    //+10 BPS in spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+10 BPS in spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail12 = new Commission_Detail__c();
    commDetail12.Deal__c = topp1.Id;
    commDetail12.Commission_Type__c = 'Direct';
    commDetail12.OwnerId = origU.Id;
    commDetail12.Internal_Referral__c = origU2.Id;
    commDetail12.Internal_Referral_Fee__c = '50%';
    commDetail12.Approval_Status__c = 'Pending';

    insert commDetail12;

    commDetail12.Approval_Status__c = 'Approved';

    update commDetail12;

    Commission_Detail__c commDetail13 = new Commission_Detail__c();
    commDetail13.Deal__c = topp1.Id;
    commDetail13.Commission_Type__c = 'Internal';
    commDetail13.OwnerId = origU.Id;
    commDetail13.Internal_Referral__c = origU2.Id;
    commDetail13.Internal_Referral_Fee__c = '50%';
    commDetail13.Approval_Status__c = 'Pending';

    insert commDetail13;

    commDetail13.Approval_Status__c = 'Approved';

    update commDetail13;

    //-10 BPS in spread / -50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-10 BPS in spread / -50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail14 = new Commission_Detail__c();
    commDetail14.Deal__c = topp1.Id;
    commDetail14.Commission_Type__c = 'Direct';
    commDetail14.OwnerId = origU.Id;
    commDetail14.Internal_Referral__c = origU2.Id;
    commDetail14.Internal_Referral_Fee__c = '50%';
    commDetail14.Approval_Status__c = 'Pending';

    insert commDetail14;

    commDetail14.Approval_Status__c = 'Approved';

    update commDetail14;

    Commission_Detail__c commDetail15 = new Commission_Detail__c();
    commDetail15.Deal__c = topp1.Id;
    commDetail15.Commission_Type__c = 'Internal';
    commDetail15.OwnerId = origU.Id;
    commDetail15.Internal_Referral__c = origU2.Id;
    commDetail15.Internal_Referral_Fee__c = '50%';
    commDetail15.Approval_Status__c = 'Pending';

    insert commDetail15;

    commDetail15.Approval_Status__c = 'Approved';

    update commDetail15;

    //+15 BPS in Spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+15 BPS in Spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail16 = new Commission_Detail__c();
    commDetail16.Deal__c = topp1.Id;
    commDetail16.Commission_Type__c = 'Direct';
    commDetail16.OwnerId = origU.Id;
    commDetail16.Internal_Referral__c = origU2.Id;
    commDetail16.Internal_Referral_Fee__c = '50%';
    commDetail16.Approval_Status__c = 'Pending';

    insert commDetail16;

    commDetail16.Approval_Status__c = 'Approved';

    update commDetail16;

    Commission_Detail__c commDetail17 = new Commission_Detail__c();
    commDetail17.Deal__c = topp1.Id;
    commDetail17.Commission_Type__c = 'Internal';
    commDetail17.OwnerId = origU.Id;
    commDetail17.Internal_Referral__c = origU2.Id;
    commDetail17.Internal_Referral_Fee__c = '50%';
    commDetail17.Approval_Status__c = 'Pending';

    insert commDetail17;

    commDetail17.Approval_Status__c = 'Approved';

    update commDetail17;

    //-15 BPS in Spread / -50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-15 BPS in Spread / -50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail18 = new Commission_Detail__c();
    commDetail18.Deal__c = topp1.Id;
    commDetail18.Commission_Type__c = 'Direct';
    commDetail18.OwnerId = origU.Id;
    commDetail18.Internal_Referral__c = origU2.Id;
    commDetail18.Internal_Referral_Fee__c = '50%';
    commDetail18.Approval_Status__c = 'Pending';

    insert commDetail18;

    commDetail18.Approval_Status__c = 'Approved';

    update commDetail18;

    Commission_Detail__c commDetail19 = new Commission_Detail__c();
    commDetail19.Deal__c = topp1.Id;
    commDetail19.Commission_Type__c = 'Internal';
    commDetail19.OwnerId = origU.Id;
    commDetail19.Internal_Referral__c = origU2.Id;
    commDetail19.Internal_Referral_Fee__c = '50%';
    commDetail19.Approval_Status__c = 'Pending';

    insert commDetail19;

    commDetail19.Approval_Status__c = 'Approved';

    update commDetail19;

    //+20 BPS in Spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+20 BPS in Spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail20 = new Commission_Detail__c();
    commDetail20.Deal__c = topp1.Id;
    commDetail20.Commission_Type__c = 'Direct';
    commDetail20.OwnerId = origU.Id;
    commDetail20.Internal_Referral__c = origU2.Id;
    commDetail20.Internal_Referral_Fee__c = '50%';
    commDetail20.Approval_Status__c = 'Pending';

    insert commDetail20;

    commDetail20.Approval_Status__c = 'Approved';

    update commDetail20;

    Commission_Detail__c commDetail21 = new Commission_Detail__c();
    commDetail21.Deal__c = topp1.Id;
    commDetail21.Commission_Type__c = 'Internal';
    commDetail21.OwnerId = origU.Id;
    commDetail21.Internal_Referral__c = origU2.Id;
    commDetail21.Internal_Referral_Fee__c = '50%';
    commDetail21.Approval_Status__c = 'Pending';

    insert commDetail21;

    commDetail21.Approval_Status__c = 'Approved';

    update commDetail21;

    //-20 BPS in Spread / -50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-20 BPS in Spread / -50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail22 = new Commission_Detail__c();
    commDetail22.Deal__c = topp1.Id;
    commDetail22.Commission_Type__c = 'Direct';
    commDetail22.OwnerId = origU.Id;
    commDetail22.Internal_Referral__c = origU2.Id;
    commDetail22.Internal_Referral_Fee__c = '50%';
    commDetail22.Approval_Status__c = 'Pending';

    insert commDetail22;

    commDetail22.Approval_Status__c = 'Approved';

    update commDetail22;

    Commission_Detail__c commDetail23 = new Commission_Detail__c();
    commDetail23.Deal__c = topp1.Id;
    commDetail23.Commission_Type__c = 'Internal';
    commDetail23.OwnerId = origU.Id;
    commDetail23.Internal_Referral__c = origU2.Id;
    commDetail23.Internal_Referral_Fee__c = '50%';
    commDetail23.Approval_Status__c = 'Pending';

    insert commDetail23;

    commDetail23.Approval_Status__c = 'Approved';

    update commDetail23;

    Test.stopTest();
  }

  @isTest
  static void termCommissiontest13() {
    commissionAutomationSetting__c settings = new commissionAutomationSetting__c(
      SetupOwnerId = UserInfo.getOrganizationId(),
      SkipProcessBuilder__c = true
    );
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
    topp1.CAF_YSP__c = null;
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

  @isTest
  static void termCommissiontestExt1() {
    commissionAutomationSetting__c settings = new commissionAutomationSetting__c(
      SetupOwnerId = UserInfo.getOrganizationId(),
      SkipProcessBuilder__c = true
    );
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
    topp1.CAF_YSP__c = null;
    topp1.CAF_Upfront_Fee__c = 2;
    topp1.Final_Loan_Amount__c = 500000;
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

    Commission_Detail__c commDetailUpdate = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail.Id
    ];

    commDetailUpdate.Approval_Status__c = 'Approved';

    update commDetailUpdate;

    Commission_Detail__c commDetail1 = new Commission_Detail__c();
    commDetail1.Deal__c = topp1.Id;
    commDetail1.Commission_Type__c = 'Internal';
    commDetail1.OwnerId = origU.Id;
    commDetail1.Approval_Status__c = 'Pending';

    insert commDetail1;

    Commission_Detail__c commDetail1Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail1.Id
    ];

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

    Commission_Detail__c commDetail2Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail2.Id
    ];

    commDetail2Update.Approval_Status__c = 'Approved';

    update commDetail2Update;

    Commission_Detail__c commDetail3 = new Commission_Detail__c();
    commDetail3.Deal__c = topp1.Id;
    commDetail3.Commission_Type__c = 'Internal';
    commDetail3.OwnerId = origU.Id;
    commDetail3.Approval_Status__c = 'Pending';

    insert commDetail3;

    Commission_Detail__c commDetail3Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail3.Id
    ];

    commDetail3Update.Approval_Status__c = 'Approved';

    update commDetail3Update;

    //+5 BPS in Spread / +25 BPS in Commissionable Fee

    topp1.CAF_YSP__c = '+5 BPS in Spread / +25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail4 = new Commission_Detail__c();
    commDetail4.Deal__c = topp1.Id;
    commDetail4.Commission_Type__c = 'Direct';
    commDetail4.OwnerId = origU.Id;
    commDetail4.Approval_Status__c = 'Pending';

    insert commDetail4;

    Commission_Detail__c commDetail4Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail4.Id
    ];

    commDetail4Update.Approval_Status__c = 'Approved';

    update commDetail4Update;

    Commission_Detail__c commDetail5 = new Commission_Detail__c();
    commDetail5.Deal__c = topp1.Id;
    commDetail5.Commission_Type__c = 'Internal';
    commDetail5.OwnerId = origU.Id;
    commDetail5.Approval_Status__c = 'Pending';

    insert commDetail5;

    Commission_Detail__c commDetail5Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail5.Id
    ];

    commDetail5Update.Approval_Status__c = 'Approved';

    update commDetail5Update;

    //-5 BPS in Spread / -25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-5 BPS in Spread / -25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail6 = new Commission_Detail__c();
    commDetail6.Deal__c = topp1.Id;
    commDetail6.Commission_Type__c = 'Direct';
    commDetail6.OwnerId = origU.Id;
    commDetail6.Approval_Status__c = 'Pending';

    insert commDetail6;

    Commission_Detail__c commDetail6Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail6.Id
    ];

    commDetail6Update.Approval_Status__c = 'Approved';

    update commDetail6Update;

    Commission_Detail__c commDetail7 = new Commission_Detail__c();
    commDetail7.Deal__c = topp1.Id;
    commDetail7.Commission_Type__c = 'Internal';
    commDetail7.OwnerId = origU.Id;
    commDetail7.Approval_Status__c = 'Pending';

    insert commDetail7;

    Commission_Detail__c commDetail7Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail7.Id
    ];

    commDetail7Update.Approval_Status__c = 'Approved';

    update commDetail7Update;

    //+10 BPS in Spread / +25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+10 BPS in Spread / +25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail8 = new Commission_Detail__c();
    commDetail8.Deal__c = topp1.Id;
    commDetail8.Commission_Type__c = 'Direct';
    commDetail8.OwnerId = origU.Id;
    commDetail8.Approval_Status__c = 'Pending';

    insert commDetail8;

    Commission_Detail__c commDetail8Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail8.Id
    ];

    commDetail8Update.Approval_Status__c = 'Approved';

    update commDetail8Update;

    Commission_Detail__c commDetail9 = new Commission_Detail__c();
    commDetail9.Deal__c = topp1.Id;
    commDetail9.Commission_Type__c = 'Internal';
    commDetail9.OwnerId = origU.Id;
    commDetail9.Approval_Status__c = 'Pending';

    insert commDetail9;

    Commission_Detail__c commDetail9Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail9.Id
    ];

    commDetail9Update.Approval_Status__c = 'Approved';

    update commDetail9Update;

    //-10 BPS in Spread / -25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-10 BPS in Spread / -25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail10 = new Commission_Detail__c();
    commDetail10.Deal__c = topp1.Id;
    commDetail10.Commission_Type__c = 'Direct';
    commDetail10.OwnerId = origU.Id;
    commDetail10.Approval_Status__c = 'Pending';

    insert commDetail10;

    Commission_Detail__c commDetail10Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail10.Id
    ];

    commDetail10Update.Approval_Status__c = 'Approved';

    update commDetail10Update;

    Commission_Detail__c commDetail11 = new Commission_Detail__c();
    commDetail11.Deal__c = topp1.Id;
    commDetail11.Commission_Type__c = 'Internal';
    commDetail11.OwnerId = origU.Id;
    commDetail11.Approval_Status__c = 'Pending';

    insert commDetail11;

    Commission_Detail__c commDetail11Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail11.Id
    ];

    commDetail11Update.Approval_Status__c = 'Approved';

    update commDetail11Update;

    //+10 BPS in spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+10 BPS in spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail12 = new Commission_Detail__c();
    commDetail12.Deal__c = topp1.Id;
    commDetail12.Commission_Type__c = 'Direct';
    commDetail12.OwnerId = origU.Id;
    commDetail12.Approval_Status__c = 'Pending';

    insert commDetail12;

    Commission_Detail__c commDetail12Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail12.Id
    ];

    commDetail12Update.Approval_Status__c = 'Approved';

    update commDetail12Update;

    Commission_Detail__c commDetail13 = new Commission_Detail__c();
    commDetail13.Deal__c = topp1.Id;
    commDetail13.Commission_Type__c = 'Internal';
    commDetail13.OwnerId = origU.Id;
    commDetail13.Approval_Status__c = 'Pending';

    insert commDetail13;

    Commission_Detail__c commDetail13Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail13.Id
    ];

    commDetail13Update.Approval_Status__c = 'Approved';

    update commDetail13Update;

    //-10 BPS in spread / -50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-10 BPS in spread / -50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail14 = new Commission_Detail__c();
    commDetail14.Deal__c = topp1.Id;
    commDetail14.Commission_Type__c = 'Direct';
    commDetail14.OwnerId = origU.Id;
    commDetail14.Approval_Status__c = 'Pending';

    insert commDetail14;

    Commission_Detail__c commDetail14Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail14.Id
    ];

    commDetail14Update.Approval_Status__c = 'Approved';

    update commDetail14Update;

    Commission_Detail__c commDetail15 = new Commission_Detail__c();
    commDetail15.Deal__c = topp1.Id;
    commDetail15.Commission_Type__c = 'Internal';
    commDetail15.OwnerId = origU.Id;
    commDetail15.Approval_Status__c = 'Pending';

    insert commDetail15;

    Commission_Detail__c commDetail15Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail15.Id
    ];

    commDetail15Update.Approval_Status__c = 'Approved';

    update commDetail15Update;

    //+15 BPS in Spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+15 BPS in Spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail16 = new Commission_Detail__c();
    commDetail16.Deal__c = topp1.Id;
    commDetail16.Commission_Type__c = 'Direct';
    commDetail16.OwnerId = origU.Id;
    commDetail16.Approval_Status__c = 'Pending';

    insert commDetail16;

    Commission_Detail__c commDetail16Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail16.Id
    ];

    commDetail16Update.Approval_Status__c = 'Approved';

    update commDetail16Update;

    Commission_Detail__c commDetail17 = new Commission_Detail__c();
    commDetail17.Deal__c = topp1.Id;
    commDetail17.Commission_Type__c = 'Internal';
    commDetail17.OwnerId = origU.Id;
    commDetail17.Approval_Status__c = 'Pending';

    insert commDetail17;

    Commission_Detail__c commDetail17Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail17.Id
    ];

    commDetail17Update.Approval_Status__c = 'Approved';

    update commDetail17Update;

    //-15 BPS in Spread / -50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-15 BPS in Spread / -50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail18 = new Commission_Detail__c();
    commDetail18.Deal__c = topp1.Id;
    commDetail18.Commission_Type__c = 'Direct';
    commDetail18.OwnerId = origU.Id;
    commDetail18.Approval_Status__c = 'Pending';

    insert commDetail18;

    Commission_Detail__c commDetail18Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail18.Id
    ];

    commDetail18Update.Approval_Status__c = 'Approved';

    update commDetail18Update;

    Commission_Detail__c commDetail19 = new Commission_Detail__c();
    commDetail19.Deal__c = topp1.Id;
    commDetail19.Commission_Type__c = 'Internal';
    commDetail19.OwnerId = origU.Id;
    commDetail19.Approval_Status__c = 'Pending';

    insert commDetail19;

    Commission_Detail__c commDetail19Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail19.Id
    ];

    commDetail19Update.Approval_Status__c = 'Approved';

    update commDetail19Update;

    /*        //+20 BPS in Spread / +50 BPS in Commissionable Fee
topp1.CAF_YSP__c = '+20 BPS in Spread / +50 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail20 = new Commission_Detail__c();
    commDetail20.Deal__c = topp1.Id;
    commDetail20.Commission_Type__c = 'Direct';
    commDetail20.OwnerId = origU.Id;
    commDetail20.Approval_Status__c = 'Pending';
     
    insert commDetail20;
        
         Commission_Detail__c commDetail20Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail20.Id limit 1];  
              
    commDetail20Update.Approval_Status__c = 'Approved';
        
        update commDetail20Update; */

    /* 
        
    Commission_Detail__c commDetail21 = new Commission_Detail__c();
    commDetail21.Deal__c = topp1.Id;
    commDetail21.Commission_Type__c = 'Internal';
    commDetail21.OwnerId = origU.Id;
    commDetail21.Approval_Status__c = 'Pending';
     
    insert commDetail21;
        
            
         Commission_Detail__c commDetail21Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail21.Id];  
              
    commDetail21Update.Approval_Status__c = 'Approved';
        
        update commDetail21Update;

      

        
        //-20 BPS in Spread / -50 BPS in Commissionable Fee
        topp1.CAF_YSP__c = '-20 BPS in Spread / -50 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail22 = new Commission_Detail__c();
    commDetail22.Deal__c = topp1.Id;
    commDetail22.Commission_Type__c = 'Direct';
    commDetail22.OwnerId = origU.Id;
    commDetail22.Approval_Status__c = 'Pending';
     
    insert commDetail22;
        
         Commission_Detail__c commDetail22Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail22.Id];  
              
    commDetail22Update.Approval_Status__c = 'Approved';
        
        update commDetail22Update;

        

        

    Commission_Detail__c commDetail23 = new Commission_Detail__c();
    commDetail23.Deal__c = topp1.Id;
    commDetail23.Commission_Type__c = 'Internal';
    commDetail23.OwnerId = origU.Id;
    commDetail23.Approval_Status__c = 'Pending';
     
    insert commDetail23;
        
          Commission_Detail__c commDetail23Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail23.Id];  
              
    commDetail23Update.Approval_Status__c = 'Approved';
        
        update commDetail23Update; */

    Test.stopTest();
  }
  @isTest
  static void termCommissiontestExt2() {
    commissionAutomationSetting__c settings = new commissionAutomationSetting__c(
      SetupOwnerId = UserInfo.getOrganizationId(),
      SkipProcessBuilder__c = true
    );
    insert settings;
    CommissionDetail_TestSkip.setDoNotRunTrigger();
    //Total Borrowed on term (account) under 5 million split ‘20%’;Final Loan Amount under 5 million

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
    topp1.CAF_YSP__c = null;
    topp1.CAF_Upfront_Fee__c = 2;
    topp1.Final_Loan_Amount__c = 500000;
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
    commDetail.Internal_Referral__c = origU2.Id;
    commDetail.Internal_Referral_Fee__c = '20%';
    commDetail.Approval_Status__c = 'Pending';

    insert commDetail;

    test.startTest();

    Commission_Detail__c commDetailUpdate = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail.Id
    ];

    commDetailUpdate.Approval_Status__c = 'Approved';

    update commDetailUpdate;

    Commission_Detail__c commDetail1 = new Commission_Detail__c();
    commDetail1.Deal__c = topp1.Id;
    commDetail1.Commission_Type__c = 'Internal';
    commDetail1.OwnerId = origU.Id;
    commDetail1.Internal_Referral__c = origU2.Id;
    commDetail1.Internal_Referral_Fee__c = '20%';
    commDetail1.Approval_Status__c = 'Pending';

    insert commDetail1;

    Commission_Detail__c commDetail1Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail1.Id
    ];

    commDetail1Update.Approval_Status__c = 'Approved';

    update commDetail1Update;

    //CAF YSP Section

    topp1.CAF_YSP__c = '0 BPS in Spread';
    update topp1;

    Commission_Detail__c commDetail2 = new Commission_Detail__c();
    commDetail2.Deal__c = topp1.Id;
    commDetail2.Commission_Type__c = 'Direct';
    commDetail2.OwnerId = origU.Id;
    commDetail2.Internal_Referral__c = origU2.Id;
    commDetail2.Internal_Referral_Fee__c = '20%';
    commDetail2.Approval_Status__c = 'Pending';

    insert commDetail2;

    Commission_Detail__c commDetail2Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail2.Id
    ];

    commDetail2Update.Approval_Status__c = 'Approved';

    update commDetail2Update;

    Commission_Detail__c commDetail3 = new Commission_Detail__c();
    commDetail3.Deal__c = topp1.Id;
    commDetail3.Commission_Type__c = 'Internal';
    commDetail3.OwnerId = origU.Id;
    commDetail3.Internal_Referral__c = origU2.Id;
    commDetail3.Internal_Referral_Fee__c = '20%';
    commDetail3.Approval_Status__c = 'Pending';

    insert commDetail3;

    Commission_Detail__c commDetail3Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail3.Id
    ];

    commDetail3Update.Approval_Status__c = 'Approved';

    update commDetail3Update;

    //+5 BPS in Spread / +25 BPS in Commissionable Fee

    topp1.CAF_YSP__c = '+5 BPS in Spread / +25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail4 = new Commission_Detail__c();
    commDetail4.Deal__c = topp1.Id;
    commDetail4.Commission_Type__c = 'Direct';
    commDetail4.OwnerId = origU.Id;
    commDetail4.Internal_Referral__c = origU2.Id;
    commDetail4.Internal_Referral_Fee__c = '20%';
    commDetail4.Approval_Status__c = 'Pending';

    insert commDetail4;

    Commission_Detail__c commDetail4Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail4.Id
    ];

    commDetail4Update.Approval_Status__c = 'Approved';

    update commDetail4Update;

    Commission_Detail__c commDetail5 = new Commission_Detail__c();
    commDetail5.Deal__c = topp1.Id;
    commDetail5.Commission_Type__c = 'Internal';
    commDetail5.OwnerId = origU.Id;
    commDetail5.Internal_Referral__c = origU2.Id;
    commDetail5.Internal_Referral_Fee__c = '20%';
    commDetail5.Approval_Status__c = 'Pending';

    insert commDetail5;

    Commission_Detail__c commDetail5Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail5.Id
    ];

    commDetail5Update.Approval_Status__c = 'Approved';

    update commDetail5Update;

    //-5 BPS in Spread / -25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-5 BPS in Spread / -25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail6 = new Commission_Detail__c();
    commDetail6.Deal__c = topp1.Id;
    commDetail6.Commission_Type__c = 'Direct';
    commDetail6.OwnerId = origU.Id;
    commDetail6.Internal_Referral__c = origU2.Id;
    commDetail6.Internal_Referral_Fee__c = '20%';
    commDetail6.Approval_Status__c = 'Pending';

    insert commDetail6;

    Commission_Detail__c commDetail6Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail6.Id
    ];

    commDetail6Update.Approval_Status__c = 'Approved';

    update commDetail6Update;

    Commission_Detail__c commDetail7 = new Commission_Detail__c();
    commDetail7.Deal__c = topp1.Id;
    commDetail7.Commission_Type__c = 'Internal';
    commDetail7.OwnerId = origU.Id;
    commDetail7.Internal_Referral__c = origU2.Id;
    commDetail7.Internal_Referral_Fee__c = '20%';
    commDetail7.Approval_Status__c = 'Pending';

    insert commDetail7;

    Commission_Detail__c commDetail7Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail7.Id
    ];

    commDetail7Update.Approval_Status__c = 'Approved';

    update commDetail7Update;

    //+10 BPS in Spread / +25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+10 BPS in Spread / +25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail8 = new Commission_Detail__c();
    commDetail8.Deal__c = topp1.Id;
    commDetail8.Commission_Type__c = 'Direct';
    commDetail8.OwnerId = origU.Id;
    commDetail8.Internal_Referral__c = origU2.Id;
    commDetail8.Internal_Referral_Fee__c = '20%';
    commDetail8.Approval_Status__c = 'Pending';

    insert commDetail8;

    Commission_Detail__c commDetail8Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail8.Id
    ];

    commDetail8Update.Approval_Status__c = 'Approved';

    update commDetail8Update;

    Commission_Detail__c commDetail9 = new Commission_Detail__c();
    commDetail9.Deal__c = topp1.Id;
    commDetail9.Commission_Type__c = 'Internal';
    commDetail9.OwnerId = origU.Id;
    commDetail9.Internal_Referral__c = origU2.Id;
    commDetail9.Internal_Referral_Fee__c = '20%';
    commDetail9.Approval_Status__c = 'Pending';

    insert commDetail9;

    Commission_Detail__c commDetail9Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail9.Id
    ];

    commDetail9Update.Approval_Status__c = 'Approved';

    update commDetail9Update;

    //-10 BPS in Spread / -25 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-10 BPS in Spread / -25 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail10 = new Commission_Detail__c();
    commDetail10.Deal__c = topp1.Id;
    commDetail10.Commission_Type__c = 'Direct';
    commDetail10.OwnerId = origU.Id;
    commDetail10.Internal_Referral__c = origU2.Id;
    commDetail10.Internal_Referral_Fee__c = '20%';
    commDetail10.Approval_Status__c = 'Pending';

    insert commDetail10;

    Commission_Detail__c commDetail10Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail10.Id
    ];

    commDetail10Update.Approval_Status__c = 'Approved';

    update commDetail10Update;

    Commission_Detail__c commDetail11 = new Commission_Detail__c();
    commDetail11.Deal__c = topp1.Id;
    commDetail11.Commission_Type__c = 'Internal';
    commDetail11.OwnerId = origU.Id;
    commDetail11.Internal_Referral__c = origU2.Id;
    commDetail11.Internal_Referral_Fee__c = '20%';
    commDetail11.Approval_Status__c = 'Pending';

    insert commDetail11;

    Commission_Detail__c commDetail11Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail11.Id
    ];

    commDetail11Update.Approval_Status__c = 'Approved';

    update commDetail11Update;

    //+10 BPS in spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+10 BPS in spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail12 = new Commission_Detail__c();
    commDetail12.Deal__c = topp1.Id;
    commDetail12.Commission_Type__c = 'Direct';
    commDetail12.OwnerId = origU.Id;
    commDetail12.Internal_Referral__c = origU2.Id;
    commDetail12.Internal_Referral_Fee__c = '20%';
    commDetail12.Approval_Status__c = 'Pending';

    insert commDetail12;

    Commission_Detail__c commDetail12Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail12.Id
    ];

    commDetail12Update.Approval_Status__c = 'Approved';

    update commDetail12Update;

    Commission_Detail__c commDetail13 = new Commission_Detail__c();
    commDetail13.Deal__c = topp1.Id;
    commDetail13.Commission_Type__c = 'Internal';
    commDetail13.OwnerId = origU.Id;
    commDetail13.Internal_Referral__c = origU2.Id;
    commDetail13.Internal_Referral_Fee__c = '20%';
    commDetail13.Approval_Status__c = 'Pending';

    insert commDetail13;

    Commission_Detail__c commDetail13Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail13.Id
    ];

    commDetail13Update.Approval_Status__c = 'Approved';

    update commDetail13Update;

    //-10 BPS in spread / -50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-10 BPS in spread / -50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail14 = new Commission_Detail__c();
    commDetail14.Deal__c = topp1.Id;
    commDetail14.Commission_Type__c = 'Direct';
    commDetail14.OwnerId = origU.Id;
    commDetail14.Internal_Referral__c = origU2.Id;
    commDetail14.Internal_Referral_Fee__c = '20%';
    commDetail14.Approval_Status__c = 'Pending';

    insert commDetail14;

    Commission_Detail__c commDetail14Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail14.Id
    ];

    commDetail14Update.Approval_Status__c = 'Approved';

    update commDetail14Update;

    Commission_Detail__c commDetail15 = new Commission_Detail__c();
    commDetail15.Deal__c = topp1.Id;
    commDetail15.Commission_Type__c = 'Internal';
    commDetail15.OwnerId = origU.Id;
    commDetail15.Internal_Referral__c = origU2.Id;
    commDetail15.Internal_Referral_Fee__c = '20%';
    commDetail15.Approval_Status__c = 'Pending';

    insert commDetail15;

    Commission_Detail__c commDetail15Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail15.Id
    ];

    commDetail15Update.Approval_Status__c = 'Approved';

    update commDetail15Update;

    //+15 BPS in Spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+15 BPS in Spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail16 = new Commission_Detail__c();
    commDetail16.Deal__c = topp1.Id;
    commDetail16.Commission_Type__c = 'Direct';
    commDetail16.OwnerId = origU.Id;
    commDetail16.Internal_Referral__c = origU2.Id;
    commDetail16.Internal_Referral_Fee__c = '20%';
    commDetail16.Approval_Status__c = 'Pending';

    insert commDetail16;

    Commission_Detail__c commDetail16Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail16.Id
    ];

    commDetail16Update.Approval_Status__c = 'Approved';

    update commDetail16Update;

    Commission_Detail__c commDetail17 = new Commission_Detail__c();
    commDetail17.Deal__c = topp1.Id;
    commDetail17.Commission_Type__c = 'Internal';
    commDetail17.OwnerId = origU.Id;
    commDetail17.Internal_Referral__c = origU2.Id;
    commDetail17.Internal_Referral_Fee__c = '20%';
    commDetail17.Approval_Status__c = 'Pending';

    insert commDetail17;

    Commission_Detail__c commDetail17Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail17.Id
    ];

    commDetail17Update.Approval_Status__c = 'Approved';

    update commDetail17Update;

    //-15 BPS in Spread / -50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '-15 BPS in Spread / -50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail18 = new Commission_Detail__c();
    commDetail18.Deal__c = topp1.Id;
    commDetail18.Commission_Type__c = 'Direct';
    commDetail18.OwnerId = origU.Id;
    commDetail18.Internal_Referral__c = origU2.Id;
    commDetail18.Internal_Referral_Fee__c = '20%';
    commDetail18.Approval_Status__c = 'Pending';

    insert commDetail18;

    Commission_Detail__c commDetail18Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail18.Id
    ];

    commDetail18Update.Approval_Status__c = 'Approved';

    update commDetail18Update;

    Commission_Detail__c commDetail19 = new Commission_Detail__c();
    commDetail19.Deal__c = topp1.Id;
    commDetail19.Commission_Type__c = 'Internal';
    commDetail19.OwnerId = origU.Id;
    commDetail19.Internal_Referral__c = origU2.Id;
    commDetail19.Internal_Referral_Fee__c = '20%';
    commDetail19.Approval_Status__c = 'Pending';

    insert commDetail19;

    Commission_Detail__c commDetail19Update = [
      SELECT Approval_Status__c
      FROM Commission_Detail__c
      WHERE id = :commDetail19.Id
    ];

    commDetail19Update.Approval_Status__c = 'Approved';

    update commDetail19Update;

    //+20 BPS in Spread / +50 BPS in Commissionable Fee
    topp1.CAF_YSP__c = '+20 BPS in Spread / +50 BPS in Commissionable Fee';
    update topp1;

    Commission_Detail__c commDetail20 = new Commission_Detail__c();
    commDetail20.Deal__c = topp1.Id;
    commDetail20.Commission_Type__c = 'Direct';
    commDetail20.OwnerId = origU.Id;
    commDetail20.Internal_Referral__c = origU2.Id;
    commDetail20.Internal_Referral_Fee__c = '20%';
    commDetail20.Approval_Status__c = 'Pending';

    insert commDetail20;

    /*          Commission_Detail__c commDetail20Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail20.Id];  
              
    commDetail20Update.Approval_Status__c = 'Approved';
        
        update commDetail20Update;

        
    Commission_Detail__c commDetail21 = new Commission_Detail__c();
    commDetail21.Deal__c = topp1.Id;
    commDetail21.Commission_Type__c = 'Internal';
    commDetail21.OwnerId = origU.Id;
    commDetail21.Internal_Referral__c = origU2.Id;
    commDetail21.Internal_Referral_Fee__c = '20%';
    commDetail21.Approval_Status__c = 'Pending';
     
    insert commDetail21;
        
            
         Commission_Detail__c commDetail21Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail21.Id];  
              
    commDetail21Update.Approval_Status__c = 'Approved';
        
        update commDetail21Update;

        
        
        //-20 BPS in Spread / -50 BPS in Commissionable Fee
        topp1.CAF_YSP__c = '-20 BPS in Spread / -50 BPS in Commissionable Fee';
        update topp1;

    Commission_Detail__c commDetail22 = new Commission_Detail__c();
    commDetail22.Deal__c = topp1.Id;
    commDetail22.Commission_Type__c = 'Direct';
    commDetail22.OwnerId = origU.Id;
    commDetail22.Internal_Referral__c = origU2.Id;
    commDetail22.Internal_Referral_Fee__c = '20%';
    commDetail22.Approval_Status__c = 'Pending';
     
    insert commDetail22;
        
         Commission_Detail__c commDetail22Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail22.Id];  
              
    commDetail22Update.Approval_Status__c = 'Approved';
        
        update commDetail22Update;

        
    Commission_Detail__c commDetail23 = new Commission_Detail__c();
    commDetail23.Deal__c = topp1.Id;
    commDetail23.Commission_Type__c = 'Internal';
    commDetail23.OwnerId = origU.Id;
    commDetail23.Internal_Referral__c = origU2.Id;
    commDetail23.Internal_Referral_Fee__c = '20%';
    commDetail23.Approval_Status__c = 'Pending';
     
    insert commDetail23;
        
            
           Commission_Detail__c commDetail23Update = [SELECT Approval_Status__c from Commission_Detail__c WHERE id=:commDetail23.Id];  
              
    commDetail23Update.Approval_Status__c = 'Approved';
        
        update commDetail23Update; */

    Test.stopTest();
  }
}