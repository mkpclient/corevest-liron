@isTest
public class DrawAdvanceProcessHandlerTest {
@testsetup
  static void datasetup() {
    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
    List<Opportunity> oppList = new List<Opportunity>();
    Opportunity opp = new Opportunity();
    Opportunity opp1 = new Opportunity();
    opp.Name = 'test';
    opp.CloseDate = System.today();
    opp.StageName = 'Initial Review';
    opp.Loan_Size__c = 2000000;
    opp.AccountId = acc.Id;
    opp.Contact__c = cont.Id;
    opp.Deal_Intro_Source__c = 'Hotline';
    opp.Deal_Intro_Sub_Source__c = 'Main';
    opp.Apex_Context__c = true;
    opp.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
    ]
    .Id;
    opp.Apex_Context__c = true;
    opp.StageName = 'Hold';
    //opp.Draw_Period__c = '12 Months';
    //opp.Repayment_Period__c = '9 Months';
    opp.LOC_Loan_Type__c = 'Credit Line';
    opp.Loan_Size__c = 3000000;
    opp.Maturity_Date_Calculation_Type__c = 'Fixed at Closing';
    //opp.Line_Expiration__c = '18 Months';
    opp.Requested_LTC_Max__c = 70;
    opp.Requested_LTV_Max__c = 80;
    opp.Requested_Origination_Fee__c = 0;
    opp.Requested_Draw_Fee__c = 2;
    opp.Requested_Exit_Fee__c = 0;
    opp.Requested_Interest_Type__c = 'Fixed';
    opp.Requested_Rate_1_9_Months__c = 10;
    opp.Requested_Revolving__c = 'Yes';
    opp.Requested_Draw_Fee_Cap__c = 'None';
    opp.Product_Sub_Type__c = 'No Renovation';
    opp.Interest_Rate_Type__c = 'Floating';
    opp.Index__c = '1M LIBOR';
    opp.Commission_Type__c = 'Internal';
   // opp.Index_Floor__c = '1.00%';
    opp.Index_Margin__c = 1.50;
    opp.Deal_Intro_Source__c = 'Hotline';
    opp.Deal_Intro_Sub_source__c = 'Direct Mail';
    opp.Fee__c = 2;
    opp.Warehouse_Line__c = 'MS3';
      
    opp1.Name = 'test1';
    opp1.CloseDate = System.today();
    opp1.StageName = 'Initial Review';
    opp1.Loan_Size__c = 2000000;
    opp1.AccountId = acc.Id;
    opp1.Contact__c = cont.Id;
    opp1.Deal_Intro_Source__c = 'Hotline';
    opp1.Deal_Intro_Sub_Source__c = 'Main';
    opp1.Apex_Context__c = true;
    opp1.AccountId = acc.id;
    opp1.Contact__c = cont.id;
    opp1.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Acquired_Bridge_Loan'
    ]
    .Id;
    opp1.StageName = 'Loan Processing';
    //opp1.Draw_Period__c = '12 Months';
    //opp1.Repayment_Period__c = '9 Months';
    opp1.LOC_Loan_Type__c = 'Credit Line';
    opp1.Loan_Size__c = 3000000;
    opp1.Maturity_Date_Calculation_Type__c = 'Fixed at Closing';
    //opp1.Line_Expiration__c = '18 Months';
    opp1.Requested_LTC_Max__c = 70;
    opp1.Requested_LTV_Max__c = 80;
    opp1.Requested_Origination_Fee__c = 0;
    opp1.Requested_Draw_Fee__c = 2;
    opp1.Requested_Exit_Fee__c = 0;
    opp1.Requested_Interest_Type__c = 'Fixed';
    opp1.Requested_Rate_1_9_Months__c = 10;
    opp1.Requested_Revolving__c = 'Yes';
    opp1.Requested_Draw_Fee_Cap__c = 'None';
    opp1.Product_Sub_Type__c = 'No Renovation';
    opp1.Interest_Rate_Type__c = 'Floating';
    opp1.Index__c = '1M LIBOR';
    opp1.Warehouse_Line__c = 'MS3';
    opp1.Commission_Type__c = 'Internal';
    //opp1.Index_Floor__c = '1.00%';
    opp1.Index_Margin__c = 1.50;
    opp1.Deal_Intro_Source__c = 'Hotline';
    opp1.Deal_Intro_Sub_source__c = 'Direct Mail';
    opp1.Fee__c = 2;
    opp1.Aggregate_Funding__c = 55000000;
    opp1.Loan_Effective_Date__c = system.today().addDays(-3);
    opp1.CloseDate = system.today().addDays(-3);
    oppList.add(opp);
    oppList.add(opp1);
    insert oppList;
      
    property__c property = new Property__c();
    property.Name = 'Test1';
    property.Deal__c = oppList[0].Id;
    property.Escrow_Company_text__c = 'ESCROW';
    property.Insurance_Company_text__c = 'INSURANCE';
    property.Status__c = 'Closing';
    property.Override_Origination_Fee__c = 1000;
    property.Acquisition_Price__c = 600000;
    property.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE
        sobjecttype = 'Property__c'
        AND DeveloperName = 'Bridge_No_Renovation'
    ]
    .Id;
    insert property;
 	Advance__c adv = new Advance__c(Deal__c = opp1.Id);
    insert adv;      
      
  }
    
