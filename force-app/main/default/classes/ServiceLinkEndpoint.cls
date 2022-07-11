@RestResource(urlMapping='/servicelink/*')
global without sharing class ServiceLinkEndpoint {
  public class ServiceLinkException extends Exception {
  }

  @HttpPost
  global static void postMethod() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    Blob body = req.requestBody;
    String requestString = body.toString();
    Map<String, Object> reqMap = (Map<String, Object>) JSON.deserialize(
      requestString,
      Map<String, Object>.class
    );
    res.addHeader('Content-Type', 'application/json');
    Map<String, String> resMap = new Map<String, String>();
    try {
      if (reqMap.containsKey('QuoteReceivedConfirm')) {
        resMap.put(
          'LoanNumber',
          processQuoteReceivedConfirm(reqMap.get('QuoteReceivedConfirm'))
        );
      } else if (reqMap.containsKey('QuoteResponse')) {
        resMap.put(
          'LoanNumber',
          processQuoteResponse(reqMap.get('QuoteResponse'))
        );
      }
      res.statusCode = 201;
      resMap.put('status', 'success');
      res.responseBody = Blob.valueOf(JSON.serialize(resMap));
    } catch (Exception err) {
      res.statusCode = 400;
      res.responseBody = Blob.valueOf(
        JSON.serialize(
          new Map<String, String>{
            'status' => 'error',
            'message' => err.getMessage()
          }
        )
      );
    }
    // List<String> params = Restcontext.request.requestURI.split('/');
  }

  public static String processQuoteResponse(Object obj) {
    QuoteResponse qteRes = (QuoteResponse) obj;
    List<Title_Order__c> titleOrders = [
      SELECT Id, Deal__c, Property__c
      FROM Title_Order__c
      WHERE Quote_ID__c = :qteRes.QuoteID
    ];
    if (titleOrders.size() > 0) {
      ContentVersion cv = createContentVersion(
        new List<ServiceLinkAPI.TitleDocument>{ qteRes.Document },
        titleOrders[0].Deal__c
      )[0];
      List<Deal_Document__c> dealDocs = new List<Deal_Document__c>();
      for (Title_Order__c tos : titleOrders) {
        ServiceLinkAPI.TitleDocument doc = qteRes.Document;
        Deal_Document__c dd = new Deal_Document__c(
          File_Name__c = cv.Title,
          ContentVersion_Id__c = cv.Id,
          Attachment_Id__c = cv.ContentDocumentId,
          Type__c = doc.DocumentType,
          Section__c = 'Title Orders',
          Document_Type__c = doc.DocumentType,
          Document_Loaded__c = true,
          Added_By__c = userInfo.getUserId(),
          Other_Document_Type__c = 'Title Order Documents',
          Deal__c = titleOrders[0].Deal__c,
          Property__c = titleOrders[0].Property__c
        );
        dealDocs.add(dd);
      }
      insert dealDocs;
    } else {
      ServiceLinkException err = new ServiceLinkException();
      err.setMessage('No existing order found for QuoteID ' + qteRes.QuoteID);
      throw err;
    }
    return qteRes.LoanNumber;
  }

  public static List<ContentVersion> createContentVersion(
    List<ServiceLinkAPI.TitleDocument> docs,
    Id parentId
  ) {
    List<ContentVersion> contentVersions = new List<ContentVersion>();

    for (ServiceLinkAPI.TitleDocument doc : docs) {
      ContentVersion cv = new ContentVersion();
      cv.VersionData = EncodingUtil.base64Decode(doc.Base64FileData);
      cv.Title = doc.DocumentName;
      cv.PathOnClient = doc.DocumentName;
      cv.Type__c = doc.DocumentType;
      contentVersions.add(cv);
    }

    insert contentVersions;

    List<ContentVersion> cvsQueried = [
      SELECT Id, VersionData, Title, PathOnClient, Type__c, ContentDocumentId
      FROM ContentVersion
      WHERE Id IN :contentVersions
    ];
    List<ContentDocumentLink> cdLinks = new List<ContentDocumentLink>();

    for (ContentVersion cv : cvsQueried) {
      ContentDocumentLink cdl = new ContentDocumentLink(
        ShareType = 'I',
        Visibility = 'AllUsers',
        LinkedEntityId = parentId,
        ContentDocumentId = cv.ContentDocumentId
      );
      cdLinks.add(cdl);
    }

    insert cdLinks;
    return cvsQueried;
  }

  public static void createDocument(
    List<ServiceLinkAPI.TitleDocument> docs,
    Id dealId,
    Id propId
  ) {
  }

  public static String processQuoteReceivedConfirm(Object obj) {
    QuoteReceivedConfirm reqObj = (QuoteReceivedConfirm) obj;
    List<Title_Order__c> titleOrders = [
      SELECT Bulk_Project_Order_Num__c
      FROM Title_Order__c
      WHERE Quote_ID__c = :reqObj.QuoteID
      FOR UPDATE
    ];
    if (titleOrders.size() > 0) {
      for (Title_Order__c tO : titleOrders) {
        tO.Order_Opened_Date__c = DateTime.parse(reqObj.OrderOpenedDate);
      }
      update titleOrders;
    } else {
      ServiceLinkException err = new ServiceLinkException();
      err.setMessage('No existing order found for QuoteID ' + reqObj.QuoteID);
      throw err;
    }

    return reqObj.LoanNumber;
  }

  public virtual class QuoteReceivedConfirm {
    public String LoanNumber { get; set; }
    public String QuoteID { get; set; }
    public String BulkProjectOrderNum { get; set; }
    public String OrderOpenedDate { get; set; }
  }

  public class QuoteResponse extends QuoteReceivedConfirm {
    public String Comments { get; set; }
    public ServiceLinkAPI.TitleDocument Document { get; set; }
  }
}
