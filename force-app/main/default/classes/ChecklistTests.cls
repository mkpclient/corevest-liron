@isTest
private class ChecklistTests {
  static testMethod void test1() {
    Test_Helper.createDealLoanNumber();

    RecordType vendorRecordType = [
      SELECT Id
      FROM RecordType
      WHERE DeveloperName LIKE '%vendor%'
      LIMIT 1
    ];
    account vendor = new account();
    vendor.name = 'test acc rec';
    vendor.phone = '1234567890';
    vendor.Alternate_Phone__c = '1234567890';
    vendor.Do_Not_Lend__c = false;
    vendor.recordTypeId = vendorRecordType.Id;
    vendor.Non_Borrower_Account_Type__c = 'Title and Escrow';

    insert vendor;

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
    opp.Maturity_Date_Calculation_Type__c = 'Fixed at Closing';
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
    Id recordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE
        sobjecttype = 'Property__c'
        AND DeveloperName = 'Bridge_No_Renovation'
    ]
    .Id;
    for (Integer i = 0; i < 20; i++) {
      property.add(
        new Property__c(
          Name = 'Test + ' + i,
          Property_Name__c = 'Test + ' + i,
          Deal__c = opp.Id,
          Escrow_Company_text__c = 'ESCROW',
          Insurance_Company_text__c = 'INSURANCE',
          Status__c = 'Pending',
          RecordTypeId = recordTypeId,
          Title_Company__c = vendor.Id
        )
      );
    }

    property[0].Status__c = 'Due Diligence';
    property[1].Status__c = 'Active';
    property[2].Payoff_Received_Date__c = system.today();
    insert property;
    Test.startTest();
    ChecklistController.init(opp.Id, 'Opportunity');
    Checklist_Section__c section = [
      SELECT Id
      FROM checklist_section__c
      LIMIT 1
    ];
    Checklist_Item__c item = [
      SELECT Id, Checklist_Section__c
      FROM Checklist_Item__c
      LIMIT 1
    ];

    ChecklistController.queryDocumentTypes(section.Id);
    ChecklistController.getComments(item.Id);
    ChecklistController.approveItems(new List<Id>{ item.Id });
    ChecklistController.upsertItem(item, 'Test');
    ChecklistController.upsertItems(new List<Checklist_Item__c>{ item });

    ContentVersion cv = new ContentVersion(
      Title = 'test.txt',
      PathOnClient = 'test.txt',
      VersionData = Blob.valueOf('test.txt'),
      Uploaded_From_Portal_Id__c = 'af-sdba'
    );

    insert cv;

    ChecklistController.handleUpload(item.Id, new List<Id>{ cv.Id });
    ChecklistController.getMilestoneList(opp.Id);
    ChecklistController.deleteItem(item.Id);
    item.Id = null;
    ChecklistController.insertItems(
      new List<Checklist_Item__c>{ item },
      'upload'
    );

    Deal_Document__c dealDoc = [SELECT Id FROM Deal_Document__C LIMIT 1];
    dealDoc.Status__c = 'Approved';
    update dealDoc;
    dealDoc.Status__c = 'Not Reviewed';
    update dealDoc;
    dealDoc.Status__c = 'Rejected';
    dealDoc.File_Name__c = 'test11';
    update dealDoc;
    Test.stopTest();
  }

  static testMethod void test2() {
    Test_Helper.createDealLoanNumber();

    RecordType lender = [
      SELECT Id
      FROM RecordType
      WHERE DeveloperName LIKE 'lender' AND SobjectType = 'account'
      LIMIT 1
    ];
    account vendor = new account();
    vendor.name = 'test acc rec';
    vendor.phone = '1234567890';
    vendor.Alternate_Phone__c = '1234567890';
    vendor.Do_Not_Lend__c = false;
    vendor.recordTypeId = lender.Id;
    vendor.Non_Borrower_Account_Type__c = 'Title and Escrow';

    insert vendor;

    // ChecklistHelper.c
  }
}