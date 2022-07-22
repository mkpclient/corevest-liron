@IsTest
private class PostClosingTests {
  // public static Opportunity setupDeal(){
  //     return null
  // }
 
  public static testMethod void UTOppInsert() {
    test_Helper.setUpProduct2();
    test_Helper.createDealLoanNumber();
    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
    Opportunity opp = test_Helper.createOpportunity(acc, cont);
    opp.Apex_Context__c = true;
    opp.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'LOC_Loan'
    ]
    .Id;
    opp.StageName = 'Hold';
    opp.Draw_Period__c = '12 Months';
    opp.Repayment_Period__c = '9 Months';
    opp.LOC_Loan_Type__c = 'Credit Line';
    opp.Loan_Size__c = 3000000;
    opp.Line_Expiration__c = '18 Months';
    opp.Requested_LTC_Max__c = 70;
    opp.Requested_LTV_Max__c = 80;
    opp.Requested_Origination_Fee__c = 0;
    opp.Requested_Draw_Fee__c = 2;
    opp.Requested_Exit_Fee__c = 0;
    opp.Requested_Interest_Type__c = 'Fixed';
    opp.Requested_Rate_1_9_Months__c = 10;
    opp.Requested_Revolving__c = 'Yes';
    opp.Requested_Draw_Fee_Cap__c = 'None';
    opp.Product_Sub_Type__c = 'Renovation';
    opp.Interest_Rate_Type__c = 'Floating';
    opp.Index__c = '1M LIBOR';
    opp.Index_Floor__c = '1.00%';
    opp.Index_Margin__c = 1.50;
    opp.Deal_Intro_Source__c = 'Hotline';
    opp.Deal_Intro_Sub_source__c = 'Main';
    update opp;

    List<Property__c> property = new List<Property__c>();
    for (Integer i = 0; i < 20; i++) {
      property.add(
        new Property__c(
          Name = 'Test + ' + i,
          Appraised_Value_Amount__c = 5,
          Acquisition_Price__c = 5,
          Property_Name__c = 'Test + ' + i,
          Deal__c = opp.Id,
          Escrow_Company_text__c = 'ESCROW',
          Insurance_Company_text__c = 'INSURANCE',
          Status__c = 'Pending',
          RecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE
              sobjecttype = 'Property__c'
              AND DeveloperName = 'Bridge_No_Renovation'
          ]
          .Id
        )
      );
    }

    property[0].Status__c = 'Due Diligence';
    property[1].Status__c = 'Active';
    property[2].Payoff_Received_Date__c = system.today();
    insert property;
    Test.startTest();
    Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([
        SELECT Id, Record_Type_Name__c,Deal_Loan_Number__c
        FROM Opportunity
    ]);
    PostClosingHelper.createPostClose(oppMap);
    PostClosingHelper.createPostClosingItems(
        oppMap,
      new Map<Id, sObject>(),
      'Opportunity',
      'afterInsert'
    );
    List<Advance__c> advances = new List<Advance__c>();

    for (Integer i = 0; i < property.size(); i++) {
      advances.add(new Advance__c(Deal__c = opp.Id));
    }

    insert advances;
    List<Property_Advance__c> pAdvs = new List<Property_Advance__c>();
    for (Integer j = 0; j < property.size(); j++) {
      pAdvs.add(new Property_Advance__c(Property__c = property[j].Id, Advance__c = advances[j].Id));
    }

    insert pAdvs;

    Post_Closing_Item__c pci = [
      SELECT Id, mdt_id__c
      FROM Post_Closing_Item__c
      LIMIT 1
    ];
    System.debug(pci);
    ContentVersion contentVersion = new ContentVersion(
      Title = 'Test',
      PathOnClient = 'test.pdf',
      VersionData = Blob.valueOf('Test Content'),
      IsMajorVersion = true
    );
    insert contentVersion;

    List<ContentDocument> documents = [
      SELECT Id, Title, LatestPublishedVersionId
      FROM ContentDocument
    ];

    ContentDocumentLink cdl = new ContentDocumentLink();
    cdl.LinkedEntityId = opp.Id;
    cdl.ContentDocumentId = documents[0].Id;
    cdl.ShareType = 'V';
    cdl.Visibility = 'AllUsers';
    insert cdl;
    

    PostClosingHelper.createDealDocs(
      advances[0].Id,
      new List<String>{documents[0].Id},
      pci.mdt_id__c,
      pci.id,
      'Advance__c'
    );
    test.stopTest();
  }
}