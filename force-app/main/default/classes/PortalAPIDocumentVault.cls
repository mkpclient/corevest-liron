@RestResource(urlMapping='/portal/documentvault/*')
global without sharing class PortalAPIDocumentVault {
  static String portalId;
  static String contactId;

  public static Integer paginationStart;
  public static Integer paginationEnd;
  public static Boolean usePagination;
  public static PortalAPIUser.PortalUser user;
  static Id recordId;

  static Map<Id, ContentVersion> contentVersionMap;

  static Boolean isVault = false;

  @HttpGet
  global static void doGet() {
    RestRequest req = RestContext.request;
    RestResponse res = Restcontext.response;

    List<String> params = Restcontext.request.requestURI.split('/');

    String pageSizeParam = RestContext.request.params.get('pageSize');
    Integer pageSize = null;
    if (String.isNotBlank(pageSizeParam)) {
      pageSize = Integer.valueOf(pageSizeParam);
    }

    Integer page = null;
    String pageParam = RestContext.request.params.get('page');
    if (String.isNotBlank(pageParam)) {
      page = Integer.valueOf(pageParam);
    }

    usePagination = false;
    if (pageSize != null && page != null) {
      //   paginationStart = pageSize * (page - 1) - 1; // 2
      //   paginationEnd = page * pageSize - 1; // 2
      paginationStart = (page - 1) * pageSize; //2
      paginationEnd = page * pageSize; //3
      usePagination = true;
    }

    portalId = params[3];
    system.debug(params);
    user = new PortalAPIUser.PortalUser(portalId);
    if (user.id != null) {
      contactId = user.contactId;
      if (params[4] == 'uncategorized') {
        List<UncategorizedDocument> docs = getUncategorizedDocuments();

        if (params.size() > 5 && params[5] == 'count') {
          Map<String, Object> countResponse = new Map<String, Integer>();
          countResponse.put('count', docs.size());

          res.addHeader('Content-Type', 'application/json');
          res.responseBody = Blob.valueOf(JSON.serialize(countResponse, true));
        } else {
          List<UncategorizedDocument> docsToSend = new List<UncategorizedDocument>();
          if (usePagination) {
            for (Integer i = paginationStart; i < paginationEnd; i++) {
              if (i < docs.size()) {
                docsToSend.add(docs[i]);
              }
            }
          } else {
            docsToSend = docs;
          }

          res.addHeader('Content-Type', 'application/json');
          res.responseBody = Blob.valueOf(JSON.serialize(docsToSend, true));
        }
      } else if (params[4] == 'vault') {
        isVault = true;
        recordId = params[5];
        DocumentVault vault = createVault();
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(vault, false));
      } else if (params[4] == 'loans') {
        List<Map<String, String>> picklists = getLoanPicklist();
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(picklists, true));
      } else if (params[4] == 'documentTypes') {
        recordId = params[5];
        List<Map<String, String>> picklists = getDocumentTypes();
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(picklists, true));
        // } else if (params[4] == 'properties') {
        //   recordId = params[5];

        //   List<PropertyFolder> propertyFolders = createPropertyFolders();
        //   res.addHeader('Content-Type', 'application/json');
        //   res.responseBody = Blob.valueOf(JSON.serialize(propertyFolders, true));
      }
    }
    // else {
    //   // Map<String, String> respBody = new Map<String, String>();
    //   // res.addHeader('Content-Type', 'application/json');
    //   // respBody.put('status', 'error');
    //   // respBody.put('message', 'User Id Not Found');
    //   // res.statusCode = 404;
    //   // res.responseBody = Blob.valueOf(JSON.serialize(respBody, true));
    // }
  }

  public static List<Map<String, String>> getLoanPicklist() {
    List<Map<String, String>> picklists = new List<Map<String, String>>();

    if (contactId != null) {
      Date today7 = system.today().addDays(7);
      //system.debug(contactId);
      Set<Id> dealIds = AlchemyAPI.getDealIdsContactId(contactId);

      // system.debug(dealIds);

      for (Opportunity opp : [
        SELECT Id, Name
        FROM Opportunity
        WHERE
          (Contact__c = :contactId
          OR Id IN :dealIds)
          AND StageName NOT IN (
            'Matured',
            'Expired',
            'Withdrawn',
            'Rejected',
            'Paid Off'
          )
          AND (StageName != 'Closed Won'
          OR (StageName = 'Closed Won'
          AND CloseDate >= :today7))
        ORDER BY CloseDate DESC, Name ASC
      ]) {
        Map<String, String> picklist = new Map<String, String>();
        picklist.put('name', opp.Name);
        picklist.put('id', opp.Id);

        picklists.add(picklist);
      }
    }

    return picklists;
  }

  public static List<Map<String, String>> getDocumentTypes() {
    List<Map<String, String>> picklists = new List<Map<String, String>>();

    for (Checklist_Item__c item : [
      SELECT Id, Document_Type__c, Status__c
      FROM Checklist_Item__c
      WHERE
        Status__c = 'Pending'
        AND Checklist_Section__r.Checklist__r.Deal__c = :recordId
        AND RecordType.DeveloperName = 'Document_Upload'
        AND (Checklist_Section__r.Type__c = 'Opportunity'
        OR Checklist_Section__r.Type__c = 'Sponsor')
      ORDER BY Document_Type__c ASC
    ]) {
      Map<String, String> picklist = new Map<String, String>();
      picklist.put('name', item.Document_Type__c);
      picklist.put('itemId', item.Id);

      picklists.add(picklist);
    }
    return picklists;
  }

  public static List<UncategorizedDocument> getUncategorizedDocuments() {
    List<UncategorizedDocument> documents = new List<UncategorizedDocument>();
    for (ContentVersion cv : [
      SELECT Id, Title, FileType, FileExtension, ContentSize, LastModifiedDate
      FROM ContentVersion
      WHERE
        Uploaded_From_Portal_Id__c = :portalId
        AND Linked_To_Record__c = FALSE
      ORDER BY LastModifiedDate DESC
    ]) {
      documents.add(new UncategorizedDocument(cv));
    }

    return documents;
  }

  class UncategorizedDocument {
    Id id;
    String fileName;
    String fileExtension;
    Integer fileSize;
    DateTime lastModifiedDate;

    UncategorizedDocument(ContentVersion cv) {
      this.id = cv.Id;
      this.fileName = cv.Title;
      this.fileExtension = cv.FileExtension;
      this.fileSize = cv.ContentSize;
      this.lastModifiedDate = cv.LastModifiedDate;
    }
  }

  // public static List<PropertyFolder> createPropertyFolders() {
  //   // List<PropertyFolder> folders = new List<PropertyFolder>();

  //   //Opportunity deal = [SELECT Id, Name FROM Opportunity WHERE Id = :recordId];
  //   PropertyVault vault = new PropertyVault();
  //   //vault.id = deal.Id;
  //   //vault.Name = deal.Name;

  //   List<Checklist_Item__c> items = new List<Checklist_Item__c>();
  //   contentVersionMap = new Map<Id, ContentVersion>();
  //   for (Checklist_Item__c item : [
  //     SELECT
  //       Id,
  //       Property__c,
  //       Property__r.Name,
  //       Deal__c,
  //       Doc_Structure_Id__c,
  //       Document_Type__c,
  //       Folder_String__c,
  //       Checklist_Section__r.Property__r.Deal__c,
  //       Checklist_Section__r.Property__r.Name,
  //       (
  //         SELECT
  //           Id,
  //           Added_On__c,
  //           Added_By__r.Name,
  //           Document_Type__c,
  //           Reviewed_By__r.Name,
  //           Reviewed_On__c,
  //           File_Name__c,
  //           ContentVersion_Id__c
  //         FROM Deal_Documents__r
  //       )
  //     FROM Checklist_Item__c
  //     WHERE
  //       Property__r.Deal__c = :recordId
  //       AND RecordType.DeveloperName = 'Document_Upload'
  //   ]) {
  //     items.add(item);
  //     for (Deal_Document__c doc : item.Deal_Documents__r) {
  //       contentVersionMap.put(doc.ContentVersion_Id__c, null);
  //     }
  //     //vault.addItem(item);
  //   }

  //   for (ContentVersion cv : [
  //     SELECT Id, FileExtension
  //     FROM ContentVersion
  //     WHERE Id IN :contentVersionMap.keySet()
  //   ]) {
  //     contentVersionMap.put(cv.Id, cv);
  //   }

  //   for (Checklist_Item__c item : items) {
  //     vault.addItem(item);
  //   }
  //   vault.documentTypes.sort();
  //   for (PropertyFolder docType : vault.documentTypes) {
  //     docType.properties.sort();
  //   }
  //   //return vault;

  //   return vault.documentTypes;
  // }

  public static DocumentVault createVault() {
    String sobjectType = recordId.getSObjectType().getDescribe().getName();
    DocumentVault vault = new DocumentVault();
    if (sobjectType == 'Property__c') {
      //vault = createPropertyVault();
    } else if (sobjectType == 'Opportunity') {
      system.debug(user.userType);
      if (user.userType == 'vendor') {
        vault = createVendorVault();
      } else {
        vault = createLoanVault();
      }
    }

    return vault;
  }

  public static DocumentVault createVendorVault() {
    Opportunity deal = [SELECT Id, Name FROM Opportunity WHERE Id = :recordId];
    DocumentVault vault = new DocumentVault();
    vault.id = deal.Id;
    vault.Name = deal.Name;

    List<Checklist_Item__c> items = new List<Checklist_Item__c>();
    contentVersionMap = new Map<Id, ContentVersion>();

    Set<String> vendorType = new Set<String>();
    for (Deal_Contact__c dc : [
      SELECT Id, Vendor_Type__c
      FROM Deal_Contact__c
      WHERE Account__c = :user.accountId AND Deal__c = :recordId
    ]) {
      if (dc.Vendor_Type__c == 'Lender Legal Counsel') {
        vendorType.add('Legal');
      } else if (
        dc.Vendor_Type__c == 'Title and Escrow' ||
        dc.Vendor_Type__c == '3rd Party Title'
      ) {
        vendorType.add('Title');
      }
    }

    for (Checklist_Item__c item : [
      SELECT
        Id,
        Property__c,
        Deal__c,
        Doc_Structure_Id__c,
        Document_Type__c,
        Folder_String__c,
        Status__c,
        Checklist_Section__r.Property__r.Name,
        (
          SELECT
            Id,
            Added_On__c,
            Added_By__r.Name,
            Document_Type__c,
            Reviewed_By__r.Name,
            Reviewed_On__c,
            File_Name__c,
            ContentVersion_Id__c,
            Status__c,
            Comments__c,
            Reviewed__c
          FROM Deal_Documents__r
        )
      FROM Checklist_Item__c
      WHERE
        Checklist_Section__r.Checklist__r.Deal__c = :recordId
        AND RecordType.DeveloperName = 'Document_Upload'
        AND (Checklist_Section__r.Type__c = 'Opportunity'
        OR Checklist_Section__r.Type__c = 'Legal')
        AND Checklist_Section__r.Deal_Contact__r.Account__c = :user.AccountId
    ]) {
      if (isVault) {
        if (item.Status__c == 'Pending') {
          items.add(item);
          for (Deal_Document__c doc : item.Deal_Documents__r) {
            contentVersionMap.put(doc.ContentVersion_Id__c, null);
          }
        }
      } else {
        items.add(item);
        for (Deal_Document__c doc : item.Deal_Documents__r) {
          contentVersionMap.put(doc.ContentVersion_Id__c, null);
        }
      }
    }

    for (ContentVersion cv : [
      SELECT Id, FileExtension
      FROM ContentVersion
      WHERE Id IN :contentVersionMap.keySet()
    ]) {
      contentVersionMap.put(cv.Id, cv);
    }

    for (Checklist_Item__c item : items) {
      vault.addItem(item);
    }
    vault.loanLevelDocuments.sort();

    items = new List<Checklist_Item__c>();
    contentVersionMap = new Map<Id, ContentVersion>();

    for (Checklist_Item__c item : [
      SELECT
        Id,
        Property__c,
        Deal__c,
        Doc_Structure_Id__c,
        Document_Type__c,
        Folder_String__c,
        Reviewed__c,
        Status__c,
        Checklist_Section__r.Property__r.Name,
        (
          SELECT
            Id,
            Added_On__c,
            Added_By__r.Name,
            Document_Type__c,
            Reviewed_By__r.Name,
            Reviewed_On__c,
            File_Name__c,
            ContentVersion_Id__c,
            Status__c,
            Comments__c,
            Reviewed__c
          FROM Deal_Documents__r
        )
      FROM Checklist_Item__c
      WHERE
        Checklist_Section__r.Checklist__r.Deal__c = :recordId
        AND RecordType.DeveloperName = 'Document_Upload'
        AND Checklist_Section__r.Type__c = 'Property'
        AND Uploader__c IN :vendorType
    ]) {
      if (isVault) {
        if (item.Status__c == 'Pending') {
          items.add(item);
          for (Deal_Document__c doc : item.Deal_Documents__r) {
            contentVersionMap.put(doc.ContentVersion_Id__c, null);
          }
        }
      } else {
        items.add(item);
        for (Deal_Document__c doc : item.Deal_Documents__r) {
          contentVersionMap.put(doc.ContentVersion_Id__c, null);
        }
      }
    }

    for (ContentVersion cv : [
      SELECT Id, FileExtension
      FROM ContentVersion
      WHERE Id IN :contentVersionMap.keySet()
    ]) {
      contentVersionMap.put(cv.Id, cv);
    }

    for (Checklist_Item__c item : items) {
      vault.addPropertyItem(item);
    }
    vault.propertyLevelDocuments.sort();

    return vault;
  }

  public static DocumentVault createLoanVault() {
    Opportunity deal = [SELECT Id, Name FROM Opportunity WHERE Id = :recordId];
    DocumentVault vault = new DocumentVault();
    vault.id = deal.Id;
    vault.Name = deal.Name;

    List<Checklist_Item__c> items = new List<Checklist_Item__c>();
    contentVersionMap = new Map<Id, ContentVersion>();
    for (Checklist_Item__c item : [
      SELECT
        Id,
        Property__c,
        Deal__c,
        Doc_Structure_Id__c,
        Document_Type__c,
        Folder_String__c,
        Status__c,
        Checklist_Section__r.Property__r.Name,
        (
          SELECT
            Id,
            Added_On__c,
            Added_By__r.Name,
            Document_Type__c,
            Reviewed_By__r.Name,
            Reviewed_On__c,
            File_Name__c,
            ContentVersion_Id__c,
            Status__c,
            Comments__c,
            Reviewed__c
          FROM Deal_Documents__r
        )
      FROM Checklist_Item__c
      WHERE
        Is_Property_Level__c = FALSE
        AND Checklist_Section__r.Checklist__r.Deal__c = :recordId
        AND RecordType.DeveloperName = 'Document_Upload'
        AND (Checklist_Section__r.Type__c = 'Opportunity'
        OR Checklist_Section__r.Type__c = 'Sponsor')
    ]) {
      if (isVault) {
        if (item.Status__c == 'Pending') {
          items.add(item);
          for (Deal_Document__c doc : item.Deal_Documents__r) {
            contentVersionMap.put(doc.ContentVersion_Id__c, null);
          }
        }
      } else {
        items.add(item);
        for (Deal_Document__c doc : item.Deal_Documents__r) {
          contentVersionMap.put(doc.ContentVersion_Id__c, null);
        }
      }
    }

    for (ContentVersion cv : [
      SELECT Id, FileExtension
      FROM ContentVersion
      WHERE Id IN :contentVersionMap.keySet()
    ]) {
      contentVersionMap.put(cv.Id, cv);
    }

    for (Checklist_Item__c item : items) {
      vault.addItem(item);
    }
    vault.loanLevelDocuments.sort();

    items = new List<Checklist_Item__c>();
    contentVersionMap = new Map<Id, ContentVersion>();
    for (Checklist_Item__c item : [
      SELECT
        Id,
        Property__c,
        Deal__c,
        Doc_Structure_Id__c,
        Document_Type__c,
        Folder_String__c,
        Reviewed__c,
        Status__c,
        Checklist_Section__r.Property__r.Name,
        (
          SELECT
            Id,
            Added_On__c,
            Added_By__r.Name,
            Document_Type__c,
            Reviewed_By__r.Name,
            Reviewed_On__c,
            File_Name__c,
            ContentVersion_Id__c,
            Status__c,
            Comments__c,
            Reviewed__c
          FROM Deal_Documents__r
        )
      FROM Checklist_Item__c
      WHERE
        Is_Property_Level__c = TRUE
        AND Checklist_Section__r.Checklist__r.Deal__c = :recordId
        AND RecordType.DeveloperName = 'Document_Upload'
        AND (Checklist_Section__r.Type__c = 'Opportunity'
        OR Checklist_Section__r.Type__c = 'Applicant')
    ]) {
      if (isVault) {
        if (item.Status__c == 'Pending') {
          items.add(item);
          for (Deal_Document__c doc : item.Deal_Documents__r) {
            contentVersionMap.put(doc.ContentVersion_Id__c, null);
          }
        }
      } else {
        items.add(item);
        for (Deal_Document__c doc : item.Deal_Documents__r) {
          contentVersionMap.put(doc.ContentVersion_Id__c, null);
        }
      }
    }

    for (ContentVersion cv : [
      SELECT Id, FileExtension
      FROM ContentVersion
      WHERE Id IN :contentVersionMap.keySet()
    ]) {
      contentVersionMap.put(cv.Id, cv);
    }

    for (Checklist_Item__c item : items) {
      vault.addPropertyItem(item);
    }
    vault.propertyLevelDocuments.sort();
    return vault;
  }

  // public static DocumentVault createPropertyVault() {
  //   Property__c property = [
  //     SELECT Id, Deal__c, Name
  //     FROM Property__c
  //     WHERE Id = :recordId
  //   ];
  //   DocumentVault vault = new DocumentVault();
  //   vault.id = property.Id;
  //   vault.Name = property.Name;
  //   List<Checklist_Item__c> items = new List<Checklist_Item__c>();
  //   contentVersionMap = new Map<Id, ContentVersion>();
  //   for (Checklist_Item__c item : [
  //     SELECT
  //       Id,
  //       Property__c,
  //       Deal__c,
  //       Doc_Structure_Id__c,
  //       Document_Type__c,
  //       Folder_String__c,
  //       (
  //         SELECT
  //           Id,
  //           Added_On__c,
  //           Added_By__r.Name,
  //           Document_Type__c,
  //           Reviewed_By__r.Name,
  //           Reviewed_On__c,
  //           File_Name__c,
  //           ContentVersion_Id__c
  //         FROM Deal_Documents__r
  //       )
  //     FROM Checklist_Item__c
  //     WHERE
  //       Property__c = :recordId
  //       AND RecordType.DeveloperName = 'Document_Upload'
  //   ]) {
  //     //vault.addItem(item);
  //     items.add(item);
  //     for (Deal_Document__c doc : item.Deal_Documents__r) {
  //       contentVersionMap.put(doc.ContentVersion_Id__c, null);
  //     }
  //   }

  //   for (ContentVersion cv : [
  //     SELECT Id, FileExtension
  //     FROM ContentVersion
  //     WHERE Id IN :contentVersionMap.keySet()
  //   ]) {
  //     contentVersionMap.put(cv.Id, cv);
  //   }

  //   for (Checklist_Item__c item : items) {
  //     vault.addItem(item);
  //   }
  //   vault.loanLevelDocuments.sort();

  //   // for (DocumentFolder folder : vault.loanLevelDocuments) {
  //   //   folder.documents.sort();
  //   // }

  //   return vault;
  // }

  public class DocumentVault {
    public List<ChecklistItem> loanLevelDocuments;
    public List<ChecklistItem> propertyLevelDocuments;
    public Id id;
    public string name;

    //transient Map<String, ChecklistItem> folderMap;
    //transient Map<String, ChecklistItem> propertyFolderMap;

    DocumentVault() {
      loanLevelDocuments = new List<ChecklistItem>();
      propertyLevelDocuments = new List<ChecklistItem>();

      //propertyLevelFolders = new List<ChecklistItem>();
      //propertyFolderMap = new Map<String, ChecklistItem>();
    }

    public void addItem(Checklist_Item__c item) {
      // String folderString = item.Folder_String__c;
      // List<String> folderStrings = folderString.split(';');

      // if (folderStrings.size() > 1) {
      //   String folderName = folderStrings[1];
      //   if (!folderMap.containsKey(folderName)) {
      //     folderMap.put(folderName, new DocumentFolder(folderName));
      //     folders.add(folderMap.get(folderName));
      //   }

      //   folderMap.get(folderName).addItem(item);
      // } else {
      //   if (!folderMap.containsKey(folderStrings[0])) {
      //     folderMap.put(folderStrings[0], new DocumentFolder(folderStrings[0]));
      //     folders.add(folderMap.get(folderStrings[0]));
      //   }

      //   folderMap.get(folderStrings[0]).addItem(item);
      // }

      //String documentType = item.Document_Type__c;
      loanLevelDocuments.add(new ChecklistItem(item));

      // if (!folderMap.containsKey(documentType)) {
      //   folderMap.put(documentType, new DocumentFolder(documentType));
      //   //loanLevelFolders.add(folderMap.get(documentType));
      // }

      //folderMap.get(documentType).addItem(item);
    }

    public void addPropertyItem(Checklist_Item__c item) {
      propertyLevelDocuments.add(new ChecklistItem(item));
      // String documentType = item.Document_Type__c;

      // if (!propertyFolderMap.containsKey(documentType)) {
      //   propertyFolderMap.put(documentType, new DocumentFolder(documentType));
      //   propertyLevelFolders.add(propertyfolderMap.get(documentType));
      // }

      // propertyFolderMap.get(documentType).addItem(item);
    }
  }

  // public class PropertyVault {
  //   public List<PropertyFolder> documentTypes;
  //   // public Id id;
  //   // public string name;

  //   transient Map<String, PropertyFolder> folderMap;

  //   PropertyVault() {
  //     documentTypes = new List<PropertyFolder>();
  //     folderMap = new Map<String, PropertyFolder>();
  //   }

  //   public void addItem(Checklist_Item__c item) {
  //     //String folderString = item.Folder_String__c;
  //     //List<String> folderStrings = folderString.split(';');

  //     String documentType = item.Document_Type__c;
  //     if (!folderMap.containsKey(documentType)) {
  //       folderMap.put(documentType, new PropertyFolder(documentType));
  //       documentTypes.add(folderMap.get(documentType));
  //     }

  //     folderMap.get(documentType).addItem(item);

  //     // if (folderStrings.size() > 1) {
  //     //   String folderName = folderStrings[1];
  //     //   if (!folderMap.containsKey(folderName)) {
  //     //     folderMap.put(folderName, new DocumentFolder(folderName));
  //     //     folders.add(folderMap.get(folderName));
  //     //   }

  //     //   folderMap.get(folderName).addItem(item);
  //     // } else {
  //     //   if (!folderMap.containsKey(folderStrings[0])) {
  //     //     folderMap.put(folderStrings[0], new DocumentFolder(folderStrings[0]));
  //     //     folders.add(folderMap.get(folderStrings[0]));
  //     //   }

  //     //   folderMap.get(folderStrings[0]).addItem(item);
  //     // }
  //   }
  // }

  // public class PropertyFolder implements Comparable {
  //   String documentType;
  //   public List<PropertyItem> properties;

  //   PropertyFolder(String documentType) {
  //     this.documentType = documentType;
  //     properties = new List<PropertyItem>();
  //   }

  //   public void addItem(Checklist_Item__c item) {
  //     // String folderString = item.Folder_String__c;
  //     // List<String> folderStrings = folderString.split(';');
  //     PropertyItem checklistItem = new PropertyItem(item);
  //     properties.add(checklistItem);
  //   }

  //   public Integer compareTo(Object folder) {
  //     PropertyFolder compareToFOlder = (PropertyFolder) folder;
  //     if (this.documentType > compareToFolder.documentType) {
  //       return 1;
  //     } else if (this.documentType < compareToFolder.documentType) {
  //       return -1;
  //     } else {
  //       return 0;
  //     }
  //   }
  // }

  // public class PropertyItem implements Comparable {
  //   Id itemId;
  //   List<Document> uploadedDocuments;
  //   String propertyName;

  //   PropertyItem(Checklist_Item__c item) {
  //     itemId = item.id;
  //     propertyName = item.Checklist_Section__r.Property__r.Name; //Document_Type__c;

  //     uploadedDocuments = new List<Document>();
  //     for (Deal_Document__c doc : item.Deal_Documents__r) {
  //       uploadedDocuments.add(new Document(doc));
  //     }
  //   }

  //   public Integer compareTo(Object item) {
  //     PropertyItem itemToCompare = (PropertyItem) item;
  //     if (this.propertyName > itemToCompare.propertyName) {
  //       return 1;
  //     } else if (this.propertyName < itemToCompare.propertyName) {
  //       return -1;
  //     } else {
  //       return 0;
  //     }
  //   }
  // }

  // public class DocumentFolder implements Comparable {
  //   String folderName;
  //   public List<ChecklistItem> documents;
  //   DocumentFolder(String folderName) {
  //     this.folderName = folderName;
  //     documents = new List<ChecklistItem>();
  //   }

  //   public void addItem(Checklist_Item__c item) {
  //     String folderString = item.Folder_String__c;
  //     List<String> folderStrings = folderString.split(';');
  //     ChecklistItem checklistItem = new ChecklistItem(item);
  //     documents.add(checklistItem);
  //   }

  //   public Integer compareTo(Object folder) {
  //     DocumentFolder compareToFOlder = (DocumentFOlder) folder;
  //     if (this.folderName > compareToFolder.folderName) {
  //       return 1;
  //     } else if (this.folderName < compareToFolder.folderName) {
  //       return -1;
  //     } else {
  //       return 0;
  //     }
  //   }
  // }

  public class ChecklistItem implements Comparable {
    Id itemId;
    List<Document> uploadedDocuments;
    String documentType;

    ChecklistItem(Checklist_Item__c item) {
      itemId = item.id;
      documentType = item.Document_Type__c;

      if (item.Checklist_Section__r.Property__c != null) {
        documentType =
          item.Checklist_Section__r.Property__r.Name +
          ' - ' +
          documentType;
      }

      uploadedDocuments = new List<Document>();
      for (Deal_Document__c doc : item.Deal_Documents__r) {
        uploadedDocuments.add(new Document(doc));
      }
    }

    public Integer compareTo(Object item) {
      ChecklistItem itemToCompare = (ChecklistItem) item;
      if (this.documentType > itemToCompare.documentType) {
        return 1;
      } else if (this.documentType < itemToCompare.documentType) {
        return -1;
      } else {
        return 0;
      }
    }
  }

  public class Document {
    public String fileName;
    public string fileExtension;
    public String id;
    public String comments;
    public Boolean reviewed;
    public String reviewedBy;
    public Date reviewedDate;
    public String status;
    public Document(Deal_Document__c doc) {
      fileName = doc.File_Name__c;
      comments = doc.Comments__c;
      status = doc.Status__c;
      if (status == null) {
        status = 'Pending';
      }

      if (fileName.contains('.')) {
        fileName = fileName.substringBefore('.');
      }

      reviewedBy = doc.Reviewed_By__c;
      if (doc.Reviewed_On__c != null) {
        reviewedDate = Date.newInstance(
          doc.Reviewed_On__c.year(),
          doc.Reviewed_On__c.month(),
          doc.Reviewed_On__c.day()
        );
      }
      reviewed = doc.Reviewed__c;
      if (contentVersionMap != null) {
        ContentVersion cv = contentVersionMap.get(doc.ContentVersion_Id__c);
        if (cv != null) {
          this.fileExtension = cv.FileExtension;
          this.id = cv.Id;
        }
      }
    }
  }

  @HttpPost
  global static void doPost() {
    RestRequest req = RestContext.request;
    RestResponse res = Restcontext.response;

    List<String> params = Restcontext.request.requestURI.split('/');

    if (params[3] == 'upload') {
      if (params.size() > 4 && params[4] == 'base64') {
        // ContentVersion cv =
        Map<String, Object> body = (Map<String, Object>) System.JSON.deserializeUntyped(
          req.requestBody.toString()
        );

        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(
          (String) body.get('base64String')
        );
        cv.Uploaded_From_Portal_Id__c = (String) body.get(
          'Uploaded_From_Portal_Id__c'
        );
        if (body.containsKey('Application__c')) {
          cv.Application__c = (String) body.get('Application__c');
        }

        // if (body.containsKey('Deal__c')) {
        //   cv.Deal__c = (String) body.get('Deal__c');
        // }

        if (body.containsKey('fileName')) {
          cv.Title = (String) body.get('fileName');
          cv.Title = cv.Title.substringBefore('.');
          cv.pathOnClient = (String) body.get('fileName');
        }

        if (body.containsKey('Description')) {
          cv.Description = (String) body.get('Description');
        }

        insert cv;

        Map<String, Object> responseBody = new Map<String, Object>();
        responseBody.put('success', true);
        responseBody.put('id', cv.Id);
        responseBody.put('errors', new List<String>());

        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(responseBody, true));
      } else {
        Map<String, Object> body = (Map<String, Object>) System.JSON.deserializeUntyped(
          req.requestBody.toString()
        );

        Id id = (Id) body.get('id');
        //   Id docStructureId = body.get('docStructureId');
        Id itemId = (Id) body.get('itemId');

        Checklist_Item__c item = [
          SELECT
            Id,
            Doc_Structure_Id__c,
            Property__c,
            Deal__c,
            Property__r.Deal__c
          FROM Checklist_Item__c
          WHERE Id = :itemId
          LIMIT 1
        ];
        ContentVersion cv = [
          SELECT Id, Title, ContentDocumentId
          FROM ContentVersion
          WHERE Id = :id
          LIMIT 1
        ];
        Deal_Document__c dealDoc = new Deal_Document__c();
        dealDoc.Document_Structure_Id__c = item.Doc_Structure_Id__c;
        dealDoc.File_Name__c = cv.Title;
        dealDoc.ContentVersion_Id__c = cv.Id;
        dealDoc.Attachment_Id__c = cv.ContentDocumentId;
        dealDoc.Deal__c = item.Deal__c;
        if (String.isNotBlank(item.Property__c)) {
          dealDoc.Property__c = item.Property__c;
          dealDoc.Deal__c = item.Deal__c;
        }
        dealDoc.Checklist_Item__c = itemId;
        dealDoc.Document_Loaded__c = true;
        dealDoc.Added_By__c = UserInfo.getUserId();
        dealDoc.Added_On__c = system.now();

        insert dealDoc;

        cv.Linked_To_Record__c = true;
        update cv;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cv.ContentDocumentId;
        cdl.LinkedEntityId = dealDoc.Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;

        Map<String, String> responseBody = new Map<String, String>();
        responseBody.put('status', 'success');
        responseBody.put('message', 'Deal Document created successfully');
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(responseBody, true));
      }
    }
  }
}