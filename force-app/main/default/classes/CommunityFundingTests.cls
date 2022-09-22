@isTest
public with sharing class CommunityFundingTests {
  @testSetup
  static void setup() {
      

test_Helper.createDealLoanNumber();
    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
    Opportunity opp = test_Helper.createBridgeDeal(acc, cont);
    opp.StageName = 'Underwriting';
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
          Property_Type__c = 'SFR',
          Number_of_Units__c = 1,
          RecordTypeId = recordTypeId
        )
      );
    }

    property[0].Status__c = 'Due Diligence';
    property[1].Status__c = 'Active';
    property[2].Payoff_Received_Date__c = system.today();
    property[0].Refinance_Acquisition__c = 'Refinance';
    insert property;
  }

  @IsTest
  static void insertTests() {
    Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
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
          Deal__c = oppId,
          Escrow_Company_text__c = 'ESCROW',
          Insurance_Company_text__c = 'INSURANCE',
          Status__c = 'Pending',
          Property_Type__c = 'SFR',
          Number_of_Units__c = 1,
          RecordTypeId = recordTypeId
        )
      );
    }

    property[0].Status__c = 'Active';
    property[0].Refinance_Acquisition__c = 'Refinance';
    property[1].Status__c = 'Active';
    property[2].Payoff_Received_Date__c = system.today();
    Test.startTest();
    try {
      CommunityFundingController.insertProperties(
        oppId,
        JSON.serialize(property)
      );
    } catch (Exception ex) {
    }
    Test.stopTest();
  }

  @isTest
  static void initTest() {
    List<Property__c> props = [
      SELECT Id, Refinance_Acquisition__c
      FROM Property__c
      WHERE Refinance_Acquisition__c = 'Refinance'
      LIMIT 1
    ];
    // if (props != null && !props.isEmpty()) {
    //   props[0].Refinance_Acquisition__c = 'Refinance';
    //   update props[0];
    // }
    test.startTest();

    Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];
    CommunityFundingController.getFundingsInProcess(o.Id);
    CommunityFundingController.getFundingsInProcess('');
    CommunityFundingController.getLOCChartData(o.Id);
    CommunityFundingController.getClosedFundings(o.Id);
    CommunityFundingController.getLoanFundings(o.Id);
    CommunityFundingController.getLOCChartData(null);
    CommunityFundingController.getClosedFundings(null);
    CommunityFundingController.getLoanFundings(null);
    CommunityFundingController.initMatrixScreen(props[0].Id);
    CommunityFundingController.updateRecord(o);
    test.stopTest();
  }
}