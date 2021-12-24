public with sharing class SecuritizationHelper {
  public static void beforeInsert(List<Securitization__c> newList) {
    Map<String, Id> recordTypeMap = new Map<String, Id>();

    for (RecordType rt : [
      SELECT Id, DeveloperName
      FROM RecordType
      WHERE Sobjecttype = 'Funding_Vehicle__c'
    ]) {
      recordTypeMap.put(rt.DeveloperName, rt.Id);
    }

    // for (Securitization__c sec : newList) {
    //   Funding_Vehicle__c fv = new Funding_Vehicle__c();
    //   fv.Name = sec.Name;
    //   fv.Funding_Vehicle_Type__c = 'Securitization';
    //   fv.RecordTypeId = recordTypeMap.get('Securitization');
    //   fv.Securitization__c = sec.Id;
    //   insert fv;
    // response.put('fvId', fv.Id);
    //   sec.Funding_Vehicle__c = fv.Id;
    //   update sec;
  }

  public static void afterInsert(List<Securitization__c> newList) {
    Map<String, Id> recordTypeMap = new Map<String, Id>();

    for (RecordType rt : [
      SELECT Id, DeveloperName
      FROM RecordType
      WHERE Sobjecttype = 'Funding_Vehicle__c'
    ]) {
      recordTypeMap.put(rt.DeveloperName, rt.Id);
    }

    for (Securitization__c sec : newList) {
      Funding_Vehicle__c fv = new Funding_Vehicle__c();
      fv.Name = sec.Name;
      fv.Funding_Vehicle_Type__c = 'Securitization';
      fv.RecordTypeId = recordTypeMap.get('Securitization');
      fv.Securitization__c = sec.Id;
      insert fv;
      // response.put('fvId', fv.Id);
    //   sec.Funding_Vehicle__c = fv.Id;
    //   update sec;
    }
  }
}