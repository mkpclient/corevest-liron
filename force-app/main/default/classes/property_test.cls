@istest
public class property_test {
  @testsetup
  static void datasetup() {
	//Account acc = test_Helper.createAccount();
    Account acc = new Account();
    acc.Name = 'test';
    acc.BillingCountry = 'United States';
    acc.BillingState = 'California';
    acc.Introductions_Source__c = 'Hotline';
    acc.Introduction_Subsource__c = 'Main';
    acc.Alternate_Phone__c = '5555555555';
    insert acc;
      
    Contact cont = test_Helper.createContact(acc);
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
    //opp.Deal_Loan_Number__c = 'test';
    opp.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
    ]
    .Id;
    insert opp;
      
  //  List<Property__c> properties = test_Helper.createProperties(opp);

    id propRecordTypeId = [ SELECT Id FROM RecordType WHERE sobjecttype = 'property__c' AND DeveloperName = 'Bridge_Renovation'].Id;
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
insert properties;
List<Property__c> properties1 = new List<Property__c>();      
	for (Integer i = 0; i < 5; i++) {
      properties1.add(
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
          Title_Company_text__c = 'Test',
          Parent_Property__c= properties[0].id,
          RecordTypeId = propRecordTypeId            
        )
      );
    }      

    insert properties1;      
      
  }


  public static testMethod void UnitTest1() {
    List<Property__c> properties = [select id,deal__c,Acquisition_Date__c,Status__c ,Yardi_Id__c,Active__c,State__c,Interest_Rate__c from Property__c];
    List<opportunity> oppor = [select id,name from Opportunity];
    //Map<id,Opportunity> opp = new Map<id,Opportunity>([select id,name from Opportunity]);
    Set<id> propset = new Set<id>{properties[0].id};
    Map<String, List<Property__c>> vendorMap = new Map<String, List<Property__c>>{'test' => properties};
    Map<Id, List<Property__c>> dealMap = new Map<Id, List<Property__c>>{oppor[0].id => properties};        
    String vendorType = 'Escrow';
      
    Test.startTest();
     
  //  property_Helper.getYardiIds(dealMap);
    
    
      
    
      Map<Id, String> refinanceBubble = new Map<Id, String>{properties[0].id => 'test'};
      ////refinanceBubble.add(properties[0].id,'test');
	property_Helper.standardizeYesNoData('yes');
    property_Helper.inheritRefinance(refinanceBubble);
    property_Helper.rollupDelete(propset);
    property_Helper.rollupParents(propset);
    property_Helper.attachVendors(vendorMap,vendorType);

   

    
	Test.stopTest();      
  }

public static testMethod void UnitTest2() {
    List<Property__c> properties = [select id,deal__c,Acquisition_Date__c,Status__c ,Yardi_Id__c,Active__c,State__c,Interest_Rate__c from Property__c];
    Test.startTest();

    properties[0].State__c = 'CA';
    properties[0].Interest_Rate__c = .22;
     
    update properties[0];
    
    properties[5].Status__c='Due Diligence';   
    update properties[5];
      
 	properties[6].Status__c='Closing';   
    update properties[6];
     
	Test.stopTest();      
  }    

}