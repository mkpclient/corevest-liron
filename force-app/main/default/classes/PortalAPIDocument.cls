@RestResource(urlMapping='/portal/documents/*')
global without sharing class PortalAPIDocument {
  static String portalId;
  static String contactId;

  public static Integer paginationStart;
  public static Integer paginationEnd;
  public static Boolean usePagination;
  public static PortalAPIUser.PortalUser user;
  static Id recordId;

  @HttpGet
  global static void doGet() {
    RestRequest req = RestContext.request;
    RestResponse res = Restcontext.response;

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

    system.debug(page);
    system.debug(pageSize);

    usePagination = false;
    if (pageSize != null && page != null) {
      paginationStart = (page - 1) * pageSize; //2 4*1
      paginationEnd = page * pageSize; //3
      usePagination = true;
    }

    system.debug(paginationStart);
    system.debug(paginationEnd);

    List<String> params = Restcontext.request.requestURI.split('/');
    portalId = params[3];

    user = new PortalAPIUser.PortalUser(portalId);

    if (user.id != null) {
      recordId = params[4];
      String sobjectType = recordId.getSObjectType().getDescribe().getName();
      if (sobjectType == 'Deal_Document__c') {
        if (params.size() > 5 && params[5] == 'data') {
          //res.addHeader('Content-Type', 'application/json');
          //res.responseBody = Blob.valueOf(JSON.serialize(docData, true));
        } else {
          Document document = new Document(recordId);

          res.addHeader('Content-Type', 'application/json');
          res.responseBody = Blob.valueOf(JSON.serialize(document, true));
        }
      } else {
        List<Document> documents = getDocuments();

        Map<Id, Document> contentVersionMap = new Map<Id, Document>();
        for (Document doc : documents) {
          contentVersionMap.put(doc.id, doc);
        }

        for (ContentVersion cv : [
          SELECT Id, FileExtension
          FROM ContentVersion
          WHERE Id IN :contentVersionMap.keySet()
        ]) {
          contentVersionMap.get(cv.Id).FileExtension = cv.FileExtension;
        }

        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(documents, true));
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

  public static List<Document> getDocuments() {
    List<Document> documents = new List<Document>();
    List<Deal_Document__c> docs = [
      SELECT
        Id,
        Deal__r.Name,
        Document_Type__c,
        Deal__c,
        Name,
        Property__c,
        File_Name__c,
        Property__r.Name,
        ContentVersion_Id__c,
        Added_On__c
      FROM Deal_Document__c
      WHERE Deal__c = :recordId OR Property__c = :recordId
      ORDER BY CreatedDate DESC
    ];

    Integer docSize = docs.size();

    if (!usePagination) {
      paginationStart = 0;
      paginationEnd = docSize;
    }

    for (Integer i = paginationStart; i < paginationEnd; i++) {
      documents.add(new Document(docs[i]));
    }

    return documents;
  }

  public class Document {
    String docNumber;
    Id id;
    String address;
    String dealName;
    String fileName;
    String documentType;
    public String fileExtension;
    DateTime addedOn;
    public Document(Id docId) {
      Deal_Document__c doc = [
        SELECT
          Id,
          File_Name__c,
          Deal__r.Name,
          Document_Type__c,
          Deal__c,
          Name,
          Property__c,
          Property__r.Name,
          ContentVersion_Id__c,
          Added_On__C
        FROM Deal_Document__c
        WHERE Id = :docId
        LIMIT 1
      ];

      this.id = doc.ContentVersion_Id__c;
      this.dealName = doc.Deal__r.Name;
      this.address = doc.Property__r.Name;
      this.fileName = doc.File_Name__c;
      this.docNumber = doc.Name;
      this.documentType = doc.Document_Type__c;
      this.addedOn = doc.Added_On__c;

      if (this.fileName.contains('.')) {
        this.fileName = this.fileName.substringBefore('.');
      }

      ContentVersion cv = [
        SELECT Id, FileExtension
        FROM ContentVersion
        WHERE Id = :doc.ContentVersion_Id__c
      ];
      this.fileExtension = cv.FileExtension;
    }

    public Document(Deal_Document__c doc) {
      this.docNumber = doc.Name;
      this.id = doc.ContentVersion_Id__c;
      this.dealName = doc.Deal__r.Name;
      this.fileName = doc.File_Name__c;
      this.documentType = doc.Document_Type__c;
      this.addedOn = doc.Added_On__c;
      this.address = doc.Property__r.Name;

      if (this.fileName.contains('.')) {
        this.fileName = this.fileName.substringBefore('.');
      }
    }
  }
}