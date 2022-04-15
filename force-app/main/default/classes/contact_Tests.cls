@isTest
private class contact_Tests {
  //static List<Account> testAccounts = testDataFactory.createTestRecords(new Account[10]);

  static testMethod void contact_Tests_UnitTest() {
    List<User> users = [SELECT Id FROM User];
    Lead l = new Lead(
      FirstName = 'Test',
      LastName = 'Tester',
      Requested_Loan_Size__c = 500,
      Company = 'Tester',
      Introduction_Source__c = 'CAF Website',
      Email = 'none@gmail.com'
    );

    insert l;

    Database.LeadConvert lc = new Database.LeadConvert();
    lc.setLeadId(l.id);

    LeadStatus convertStatus = [
      SELECT Id, MasterLabel
      FROM LeadStatus
      WHERE IsConverted = TRUE
      LIMIT 1
    ];
    lc.setConvertedStatus(convertStatus.MasterLabel);
    lc.setDoNotCreateOpportunity(true);
    Database.LeadConvertResult lcr = Database.convertLead(lc);

    Lead convertedLead = [
      SELECT Id, ConvertedContactId
      FROM Lead
      WHERE Id = :l.Id
    ];
    Contact c = [
      SELECT Id, OwnerId
      FROM Contact
      WHERE Id = :convertedLead.ConvertedContactId
    ];

    Test.startTest();
    if (c.OwnerId != users[0].Id) {
      c.OwnerId = users[0].Id;
    } else {
      c.OwnerId = users[1].Id;
    }

    update c;
    Test.stopTest();

    // Lead updatedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = : l.Id];
    //system.assertEquals(c.OwnerId, updatedLead.OwnerId);
  }

  static testMethod void contact_Tests_UnitTest2() {
    account acc = new account();
    acc.name = 'test123';
    acc.Site = 'California';
    insert acc;
    contact con = new contact();
    con.FirstName = 'testfirst';
    con.LastName = 'testlast';
    con.AccountId = acc.id;
    insert con;
    con.In_Litigation__c = true;
    update con;
    account acc2 = new account();
    acc2.name = 'test456';
    acc2.Site = 'California';
    insert acc2;
    con.AccountId = acc2.Id;
    update con;
    delete con;
  }

  @IsTest
  static void contactPhoneTest() {
    Test.startTest();
    account acc = new account();
    acc.name = 'contactPhoneTest';
    acc.Site = 'California';
    insert acc;
    contact con = new contact();
    con.AccountId = acc.id;
    con.FirstName = 'testfirst';
    con.LastName = 'testlast';
    con.Phone = '5555555555';
    con.HomePhone = '2222222222';
    con.MobilePhone = '3333333333';
    insert con;

    con.Phone = '9999999999';
    con.HomePhone = '1111111111';
    con.MobilePhone = '4444444444';
    update con;
    Test.stopTest();
  }

  @IsTest
  static void contactPhoneTest2() {
    Test.startTest();
    account acc = new account();
    acc.name = 'contactPhoneTest';
    acc.Site = 'California';
    insert acc;
    contact con = new contact();
    con.AccountId = acc.id;
    con.FirstName = 'testfirst';
    con.LastName = 'testlast';
    con.HomePhone = '2222222222';
    con.MobilePhone = '3333333333';
    insert con;

    contact con2 = new contact();
    con2.AccountId = acc.id;
    con2.FirstName = 'testfirst';
    con2.LastName = 'testlast';
    insert con2;

    con2.MobilePhone = '6666666666';
    update con2;

    Test.stopTest();
  }

  @IsTest(SeeAllData=true)
  static void bizTerminatedTest() {
    Contact c = [
      SELECT Id, Status__c
      FROM Contact
      WHERE
        Status__c != 'Business Relationship Terminated'
        AND RecordType.Name = 'Vendor'
      LIMIT 1
    ];

    ContentNote noteRecord = new ContentNote();
    noteRecord.Title = 'Test Content Note';
    String body = 'Test Content Note';
    noteRecord.Content = Blob.valueOf(body.escapeHTML4());
    insert noteRecord;
    ContentDocumentLink link = new ContentDocumentLink();
    link.ContentDocumentId = noteRecord.id;
    link.LinkedEntityId = c.Id;
    link.ShareType = 'I';
    link.Visibility = 'InternalUsers';
    insert link;

    c.Status__c = 'Business Relationship Terminated';
    update c;
  }
}
