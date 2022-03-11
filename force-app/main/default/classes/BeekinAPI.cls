public class BeekinAPI {
    public static Red_Bell_Settings__c BeekinSettings = Red_bell_Settings__c.getInstance();
    static String USERNAME = BeekinSettings.Username__c;
    static String PASSWORD = BeekinSettings.Password__c;
    static String GRANT_TYPE = BeekinSettings.Grant_Type__c;
    static String BASE_URL = BeekinSettings.Endpoint__c;
    static String ACCESS_TOKEN;
    static Boolean RETRIED_AUTH = False;

    @auraEnabled
    public static Map<String, Object> getProperties(Id recordId) {
        Map<String, Object> response = new Map<String, Object>();
        
        List<Property__c> properties = [SELECT Id, Name, City__c, State__c, ZipCode__c, Status__c, Number_of_Beds__c, Number_of_Bath__c
                                        , Square_Feet__c, Year_Built__c, Pool__c, Property_Type__c, Invalid_Address__c,
											(Select Estimated_Rent__c,Estimated_Min_Rent__c,Estimated_Max_Rent__c
											from Property_AVMs__r where recordtypeid = '012780000008V3MAAU')
                                        FROM Property__c
                                        WHERE
                                            Property__c.Deal__c = :recordId AND Status__c NOT IN ('Inactive','Cancelled','Rescinded')
                                        AND
                                            Property__c.ZipCode__c != null AND 
                                            (Property__c.Property_Type__c = null OR Property__c.Property_Type__c = 'SFR' 
                                             OR Property__c.Property_Type__c = 'Condo' OR Property__c.Property_Type__c = 'Townhome' 
                                             OR (Property__c.Property_Type__c = '2-4 Unit' AND Property__c.Is_Parent__c = true))
                                        ORDER BY Property_Name__c
                                        ];

        System.debug('RS999 property :' +properties);
        response.put('properties', properties);
        return response;
    }

    public class TokenResponse {
        String access_token;
        String token_type;
        Integer expires_in;
        String error;
        String error_description;
    }

    public class AveResponse {
        AveData ave;
        Integer status;
        String message;
    }

    public class AveData {
        AveSubjectData subject;
        AveCompData comps;
    }

    public class AveSubjectData {
        String address;
        String city;
        String state;
        String zip;
        Decimal bed;
        Decimal bath;
        Decimal sqft;
        String propertyType;
        Boolean Pool;
    }

    public class AveCompData {
        Integer estimatedRent;
        Integer estimatedMinRent;
        Integer estimatedMaxRent;
        }

    public static void throwError(String errorMsg) {
        AuraHandledException ex = new AuraHandledException(errorMsg);
        ex.setMessage(errorMsg);
        throw ex;
    }

    @auraEnabled
    public static Map<String, Object> callBeekin(List<Property__c> properties, Id recordId) {
        System.debug(properties);
        AveResponse aveResponse;

        getAccessToken();
        for (Property__c prop : properties) {
            getAveData(prop);
        }
        System.debug(998);
        update properties;
        System.debug(999);
        return getProperties(recordId);
    }

    @auraEnabled
    public static Map<String, Object> callBeekinSingle(Property__c property, Id recordId) {
        System.debug(property);
        AveResponse aveResponse;

        getAccessToken();
        getAveData(property);
        System.debug(998);
        update property;
        System.debug(999);
        return getProperties(recordId);
    }

    public static void getAccessToken() {
        Map<String, String> parameters;
        Map<String, String> headers;
        String endpoint;
        String method;
        String body;
        String rawJSON;
        TokenResponse tokenResponse;

        parameters = new Map<String, String>();
        parameters.put('grant_type', GRANT_TYPE);
        parameters.put('username', USERNAME);
        parameters.put('password', PASSWORD);

        body = getBodyString(parameters);

        headers = new Map<String, String>();
        headers.put('Content-Type', 'application/x-www-form-urlencoded');
        headers.put('Content-Length', String.valueOf(body.length()));
        headers.put('Accept', 'application/json');

        endpoint = BASE_URL + '/token';

        method = 'POST';

        System.debug('body:');
        System.debug(body);
        System.debug(endpoint);

        rawJSON = callOut(method, endpoint, body, headers);

        System.debug(444);
        System.debug(rawJSON);

        TokenResponse = (TokenResponse)JSON.deserialize(rawJSON, TokenResponse.class);

        if (TokenResponse.error != null && TokenResponse.error_description != null) {
            throwError(TokenResponse.error_description);
        }
        else if (TokenResponse.error != null) {
            throwError(TokenResponse.error);
        }
        else {
            ACCESS_TOKEN = TokenResponse.access_token;
        }
    }

    public static void getAveData(Property__c prop) {
        Map<String, String> parameters;
        Map<String, String> headers;
        String endpoint;
        String method;
        String body;
        String rawJSON;
        AveResponse aveResponse;

        string noofbeds = string.valueof(prop.Number_of_Beds__c);
        string noofbath = string.valueof(prop.Number_of_Bath__c);
        string sqft = string.valueof(prop.Square_Feet__c);
        
        String pool = 'false';
        
        if (prop.pool__c == 'Y')
        {
           pool = 'true'; 
        }
        
        string propertytype;
      
        switch on  prop.Property_Type__c
         {
             when 'a' {
                 propertytype = '0';
             }
             when 'b' {
                 propertytype = '1';
             }
             when 'c' {
                 propertytype = '2';
             }
             when 'd' {
                 propertytype = '3';
             }             
        }
            
        parameters = new Map<String, String>{'Address'=>prop.Name, 'Sqft'=>sqft, 'beds'=>noofbeds, 'bath'=>noofbath, 'pool'=>pool, 'property_type'=>propertytype};
        body = JSON.serialize(parameters);
        System.debug(body);

        headers = new Map<String, String>();
        headers.put('Authorization', 'bearer ' + ACCESS_TOKEN);
        headers.put('Content-Type', 'application/json');
        headers.put('Content-Length', String.valueOf(body.length()));
        headers.put('Accept', 'application/json');

        endpoint = BASE_URL + '/upload/ave';

        method = 'POST';

        rawJSON = callOut(method, endpoint, body, headers);
        System.debug('123');
        System.debug(rawJSON);
        aveResponse = (AveResponse)JSON.deserialize(rawJSON, AveResponse.class);
        System.debug(aveResponse);
        if (aveResponse.message == 'Authorization has been denied for this request.' && RETRIED_AUTH == True) {
            System.debug(555);
            throwError(aveResponse.message);
        }
        else if (aveResponse.message == 'Authorization has been denied for this request.') {
            System.debug(666);
            RETRIED_AUTH = True;
            getAccessToken();
            getAveData(prop);
        }
        else if (aveResponse.status != 0) {
            System.debug(777);
            throwError(aveResponse.message);
        }
        else {
            System.debug(888);
            RETRIED_AUTH = False;
            populatePropertyWithFields(prop, aveResponse);
        }
    }

    public static void populatePropertyWithFields(Property__c prop, AveResponse aveResponse) {

        System.debug(aveResponse);

       // prop.Estimated_Max_Rent__c = aveResponse.ave.subject.estimatedMaxRent ;
       // prop.Estimated_Min_Rent__c =  aveResponse.ave.subject.estimatedMinRent;
       // prop.Estimated_Rent__c =  aveResponse.ave.subject.estimatedRent;
       
        
        Property_AVM__c avm=new Property_AVM__c();
        if(prop.Property_AVMs__r.size()>0){
            avm.Id=prop.Property_AVMs__r[0].Id;
        }else{
			avm.RelatedProperty__c=prop.Id;
		}
     
           
        if(avm.Id==null){
            insert avm;
        }else{
            update avm;
        }
        
    }


    public static String getBodyString(Map<String, String> parameters) {
        String bodyStr = '';
        if (parameters != null) {
            for (String key : parameters.keySet()) {
                bodyStr += key + '=' + EncodingUtil.urlEncode(parameters.get(key), 'UTF-8') + '&';
            }
        }
        return bodyStr;
    }

    public static String callOut(String method, String endpoint, String body, Map<String, String> headers) {
        HttpResponse response = new HttpResponse();

        HttpRequest request = new httpRequest();
        request.setTimeout(60000);
    request.setMethod(method);
        request.setEndpoint(endpoint);
        if (headers != null) {
            for (String key : headers.keySet()) {
                request.setHeader(key, headers.get(key));
            }
        }
        if (body != null) {
            request.setBody(body);
        }
        response = new Http().send(request);
        return response.getBody();
    }
   
 }