public static testMethod void DrawAdvanceProcessHandler_UnitTest1() {
    
    Test.startTest();
    List<opportunity> opp = [select id,Deal_Loan_Number__c from opportunity where Name = 'test'];
    List<opportunity> opp1 = [select id,Deal_Loan_Number__c from opportunity where Name = 'test1'];
    List<Advance__c> adv = [select Advance_Num__c from Advance__c where deal__c = :opp1[0].id];
    
      Messaging.InboundEmail email = new Messaging.InboundEmail() ;
      Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
       
      email.subject = 'Create Task';
      email.fromAddress = 'support@cvest.com';
      email.plainTextBody = 'Test Task Creation';
      
      String fileBody = 'Loan ID,Loan Name,MortgageLoan Initial Funded Amount,Origination Date,Monthly Debt Service,Interest Rate,Origination Date,First Payment Date,Initial Maturity Date,Borrower Name,Sponsor _name';
      fileBody = fileBody + '\r\n' + opp[0].Deal_Loan_Number__c + ',Test Loan1,"1,000",6/3/2022,1000,0.999,6/3/2022,3/9/2022,1/1/2000,Test Borrower1,Test Sponser Name 1';
      Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
      attachment.body = blob.valueOf(fileBody);
      attachment.fileName = 'Term.csv';
      attachment.mimeTypeSubType = 'text/plain';
      
      String fileBody1 = 'Loan ID,SF Asset ID,Loan Name,Address (Street),City,State,Zip,County,Advance #,,Loan ID,Loan Name,LOC Closing Date,LOC Commitment';
      fileBody1 = fileBody1 + '\r\n' + opp1[0].Deal_Loan_Number__c + ',123456,Testing Name,123 testing address,testing,ca,33209,test,' + adv[0].Advance_Num__c + ',,38553,LJ Phoenician Properties LLC,12/9/2021,1000';
      Messaging.InboundEmail.BinaryAttachment attachment1 = new Messaging.InboundEmail.BinaryAttachment();
      attachment1.body = blob.valueOf(fileBody1);
      attachment1.fileName = 'Bridge.csv';
      attachment1.mimeTypeSubType = 'text/plain';
      
      email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment,attachment1 };
      
 
      /*Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
      attachmenttext.body = 'Create Task';
      attachmenttext.fileName = 'Term.csv';
      attachmenttext.mimeTypeSubType = 'texttwo/plain';
      email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };*/
      
      
      // call the email service class and test it with the data in the testMethod
      DrawAdvanceProcessHandler testInbound = new DrawAdvanceProcessHandler();
      testInbound.handleInboundEmail(email, env);
    Test.stopTest();
  }
public static testMethod void DrawAdvanceProcessHandler_UnitTest2() {
    
    Test.startTest();
    List<opportunity> opp = [select id,Deal_Loan_Number__c from opportunity where Name = 'test'];
    List<opportunity> opp1 = [select id,Deal_Loan_Number__c from opportunity where Name = 'test1'];
    List<Advance__c> adv = [select Advance_Num__c from Advance__c where deal__c = :opp1[0].id];
    
      Messaging.InboundEmail email = new Messaging.InboundEmail() ;
      Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
       
      email.subject = 're:Create Task';
      email.fromAddress = 'support@cvest.com';
      email.plainTextBody = 'Test Task Creation';
      
      String fileBody = 'Load ID,Loan Name,MortgageLoan Initial Funded Amount,Origination Date,Monthly Debt Service,Interest Rate,Origination Date,First Payment Date,Initial Maturity Date,Borrower Name,Sponsor _name';
      fileBody = fileBody + '\r\n' + opp[0].Deal_Loan_Number__c + ',Test Loan1,1000,6/3/2022,1000,0.999,6/3/2022,3/9/2022,1/1/2000,Test Borrower1,Test Sponser Name 1';
      Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
      attachment.body = blob.valueOf(fileBody);
      attachment.fileName = 'Term.csv';
      attachment.mimeTypeSubType = 'text/plain';
      
      String fileBody1 = 'Loan ID,SF Asset ID,Loan Name,Address (Street),City,State,Zip,County,Advance #,,Loan ID,Loan Name,LOC Closing Date,LOC Commitment';
      fileBody1 = fileBody1 + '\r\n' + opp1[0].Deal_Loan_Number__c + ',123456,Testing Name,123 testing address,testing,ca,33209,test,' + adv[0].Advance_Num__c + ',,38553,LJ Phoenician Properties LLC,12/9/2021,1000';
      Messaging.InboundEmail.BinaryAttachment attachment1 = new Messaging.InboundEmail.BinaryAttachment();
      attachment1.body = blob.valueOf(fileBody1);
      attachment1.fileName = 'Bridge.csv';
      attachment1.mimeTypeSubType = 'text/plain';
      
      email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment,attachment1 };
      
 
      /*Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
      attachmenttext.body = 'Create Task';
      attachmenttext.fileName = 'Term.csv';
      attachmenttext.mimeTypeSubType = 'texttwo/plain';
      email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };*/
      
      
      // call the email service class and test it with the data in the testMethod
      DrawAdvanceProcessHandler testInbound = new DrawAdvanceProcessHandler();
      testInbound.handleInboundEmail(email, env);
    Test.stopTest();
  }    
}