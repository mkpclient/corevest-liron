@RestResource(urlMapping='/portal/documentvault/*')
global without sharing class PortalAPIDocumentVault {
  static String portalId;
  static String contactId;

  public static Integer paginationStart;
  public static Integer paginationEnd;
  public static Boolean usePagination;

  static Id recordId;

  static Map<Id, ContentVersion> contentVersionMap;

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
    PortalAPIUser.PortalUser user = new PortalAPIUser.PortalUser(portalId);
    if (user.id != null) {
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
      } else {
        contactId = user.contactId;
        recordId = params[4];
        DocumentVault vault = createVault();
        system.debug(vault);
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(vault, true));
      }
    } else {
      Map<String, String> respBody = new Map<String, String>();
      res.addHeader('Content-Type', 'application/json');
      respBody.put('status', 'error');
      respBody.put('message', 'User Id Not Found');
      res.statusCode = 404;
      res.responseBody = Blob.valueOf(JSON.serialize(respBody, true));
    }
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

  public static DocumentVault createVault() {
    String sobjectType = recordId.getSObjectType().getDescribe().getName();
    DocumentVault vault = new DocumentVault();
    if (sobjectType == 'Property__c') {
      vault = createPropertyVault();
    } else if (sobjectType == 'Opportunity') {
      vault = createLoanVault();
    }

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
        (
          SELECT
            Id,
            Added_On__c,
            Added_By__r.Name,
            Document_Type__c,
            Reviewed_By__r.Name,
            Reviewed_On__c,
            File_Name__c,
            ContentVersion_Id__c
          FROM Deal_Documents__r
        )
      FROM Checklist_Item__c
      WHERE
        Checklist_Section__r.Checklist__r.Deal__c = :recordId
        AND RecordType.DeveloperName = 'Document_Upload'
        AND ((Checklist_Section__r.Type__c = 'Opportunity'
        AND Responsible_Party__c = 'Sponsor')
        OR (Checklist_Section__r.Type__c = 'Sponsor'
        AND Checklist_Section__r.Deal_Contact__r.Contact__c = :contactId))
    ]) {
      items.add(item);
      for (Deal_Document__c doc : item.Deal_Documents__r) {
        contentVersionMap.put(doc.ContentVersion_Id__c, null);
      }
      //vault.addItem(item);
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
    vault.folders.sort();
    for (DocumentFolder folder : vault.folders) {
      folder.documents.sort();
    }
    return vault;
  }

  public static DocumentVault createPropertyVault() {
    Property__c property = [
      SELECT Id, Deal__c, Name
      FROM Property__c
      WHERE Id = :recordId
    ];
    DocumentVault vault = new DocumentVault();
    vault.id = property.Id;
    vault.Name = property.Name;
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
        (
          SELECT
            Id,
            Added_On__c,
            Added_By__r.Name,
            Document_Type__c,
            Reviewed_By__r.Name,
            Reviewed_On__c,
            File_Name__c,
            ContentVersion_Id__c
          FROM Deal_Documents__r
        )
      FROM Checklist_Item__c
      WHERE
        Property__c = :recordId
        AND RecordType.DeveloperName = 'Document_Upload'
        AND Responsible_Party__c = 'Sponsor'
    ]) {
      //vault.addItem(item);
      items.add(item);
      for (Deal_Document__c doc : item.Deal_Documents__r) {
        contentVersionMap.put(doc.ContentVersion_Id__c, null);
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
    vault.folders.sort();

    for (DocumentFolder folder : vault.folders) {
      folder.documents.sort();
    }

    return vault;
  }

  public class DocumentVault {
    public List<DocumentFolder> folders;
    public Id id;
    public string name;

    transient Map<String, DocumentFolder> folderMap;

    DocumentVault() {
      folders = new List<DocumentFolder>();
      folderMap = new Map<String, DocumentFolder>();
    }

    public void addItem(Checklist_Item__c item) {
      String folderString = item.Folder_String__c;
      List<String> folderStrings = folderString.split(';');

      if (folderStrings.size() > 1) {
        String folderName = folderStrings[1];
        if (!folderMap.containsKey(folderName)) {
          folderMap.put(folderName, new DocumentFolder(folderName));
          folders.add(folderMap.get(folderName));
        }

        folderMap.get(folderName).addItem(item);
      } else {
        if (!folderMap.containsKey(folderStrings[0])) {
          folderMap.put(folderStrings[0], new DocumentFolder(folderStrings[0]));
          folders.add(folderMap.get(folderStrings[0]));
        }

        folderMap.get(folderStrings[0]).addItem(item);
      }
    }
  }

  public class DocumentFolder implements Comparable {
    String folderName;
    public List<ChecklistItem> documents;
    //public List<DocumentFolder> folders;

    //transient Map<String, DocumentFolder> folderMap;
    DocumentFolder(String folderName) {
      this.folderName = folderName;
      //folderMap = new Map<String, DocumentFolder>();
      //folders = new List<DocumentFolder>();
      documents = new List<ChecklistItem>();
    }

    public void addItem(Checklist_Item__c item) {
      String folderString = item.Folder_String__c;
      List<String> folderStrings = folderString.split(';');

      ChecklistItem checklistItem = new ChecklistItem(item);
      //system.debug(folderString);
      // if (folderStrings.size() > 1) {
      //   String folderName = folderStrings[1];
      //   if (!folderMap.containsKey(folderName)) {
      //     folderMap.put(folderName, new DocumentFolder(folderName));
      //     folders.add(folderMap.get(folderName));
      //   }

      //   folderMap.get(folderName).documents.add(checklistItem);
      //   //folderMap.get(folders[1]).addDocument(item);
      // } else {
      //   documents.add(checklistItem);
      // }
      documents.add(checklistItem);
    }

    public Integer compareTo(Object folder) {
      DocumentFolder compareToFOlder = (DocumentFOlder) folder;
      if (this.folderName > compareToFolder.folderName) {
        return 1;
      } else if (this.folderName < compareToFolder.folderName) {
        return -1;
      } else {
        return 0;
      }
    }
  }

  public class ChecklistItem implements Comparable {
    Id itemId;
    // List<Deal_Document__c> uploadedDocuments;
    List<Document> uploadedDocuments;
    String documentType;

    ChecklistItem(Checklist_Item__c item) {
      itemId = item.id;
      documentType = item.Document_Type__c;

      uploadedDocuments = new List<Document>();
      // if (item.Deal_Documents__r.size() > 0) {
      //   uploadedDocuments.add(new Document(doc));
      //   // uploadedDocuments = item.Deal_Documents__r;
      // }
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
    Document(Deal_Document__c doc) {
      fileName = doc.File_Name__c;

      ContentVersion cv = contentVersionMap.get(doc.ContentVersion_Id__c);
      if (cv != null) {
        this.fileExtension = cv.FileExtension;
        this.id = cv.Id;
      }
    }
  }

  @HttpPost
  global static void doPost() {
    RestRequest req = RestContext.request;
    RestResponse res = Restcontext.response;

    List<String> params = Restcontext.request.requestURI.split('/');

    if (params[3] == 'upload') {
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
          Property__r.Deal__c,
          Deal_Contact__c,
          Deal_Contact__r.Deal__c
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

      if (String.isNotBlank(item.Deal_Contact__c)) {
        dealDoc.Deal_Contact__c = item.Deal_Contact__c;
        dealDoc.Deal__C = item.Deal_Contact__r.Deal__c;
      }

      dealDoc.Checklist_Item__c = itemId;

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