public without sharing class LoanVersionHelper {
  public static Map<Id, String> RECORDTYPE_MAP = compileRecordTypeMap();

  public static Map<Id, String> compileRecordTypeMap() {
    Map<Id, String> recordmap = new Map<Id, String>();
    for (RecordType r : [
      SELECT Id, Name, DeveloperName
      FROM RecordType
      WHERE sobjecttype = 'Loan_Version__c'
    ]) {
      recordmap.put(r.id, r.DeveloperName);
    }
    return recordmap;
  }

  public static void beforeInsert(List<Loan_Version__c> newList) {
    Map<Id, List<Loan_Version__C>> loanVersionMap = new Map<Id, List<Loan_Version__C>>();

    for (Loan_Version__c lv : newList) {
      if (!loanVersionMap.containsKey(lv.Deal__c)) {
        loanVersionMap.put(lv.Deal__c, new List<Loan_Version__c>());
      }

      loanVersionMap.get(lv.Deal__c).add(lv);
    }

    for (Opportunity o : [
      SELECT
        Id,
        Name,
        Deal_Loan_Number__c,
        (
          SELECT Id, Name, RecordTypeId
          FROM Loan_Versions__r
          WHERE RecordTypeId != NULL
          ORDER BY CreatedDate
        )
      FROM Opportunity
      WHERE Id IN :loanVersionMap.keySet()
    ]) {
      Map<Id, Integer> rtSizeMap = new Map<Id, Integer>();
      for (Loan_Version__C lv : o.Loan_Versions__r) {
        if (!rtSizeMap.containsKey(lv.RecordTypeId)) {
          rtSizeMap.put(lv.RecordTypeId, 0);
        }
        Integer newSize = rtSizeMap.get(lv.RecordTypeId) + 1;
        rtSizeMap.put(lv.RecordTypeId, newSize);
      }

      for (Loan_Version__c lv : loanVersionMap.get(o.Id)) {
        if (String.isBlank(lv.Name)) {
          // if(o.Loan_Versions__r.size() > 0 ){
          //     lv.Name = String.valueOf(o.Loan_Versions__r.size() + 1);
          // }else{
          //     lv.Name = '1';
          // }
          //lv.Loan_Agreement_Name__c = o.Deal_Loan_Number__c + ' / ' + o.Name + ' / ' + lv.Borrower__c + ' / Loan Agreement Version ' + lv.Name;
          //lv.Name = lv.Name

          String versionName = '';

          Integer versionNumber = 1;

          if (rtSizeMap.containsKey(lv.RecordTypeId)) {
            versionNumber = rtSizeMap.get(lv.RecordTypeId) + 1;
          }

          String recordTypeDeveloperName = RECORDTYPE_MAP.get(lv.RecordTypeId);

          if (recordTypeDeveloperName == 'Schedule_of_Lender_Cost') {
            //lv.Name = o.Deal_Loan_Number__c + ' / ' + o.Name + ' / ' + lv.Borrower__c + ' / Schedule of Lender Cost ' + String.valueOf(versionNumber);
            lv.Name =
              'Schedule of Lender Cost ' + String.valueOf(versionNumber);
          } else if (recordTypeDeveloperName == 'Loan_Agreement') {
            //lv.Name = o.Deal_Loan_Number__c + ' / ' + o.Name + ' / ' + lv.Borrower__c + ' / Loan Agreement Version ' + String.valueOf(versionNumber);
            lv.Name = 'Loan Agreement Version ' + String.valueOf(versionNumber);
          }
        }
      }
    }
  }
}