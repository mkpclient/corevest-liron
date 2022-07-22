@isTest
private class RStest {

  static testMethod void lightning_Tests_UnitTest() {
    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
    Opportunity opp = test_Helper.createOpportunity(acc, cont);
    List<Property__c> properties = test_Helper.createProperties(opp);

    Test.startTest();
    lightning_Controller.getSession();
    lightning_Controller.getRecord(opp.Id);
     lightning_Controller.getRecordListPileLineRpt(
      opp.Id,
      '',
      'opportunity',
	  new List<String>{ 'Anticipated_Closing_Date__c','Name' ,'Spread_BPS__c','Are_Assets_Being_RFNC_From_Existing_Term__c','Final_Spread__c', 'Loan_Purpose__c','Deal_Loan_Number__c','Account.Introductions_Source__c','Recourse__c','Cash_Management__c','Term_Loan_Type__c','LTV__c','Amortization_Term__c','Floor__c','State_Percentages__c','StageName','Current_Loan_Amount__c','Owner.LastName','Underwriter__r.Initials__c','Loan_Coordinator__r.Initials__c','Closer__r.Initials__c','Title__r.Name','Third_Party_Title__r.Name','Are_Assets_Coming_Off_Bridge_Line__c','Warehouse_Line__c','Kickoff_Date__c','Days_In_Underwriting__c','Anticipated_IC_Approval__c','CloseDate','Loan_Size__c','Final_Loan_Amount__c','Awaiting_Kickoff_Call__c','In_Process_of_Withdrawn_or_Rejected__c','id'} ,        
      'Id',
      'Desc',
      ' Account.Name != \'Inhouse Test Account\' AND Lender__c LIKE \'%CoreVest%\' AND CloseDate = THIS_MONTH',
      'Awaiting_Kickoff_Call__c ASC, Anticipated_Closing_Date__c ASC, StageName DESC ',
      'P'
    );      
 
    Test.stopTest();
  }
}