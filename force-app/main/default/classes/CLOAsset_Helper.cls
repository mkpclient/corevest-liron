public class CLOAsset_Helper {
  public static boolean runTigger = true;

  public static void afterInsert(List<CLO_Asset_Details__c> newList) {
    List<Opportunity> oppsToUpdate = new List<Opportunity>();

    for (CLO_Asset_Details__c cad : newList) {
      if (cad.Deal_ID__c != null) {
        Opportunity opp = new Opportunity();

        if (cad.Interest_Rate_Cap_Reserve__c != null) {
          opp.Interest_Rate_Cap_Reserve__c = cad.Interest_Rate_Cap_Reserve__c;
        }
        if (cad.Reserve_Cap_Ex__c != null) {
          opp.Reserve_Cap_Ex__c = cad.Reserve_Cap_Ex__c;
        }
        if (cad.Reserve_Insurance__c != null) {
          opp.Reserve_Insurance__c = cad.Reserve_Insurance__c;
        }
        if (cad.Reserve_Tax__c != null) {
          opp.Reserve_Tax__c = cad.Reserve_Tax__c;
        }

        if (opp != new Opportunity()) {
          opp.Id = cad.Deal_ID__c;
          oppsToUpdate.add(opp);
        }
      }
    }

    if (oppsToUpdate.size() > 0) {
      update oppsToUpdate;
    }
  }

  /**
   * @name afterUpdate
   * @description
   * @param
   **/
  public static void afterUpdate(
    List<CLO_Asset_Details__c> newList,
    List<CLO_Asset_Details__c> oldList
  ) {
    List<Property__c> propertyList = new List<Property__c>();
    List<Opportunity> opportunityList = new List<Opportunity>();
    for (Integer i = 0; i < newList.size(); i++) {
      CLO_Asset_Details__c newCad = newList[i];
      CLO_Asset_Details__c oldCad = oldList[i];
      Property__c property = new Property__c();
      Opportunity opportunity = new Opportunity();

      if (shouldUpdateOpp(newCad, oldCad)) {
        Opportunity opp = new Opportunity();

        if (newCad.Interest_Rate_Cap_Reserve__c != null) {
          opp.Interest_Rate_Cap_Reserve__c = newCad.Interest_Rate_Cap_Reserve__c;
        }
        if (newCad.Reserve_Cap_Ex__c != null) {
          opp.Reserve_Cap_Ex__c = newCad.Reserve_Cap_Ex__c;
        }
        if (newCad.Reserve_Insurance__c != null) {
          opp.Reserve_Insurance__c = newCad.Reserve_Insurance__c;
        }
        if (newCad.Reserve_Tax__c != null) {
          opp.Reserve_Tax__c = newCad.Reserve_Tax__c;
        }

				opp.Id = newCad.Deal_ID__c;
        opportunityList.add(opp);
      }

      if (newCad.Property_Name__c != oldCad.Property_Name__c)
        property.Property_Name__c = newCad.Property_Name__c;
      if (newCad.Property_City__c != oldCad.Property_City__c)
        property.City__c = newCad.Property_City__c;
      if (newCad.Property_State__c != oldCad.Property_State__c)
        property.State__c = newCad.Property_State__c;
      if (newCad.Property_Zip_Code__c != oldCad.Property_Zip_Code__c)
        property.ZipCode__c = newCad.Property_Zip_Code__c;
      if (newCad.Property_County__c != oldCad.Property_County__c)
        property.County__c = newCad.Property_County__c;
      if (newCad.Year_Built__c != oldCad.Year_Built__c)
        property.Year_Built__c = newCad.Year_Built__c;
      if (newCad.Property_Type__c != oldCad.Property_Type__c)
        property.Property_Type__c = newCad.Property_Type__c;
      if (newCad.Number_of_Units__c != oldCad.Number_of_Units__c)
        property.Number_of_Units__c = newCad.Number_of_Units__c;
      //	if (newCad.Initial_Funded_Amount__c != oldCad.Initial_Funded_Amount__c )  property.Initial_Disbursement__c = newCad.Initial_Funded_Amount__c;
      if (newCad.First_Payment_Date__c != oldCad.First_Payment_Date__c)
        property.First_Payment_Date__c = newCad.First_Payment_Date__c;
      // if (newCad.First_Payment_Date__c != oldCad.First_Payment_Date__c )  property.First_Payment_Date__c = newCad.First_Payment_Date__c;
      //	if (newCad.Initial_Maturity_Date__c != oldCad.Initial_Maturity_Date__c )  property.Asset_Maturity_Date__c = newCad.Initial_Maturity_Date__c;
      if (
        newCad.Engineering_Report_Date__c != oldCad.Engineering_Report_Date__c
      )
        property.Report_Due_Date_PCR__c = newCad.Engineering_Report_Date__c;
      if (
        newCad.Environmental_Report_Date_Phase_1__c !=
        oldCad.Environmental_Report_Date_Phase_1__c
      )
        property.Report_Due_Date_PH1__c = newCad.Environmental_Report_Date_Phase_1__c;
      if (
        newCad.Environmental_Report_Date_Phase_2__c !=
        oldCad.Environmental_Report_Date_Phase_2__c
      )
        property.Report_Due_Date_PH2__c = newCad.Environmental_Report_Date_Phase_2__c;
      if (newCad.Seismic_Report_Date__c != oldCad.Seismic_Report_Date__c)
        property.Report_Due_Date_SEI__c = newCad.Seismic_Report_Date__c;
      if (property != new Property__c()) {
        property.id = newCad.Related_Property__c;
        propertyList.add(property);
      }

      /*	opportunity.id = newCad.Deal_ID__c;          
    	if (newCad.Loan_Purpose__c != oldCad.Loan_Purpose__c )  opportunity.Loan_Purpose__c = newCad.Loan_Purpose__c;                                         
    	if (newCad.Borrower_Name__c != oldCad.Borrower_Name__c )  opportunity.Borrower_Entity__c = newCad.Borrower_Name__c;     
    	if (newCad.Loan_Commitment_Original_Balance__c != oldCad.Loan_Commitment_Original_Balance__c )  opportunity.LOC_Commitment__c = newCad.Loan_Commitment_Original_Balance__c;             
    	if (newCad.Note_Date__c != oldCad.Note_Date__c )  opportunity.CloseDate = newCad.Note_Date__c;                       
    	//if (newCad.First_Extension_Fee__c != oldCad.First_Extension_Fee__c )  opportunity.Extension_Fee__c = newCad.First_Extension_Fee__c;            
    	if (newCad.Exit_Fee__c != oldCad.Exit_Fee__c )  opportunity.Exit_Fee__c = newCad.Exit_Fee__c;                      
    	if (newCad.Interest_Rate_Type__c != oldCad.Interest_Rate_Type__c )  opportunity.Interest_Rate_Type__c = newCad.Interest_Rate_Type__c;             
    	if (newCad.Index_for_Floating_Rate__c != oldCad.Index_for_Floating_Rate__c )  opportunity.Index__c = newCad.Index_for_Floating_Rate__c;                       
    	if (newCad.SOFR_Floor__c != oldCad.SOFR_Floor__c )  opportunity.Index_Floor__c = newCad.SOFR_Floor__c;                                 
    	if (newCad.Appraisal_Stabilized_Occupancy__c != oldCad.Appraisal_Stabilized_Occupancy__c )  opportunity.Total_ARV_LTV__c = newCad.Appraisal_Stabilized_Occupancy__c;           
    	if (newCad.Recourse__c != oldCad.Recourse__c )  opportunity.Recourse__c = newCad.Recourse__c;                     
    	if (newCad.Maturity_Date__c != oldCad.Maturity_Date__c )  opportunity.Updated_Loan_Maturity_Date__c = newCad.Maturity_Date__c;           
    	if (newCad.Amortization_Term__c != oldCad.Amortization_Term__c )  opportunity.Amortization_Term__c = newCad.Amortization_Term__c;                     
		opportunityList.add(opportunity);     */
    }

    if (propertyList.size() > 0) {
      update propertyList;
    }

    if (opportunityList.size() > 0) {
      update opportunityList;
    }
    // update opportunityList;
  }

  public static Boolean shouldUpdateOpp(
    CLO_Asset_Details__c nCad,
    CLO_Asset_Details__c oCad
  ) {
    return nCad.Deal_ID__c != null &&
      (nCad.Interest_Rate_Cap_Reserve__c != oCad.Interest_Rate_Cap_Reserve__c ||
      nCad.Reserve_Cap_Ex__c != oCad.Reserve_Cap_Ex__c ||
      nCad.Reserve_Insurance__c != oCad.Reserve_Insurance__c ||
      nCad.Reserve_Tax__c != oCad.Reserve_Tax__c);
  }
}