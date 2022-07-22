@isTest
private class ConfirmationOfTermsTests {
  @isTest
  private static void testMethod1() {
    test_Helper.createDealLoanNumber();
    Account a = new Account();
    a.Name = 'test';
    a.BillingCountry = 'United States';
    a.BillingState = 'California';
    a.Introductions_Source__c = 'Hotline';
    a.Introduction_Subsource__c = 'Main';
    a.Alternate_Phone__c = '5555555555';
    insert a;

    Contact c = new Contact();
    c.FirstName = 'test';
    c.LastName = 'test';
    c.MailingCountry = 'United States';
    c.MailingState = 'California';
    c.AccountId = a.Id;
    c.MobilePhone = '5555555555';
    c.Phone = '7777777777';
    c.Experian__c = 700;
    c.TransUnion__c = 710;
    c.Equifax__c = 700;
    c.Years_of_Experience__c = 10;
    c.Rental_Units_Owned__c = '5';
    c.Sponsor_Tier__c = 'Tier 1';
    c.Experience__c = 5;
    insert c;

    User u = [
      SELECT Id
      FROM User
      WHERE
        Profile.Name = 'System Administrator'
        AND IsActive = TRUE
        AND Id != :UserInfo.getUserId()
      LIMIT 1
    ];

    opportunity opp = new opportunity();
    opp.Name = 'Test opportunity';
    opp.CloseDate = System.today();
    opp.StageName = 'Initial Review';
    opp.Foreign_National_picklist__c = 'No';
    opp.AccountId = a.id;
    opp.Contact__c = c.id;
    opp.OwnerId = UserInfo.getUserId();
    opp.CAF_Analyst__c = UserInfo.getUserId();
    opp.Underwriter__c = u.Id;
    opp.Closer__c = UserInfo.getUserId();
    // opp.
    insert opp;

    // Property__c pr = new Property__c();
    // pr.Name = 'Test Property';
    // pr.Property_Type__c = 'SFR';
    // pr.Deal__c = opp.id;
    // pr.Status__c = 'Active';
    // pr.Number_of_Units__c = 25;
    // insert pr;

    Test.startTest();
    ConfirmationOfTermsController.getApprovalPicklists(opp.Id);
    ConfirmationOfTermsController.Panels panels = (ConfirmationOfTermsController.Panels) JSON.deserialize(
      ConfirmationOfTermsController.getRecordDetails(opp.Id, null),
      ConfirmationOfTermsController.Panels.class
    );
    ConfirmationOfTermsController.getWrapperBundle(opp.Id, null);

    ConfirmationOfTermsController.submitApproval(
      opp.Id,
      'Test',
      JSON.serialize(panels.submissionDetails)
    );

    ConfirmationOfTermsController.originatorApprove(
      opp.Id,
      'Test',
      JSON.serialize(panels.submissionDetails),
      JSON.serialize(panels.comments)
    );

    ConfirmationOfTermsController.underwriterApprove(
      opp.Id,
      'Test',
      JSON.serialize(panels.submissionDetails),
      JSON.serialize(panels.comments)
    );
    Test.stopTest();
  }
}