global class ClearCapitalBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
  public ClearCapitalBatch() {
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    String queryString = 'SELECT Id FROM Appraisal__c';

    queryString += ' WHERE Appraisal_Firm_Transaction_ID__c != null AND Vendor_Ordered_From__c = \'Clear Capital\'';
    queryString += ' AND (CreatedDate = LAST_N_DAYS:30 OR CreatedDate >= TODAY) AND Property__c != null ';
    queryString += ' AND Status__c != \'Complete-Delivered\' AND Status__c != \'Cancelled\' AND Prevent_Auto_Refresh__c = false';

    return Database.getQueryLocator(queryString);
  }

  global void execute(Database.BatchableContext BC, List<sObject> scope) {
    for (sobject s : scope) {
      AppraisalMergeController.checkStatus((Id) s.get('Id'));
    }
  }

  global void finish(Database.BatchableContext BC) {
  }
}