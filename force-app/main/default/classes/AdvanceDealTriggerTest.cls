@isTest
private class AdvanceDealTriggerTest {
  @TestVisible
  private static string statusValid = 'Completed';
  @TestVisible
  private static string statusInvalid = 'Pending';
  @isTest
  static void advanceDealTriggerTestInsert() {
    Test_Helper.createRate();
    Test_Helper.createDealLoanNumber();
    Account acc = test_Helper.createAccount();
    Contact testContact = new Contact();
    testContact.FirstName = 'Test';
    testContact.LastName = 'Contact';
    testContact.Email = 'logins+cvest@mkpartners.com';
    testContact.AccountId = acc.Id;

    insert testContact;

    Opportunity testDeal = new Opportunity();
    testDeal.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'LOC_Loan'
    ]
    .Id;
    testDeal.LOC_Loan_Type__c = 'Credit Line';
    testDeal.Active_States__c = 'Iowa;Ohio';
    testDeal.Product_Sub_Type__c = 'Renovation';
    testDeal.Renovation_Funding__c = 'Yes';
    testDeal.Reno_Funding_Type__c = 'Advances';
    testDeal.Project_Strategy__c = 'Renovate and Rent';
    testDeal.Name = 'Test Deal';
    testDeal.StageName = 'Loan Processing';
    testDeal.Contact__c = testContact.Id;
    testDeal.CloseDate = Date.today();
    testDeal.AccountId = acc.Id;
    testDeal.Stated_Maturity_Date__c = null;

    insert testDeal;

    //very picky picklist
    testDeal.Maturity_Date_Calculation_Type__c = 'Fixed at First Advance';

    update testDeal;

    testDeal.Advance_Period__c = 365;
    testDeal.LOC_Term__c = '540 Days';

    update testDeal;

    Deal_Contact__c testDealContact = new Deal_Contact__c(
      Contact__c = testContact.Id,
      Deal_Contact_Type__c = 'Individual',
      Entity_Type__c = 'Guarantor',
      Deal__c = testDeal.Id
    );

    insert testDealContact;

    Advance__c testAdvance = new Advance__c();
    testAdvance.Status__c = statusValid;
    testAdvance.Deal__c = testDeal.Id;
    testAdvance.Wire_Date__c = Date.today();
    testAdvance.Closing_Funds_Checklist__c = true;
    testAdvance.Manager_Approved__c = true;
    testAdvance.Evidence_of_Insurance_Approved__c = true;
    testAdvance.Flood_Certificate_Approved__c = true;

    Test.startTest();
    insert testAdvance;
    Integer emailInvocations = Limits.getEmailInvocations();
    Test.stopTest();

    Date expirationDate = Date.today().addDays(365);
    Date matDate = Date.today().addDays(540);

    Opportunity updatedDeal = [
      SELECT
        Id,
        Modified_Expiration_Date__c,
        Stated_Maturity_Date__c,
        Updated_Loan_Maturity_Date__c
      FROM Opportunity
      WHERE Id = :testDeal.Id
      LIMIT 1
    ];

    System.assertEquals(1, emailInvocations, 'An email should be sent.');

