@isTest
private class community_Tests {
  //static List<Account> testAccounts = testDataFactory.createTestRecords(new Account[10]);

  static testMethod void community_Tests_UnitTest() {
    test_Helper.createDealLoanNumber();
    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
    Opportunity opp = test_Helper.createOpportunity(acc, cont);
    insert new Deal_Contact__c(Account__c = acc.Id, Deal__c = opp.Id);
    opp.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE DeveloperName = 'Term_Loan' AND sobjecttype = 'Opportunity'
    ]
    .Id;
    List<Property__c> properties = test_Helper.createProperties(opp);

    //Code Added by Trivikram
    List<Opportunity> listTestOpportunity = new List<Opportunity>();
    listTestOpportunity.add(opp);

    Test.startTest();
    community_Controller.getRecordTypeName(opp.Id);
    community_Controller.getRecordList(
      opp.Id,
      'Deal__c',
      'Property__c',
      new List<String>{ 'Name' },
      'Name',
      'Desc',
      'Name != null',
      ''
    );
    community_Controller.queryRecord(opp.Id, new List<String>{ 'Name' });
    community_Controller.getFieldTypeMap('Opportunity');
    community_Controller.getDocumentList(
      opp.Id,
      'Deal__c',
      'Deal_Document__c',
      new List<String>{ 'Name' },
      'Name',
      'Desc',
      '',
      '',
      acc.Id,
      'Title and Escrow',
      'vendor'
    );
    community_Controller.getBorrowerDeals(
      cont.Id,
      new List<String>{ 'Name' },
      'Desc',
      'Name',
      '',
      false,
      false,
      false
    );
    lightning_Controller.getDocuments(
      String.valueOf(opp.Id),
      'vendor',
      String.valueOf(acc.Id),
      'Title and Escrow'
    );
    lightning_Controller.getDocuments(
      String.valueOf(opp.Id),
      'borrower',
      String.valueOf(acc.Id),
      'Title and Escrow'
    );
    lightning_Controller.getDocuments(
      String.valueOf(opp.Id),
      'internal',
      String.valueOf(acc.Id),
      'Title and Escrow'
    );
    community_Controller.getUser();
    community_Controller.getPropertyPicklists(opp.Id);
    community_Controller.getProperties(
      'Borrower',
      opp.Id,
      new List<String>{ 'Id', 'Name' },
      'Name != null',
      '',
      '',
      false,
      false,
      false
    );
    //community_Controller.queryLayout('Opportunity', 'Term Loan', 'Borrower');
    community_Controller.getVendorDeals(
      acc.Id,
      new List<String>{ 'Id', 'Name' },
      'Asc',
      'Name',
      'Name != null',
      true,
      false,
      false
    );

    //Code Added by Trivikram : Start
    community_Controller.upsertRecords(listTestOpportunity);
    community_Controller.getPropertyDeal(
      opp.Id,
      new List<String>{ 'Name' },
      'Property__c',
      'Name',
      'Name'
    );
    community_Controller.getRecordTypeName('');
    community_Controller.getDeals(
      new List<String>{ 'Name' },
      'Name',
      'Name',
      '',
      false,
      false,
      false
    );
    community_Controller.getVendorDeals(
      acc.Id,
      new List<String>{ 'Id', 'Name' },
      'Asc',
      'Name',
      'Name != null',
      false,
      true,
      false
    );
    community_Controller.getVendorDeals(
      acc.Id,
      new List<String>{ 'Id', 'Name' },
      'Asc',
      'Name',
      'Name != null',
      false,
      false,
      true
    );
    community_Controller.getDealRecordTypeName('');
    community_Controller.getDealRecordTypeName(properties[0].Id);
    User testVendorUser = setupVendor();

    System.runAs(testVendorUser) {
      community_Controller.getDocumentList(
        opp.Id,
        'Deal__c',
        'Deal_Document__c',
        new List<String>{ 'Name' },
        'Name',
        'Desc',
        'Name != null',
        'Name',
        acc.Id,
        'Title and Escrow',
        'vendor'
      );

      community_Controller.getProperties(
        'Borrower',
        opp.Id,
        new List<String>{ 'Id', 'Name' },
        'Name != null',
        '',
        'Name != null',
        false,
        false,
        false
      );
      community_Controller.getBorrowerDeals(
        cont.Id,
        new List<String>{ 'Name' },
        'Desc',
        'Name',
        '',
        true,
        false,
        false
      );
      community_Controller.getBorrowerDeals(
        cont.Id,
        new List<String>{ 'Name' },
        'Desc',
        'Name',
        'Name != null',
        false,
        true,
        false
      );
      community_Controller.getBorrowerDeals(
        cont.Id,
        new List<String>{ 'Name' },
        'Desc',
        'Name',
        '',
        false,
        false,
        true
      );

      try {
        community_Controller.getDeals(
          new List<String>{ 'Name' },
          'Name',
          'Name',
          '',
          false,
          false,
          false
        );
      } catch (Exception ex) {
        System.debug('Exception >>>>>>' + ex);
      }
    }
    //Code Added by Trivikram : End

    Test.stopTest();
  }

  //Method Added by Trivikram
  private static User setupVendor() {
    Id p = [SELECT Id FROM Profile WHERE Name = 'Vendor Portal User'].Id;
    Id recordType = [
      SELECT Id
      FROM RecordType
      WHERE SobjectType = 'Account' AND DeveloperName = 'Vendor'
      LIMIT 1
    ]
    .Id;
    Account ac = new Account(name = 'Grazitti');
    ac.RecordTypeId = recordType;
    insert ac;

    Contact con = new Contact(LastName = 'testCon', AccountId = ac.Id);
    insert con;
    User user = new User(
      alias = 'test123',
      email = 'test123@noemail.com',
      emailencodingkey = 'UTF-8',
      lastname = 'Testing',
      languagelocalekey = 'en_US',
      localesidkey = 'en_US',
      profileid = p,
      country = 'United States',
      IsActive = true,
      ContactId = con.Id,
      timezonesidkey = 'America/Los_Angeles',
      username = 'tester@noemail.com'
    );

    insert user;
    return user;
  }
}