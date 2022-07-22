public class RedBellAPI {

    public static Red_Bell_Settings__c redBellSettings = Red_Bell_Settings__c.getInstance();
    static String USERNAME = redBellSettings.Username__c;
    static String PASSWORD = redBellSettings.Password__c;
    static String GRANT_TYPE = redBellSettings.Grant_Type__c;
    static String BASE_URL = redBellSettings.Endpoint__c;
    static String ACCESS_TOKEN;
    static Boolean RETRIED_AUTH = False;


    @auraEnabled
    public static Map<String, Object> getProperties(Id recordId) {
        Map<String, Object> response = new Map<String, Object>();
        
        List<Property__c> properties = [SELECT Id, Name, City__c, State__c, ZipCode__c, Status__c, Number_of_Beds__c, Number_of_Bath__c, Square_Feet__c, Year_Built__c, APN__c, Borrower_Opinion_of_Current_Value__c, Property_Type__c, Invalid_Address__c, Calc_AveValue__c, Is_HOA__c,
											(Select AVM_Provider__c, AVM_Is_HOA__c, AVM_Address__c, AVM_City__c, AVM_State__c, AVM_ZIP__c, AVM_Beds__c, AVM_Baths__c, AVM_Square_Feet__c, AVM_Year_Built__c, AVM_APN__c, AVM_REO__c, AVM_Last_Sale_Price__c, AVM_Last_Sale_Date__c, AVM_Calculated_Price__c, AVM_Property_Type__c,//Red_Bell_Loan_Number__c,
											AVM_C1_Act_Dom__c, AVM_C1_Address__c, AVM_C1_Baths__c, AVM_C1_Beds__c, AVM_C1_City__c, AVM_C1_Comp_Type__c, AVM_C1_Garage__c, AVM_C1_Image__c, AVM_C1_included_In_Calculation__c, AVM_C1_Last_Sale_Date__c, AVM_C1_Last_Sale_Price__c, AVM_C1_List_Date__c,
											AVM_C1_List_Price__c, AVM_C1_Lot_Size__c, AVM_C1_Percentage_Of_Valuation__c, AVM_C1_Square_Feet__c,AVM_C1_Square_Foot_Price__c, AVM_C1_State__c, AVM_C1_Target_Distance__c, AVM_C1_tot_Dom__c, AVM_C1_Units__c, AVM_C1_Year_Built__c, AVM_C1_Zip__c, AVM_C1_REO__c,
											AVM_C2_Act_Dom__c, AVM_C2_Address__c, AVM_C2_Baths__c, AVM_C2_Beds__c, AVM_C2_City__c, AVM_C2_Comp_Type__c, AVM_C2_Garage__c, AVM_C2_Image__c, AVM_C2_Included_In_Calculation__c, AVM_C2_Last_Sale_Date__c, AVM_C2_Last_Sale_Price__c, AVM_C2_List_Date__c,
											AVM_C2_list_Price__c, AVM_C2_Lot_Size__c, AVM_C2_Percentage_Of_Valuation__c, AVM_C2_Square_Feet__c,AVM_C2_Square_Foot_Price__c, AVM_C2_State__c, AVM_C2_Target_Distance__c, AVM_C2_Tot_Dom__c, AVM_C2_Units__c, AVM_C2_Year_Built__c, AVM_C2_ZIP__c, AVM_C2_REO__c,
											AVM_C3_Act_Dom__c, AVM_C3_Address__c, AVM_C3_Baths__c, AVM_C3_Beds__c, AVM_C3_City__c, AVM_C3_Comp_Type__c, AVM_C3_Garage__c, AVM_C3_Image__c, AVM_C3_Included_In_Calculation__c, AVM_C3_Last_Sale_Date__c,AVM_C3_Last_Sale_Price__c, AVM_C3_List_Date__c,
											AVM_C3_List_Price__c, AVM_C3_Lot_Size__c, AVM_C3_Percentage_Of_Valuation__c, AVM_C3_Square_Feet__c,AVM_C3_Square_Foot_Price__c, AVM_C3_State__c, AVM_C3_Target_Distance__c, AVM_C3_Tot_Dom__c, AVM_C3_Units__c, AVM_C3_Year_Built__c, AVM_C3_Zip__c, AVM_C3_REO__c 
											from Property_AVMs__r where recordtypeid in (SELECT Id FROM RecordType WHERE sobjecttype = 'Property_AVM__c' 
                                                                                        and DeveloperName  = 'Red_Bell_AVM'))
                                        FROM Property__c
                                        WHERE
                                            Property__c.Deal__c = :recordId AND Status__c NOT IN ('Inactive','Cancelled','Rescinded')
                                        AND
                                            Property__c.ZipCode__c != null AND 
                                            (Property__c.Property_Type__c = null OR Property__c.Property_Type__c = 'SFR' OR Property__c.Property_Type__c = 'Condo' OR Property__c.Property_Type__c = 'Townhome' OR (Property__c.Property_Type__c = '2-4 Unit' AND Property__c.Is_Parent__c = true))
                                        ORDER BY Property_Name__c
                                        ];

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
        List<AveCompData> comps;
    }

    public class AveSubjectData {
        //String loanNumber;
        String address;
        String city;
        String state;
        String zip;
        Decimal bed;
        Decimal bath;
        Decimal sqft;
        Integer yearBuilt;
        String propertyType;
        //Boolean reo;
        String apn;
        //Datetime asOfDate;
        Decimal soldPrice;
        Datetime soldDate;
        Decimal calculatedPrice;
        Boolean isHOA;
    }

    public class AveCompData {
        String address;
        String city;
        String state;
        String zip;
        String image;
        Decimal bed;
        Decimal bath;
        Decimal sqft;
        Decimal garage;
        String lotSize;
        Integer yearBuilt;
        Integer units;
        Decimal targetDistance;
        Datetime listDate;
        Decimal listPrice;
        Datetime soldDate;
        Decimal soldPrice;
        Integer actDom;
        Integer totDom;
        Decimal sqftPrice;
        Decimal percentOfValuation;
        Boolean includedInCalculation;
        String compType;
    }

    public static void throwError(String errorMsg) {
        AuraHandledException ex = new AuraHandledException(errorMsg);
        ex.setMessage(errorMsg);
        throw ex;
    }

    @auraEnabled
    public static Map<String, Object> callRedBell(List<Property__c> properties, Id recordId) {
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
    public static Map<String, Object> callRedBellSingle(Property__c property, Id recordId) {
        System.debug(property);
        AveResponse aveResponse;

        getAccessToken();
        // for (Property__c prop : properties) {
        getAveData(property);
        //}
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

        parameters = new Map<String, String>{'Address'=>prop.Name, 'City'=>prop.City__c, 'State'=>prop.State__c, 'Zip'=>prop.ZipCode__c, 'MonthsBack'=>'six'};
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
        System.debug(999);
        System.debug(prop.Name);
        System.debug(prop.City__c);
        System.debug(prop.State__c);
        System.debug(prop.ZipCode__c);
        System.debug(prop.APN__c);
        System.debug(prop.Calc_AveValue__c);
        System.debug(prop.Number_of_Beds__c);
        System.debug(prop.Number_of_Bath__c);
        System.debug(aveResponse);

        // if (aveResponse.ave.subject.apn == null || aveResponse.ave.subject.soldPrice == null || aveResponse.ave.subject.soldDate == null) {
        //  prop.Invalid_Address__c = True;
        //  return;
        // }
        // else {
            prop.Invalid_Address__c = False;
        // }

        prop.Name = prop.Name == null ? aveResponse.ave.subject.address : prop.Name; 
        prop.City__c = prop.City__c == null ? aveResponse.ave.subject.city : prop.City__c;
        prop.State__c = prop.State__c == null ? aveResponse.ave.subject.state : prop.State__c;
        prop.ZipCode__c = prop.ZipCode__c == null ? aveResponse.ave.subject.zip : prop.ZipCode__c;
        prop.APN__c = prop.APN__c == null ? aveResponse.ave.subject.apn : prop.APN__c;
        prop.Calc_AveValue__c = prop.Calc_AveValue__c == null ? aveResponse.ave.subject.calculatedPrice : prop.Calc_AveValue__c;
        prop.Number_of_Beds__c = prop.Number_of_Beds__c == null ? aveResponse.ave.subject.bed : prop.Number_of_Beds__c;
        prop.Number_of_Bath__c = prop.Number_of_Bath__c == null ? aveResponse.ave.subject.bath : prop.Number_of_Bath__c;
        prop.Square_Feet__c = prop.Square_Feet__c   == null && aveResponse.ave.subject.sqft != null ? String.valueOf(aveResponse.ave.subject.sqft) : prop.Square_Feet__c;
        prop.Year_Built__c = prop.Year_Built__c == null && aveResponse.ave.subject.yearBuilt != null ? String.valueOf(aveResponse.ave.subject.yearBuilt) : prop.Year_Built__c;

        
        Property_AVM__c avm=new Property_AVM__c();
        if(prop.Property_AVMs__r.size()>0){
            avm.Id=prop.Property_AVMs__r[0].Id;
        }else{
			avm.RelatedProperty__c=prop.Id;
		}
        //prop.Red_Bell_Loan_Number__c = aveResponse.ave.subject.loanNumber;
        avm.AVM_Provider__c = 'Red Bell';
        avm.recordtypeid = [SELECT Id FROM RecordType WHERE sobjecttype = 'Property_AVM__c' and DeveloperName  = 'Red_Bell_AVM'].Id;
        avm.AVM_Address__c = aveResponse.ave.subject.address;
        avm.AVM_City__c = aveResponse.ave.subject.city;
        avm.AVM_State__c = aveResponse.ave.subject.state;
        avm.AVM_ZIP__c = aveResponse.ave.subject.zip;
        avm.AVM_Beds__c = aveResponse.ave.subject.bed;
        avm.AVM_Baths__c = aveResponse.ave.subject.bath;
        avm.AVM_Square_Feet__c = aveResponse.ave.subject.sqft;
        avm.AVM_Year_Built__c =  String.valueOf(aveResponse.ave.subject.yearBuilt);
        avm.AVM_REO__c = '0';
        avm.AVM_APN__c = aveResponse.ave.subject.apn;
        avm.AVM_Calculated_Price__c = aveResponse.ave.subject.calculatedPrice;
        prop.Calc_AveValue__c = aveResponse.ave.subject.calculatedPrice;
        if (aveResponse.ave.subject.propertyType == 'Single Family') {
            avm.AVM_Property_Type__c = 'SFR';
        } else {
            avm.AVM_Property_Type__c = aveResponse.ave.subject.propertyType;
        }
        avm.AVM_Last_Sale_Price__c = aveResponse.ave.subject.soldPrice;
        prop.AVM_Last_Sale_Price__c = aveResponse.ave.subject.soldPrice;
        avm.AVM_Last_Sale_Date__c = aveResponse.ave.subject.soldDate != null ? aveResponse.ave.subject.soldDate.dateGMT() : null;
        prop.AVM_Last_Sale_Date__c = aveResponse.ave.subject.soldDate != null ? aveResponse.ave.subject.soldDate.dateGMT() : null;
        //prop.Red_Bell_Last_Inspection_Date__c = aveResponse.ave.subject.asOfDate != null ? aveResponse.ave.subject.asOfDate.dateGMT() : null;  //if added back, need to query
        if (aveResponse.ave.subject.isHOA != null) {
            avm.AVM_Is_HOA__c = aveResponse.ave.subject.isHOA ? 'Yes' : 'No';
        }

        System.debug('Comps size:');
        System.debug(aveResponse.ave.comps.size());

        for (Integer i = 0; i < aveResponse.ave.comps.size(); i++) {
            if (i == 0) {
                avm.AVM_C1_Address__c = aveResponse.ave.comps[i].address;
                avm.AVM_C1_City__c = aveResponse.ave.comps[i].city;
                avm.AVM_C1_State__c = aveResponse.ave.comps[i].state;
                avm.AVM_C1_Zip__c = aveResponse.ave.comps[i].zip;
                avm.AVM_C1_Image__c = aveResponse.ave.comps[i].image;
                avm.AVM_C1_Beds__c = aveResponse.ave.comps[i].bed;
                avm.AVM_C1_Baths__c = aveResponse.ave.comps[i].bath;
                avm.AVM_C1_Square_Feet__c = aveResponse.ave.comps[i].sqft;
                avm.AVM_C1_Garage__c = aveResponse.ave.comps[i].garage;
                avm.AVM_C1_Lot_Size__c = aveResponse.ave.comps[i].lotSize;
                avm.AVM_C1_Year_Built__c = aveResponse.ave.comps[i].yearBuilt;
                avm.AVM_C1_Units__c = aveResponse.ave.comps[i].units;
                avm.AVM_C1_Target_Distance__c = aveResponse.ave.comps[i].targetDistance;
                avm.AVM_C1_List_Price__c = aveResponse.ave.comps[i].listPrice;
                avm.AVM_C1_List_Date__c = aveResponse.ave.comps[i].listDate != null ? aveResponse.ave.comps[i].listDate.dateGMT() : null;
                avm.AVM_C1_Last_Sale_Price__c = aveResponse.ave.comps[i].soldPrice;
                avm.AVM_C1_Last_Sale_Date__c = aveResponse.ave.comps[i].soldDate != null ? aveResponse.ave.comps[i].soldDate.dateGMT() : null;
                avm.AVM_C1_Act_Dom__c = aveResponse.ave.comps[i].actDom;
                avm.AVM_C1_tot_Dom__c = aveResponse.ave.comps[i].totDom;
                avm.AVM_C1_Square_Foot_Price__c = aveResponse.ave.comps[i].sqftPrice;
                avm.AVM_C1_Percentage_Of_Valuation__c = aveResponse.ave.comps[i].percentOfValuation;
                avm.AVM_C1_included_In_Calculation__c = aveResponse.ave.comps[i].includedInCalculation;
                avm.AVM_C1_Comp_Type__c = aveResponse.ave.comps[i].compType;
                avm.AVM_C1_REO__c = '0';
            }
            else if (i == 1) {
                avm.AVM_C2_Address__c = aveResponse.ave.comps[i].address;
                avm.AVM_C2_City__c = aveResponse.ave.comps[i].city;
                avm.AVM_C2_State__c = aveResponse.ave.comps[i].state;
                avm.AVM_C2_ZIP__c = aveResponse.ave.comps[i].zip;
                avm.AVM_C2_Image__c = aveResponse.ave.comps[i].image;
                avm.AVM_C2_Beds__c = aveResponse.ave.comps[i].bed;
                avm.AVM_C2_Baths__c = aveResponse.ave.comps[i].bath;
                avm.AVM_C2_Square_Feet__c = aveResponse.ave.comps[i].sqft;
                avm.AVM_C2_Garage__c = aveResponse.ave.comps[i].garage;
                avm.AVM_C2_Lot_Size__c = aveResponse.ave.comps[i].lotSize;
                avm.AVM_C2_Year_Built__c = aveResponse.ave.comps[i].yearBuilt;
                avm.AVM_C1_Units__c = aveResponse.ave.comps[i].units;
                avm.AVM_C2_Target_Distance__c = aveResponse.ave.comps[i].targetDistance;
                avm.AVM_C2_list_Price__c = aveResponse.ave.comps[i].listPrice;
                avm.AVM_C2_List_Date__c = aveResponse.ave.comps[i].listDate != null ? aveResponse.ave.comps[i].listDate.dateGMT() : null;
                avm.AVM_C2_Last_Sale_Price__c = aveResponse.ave.comps[i].soldPrice;
                avm.AVM_C2_Last_Sale_Date__c = aveResponse.ave.comps[i].soldDate != null ? aveResponse.ave.comps[i].soldDate.dateGMT() : null;
                avm.AVM_C2_Act_Dom__c = aveResponse.ave.comps[i].actDom;
                avm.AVM_C2_Tot_Dom__c = aveResponse.ave.comps[i].totDom;
                avm.AVM_C2_Square_Foot_Price__c = aveResponse.ave.comps[i].sqftPrice;
                avm.AVM_C2_Percentage_Of_Valuation__c = aveResponse.ave.comps[i].percentOfValuation;
                avm.AVM_C2_Included_In_Calculation__c = aveResponse.ave.comps[i].includedInCalculation;
                avm.AVM_C2_Comp_Type__c = aveResponse.ave.comps[i].compType;
                avm.AVM_C2_REO__c = '0';
            }
            else if (i == 2) {
                avm.AVM_C3_Address__c = aveResponse.ave.comps[i].address;
                avm.AVM_C3_City__c = aveResponse.ave.comps[i].city;
                avm.AVM_C3_State__c = aveResponse.ave.comps[i].state;
                avm.AVM_C3_Zip__c = aveResponse.ave.comps[i].zip;
                avm.AVM_C3_Image__c = aveResponse.ave.comps[i].image;
                avm.AVM_C3_Beds__c = aveResponse.ave.comps[i].bed;
                avm.AVM_C3_Baths__c = aveResponse.ave.comps[i].bath;
                avm.AVM_C2_Square_Feet__c = aveResponse.ave.comps[i].sqft;
                avm.AVM_C3_Garage__c = aveResponse.ave.comps[i].garage;
                avm.AVM_C3_Lot_Size__c = aveResponse.ave.comps[i].lotSize;
                avm.AVM_C3_Year_Built__c = aveResponse.ave.comps[i].yearBuilt;
                avm.AVM_C3_Units__c = aveResponse.ave.comps[i].units;
                avm.AVM_C3_Target_Distance__c = aveResponse.ave.comps[i].targetDistance;
                avm.AVM_C3_List_Price__c = aveResponse.ave.comps[i].listPrice;
                avm.AVM_C3_List_Date__c = aveResponse.ave.comps[i].listDate != null ? aveResponse.ave.comps[i].listDate.dateGMT() : null;
                avm.AVM_C3_Last_Sale_Price__c = aveResponse.ave.comps[i].soldPrice;
                avm.AVM_C3_Last_Sale_Date__c = aveResponse.ave.comps[i].soldDate != null ? aveResponse.ave.comps[i].soldDate.dateGMT() : null;
                avm.AVM_C3_Act_Dom__c = aveResponse.ave.comps[i].actDom;
                avm.AVM_C3_Tot_Dom__c = aveResponse.ave.comps[i].totDom;
                avm.AVM_C3_Square_Foot_Price__c = aveResponse.ave.comps[i].sqftPrice;
                avm.AVM_C3_Percentage_Of_Valuation__c = aveResponse.ave.comps[i].percentOfValuation;
                avm.AVM_C3_Included_In_Calculation__c = aveResponse.ave.comps[i].includedInCalculation;
                avm.AVM_C3_Comp_Type__c = aveResponse.ave.comps[i].compType;
                avm.AVM_C3_REO__c = '0';
            }
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

    //
    //  Long rightNow = system.now().getTime();
    //
    //  if (String.isBlank(oauthToken) ||  String.isBlank(oauthTokenSecret)) {
    //      System.debug('oauth tokens null');
    //      return null;
    //  }
    //
    //  HttpResponse res = new HttpResponse();
    //  Map<String,String> parameters = new Map<String,String>();
    //  parameters.put('oauth_token', oauthToken);
    //  parameters.put('oauth_nonce',String.valueOf(Crypto.getRandomLong()));
    //  parameters.put('oauth_consumer_key',OAUTH_CONSUMER_KEY);
    //  parameters.put('oauth_signature_method','RSA-SHA1');
    //  parameters.put('oauth_timestamp',string.valueOf(DateTime.now().getTime()).substring(0,10));
    //  parameters.put('oauth_version','1.0');
    //  PageReference reqURL = new PageReference(endpoint);
    //
    //  HttpRequest req = new httpRequest();
    //  req.setMethod(method);
    //  endpoint = endpoint.replace('(','%28');
    //  endpoint = endpoint.replace(')','%29');
    //  endpoint = endpoint.replace(',','%2C');
    //
    //  req.setEndpoint(endpoint);
    //  req.setHeader('Accept','application/json');
    //  req.setTimeout(120000);
    //  if ( String.isNotBlank(body) ){
    //          req.setHeader('Content-Type','application/json');
    //          req.setHeader('Content-Length',string.valueOf(body.length()));
    //          req.setBody(body);
    //  }
    //  system.debug(req.getBody());
    //  String signature = generateSignature(req, parameters);
    //
    //  req.setHeader('Authorization',generateHeader(signature, parameters));
    //  system.debug(req.getEndpoint());
    //  system.debug(req.getHeader('Authorization'));
    //
    //  res = new http().send(req);
    //  system.debug(res.getStatusCode()+' : '+res.getStatus());
    //  system.debug('abc');
    //  system.debug(res.getBody());
    //  return res.getBody();
    // }
    //
    // public static String getAccessToken() {
    //  'https://beta.redbellre.com/orders/api/token'
    //
    // }
 }