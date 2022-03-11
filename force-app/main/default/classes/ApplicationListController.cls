public without sharing class ApplicationListController {
  @AuraEnabled
  public static List<Application__c> getApplications(String recordId) {
    try {
      return [
        SELECT Id, Name, Status__c, Contact__c, Loan_Type__c, Contact__r.Name
        FROM Application__c
        WHERE Deal__c = :recordId Order by createddate asc
      ];
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static void setMainApplication(String dealId, String applicationId) {
    try {
      Opportunity deal = [SELECT Id, Application__c FROM Opportunity WHERE Id =: dealId LIMIT 1];
        
        if(deal.Application__c != applicationId){
            deal.Application__c = applicationId;
            update deal;
            
            List<Deal_Document__c> dealDocs = [SELECT Id FROM Deal_Document__c WHERE Document_Type__c = 'Term Sheet' AND Executive_Approval_Date__c != null AND Deal__c =:dealId ORDER BY Executive_Approval_Date__c DESC];
            
            if(dealDocs.size() > 0){
                AlchemyAPI.sendTermSheet(dealId, dealDocs[0].Id);
            }
        }

      //fire off term sheet notification api if applicable
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}