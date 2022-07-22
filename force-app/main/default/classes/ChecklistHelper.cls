public without sharing class ChecklistHelper {
  public static void createChecklistAccount(Set<Id> accountIds) {
    Map<String, Id> recordTypeMap = new Map<String, Id>();

    for (RecordType rt : [
      SELECT Id, DeveloperName
      FROM RecordType
      WHERE Sobjecttype = 'Checklist_Item__c'
    ]) {
      recordTypeMap.put(rt.DeveloperName, rt.Id);
    }

    Map<Id, String> accRecordTypeMap = new Map<Id, String>();

    for (Account acc : [
      SELECT Id, RecordType.DeveloperName
      FROM Account
      WHERE Id = :accountIds
    ]) {
      accRecordTypeMap.put(acc.Id, acc.RecordType.DeveloperName);
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
          RecordType__c IN :accRecordTypeMap.values()
          AND sObject__c = 'Account'
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
    Map<Id, Checklist__c> accChecklistMap = new Map<Id, Checklist__c>();
    Map<Id, Checklist_Section__c> accSectionMap = new Map<Id, Checklist_Section__c>();
    for (Id accId : accRecordTypeMap.keySet()) {
      String recordTypeName = accRecordTypeMap.get(accId);
      if (recordTypeConfigMap.containsKey(recordTypeName)) {
        Checklist__c checklist = new Checklist__c();
        checklist.Milestone__c = 'Onboarding';
        checklist.Account__c = accId;
        accChecklistMap.put(accId, checklist);
      }
    }

    //system.debug(dealChecklistMap.values());
    insert accChecklistMap.values();

    for (Id accId : accRecordTypeMap.keySet()) {
      if (accChecklistMap.containsKey(accId)) {
        Checklist_Section__c section = new Checklist_Section__c();
        section.Type__c = 'Lender';
        section.Account__c = accId;
        section.Checklist__c = accChecklistMap.get(accId).Id;
        section.Name = 'Lender';
        accSectionMap.put(section.Account__c, section);
      }
    }

    insert accSectionMap.values();

    system.debug(recordTypeConfigMap);
    List<Checklist_Item__c> checklistItems = new List<Checklist_Item__c>();
    for (Id accId : accRecordTypeMap.keySet()) {
      String recordTypeName = accRecordTypeMap.get(accId);
      if (recordTypeConfigMap.containsKey(recordTypeName)) {
        for (
          Checklist_Item_Config__mdt itemConfig : recordTypeConfigMap.get(
            recordTypeName
          )
        ) {
          Checklist_Item__c item = new Checklist_Item__c();
          item.Checklist_Section__c = accSectionMap.get(accId).Id;
          item.Account__c = accId;
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
      SELECT Id, RecordType.DeveloperName, LOC_Loan_Type__c
      FROM Opportunity
      WHERE Id = :opportunityIds
    ]) {
      if (opp.LOC_Loan_Type__c == 'Multifamily/CRE') {
        oppRecordTypeMap.put(opp.Id, 'CRE_Loan');
      } else {
        oppRecordTypeMap.put(opp.Id, opp.RecordType.DeveloperName);
      }
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
        checklist.Milestone__c = 'Kick-Off';
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
      SELECT
        Id,
        Name,
        Deal__c,
        Deal__r.RecordType.DeveloperName,
        Deal__r.LOC_Loan_Type__c
      FROM Property__c
      WHERE Id IN :propertyIds
    ]) {
      propertyDealMap.put(property.Id, property.Deal__c);
      if (property.Deal__r.LOC_Loan_Type__c == 'Multifamily/CRE') {
        oppRecordTypeMap.put(property.Deal__c, 'CRE_Loan');
      } else {
        oppRecordTypeMap.put(
          property.Deal__c,
          property.Deal__r.RecordType.DeveloperName
        );
      }

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
        if (property.Deal__r.LOC_Loan_Type__c == 'Multifamily/CRE') {
          recordTypeName = 'CRE_Loan';
        }
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

  @future
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
    // Map<Id, Set<Id>> dealContactMap = new Map<Id, Set<Id>>();
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
        Account__r.Name,
        Deal__r.LOC_Loan_Type__c
      FROM Deal_Contact__c
      WHERE Id IN :dealContactIds
    ]) {
      contactDealMap.put(dealContact.Id, dealContact.Deal__c);
      if (dealContact.Deal__r.LOC_Loan_Type__c == 'Multifamily/CRE') {
        oppRecordTypeMap.put(dealContact.Deal__c, 'CRE_Loan');
      } else {
        oppRecordTypeMap.put(
          dealContact.Deal__c,
          dealContact.Deal__r.RecordType.DeveloperName
        );
      }

      if (!dealContactMap.containsKey(dealContact.Deal__c)) {
        dealContactMap.put(dealContact.Deal__c, new List<Deal_Contact__c>());
        // dealContactMap.put(dealCOntact.Deal__c, new Set<Id>());
      }

      dealContactMap.get(dealContact.Deal__c).add(dealContact);
    }

    for (Checklist_Section__c section : [
      SELECT Id, Contact__c, Checklist__r.Deal__c
      FROM Checklist_Section__c
      WHERE Checklist__r.Deal__c IN :dealContactMap.keySet()
    ]) {
      if (dealCOntactMap.containsKey(section.Checklist__r.Deal__c)) {
        //if(dealContactMap.get(Checklist__r.Deal__c.contains))
        List<Deal_Contact__c> dcList = dealContactMap.get(
          section.Checklist__r.Deal__c
        );
        for (Integer i = dcList.size() - 1; i >= 0; i--) {
          if (dcList[i].Contact__c == section.Contact__c) {
            dcList.remove(i);
          }
        }
      }
      // dealContactMap.remove(section.Deal_Contact__c);
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
        if (dealContact.Deal__r.LOC_Loan_Type__c == 'Multifamily/CRE') {
          recordTypeName = 'CRE_Loan';
        }
        if (recordTypeConfigMap.containsKey(recordTypeName)) {
          Checklist_Section__c section = new Checklist_Section__c();
          section.Checklist__c = checklist.Id;
          section.Contact__c = dealContact.Contact__c;
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
                item.Contact__c = dealContact.Contact__c;
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

    reuseDocuments(checklistItems);
  }

  public static void reuseDocuments(List<Checklist_Item__c> items) {
    Set<Id> docStructureIds = new Set<Id>();
    Set<Id> itemIds = new Set<Id>();
    Map<Id, List<Checklist_Item__c>> contactItemMap = new Map<Id, List<Checklist_Item__c>>();

    List<Checklist_Item__c> itemsNeedDocuments = new List<Checklist_Item__c>();
    for (Checklist_Item__c item : items) {
      if (
        item.Checklist_Type__c == 'Sponsor' ||
        item.Checklist_Type__c == 'Guarantor'
      ) {
        itemsNeedDocuments.add(item);
        itemIds.add(item.Id);
        docStructureIds.add(item.Doc_Structure_Id__c);
        if (!contactItemMap.containsKey(item.Contact__c)) {
          contactItemMap.put(item.Contact__c, new List<Checklist_Item__c>());
        }
        contactItemMap.get(item.Contact__c).add(item);
      }
    }

    Map<Id, Map<Id, Checklist_Item__c>> conDocStructItemMap = new Map<Id, Map<Id, Checklist_Item__c>>();
    for (Checklist_Item__c item : [
      SELECT
        Id,
        Doc_Structure_Id__c,
        Contact__c,
        CreatedDate,
        (
          SELECT
            Id,
            Reviewed_On__c,
            Reviewed_By__c,
            Added_By__c,
            Added_On__c,
            ContentVersion_Id__c,
            Attachment_Id__c,
            Deal__c,
            File_Name__c
          FROM Deal_Documents__r
          WHERE
            (Expiration_Date__c = NULL
            OR Expiration_Date__c <= TODAY)
            AND Status__c != 'Rejected'
        )
      FROM Checklist_Item__c
      WHERE
        Contact__c IN :contactItemMap.keySet()
        AND Id NOT IN :itemIds
        AND Doc_Structure_Id__c IN :docStructureIds
    ]) {
      if (item.Deal_Documents__r.size() > 0) {
        if (!conDocStructItemMap.containsKey(item.Contact__c)) {
          conDocStructItemMap.put(
            item.Contact__c,
            new Map<Id, Checklist_Item__c>()
          );
        }

        if (
          !conDocStructItemMap.get(item.Contact__c)
            .containsKey(item.Doc_Structure_Id__c)
        ) {
          conDocStructItemMap.get(item.Contact__c)
            .put(item.Doc_Structure_Id__c, item);
        } else {
          Checklist_Item__c existingItem = conDocStructItemMap.get(
              item.Contact__c
            )
            .get(item.Doc_Structure_Id__c);
          if (existingItem.createdDate < item.CreatedDate) {
            conDocStructItemMap.get(item.Contact__c)
              .put(item.Doc_Structure_Id__c, item);
          }
        }
      }
    }

    List<Deal_Document__c> dealDocs = new List<Deal_Document__c>();
    for (Checklist_Item__c item : itemsNeedDocuments) {
      Id contactId = item.Contact__c;
      Id docStructureId = item.Doc_Structure_Id__c;

      if (
        conDocStructItemMap.containsKey(contactId) &&
        conDocStructItemMap.get(contactId).containsKey(docStructureId)
      ) {
        Checklist_Item__c existingItem = conDocStructItemMap.get(
            item.Contact__c
          )
          .get(item.Doc_Structure_Id__c);

        for (Deal_Document__c dealDoc : existingItem.Deal_Documents__r) {
          Deal_Document__c newDealDoc = new Deal_Document__c();
          newDealDoc.Status__c = 'Not Reviewed';
          newDealDoc.Added_By__c = dealDoc.Added_By__c;
          newDealDoc.Added_On__c = dealDoc.Added_On__c;
          newDealDoc.ContentVersion_Id__c = dealDoc.ContentVersion_Id__c;
          newDealDoc.Attachment_Id__c = dealDoc.Attachment_Id__c;
          newDealDoc.Deal__c = dealDoc.Deal__c;
          newDealDoc.Checklist_Item__c = item.Id;
          newDealDoc.File_Name__c = dealDoc.File_Name__c;
          dealDocs.add(newDealDoc);
        }
      }
    }

    insert dealDocs;

    List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
    for (Deal_Document__c dealDoc : dealDocs) {
      ContentDocumentLink cdl = new ContentDocumentLink();
      cdl.ContentDocumentId = dealDoc.Attachment_Id__c;
      cdl.LinkedEntityId = dealDoc.Id;
      cdl.ShareType = 'V';
      cdl.Visibility = 'AllUsers';
      cdls.add(cdl);
    }

    insert cdls;
  }
}