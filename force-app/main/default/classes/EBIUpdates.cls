public class EBIUpdates {
  public static void afterUpdate(
    List<EBI_Updates__c> newList,
    List<EBI_Updates__c> oldList
  ) {
    List<Appraisal__c> appraisals = new List<Appraisal__c>();

    for (EBI_Updates__c ebirow : newList) {
      Appraisal__c appraisal = new Appraisal__c(
        Id = ebirow.Property_Appraisal_ID__c,
        ESA_Delivered_Date__c = ebirow.ESA_Delivered_Date__c,
        Order_Number__c = ebirow.Order_Number__c,
        PCA_Delivered_Date__c = ebirow.PCA_Delivered_Date__c,
        PCA_Report_Manager__c = ebirow.PCA_Report_Manager__c,
        PCA_Report_Manager_Email__c = ebirow.PCA_Report_Manager_Email__c,
        PCA_Reports_Due__c = ebirow.PCA_Reports_Due__c,
        Phase_1_Report_Manager__c = ebirow.Phase_1_Report_Manager__c,
        Phase_1_Report_Manager_Email__c = ebirow.Phase_1_Report_Manager_Email__c,
        Phase_One_Reports_Due__c = ebirow.Phase_One_Reports_Due__c,
        Price_for_ESA__c = ebirow.Price_for_ESA__c,
        Price_for_PCA__c = ebirow.Price_for_PCA__c,
        EBI_Project_Id__c = ebirow.EBI_Project_Id__c,
        EBI_Project_No__c = ebirow.EBI_Project_No__c,
        PSI_URL_1__c = ebirow.PSI_URL_1__c,
        PSI_URL_2__c = ebirow.PSI_URL_2__c,
        EBI_Report_Status__c = ebirow.EBI_Report_Status__c,
        Price_for_RDNSMP__c = ebirow.Price_for_RDNSMP__c,
        RDNSMP_Due_Date__c = ebirow.RDNSMP_Due_Date__c,
        RDNSMP_Report_Manager__c = ebirow.RDNSMP_Report_Manager__c,
        RDNSMP_Report_Manager_Email__c = ebirow.RDNSMP_Report_Manager_Email__c,
        Price_for_Zoning_Report__c = ebirow.Price_for_Zoning_Report__c,
        Zoning_Report_Due_Date__c = ebirow.Zoning_Report_Due_Date__c,
        Zoning_Report_Report_Manager__c = ebirow.Zoning_Report_Report_Manager__c,
        Zoning_Report_Manager_Email__c = ebirow.Zoning_Report_Manager_Email__c,
        RDNSMP_Delivered_Date__c = ebirow.RDNSMP_Delivered_Date__c,
        Zoning_Report_Delivered_Date__c = ebirow.Zoning_Report_Delivered_Date__c,
        RDNSMP_URL_1__c = ebirow.RDNSMP_URL_1__c
      );
      if (ebirow.Zoning_Report_URL_1__c != null) {
        List<String> zoningURLs = ebirow.Zoning_Report_URL_1__c.split(' ');
        if (zoningURLs.size() > 0) {
          appraisal.Zoning_Report_URL_1__c = zoningURLs[0];
          if (zoningURLs.size() > 1 && zoningURLs[1] != null) {
            appraisal.Zoning_Report_URL_2__c = zoningURLs[1];
          }
        }
      }

      appraisals.add(appraisal);
    }


    update appraisals;
  }
}