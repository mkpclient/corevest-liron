public without sharing class ChecklistController {
  public static Map<Id, List<Deal_Document__c>> itemDocMap;
  public static Map<Id, List<Comment__c>> itemCommentMap;

  @AuraEnabled
  public static void updateChecklist(Checklist__c checklist) {
    try {
      update checklist;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static List<PortalAPIComments.Comment> getComments(Id itemId) {
    try {
      List<PortalAPIComments.Comment> comments = new List<PortalAPIComments.Comment>();
      for (Comment__c comment : [
        SELECT
          Id,
          Deal__c,
          Lead__r.Name,
          Contact__r.Name,
          Lead__c,
          Contact__c,
          Application__c,
          Body__c,
          Alchemy_Portal_Id__c,
          Submitted_From_Portal__c,
          Deal_Document__c,
          Property__c,
          CreatedDate,
          Owner.Name,
          Owner.Id,
          Subject__c,
          Comment__c,
          Owner_Image__c,
          Application__r.Name,
          Property__r.Name,
          Deal__r.Name,
          Deal_Document__r.Name,
          Unread__c,
          Checklist_Item__c
        FROM Comment__c
        WHERE Checklist_ITem__c = :itemId
      ]) {
        comments.add(new PortalAPIComments.Comment(comment));
      }

      return comments;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static List<Map<String, String>> queryDocumentTypes(Id sectionId) {
    try {
      Checklist_Section__c section = [
        SELECT
          Id,
          Type__c,
          Deal__c,
          Checklist__r.Deal__c,
          Checklist__r.Account__c,
          Property__c,
          Deal_Contact__c,
          Deal_Contact__r.Name
        FROM Checklist_Section__c
        WHERE Id = :sectionId
      ];

      String recordType = '';

      String sobjectType = '';

      if (
        section.Type__c == 'Opportunity' ||
        section.Type__c == 'Sponsor' ||
        section.Type__c == 'Applicant' ||
        section.Type__c == 'Borrower' ||
        section.Type__c == 'Lender'
      ) {
        sobjectType = 'Opportunity';
      } else if (section.Type__c == 'Account') {
        sobjectType = 'Account';
      } else if (section.Type__c == 'Property') {
        sobjectType = 'Property__c';
      } else if (section.Type__c == 'Advance') {
        sobjectType = 'Advance__c';
      } else if (section.Type__c == 'Lender') {
        sobjectType = 'Account';
      }

      recordType = [
        SELECT Id, RecordType.DeveloperName
        FROM Opportunity
        WHERE Id = :section.Checklist__r.Deal__c
      ]
      .RecordType.DeveloperName;

      List<Map<String, String>> documentTypes = new List<Map<String, String>>();

      for (Document_Structure__mdt structure : [
        SELECT Id, Document_Type__c
        FROM Document_Structure__mdt
        WHERE sObject__c = :sobjectType AND RecordType__c = :recordType
        ORDER BY Document_Type__c ASC
      ]) {
        documentTypes.add(
          new Map<String, String>{
            'label' => structure.Document_Type__c,
            'value' => structure.Id
          }
        );
      }

      return documentTypes;

      // if(section.Type__c == 'Property' || )
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static void approveItems(List<Id> itemIds) {
    try {
      List<Checklist_Item__c> items = new List<Checklist_Item__c>();
      for (Id itemId : itemIds) {
        Checklist_Item__c item = new Checklist_Item__c();
        item.Id = itemId;
        item.Status__c = 'Completed';
        items.add(item);
      }

      update items;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static List<Checklist_Item__c> upsertItems(
    List<Checklist_Item__c> items
  ) {
    try {
      upsert items;
      return items;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static void deleteItems(List<Checklist_Item__c> items) {
    try {
      delete items;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static void deleteItem(Id itemId) {
    try {
      delete new Checklist_Item__c(Id = itemId);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static Checklist_Item__c upsertItem(
    Checklist_Item__c item,
    String itemType
  ) {
    try {
      if (itemType != null) {
        Map<String, Id> recordTypeMap = new Map<String, Id>();

        for (RecordType rt : [
          SELECT Id, DeveloperName
          FROM RecordType
          WHERE Sobjecttype = 'Checklist_Item__c'
        ]) {
          recordTypeMap.put(rt.DeveloperName, rt.Id);
        }

        if (itemType == 'upload') {
          item.RecordTypeId = recordTypeMap.get('Document_Upload');
        } else {
          item.RecordTypeId = recordTypeMap.get('Task');
        }
      }

      upsert item;
      return item;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static List<Checklist_Item__c> insertItems(
    List<Checklist_Item__c> items,
    String itemType
  ) {
    system.debug(itemType);
    try {
      if (itemType != null) {
        Map<String, Id> recordTypeMap = new Map<String, Id>();

        for (RecordType rt : [
          SELECT Id, DeveloperName
          FROM RecordType
          WHERE Sobjecttype = 'Checklist_Item__c'
        ]) {
          recordTypeMap.put(rt.DeveloperName, rt.Id);
        }

        Id recordTypeId = null;

        if (itemType == 'upload') {
          recordTypeId = recordTypeMap.get('Document_Upload');
        } else {
          recordTypeId = recordTypeMap.get('Task');
        }

        system.debug(recordTypeId);

        for (Checklist_Item__c item : items) {
          item.RecordTypeId = recordTypeId;
        }
      }

      insert items;
      return items;
    } catch (Exception e) {
      // e.getLineNumber();
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static void handleUpload(Id itemId, List<Id> contentVersionIds) {
    try {
      Checklist_Item__c item = [
        SELECT
          Id,
          Doc_Structure_Id__c,
          Property__c,
          Deal__c,
          Property__r.Deal__c,
          Checklist_Section__r.Checklist__r.Deal__c,
          Checklist_Section__r.Property__c
        FROM Checklist_Item__c
        WHERE Id = :itemId
        LIMIT 1
      ];

      item.Status__c = 'Uploaded';
      update item;

      List<Deal_Document__c> dealDocs = new List<Deal_Document__c>();
      List<ContentVersion> cvs = new List<ContentVersion>();
      List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
      for (ContentVersion cv : [
        SELECT Id, Title, ContentDocumentId
        FROM ContentVersion
        WHERE Id IN :contentVersionIds
      ]) {
        Deal_Document__c dealDoc = new Deal_Document__c();
        dealDoc.Document_Structure_Id__c = item.Doc_Structure_Id__c;
        dealDoc.File_Name__c = cv.Title;
        dealDoc.ContentVersion_Id__c = cv.Id;
        dealDoc.Attachment_Id__c = cv.ContentDocumentId;
        //dealDoc.Deal__c = item.Deal__c;
        dealDoc.Deal__c = item.Checklist_Section__r.Checklist__r.Deal__c;
        dealDoc.Property__c = item.Checklist_Section__r.Property__c;
        dealDoc.Status__c = 'Not Reviewed';
        if (String.isNotBlank(item.Property__c)) {
          dealDoc.Property__c = item.Property__c;
          dealDoc.Deal__c = item.Deal__c;
        }
        dealDoc.Document_Loaded__c = true;

        dealDoc.Checklist_Item__c = itemId;

        dealDoc.Added_By__c = UserInfo.getUserId();
        dealDoc.Added_On__c = system.now();
        dealDocs.add(dealDoc);

        cv.Linked_To_Record__c = true;
        cvs.add(cv);
      }

      insert dealDocs;
      update cvs;

      for (Deal_Document__c doc : dealDocs) {
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = doc.Attachment_Id__c;
        cdl.LinkedEntityId = doc.Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        cdls.add(cdl);
      }

      insert cdls;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static String init(Id recordId, String objectApiName) {
    system.debug(recordId);

    Checklist__c checklistRecord = [
      SELECT Id, Milestone__c
      FROM Checklist__c
      WHERE Deal__c = :recordId OR Account__c = :recordId
      LIMIT 1
    ];

    //system.debug(checklistId);

    List<Checklist_Section__c> sections = [
      SELECT
        Id,
        Name,
        Contact__c,
        Deal__c,
        Deal__r.Name,
        Deal_Contact__c,
        Documents_Reviewed__c,
        Documents_Uploaded__c,
        Property__c,
        Property__r.Name,
        Total_Documents__c,
        Type__c,
        Deal_Contact__r.Name,
        Deal_Contact__r.Contact__r.Name,
        Account__r.Name,
        Account__c,
        (
          SELECT
            Id,
            Checklist_Type__c,
            Contact__c,
            Deal__c,
            Deal_Contact__c,
            Doc_Structure_Id__c,
            Document_Type__c,
            Document_Category__c,
            Is_Property_Level__c,
            Milestone__c,
            Responsible_Party__c,
            Reviewed__c,
            Status__c,
            Uploaded__c,
            Uploaded_Date__c,
            User_Assigned__c,
            User_Assigned__r.Name,
            Name,
            Deal__r.Name,
            Property__r.Name,
            Deal_Contact__r.Name,
            Deal_Contact__r.Contact__r.Name,
            Deal_Contact__r.Contact__c,
            RecordType.Name,
            Comments__c,
            External_Comments__c,
            Uploader__c,
            Account__r.Name,
            Account__c
          FROM Checklist_Items__r
          ORDER BY Name ASC
        )
      FROM Checklist_Section__c
      WHERE Checklist__c = :checklistRecord.Id
    ];

    itemDocMap = new Map<Id, List<Deal_Document__c>>();
    itemCommentMap = new Map<Id, List<Comment__c>>();
    for (Checklist_Section__c section : sections) {
      for (Checklist_Item__c item : section.Checklist_Items__r) {
        itemDocMap.put(item.Id, new List<Deal_Document__c>());
        itemCommentMap.put(item.Id, new List<Comment__c>());
      }
    }

    // for()

    for (Checklist_Item__c item : [
      SELECT Id, (SELECT Id, Is_Expired__c FROM Deal_Documents__r)
      FROM Checklist_Item__c
      WHERE Id IN :itemDocMap.keySet()
    ]) {
      itemDocMap.put(item.Id, item.Deal_Documents__r);
    }

    for (Checklist_Item__c item : [
      SELECT Id, (SELECT Id FROM Comments__r)
      FROM Checklist_Item__c
      WHERE Id IN :itemDocMap.keySet()
    ]) {
      itemCommentMap.put(item.Id, item.Comments__r);
    }

    Checklist checklist = new Checklist(checklistRecord, sections);
    checklist.populateMilestones();

    return JSON.serialize(checklist);
  }

  public class Milestone {
    public String name;
    public List<Section> sections;

    public transient Map<Id, Section> sectionMap;
    public transient Map<Id, Item> itemMap;

    Milestone(String milestone) {
      this.name = milestone;
      this.sections = new List<Section>();
      this.sectionMap = new Map<Id, Section>();
    }

    public void addItem(Section section, Item item) {
      if (!this.sectionMap.containsKey(section.Id)) {
        Section milestoneSection = new Section(section);
        this.sections.add(milestoneSection);
        this.sectionMap.put(milestoneSection.Id, milestoneSection);
      }

      this.sectionMap.get(section.id).addItem(item);
    }
  }

  public class Checklist {
    public Id id;
    public transient List<Section> sections;
    List<Milestone> milestones;
    public transient Map<Id, Item> itemMap;
    public String currentMilestone;
    // transient Map<String, Milestone> milestoneMap;

    Checklist(Checklist__c check, List<Checklist_Section__c> sections) {
      this.id = check.id;
      this.sections = new List<Section>();
      // this.itemMap = new Map<Id, Item>();
      this.currentMilestone = check.Milestone__c;
      // this.milestones = new List<String>();

      for (Checklist_Section__c section : sections) {
        this.sections.add(new Section(section));
      }

      // for (Section section : this.sections) {
      //   for (Item item : section.items) {
      //     itemMap.put(item.id, item);
      //   }
      // }
    }

    public void populateMilestones() {
      Map<String, Milestone> milestoneMap = new Map<String, Milestone>();
      // Set<String> milestones = new Set<String>();
      for (Section section : this.sections) {
        for (Item item : section.items) {
          if (!milestoneMap.containsKey(item.milestone)) {
            milestoneMap.put(item.milestone, new Milestone(item.milestone));
          }
          // system.debug(item.milestone);
          // system.debug(milestoneMap.get(item.milestone));
          // system.debug(section);
          // system.debug(item);
          milestoneMap.get(item.milestone).addItem(section, item);
          //milestones.add(item.milestone);
        }
      }

      this.milestones = milestoneMap.values();

      // this.milestones = new List<String>(milestones);
    }
  }

  public class Section {
    public String name;
    public String sectionType;
    public transient List<Item> items;
    public Id id;
    public Id recordId;
    public String recordName;

    public List<Item> uploadItems;
    public List<Item> taskItems;
    public Boolean showUploads = false;
    public Boolean showTasks = false;

    public Boolean showPropertyActions = false;

    Section(Checklist_Section__c section) {
      this.name = section.Name;
      this.sectionType = section.Type__c;
      this.id = section.Id;
      this.items = new List<Item>();

      // if (this.sectionType == 'Property') {
      //   this.showPropertyActions = true;
      // }
      //this.recordId =

      if (this.sectionType == 'Property') {
        this.recordId = section.Property__c;
        this.recordName = section.Property__r.Name;
        this.showPropertyActions = true;
      } else if (this.sectionType == 'Account') {
        // this.recordId = section.Account
        this.sectionType = 'Account';
        this.recordId = section.Account__c;
        this.recordName = section.Account__r.Name;
      } else if (this.sectionType == 'Opportunity') {
        this.sectionType = 'Deal';
        this.recordId = section.Deal__c;
        this.recordName = section.Deal__r.Name;
        this.name = section.Deal__r.Name;
      } else if (
        this.sectionType == 'Applicant' ||
        this.sectionType == 'Sponsor'
      ) {
        // this.name = section.Deal_Contact__r.Contact__r.Name;
        this.recordId = section.Deal_Contact__c;
        this.recordName = section.Deal_Contact__r.Contact__r.Name;
      }

      for (Checklist_Item__c checklistItem : section.Checklist_Items__r) {
        Item item = new Item(checklistItem);
        items.add(item);
      }
    }

    Section(Section section) {
      this.name = section.name;
      this.sectionType = section.sectionType;
      this.id = section.id;
      this.recordId = section.recordId;
      this.recordName = section.recordName;
      // this.items = new List<Item>();
      this.uploadItems = new List<Item>();
      this.taskItems = new List<Item>();
      this.showPropertyActions = section.showPropertyActions;
    }

    public void addItem(Item item) {
      //this.items.add(item);
      if (item.itemType == 'Document Upload') {
        this.uploadItems.add(item);
        this.showUploads = true;
      } else if (item.itemType == 'Task') {
        this.taskItems.add(item);
        this.showTasks = true;
      }
    }
  }

  public class Item {
    public Id id;
    public String name;
    public String documentCategory;
    public String documentType;
    public String docStructureId;
    public String milestone;
    public String itemType;
    public Boolean uploaded;
    public DateTime uploadedDate;
    public Id userAssignedId;
    public String userAssignedName;
    public String status;
    public Id recordId;
    public String recordName;
    public Boolean isPropertyLevel;
    public String comments;
    public List<Deal_Document__c> documents;
    public Boolean hasExpiredDocuments;
    public Boolean showDocuments;
    public String externalComments;
    public String uploader;
    public Integer numberOfDocuments;
    public Integer numberOfComments;
    public String responsibleParty;
    public List<String> draftValues;
    Item(Checklist_Item__c item) {
      this.draftValues = new List<String>();
      this.id = item.Id;
      this.Name = item.Name;
      this.documentCategory = item.Document_Category__c;
      this.documentType = item.Document_Type__c;
      this.docStructureId = item.Doc_Structure_Id__c;
      this.milestone = item.Milestone__c;
      this.itemType = item.RecordType.Name;
      this.uploaded = item.Uploaded__c;
      this.uploadedDate = item.Uploaded_Date__c;
      this.userAssignedId = item.User_Assigned__c;
      this.userAssignedName = item.User_Assigned__r.Name;
      this.status = item.Status__c;
      this.isPropertyLevel = item.Is_Property_Level__c;
      this.comments = item.Comments__c;
      this.externalComments = item.External_Comments__c;
      this.responsibleParty = item.Responsible_Party__c;
      this.uploader = item.Uploader__c;
      //this.documents = new List<Deal_Document__c>();
      this.documents = itemDocMap.get(item.Id);
      this.numberOfDocuments = this.documents.size();
      this.numberOfComments = itemCommentMap.get(item.Id).size();
      this.showDocuments = this.documents.size() > 0;

      this.hasExpiredDocuments = false;
      for (Deal_Document__c dealDocument : this.documents) {
        if (dealDocument.Is_Expired__c) {
          this.hasExpiredDocuments = true;
        }
      }

      if (this.itemType == 'Property') {
        this.recordId = item.Property__c;
        this.recordName = item.Property__r.Name;
      } else if (this.itemType == 'Deal') {
        this.recordId = item.Deal__c;
        this.recordName = item.Deal__r.Name;
      } else if (this.itemType == 'Applicant' || this.itemType == 'Sponsor') {
        this.recordId = item.Deal_Contact__c;
        this.recordName = item.Deal_Contact__r.Contact__r.Name;
      }
    }
  }

  @AuraEnabled
  public static List<String> getMilestoneList(Id recordId) {
    try {
      Opportunity opp = [
        SELECT Id, RecordType.DeveloperName
        FROM Opportunity
        WHERE Id = :recordId
      ];

      List<String> milestones = new List<String>();

      if (opp.recordType.DeveloperName == 'Term_Loan') {
        milestones = termMilestones;
      } else if (opp.recordType.DeveloperName == 'LOC_Loan') {
        milestones = bridgeMilestones;
      } else if (opp.recordType.DeveloperName == 'Single_Asset_Bridge_Loan') {
        milestones = sabMilestones;
      }

      return milestones;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public static List<String> termMilestones = new List<String>{
    'Kick-Off',
    'Vendor Orders',
    'In Processing',
    'In Underwriting',
    'In Closing',
    'Funding'
  };

  public static List<String> bridgeMilestones = new List<String>{
    'Kick-Off',
    'In Processing',
    'In Underwriting',
    'In Closing'
  };

  public static List<String> sabMilestones = new List<String>{
    'Kick-Off',
    'In Processing',
    'In Underwriting',
    'In Closing',
    'Post Closing'
  };

  public static List<String> lenderMilestones = new List<String>{
    'Onboarding'
  };
}