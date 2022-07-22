public class CLOAsset_Helper {
 public static boolean runTigger = True;
    
  /**
   * @name afterUpdate
   * @description
   * @param
   **/
  public static void afterUpdate(
    List<CLO_Asset_Details__c> newList,
    List<CLO_Asset_Details__c> oldList
  )
	{
    List<CLO_Asset_Details__c> cLOAssetList = new List<CLO_Asset_Details__c>();
    List<Property__c> propertyList = New List<Property__c>();
    List<Opportunity> opportunityList = New List<Opportunity>();        
	for (Integer i = 0; i < newList.size(); i++) 
      {
        CLO_Asset_Details__c cLOAsset = new CLO_Asset_Details__c();
		Property__c property = New Property__c();
    	Opportunity opportunity = New Opportunity();  
          
        property.id = newList[i].Related_Property__c;  
    	if (newList[i].Property_Name__c != oldList[i].Property_Name__c )  property.Property_Name__c = newList[i].Property_Name__c;
    	if (newList[i].Property_City__c != oldList[i].Property_City__c )  property.City__c = newList[i].Property_City__c;          
    	if (newList[i].Property_State__c != oldList[i].Property_State__c )  property.State__c = newList[i].Property_State__c;           
    	if (newList[i].Property_Zip_Code__c != oldList[i].Property_Zip_Code__c )  property.ZipCode__c = newList[i].Property_Zip_Code__c;            
    	if (newList[i].Property_County__c != oldList[i].Property_County__c )  property.County__c = newList[i].Property_County__c;           
    	if (newList[i].Year_Built__c != oldList[i].Year_Built__c )  property.Year_Built__c = newList[i].Year_Built__c;            
    	if (newList[i].Property_Type__c != oldList[i].Property_Type__c )  property.Property_Type__c = newList[i].Property_Type__c;          
    	if (newList[i].Number_of_Units__c != oldList[i].Number_of_Units__c )  property.Number_of_Units__c = newList[i].Number_of_Units__c;           
    //	if (newList[i].Initial_Funded_Amount__c != oldList[i].Initial_Funded_Amount__c )  property.Initial_Disbursement__c = newList[i].Initial_Funded_Amount__c;           
    	if (newList[i].First_Payment_Date__c != oldList[i].First_Payment_Date__c )  property.First_Payment_Date__c = newList[i].First_Payment_Date__c;                     
    	if (newList[i].First_Payment_Date__c != oldList[i].First_Payment_Date__c )  property.First_Payment_Date__c = newList[i].First_Payment_Date__c;                               
    //	if (newList[i].Initial_Maturity_Date__c != oldList[i].Initial_Maturity_Date__c )  property.Asset_Maturity_Date__c = newList[i].Initial_Maturity_Date__c;                                         
    	if (newList[i].Engineering_Report_Date__c != oldList[i].Engineering_Report_Date__c )  property.Report_Due_Date_PCR__c = newList[i].Engineering_Report_Date__c;            
    	if (newList[i].Environmental_Report_Date_Phase_1__c != oldList[i].Environmental_Report_Date_Phase_1__c )  property.Report_Due_Date_PH1__c = newList[i].Environmental_Report_Date_Phase_1__c;            
    	if (newList[i].Environmental_Report_Date_Phase_2__c != oldList[i].Environmental_Report_Date_Phase_2__c )  property.Report_Due_Date_PH2__c = newList[i].Environmental_Report_Date_Phase_2__c;                	
    	if (newList[i].Seismic_Report_Date__c != oldList[i].Seismic_Report_Date__c )  property.Report_Due_Date_SEI__c = newList[i].Seismic_Report_Date__c;                	          
		propertyList.add(property);
        
	/*	opportunity.id = newList[i].Deal_ID__c;          
    	if (newList[i].Loan_Purpose__c != oldList[i].Loan_Purpose__c )  opportunity.Loan_Purpose__c = newList[i].Loan_Purpose__c;                                         
    	if (newList[i].Borrower_Name__c != oldList[i].Borrower_Name__c )  opportunity.Borrower_Entity__c = newList[i].Borrower_Name__c;     
    	if (newList[i].Loan_Commitment_Original_Balance__c != oldList[i].Loan_Commitment_Original_Balance__c )  opportunity.LOC_Commitment__c = newList[i].Loan_Commitment_Original_Balance__c;             
    	if (newList[i].Note_Date__c != oldList[i].Note_Date__c )  opportunity.CloseDate = newList[i].Note_Date__c;                       
    	//if (newList[i].First_Extension_Fee__c != oldList[i].First_Extension_Fee__c )  opportunity.Extension_Fee__c = newList[i].First_Extension_Fee__c;            
    	if (newList[i].Exit_Fee__c != oldList[i].Exit_Fee__c )  opportunity.Exit_Fee__c = newList[i].Exit_Fee__c;                      
    	if (newList[i].Interest_Rate_Type__c != oldList[i].Interest_Rate_Type__c )  opportunity.Interest_Rate_Type__c = newList[i].Interest_Rate_Type__c;             
    	if (newList[i].Index_for_Floating_Rate__c != oldList[i].Index_for_Floating_Rate__c )  opportunity.Index__c = newList[i].Index_for_Floating_Rate__c;                       
    	if (newList[i].SOFR_Floor__c != oldList[i].SOFR_Floor__c )  opportunity.Index_Floor__c = newList[i].SOFR_Floor__c;                                 
    	if (newList[i].Appraisal_Stabilized_Occupancy__c != oldList[i].Appraisal_Stabilized_Occupancy__c )  opportunity.Total_ARV_LTV__c = newList[i].Appraisal_Stabilized_Occupancy__c;           
    	if (newList[i].Recourse__c != oldList[i].Recourse__c )  opportunity.Recourse__c = newList[i].Recourse__c;                     
    	if (newList[i].Maturity_Date__c != oldList[i].Maturity_Date__c )  opportunity.Updated_Loan_Maturity_Date__c = newList[i].Maturity_Date__c;           
    	if (newList[i].Amortization_Term__c != oldList[i].Amortization_Term__c )  opportunity.Amortization_Term__c = newList[i].Amortization_Term__c;                     
		opportunityList.add(opportunity);     */     
      }
      update propertyList;
     // update opportunityList;        
    }
}