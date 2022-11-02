public without sharing class PropertyExtensionHelper {
  public static final String SNAPSHOT_ENTITY = 'Extension Completed';
  public static final List<String> FIELDS_FOR_DEAL = new List<String>{
    'Modified_Floor__c',
    'Modified_Margin__c',
    'Modified_Interest_Rate__c'
  };

  public static final List<String> COMPLETE_STATUSES = new List<String>{
    'Complete - Paid',
    'Complete - Bill to Loan'
  };

  public static void beforeInsert(List<Property_Extension__c> newList) {
    // Index Rate + Modified Margin (Index Rate new field, question pending)
    // if modified floor > index rate
    Map<Id, Property__c> propMap = new Map<Id, Property__c>();

    for (Property_Extension__c pe : newList) {
      if (pe.Property__c != null && pe.Modified_Margin__c != null) {
        propMap.put(pe.Property__c, new Property__c());
      }
    }

    propMap = new Map<Id, Property__c>(
      [
        SELECT Id, Deal__r.Interest_Rate_Type__c, Deal__r.Index_Rate__c
        FROM Property__c
        WHERE
          Id IN :propMap.keySet()
          AND Deal__r.Interest_Rate_Type__c = 'Floating'
      ]
    );

    if (propMap.size() > 0) {
      for (Property_Extension__c pe : newList) {
        if (pe.Property__c != null && propMap.containsKey(pe.Property__c)) {
          Property__c p = propMap.get(pe.Property__c);

          if (
            p.Deal__r.Index_Rate__c != null &&
            (pe.Modified_Floor__c == null ||
            pe.Modified_Floor__c <= p.Deal__r.Index_Rate__c)
          ) {
            pe.Modified_Interest_Rate__c =
              p.Deal__r.Index_Rate__c + pe.Modified_Margin__c;
          } else if (
            pe.Modified_Floor__c != null &&
            (p.Deal__r.Index_Rate__c == null ||
            p.Deal__r.Index_Rate__c < pe.Modified_Floor__c)
          ) {
            pe.Modified_Interest_Rate__c =
              pe.Modified_Floor__c + pe.Modified_Margin__c;
          }
        }
      }
    }
  }

  public static void afterInsert(Map<Id, Property_Extension__c> newMap) {
    Set<Id> propertyIds = new Set<Id>();
    Map<String, Map<Id, Property_Extension__c>> forSnapshotMap = new Map<String, Map<Id, Property_Extension__c>>();
    List<Property__c> propsToUpdate = new List<Property__c>();
    Map<Id, Opportunity> propOppMap = new Map<Id, Opportunity>();
    for (Property_Extension__c pE : newMap.values()) {
      propertyIds.add(pE.Property__c);
      propsToUpdate.add(
        new Property__c(
          Id = pE.Property__c,
          Newest_Property_Extension__c = pE.Id
        )
      );
      if (pE.Extension_Date__c != null) {
        if (forSnapshotMap.containsKey(SNAPSHOT_ENTITY)) {
          Map<Id, Property_Extension__c> propExMap = forSnapshotMap.get(
            SNAPSHOT_ENTITY
          );
          propExMap.put(pE.Id, pE);
          forSnapshotMap.put(SNAPSHOT_ENTITY, propExMap);
        } else {
          forSnapshotMap.put(
            SNAPSHOT_ENTITY,
            new Map<Id, Property_Extension__c>{ pE.Id => pE }
          );
        }
      }

      if (shouldUpdateDeal(pE, null)) {
        Opportunity newDeal = new Opportunity();

        for (String field : FIELDS_FOR_DEAL) {
          if (pE.get(field) != null) {
            newDeal.put(field, pE.get(field));
          }
        }

        propOppMap.put(pE.Property__c, newDeal);
      }
    }

    if (propsToUpdate.size() > 0) {
      update propsToUpdate;
    }

    if (propOppMap.size() > 0) {
      updateDealFromQuery(propOppMap);
    }

    if (forSnapshotMap.size() > 0) {
      PropertySnapshotHelper.createPropertySnapshot(forSnapshotMap);
    }

    Map<Id, Property__c> propMap = getFirstPropertyExtensions(propertyIds);

    if (propMap.size() > 0) {
      List<Property_Extension__c> propExtensions = new List<Property_Extension__c>();

      for (Property_Extension__c pE : newMap.values()) {
        Property__c p = propMap.get(pE.Property__c);
        if (
          p.Property_Extensions__r != null &&
          p.Property_Extensions__r[0].Id == pE.Id
        ) {
          Property_Extension__c updatedPe = new Property_Extension__c(
            Id = pE.Id,
            Is_First__c = true
          );
          propExtensions.add(updatedPe);
        }
      }

      if (propExtensions.size() > 0) {
        update propExtensions;
      }
    }
  }

  public static void beforeUpdate(
    Map<Id, Property_Extension__c> oldMap,
    Map<Id, Property_Extension__c> newMap
  ) {
    Map<Id, Property__c> propMap = new Map<Id, Property__c>();

    for (Id recId : newMap.keySet()) {
      Property_Extension__c n = newMap.get(recId);
      Property_Extension__c o = oldMap.get(recId);

      if (
        n.Modified_Floor__c != o.Modified_Floor__c ||
        n.Modified_Margin__c != n.Modified_Margin__c
      ) {
        propMap.put(n.Property__c, new Property__c());
      }
    }

    if (propMap.keySet().size() > 0) {
      propMap = new Map<Id, Property__c>(
        [
          SELECT Id, Deal__r.Interest_Rate_Type__c
          FROM Property__c
          WHERE
            Id IN :propMap.keySet()
            AND Deal__r.Interest_Rate_Type__c = 'Floating'
        ]
      );

      for (Id recId : newMap.keySet()) {
        Property_Extension__c n = newMap.get(recId);
        Property_Extension__c o = oldMap.get(recId);

        if (
          (n.Modified_Floor__c != o.Modified_Floor__c ||
          n.Modified_Margin__c != n.Modified_Margin__c) &&
          propMap.containsKey(n.Property__c)
        ) {
          // Index Rate + Modified Margin (Index Rate new field, question pending)
          // if modified floor > index rate
          // Modified Margin + Modified Floor

          Boolean calculateNone = n.Modified_Margin__c == null;
          Boolean calculateFirst = !calculateNone && n.Index_Rate__c != null && (n.Modified_Floor__c == null || n.Modified_Floor__c <= n.Index_Rate__c);
          Boolean calculateSecond = !calculateNone && !calculateFirst && n.Modified_Floor__c != null && (n.Index_Rate__c == null || n.Index_Rate__c < n.Modified_Floor__c);
          
          n.Modified_Interest_Rate__c = calculateFirst ? n.Index_Rate__c + n.Modified_Margin__c : calculateSecond ? n.Modified_Floor__c + n.Modified_Margin__c : null;
        }
      }
    }
  }

  public static void afterUpdate(
    Map<Id, Property_Extension__c> oldMap,
    Map<Id, Property_Extension__c> newMap
  ) {
    Set<Id> propertyIds = new Set<Id>();
    Map<String, Map<Id, Property_Extension__c>> forSnapshotMap = new Map<String, Map<Id, Property_Extension__c>>();
    Map<Id, Opportunity> propOppMap = new Map<Id, Opportunity>();

    for (Id key : newMap.keySet()) {
      Property_Extension__c oldPe = oldMap.get(key);
      Property_Extension__c newPe = newMap.get(key);

      if (oldPe.Extension_Date__c == null && newPe.Extension_Date__c != null) {
        if (forSnapshotMap.containsKey(SNAPSHOT_ENTITY)) {
          Map<Id, Property_Extension__c> propExMap = forSnapshotMap.get(
            SNAPSHOT_ENTITY
          );
          propExMap.put(key, newPe);
          forSnapshotMap.put(SNAPSHOT_ENTITY, propExMap);
        } else {
          forSnapshotMap.put(
            SNAPSHOT_ENTITY,
            new Map<Id, Property_Extension__c>{ key => newPe }
          );
        }
      }

      if (shouldUpdateDeal(newPe, oldPe)) {
        Opportunity newDeal = new Opportunity();

        for (String field : FIELDS_FOR_DEAL) {
          if (newPe.get(field) != null) {
            newDeal.put(field, newPe.get(field));
          }
        }

        propOppMap.put(newPe.Property__c, newDeal);
      }

      if (
        oldPe.Extension_Date__c != newPe.Extension_Date__c ||
        oldPe.Original_Asset_Maturity_Date_Formula__c !=
        newPe.Original_Asset_Maturity_Date_Formula__c ||
        oldPe.New_Asset_Maturity_Date__c != newPe.New_Asset_Maturity_Date__c
      ) {
        propertyIds.add(newPe.Property__c);
      }
    }

    if (propOppMap.size() > 0) {
      updateDealFromQuery(propOppMap);
    }

    if (forSnapshotMap.size() > 0) {
      PropertySnapshotHelper.createPropertySnapshot(forSnapshotMap);
    }

    if (propertyIds.size() > 0) {
      Map<Id, Property__c> propMap = getFirstPropertyExtensions(propertyIds);

      if (propMap.size() > 0) {
        List<Property_Extension__c> propExtensions = new List<Property_Extension__c>();

        for (Property_Extension__c pE : newMap.values()) {
          Property__c p = propMap.get(pE.Property__c);
          Property_Extension__c updatedPe = new Property_Extension__c(
            Id = pE.Id
          );
          if (pE.Extension_Date__c != null) {
            // // updatedPe.Days_To_Resolve__c = calculateDaysToResolve(
            //   pE,
            //   p.Property_Extensions__r != null &&
            //   p.Property_Extensions__r.size() > 0 &&
            //   p.Property_Extensions__r[0].Id == pE.Id
            // );

            propExtensions.add(updatedPe);
          }
        }

        if (propExtensions.size() > 0) {
          update propExtensions;
        }
      }
    }
  }

  public static Map<Id, Property__c> getFirstPropertyExtensions(
    Set<Id> propIds
  ) {
    return propIds.size() > 0
      ? new Map<Id, Property__c>(
          [
            SELECT
              Id,
              (
                SELECT Id
                FROM Property_Extensions__r
                ORDER BY CreatedDate ASC
                LIMIT 1
              )
            FROM Property__c
            WHERE Id IN :propIds
          ]
        )
      : new Map<Id, Property__c>();
  }

  public static void updateDealFromQuery(Map<Id, Opportunity> propOppMap) {
    List<Opportunity> deals = new List<Opportunity>();
    for (Property__c prop : [
      SELECT Id, Deal__c
      FROM Property__c
      WHERE Id IN :propOppMap.keySet()
    ]) {
      Opportunity d = propOppMap.get(prop.Id);
      d.Id = prop.Deal__c;
      deals.add(d);
    }

    update deals;
  }

  public static Boolean shouldUpdateDeal(
    Property_Extension__c n,
    Property_Extension__c o
  ) {
    return (n.Property__c != null) &&
      (o == null
        ? n.Modified_Floor__c != null ||
          n.Modified_Margin__c != null ||
          n.Modified_Interest_Rate__c != null
        : n.Modified_Floor__c != o.Modified_Floor__c ||
          n.Modified_Margin__c != o.Modified_Margin__c ||
          n.Modified_Interest_Rate__c != o.Modified_Interest_Rate__c);
  }
}