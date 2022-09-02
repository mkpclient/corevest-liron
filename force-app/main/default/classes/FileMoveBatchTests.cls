@isTest
private class FileMoveBatchTests {
  static testMethod void unittest() {
    Test_Helper.createDealLoanNumber();
    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
    // Opportunity opp = test_Helper.createOpportunity(acc, cont);
    // opp.Apex_Context__c = true;
    // opp.RecordTypeId = [
    //   SELECT Id
    //   FROM RecordType
    //   WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'LOC_Loan'
    // ]
    // .Id;
    // opp.StageName = 'Hold';
    // opp.Draw_Period__c = '12 Months';
    // opp.Repayment_Period__c = '9 Months';
    // opp.LOC_Loan_Type__c = 'Credit Line';
    // opp.Loan_Size__c = 3000000;
    // opp.Maturity_Date_Calculation_Type__c = 'Fixed at Closing';
    // opp.Line_Expiration__c = '18 Months';
    // opp.Requested_LTC_Max__c = 70;
    // opp.Requested_LTV_Max__c = 80;
    // opp.Requested_Origination_Fee__c = 0;
    // opp.Requested_Draw_Fee__c = 2;
    // opp.Requested_Exit_Fee__c = 0;
    // opp.Requested_Interest_Type__c = 'Fixed';
    // opp.Requested_Rate_1_9_Months__c = 10;
    // opp.Requested_Revolving__c = 'Yes';
    // opp.Requested_Draw_Fee_Cap__c = 'None';
    // opp.Product_Sub_Type__c = 'Renovation';
    // opp.Interest_Rate_Type__c = 'Floating';
    // opp.Index__c = '1M LIBOR';
    // opp.Index_Floor__c = '1.00%';
    // opp.Index_Margin__c = 1.50;
    // opp.Deal_Intro_Source__c = 'Hotline';
    // opp.Deal_Intro_Sub_source__c = 'Main';
    // update opp;

    //Advance__c adv = new Advance__c(Deal__c = opp.Id);

    //insert adv;

    ContentVersion cv = new ContentVersion(
      Title = 'test.txt',
      PathOnClient = 'test.txt',
      VersionData = Blob.valueOf('test.txt'),
      Migrated_File__c = true,
      FirstPublishLocationId = acc.Id
    );

    insert cv;

    Test.startTest();
    Database.executeBatch(new FileMoveBatch());
    Test.stopTest();

    ContentVersion contentVersion = [
      SELECT Id, Linked_To_Record__c
      FROM ContentVersion
      WHERE Id = :cv.Id
      LIMIT 1
    ];
    system.assertEquals(true, contentVersion.Linked_To_Record__c);
    Deal_Document__c dealDoc = [
      SELECT Id
      FROM Deal_Document__c
      WHERE ContentVersion_Id__c = :cv.Id
      LIMIT 1
    ];
    system.assertNotEquals(dealDoc, null);
  }
}