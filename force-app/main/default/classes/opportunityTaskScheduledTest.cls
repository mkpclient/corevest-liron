@isTest
private class opportunityTaskScheduledTest {
  @isTest
  static void opportunityTaskScheduledTestmethod() {
    User myUser = [
      SELECT Id
      FROM User
      WHERE Profile.Name = 'System Administrator'
      LIMIT 1
    ];
    User myUser2 = [
      SELECT Id
      FROM User
      WHERE Profile.Name = 'System Administrator'
      LIMIT 1
    ];
    User myUser3 = [
      SELECT Id
      FROM User
      WHERE Profile.Name = 'System Administrator'
      LIMIT 1
    ];

    Account acc = test_Helper.createAccount();

    Contact cont = test_Helper.createContact(acc);
    Opportunity opp = test_Helper.createBridgeDeal(acc, cont);
    opp.StageName = 'Loan Processing';
    opp.Loan_Coordinator__c = myUser.id;
    opp.CloseDate = System.today() - 3;
    update opp;

    Opportunity opp1 = test_Helper.createBridgeDeal(acc, cont);
    opp1.StageName = 'Underwriting';
    opp1.Underwriter__c = myUser2.id;
    opp1.CloseDate = System.today() - 3;
    update opp1;

    Opportunity opp2 = test_Helper.createBridgeDeal(acc, cont);
    opp2.StageName = 'Loan Processing';
    opp2.Closer__c = myUser3.id;
    opp2.CloseDate = System.today() - 3;
    update opp2;

    // Opportunity myOpp = new Opportunity();
    // myOpp.name = 'testopp';
    // myOpp.AccountId = acc.id;
    // myOpp.Contact__c = cont.id;
    // myOpp.StageName = 'Underwriting';
    // myOpp.CloseDate = System.today() - 3;
    // myOpp.Underwriter__c = myUser2.id;
    // insert myOpp;

    // Opportunity myOppor = new Opportunity();
    // myOppor.name = 'testopp';
    // myOppor.AccountId = acc.id;
    // myOppor.Contact__c = cont.id;
    // myOppor.StageName = 'Approved by Committee';
    // myOppor.CloseDate = System.today() - 3;
    // myOppor.Closer__c = myUser3.id;
    // insert myOppor;

    test.starttest();

    opportunityTaskScheduled myClass = new opportunityTaskScheduled();
    String chron = '0 0 23 * * ?';
    system.schedule('Test Sched', chron, myClass);
    System.debug(myClass);
    test.stopTest();
  }
}