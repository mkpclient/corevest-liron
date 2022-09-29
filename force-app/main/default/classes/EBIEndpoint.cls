@RestResource(urlMapping='/EBIDataUpdate')
global without sharing class EBIEndpoint {
  public class EBIException extends Exception {
  }

  @HttpPost
  global static string postMethod()
  {
    try
   {
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        
        System.Debug('RS999 requestString :' +requestString);
        
        Map<String, String> EBIMap = new Map<String, String>();

        EBI_Updates__c EBIReq =  (EBI_Updates__c) JSON.deserialize(requestString, EBI_Updates__c.class);    
        System.Debug('RS999 EBIReq :' +EBIReq);
        
        EBI_Updates__c dataEBI = New EBI_Updates__c();
        dataEBI.EBI_Report_Status__c			=	EBIReq.EBI_Report_Status__c;
        dataEBI.EBI_Project_No__c				=	EBIReq.EBI_Project_No__c;
        dataEBI.Phase_One_Reports_Due__c		=	EBIReq.Phase_One_Reports_Due__c;
        dataEBI.Phase_1_Report_Manager__c		=	EBIReq.Phase_1_Report_Manager__c;
        dataEBI.Phase_1_Report_Manager_Email__c	=	EBIReq.Phase_1_Report_Manager_Email__c;
        dataEBI.Price_for_ESA__c				=	EBIReq.Price_for_ESA__c;
        dataEBI.Price_for_PCA__c				=	EBIReq.Price_for_PCA__c;
        dataEBI.PCA_Reports_Due__c				=	EBIReq.PCA_Reports_Due__c;
        dataEBI.PCA_Report_Manager__c			=	EBIReq.PCA_Report_Manager__c;
        dataEBI.PCA_Report_Manager_Email__c		=	EBIReq.PCA_Report_Manager_Email__c;
        Insert dataEBI;
        return 'Success';
    }
    catch(exception e)
    {
        return e.getMessage();
    }

  }
  
}