    System.assertEquals(
      matDate,
      updatedDeal.Stated_Maturity_Date__c,
      'Stated Maturity date should match'
    );
    System.assertEquals(
      matDate,
      updatedDeal.Updated_Loan_Maturity_Date__c,
      'Updated Loan Maturity date should match'
    );
    System.assertEquals(
      expirationDate,
      updatedDeal.Modified_Expiration_Date__c,
      'Expiration date should match'
    );
  }

  @isTest
  static void advanceDealTriggerTestUpdatePass() {
    Test_Helper.createRate();
    Test_Helper.createDealLoanNumber();
    Account acc = test_Helper.createAccount();
    Contact testContact = new Contact();
    testContact.FirstName = 'Test';
    testContact.LastName = 'Contact';
    testContact.Email = 'logins+cvest@mkpartners.com';
    testContact.AccountId = acc.Id;

    insert testContact;

    Opportunity testDeal = new Opportunity();
    testDeal.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'LOC_Loan'
    ]
    .Id;
    testDeal.LOC_Loan_Type__c = 'Credit Line';
    testDeal.Active_States__c = 'Iowa;Ohio';
    testDeal.Product_Sub_Type__c = 'Renovation';
    testDeal.Renovation_Funding__c = 'Yes';
    testDeal.Reno_Funding_Type__c = 'Advances';
    testDeal.Project_Strategy__c = 'Renovate and Rent';
    testDeal.Name = 'Test Deal';
    testDeal.StageName = 'Loan Processing';
    testDeal.Contact__c = testContact.Id;
    testDeal.CloseDate = Date.today();
    testDeal.AccountId = acc.Id;
    testDeal.Stated_Maturity_Date__c = null;

    insert testDeal;

    //very picky picklist
    testDeal.Maturity_Date_Calculation_Type__c = 'Fixed at First Advance';

    update testDeal;

    testDeal.Advance_Period__c = 365;
    testDeal.LOC_Term__c = '540 Days';

    update testDeal;

    Deal_Contact__c testDealContact = new Deal_Contact__c(
      Contact__c = testContact.Id,
      Deal_Contact_Type__c = 'Individual',
      Entity_Type__c = 'Guarantor',
      Deal__c = testDeal.Id
    );

    insert testDealContact;

    Advance__c testAdvance = new Advance__c();
    testAdvance.Status__c = statusInvalid;
    testAdvance.Deal__c = testDeal.Id;
    testAdvance.Wire_Date__c = Date.today();
    testAdvance.Closing_Funds_Checklist__c = true;
    testAdvance.Manager_Approved__c = true;
    testAdvance.Evidence_of_Insurance_Approved__c = true;
    testAdvance.Flood_Certificate_Approved__c = true;

    insert testAdvance;

    Advance__c updatedAdvance = new Advance__c();
    updatedAdvance.Id = testAdvance.Id;
    updatedAdvance.Status__c = statusValid;

    Test.startTest();
    update updatedAdvance;
    Integer emailInvocations = Limits.getEmailInvocations();
    Test.stopTest();

    Date expirationDate = Date.today().addDays(365);
    Date matDate = Date.today().addDays(540);

    Opportunity updatedDeal = [
      SELECT
        Id,
        Modified_Expiration_Date__c,
        Stated_Maturity_Date__c,
        Updated_Loan_Maturity_Date__c
      FROM Opportunity
      WHERE Id = :testDeal.Id
      LIMIT 1
    ];

    System.assertEquals(1, emailInvocations, 'An email should be sent.');

    System.assertEquals(
      expirationDate,
      updatedDeal.Modified_Expiration_Date__c,
      'Expiration date should match'
    );
    System.assertEquals(
      matDate,
      updatedDeal.Stated_Maturity_Date__c,
      'Stated Maturity date should match'
    );
    System.assertEquals(
      matDate,
      updatedDeal.Updated_Loan_Maturity_Date__c,
      'Updated Loan Maturity date should match'
    );
  }

  @isTest
  static void advanceDealTriggerTestUpdateFail() {
    Test_Helper.createRate();
    Test_Helper.createDealLoanNumber();
    Contact testContact = new Contact();
    testContact.FirstName = 'Test';
    testContact.LastName = 'Contact';

    insert testContact;

    Opportunity testDeal = new Opportunity();
    testDeal.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'LOC_Loan'
    ]
    .Id;
    testDeal.LOC_Loan_Type__c = 'Credit Line';
    testDeal.Active_States__c = 'Iowa;Ohio';
    testDeal.Product_Sub_Type__c = 'Renovation';
    testDeal.Renovation_Funding__c = 'Yes';
    testDeal.Reno_Funding_Type__c = 'Advances';
    testDeal.Project_Strategy__c = 'Renovate and Rent';
    testDeal.Name = 'Test Deal';
    testDeal.StageName = 'Loan Processing';
    testDeal.Contact__c = testContact.Id;
    testDeal.CloseDate = Date.today();
    testDeal.Stated_Maturity_Date__c = null;

    insert testDeal;

    //very picky picklist
    testDeal.Maturity_Date_Calculation_Type__c = 'Fixed at First Advance';

    update testDeal;

    testDeal.Advance_Period__c = 365;
    testDeal.LOC_Term__c = '540 Days';

    update testDeal;

    Advance__c testAdvance = new Advance__c();
    testAdvance.Status__c = statusInvalid;
    testAdvance.Deal__c = testDeal.Id;
    testAdvance.Wire_Date__c = Date.today();

    insert testAdvance;

    Test.startTest();
    update testAdvance;
    Integer emailInvocations = Limits.getEmailInvocations();
    Test.stopTest();

    Date expirationDate = Date.today().addDays(365);
    Date matDate = Date.today().addDays(540);

    Opportunity updatedDeal = [
      SELECT
        Id,
        Modified_Expiration_Date__c,
        Stated_Maturity_Date__c,
        Updated_Loan_Maturity_Date__c
      FROM Opportunity
      WHERE Id = :testDeal.Id
      LIMIT 1
    ];

    System.assertEquals(0, emailInvocations, 'An email should not be sent.');

    System.assertNotEquals(
      expirationDate,
      updatedDeal.Modified_Expiration_Date__c,
      'Expiration date should not match'
    );
    System.assertNotEquals(
      matDate,
      updatedDeal.Stated_Maturity_Date__c,
      'Stated Maturity date should not match'
    );
    System.assertNotEquals(
      matDate,
      updatedDeal.Updated_Loan_Maturity_Date__c,
      'Updated Loan Maturity date should not match'
    );
  }
}