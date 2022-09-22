@isTest
private class YardiTests {
  static testMethod void locTest() {
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

    opp.StageName = 'Data Tape Received';
    update opp;
    Advance__c adv = new Advance__c(Deal__c = opp.Id);
    adv.Status__c = 'Completed';
    adv.Wire_Date__c = system.today();
    adv.Origination_Fee_Adjustment__c = 100;
    adv.BlackSquare_Fee_Adjustment__c = 100;
    adv.BPO_Appraisal_Fee_Adjustment__c = 100;
    adv.Doc_Prep_Fee_Adjustment__c = 100;
    adv.Daily_Interest_Rate_Adjustment__c = 100;
    Test.startTest();

    // adv.Broker_Fee_Paid_When__c = 'Origination';

    insert adv;
    List<Property_Advance__c> padv = new List<Property_Advance__c>{
      new Property_Advance__c(
        Property__c = property[0].Id,
        Advance__c = adv.Id,
        BPO_Appraisal_Fee__c = 100,
        Advance_Fee__c = 100,
        Doc_Prep_Fee__c = 100,
        Broker_Advance_Fee__c = 100
      ),
      new Property_Advance__c(
        Property__c = property[1].Id,
        Advance__c = adv.Id
      ),
      new Property_Advance__c(Property__c = property[2].Id, Advance__c = adv.Id)
    };

    insert padv;

    padv[0].Advance_Fee__c = 1000;
    padv[0].Initial_Disbursement__c = 500000;
    padv[0].Renovation_Reserve__c = 500000;
    padv[0].Origination_Fee__c = 1000;
    padv[0].BPO_Appraisal_Fee__c = 100;
    padv[0].Advance_Fee__c = 100;
    padv[0].Doc_Prep_Fee__c = 100;
    padv[0].Broker_Advance_Fee__c = 100;

    padv[1].Advance_Fee__c = 1000;
    padv[1].Initial_Disbursement__c = 500000;
    padv[1].Renovation_Reserve__c = 500000;
    padv[1].Origination_Fee__c = 1000;

    padv[2].Advance_Fee__c = 1000;
    padv[2].Initial_Disbursement__c = 500000;
    padv[2].Renovation_Reserve__c = 500000;
    padv[2].Origination_Fee__c = 1000;

    update padv;

    system.enqueueJob(new YardiQueueable('advanceXML', new List<Id>{ adv.Id }));
    system.enqueueJob(
      new YardiQueueable(
        'propertyCSV',
        new List<Id>{ property[0].Id, property[1].Id, property[2].Id }
      )
    );
    Test.stopTest();
  }

  static testMethod void termTest() {
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
    Opportunity topp1 = new Opportunity();
    topp1.Name = 'test';
    topp1.CloseDate = System.today();
    topp1.StageName = 'Initial Review';
    topp1.Loan_Size__c = 2000000;
    topp1.AccountId = acc.Id;
    topp1.Contact__c = cont.Id;
    topp1.Final_Loan_Amount__c = 100;
    topp1.Deal_Intro_Source__c = 'Hotline';
    topp1.Deal_Intro_Sub_Source__c = 'Main';
    topp1.Apex_Context__c = true;
    topp1.Term_Loan_Type__c = '5 Year';
    topp1.YM_Prepayment_Penalty__c = '48 Months';
    topp1.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
    ]
    .Id;
    topp1.Title__c = vendor.Id;
    topp1.Third_Party_Title__c = vendor.Id;
    insert topp1;

    Test.startTest();
    system.enqueueJob(new YardiQueueable('termXML', new List<Id>{ topp1.Id }));
    system.enqueueJob(new YardiQueueable('termCSV', new List<Id>{ topp1.Id }));

    try {
      String str;
      str.split(';');

      // if()
    } catch (Exception e) {
      HttpRequest req = new HttpRequest();
      req.setEndpoint('https://google.com');
      System.enqueueJob(
        new APILoggerQueueable(req, new HttpResponse(), topp1.Id, e)
      );
    }

    Test.stopTest();
  }

  static testMethod void emailTests() {
    Test_Helper.createDealLoanNumber();

    List<RecordType> opptyRecordTypes = [
      SELECT Id
      FROM RecordType
      WHERE sObjectType = 'Opportunity'
    ];

    Id termLoanRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
      .get('Term Loan')
      .getRecordTypeId();
    Id bridgeLoanRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
      .get('Bridge Loan')
      .getRecordTypeId();

    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
    Opportunity opp = test_Helper.createOpportunity(acc, cont);
    opp.RecordTypeId = opptyRecordTypes[0].Id;
    opp.Loan_Effective_Date__c = system.today();
    opp.StageName = 'Approved by Committee';
    update opp;

    Attachment a = new Attachment(
      Name = 'Test',
      ParentId = opp.Id,
      Body = blob.valueOf('test')
    );

    Test.startTest();
    ContentVersion cv = new ContentVersion();
    cv.PathOnClient = '/';
    cv.VersionData = blob.valueOf('test');
    YardiEmailSubmissionController.constructFileAttachment(cv);
    YardiEmailSubmissionController.Person person = new YardiEmailSubmissionController.Person()
      .CurrentUser();
    YardiEmailSubmissionController.returnDeal(opp.Id);
    List<EmailTemplate> e = YardiEmailSubmissionController.queryEmailTemplate(
      'Send_to_Accounting'
    );
    Map<String, String> m = new Map<String, String>();
    m.put('recipients', 'test@test.com');
    m.put('cc', 'test@test.com');
    m.put('whatId', opp.Id);
    List<Id> aIds = new List<Id>();
    List<Id> cIds = new List<Id>();
    try {
      Messaging.reserveSingleEmailCapacity(2);
      YardiEmailSubmissionController.sendMail(
        new List<String>{ 'test@test.com' },
        'Subject',
        'html',
        new List<Messaging.EmailFileAttachment>(),
        new List<String>{ 'test@test.com' },
        'Test',
        null,
        null,
        null,
        null,
        null
      );

      YardiEmailSubmissionController.sendMail(
        new List<String>{ 'logins+cvest@mkpartners.com' },
        null,
        null,
        null,
        null,
        'MKP',
        false,
        false,
        cont.Id,
        e[0].Id,
        opp.Id
      );
      YardiEmailSubmissionController.sendEmail(
        JSON.serialize(m),
        JSON.serialize(cIds)
      );
    } catch (Exception exc) {
      System.debug(exc);
    }
    Test.stopTest();
  }
}