@RestResource(urlMapping='/portal/property/*')
global without sharing class PortalAPIProperty {
  @HttpGet
  global static void doGet() {
    RestRequest req = RestContext.request;
    RestResponse res = Restcontext.response;

    List<String> params = Restcontext.request.requestURI.split('/');
    system.debug(params);
    if (params[3] == 'userId') {
    } else if (params[3] == 'dealId') {
      Id dealId = params[4];
      system.debug(dealId);
      List<Opportunity> opp = [
        SELECT Id, RecordType.DeveloperName
        FROM Opportunity
        WHERE Id = :dealId
      ];

      if (opp.size() > 0) {
        Set<String> fields = new Set<String>{
          'Id',
          'Deal__c',
          'Deal__r.Name',
          'Name',
          'Deal__r.Onboarding_File_Sent_to_Servicer__c',
          'Deal__r.Current_UPB__c',
          'Deal__r.Next_Payment_Date__c',
          'Deal__r.Stated_Maturity_Date__c',
          'Deal__r.Servicer_Name__c',
          'Deal__r.Deal_Loan_Number__c',
          'Deal__r.StageName',
          'Deal__r.RecordType.DeveloperName',
          'Current_Asset_Maturity_Date__c',
          'Full_Address__c'
        };
        //}//TERM_SRL_FIELDS;

        String queryString = 'SELECT ';
        queryString += String.join(new List<String>(fields), ',');
        queryString += ' FROM Property__c ';
        queryString += ' WHERE Deal__c =\'' + dealId + '\'';
        //system.debug(queryString);

        List<Property__c> properties = (List<Property__c>) Database.query(
          queryString
        );

        res.responseBody = Blob.valueOf(JSON.serialize(properties, true));
        res.addHeader('Content-Type', 'application/json');
      } else {
        Map<String, String> bodyResp = new Map<String, String>();
        bodyResp.put('status', 'error');
        bodyResp.put('message', 'Deal not found with Id ' + dealId);
        res.responseBody = Blob.valueOf(JSON.serialize(bodyResp));
        res.addHeader('Content-Type', 'application/json');
      }
    } else {
      Id propertyId = params[3];

      Set<String> fields = TERM_SRL_FIELDS;

      String queryString = 'SELECT ';
      queryString += String.join(new List<String>(fields), ',');
      queryString += ' FROM Property__c ';
      queryString += ' WHERE Id =\'' + propertyId + '\'';

      List<Property__c> properties = (List<Property__c>) Database.query(
        queryString
      );

      if (properties.size() > 0) {
        res.responseBody = Blob.valueOf(JSON.serialize(properties[0], true));
        res.addHeader('Content-Type', 'application/json');
      } else {
        Map<String, String> bodyResp = new Map<String, String>();
        bodyResp.put('status', 'error');
        bodyResp.put('message', 'Property not found with Id ' + propertyId);
        res.responseBody = Blob.valueOf(JSON.serialize(bodyResp));
        res.addHeader('Content-Type', 'application/json');
      }
    }
  }

  public static Set<String> TERM_SRL_FIELDS = new Set<String>{
    'Id',
    'Deal__r.Name',
    'Deal__r.Onboarding_File_Sent_to_Servicer__c',
    'Deal__r.Current_UPB__c',
    'Deal__r.Next_Payment_Date__c',
    'Deal__r.Stated_Maturity_Date__c',
    'Deal__r.Servicer_Name__c',
    'Deal__r.Application__c',
    'Deal__r.Deal_Loan_Number__c',
    'Deal__r.StageName',
    'Deal__r.RecordType.DeveloperName',
    'Number_of_Units__c',
    'Acquisition_Date__c',
    'Acquisition_Price__c',
    'Acquisition_Type__c',
    'Name',
    'ALA__c',
    'Annual_HOA_Fee__c',
    'Annual_Insurance__c',
    'Annual_Managment_Fee__c',
    'Annual_Taxes__c',
    'APN__c',
    'Appraisal_Due_Date__c',
    'Approved_Advance_Amount_Remaining__c',
    'Approved_Advance_Amount_Max__c',
    'Approved_Advance_Amount_Used__c',
    'Asset_ID__c',
    'Attachment_Type__c',
    'Number_of_Bath__c',
    'Number_of_Beds__c',
    'Borrower_Opinion_of_Current_Value__c',
    'Calc_AveValue__c',
    'City__c',
    'County__c',
    'BPO_Appraisal_Date__c',
    'After_Repair_Value__c',
    'Appraised_Value_Amount__c',
    'Current_UPB__c',
    'Deal__c',
    'Deal_Loan_Number__c',
    'First_Funding_Date__c',
    'First_Payment_Date__c',
    'Initial_Disbursement_Used__c',
    'Initial_Disbursement__c',
    'Initial_Disbursement_Remaining__c',
    'Interior_Access_POC__c',
    'Interior_Access_POC_Email__c',
    'Interior_Access_POC_Phone__c',
    'Is_Parent__c',
    'Is_Sub_Unit__c',
    'Funding_Date__c',
    'Lease_End_Date__c',
    'Lease_Ready__c',
    'Lease_Start_Date__c',
    'Lease_Up_Marketing__c',
    'Maintenance_Repairs__c',
    'Monthly_Rent__c',
    'MSA__c',
    'Other_Expenses__c',
    'Other_Income__c',
    'ZipCode__c',
    'State__c',
    'Square_Feet__c',
    'Year_Built__c',
    'Property_Type__c',
    'Current_Asset_Maturity_Date__c',
    'Full_Address__c'
  };
}