public with sharing class SecuritizationHelper {
  public static final Map<String, Id> RT_MAP = queryRecordTypeMap();

  public static void beforeInsert(List<Securitization__c> newList) {
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
    createRelatedFundingVehicles(newList);
  }

  public static void afterUpdate(
    Map<Id, Securitization__c> oldMap,
    List<Securitization__c> newList
  ) {
    Map<Id, Securitization__c> secMap = new Map<Id, Securitization__c>();

    for (Securitization__c sec : newList) {
      Securitization__c oldSec = oldMap.get(sec.Id);
      if (
        (oldSec.Status__c != sec.Status__c && sec.Status__c == 'Redeemed') ||
        (sec.Status__c == 'Pending' &&
        oldSec.Close_Date__c != sec.Close_Date__c
        && sec.Close_Date__c != null)
      ) {
        secMap.put(sec.Id, sec);
      }
    }

    if (secMap.size() > 0) {
      updateFundingVehicleCnx(secMap);
    }
  }

  public static void updateFundingVehicleCnx(
    Map<Id, Securitization__c> secMap
  ) {
    Set<Id> dealsToUpdate = new Set<Id>();
    List<Deal_x_Funding_Vehicle__c> dfvs = [
      SELECT Id, End_Date__c, Deal__c, Funding_Vehicle__r.Securitization__c
      FROM Deal_x_Funding_Vehicle__c
      WHERE Funding_Vehicle__r.Securitization__c IN :secMap.keySet()
    ];

    for (Deal_x_Funding_Vehicle__c d : dfvs) {
      Securitization__c sec = secMap.get(d.Funding_Vehicle__r.Securitization__c);

      if (sec.Status__c == 'Pending') {
        d.Start_Date__c = sec.Close_Date__c;
      } else if (sec.Status__c == 'Redeemed') {
        d.End_Date__c = (Date) System.today();
        dealsToUpdate.add(d.Deal__c);
      }
    }

    update dfvs;
    updateDeals(dealsToUpdate);
  }

  public static void updateDeals(Set<Id> dealIds) {
    List<Opportunity> updDeals = new List<Opportunity>();

    for (Id id : dealIds) {
      updDeals.add(
        new Opportunity(
          Id = id,
          Securitization__c = null,
          Securitized__c = false
        )
      );
    }

    update updDeals;
  }

  public static Map<String, Id> queryRecordTypeMap() {
    Map<String, Id> recordTypeMap = new Map<String, Id>();

    for (RecordType rt : [
      SELECT Id, DeveloperName
      FROM RecordType
      WHERE Sobjecttype = 'Funding_Vehicle__c'
    ]) {
      recordTypeMap.put(rt.DeveloperName, rt.Id);
    }

    return recordTypeMap;
  }

  public static void createRelatedFundingVehicles(
    List<Securitization__c> newList
  ) {
    List<Funding_Vehicle__c> fvList = new List<Funding_Vehicle__c>();

    for (Securitization__c sec : newList) {
      Funding_Vehicle__c fv = new Funding_Vehicle__c();
      fv.Name = sec.Name;
      fv.Funding_Vehicle_Type__c = 'Securitization';
      fv.RecordTypeId = RT_MAP.get('Securitization');
      fv.Securitization__c = sec.Id;
      fvList.add(fv);
    }

    insert fvList;
  }
}