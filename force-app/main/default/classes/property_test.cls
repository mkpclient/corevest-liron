@istest
public class property_test {
  @testsetup
  static void datasetup() {
    //Account acc = test_Helper.createAccount();
    test_Helper.createDealLoanNumber();
    Account acc = new Account();
    acc.Name = 'test';
    acc.BillingCountry = 'United States';
    acc.BillingState = 'California';
    acc.Introductions_Source__c = 'Hotline';
    acc.Introduction_Subsource__c = 'Main';
    acc.Alternate_Phone__c = '5555555555';
    insert acc;
    System.debug(
      '1.Number of Queries used in this apex code so far: ' +
      Limits.getQueries()
    );
    Contact cont = test_Helper.createContact(acc);
    System.debug(
      '2.Number of Queries used in this apex code so far: ' +
      Limits.getQueries()
    );
    //Opportunity opp = test_Helper.createOpportunity(acc, cont);
    Opportunity opp = new Opportunity();
    opp.Name = 'test';
    opp.CloseDate = System.today() + 10;
    opp.StageName = 'Initial Review';
    opp.Loan_Size__c = 2000000;
    opp.AccountId = acc.Id;
    opp.Contact__c = cont.Id;
    opp.Deal_Intro_Source__c = 'Hotline';
    opp.Deal_Intro_Sub_Source__c = 'Main';
    opp.Apex_Context__c = true;
    opp.Commission_Type__c = 'Internal';
    opp.LOC_Loan_Type__c = 'Multifamily/CRE';
    opp.Project_Strategy__c = 'Multifamily Heavy Lift/CLO';
    //opp.Deal_Loan_Number__c = 'test';
    opp.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
    ]
    .Id;
    insert opp;
    System.debug(
      '3.Number of Queries used in this apex code so far: ' +
      Limits.getQueries()
    );
    //  List<Property__c> properties = test_Helper.createProperties(opp);

