public class EBIUpdates {

    public static void afterUpdate(List<EBI_Updates__c> newList,List<EBI_Updates__c> oldList) {
     List<Appraisal__c> ListAppraisal = new List<Appraisal__c>();
     For (EBI_Updates__c ebirow : newList)
     {
     ListAppraisal = [SELECT id from Appraisal__c where id = :ebirow.Property_Appraisal_ID__c];
     For (Integer i=0;i<ListAppraisal.size();i++)
     {
        ListAppraisal[i].ESA_Delivered_Date__c				= ebirow.ESA_Delivered_Date__c;
        ListAppraisal[i].Order_Number__c					= ebirow.Order_Number__c;
        ListAppraisal[i].PCA_Delivered_Date__c				= ebirow.PCA_Delivered_Date__c;
        ListAppraisal[i].PCA_Report_Manager__c				= ebirow.PCA_Report_Manager__c;
        ListAppraisal[i].PCA_Report_Manager_Email__c		= ebirow.PCA_Report_Manager_Email__c;
        ListAppraisal[i].PCA_Reports_Due__c					= ebirow.PCA_Reports_Due__c;
        ListAppraisal[i].Phase_1_Report_Manager__c			= ebirow.Phase_1_Report_Manager__c;
        ListAppraisal[i].Phase_1_Report_Manager_Email__c	= ebirow.Phase_1_Report_Manager_Email__c;
        ListAppraisal[i].Phase_One_Reports_Due__c			= ebirow.Phase_One_Reports_Due__c;
        ListAppraisal[i].Price_for_ESA__c					= ebirow.Price_for_ESA__c;
        ListAppraisal[i].Price_for_PCA__c					= ebirow.Price_for_PCA__c;
        ListAppraisal[i].EBI_Project_Id__c					= ebirow.EBI_Project_Id__c;
        ListAppraisal[i].EBI_Project_No__c					= ebirow.EBI_Project_No__c;
        ListAppraisal[i].PSI_URL_1__c						= ebirow.PSI_URL_1__c;
        ListAppraisal[i].PSI_URL_2__c						= ebirow.PSI_URL_2__c;
        ListAppraisal[i].EBI_Report_Status__c				= ebirow.EBI_Report_Status__c;
        ListAppraisal[i].Price_for_RDNSMP__c  				= ebirow.Price_for_RDNSMP__c ;
        ListAppraisal[i].RDNSMP_Due_Date__c 				= ebirow.RDNSMP_Due_Date__c;
        ListAppraisal[i].RDNSMP_Report_Manager__c 			= ebirow.RDNSMP_Report_Manager__c;
        ListAppraisal[i].RDNSMP_Report_Manager_Email__c 	= ebirow.RDNSMP_Report_Manager_Email__c;
        ListAppraisal[i].Price_for_Zoning_Report__c 		= ebirow.Price_for_Zoning_Report__c;
        ListAppraisal[i].Zoning_Report_Due_Date__c 			= ebirow.Zoning_Report_Due_Date__c;
        ListAppraisal[i].Zoning_Report_Report_Manager__c 	= ebirow.Zoning_Report_Report_Manager__c;
        ListAppraisal[i].Zoning_Report_Manager_Email__c 	= ebirow.Zoning_Report_Manager_Email__c;
        ListAppraisal[i].RDNSMP_Delivered_Date__c			= ebirow.RDNSMP_Delivered_Date__c;
        ListAppraisal[i].Zoning_Report_Delivered_Date__c 	= ebirow.Zoning_Report_Delivered_Date__c;
        ListAppraisal[i].RDNSMP_URL_1__c 					= ebirow.RDNSMP_URL_1__c;
        if (ebirow.Zoning_Report_URL_1__c != Null) 
        {
            List<String> zoningURLs = ebirow.Zoning_Report_URL_1__c.split(' '); 
            if (zoningURLs.size() > 0)
            {
            ListAppraisal[i].Zoning_Report_URL_1__c  = zoningURLs[0];
            if (zoningURLs.size() > 1)
            {
            if (zoningURLs[1] != Null ) ListAppraisal[i].Zoning_Report_URL_2__c  = zoningURLs[1];             
            }
            }
        }
     }
 	 }     
     Update ListAppraisal;
    }
}