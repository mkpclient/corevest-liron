@isTest
private class OpenPeriodTaskEmailScheduleTest {
  @isTest
  static void OpenPeriodTaskEmailScheduleTestMethod() {
    test_Helper.createDealLoanNumber();
    Profile profileDetail = [
      SELECT Id
      FROM Profile
      WHERE Name = 'Standard User'
    ];
    String orgId = UserInfo.getOrganizationId();
    String dateString = String.valueof(Datetime.now())
      .replace(' ', '')
      .replace(':', '')
      .replace('-', '');
    Integer RandomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
    String uniqueName = orgId + dateString + RandomId;
    String uniqueName1 = orgId + dateString + RandomId + '1';
    String uniqueName2 = orgId + dateString + RandomId + '2';

    User oneUser = new User(
      Alias = 'standt',
      Email = 'standarduser@testorg.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = profileDetail.Id,
      IsActive = true,
      TimeZoneSidKey = 'America/New_York',
      UserName = uniqueName + '@test' + orgId + '.org'
    );
    insert oneUser;

    User twoUser = new User(
      Alias = 'standt',
      Email = 'standarduser1@testorg.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing1',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = profileDetail.Id,
      IsActive = false,
      TimeZoneSidKey = 'America/New_York',
      UserName = uniqueName1 + '@test' + orgId + '.org'
    );
    insert twoUser;

    User threeUser = new User(
      Alias = 'standt',
      Email = 'standarduser2@testorg.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing2',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = profileDetail.Id,
      IsActive = true,
      TimeZoneSidKey = 'America/New_York',
      UserName = uniqueName2 + '@test' + orgId + '.org'
    );
    insert threeUser;
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

    Opportunity opp = new Opportunity();
    opp.Name = 'test';
    opp.OwnerId = oneUser.id;
    opp.Current_UPB__c = 100;
    opp.CloseDate = System.today();
    opp.Final_Spread__c = 2;
    opp.Final_Swap__c = 2;
    opp.StageName = 'Closed Won';
    opp.Type = 'Term Loan';
    opp.Loan_Size__c = 2000000;
    opp.AccountId = a.Id;
    opp.Contact__c = cont.Id;
    opp.Term_Loan_Type__c = '5 Year';
    opp.Final_Loan_Amount__c = 100;
    opp.Deal_Intro_Source__c = 'Hotline';
    opp.Deal_Intro_Sub_Source__c = 'Main';
    opp.Apex_Context__c = true;
    //opp.Loan_in_Default__c = false;

    // opp.Updated_Loan_Maturity_Date__c = System.today().addMonths(9);
    opp.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
    ]
    .Id;
    opp.GLC_Approved__c = false;
    opp.Background_Check_Completed__c = false;
    opp.Term_Loan_Type__c = '5 Year';
    opp.YM_Prepayment_Penalty__c = '34 Months';
    opp.First_Payment_Date__c = System.today().addmonths(-22);

    insert opp;
    opportunity myOpp = [
      SELECT Open_Period_Begins__c
      FROM Opportunity
      WHERE ID = :opp.ID
    ];
    system.debug('date?' + myOpp.Open_Period_Begins__c);
    Opportunity opp2 = new Opportunity();
    opp2.Name = 'test';
    opp2.OwnerId = twoUser.id;
    opp2.Current_UPB__c = 100;
    opp2.CloseDate = System.today();
    opp2.Final_Spread__c = 2;
    opp2.Final_Swap__c = 2;
    opp2.StageName = 'Closed Won';
    opp2.Type = 'Term Loan';
    opp2.Term_Loan_Type__c = '5 Year';

    opp2.Loan_Size__c = 2000000;
    opp2.AccountId = a.Id;
    opp2.Contact__c = cont.Id;
    opp2.Final_Loan_Amount__c = 100;
    opp2.Deal_Intro_Source__c = 'Hotline';
    opp2.Deal_Intro_Sub_Source__c = 'Main';
    opp2.Apex_Context__c = true;

    //opp.Loan_in_Default__c = false;

    // opp2.Updated_Loan_Maturity_Date__c = System.today().addMonths(12);
    opp2.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
    ]
    .Id;
    opp2.GLC_Approved__c = false;
    opp2.Background_Check_Completed__c = false;
    opp2.Term_Loan_Type__c = '5 Year';
    opp2.YM_Prepayment_Penalty__c = '34 Months';
    opp2.First_Payment_Date__c = System.today().addmonths(-25);

    insert opp2;

    opportunity myOpp2 = [
      SELECT Open_Period_Begins__c
      FROM Opportunity
      WHERE ID = :opp2.ID
    ];
    system.debug('date2?' + myOpp2.Open_Period_Begins__c);

    test.startTest();
    OpenPeriodTaskEmailScheduled myClass = new OpenPeriodTaskEmailScheduled();
    String chron = '0 0 21 * * ?';
    system.schedule('Test Sched', chron, myClass);
    System.debug(myClass);
    test.stopTest();
  }
}