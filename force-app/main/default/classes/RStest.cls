@isTest
public class RStest {
 @TestSetup
  static void dataSetup() {
    Account acc = test_Helper.createAccount();
  //  acc.Alternate_Phone__c = '7777777777';
   // update acc;
      
    Contact cont = test_Helper.createContact(acc);
  //  cont.MobilePhone = '2222222222';
  //  cont.Phone = '9999999999';

    Opportunity topp1 = new Opportunity();
    topp1.Name = 'TERM TEST 123';
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
    insert topp1;
  }    
static testMethod void opportunity_UnitTest5() {
    /*Account a = new Account();
    a.Name = 'Alston & Bird';
    a.BillingCountry = 'United States';
    a.BillingState = 'California';
    a.Introductions_Source__c = 'Hotline';
    a.Introduction_Subsource__c = 'Main';
    a.Alternate_Phone__c = '55555555355';
    insert a;*/
System.debug('RS999 - 1 Number of Queries used in this apex code so far: ' + Limits.getQueries());
    Account acc = [SELECT Id FROM Account ORDER BY CreatedDate DESC LIMIT 1];
    Contact cont = [SELECT Id FROM Contact ORDER BY CreatedDate DESC LIMIT 1];
    //cont.AccountId = acc.Id;
   // update cont;
System.debug('RS999 - 2 Number of Queries used in this apex code so far: ' + Limits.getQueries());
    Opportunity opp = new Opportunity();
    opp.Name = 'test';
    opp.CloseDate = System.today();
    opp.StageName = 'Initial Review';
    opp.Loan_Size__c = 2000000;
    opp.AccountId = acc.Id;
    opp.Contact__c = cont.Id;
    opp.Final_Loan_Amount__c = 1000000;
    opp.Deal_Intro_Source__c = 'Hotline';
    opp.Deal_Intro_Sub_Source__c = 'Main';
    opp.Apex_Context__c = true;
    opp.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
    ]
    .Id;
    opp.GLC_Approved__c = true;
    opp.Background_Check_Completed__c = true;
    insert opp;
System.debug('RS999 - 3 Number of Queries used in this apex code so far: ' + Limits.getQueries());
    insert new deal_contact__c(
      deal__c = opp.Id,
      Contact__c = cont.Id,
      entity_type__c = 'Sponsor',
      Account__c = acc.id
    );
System.debug('RS999 - 4 Number of Queries used in this apex code so far: ' + Limits.getQueries());
    Deal_Document__c doc = new Deal_Document__c(
      Deal__c = opp.Id,
      Document_Loaded__c = true,
      Is_Deleted__c = false
    );

    insert doc;
System.debug('RS999 - 5 Number of Queries used in this apex code so far: ' + Limits.getQueries());
    Document_Information__c docInfo = new Document_Information__c(
      Deal__c = opp.Id,
      Doc_String__c = 'Loan Document;Title Policies|Miscellaneous'
    );

    Test.startTest();
    insert docInfo;
System.debug('RS999 - 6 Number of Queries used in this apex code so far: ' + Limits.getQueries());
    Opportunity opp2 = new Opportunity();
    opp2.Name = 'test';
    opp2.id = opp.id;
    opp2.CloseDate = System.today();
    opp2.Final_Spread__c = 2;
    opp2.Final_Swap__c = 2;
    opp2.StageName = 'Closed Won';
    opp2.Type = 'Term Loan';
    opp2.Loan_Size__c = 2000000;
    opp2.AccountId = acc.Id;
    opp2.Contact__c = cont.Id;
    opp2.Final_Loan_Amount__c = 100;
    opp2.Deal_Intro_Source__c = 'Hotline';
    opp2.Deal_Intro_Sub_Source__c = 'Main';
    opp2.Apex_Context__c = true;
    opp2.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
    ]
    .Id;
    opp2.GLC_Approved__c = false;
    opp2.Background_Check_Completed__c = false;

    update opp2;
System.debug('RS999 - 7 Number of Queries used in this apex code so far: ' + Limits.getQueries());
    Map<Id, Opportunity> newMap = new Map<Id, Opportunity>();
    newMap.put(opp2.id, opp2);
    opportunity_Helper.attachDealContactIFClosedWON(newMap);

    Property__c prop = new Property__c();
    prop.Property_Type__c = 'SFR';
    prop.Deal__c = opp.Id;
    prop.Calc_AveValue__c = 100000;
    prop.Name = 'test';
    prop.Property_Name__c = 'test Street';
    prop.City__c = 'test';
    prop.State__c = 'test';
    prop.ZipCode__c = 'test';
    insert prop;
System.debug('RS999 - 8 Number of Queries used in this apex code so far: ' + Limits.getQueries());
    opp.Commission_Type__c = 'Internal';
    update opp;
System.debug('RS999 - 9 Number of Queries used in this apex code so far: ' + Limits.getQueries());
    opp.Term_Loan_Type__c = '5 Year';
    opp.YM_Prepayment_Penalty__c = '48 Months';
    update opp;
System.debug('RS999 - 10 Number of Queries used in this apex code so far: ' + Limits.getQueries());
    opp.Term_Loan_Type__c = '10 Year';
    opp.YM_Prepayment_Penalty__c = '114 Months';
    update opp;
System.debug('RS999 - 11 Number of Queries used in this apex code so far: ' + Limits.getQueries());
    List<String> docIds = new List<String>();
    docIds.add(doc.id);

    opportunity_Helper.getFiles(opp.id, docInfo.id);
    opportunity_Helper.reviewDocuments(docIds);
    Test.stopTest();

    Map<Id, Opportunity> newoppmap = new Map<Id, Opportunity>();
    Map<Id, Opportunity> oldoppmap = new Map<Id, Opportunity>();

    /*newoppmap.put(opp.id,opp);
        oldoppmap.put(opp2.id,opp2);
        
        opportunity_Helper.beforeUpdate(newoppmap,oldoppmap); */
  }
}