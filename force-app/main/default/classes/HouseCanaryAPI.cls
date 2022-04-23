public class HouseCanaryAPI {
public static HouseCanary__c HouseCanarySettings = HouseCanary__c.getInstance();
    static String USERNAME = HouseCanarySettings.APIKey__c;
    static String PASSWORD = HouseCanarySettings.APISecret__c;
    static String BASE_URL = HouseCanarySettings.Endpoint__c;
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
											AVM_C3_List_Price__c, AVM_C3_Lot_Size__c, AVM_C3_Percentage_Of_Valuation__c, AVM_C3_Square_Feet__c,AVM_C3_Square_Foot_Price__c, AVM_C3_State__c, AVM_C3_Target_Distance__c, AVM_C3_Tot_Dom__c, AVM_C3_Units__c, AVM_C3_Year_Built__c, AVM_C3_Zip__c, AVM_C3_REO__c,
											AVM_number_of_comps__c,AVM_estimated_value__c                                           
											from Property_AVMs__r WHERE recordtypeid IN (SELECT Id FROM RecordType WHERE sobjecttype = 'Property_AVM__c' 
                                                                                        and DeveloperName  = 'HouseCanary_Rental_AVM') order by CreatedDate desc)
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
        AveDataValue ave;
        Integer status;
        String message;
    }

    public class AveDataValue {
        checks	checks;
        input_params input_params;
        String recommended_approach;
        hc_avm_value_analysis hc_avm_value_analysis;
        AveSubjectData subject;
        List<AveCompData> comps;
    }	

	public class checks {
        Boolean All_pre_analysis_checks_passed;
        Boolean Address_is_supported;
        Boolean Address_is_complete;
        Boolean Precise_geocode_is_available_for_address;
        Boolean Property_at_address_is_of_supported_type;
        Boolean Census_block_group_information_is_available;
        Boolean Enough_information_on_neighborhood_characteristics_is_available;
        Boolean Gross_living_area_of_property_is_available_or_provided_as_input;
        Boolean Comps_available_for_analysis;
    }   
	public class input_params {
        Boolean include_comp_based_analysis;
        String street_address;
        String zipcode;
        String product_type;
    }    

	public class hc_avm_value_analysis {
        String avm_value;
        String avm_confidence;
        Double avm_fsd;
	    neighborhood_analysis neighborhood_analysis;
		comp_based_analysis comp_based_analysis;
	}
    
	public class neighborhood_analysis {
            integer avm_value_sqft;
            double fifth_percentile_value_per_sqft;
            double ninthfifth_percentile_value_per_sqft;
            Boolean within_neighborhood_norms;
        }
    
	public class comp_based_analysis {
            double comp_fsd;
            Integer number_of_comps;
            Integer fifth_percentile_adjusted_comp_value;
            Integer ninthFifth_percentile_adjusted_comp_value;
            Double avm_value_percentile_in_adjusted_comp_values;
            Boolean within_adjusted_comp_values;
        }

