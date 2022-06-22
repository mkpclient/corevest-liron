@RestResource(urlMapping='/servicelink/*')
global without sharing class ServiceLinkEndpoint {
  @HttpPost
  global static void postMethod() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    List<String> params = Restcontext.request.requestURI.split('/');
  }
}