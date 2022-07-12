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
    res.addHeader('Content-Type', 'application/json');
    Map<String, String> resMap = new Map<String, String>();
    try {
      Map<String,ServiceLinkResponse> respMap = (Map<String,ServiceLinkResponse>) JSON.deserialize(requestString, Map<String,ServiceLinkResponse>.class);
      if (respMap.containsKey('QuoteReceivedConfirm')) {
        resMap.put(
          'LoanNumber',
          processQuoteReceivedConfirm(respMap.values()[0])
        );
      } else if (respMap.containsKey('QuoteResponse')) {
        resMap.put(
          'LoanNumber',
          processQuoteResponse(respMap.values()[0])
        );
      } else if (respMap.containsKey('OrderInquiryResponse')) {

      } else if (respMap.containsKey('OrderConfirmation')) {
        resMap.put('LoanNumber', processOrderConfirmation(respMap.values()[0]));
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

  public static String processOrderConfirmation(ServiceLinkResponse ordConf) {
    List<Title_Order__c> titleOrders = [
      SELECT Id
      FROM Title_Order__c
      WHERE Asset_ID__c = :ordConf.AssetID AND
      Bulk_Project_Order_Num__c = :ordConf.BulkProjectOrderNum
      FOR UPDATE
    ];
    if(titleOrders.size() == 0) {
      ServiceLinkException err = new ServiceLinkException();
      err.setMessage('Unable to locate orders.');
      throw err;
    }
    
    for(Title_Order__c to : titleOrders) {
      to.Order_Opened_Date__c = DateTime.valueOf(ordConf.OrderOpenedDate.replace('T', ' '));
      if(ordConf.Status == 'SUCCESS') {
        to.Order_Number__c = ordConf.OrderNumber;
        to.Status__c = 'Order Confirmed';
      } else {
        to.Status__c = 'Order Failed';
        to.Error_Message__c = ordConf.ErrorMessage;
      }
    }

    update titleOrders;

    return ordConf.LoanNumber;
  }

  public static String processQuoteResponse(ServiceLinkResponse qteRes) {
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

  public static String processQuoteReceivedConfirm(ServiceLinkResponse reqObj) {
    List<Title_Order__c> titleOrders = [
      SELECT Bulk_Project_Order_Num__c
      FROM Title_Order__c
      WHERE Quote_ID__c = :reqObj.QuoteID
      FOR UPDATE
    ];
    if (titleOrders.size() > 0) {
      for (Title_Order__c tO : titleOrders) {
        tO.Order_Opened_Date__c = DateTime.valueOf(reqObj.OrderOpenedDate.replace('T', ' '));
        tO.Bulk_Project_Order_Num__c = reqObj.BulkProjectOrderNum;
      }
      update titleOrders;
    } else {
      ServiceLinkException err = new ServiceLinkException();
      err.setMessage('No existing order found for QuoteID ' + reqObj.QuoteID);
      throw err;
    }

    return reqObj.LoanNumber;
  }

  public virtual class ServiceLinkResponse {
    public String LoanNumber { get; set; }
    public String QuoteID { get; set; }
    public String BulkProjectOrderNum { get; set; }
    public String OrderOpenedDate { get; set; }
    public String Comments { get; set; }
    public ServiceLinkAPI.TitleDocument Document { get; set; }
    public String AssetID { get; set; }
    public String OrderNumber { get; set; }
    public String Status { get; set; }
    public String ErrorMessage { get; set; }
  }

}