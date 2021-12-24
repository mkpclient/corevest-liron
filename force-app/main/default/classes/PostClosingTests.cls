@IsTest
private class PostClosingTests {
    // public static Opportunity setupDeal(){
    //     return null
    // }

    public static TestMethod void UTOppInsert(){
        test_Helper.setUpProduct2();
        Account acc = test_Helper.createAccount();
		Contact cont = test_Helper.createContact( acc );
		Opportunity opp = test_Helper.createOpportunity( acc, cont );
        opp.Apex_Context__c = true;
		opp.RecordTypeId = [SELECT Id FROM RecordType WHERE sobjecttype = 'Opportunity' and DeveloperName = 'LOC_Loan'].Id;
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
		for(Integer i = 0; i < 20; i++){
			property.add(
                new Property__c(
                    Name='Test + ' + i, 
                    Appraised_Value_Amount__c = 5, 
                    Acquisition_Price__c = 5, 
                    Property_Name__c='Test + ' + i, 
                    Deal__c = opp.Id, 
                    Escrow_Company_text__c = 'ESCROW', 
                    Insurance_Company_text__c = 'INSURANCE', 
                    Status__c = 'Pending',
                    RecordTypeId = [SELECT Id FROM RecordType WHERE sobjecttype = 'Property__c' and DeveloperName = 'Bridge_No_Renovation'].Id
                )
            );
        }

		property[0].Status__c = 'Due Diligence';
		property[1].Status__c = 'Active';
		property[2].Payoff_Received_Date__c = system.today();
        insert property;
        
    } 
}