@isTest
private class DealSchedulerTest {
  static testMethod void testMethod1() {
    List<Account> testAccts = new List<Account>();
    List<Opportunity> testOppts = new List<Opportunity>();
    List<Contact> testContacts = new List<Contact>();
    List<Id> opptIds = new List<Id>();

    for (Integer i = 0; i < 5; i++) {
      testAccts.add(
        new Account(
          Name = 'Test Account ' + i,
          BillingCountry = 'United States',
          BillingState = 'Iowa',
          BillingCity = 'Dubuque',
          BillingStreet = '111 Main St.',
          Introductions_Source__c = 'Hotline',
          Introduction_Subsource__c = 'Main',
          Alternate_Phone__c = '5555555555'
        )
      );
      testContacts.add(
        new Contact(
          FirstName = 'Test',
          LastName = 'Contact' + i,
          MailingCountry = 'United States',
          MailingState = 'Wisconsin',
          MailingCity = 'Eau Claire',
          MailingStreet = '111 Main St.',
          Email = 'logins+cvest@mkpartners.com'
        )
      );
    }

    insert testAccts;
    insert testContacts;

    for (Integer j = 0; j < 5; j++) {
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
      testDeal.Name = 'Test Deal' + j;
      testDeal.StageName = 'Loan Processing';
      testDeal.Contact__c = testContacts[j].Id;
      testDeal.CloseDate = Date.today().addDays(-89 - j);
      testDeal.AccountId = testAccts[j].Id;
      testDeal.Stated_Maturity_Date__c = null;
      testOppts.add(testDeal);
    }

    insert testOppts;

    for (Opportunity testDeal : testOppts) {
      testDeal.Maturity_Date_Calculation_Type__c = 'Fixed at First Advance';
      opptIds.add(testDeal.Id);
    }

    update testOppts;

    for (Opportunity testDeal : testOppts) {
      testDeal.Advance_Period__c = 365;
      testDeal.LOC_Term__c = '540 Days';
    }

    update testOppts;

    system.debug('Deal schedule test oppts: ' + testOppts);

    List<Deal_Contact__c> testDealContacts = new List<Deal_Contact__c>();
    for (integer h = 0; h < 5; h++) {
      testDealContacts.add(
        new Deal_Contact__c(
          Contact__c = testContacts[h].Id,
          Deal_Contact_Type__c = 'Individual',
          Entity_Type__c = 'Guarantor',
          Deal__c = testOppts[h].Id
        )
      );
    }

    insert testDealContacts;

    Test.startTest();
    new DealScheduler().execute(null);
    Test.stopTest();

    Date expirationDate = Date.today().addDays(365);
    Date matDate = Date.today().addDays(540);

    List<Opportunity> returnedDeals = [
      SELECT
        Id,
        Stated_Maturity_Date__c,
        Updated_Loan_Maturity_Date__c,
        Modified_Expiration_Date__c,
        CloseDate
      FROM Opportunity
      WHERE Id IN :opptIds
    ];

    System.debug('Returned deals from deal schedule test : ' + returnedDeals);

    for (Opportunity deal : returnedDeals) {
      if (deal.CloseDate <= Date.today().addDays(-90)) {
        System.assertEquals(
          matDate,
          deal.Stated_Maturity_Date__c,
          'Maturity Dates should match.'
        );
        System.assertEquals(
          matDate,
          deal.Updated_Loan_Maturity_Date__c,
          'Updated Maturity dates should match.'
        );
        System.assertEquals(
          expirationDate,
          deal.Modified_Expiration_Date__c,
          'Expiration dates should match.'
        );
      } else {
        System.assertNotEquals(
          matDate,
          deal.Stated_Maturity_Date__c,
          'Maturity Dates should not match.'
        );
        System.assertNotEquals(
          matDate,
          deal.Updated_Loan_Maturity_Date__c,
          'Updated Maturity dates should not match.'
        );
        System.assertNotEquals(
          expirationDate,
          deal.Modified_Expiration_Date__c,
          'Expiration dates should not match.'
        );
      }
    }
  }
}