//Input parameters for the call    
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
        String apn;
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
    public static Map<String, Object> callHouseCanary(List<Property__c> properties, Id recordId) {
        System.debug(properties);
        AveResponse aveResponse;
		System.Debug('RS999 callHouseCanary');
       // getAccessToken();
        for (Property__c prop : properties) {
            getAveData(prop);
        }
        System.debug(998);
       // update properties;
        System.debug(999);
        return getProperties(recordId);
    }

    @auraEnabled
    public static Map<String, Object> callHouseCanarySingle(Property__c property, Id recordId) {
        System.debug(property);
        System.Debug('RS999 callHouseCanarySingle');
        AveResponse aveResponse;

       // getAccessToken();
        // for (Property__c prop : properties) {
        getAveData(property);
        //}
        System.debug(998);
      //  update property;
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
        parameters.put('username', USERNAME);
        parameters.put('password', PASSWORD);

        body = getBodyString(parameters);
        headers = new Map<String, String>();
        headers.put('hc_api_key','ZMYYQSD732KYF6PNP0HF' );
        headers.put('hc_api_secret', 'UztQDJ9csLks6FJMplKWP4zI21l2issy');

        //endpoint = BASE_URL + '/upload/ave';
        endpoint = 'https://api.housecanary.com/v2/property/value_analysis/check';
        String parameter;
       // if (prop.Name != null)
       // {
        // String address = prop.Name ;
         parameter = '?street_address='+ EncodingUtil.urlEncode('4123 Main St', 'UTF-8');
         parameter = parameter  + 'zipcode=' + EncodingUtil.urlEncode('94132', 'UTF-8');
       // }
		endpoint = endpoint + parameter;
        method = 'GET';
        System.debug('body:');
        System.debug(body);
        System.debug(endpoint);

        rawJSON = callOut(method, endpoint, body, headers);

        System.debug(444);
        System.debug(rawJSON);
/*
        TokenResponse = (TokenResponse)JSON.deserialize(rawJSON, TokenResponse.class);

        if (TokenResponse.error != null && TokenResponse.error_description != null) {
            throwError(TokenResponse.error_description);
        }
        else if (TokenResponse.error != null) {
            throwError(TokenResponse.error);
        }
        else {
            ACCESS_TOKEN = TokenResponse.access_token;
        }*/
    }

    public static void getAveData(Property__c prop) {
        Map<String, String> parameters;
        Map<String, String> headers;
        String endpoint;
        String method;
        String body;
        String rawJSON;
        AveResponse aveResponse;

       // parameters = new Map<String, String>{'Address'=>prop.Name, 'City'=>prop.City__c, 'State'=>prop.State__c, 'Zip'=>prop.ZipCode__c, 'MonthsBack'=>'six'};
       // parameters = new Map<String, String>{'street_address'=>prop.Name, 'Zip'=>prop.ZipCode__c,'include_comp_based_analysis'=>'True'};
       // body = JSON.serialize(parameters);
       // System.debug(body);

        headers = new Map<String, String>();
       // headers.put('Username','ZMYYQSD732KYF6PNP0HF' );
       // headers.put('Password', 'UztQDJ9csLks6FJMplKWP4zI21l2issy');
       headers.put('Authorization: Basic', 'Wk1ZWVFTRDczMktZRjZQTlAwSEY6VXp0UURKOWNzTGtzNkZKTXBsS1dQNHpJMjFsMmlzc3k=');

        //endpoint = BASE_URL + '/upload/ave';
         Blob headerValue = Blob.valueOf('ZMYYQSD732KYF6PNP0HF' + ':' + 'UztQDJ9csLks6FJMplKWP4zI21l2issy');
    
         String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
         
         headers.put('Authorization', authorizationHeader);        
       
        endpoint = 'https://api.housecanary.com/v2/property/value_analysis/check';
        String parameter;
        if (prop.Name != null)
        {
         String address = prop.Name ;
         parameter = '?street_address='+ EncodingUtil.urlEncode('4123 Main St', 'UTF-8');
         parameter = parameter  + '&zipcode=' + EncodingUtil.urlEncode('94132', 'UTF-8');
        }
		endpoint = endpoint + parameter;
        method = 'GET';

        rawJSON = callOut(method, endpoint, body, headers);
        System.debug('RS999 rawJSON :' +rawJSON);
       /* aveResponse = (AveResponse)JSON.deserialize(rawJSON, AveResponse.class);
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
        }*/
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
        prop.Invalid_Address__c = False;

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
        avm.AVM_Provider__c = 'Red Bell';
        avm.AVM_Address__c = aveResponse.ave.subject.address;
        avm.AVM_City__c = aveResponse.ave.subject.city;
        avm.AVM_State__c = aveResponse.ave.subject.state;
        avm.AVM_ZIP__c = aveResponse.ave.subject.zip;
        avm.AVM_Beds__c = aveResponse.ave.subject.bed;
        avm.AVM_Baths__c = aveResponse.ave.subject.bath;
        avm.AVM_Square_Feet__c = aveResponse.ave.subject.sqft;
        avm.AVM_Year_Built__c = aveResponse.ave.subject.yearBuilt;
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
    	request.setMethod('GET');
      //  request.setEndpoint(endpoint);
  	//		Parameters = '?street_address=4123 Main St&zipcode=94132&estimated_value=1050000&include_comp_based_analysis=true'
  		//String parameter = '/value_analysis/check';
  		//parameter = parameter  + '?street_address='+ EncodingUtil.urlEncode('6822 Clemson ln', 'UTF-8');
        //parameter = parameter  + '&zipcode=' + EncodingUtil.urlEncode('77479', 'UTF-8');
  		//String parameter = '/rental_value_forecast';
  		String parameter = '/details';
  		parameter = parameter  + '?address='+ EncodingUtil.urlEncode('6822 Clemson ln', 'UTF-8');
        parameter = parameter  + '&zipcode=' + EncodingUtil.urlEncode('77479', 'UTF-8');
        request.setEndpoint('callout:HouseCanary'+parameter);
       // if (headers != null) {
      //     for (String key : headers.keySet()) {
       //        system.Debug('RS999 Header key :' +key);
      //         system.Debug('RS999 headers.get(key) :' +headers.get(key));
      //          request.setHeader(key, headers.get(key));
       //     }
     //   }
        
       // if (body != null) {
       //     request.setBody(body);
       // }

		//System.Debug('RS999 request Header ' +request.getHeader('Authorization'));      
        response = new Http().send(request);
        System.Debug('RS999 response :' +response);
        
        return response.getBody();
    }

  }