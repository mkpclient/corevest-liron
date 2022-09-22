@isTest
private class CovenantRecurringEmailTest {
  @isTest
  static void CovenantRecurringEmailAlertTest() {
      

test_Helper.createDealLoanNumber();
    account acc = new account();
    acc.name = 'testacc';

    insert acc;

    contact con = new contact();
    con.FirstName = 'test contact';
    con.LastName = 'test cont';
    con.Email = 'email@email.com';
    con.Primary_Contact__c = true;
    con.AccountId = acc.Id;
    con.MailingCity = 'test city';
    con.MailingCountry = 'United States';

    insert con;

    System.debug(con.FirstName);
    System.debug(con.LastName);

    opportunity opp = new opportunity();
    opp.name = 'testopp';
    opp.StageName = 'Initial Review';
    opp.CloseDate = date.today();
    opp.AccountId = acc.Id;
    opp.ContactId = con.id;
    opp.Contact__c = con.id;

    insert opp;

    covenant__c cov = new covenant__c();
    cov.Name = 'testcov';
    cov.Deal__c = opp.id;
    cov.Due_Date__c = system.today();

    insert cov;

    task tsk = new task();
    tsk.Subject = 'Financial Covenants';
    tsk.Priority = 'Normal';
    tsk.Status = 'Open';
    tsk.Type = 'Financial Covenants';
    tsk.WhatId = cov.Id;
    task t = new task();
    t.type = 'Financial Covenants';
    t.X10_Day_Email_Sent__c = true;
    t.Status = 'Open';
    t.Covenant_Milestones__c = false;
    t.Subject = 'Financial Covenants';
    t.WhatId = cov.id;

    insert t;

    test.starttest();
    CovenantRecurringEmailAlert myClass = new CovenantRecurringEmailAlert();
    String chron = '0 0 23 * * ?';
    system.schedule('Test Sched', chron, myClass);
    System.debug(myClass);
    test.stopTest();
  }
}