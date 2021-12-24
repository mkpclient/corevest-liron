@isTest
public class Deal_Contact_HelperTest {
  static testMethod void testMethod1() {
    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
    Opportunity opp = test_Helper.createOpportunity(acc, cont);

    test.startTest();
    List<Deal_Contact__c> conts = new List<Deal_Contact__c>();
    conts.add(
      new Deal_Contact__c(
        Deal__c = opp.Id,
        Account__c = acc.Id,
        Contact__c = cont.Id,
        Deal_Contact_Type__c = 'Individual',
        Entity_Type__c = 'Guarantor',
        Is_Guarantor__c = true
      )
    );
    conts.add(
      new Deal_Contact__c(
        Deal__c = opp.Id,
        Account__c = acc.Id,
        Contact__c = cont.Id,
        Deal_Contact_Type__c = 'Individual',
        Entity_Type__c = 'Sponsor'
      )
    );
    conts.add(
      new Deal_Contact__c(
        Deal__c = opp.Id,
        Account__c = acc.Id,
        Deal_Contact_Type__c = 'Vendor',
        Vendor_Type__c = 'Legal Counsel'
      )
    );
    conts.add(
      new Deal_Contact__c(
        Deal__c = opp.Id,
        Account__c = acc.Id,
        Deal_Contact_Type__c = 'Vendor',
        Vendor_Type__c = 'Insurance Review'
      )
    );
    conts.add(
      new Deal_Contact__c(
        Deal__c = opp.Id,
        Account__c = acc.Id,
        Deal_Contact_Type__c = 'Vendor',
        Vendor_Type__c = 'Legal Counsel'
      )
    );
    conts.add(
      new Deal_Contact__c(
        Deal__c = opp.Id,
        Account__c = acc.Id,
        Deal_Contact_Type__c = 'Vendor',
        Vendor_Type__c = 'Title and Escrow'
      )
    );
    conts.add(
      new Deal_Contact__c(
        Deal__c = opp.Id,
        Account__c = acc.Id,
        Deal_Contact_Type__c = 'Vendor',
        Vendor_Type__c = 'Rent Deposit Bank'
      )
    );
    conts.add(
      new Deal_Contact__c(
        Deal__c = opp.Id,
        Account__c = acc.Id,
        Deal_Contact_Type__c = 'Vendor',
        Vendor_Type__c = 'Cash Management'
      )
    );
    conts.add(
      new Deal_Contact__c(
        Deal__c = opp.Id,
        Account__c = acc.Id,
        Deal_Contact_Type__c = 'Vendor',
        Vendor_Type__c = '3rd Party Title'
      )
    );
    conts.add(
      new Deal_Contact__c(
        Deal__c = opp.Id,
        Account__c = acc.Id,
        Deal_Contact_Type__c = 'Vendor',
        Vendor_Type__c = 'Lender Legal Counsel'
      )
    );

    insert conts;

    conts[0].Sponsor_Tier__c = 'Tier 2';
    conts[0].Experience__c = 3;
    conts[0].Liquidity__c = 100;
    conts[0].Experian__c = 100;
    conts[0].TransUnion__c = 100;
    conts[0].Equifax__c = 100;
    conts[0].Cash_Equivalent__c = 1000;
    conts[0].Cash_Position__c = 1000;
    conts[0].Net_Worth__c = 1000;
    conts[0].Rental_Units_Owned__c = '20';
    conts[0].Years_of_Experience1__c = 3;
    update conts;

    insert new Deal_Contact__c(
      Deal__c = opp.Id,
      Deal_Contact_Type__c = 'Entity',
      Entity_Type__c = 'Pledgor',
      Company_Name__c = 'Test Company',
      Operating_Agreement_Date__c = system.today(),
      Company_Jurisdiction__c = 'Delaware',
      Company_Type__c = 'Non Profit Corporation',
      Business_Tax_ID_EIN__c = 'test'
    );
    insert new Deal_Contact__c(
      Deal__c = opp.Id,
      Deal_Contact_Type__c = 'Entity',
      Entity_Type__c = 'Borrower',
      Company_Name__c = 'Test Company1',
      Operating_Agreement_Date__c = system.today(),
      Company_Jurisdiction__c = 'Delaware',
      Company_Type__c = 'Non Profit Corporation',
      Business_Tax_ID_EIN__c = 'test'
    );

    // Calling the below method deliberately as this method is not been called in the after insert of Deal Contact Trigger
    deal_Contact_Helper.afterInsert(conts);

    Test.stopTest();
  }

  static testMethod void testMethodDelete() {
    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
    Opportunity opp = test_Helper.createOpportunity(acc, cont);

    test.startTest();
    List<Deal_Contact__c> conts = new List<Deal_Contact__c>();
    conts.add(
      new Deal_Contact__c(
        Deal__c = opp.Id,
        Account__c = acc.Id,
        Deal_Contact_Type__c = 'Vendor',
        Vendor_Type__c = 'Insurance Review'
      )
    );
    conts.add(
      new Deal_Contact__c(
        Deal__c = opp.Id,
        Account__c = acc.Id,
        Deal_Contact_Type__c = 'Vendor',
        Vendor_Type__c = 'Lender Legal Counsel'
      )
    );
    conts.add(
      new Deal_Contact__c(
        Deal__c = opp.Id,
        Account__c = acc.Id,
        Deal_Contact_Type__c = 'Vendor',
        Vendor_Type__c = '3rd Party Title'
      )
    );
    conts.add(
      new Deal_Contact__c(
        Deal__c = opp.Id,
        Account__c = acc.Id,
        Deal_Contact_Type__c = 'Vendor',
        Vendor_Type__c = 'Title and Escrow'
      )
    );

    insert conts;
    delete conts;

    Test.stopTest();
  }
}