@RestResource(urlMapping='/landgorilla/')
global without sharing class LandGorillaDrawAPI {
  @HttpPost
  global static void postMethod() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    DrawResponse response = new DrawResponse();
    try {
        DrawRequest request = (DrawRequest) JSON.deserialize(req.requestBody.toString(), DrawRequest.class);
        switch on request.data.updated_status {
            when 'Draw Create' {
                createAdvance(request);
            }
        }
        response.message = 'success';
        res.statusCode = 201;
        res.responseBody = Blob.valueOf(JSON.serialize(response));

    } catch (Exception err) {
        response.message = err.getMessage() + ' on line ' + err.getLineNumber();
        res.statusCode = 400;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
  }

  public static void createAdvance(DrawRequest req) {
    String loanId = String.valueOf(req.data.loan_id);
    List<Property__c> prop = [
        SELECT Id, Deal__c
        FROM Property__c
        WHERE ConstructionManagementLoanId__c = :loanId
    ];

    if(prop.size() > 0) {
        Advance__c adv = new Advance__c(
            Deal__c = prop[0].Deal__c,
            Status__c = 'Pending',
            DrawContainerId__c = String.valueOf(req.id)
        );

        insert adv;

        Property_Advance__c propAdv = new Property_Advance__c(
            Property__c = prop[0].Id,
            Advance__c = adv.Id
        );
        
        insert propAdv;
    }
  }

  public class DrawResponse {
      public String message { get; set; }
  }

  public class DrawData {
      public Integer loan_id { get; set; }
      public String draw_name { get; set; }
      public String updated_status { get; set; }
  }

  public class DrawRequest {
      public Integer id { get; set; }
      public DrawData data { get; set; }
      public String date_webhook {get; set;}
  }
}