    id propRecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'property__c' AND DeveloperName = 'Bridge_Renovation'
    ]
    .Id;
    List<Property__c> properties = new List<Property__c>();
    for (Integer i = 0; i < 5; i++) {
      properties.add(
        new Property__c(
          Deal__c = opp.Id,
          Name = i + ' Test',
          Property_Name__c = i + ' Test',
          Property_Type__c = 'SFR',
          Number_of_Units__c = 1,
          Interior_Access_POC_Email__c = 'test@test.com',
          Security_Deposit__c = 800,
          Status__c = 'Active',
          BlackSquare_Fee__c = null,
          Yardi_Id__c = '123456789',
          RecordTypeId = propRecordTypeId
        )
      );
    }
    System.debug(
      '4.Number of Queries used in this apex code so far: ' +
      Limits.getQueries()
    );
    for (Integer i = 0; i < 5; i++) {
      properties.add(
        new Property__c(
          Deal__c = opp.Id,
          Name = i + ' Test',
          Property_Name__c = i + ' Test',
          Property_Type__c = 'SFR',
          Current_UPB__c = 1000,
          Number_of_Units__c = 1,
          Interior_Access_POC_Email__c = 'test@test.com',
          Security_Deposit__c = 800,
          Status__c = 'Active',
          BlackSquare_Fee__c = null,
          Title_Company_text__c = 'Test',
          Parent_Property__c = properties[0].id,
          RecordTypeId = propRecordTypeId
        )
      );
    }

    insert properties;
    System.debug(
      '5.Number of Queries used in this apex code so far: ' +
      Limits.getQueries()
    );
  }

  public static testMethod void UnitTest1() {
    List<Property__c> properties = [
      SELECT
        id,
        deal__c,
        Acquisition_Date__c,
        Status__c,
        Yardi_Id__c,
        Active__c,
        State__c,
        Interest_Rate__c
      FROM Property__c
    ];
    System.debug(
      '6.Number of Queries used in this apex code so far: ' +
      Limits.getQueries()
    );
    List<opportunity> oppor = [SELECT id, name FROM Opportunity];
    // Map<id,Opportunity> opp = new Map<id,Opportunity>([select id,name from Opportunity]);
    Set<id> propset = new Set<id>{ properties[0].id };
    Set<id> deleteSet = new Set<Id> { properties[1].id };
    Map<String, List<Property__c>> vendorMap = new Map<String, List<Property__c>>{
      'test' => properties
    };
    Map<Id, List<Property__c>> dealMap = new Map<Id, List<Property__c>>{
      oppor[0].id => properties
    };
    String vendorType = 'Escrow';

    //  property_Helper.getYardiIds(dealMap);

    Map<Id, String> refinanceBubble = new Map<Id, String>{
      properties[0].id => 'test'
    };
    ////refinanceBubble.add(properties[0].id,'test');
    property_Helper.standardizeYesNoData('yes');
    property_Helper.standardizePropertyState('iowa');
    Test.startTest();
    property_Helper.inheritRefinance(refinanceBubble);
    property_Helper.rollupDelete(deleteSet);
    property_Helper.rollupParents(propSet);
    property_Helper.attachVendors(vendorMap, vendorType);

    properties[0].State__c = 'CA';
    properties[0].Interest_Rate__c = .22;

    update properties[0];

    Test.stopTest();
  }

  public static testMethod void UnitTest2() {
    List<Property__c> properties = [
      SELECT
        id,
        deal__c,
        Acquisition_Date__c,
        Status__c,
        Yardi_Id__c,
        Active__c,
        State__c,
        Interest_Rate__c
      FROM Property__c
    ];
    properties[5].Status__c = 'Due Diligence';

    properties[6].Status__c = 'Closing';
    properties[6].Current_UPB__c = 2000;

    Test.startTest();

    update new List<Property__c>{properties[5], properties[6]};

    // properties[6].Status__c = 'Active';
    // properties[6].Current_UPB__c = 2000;
    // update properties[6];

    delete properties[4];
    Test.stopTest();
  }

  public static testMethod void UnitTest3() {
    Map<Id, Opportunity> dealMap = new Map<Id, Opportunity>(
      [
        SELECT
          Id,
          Distinct_States__c,
          Distinct_States_Full__c,
          Distinct_Property_Types__c,
          Distinct_MSAs__c,
          Distinct_Counties__c,
          Sum_of_Borrower_Estimated_Value__c,
          Annual_HOA__c,
          Average_Acquisition_Date_By_Property__c,
          Total_Units__c,
          Total_Properties__c,
          Apex_Context__c,
          Refinance_Property_Count__c,
          Acquisition_Property_Count__c, //CIP-2286.RS.7/21/22.Begin.
          Deal_Loan_Number__c,
          Loan_Purpose__c,
          Borrower_Entity__c,
          Extension_Fee__c,
          Exit_Fee__c,
          Interest_Rate_Type__c,
          Index__c,
          Total_ARV_LTV__c,
          Recourse__c,
          Current_Line_Maturity_Date__c,
          Amortization_Term__c,
          Project_Strategy__c,
          LOC_Commitment__c,
          CloseDate,
          Floor__c,
          Name //CIP-2286.RS.7/21/22.End.
        FROM Opportunity
      ]
    );

    property_Helper.sumRehab(dealMap);
    List<String> singleList = new List<String>{
      'Condo',
      'Other',
      'SFR',
      'Townhome'
      //, 'Parent'
    };
    List<String> multiList = new List<String>{
      '2-4 Unit',
      'Multifamily',
      'Duplex',
      'Triplex',
      'Fourplex',
      '5+ Units',
      'Mixed Use'
    };

    Map<Id, String> propTypeCounts = property_Helper.findPropertyType(
      singleList,
      multiList,
      dealMap.keySet()
    );
  }

  public static testMethod void UnitTest4() {
    Map<Id, Opportunity> dealMap = new Map<Id, Opportunity>(
      [
        SELECT
          Id,
          Distinct_States__c,
          Distinct_States_Full__c,
          Distinct_Property_Types__c,
          Distinct_MSAs__c,
          Distinct_Counties__c,
          Sum_of_Borrower_Estimated_Value__c,
          Annual_HOA__c,
          Average_Acquisition_Date_By_Property__c,
          Total_Units__c,
          Total_Properties__c,
          Apex_Context__c,
          Refinance_Property_Count__c,
          Acquisition_Property_Count__c, //CIP-2286.RS.7/21/22.Begin.
          Deal_Loan_Number__c,
          Loan_Purpose__c,
          Borrower_Entity__c,
          Extension_Fee__c,
          Exit_Fee__c,
          Interest_Rate_Type__c,
          Index__c,
          Total_ARV_LTV__c,
          Recourse__c,
          Current_Line_Maturity_Date__c,
          Amortization_Term__c,
          Project_Strategy__c,
          LOC_Commitment__c,
          CloseDate,
          Floor__c,
          Name //CIP-2286.RS.7/21/22.End.
        FROM Opportunity
      ]
    );

    property_Helper.sendDataTapeNotification(dealMap.values()[0].Id);

  }
}