@RestResource(urlMapping='/servicelink/*')
global without sharing class ServiceLinkEndpoint {
  @HttpPost
  global static void postMethod() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    Blob body = req.requestBody;
    String requestString = body.toString();
    Map<String, Object> reqMap = (Map<String,Object>) JSON.deserialize(requestString, Map<String,Object>.class);
    if(reqMap.containsKey('QuoteReceivedConfirm')) {
      processQuoteReceivedConfirm(reqMap.get('QuoteReceivedConfirm'));
    }
    List<String> params = Restcontext.request.requestURI.split('/');
  }

  public static void processQuoteReceivedConfirm(Object obj) {
    QuoteReceivedConfirm reqObj = (QuoteReceivedConfirm) obj;
    List<Title_Order__c> titleOrders = [SELECT Bulk_Project_Order_Num__c FROM Title_Order__c WHERE Bulk_Project_Order_Num__c = :reqObj.BulkProjectOrderNum FOR UPDATE];
    for(Title_Order__c tO : titleOrders) {
      tO.Order_Opened_Date__c = DateTime.parse(reqObj.OrderOpenedDate);
    }

    update titleOrders;
  }

  public class QuoteReceivedConfirm {
    public String LoanNumber;
    public String QuoteId;
    public String BulkProjectOrderNum;
    public String OrderOpenedDate;
  }
}