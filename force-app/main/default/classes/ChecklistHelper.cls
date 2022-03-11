public without sharing class ChecklistHelper {
  public static void createChecklist(Set<Id> opportunityIds) {
    Map<String, Id> recordTypeMap = new Map<String, Id>();

    for (RecordType rt : [
      SELECT Id, DeveloperName
      FROM RecordType
      WHERE Sobjecttype = 'Checklist_Item__c'
    ]) {
      recordTypeMap.put(rt.DeveloperName, rt.Id);
    }

    Map<Id, String> oppRecordTypeMap = new Map<Id, String>();

    for (Opportunity opp : [
      SELECT Id, RecordType.DeveloperName
      FROM Opportunity
      WHERE Id = :opportunityIds
    ]) {
      oppRecordTypeMap.put(opp.Id, opp.RecordType.DeveloperName);
    }

    Map<String, List<Checklist_Item_Config__mdt>> recordTypeConfigMap = new Map<String, List<Checklist_Item_Config__mdt>>();
    for (
      Checklist_Item_Config__mdt checklistConfig : [
        SELECT
          Id,
          RecordType__c,
          Responsible_Party__c,
          Approver__c,
          Milestone__c,
          Uploader__c,
          Reviewer__c,
          Checklist_Type__c,
          Checklist_Item_Name__c,
          sObject__c,
          Type__c,
          Use_Historical_Uploads__c,
          Document_Structure__c,
          Label,
          Document_Structure__r.Folder_Structure_String__c,
          Document_Structure__r.Document_Type__c,
          Is_Bulk__c
        // Is_Property_Level__c
        FROM Checklist_Item_Config__mdt
        WHERE
          RecordType__c IN :oppRecordTypeMap.values()
          AND sObject__c = 'Opportunity'
          AND Type__c != NULL
      ]
    ) {
      system.debug(checklistConfig.Label);
      if (!recordTypeConfigMap.containsKey(checklistConfig.RecordType__c)) {
        recordTypeConfigMap.put(
          checklistConfig.RecordType__c,
          new List<Checklist_Item_Config__mdt>()
        );
      }
      recordTypeConfigMap.get(checklistConfig.RecordType__c)
        .add(checklistConfig);
    }

    // system.debug(checklist)

    List<Checklist__c> checklists = new List<Checklist__c>();
    Map<Id, Checklist__c> dealChecklistMap = new Map<Id, Checklist__c>();
    Map<Id, Checklist_Section__c> dealSectionMap = new Map<Id, Checklist_Section__c>();
    for (Id oppId : oppRecordTypeMap.keySet()) {
      String recordTypeName = oppRecordTypeMap.get(oppId);
      if (recordTypeConfigMap.containsKey(recordTypeName)) {
        Checklist__c checklist = new Checklist__c();
        checklist.Deal__c = oppId;
        dealChecklistMap.put(oppId, checklist);
      }
    }

    //system.debug(dealChecklistMap.values());
    insert dealChecklistMap.values();

    for (Id oppId : oppRecordTypeMap.keySet()) {
      if (dealChecklistMap.containsKey(oppId)) {
        Checklist_Section__c section = new Checklist_Section__c();
        section.Type__c = 'Opportunity';
        section.Deal__c = oppId;
        section.Checklist__c = dealChecklistMap.get(oppId).Id;
        section.Name = 'Deal';
        dealSectionMap.put(section.Deal__c, section);
      }
    }

    insert dealSectionMap.values();

    system.debug(recordTypeConfigMap);
    List<Checklist_Item__c> checklistItems = new List<Checklist_Item__c>();
    for (Id oppId : oppRecordTypeMap.keySet()) {
      String recordTypeName = oppRecordTypeMap.get(oppId);
      if (recordTypeConfigMap.containsKey(recordTypeName)) {
        for (
          Checklist_Item_Config__mdt itemConfig : recordTypeConfigMap.get(
            recordTypeName
          )
        ) {
          Checklist_Item__c item = new Checklist_Item__c();
          item.Checklist_Section__c = dealSectionMap.get(oppId).Id;
          item.Deal__c = oppId;
          item.Status__c = 'Pending';
          item.Responsible_Party__c = itemConfig.Responsible_Party__c;
          item.Milestone__c = itemConfig.Milestone__c;
          item.Checklist_Type__c = itemConfig.Checklist_Type__c;
          item.Name = itemConfig.Checklist_Item_Name__c;
          item.Document_Type__c = itemConfig.Document_Structure__r.Document_Type__c;
          item.Doc_Structure_Id__c = itemConfig.Document_Structure__c;
          item.Folder_String__c = itemConfig.Document_Structure__r.Folder_Structure_String__c;
          item.Approver__c = itemConfig.Approver__c;
          item.Uploader__c = itemConfig.Approver__c;
          item.Reviewer__c = itemConfig.Reviewer__c;
          item.Is_Bulk__c = itemConfig.Is_Bulk__c;
          // item.Is_Property_Level__c = itemConfig.Is_Property_Level__c;

          if (itemConfig.Type__c == 'Upload') {
            item.RecordTypeId = recordTypeMap.get('Document_Upload'); //'012Z0000000aZRZIA2';
          } else if (itemConfig.Type__c == 'Action') {
            item.RecordTypeId = recordTypeMap.get('Task'); //'012Z0000000aZRUIA2';
          }

          checklistItems.add(item);
        }
      }
    }
    insert checklistItems;
  }

  @future
  public static void createChecklistSectionProperty(Set<Id> propertyIds) {
    Map<String, Id> recordTypeMap = new Map<String, Id>();

    for (RecordType rt : [
      SELECT Id, DeveloperName
      FROM RecordType
      WHERE Sobjecttype = 'Checklist_Item__c'
    ]) {
      recordTypeMap.put(rt.DeveloperName, rt.Id);
    }

    Map<Id, String> oppRecordTypeMap = new Map<Id, String>();
    Map<Id, Id> propertyDealMap = new Map<Id, Id>();
    Map<Id, List<Property__c>> dealPropertyMap = new Map<Id, List<Property__C>>();

    for (Property__c property : [
      SELECT Id, Name, Deal__c, Deal__r.RecordType.DeveloperName
      FROM Property__c
      WHERE Id IN :propertyIds
    ]) {
      propertyDealMap.put(property.Id, property.Deal__c);
      oppRecordTypeMap.put(
        property.Deal__c,
        property.Deal__r.RecordType.DeveloperName
      );

      if (!dealPropertyMap.containsKey(property.Deal__c)) {
        dealPropertyMap.put(property.Deal__c, new List<Property__c>());
      }

      dealPropertyMap.get(property.Deal__c).add(property);
    }

    //system.debug(oppRecordTypeMap);

    Map<String, List<Checklist_Item_Config__mdt>> recordTypeConfigMap = new Map<String, List<CHecklist_Item_Config__mdt>>();
    for (Checklist_Item_Config__mdt checklistConfig : [
      SELECT
        Id,
        Checklist_Item_Name__c,
        Milestone__c,
        Checklist_Type__c,
        RecordType__c,
        Responsible_Party__c,
        sObject__c,
        Type__c,
        Use_Historical_Uploads__c,
        Document_Structure__c,
        Document_Structure__r.Folder_Structure_String__c,
        Label,
        Document_Structure__r.Document_Type__c,
        Approver__c,
        Uploader__c,
        Reviewer__c,
        Is_Bulk__c
      FROM Checklist_Item_Config__mdt
      WHERE
        RecordType__c IN :oppRecordTypeMap.values()
        AND sObject__c = 'Property__c'
        AND Type__c != NULL
    ]) {
      if (!recordTypeConfigMap.containsKey(checklistConfig.RecordType__c)) {
        recordTypeConfigMap.put(
          checklistConfig.RecordType__c,
          new List<Checklist_Item_Config__mdt>()
        );
      }
      recordTypeConfigMap.get(checklistConfig.RecordType__c)
        .add(checklistConfig);
    }

    // Map<Id, Checklist_Section__c> c
    Map<Id, Checklist_Section__c> propertySectionMap = new Map<Id, Checklist_Section__C>();
    for (Checklist__c checklist : [
      SELECT Id, Deal__c
      FROM Checklist__c
      WHERE Deal__c IN :oppRecordTypeMap.keySet()
    ]) {
      // Checklist_Section__c checklistSection

      for (Property__c property : dealPropertyMap.get(checklist.Deal__c)) {
        String recordTypeName = property.Deal__r.RecordType.DeveloperName;
        if (recordTypeConfigMap.containsKey(recordTypeName)) {
          Checklist_Section__c section = new Checklist_Section__c();
          section.Checklist__c = checklist.Id;
          section.Property__c = property.Id;
          section.Name = property.Name;
          section.Type__c = 'Property';
          propertySectionMap.put(property.Id, section);
        }
      }
    }

    insert propertySectionMap.values();
    // system.debug(recordTypeConfigMap);
    List<Checklist_Item__c> checklistItems = new List<Checklist_Item__c>();
    for (Id oppId : oppRecordTypeMap.keySet()) {
      String recordTypeName = oppRecordTypeMap.get(oppId);
      if (recordTypeConfigMap.containsKey(recordTypeName)) {
        for (
          Checklist_Item_Config__mdt itemConfig : recordTypeConfigMap.get(
            recordTypeName
          )
        ) {
          for (Property__c property : dealPropertyMap.get(oppId)) {
            Checklist_Item__c item = new Checklist_Item__c();
            if (propertySectionMap.containsKey(property.Id)) {
              item.Checklist_Section__c = propertySectionMap.get(property.Id)
                .Id;
              item.Property__c = property.Id;
              item.Status__c = 'Pending';
              item.Responsible_Party__c = itemConfig.Responsible_Party__c;
              item.Milestone__c = itemConfig.Milestone__c;
              item.Checklist_Type__c = itemConfig.Checklist_Type__c;
              item.Name = itemConfig.Checklist_Item_Name__c;
              item.Document_Type__c = itemConfig.Document_Structure__r.Document_Type__c;
              item.Doc_Structure_Id__c = itemConfig.Document_Structure__c;
              item.Folder_String__c = itemConfig.Document_Structure__r.Folder_Structure_String__c;
              item.Approver__c = itemConfig.Approver__c;
              item.Uploader__c = itemConfig.Uploader__c;
              item.Reviewer__c = itemConfig.Reviewer__c;
              item.Is_Bulk__c = itemCOnfig.Is_Bulk__c;
              if (itemConfig.Type__c == 'Upload') {
                item.RecordTypeId = recordTypeMap.get('Document_Upload'); //'012Z0000000aZRZIA2';
              } else if (itemConfig.Type__c == 'Action') {
                item.RecordTypeId = recordTypeMap.get('Task'); //'012Z0000000aZRUIA2';
              }

              checklistItems.add(item);
            }
          }
        }
      }
    }

    insert checklistItems;
  }

  public static void createChecklistDealContact(Set<Id> dealContactIds) {
    Map<String, Id> recordTypeMap = new Map<String, Id>();

    for (RecordType rt : [
      SELECT Id, DeveloperName
      FROM RecordType
      WHERE Sobjecttype = 'Checklist_Item__c'
    ]) {
      recordTypeMap.put(rt.DeveloperName, rt.Id);
    }
    Map<Id, String> oppRecordTypeMap = new Map<Id, String>();
    Map<Id, Id> contactDealMap = new Map<Id, Id>();
    Map<Id, List<Deal_Contact__c>> dealContactMap = new Map<Id, List<Deal_Contact__c>>();

    for (Deal_Contact__c dealContact : [
      SELECT
        Id,
        Name,
        Contact__c,
        Deal__c,
        Deal__r.RecordType.DeveloperName,
        Vendor_Type__c,
        Entity_Type__c,
        Contact__r.Name,
        Account__r.Name
      FROM Deal_Contact__c
      WHERE Id IN :dealContactIds
    ]) {
      contactDealMap.put(dealContact.Id, dealContact.Deal__c);
      oppRecordTypeMap.put(
        dealContact.Deal__c,
        dealContact.Deal__r.RecordType.DeveloperName
      );

      if (!dealContactMap.containsKey(dealContact.Deal__c)) {
        dealContactMap.put(dealContact.Deal__c, new List<Deal_Contact__c>());
      }

      dealContactMap.get(dealContact.Deal__c).add(dealContact);
    }

    for (Checklist_Section__c section : [
      SELECT Id, Deal_Contact__c
      FROM Checklist_Section__c
      WHERE Deal_Contact__c IN :dealContactMap.keySet()
    ]) {
      dealContactMap.remove(section.Deal_Contact__c);
    }

    // system.debug(oppRecordTypeMap);

    Map<String, List<Checklist_Item_Config__mdt>> recordTypeConfigMap = new Map<String, List<Checklist_Item_Config__mdt>>();
    for (Checklist_Item_Config__mdt checklistConfig : [
      SELECT
        Id,
        RecordType__c,
        Responsible_Party__c,
        Milestone__c,
        Checklist_Item_Name__c,
        Checklist_Type__c,
        sObject__c,
        Type__c,
        Use_Historical_Uploads__c,
        Document_Structure__r.Folder_Structure_String__c,
        Label,
        Document_Structure__r.Document_Type__c,
        Approver__c,
        Uploader__c,
        Reviewer__c
      FROM Checklist_Item_Config__mdt
      WHERE
        RecordType__c IN :oppRecordTypeMap.values()
        AND sObject__c IN ('Sponsor', 'Legal', 'Guarantor')
        AND Type__c != NULL
    ]) {
      if (!recordTypeConfigMap.containsKey(checklistConfig.RecordType__c)) {
        recordTypeConfigMap.put(
          checklistConfig.RecordType__c,
          new List<Checklist_Item_Config__mdt>()
        );
      }
      recordTypeConfigMap.get(checklistConfig.RecordType__c)
        .add(checklistConfig);
    }

    // Map<Id, Checklist_Section__c> c
    Map<Id, Checklist_Section__c> dealContactSectionMap = new Map<Id, Checklist_Section__C>();
    for (Checklist__c checklist : [
      SELECT Id, Deal__c
      FROM Checklist__c
      WHERE Deal__c IN :oppRecordTypeMap.keySet()
    ]) {
      // Checklist_Section__c checklistSection

      for (
        Deal_Contact__c dealContact : dealContactMap.get(checklist.Deal__c)
      ) {
        String dcType = '';
        if (dealContact.Entity_Type__c != null) {
          dcType = dealContact.Entity_Type__c;
          if (dcType == 'Applicant') {
            dcType = 'Sponsor';
          }
        } else if (dealContact.Vendor_Type__c != null) {
          if (dealCOntact.Vendor_Type__c == 'Lender Legal Counsel') {
            dcType = 'Legal';
          } else {
            dcType = dealContact.Entity_Type__c;
          }
        }
        String recordTypeName = dealContact.Deal__r.RecordType.DeveloperName;
        if (recordTypeConfigMap.containsKey(recordTypeName)) {
          Checklist_Section__c section = new Checklist_Section__c();
          section.Checklist__c = checklist.Id;
          section.Deal_Contact__c = dealContact.Id;
          if (dealContact.Entity_Type__c != null) {
            section.Name = dealContact.Contact__r.Name;
          } else if (dealContact.Vendor_Type__c != null) {
            section.Name = dealContact.Account__r.Name;
          }
          section.Type__c = dcType;
          dealContactSectionMap.put(dealContact.Id, section);
        }
      }
    }

    insert dealContactSectionMap.values();
    //system.debug(recordTypeConfigMap);
    List<Checklist_Item__c> checklistItems = new List<Checklist_Item__c>();
    for (Id oppId : oppRecordTypeMap.keySet()) {
      String recordTypeName = oppRecordTypeMap.get(oppId);
      if (recordTypeConfigMap.containsKey(recordTypeName)) {
        for (
          Checklist_Item_Config__mdt itemConfig : recordTypeConfigMap.get(
            recordTypeName
          )
        ) {
          for (Deal_Contact__c dealContact : dealContactMap.get(oppId)) {
            String dcType = '';
            if (dealContact.Entity_Type__c != null) {
              dcType = dealContact.Entity_Type__c;
              if (dcType == 'Applicant') {
                dcType = 'Sponsor';
              }
            } else if (dealContact.Vendor_Type__c != null) {
              if (dealCOntact.Vendor_Type__c == 'Lender Legal Counsel') {
                dcType = 'Legal';
              } else {
                dcType = dealContact.Entity_Type__c;
              }
            }

            if (itemConfig.sobject__c == dcType) {
              Checklist_Item__c item = new Checklist_Item__c();
              if (dealContactSectionMap.containsKey(dealContact.Id)) {
                item.Checklist_Section__c = dealContactSectionMap.get(
                    dealContact.Id
                  )
                  .Id;
                item.Deal_Contact__c = dealContact.Id;
                item.Status__c = 'Pending';
                item.Responsible_Party__c = itemConfig.Responsible_Party__c;
                item.Milestone__c = itemConfig.Milestone__c;
                item.Checklist_Type__c = itemConfig.Checklist_Type__c;
                item.Name = itemConfig.Checklist_Item_Name__c;
                item.Document_Type__c = itemConfig.Document_Structure__r.Document_Type__c;
                item.Doc_Structure_Id__c = itemConfig.Document_Structure__c;
                item.Folder_String__c = itemConfig.Document_Structure__r.Folder_Structure_String__c;
                item.Approver__c = itemConfig.Approver__c;
                item.Uploader__c = itemConfig.Approver__c;
                item.Reviewer__c = itemConfig.Reviewer__c;
                if (itemConfig.Type__c == 'Upload') {
                  item.RecordTypeId = recordTypeMap.get('Document_Upload'); //'012Z0000000aZRZIA2';
                } else if (itemConfig.Type__c == 'Action') {
                  item.RecordTypeId = recordTypeMap.get('Task'); //'012Z0000000aZRUIA2';
                }

                checklistItems.add(item);
              }
            }
          }
        }
      }
    }

    insert checklistItems;
  }
}