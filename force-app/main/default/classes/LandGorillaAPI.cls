public without sharing class LandGorillaAPI {
  public static final String BASE_URL = Settings__mdt.getInstance(
      'Universal_Settings'
    )
    .LandGorilla_Endpoint__c;
  public static final String API_NAME = Settings__mdt.getInstance(
      'Universal_Settings'
    )
    .LandGorllia_ApiName__c;
  public static final String USERNAME = Settings__mdt.getInstance(
      'Universal_Settings'
    )
    .LandGorilla_Username__c;
  public static final String PASSWORD = Settings__mdt.getInstance(
      'Universal_Settings'
    )
    .LandGorilla_Password__c;
  public static final Boolean IS_API_ENABLED = Settings__mdt.getInstance(
      'Universal_Settings'
    )
    .Enable_LandGorilla_API__c;

  public class TokenResponse {
    public String id { get; set; }
    public String token { get; set; }
    public DateTime expired { get; set; }
  }

  public class PostResponse {
    public String id { get; set; }
    public String message { get; set; }
  }

  public static TokenResponse currentToken {
    get {
      if (
        !IS_API_ENABLED ||
        String.isEmpty(BASE_URL) ||
        String.isEmpty(API_NAME) ||
        String.isEmpty(USERNAME) ||
        String.isEmpty(PASSWORD)
      ) {
        return null;
      }

      if (
        currentToken != null &&
        currentToken.expired < System.now().dateGmt()
      ) {
        return currentToken;
      }

      return requestToken();
    }
    private set;
  }

  public static TokenResponse requestToken() {
    String token = '';
    HttpRequest req;
    HttpResponse resp;
    String tokenEndpoint = BASE_URL + '/api/token&api_name=' + API_NAME;
    try {
      req = new HttpRequest();
      req.setEndpoint(tokenEndpoint);
      req.setMethod('GET');
      req.setHeader('USER', USERNAME);
      req.setHeader('PASSWORD', PASSWORD);

      String payload = 'api_name=' + API_NAME;

      req.setTimeout(120000);
      Integer statusCode = 200;
      String respBody = '';

      if (!Test.isRunningTest()) {
        resp = new Http().send(req);
        statusCode = resp.getStatusCode();
        respBody = resp.getBody();
        if (statusCode == 200) {
          Map<String, Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(
            respBody
          );
          TokenResponse retVal = new TokenResponse();
          retVal.id = String.valueOf(respMap.get('id'));
          retVal.token = String.valueOf(respMap.get('token'));
          // 2021-09-27 13:44:52
          String dateString = String.valueOf(respMap.get('expired'));
          // Integer year = Integer.valueOf(dateString.substring(0, 4));
          // Integer month = Integer.valueOf(dateString.substring(5, 7));
          // Integer day = Integer.valueOf(dateString.substring(8, 10));
          // Integer hour = Integer.valueOf(dateString.substring(11, 13));
          // Integer minute = Integer.valueOf(dateString.substring(14, 16));
          // Integer second = Integer.valueOf(dateString.substring(17, 19));
          retVal.expired = Datetime.valueOf(dateString);
          System.debug(retVal);
          return retVal;
        } else {
          return null;
        }
      } else {
        TokenResponse respMap = new TokenResponse();
        respMap.id = '1';
        respMap.token = '12345';
        respMap.expired = System.now().addHours(1);
        return respMap;
      }
    } catch (Exception err) {
      System.debug(err.getMessage());
      return null;
    }
  }

  public static void processPropertiesForPostLoan(Set<Id> propertyIds) {
    List<Property__c> props = [
      SELECT
        Id,
        Name,
        City__c,
        ZipCode__c,
        Approved_Advance_Amount__c,
        County__c,
        State__c,
        Yardi_Id__c,
        Deal__r.Borrower_entity__r.Name,
        Deal__r.Original_Line_Maturity_Date__c,
        Deal__r.CloseDate,
        Deal__r.Stated_Maturity_Date__c
      FROM Property__c
      WHERE
        Id = :propertyIds
        AND ((Deal__r.LOC_Loan_Type__c = 'Credit Line'
        AND Deal__r.Product_Sub_Type__c = 'Renovation')
        OR Deal__r.LOC_Loan_Type__c = 'Multifamily/CRE'
        OR (Deal__r.LOC_Loan_Type__c = 'Single Asset (1-4 Unit)'
        AND Deal__r.Product_Sub_Type__c IN ('Renovation', 'Construction'))
        OR (Deal__r.LOC_Loan_Type__c = 'Single Asset (5-10 Unit)'
        AND Deal__r.Product_Sub_Type__c IN ('Renovation', 'Construction'))
        OR Deal__r.LOC_Loan_Type__c = 'Build to Rent')
        AND Deal__r.StageName IN ('Approved by Committee', 'Closed Won')
        AND RecordType.Name IN (
          'Bridge Renovation',
          'Bridge Renovation Special Asset',
          'Ground Up Construction',
          'Ground Up Construction Special Asset'
        )
    ];

    if (props.size() > 0) {
      List<Property__c> updatedProperties = new List<Property__c>();
      for (Property__c prop : props) {
        PostResponse res = postLoan(prop);
        if (res != null && String.isNotBlank(res.id)) {
          updatedProperties.add(
            new Property__c(
              Id = prop.Id,
              ConstructionManagementLoanId__c = res.id
            )
          );
        }
      }

      if (updatedProperties.size() > 0) {
        update updatedProperties;
      }
    }
  }

  public static PostResponse postLoan(Property__c p) {
    if (
      !IS_API_ENABLED ||
      String.isEmpty(BASE_URL) ||
      String.isEmpty(API_NAME) ||
      String.isEmpty(USERNAME) ||
      String.isEmpty(PASSWORD)
    ) {
      return null;
    }

    String postLoanEndpoint = BASE_URL + '/api/clm/loan';
    HttpRequest req;
    HttpResponse resp;
    try {
      TokenResponse tokenData = currentToken;
      String token = tokenData.token;
      PostResponse returnStatement = new PostResponse();
      req = new HttpRequest();
      req.setMethod('POST');
      Map<String, String> headers = new Map<String, String>();
      req.setHeader('Authorization', 'Bearer ' + token);

      req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
      req.setEndpoint(postLoanEndpoint);
      Map<String, String> payload = new Map<String, String>();
      payload.put('Loan File Number', p.Yardi_Id__c);
      // payload.put('Loan Type', 'Commercial');
      // payload.put('Loan Program', 'Test');
      // payload.put('Loan Purpose', 'Purchase');
      // payload.put('Loan Term in Days', '' + (p.Deal__r.CloseDate.daysBetween(p.Deal__r.Original_Line_Maturity_Date__c)));
      // payload.put('Loan Funded Date', String.valueOf(p.Deal__r.CloseDate));
      payload.put('Subject property address', p.Name);
      payload.put('Zip', p.ZipCode__c);
      payload.put('City', p.City__c);
      payload.put('State', p.State__c);
      payload.put('County', p.County__c);
      // payload.put('Borrower First Name', p.Deal__r.Borrower_entity__r.Name.substringBefore(' '));
      // payload.put('Borrower Last Name', p.Deal__r.Borrower_entity__r.Name.substringAfterLast(' '));
      // payload.put('Loan Amount', String.valueOf(p.Approved_Advance_Amount__c));

      // payload.put('Loan File Number', '1234ABC');
      // payload.put('Loan Type', 'Commercial');
      // payload.put('Loan Program', 'Test');
      // payload.put('Loan Purpose', 'Purchase');
      // payload.put('Loan Term in Days', '10950');
      // payload.put('Loan Funded Date', '5/11/2022');
      // payload.put('Subject property address', '1600 Pennsylvania Ave NW');
      // payload.put('Zip', '20500');
      // payload.put('City', 'Washington');
      // payload.put('State', 'DC');
      // payload.put('County', 'DC');
      // payload.put('Borrower First Name', 'John');
      // payload.put('Borrower Last Name', 'Doe');
      // payload.put('Loan Amount', '2000000');

      req.setBody(getBodyString(payload));
      req.setTimeout(120000);

      if (!Test.isRunningTest()) {
        resp = new Http().send(req);
        if (resp.getStatusCode() == 200) {
          String respval = resp.getBody();
          returnStatement = (PostResponse) JSON.deserialize(
            respval,
            PostResponse.class
          );
        } else {
          System.debug(resp.getBody());
        }
      }

      return returnStatement;
    } catch (Exception err) {
      System.debug(err.getMessage() + ' on line ' + err.getLineNumber());
      return null;
    }
  }

  public static String getBodyString(Map<String, String> parameters) {
    String bodyStr = '';
    if (parameters != null) {
      for (String key : parameters.keySet()) {
        bodyStr +=
          key +
          '=' +
          EncodingUtil.urlEncode(parameters.get(key), 'UTF-8') +
          '&';
      }
    }
    return bodyStr;
  }
}
