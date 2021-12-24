public class LoanStatusUpdatesController {
	@AuraEnabled
    public static List<Loan_Status__c> getRecord(String dealId){
        return [Select Id,Subject__c,Comment__c,CreatedBy.Name,CreatedDate from Loan_Status__c where Deal__c=:dealId ORDER BY CreatedDate DESC NULLS LAST];
    }
    
    @AuraEnabled
    public static List<Loan_Status__c> deleteRecord(String recordId, String dealId){
        delete [Select Id from Loan_Status__c where Id=:recordId];
        return getRecord(dealId);
    }
}