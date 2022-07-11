public without sharing class TitleOrderHelper {
  public static void beforeInsert(List<Title_Order__c> newList) {
    Set<Id> propIds = new Set<Id>();

    for (Title_Order__c to : newList) {
      if (String.isEmpty(to.Asset_ID__c)) {
        propIds.add(to.Property__c);
      }
    }

    Map<Id, Property__c> propMap = new Map<Id, Property__c>(
      [
        SELECT Id, Asset_ID__c
        FROM Property__c
        WHERE Id IN :propIds AND Asset_ID__c != NULL
      ]
    );

    for (Title_Order__c to : newList) {
      if (propMap.containsKey(to.Property__c)) {
        to.Asset_ID__c = propMap.get(to.Property__c).Asset_ID__c;
      }
    }
  }
}
