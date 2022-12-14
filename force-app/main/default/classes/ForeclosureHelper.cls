public without sharing class ForeclosureHelper {
  public static void beforeInsert(List<Foreclosure__c> newList) {
    Map<Id, Property__c> propMap = new Map<Id,Property__c>();

    for(Foreclosure__c f : newList) {
      if(f.Special_Asset__c == null && f.Property__c != null) {
        propMap.put(f.Property__c, new Property__c());
      }
    }

    propMap = new Map<Id,Property__c>([
      SELECT Id, Special_Asset__c FROM Property__c WHERE Id IN :propMap.keySet() AND Special_Asset__c != null
    ]);

    for(Foreclosure__c f : newList) {
      if(f.Special_Asset__c == null && f.Property__c !=null && propMap.containsKey(f.Property__c)) {
        f.Special_Asset__c = propMap.get(f.Property__c).Special_Asset__c;
      }
    }
  }
  public static void afterInsert(List<Foreclosure__c> newList) {
    Map<Id, Foreclosure__c> specAssetsToUpdate = new Map<Id, Foreclosure__c>();
    Map<Id, Foreclosure__c> propertiesToUpdate = new Map<Id,Foreclosure__c>();
    for (Foreclosure__c fc : newList) {
      if (fc.Special_Asset__c != null) {
        specAssetsToUpdate.put(fc.Id, fc);
      }
      if(fc.Property__c != null) {
        propertiesToUpdate.put(fc.Property__c, fc);
      }
    }

    if (specAssetsToUpdate.size() > 0) {
      updateSpecialAssets(specAssetsToUpdate, true);
    }

    if(propertiesToUpdate.size() > 0) {
      updateProperties(propertiesToUpdate);
    }
  }

  public static void afterUpdate(
    Map<Id, Foreclosure__c> oldMap,
    Map<Id, Foreclosure__c> newMap
  ) {
    Map<Id, Foreclosure__c> specAssetsToUpdate = new Map<Id, Foreclosure__c>();
    for (Id key : newMap.keySet()) {
      Foreclosure__c nFc = newMap.get(key);
      Foreclosure__c oFc = oldMap.get(key);
      if (
        nFc.Special_Asset__c != null &&
        (nFc.REO_date__c != oFc.REO_date__c ||
        nFc.Special_Asset__c != oFc.Special_Asset__c)
      ) {
        specAssetsToUpdate.put(key, nFc);
      }
    }

    if (specAssetsToUpdate.size() > 0) {
      updateSpecialAssets(specAssetsToUpdate, false);
    }
  }

  public static void updateProperties(Map<Id, Foreclosure__c> propertiesToUpdate) {
    List<Property__c> props = new List<Property__c>();

    for(Id propId : propertiesToUpdate.keySet()) {
      props.add(new Property__c(
        Id = propId,
        Foreclosure__c = propertiesToUpdate.get(propId).Id
      ));
    }

    update props;
  }

  public static void updateSpecialAssets(
    Map<Id, Foreclosure__c> fcMap,
    Boolean isInsert
  ) {
    Map<Id, Special_Asset__c> specAssets = new Map<Id, Special_Asset__c>(
      [
        SELECT Id, REO_Date__c
        FROM Special_Asset__c
        WHERE
          Id IN (
            SELECT Special_Asset__c
            FROM Foreclosure__c
            WHERE Id IN :fcMap.keySet()
          )
      ]
    );

    List<Special_Asset__c> forUpdate = new List<Special_Asset__c>();
    List<Foreclosure__c> forUpdateFc = new List<Foreclosure__c>();

    if (specAssets.size() > 0) {
      for (Foreclosure__c fc : fcMap.values()) {
        Special_Asset__c sa = specAssets.get(fc.Special_Asset__c);
        if (sa != null && sa.REO_Date__c != fc.REO_date__c) {
          if (isInsert && sa.REO_Date__c != null && fc.REO_Date__c == null) {
            forUpdateFc.add(
              new Foreclosure__c(Id = fc.Id, REO_date__c = sa.REO_Date__c)
            );
          } else {
            sa.REO_Date__c = fc.REO_date__c;
            forUpdate.add(sa);
          }
        }
      }
    }

    if (forUpdate.size() > 0) {
      update (forUpdate);
    }

    if (forUpdateFc.size() > 0) {
      update (forUpdateFc);
    }

  }
}