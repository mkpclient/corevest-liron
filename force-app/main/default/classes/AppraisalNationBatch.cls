global class AppraisalNationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public static Map<String, List<SObject>> finishedMap = new Map<String, List<Sobject>>{
      'Appraisals' => new List<SObject>(),
      'Comments' => new List<Sobject>()
    };

    public static List<Id> ID_LIST = new List<Id>();
  
    global Database.QueryLocator start(Database.BatchableContext BC) {
      String queryString = 'SELECT Id FROM Appraisal__c';
  
      queryString += ' WHERE Appraisal_Firm_Transaction_ID__c != null AND Vendor_Ordered_From__c = \'Appraisal Nation\'';
      queryString += ' AND CreatedDate = LAST_N_DAYS:30 AND Property__c != null';
      queryString += ' AND Status__c != \'Complete-Delivered\' AND Status__c != \'Cancelled\' AND Prevent_Auto_Refresh__c = false LIMIT 3';
  
      return Database.getQueryLocator(queryString);
    }
  
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
      for (sobject s : scope) {
        ID_LIST.add((Id) s.get('Id'));
      }


    }
  
    global void finish(Database.BatchableContext BC) {

      finishedMap.putAll(AppraisalMergeController.refreshBatch(ID_LIST));

      if(finishedMap.get('Appraisals').size() > 0) {
        update finishedMap.get('Appraisals');
      }
      if(finishedMap.get('Comments').size() > 0)  {
        update finishedMap.get('Comments');
      }
    }
  }