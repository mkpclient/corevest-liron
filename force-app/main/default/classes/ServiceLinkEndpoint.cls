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
  }

  public class QuoteReceivedConfirm {
    public String LoanNumber;
    public String QuoteId;
    public String BulkProjectOrderNum;
    public String OrderOpenedDate;
  }
}