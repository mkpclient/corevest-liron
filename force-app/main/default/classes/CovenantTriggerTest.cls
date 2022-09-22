@isTest
private class CovenantTriggerTest {
  @isTest
  static void CovTriggerTest() {
    Id recordTypeId = Schema.SObjectType.task.getRecordTypeInfosByDeveloperName()
      .get('Task')
      .getRecordTypeId();


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

    insert con;

    opportunity opp = new opportunity();
    opp.name = 'testopp';
    opp.StageName = 'Term sheet Issued';
    opp.CloseDate = date.today();
    opp.AccountId = acc.Id;
    opp.Contact__c = con.id;
    opp.ContactId = con.id;

    insert opp;

    covenant__c cov = new covenant__c();
    cov.Name = 'testcov';
    cov.Deal__c = opp.id;

    insert cov;

    task tsk = new task();
    tsk.Subject = cov.Name;
    tsk.Priority = 'Normal';
    tsk.Status = 'Open';
    tsk.Type = 'Financial Covenants';
    tsk.WhatId = cov.Id;
    tsk.RecordTypeId = recordTypeId;

    insert tsk;
    system.assertEquals('Open', tsk.Status);

    cov.Milestones__c = 'Construction milestone pending';

    update cov;
    task updatedTask = [SELECT status FROM task WHERE id = :tsk.id];
    system.assertEquals('Completed', updatedTask.Status);
  }
  @isTest
  static void CovTriggerTestDueDate() {
    Id recordTypeId = Schema.SObjectType.task.getRecordTypeInfosByDeveloperName()
      .get('Task')
      .getRecordTypeId();
    account acc = new account();
    acc.name = 'testacc';

    insert acc;

    contact con = new contact();
    con.FirstName = 'test contact';
    con.LastName = 'test cont';
    con.Email = 'email@email.com';
    con.Primary_Contact__c = true;
    con.AccountId = acc.Id;

    insert con;


test_Helper.createDealLoanNumber();
    opportunity opp = new opportunity();
    opp.name = 'testopp';
    opp.StageName = 'Term sheet Issued';
    opp.CloseDate = date.today();
    opp.AccountId = acc.Id;
    opp.Contact__c = con.id;
    opp.ContactId = con.id;

    insert opp;

    covenant__c cov = new covenant__c();
    cov.Name = 'testcov';
    cov.Deal__c = opp.id;
    cov.Covenant_Details__c = 'test comments';
    cov.Due_Date__c = date.today();

    insert cov;

    task tsk = new task();
    tsk.Subject = cov.Name;
    tsk.Priority = 'Normal';
    tsk.Status = 'Open';
    tsk.Type = 'Financial Covenants';
    tsk.WhatId = cov.Id;
    tsk.RecordTypeId = recordTypeId;
    tsk.ActivityDate = cov.Due_Date__c;
    tsk.IsReminderSet = true;
    tsk.ReminderDateTime = cov.Due_Date__c - 15;

    insert tsk;
    system.assertEquals('Open', tsk.Status);

    cov.Milestones__c = 'Construction milestone pending';

    update cov;

    task updatedTask = [SELECT status FROM task WHERE id = :tsk.id];
    system.assertEquals('Completed', updatedTask.Status);
  }
}