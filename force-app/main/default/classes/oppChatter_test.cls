@istest
public class oppChatter_test {
@testsetup
static void datasetup() {
    test_Helper.createDealLoanNumber();
    List<Account> al = new List<Account>();
    Account a0 = new Account();
    a0.Name = 'Berkadia Commercial Mortgage';
    a0.BillingCountry = 'United States';
    a0.BillingState = 'California';
    a0.Introductions_Source__c = 'Hotline';
    a0.Introduction_Subsource__c = 'Main';
    a0.Alternate_Phone__c = '5555555555';
    al.add(a0);
    insert al;
    List<Contact> cl = new List<Contact>();
    Contact c0 = new Contact();
    c0.FirstName = 'test';
    c0.LastName = 'test';
    c0.MailingCountry = 'United States';
    c0.MailingState = 'California';
    c0.AccountId = al[0].Id;
    c0.MobilePhone = '5555555555';
    c0.Phone = '7777777777';
    c0.Experian__c = 700;
    c0.TransUnion__c = 710;
    c0.Equifax__c = 700;
    c0.Years_of_Experience__c = 10;
    c0.Rental_Units_Owned__c = '5';
    c0.Sponsor_Tier__c = 'Tier 1';
    c0.Experience__c = 5;
    cl.add(c0);
    Opportunity opp0 = new Opportunity();
    opp0.Name = 'TERM TEST 0';
    opp0.CloseDate = System.today();
    opp0.Rate_Locked__c = false;
    opp0.Term_Loan_Type__c = '5 Year';
    opp0.StageName = 'Initial Review';
    opp0.Loan_Size__c = 2000000;
    opp0.AccountId = al[0].Id;
    opp0.Contact__c = cl[0].Id;
    opp0.Final_Loan_Amount__c = 100;
    opp0.Final_Swap__c = 1.7;
    opp0.Final_Spread__c = 1.1;
    opp0.Apex_Context__c = true;
    opp0.Loan_Effective_Date__c = date.today();
    Id id1 = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
    ]
    .Id;
    opp0.RecordTypeId = id1;

///////////////////////////////////////////////

    List<Opportunity> oppLst = new List<Opportunity>();
    oppLst.add(opp0);
    insert oppLst;

	Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
	req.setObjectId(oppLst[0].Id);
    req.setSkipEntryCriteria(true);
    Approval.ProcessResult result = Approval.process(req);
    
 	ProcessInstanceWorkItem piw = [SELECT ProcessInstance.TargetObjectId FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :oppLst[0].Id LIMIT 1];
            
    Custom_Chatter_Mapping__c record=new Custom_Chatter_Mapping__c(
        Parent_Id__c=oppLst[0].Id,
        Deal__c=piw.ProcessInstance.TargetObjectId
    );
    insert record;

    FeedItem newFI 		= new FeedItem();
    newFI.Type			= 'TextPost';
    newFI.NetworkScope 	= 'AllNetworks';
    newFI.Visibility 	= 'AllUsers';
    newFI.Body 			= 'Testing';
    newFI.IsRichText 	=  false;
    newFI.ParentId 		= record.Id;
    Insert newFI;    
    
    FeedComment newFIc = new FeedComment();
    newFIc.CommentType		=	'TextComment';
    newFIc.FeedItemId		=	newFI.id;	
    newFIc.CommentBody		=	'Comment Test';
    newFIc.IsRichText		=	false;
    newFI.Status			=	'Published';
    insert newFIc;
    
    System.debug(
      '2.RS 999 Number of Queries used in this apex code so far: ' +
      Limits.getQueries()
    );
  }

public static testMethod void unitTest1() {
    Test.startTest();
     List<FeedItem> fI = [SELECT id,body from  FeedItem];
    System.debug('RS 999 fI :' +fI); 
     List<FeedComment> FIc = [SELECT id,CommentBody from  FeedComment];
    System.debug('RS 999 FIc :' +FIc);    
     fI[0].body = 'test12';
    update fI;
    FIc[0].CommentBody = 'Comment Test 123';
    update FIc;
    delete FIc[0];
    delete FI[0];
    
    Test.stopTest();
  }    
    
}