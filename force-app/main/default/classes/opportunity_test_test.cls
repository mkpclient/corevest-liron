@isTest
public with sharing class opportunity_test_test {
 @TestSetup
  static void dataSetup() {
    Account acc = test_Helper.createAccount();

    acc.Alternate_Phone__c = '7777777777';
    update acc;
    Contact cont = test_Helper.createContact(acc);

    cont.MobilePhone = '2222222222';
    cont.Phone = '9999999999';

    Opportunity topp1 = new Opportunity();
    topp1.Name = 'TERM TEST 123';
    topp1.CloseDate = System.today();
    topp1.StageName = 'Initial Review';
    topp1.Loan_Size__c = 2000000;
    topp1.AccountId = acc.Id;
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
    insert topp1;
  }    
    
static testMethod void opportunity_TermTest11() {
    List<User> newUsers = new List<User>();
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
    //insert p;
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
    //insert p;
    insert origU2;

    User origU3 = new User(
      Alias = 'orig',
      Email = 'standarduser@cvest.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = [SELECT Id FROM Profile WHERE Name = 'Relationship Manager']
      .Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'originator3@teada.com'
    );
    //insert p;
    insert origU3;

    User origU4 = new User(
      Alias = 'orig',
      Email = 'standarduser@cvest.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = [SELECT Id FROM Profile WHERE Name = 'Relationship Manager']
      .Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'originator4@teada.com'
    );
    //insert p;
    insert origU4;

    User analystU = new User(
      Alias = 'analyst',
      Email = 'standarduser@cvest.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales Analyst']
      .Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'analyst@teada.com'
    );
    //insert p;
    insert analystU;

    User analystU2 = new User(
      Alias = 'analyst',
      Email = 'standarduser@cvest.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales Analyst']
      .Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'analyst2@teada.com'
    );
    //insert p;
    insert analystU2;

    User analystU3 = new User(
      Alias = 'analyst',
      Email = 'standarduser@cvest.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales Analyst']
      .Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'analyst3@teada.com'
    );
    //insert p;
    insert analystU3;

    User analystU4 = new User(
      Alias = 'analyst',
      Email = 'standarduser@cvest.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales Analyst']
      .Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'analyst4@teada.com'
    );
    //insert p;
    insert analystU4;

    User uwU = new User(
      Alias = 'underw',
      Email = 'standarduser@cvest.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = [SELECT Id FROM Profile WHERE Name = 'Term Operations']
      .Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'underwriter@teada.com'
    );
    //insert p;
    insert uwU;

    User uwU2 = new User(
      Alias = 'underw',
      Email = 'standarduser@cvest.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = [SELECT Id FROM Profile WHERE Name = 'Term Operations']
      .Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'underwriter2@teada.com'
    );
    //insert p;
    insert uwU2;

    User lcU = new User(
      Alias = 'loanco',
      Email = 'standarduser@cvest.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = [SELECT Id FROM Profile WHERE Name = 'Term Operations']
      .Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'coord1@teada.com'
    );
    //insert p;
    insert lcU;

    User lcU2 = new User(
      Alias = 'loanco',
      Email = 'standarduser@cvest.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = [SELECT Id FROM Profile WHERE Name = 'Term Operations']
      .Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'coord2@teada.com'
    );
    //insert p;
    insert lcU2;

    User closerU = new User(
      Alias = 'clos',
      Email = 'standarduser@cvest.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = [SELECT Id FROM Profile WHERE Name = 'Term Operations']
      .Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'closer1@teada.com'
    );
    //insert p;
    insert closerU;

    User closerU2 = new User(
      Alias = 'clos',
      Email = 'standarduser@cvest.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = [SELECT Id FROM Profile WHERE Name = 'Term Operations']
      .Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'closer2@teada.com'
    );
    //insert p;
    insert closerU2;

    Opportunity topp1 = [
      SELECT Id
      FROM Opportunity
      WHERE Name = 'TERM TEST 123'
      LIMIT 1
    ];
    List<Loan_Version__c> loanVersionList = new List<Loan_Version__c>();
    Loan_Version__c loanVersion = new Loan_Version__c();
    loanVersion.Deal__c = topp1.id;
    loanVersion.Finalized__c = True;
    loanVersion.RecordTypeId = [SELECT Id FROM RecordType WHERE sobjecttype = 'Loan_Version__c' AND DeveloperName = 'Loan_Agreement'].Id;      
    loanVersionList.add(loanVersion);
      
    Loan_Version__c loanVersion1 = new Loan_Version__c();    
    loanVersion1.Deal__c = topp1.id;
    loanVersion1.Finalized__c = True;    
    loanVersion1.RecordTypeId = [SELECT Id FROM RecordType WHERE sobjecttype = 'Loan_Version__c' AND DeveloperName = 'Schedule_of_Lender_Cost'].Id;      
    loanVersionList.add(loanVersion1);      

	Insert loanVersionList;
 
    Test.startTest();
    Securitization__c sec = test_Helper.createSecuritization();

    topp1.Term_Sheet_Issued__c = System.today();
    topp1.Trigger_Field__c = 'Originations Model;Model Name Test';
    topp1.Pres_Deal_Id__c = '123';
    //topp1.StageName = 'Term Sheet Issued';
    topp1.Loan_Effective_Date__c = System.today();
    topp1.Deal_Intro_Source__c = 'Email';
    topp1.Bridge_Borrower__c = 'No';
    topp1.Are_Assets_Coming_Off_Bridge_Line__c = 'No';
    topp1.Term_Sheet_Signed__c = System.today();
    topp1.OwnerId = origU.Id;
    topp1.CAF_Analyst__c = analystU.Id;
    topp1.Second_Production_Analyst__c = analystU3.Id;
    topp1.Co_Originator__c = origU3.Id;
    topp1.IO_Term__c = '0 months';
    topp1.Deposit_Amount__c = 0;
    topp1.Deposit_Collected__c = System.today();
    topp1.Deposit_Fed_Reference__c = 'adfaf';
    topp1.Broker_Fees_and_or_YSP__c = 'adffda';
    topp1.Property_Management__c = 'Third Party';
    topp1.StageName = 'Underwriting';
    topp1.Current_Loan_Amount__c = 2000000;
    topp1.Underwriter__c = uwU.Id;
    topp1.Loan_Coordinator__c = lcU.Id;
    topp1.Closer__c = closerU.Id;
    topp1.Kickoff_Date__c = System.today();
    // topp1.Commission_Type__c = 'Direct';
    topp1.StageName = 'UW Hold';
    topp1.StageName = 'Underwriting';
    topp1.IO_Term__c = '120 months';
    topp1.Final_Loan_Amount__c = 1000000;
    topp1.CAF_Analyst__c = analystU2.Id;
    topp1.Second_Production_Analyst__c = analystU4.Id;
    topp1.Underwriter__c = uwU2.Id;
    topp1.Loan_Coordinator__c = lcU2.Id;
    topp1.Closer__c = closerU2.Id;
    topp1.Co_Originator__c = origU4.Id;
    topp1.Final_Spread__c = 2;
    topp1.Final_Swap__c = 2;
    topp1.Trigger_Field__c = 'Term Underwriting Model;Model Name Test';

    topp1.Anticipated_Closing_Date__c = System.today() + 30;
    topp1.Final_Loan_Amount__c = null;
    topp1.OwnerId = origU2.Id;
    topp1.StageName = 'Underwriting';
    topp1.StageName = 'Approved by Committee';
    topp1.Final_Loan_Amount__c = 2000000;
    topp1.StageName = 'Closed Won';
    topp1.Servicer_Name__c = 'Midland';
    topp1.Servicer_Commitment_Id__c = '12345';
    topp1.First_Payment_Date__c = System.today() + 30;
    topp1.Last_Payment_Date__c = System.today() + 30;
    topp1.Delinquent_30_Days__c = 1;
    topp1.Delinquent_60_Days__c = 0;
    topp1.Delinquent_90_Days__c = 0;
    topp1.Delinquent_120_Days__c = 3;
    topp1.Current_UPB__c = 300000;
    topp1.Onboarded_at_Servicer__c = System.today() + 30;
    topp1.Onboarding_File_Sent_to_Servicer__c = System.today() + 30;
    topp1.P_I__c = 2000;
    topp1.T_I__c = 3333;
    topp1.Servicer_Status__c = 'Active';
    topp1.Servicer_Provided_Portfolio_Name__c = 'CAF 2020';
    update topp1;

    topp1.Servicer_Name__c = 'Midland1';
    topp1.Servicer_Commitment_Id__c = '123455';

    update topp1;
    Test.stopTest();
  }    
}