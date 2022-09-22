public class HouseCanaryAPI {
    static String ACCESS_TOKEN;
    static Boolean RETRIED_AUTH = False;
    //Data Object        
    public static HouseCanaryResponseModel.Property_value_analysis_check vaDataObjectsResultsFinal;
    public static HouseCanaryResponseModel.Property_RentalValue rvDataObjectsResultsFinal;
    public static HouseCanaryResponseModel.Property_Rental_Value_Forecast rfDataObjectsResultsFinal;
    public static HouseCanaryResponseModel.propert_details pdDataObjectsResultsFinal;
    public static HouseCanaryResponseModel.property_sales_history shDataObjectsResultsFinal;
    public static HouseCanaryResponseModel.property_mortgage_lien_all mlaDataObjectsResultsFinal;
    public static HouseCanaryResponseModel.property_flood fldDataObjectsResultsFinal;
    public static HouseCanaryResponseModel.property_tax_history thDataObjectsResultsFinal;
    public static HouseCanaryResponseModel.property_block_crime bcDataObjectsResultsFinal;
    public static HouseCanaryResponseModel.Property_ValueReport vrDataObjectsResultsFinal;
    Public static Boolean validCall = False;
    Public static boolean valueReportOnly = False;
    Public static string errorFromHouseCanary;
	public static List<Integer> responseCodes  = new List<Integer>();
    public static List<String>  responseString = new List<String>();
    public static List<Property_AVM__c> propertiesAVM = new List<Property_AVM__c>();
    
   @auraEnabled
    public static Map<String, Object> getProperties(Id recordId) {
        Map<String, Object> response = new Map<String, Object>();
        
        List<Property__c> properties = [SELECT Id, Name, City__c, State__c, ZipCode__c, Status__c, Number_of_Beds__c, Number_of_Bath__c, Square_Feet__c, 
                                        Year_Built__c, APN__c, Borrower_Opinion_of_Current_Value__c, Property_Type__c, Invalid_Address__c, 
                                        Calc_AveValue__c,no_of_stories__c, Is_HOA__c,Monthly_Rent__c,
											(Select AVM_Address__c,HouseCanary_Sync_Allowed__c,Estimated_Rent__c,no_of_stories__c,value_report_static_Link__c,apn__c, 
                                             Tax_History_Tax_Year__c, Tax_History_Tax_Amount__c, Sale_History_Data_Present__c, Mortgage_Lien_Data_Present__c,
                                             Block_Crime_Data_Present__c, Tax_History_Data_Present__c, AVM_Square_Feet__c,assessment_year__c,AVM_Year_Built__c,
                                             AVM_Last_Sale_Date__c,AVM_Last_Sale_Price__c,property_type__c,AVM_Calculated_Price__c,number_of_bedrooms__c,AVM_Baths__c,total_bath_count__c
                                             from Property_AVMs__r WHERE recordtypeid IN (SELECT Id FROM RecordType WHERE sobjecttype = 'Property_AVM__c' 
                                                                                        and DeveloperName  = 'HouseCanary_Rental_AVM') order by CreatedDate desc Limit 1)
                                        FROM Property__c WHERE Property__c.Deal__c = :recordId 
                                        AND Deal__r.StageName IN ('Data Tape Received' , 'Term Sheet Issued' , 'Term Sheet Signed/Deposit Collected' 
                                                                  ,'Submitted to Underwriting', 'Loan Processing', 'Processing Hold' , 'Underwriting' , 'UW Hold' , 'Approved by Committee', 'Closed Won')  
                                        AND Status__c NOT IN ('Inactive','Cancelled','Rescinded')
                                        AND Property__c.ZipCode__c != null
                                        AND (Property__c.Property_Type__c = null OR Property__c.Property_Type__c = 'SFR' OR Property__c.Property_Type__c = 'Condo' OR Property__c.Property_Type__c = 'Townhome' OR (Property__c.Property_Type__c = '2-4 Unit' AND Property__c.Is_Sub_Unit__c = false))
                                        ORDER BY Property_Name__c];
		System.Debug('properties :' +properties)        ;

        response.put('properties', properties);
        return response;
    }

        public static List<Property_AVM__c> getPropertiesAVM(Id recordId) {
        List<Property_AVM__c> propertiesAVM = [Select id,HouseCanary_Sync_Allowed__c,RelatedProperty__c from Property_AVM__c where RelatedProperty__c = :recordId and recordtypeid IN (SELECT Id FROM RecordType WHERE sobjecttype = 'Property_AVM__c' 
                                                                                        and DeveloperName  = 'HouseCanary_Rental_AVM') order by CreatedDate desc Limit 1];
        return propertiesAVM;
    }    
    
    public static void throwError(String errorMsg) {
        AuraHandledException ex = new AuraHandledException(errorMsg);
        ex.setMessage(errorMsg);
        throw ex;
    }

  /*  @auraEnabled
    public static Map<String, Object> callHouseCanary(List<Property__c> properties, Id recordId) {
        for (Property__c prop : properties) {
            getHouseCanaryData(prop);
        }
       // update properties;
        return getProperties(recordId);
    }*/
    @auraEnabled
    public static Map<String, Object> callHouseCanarySingle(Property__c property, Id recordId, boolean valueReport) {
        valueReportOnly = valueReport;

        getHouseCanaryData(property);
		if (!validCall) 
        {
            errorFromHouseCanary ='';
            For(integer i=0;i<responseString.size();i++)
            {
            errorFromHouseCanary = responseString[i] + '\n' + errorFromHouseCanary;  
            }
            throwError(errorFromHouseCanary);            
        }
        return getProperties(recordId);
    }
////////////////////////// 
    public static void getHouseCanaryData(Property__c prop) 
    {
		propertiesAVM = getPropertiesAVM(prop.id);

        if (propertiesAVM.size() > 0 && propertiesAVM[0].HouseCanary_Sync_Allowed__c == 'No' )
        {
        	errorFromHouseCanary =' HouseCanary Sync for ths property is not allowed at this time as not enough time has pssed since the previous call';
            throwError(errorFromHouseCanary);
        }
        
        List<Property__c> property = new List<Property__c>();
        if (valueReportOnly)
        {
            if (!(propertiesAVM.size() > 0))
            {
              errorFromHouseCanary = ' Please Run Value analysis Sync before Value Report-Static Link';  
			  throwError(errorFromHouseCanary);                
            }
            Else
            {
                get_Value_Report_Data(prop); 
      
                if (validCall)
                {  
                property.add(prop);
                insertPropertyAVM(property);
                }
            }
        }
        Else
        {
  			get_Value_Analysis_Data(prop); 
        	get_Property_Details_Data(prop);
            if (validCall)
            {        
                get_Rental_Value_Data(prop);         
                //get_Rental_Value_Forecast_Data(prop); 
                get_Sales_History_Data(prop);
                get_Mortgage_Lien_All_Data(prop);
                get_Flood_Data(prop);
                get_Block_Crime_Data(prop);
                get_Tax_History_Data(prop);        
                property.add(prop);
                insertPropertyAVM(property);
            }
        }
    }
    
////////////////////////// 
    public static void get_Value_Analysis_Data(Property__c prop)
    {
        String endpoint;
        String method;
		String parameter;
        String rawJSON;        
    
        endpoint = '/value_analysis/check';

        if (prop.Name != null)
        {
            String address = prop.Name ;
            parameter = '?street_address='+ EncodingUtil.urlEncode(prop.Name, 'UTF-8');
            parameter = parameter  + '&zipcode=' + EncodingUtil.urlEncode(prop.ZipCode__c, 'UTF-8');
            parameter = parameter  + '&include_comp_based_analysis=true';
            endpoint = endpoint + parameter;
            method = 'GET';
            if (test.isRunningTest())
            {
            rawJSON = '{"checks": {"All pre-analysis checks passed": true, "Address is supported": true, "Address is complete": true, "Precise geocode is available for address": true, "Property at address is of supported type": true, "Census block group information is available": true, "Enough information on neighborhood characteristics is available": true, "Gross living area of property is available or provided as input": true, "Comps available for analysis": false}, "input_params": {"street_address": "103 Forest Point Dr", "zipcode": "39047", "include_comp_based_analysis": "true", "product_type": "value_analysis"}, "recommended_approach": "Minor exceptions - Human review", "hc_avm_value_analysis": {"avm_value": 250834, "avm_confidence": "high", "avm_fsd": 0.12, "neighborhood_analysis": {"avm_value_sqft": 118, "5th_percentile_value_per_sqft": 107.1, "95th_percentile_value_per_sqft": 188.6, "within_neighborhood_norms": true}}}';            
            }
            Else
            {
            rawJSON = callOut(method, endpoint);            
            }

            if (rawJSON.Substring(0,5) != 'Error')
            {  
                vaDataObjectsResultsFinal = (HouseCanaryResponseModel.Property_value_analysis_check)JSON.deserialize(rawJSON, HouseCanaryResponseModel.Property_value_analysis_check.class);  //Data Object
                 if (vaDataObjectsResultsFinal.recommended_approach == 'Major exceptions - Onsite review' )
                  //   || vaDataObjectsResultsFinal.recommended_approach == 'Minor exceptions - Human review')
                 {
                    responseCodes.add(99);
                    //CIP-2604 responseString.add('value_analysis/check : ' + 'Return Code : 99 ' + vaDataObjectsResultsFinal.recommended_approach);
                    responseString.add('value_analysis/check : ' + 'Return Code : 99 ' + PricingReviewRequest_LightningController.GetMessage(7));

                 }
                Else
                {
                responseCodes.add(0);
                responseString.add('');
                validCall = True;
                }                
            }
            Else
            {
                responseCodes.add(99);
               //CIP-2604 responseString.add('value_analysis/check : ' + 'Return Code : 99 ' +  rawJSON);
               responseString.add('value_analysis/check : ' + 'Return Code : 99 ' + PricingReviewRequest_LightningController.GetMessage(7));
            }
       } //(prop.Name != null)
    }
//////////////////////////    
    public static void get_Property_Details_Data(Property__c prop)
    {
        String endpoint;
        String method;
		String parameter;
        String rawJSON;

 		endpoint = '/details';
        
        
        if (prop.Name != null)
        {
         String address = prop.Name ;
         parameter = '?address='+ EncodingUtil.urlEncode(prop.Name, 'UTF-8');
         parameter = parameter  + '&zipcode=' + EncodingUtil.urlEncode(prop.ZipCode__c, 'UTF-8');
        }
		endpoint = endpoint + parameter;
        method = 'GET';
        if (test.isRunningTest())
        {
        rawJSON = '[{"property/details":{"api_code_description":"ok","api_code":0,"result":{"property":{"no_of_buildings":null,"attic":null,"total_bath_count":1.5,"full_bath_count":1,"partial_bath_count":1,"total_number_of_rooms":9,"heating":"forced_air_unit","heating_fuel_type":null,"style":null,"garage_parking_of_cars":null,"site_area_acres":0.0,"number_of_units":null,"building_area_sq_ft":2125,"garage_type_parking":null,"basement":null,"air_conditioning":"yes","fireplace":true,"pool":null,"no_of_stories":1,"water":null,"year_built":1972,"exterior_walls":"wood","number_of_bedrooms":4,"sewer":null,"property_type":"Single Family Residential","subdivision":"FOREST POINT SD","building_quality_score":3,"building_condition_score":3,"construction_type":null,"roof_cover":"Shingle (Not Wood)","roof_type":"Gambrel","zoning":null},"assessment":{"apn":"H12B000013 01630","assessment_year":2021,"tax_amount":1816.65,"total_assessed_value":17106.0,"tax_year":2021}}},"address_info":{"city":"Brandon","county_fips":"28121","geo_precision":"rooftop","zipcode":"39047","address_full":"103 Forest Point Dr Brandon MS 39047","slug":"103-Forest-Point-Dr-Brandon-MS-39047","block_id":"281210202094016","blockgroup_id":"281210202094","state":"MS","zipcode_plus4":"6207","address":"103 Forest Point Dr","lat":32.3754997,"lng":-90.021965,"unit":null,"msa":"27140","metrodiv":null,"status":{"match":true,"details":["Address fully verified"],"errors":[],"changes":["Locality (city, municipality) added or changed","State added or changed"],"requested_item":{"zipcode":"39047","address_id":83910163,"address":"103 Forest Point Dr"}}}}]';            
        }
        Else
        {
        rawJSON = callOut(method, endpoint);            
        }
        if (rawJSON.Substring(0,5) != 'Error')
        {        
        if (rawJSON.substring(0, 1) == '[')    rawJSON = rawJSON.substring(1, rawJSON.length()-1); //get the json from the list.

		Map<String, Object> propert_details =(Map<String, Object>)JSON.deserializeUntyped(rawJSON);
        Map<String, Object> pdMapObjects = (Map<String, Object>) propert_details?.get('property/details');
		pdDataObjectsResultsFinal = new HouseCanaryResponseModel.propert_details(); //Data Object            
        pdDataObjectsResultsFinal.api_code_description = (string) pdMapObjects?.get('api_code_description');
        pdDataObjectsResultsFinal.api_code = (Integer) pdMapObjects?.get('api_code');
        if (pdDataObjectsResultsFinal.api_code == 0)
        {
      /*  Map<String, Object> pdMapObjectsAddress = (Map<String, Object>) pdMapObjects?.get('address_info'); 
        System.Debug('pdMapObjectsAddress :' +pdMapObjectsAddress);
		pdDataObjectsResultsFinal.Address_Info.Address  = (string) pdMapObjectsAddress?.get('address');
		pdDataObjectsResultsFinal.Address_Info.Zipcode	= (string) pdMapObjectsAddress?.get('zipcode');
		pdDataObjectsResultsFinal.Address_Info.State	= (string) pdMapObjectsAddress?.get('state');
		pdDataObjectsResultsFinal.Address_Info.City		= (string) pdMapObjectsAddress?.get('city');    */        
            
        Map<String, Object> pdMapObjectsResults = (Map<String, Object>) pdMapObjects?.get('result');
		Map<String, Object> pdMapObjectsResultsfields = (Map<String, Object>) pdMapObjectsResults?.get('assessment');  
        pdDataObjectsResultsFinal.Result_Detail.assessment.apn =  (string) pdMapObjectsResultsfields?.get('apn');
        pdDataObjectsResultsFinal.Result_Detail.assessment.assessment_year =  (String) String.valueOf(pdMapObjectsResultsfields?.get('assessment_year'));
		pdDataObjectsResultsFinal.Result_Detail.assessment.tax_amount =  (Double) pdMapObjectsResultsfields?.get('tax_amount');                                                                                                      
		pdDataObjectsResultsFinal.Result_Detail.assessment.total_assessed_value =  (Double) pdMapObjectsResultsfields?.get('total_assessed_value');
		pdDataObjectsResultsFinal.Result_Detail.assessment.tax_year =  (String) String.valueOf(pdMapObjectsResultsfields?.get('tax_year')); 
            
		pdMapObjectsResultsfields = (Map<String, Object>) pdMapObjectsResults.get('property'); 
		pdDataObjectsResultsFinal.Result_Detail.propert_detail.no_of_buildings 			= (Integer) pdMapObjectsResultsfields?.get('no_of_buildings');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.attic 					= (boolean) pdMapObjectsResultsfields?.get('attic');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.total_bath_count 		= (Double) pdMapObjectsResultsfields?.get('total_bath_count');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.full_bath_count 			= (Integer) pdMapObjectsResultsfields?.get('full_bath_count');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.partial_bath_count 		= (Double) pdMapObjectsResultsfields?.get('partial_bath_count');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.total_number_of_rooms 	= (Integer) pdMapObjectsResultsfields?.get('total_number_of_rooms');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.heating 					= (String) pdMapObjectsResultsfields?.get('heating');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.heating_fuel_type 		= (String) pdMapObjectsResultsfields?.get('heating_fuel_type');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.style 					= (String) pdMapObjectsResultsfields?.get('style');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.garage_parking_of_cars 	= (Integer) pdMapObjectsResultsfields?.get('garage_parking_of_cars');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.site_area_acres 			= (Double) pdMapObjectsResultsfields?.get('site_area_acres');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.number_of_units 			= (Integer) pdMapObjectsResultsfields?.get('number_of_units');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.building_area_sq_ft 		= (Integer) pdMapObjectsResultsfields?.get('building_area_sq_ft');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.garage_type_parking 		= (String) pdMapObjectsResultsfields?.get('garage_type_parking');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.basement 				= (String) pdMapObjectsResultsfields?.get('basement');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.air_conditioning 		= (String) pdMapObjectsResultsfields?.get('air_conditioning');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.fireplace 				= (boolean) pdMapObjectsResultsfields?.get('fireplace');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.pool 					= (boolean) pdMapObjectsResultsfields?.get('pool');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.no_of_stories 			= (Integer) pdMapObjectsResultsfields?.get('no_of_stories');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.water 					= (String) pdMapObjectsResultsfields?.get('water');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.year_built 				= (Integer) pdMapObjectsResultsfields?.get('year_built');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.exterior_walls 			= (String) pdMapObjectsResultsfields?.get('exterior_walls');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.number_of_bedrooms 		= (Integer) pdMapObjectsResultsfields?.get('number_of_bedrooms');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.sewer 					= (String) pdMapObjectsResultsfields?.get('sewer');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.property_type 			= (String) pdMapObjectsResultsfields?.get('property_type');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.subdivision 				= (String) pdMapObjectsResultsfields?.get('subdivision');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.building_quality_score 	= (Integer) pdMapObjectsResultsfields?.get('building_quality_score');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.building_condition_score = (Integer) pdMapObjectsResultsfields?.get('building_condition_score');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.construction_type 		= (String) pdMapObjectsResultsfields?.get('construction_type');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.roof_cover 				= (String) pdMapObjectsResultsfields?.get('roof_cover');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.roof_type 				= (String) pdMapObjectsResultsfields?.get('roof_type');
        pdDataObjectsResultsFinal.Result_Detail.propert_detail.zoning 					= (String) pdMapObjectsResultsfields?.get('zoning');           
 
        responseCodes.add(0);
        responseString.add('');
        validCall = True;
        }
        else
        {
            responseCodes.add(pdDataObjectsResultsFinal?.api_code);
           //CIP-2604 responseString.add('\n'+'Property Details : ' + 'Return Code : ' + pdDataObjectsResultsFinal?.api_code + ' ' + pdDataObjectsResultsFinal?.api_code_description);
            responseString.add('\n'+'Property Details : ' + 'Return Code : ' + pdDataObjectsResultsFinal?.api_code + ' ' + PricingReviewRequest_LightningController.GetMessage(7));

        }                
        }           
    }
    
//////////////////////////    
    public static void get_Rental_Value_Data(Property__c prop)
    {
    String endpoint;
        String method;
		String parameter;
        String rawJSON;
    
 		endpoint = '/rental_value';
        if (prop.Name != null)
        {
         String address = prop.Name ;
         parameter = '?address='+ EncodingUtil.urlEncode(prop.Name, 'UTF-8');
         parameter = parameter  + '&zipcode=' + EncodingUtil.urlEncode(prop.ZipCode__c, 'UTF-8');
        }
		endpoint = endpoint + parameter;
        method = 'GET';
        if (test.isRunningTest())
        {
        rawJSON = '[{"property/rental_value":{"api_code_description":"ok","api_code":0,"result":{"price_upr":2615,"price_lwr":1763,"price_mean":2189,"fsd":0.1946094}},"address_info":{"city":"Brandon","county_fips":"28121","geo_precision":"rooftop","zipcode":"39047","address_full":"103 Forest Point Dr Brandon MS 39047","slug":"103-Forest-Point-Dr-Brandon-MS-39047","block_id":"281210202094016","blockgroup_id":"281210202094","state":"MS","zipcode_plus4":"6207","address":"103 Forest Point Dr","lat":32.3754997,"lng":-90.021965,"unit":null,"msa":"27140","metrodiv":null,"status":{"match":true,"details":["Address fully verified"],"errors":[],"changes":["State added or changed","Locality (city, municipality) added or changed"],"requested_item":{"zipcode":"39047","address":"103 Forest Point Dr","address_id":83910163}}}}]';            
        }
        Else
        {
        rawJSON = callOut(method, endpoint);            
        }
        if (rawJSON.Substring(0,5) != 'Error')
        {        
        if (rawJSON.substring(0, 1) == '[')    rawJSON = rawJSON.substring(1, rawJSON.length()-1); //get the json from the list.

		Map<String, Object> property_Rental_Value =(Map<String, Object>)JSON.deserializeUntyped(rawJSON);
        Map<String, Object> rvMapObjects = (Map<String, Object>) property_Rental_Value?.get('property/rental_value');
		rvDataObjectsResultsFinal = new HouseCanaryResponseModel.Property_RentalValue(); //Data Object
        rvDataObjectsResultsFinal.api_code_description = (string) rvMapObjects?.get('api_code_description');
        rvDataObjectsResultsFinal.api_code = (Integer) rvMapObjects?.get('api_code');
        if (rvDataObjectsResultsFinal.api_code == 0)
        {
            Map<String, Object> rvMapObjectsResults = (Map<String, Object>) rvMapObjects?.get('result');
            rvDataObjectsResultsFinal.Result_RetalValue.price_upr = (integer) rvMapObjectsResults?.get('price_upr');        
            rvDataObjectsResultsFinal.Result_RetalValue.price_lwr = (integer) rvMapObjectsResults?.get('price_lwr');
            rvDataObjectsResultsFinal.Result_RetalValue.price_mean = (integer) rvMapObjectsResults?.get('price_mean');
            rvDataObjectsResultsFinal.Result_RetalValue.fsd = (Double) rvMapObjectsResults?.get('fsd');
            
            responseCodes.add(0);
            responseString.add('');
            validCall = True;
        }
        else
        {
            responseCodes.add(rvDataObjectsResultsFinal.api_code);
            responseString.add('\n' +  'rental_value : ' + 'Return Code : ' + rvDataObjectsResultsFinal.api_code  + ' ' + rvDataObjectsResultsFinal.api_code_description);
        }
        }             
    }
    
//////////////////////////    
   /* public static void get_Rental_Value_Forecast_Data(Property__c prop)
    {
        String endpoint;
        String method;
		String parameter;
        String rawJSON;        

 		endpoint = '/rental_value_forecast';
        if (prop.Name != null)
        {
         String address = prop.Name ;
         parameter = '?address='+ EncodingUtil.urlEncode(prop.Name, 'UTF-8');
         parameter = parameter  + '&zipcode=' + EncodingUtil.urlEncode(prop.ZipCode__c, 'UTF-8');
        }
		endpoint = endpoint + parameter;
        method = 'GET';
        if (test.isRunningTest())
        {
        rawJSON = '';            
        }
        Else
        {
        rawJSON = callOut(method, endpoint);            
        }
        if (rawJSON.Substring(0,5) != 'Error')
        {        
        if (rawJSON.substring(0, 1) == '[')    rawJSON = rawJSON.substring(1, rawJSON.length()-1); //get the json from the list.

		Map<String, Object> property_Rental_Value_Forecast =(Map<String, Object>)JSON.deserializeUntyped(rawJSON);
        Map<String, Object> rfMapObjects = (Map<String, Object>) property_Rental_Value_Forecast?.get('property/rental_value_forecast');
		rfDataObjectsResultsFinal = new HouseCanaryResponseModel.Property_Rental_Value_Forecast(); //Data Object
        rfDataObjectsResultsFinal.api_code_description = (string) rfMapObjects?.get('api_code_description');
        rfDataObjectsResultsFinal.api_code = (Integer) rfMapObjects.get('api_code');
        if (rfDataObjectsResultsFinal.api_code == 0)
        {
        Map<String, Object> rfMapObjectsResults = (Map<String, Object>) rfMapObjects?.get('result');
        Map<String, Object> rfMapObjectsResultfields = (Map<String, Object>) rfMapObjectsResults?.get('month_03');
		rfDataObjectsResultsFinal.Result_Retal_Value.month_03.value = (integer) rfMapObjectsResultfields?.get('value');        
        rfMapObjectsResultfields = (Map<String, Object>) rfMapObjectsResults?.get('month_06');
		rfDataObjectsResultsFinal.Result_Retal_Value.month_06.value = (integer) rfMapObjectsResultfields?.get('value');        
        rfMapObjectsResultfields = (Map<String, Object>) rfMapObjectsResults?.get('month_12');
		rfDataObjectsResultsFinal.Result_Retal_Value.month_12.value = (integer) rfMapObjectsResultfields?.get('value');
        responseCodes.add(0);
        responseString.add(''); 
		validCall = True;            
        }
        else
        {
            responseCodes.add(rfDataObjectsResultsFinal.api_code);
            responseString.add('\n' + 'rental_value_forecast : ' + 'Return Code : ' + rfDataObjectsResultsFinal.api_code + ' ' + rfDataObjectsResultsFinal.api_code_description);
        }            
        }        
    }*/

//////////////////////////    
    public static void get_Sales_History_Data(Property__c prop)
    {
        String endpoint;
        String method;
		String parameter;
        String rawJSON;
        

 		endpoint = '/sales_history';
        if (prop.Name != null)
        {
         String address = prop.Name ;
         parameter = '?address='+ EncodingUtil.urlEncode(prop.Name, 'UTF-8');
         parameter = parameter  + '&zipcode=' + EncodingUtil.urlEncode(prop.ZipCode__c, 'UTF-8');
         parameter = parameter  + '&order=desc';
        }
		endpoint = endpoint + parameter;
        method = 'GET';
        if (test.isRunningTest())
        {
        rawJSON = '[{"property/sales_history":{"api_code_description":"ok","api_code":0,"result":[{"event_type":"arms_length_sale","grantee_1":"BRICKS&TIMBER RESIDENTIAL","grantee_1_forenames":null,"grantee_2":null,"grantee_2_forenames":null,"record_page":"14404","amount":null,"grantor_1":"US HOME AG SERIES 3RD LLC","grantor_1_forenames":null,"apn":"H12B000013 01630","record_date":"2022-06-15","grantor_2":null,"grantor_2_forenames":null,"fips":"28121","record_doc":null,"record_book":"2022"},{"event_type":"arms_length_sale","grantee_1":"US HOME AG SERIES 3RD LLC","grantee_1_forenames":null,"grantee_2":null,"grantee_2_forenames":null,"record_page":"13714","amount":null,"grantor_1":"JAMES B BAILEY PROPS LLC","grantor_1_forenames":null,"apn":"H12B000013 01630","record_date":"2020-07-17","grantor_2":null,"grantor_2_forenames":null,"fips":"28121","record_doc":null,"record_book":"2020"},{"event_type":"arms_length_sale","grantee_1":"JAMES B BAILEY PROPS LLC","grantee_1_forenames":null,"grantee_2":null,"grantee_2_forenames":null,"record_page":"11156","amount":null,"grantor_1":"MARKHAM","grantor_1_forenames":"HAROLD L","apn":"H12B000013 01630","record_date":"2020-06-16","grantor_2":"MARKHAM","grantor_2_forenames":"BETTY H","fips":"28121","record_doc":null,"record_book":"2020"}]},"address_info":{"city":"Brandon","county_fips":"28121","geo_precision":"rooftop","zipcode":"39047","address_full":"103 Forest Point Dr Brandon MS 39047","slug":"103-Forest-Point-Dr-Brandon-MS-39047","block_id":"281210202094016","blockgroup_id":"281210202094","state":"MS","zipcode_plus4":"6207","address":"103 Forest Point Dr","lat":32.3754997,"lng":-90.021965,"unit":null,"msa":"27140","metrodiv":null,"status":{"match":true,"details":["Address fully verified"],"errors":[],"changes":["State added or changed","Locality (city, municipality) added or changed"],"requested_item":{"zipcode":"39047","address_id":83910163,"address":"103 Forest Point Dr"}}}}]';            
        }
        Else
        {
        rawJSON = callOut(method, endpoint);            
        }

        if (rawJSON.Substring(0,5) != 'Error')
        {
        if (rawJSON.substring(0, 1) == '[')  rawJSON = rawJSON.substring(1, rawJSON.length()-1); //get the json from the list.
        Map<String, Object> property_sales_history =(Map<String, Object>)JSON.deserializeUntyped(rawJSON);
        Map<String, Object> shMapObjects = (Map<String, Object>) property_sales_history.get('property/sales_history');
		shDataObjectsResultsFinal = new HouseCanaryResponseModel.property_sales_history();  //Data Object
        shDataObjectsResultsFinal.api_code_description = (string) shMapObjects?.get('api_code_description');
        shDataObjectsResultsFinal.api_code = (Integer) shMapObjects?.get('api_code');
        if (shDataObjectsResultsFinal.api_code == 0)
        {
		List<HouseCanaryResponseModel.result_sales_history> shDataObjectsResultsListFinal =  shDataObjectsResultsFinal?.result_sales_history;             
        List<Object> shMapObjectsResults = (List<Object>) shMapObjects.get('result');
        for(object shMapObjectsResult : shMapObjectsResults) 
        {
            HouseCanaryResponseModel.result_sales_history propertySalesResults = new HouseCanaryResponseModel.result_sales_history();
            Map<String, Object> shMapObjectsResultfields = (Map<String, Object>) shMapObjectsResult;
            propertySalesResults.event_type = (string) shMapObjectsResultfields?.get('event_type');
            propertySalesResults.grantee_1 = (string) shMapObjectsResultfields?.get('grantee_1');  
            propertySalesResults.grantee_1_forenames = (string) shMapObjectsResultfields?.get('grantee_1_forenames');  
            propertySalesResults.grantee_2 = (string) shMapObjectsResultfields?.get('grantee_2'); 
            propertySalesResults.grantee_2_forenames = (string) shMapObjectsResultfields?.get('grantee_2_forenames');  
            propertySalesResults.record_page = (string) shMapObjectsResultfields?.get('record_page'); 
            if (shMapObjectsResultfields.get('amount') != 'null')  propertySalesResults.amount = (Decimal) shMapObjectsResultfields?.get('amount');  
            propertySalesResults.grantor_1 = (string) shMapObjectsResultfields?.get('grantor_1');  
            propertySalesResults.grantor_1_forenames = (string) shMapObjectsResultfields?.get('grantor_1_forenames');  
            propertySalesResults.grantor_2 = (string) shMapObjectsResultfields?.get('grantor_2');            
            propertySalesResults.apn = (string) shMapObjectsResultfields?.get('apn');  
            propertySalesResults.record_date = (string) shMapObjectsResultfields?.get('record_date');  
            propertySalesResults.fips = (string) shMapObjectsResultfields?.get('fips'); 
            propertySalesResults.record_doc = (string) shMapObjectsResultfields?.get('record_doc');  
            propertySalesResults.record_book = (string) shMapObjectsResultfields?.get('record_book');   
			shDataObjectsResultsListFinal.add(propertySalesResults); 
        }
        responseCodes.add(0);
        responseString.add('');
        validCall = True;
    	}
        else
        {
            responseCodes.add(shDataObjectsResultsFinal.api_code);
            responseString.add('\n' + 'Sales History : ' + 'Return Code : ' + shDataObjectsResultsFinal.api_code + ' ' + shDataObjectsResultsFinal.api_code_description);
        }             
	}
	}        

//////////////////////////    
    public static void get_Mortgage_Lien_All_Data(Property__c prop)
    {
        String endpoint;
        String method;
		String parameter;
        String rawJSON;        

 		endpoint = '/mortgage_lien_all';
        if (prop.Name != null)
        {
         String address = prop.Name ;
         parameter = '?address='+ EncodingUtil.urlEncode(prop.Name, 'UTF-8');
         parameter = parameter  + '&zipcode=' + EncodingUtil.urlEncode(prop.ZipCode__c, 'UTF-8');
        }
		endpoint = endpoint + parameter;
        method = 'GET';
        if (test.isRunningTest())
        {
        rawJSON = '[{"property/mortgage_lien_all":{"api_code_description":"no content","api_code":204,"result":null},"address_info":{"city":"Brandon","county_fips":"28121","geo_precision":"rooftop","zipcode":"39047","address_full":"103 Forest Point Dr Brandon MS 39047","slug":"103-Forest-Point-Dr-Brandon-MS-39047","block_id":"281210202094016","blockgroup_id":"281210202094","state":"MS","zipcode_plus4":"6207","address":"103 Forest Point Dr","lat":32.3754997,"lng":-90.021965,"unit":null,"msa":"27140","metrodiv":null,"status":{"match":true,"details":["Address fully verified"],"errors":[],"changes":["State added or changed","Locality (city, municipality) added or changed"],"requested_item":{"zipcode":"39047","address_id":83910163,"address":"103 Forest Point Dr"}}}}]';            
        }
        Else
        {
        rawJSON = callOut(method, endpoint);            
        }
        if (rawJSON.Substring(0,5) != 'Error')
        {        
        if (rawJSON.substring(0, 1) == '[')    rawJSON = rawJSON.substring(1, rawJSON.length()-1); //get the json from the list.

		Map<String, Object> mortgage_lien_all =(Map<String, Object>)JSON.deserializeUntyped(rawJSON);
        Map<String, Object> mlaMapObjects = (Map<String, Object>) mortgage_lien_all.get('property/mortgage_lien_all');
		mlaDataObjectsResultsFinal = new HouseCanaryResponseModel.property_mortgage_lien_all(); //Data Object            
        mlaDataObjectsResultsFinal.api_code_description = (string) mlaMapObjects.get('api_code_description');
        mlaDataObjectsResultsFinal.api_code = (Integer) mlaMapObjects.get('api_code');
        if (mlaDataObjectsResultsFinal.api_code == 0)
        {
		List<HouseCanaryResponseModel.result_mortgage_liens_all> mlaDataObjectsResultsListFinal =  mlaDataObjectsResultsFinal.result_mortgage_lien_all;             
        List<object> mlaMapObjectsResults = (List<object>) mlaMapObjects.get('result');
		for(object mlaMapObjectsResult : mlaMapObjectsResults) 
        {
            HouseCanaryResponseModel.result_mortgage_liens_all mortageLienAllResults = new HouseCanaryResponseModel.result_mortgage_liens_all();            
           	Map<String, Object> mlaMapObjectsResultfields = (Map<String, Object>) mlaMapObjectsResult;
            mortageLienAllResults.fips 					= (String) mlaMapObjectsResultfields?.get('fips');
            mortageLienAllResults.apn 					= (String) mlaMapObjectsResultfields?.get('apn');
            mortageLienAllResults.amount 				= (Double) mlaMapObjectsResultfields?.get('amount');
            mortageLienAllResults.due_date 				= (String) mlaMapObjectsResultfields?.get('due_date');
            mortageLienAllResults.event_type 			= (String) mlaMapObjectsResultfields?.get('event_type');
            mortageLienAllResults.grantee_1 			= (String) mlaMapObjectsResultfields?.get('grantee_1');
            mortageLienAllResults.grantee_1_forenames 	= (String) mlaMapObjectsResultfields?.get('grantee_1_forenames');
            mortageLienAllResults.grantee_2 			= (String) mlaMapObjectsResultfields?.get('grantee_2');
            mortageLienAllResults.grantee_2_forenames 	= (String) mlaMapObjectsResultfields?.get('grantee_2_forenames');
            mortageLienAllResults.grantor_1 			= (String) mlaMapObjectsResultfields?.get('grantor_1');
            mortageLienAllResults.grantor_2 			= (String) mlaMapObjectsResultfields?.get('grantor_2');
            mortageLienAllResults.interest_rate 		= (Double) mlaMapObjectsResultfields?.get('interest_rate');
            mortageLienAllResults.record_book 			= (String) mlaMapObjectsResultfields?.get('record_book');
            mortageLienAllResults.record_date 			= (String) mlaMapObjectsResultfields?.get('record_date');
            mortageLienAllResults.record_doc 			= (String) mlaMapObjectsResultfields?.get('record_doc');
            mortageLienAllResults.record_page 			= (String) mlaMapObjectsResultfields?.get('record_page');
            mortageLienAllResults.mortgage_years 		= (Integer) mlaMapObjectsResultfields?.get('mortgage_years');
            mortageLienAllResults.thirty_yr 			= (Double) mlaMapObjectsResultfields?.get('thirty_yr');
            mortageLienAllResults.fifteen_yr 			= (Double) mlaMapObjectsResultfields?.get('fifteen_yr');
            mortageLienAllResults.hc_interest_rate 		= (Double) mlaMapObjectsResultfields?.get('hc_interest_rate');
            mortageLienAllResults.lien_type 			= (String) mlaMapObjectsResultfields?.get('lien_type');
            mortageLienAllResults.heloc 				= (Boolean) mlaMapObjectsResultfields?.get('heloc');
            mortageLienAllResults.stand_alone_refi 		= (Boolean) mlaMapObjectsResultfields?.get('stand_alone_refi');
            mortageLienAllResults.lender_type 			= (String) mlaMapObjectsResultfields?.get('lender_type');
            mortageLienAllResults.arm_index 			= (String) mlaMapObjectsResultfields?.get('arm_index');
			mlaDataObjectsResultsListFinal.add(mortageLienAllResults);
        }            
 
        responseCodes.add(0);
        responseString.add('');
        validCall = True;
        }
        else
        {
            responseCodes.add(mlaDataObjectsResultsFinal.api_code);
            responseString.add('\n' + 'Mortgage Lien : ' + 'Return Code : ' + mlaDataObjectsResultsFinal.api_code + ' ' + mlaDataObjectsResultsFinal.api_code_description);
        }                         
        }          
    }

//////////////////////////    
    public static void get_Flood_Data(Property__c prop)
    {
        String endpoint;
        String method;
		String parameter;
        String rawJSON;
 
 		endpoint = '/flood';
        if (prop.Name != null)
        {
         String address = prop.Name ;
         parameter = '?address='+ EncodingUtil.urlEncode(prop.Name, 'UTF-8');
         parameter = parameter  + '&zipcode=' + EncodingUtil.urlEncode(prop.ZipCode__c, 'UTF-8');
        }
		endpoint = endpoint + parameter;
        method = 'GET';
        if (test.isRunningTest())
        {
        rawJSON = '[{"property/flood":{"api_code_description":"ok","api_code":0,"result":{"effective_date":"2014-06-09","zone":"X","flood_risk":"low","panel_number":"28121C0070F"}},"address_info":{"city":"Brandon","county_fips":"28121","geo_precision":"rooftop","zipcode":"39047","address_full":"103 Forest Point Dr Brandon MS 39047","slug":"103-Forest-Point-Dr-Brandon-MS-39047","block_id":"281210202094016","blockgroup_id":"281210202094","state":"MS","zipcode_plus4":"6207","address":"103 Forest Point Dr","lat":32.3754997,"lng":-90.021965,"unit":null,"msa":"27140","metrodiv":null,"status":{"match":true,"details":["Address fully verified"],"errors":[],"changes":["State added or changed","Locality (city, municipality) added or changed"],"requested_item":{"zipcode":"39047","address_id":83910163,"address":"103 Forest Point Dr"}}}}]';            
        }
        Else
        {
        rawJSON = callOut(method, endpoint);            
        }
        if (rawJSON.Substring(0,5) != 'Error')
        {        
        if (rawJSON.substring(0, 1) == '[')    rawJSON = rawJSON.substring(1, rawJSON.length()-1); //get the json from the list.

		Map<String, Object> property_flood =(Map<String, Object>)JSON.deserializeUntyped(rawJSON);
        Map<String, Object> fldMapObjects = (Map<String, Object>) property_flood.get('property/flood');
		fldDataObjectsResultsFinal = new HouseCanaryResponseModel.property_flood(); //Data Object            
        fldDataObjectsResultsFinal.api_code_description = (string) fldMapObjects.get('api_code_description');
        fldDataObjectsResultsFinal.api_code = (Integer) fldMapObjects.get('api_code');
        if (fldDataObjectsResultsFinal.api_code == 0)
        {
		Map<String, Object> fldMapObjectsResults = (Map<String, Object>) fldMapObjects.get('result');
		fldDataObjectsResultsFinal.result_flood.effective_date 	= (string) fldMapObjectsResults?.get('effective_date');   
		fldDataObjectsResultsFinal.result_flood.zone 			= (string) fldMapObjectsResults?.get('zone');  
		fldDataObjectsResultsFinal.result_flood.flood_risk 		= (string) fldMapObjectsResults?.get('flood_risk');  
		fldDataObjectsResultsFinal.result_flood.panel_number 	= (string) fldMapObjectsResults?.get('panel_number');  
  
        responseCodes.add(0);
        responseString.add('');
        validCall = True;
        }
        else
        {
            responseCodes.add(fldDataObjectsResultsFinal.api_code);
            responseString.add('\n' + 'Flood : ' + 'Return Code : ' + fldDataObjectsResultsFinal.api_code + ' ' + fldDataObjectsResultsFinal.api_code_description);
        }             
        }         
    }
    
//////////////////////////    
    public static void get_Block_Crime_Data(Property__c prop)
    {
        String endpoint;
        String method;
		String parameter;
        String rawJSON;
        
 		endpoint = '/block_crime';
        if (prop.Name != null)
        {
         String address = prop.Name ;
         parameter = '?address='+ EncodingUtil.urlEncode(prop.Name, 'UTF-8');
         parameter = parameter  + '&zipcode=' + EncodingUtil.urlEncode(prop.ZipCode__c, 'UTF-8');
        }
		endpoint = endpoint + parameter;
        method = 'GET';
        if (test.isRunningTest())
        {
        rawJSON = '{"property/block_crime":{"api_code_description":"ok","api_code":0,"result":{"all":{"incidents":0,"county_percentile":0,"nation_percentile":0},"property":null,"violent":{"incidents":0,"county_percentile":0,"nation_percentile":0},"other":{"incidents":0,"county_percentile":0,"nation_percentile":0}}},"address_info":{"city":"Brandon","county_fips":"28121","geo_precision":"rooftop","zipcode":"39047","address_full":"103 Forest Point Dr Brandon MS 39047","slug":"103-Forest-Point-Dr-Brandon-MS-39047","block_id":"281210202094016","blockgroup_id":"281210202094","state":"MS","zipcode_plus4":"6207","address":"103 Forest Point Dr","lat":32.3754997,"lng":-90.021965,"unit":null,"msa":"27140","metrodiv":null,"status":{"match":true,"details":["Address fully verified"],"errors":[],"changes":["State added or changed","Locality (city, municipality) added or changed"],"requested_item":{"address":"103 Forest Point Dr","address_id":83910163,"zipcode":"39047"}}}}';            
        }
        Else
        {
        rawJSON = callOut(method, endpoint);            
        }
        if (rawJSON.Substring(0,5) != 'Error')
        {        
        if (rawJSON.substring(0, 1) == '[')    rawJSON = rawJSON.substring(1, rawJSON.length()-1); //get the json from the list.

		Map<String, Object> block_crime =(Map<String, Object>)JSON.deserializeUntyped(rawJSON);
        Map<String, Object> bcMapObjects = (Map<String, Object>) block_crime.get('property/block_crime');
		bcDataObjectsResultsFinal = new HouseCanaryResponseModel.property_block_crime(); //Data Object  
        bcDataObjectsResultsFinal.api_code_description = (string) bcMapObjects.get('api_code_description');
        bcDataObjectsResultsFinal.api_code = (Integer) bcMapObjects.get('api_code');
        if (bcDataObjectsResultsFinal.api_code == 0)
        {
		Map<String, Object> bcMapObjectsResults = (Map<String, Object>) bcMapObjects.get('result');
        Map<String, Object> bcMapObjectsResultsAll = (Map<String, Object>) bcMapObjectsResults.get('all');
		bcDataObjectsResultsFinal.result_block_crime.all.incidents 			= (Integer) bcMapObjectsResultsAll?.get('incidents');   
		bcDataObjectsResultsFinal.result_block_crime.all.county_percentile 	= (Integer) bcMapObjectsResultsAll?.get('county_percentile'); 
		bcDataObjectsResultsFinal.result_block_crime.all.nation_percentile 	= (Integer) bcMapObjectsResultsAll?.get('nation_percentile');  
        Map<String, Object> bcMapObjectsResultsother = (Map<String, Object>) bcMapObjectsResults.get('other');
		bcDataObjectsResultsFinal.result_block_crime.other.incidents 			= (Integer) bcMapObjectsResultsother?.get('incidents');   
		bcDataObjectsResultsFinal.result_block_crime.other.county_percentile 	= (Integer) bcMapObjectsResultsother?.get('county_percentile'); 
		bcDataObjectsResultsFinal.result_block_crime.other.nation_percentile 	= (Integer) bcMapObjectsResultsother?.get('nation_percentile');  
        Map<String, Object> bcMapObjectsResultsviolent = (Map<String, Object>) bcMapObjectsResults.get('violent');
		bcDataObjectsResultsFinal.result_block_crime.violent.incidents 			= (Integer) bcMapObjectsResultsviolent?.get('incidents');   
		bcDataObjectsResultsFinal.result_block_crime.violent.county_percentile 	= (Integer) bcMapObjectsResultsviolent?.get('county_percentile'); 
		bcDataObjectsResultsFinal.result_block_crime.violent.nation_percentile 	= (Integer) bcMapObjectsResultsviolent?.get('nation_percentile'); 
        Map<String, Object> bcMapObjectsResultsproperty = (Map<String, Object>) bcMapObjectsResults.get('property');
		bcDataObjectsResultsFinal.result_block_crime.property.incidents 			= (Integer) bcMapObjectsResultsproperty?.get('incidents');   
		bcDataObjectsResultsFinal.result_block_crime.property.county_percentile 	= (Integer) bcMapObjectsResultsproperty?.get('county_percentile'); 
		bcDataObjectsResultsFinal.result_block_crime.property.nation_percentile 	= (Integer) bcMapObjectsResultsproperty?.get('nation_percentile');             

        responseCodes.add(0);
        responseString.add('');
        validCall = True;
        }
        else
        {
            responseCodes.add(bcDataObjectsResultsFinal.api_code);
            responseString.add('\n' + 'Block Crime : ' + 'Return Code : ' + bcDataObjectsResultsFinal.api_code + ' ' + bcDataObjectsResultsFinal.api_code_description);
        }             
        }             
    }        

//////////////////////////    
    public static void get_Tax_History_Data(Property__c prop)
    {
        String endpoint;
        String method;
		String parameter;
        String rawJSON;
        
 		endpoint = '/tax_history';
        if (prop.Name != null)
        {
         String address = prop.Name ;
         parameter = '?address='+ EncodingUtil.urlEncode(prop.Name, 'UTF-8');
         parameter = parameter  + '&zipcode=' + EncodingUtil.urlEncode(prop.ZipCode__c, 'UTF-8');
         parameter = parameter  + '&order=desc';
        }
		endpoint = endpoint + parameter;
        method = 'GET';
        if (test.isRunningTest())
        {
        rawJSON = '[{"property/tax_history":{"api_code_description":"ok","api_code":0,"result":{"tax_history":[{"apn":"H12B000013 01630","assessment_year":2021,"tax_year":2021,"total_assessed_value":17106,"tax_amount":1816},{"apn":"H12B000013 01630","assessment_year":2020,"tax_year":2020,"total_assessed_value":17106,"tax_amount":1816},{"apn":"H12B000013 01630","assessment_year":2019,"tax_year":2019,"total_assessed_value":15560,"tax_amount":1695},{"apn":"H12B000013 01630","assessment_year":2017,"tax_year":2017,"total_assessed_value":15560,"tax_amount":1664},{"apn":"H12B000013 01630","assessment_year":2015,"tax_year":2015,"total_assessed_value":15188,"tax_amount":1548},{"apn":"H12B000013 01630","assessment_year":2014,"tax_year":2014,"total_assessed_value":15188,"tax_amount":1516}]}},"address_info":{"city":"Brandon","county_fips":"28121","geo_precision":"rooftop","zipcode":"39047","address_full":"103 Forest Point Dr Brandon MS 39047","slug":"103-Forest-Point-Dr-Brandon-MS-39047","block_id":"281210202094016","blockgroup_id":"281210202094","state":"MS","zipcode_plus4":"6207","address":"103 Forest Point Dr","lat":32.3754997,"lng":-90.021965,"unit":null,"msa":"27140","metrodiv":null,"status":{"match":true,"details":["Address fully verified"],"errors":[],"changes":["State added or changed","Locality (city, municipality) added or changed"],"requested_item":{"zipcode":"39047","address":"103 Forest Point Dr","address_id":83910163}}}}]';            
        }
        Else
        {
        rawJSON = callOut(method, endpoint);            
        }
        if (rawJSON.Substring(0,5) != 'Error')
        {        
        if (rawJSON.substring(0, 1) == '[')    rawJSON = rawJSON.substring(1, rawJSON.length()-1); //get the json from the list.
		Map<String, Object> tax_history =(Map<String, Object>)JSON.deserializeUntyped(rawJSON);
        Map<String, Object> thMapObjects = (Map<String, Object>) tax_history.get('property/tax_history');
		thDataObjectsResultsFinal = new HouseCanaryResponseModel.property_tax_history(); //Data Object  
        thDataObjectsResultsFinal.api_code_description = (string) thMapObjects.get('api_code_description');
        thDataObjectsResultsFinal.api_code = (Integer) thMapObjects.get('api_code');
        if (thDataObjectsResultsFinal.api_code  == 0)
        {		            
		List<HouseCanaryResponseModel.result_tax_history> thDataObjectsResultsListFinal =  thDataObjectsResultsFinal.result_tax_history;             
        Map<String, Object> thMapObjectsResults_prev = (Map<String, Object>) thMapObjects.get('result');
		List<Object> thMapObjectsResults = (List<Object>) thMapObjectsResults_prev.get('tax_history');            
		for(object thMapObjectsResult : thMapObjectsResults) 
        {
            HouseCanaryResponseModel.result_tax_history taxHistoryResults = new HouseCanaryResponseModel.result_tax_history();            
           	Map<String, Object> thMapObjectsResultfields = (Map<String, Object>) thMapObjectsResult;
            taxHistoryResults.apn 					= (String) thMapObjectsResultfields.get('apn');
            taxHistoryResults.assessment_year 		= (String) String.valueOf(thMapObjectsResultfields.get('assessment_year'));            
            taxHistoryResults.tax_year 				= (String) String.valueOf(thMapObjectsResultfields.get('tax_year')); 
            taxHistoryResults.total_assessed_value	= (Integer) thMapObjectsResultfields.get('total_assessed_value');             
            taxHistoryResults.tax_amount			= (Integer) thMapObjectsResultfields.get('tax_amount');
            thDataObjectsResultsListFinal.add(taxHistoryResults);
        }
        responseCodes.add(0);
        responseString.add('');
        validCall = True;
        }
        else
        {
            responseCodes.add(thDataObjectsResultsFinal.api_code);
            responseString.add('\n' + 'Tax History : ' + 'Return Code : ' + thDataObjectsResultsFinal.api_code + ' ' + thDataObjectsResultsFinal.api_code_description);
        }                
        }            
    }
////////////////////////// 
public static void get_Value_Report_Data(Property__c prop)
    {
        String endpoint;
        String method;
		String parameter;
        String rawJSON;
        
 		endpoint = '/value_report_static_link';
        if (prop.Name != null)
        {
         String address = prop.Name ;
         parameter = '?address='+ EncodingUtil.urlEncode(prop.Name, 'UTF-8');
         parameter = parameter  + '&zipcode=' + EncodingUtil.urlEncode(prop.ZipCode__c, 'UTF-8');
        }
		endpoint = endpoint + parameter;
        method = 'GET';
        if (test.isRunningTest())
        {
        rawJSON = '{"property/value_report_static_link": {"api_code": 200, "api_code_description": "ok", "result": {"link": "https://api.housecanary.com/api/v1/proxy/report_download/gAAAAABixOF4eQzacEofTy-0nGIwGFyeGS1rhdoJ2pjeYMiy6Yslt-7a4SfSISITZGz_D_2sKzqBRdlagO9-QXyNSMsXhye9-qRFi9GCM2ghKGjJxivziInSKNKEk2VEnvYpS_B5MXHeOxL4R-uT7-euYoI8NxkwAmYq9WBto3dxw7pK4FWkWG4="}}, "address_info": {"address_full": "103 Forest Point Dr Brandon MS 39047", "slug": "103-Forest-Point-Dr-Brandon-MS-39047", "address": "103 Forest Point Dr", "unit": null, "unit_designator": null, "zipcode": "39047", "zipcode_plus4": "6207", "block_id": "281210202094016", "blockgroup_id": "281210202094", "county_fips": "28121", "metrodiv": null, "msa": "27140", "city": "Brandon", "state": "MS", "geo_precision": "rooftop", "lat": 32.3755, "status": {"match": true, "details": ["Address fully verified"], "errors": [], "changes": ["State added or changed", "Locality (city, municipality) added or changed"]}, "is_complete": true, "requested_item": {"address": "103 Forest Point Dr", "zipcode": "39047"}, "lng": -90.02196}}';            
        }
        Else
        {
        rawJSON = callOut(method, endpoint);            
        }
        if (rawJSON.Substring(0,5) != 'Error')
        {        
        if (rawJSON.substring(0, 1) == '[')    rawJSON = rawJSON.substring(1, rawJSON.length()-1); //get the json from the list.
		Map<String, Object> value_Report =(Map<String, Object>)JSON.deserializeUntyped(rawJSON);
        Map<String, Object> vrMapObjects = (Map<String, Object>) value_Report.get('property/value_report_static_link');
		vrDataObjectsResultsFinal = new HouseCanaryResponseModel.Property_ValueReport(); //Data Object  
        vrDataObjectsResultsFinal.api_code_description = (string) vrMapObjects.get('api_code_description'); 
        vrDataObjectsResultsFinal.api_code = (Integer) vrMapObjects.get('api_code');
        if (vrDataObjectsResultsFinal.api_code  == 200)
        {		            
        Map<String, Object> vrMapObjectsResults = (Map<String, Object>) vrMapObjects.get('result');
        vrDataObjectsResultsFinal.Result_ValueReport.link 			= (String) vrMapObjectsResults?.get('link'); 
        responseCodes.add(0);
        responseString.add('');
        validCall = True;
        }
        else
        {
            responseCodes.add(vrDataObjectsResultsFinal.api_code);
            responseString.add('\n' + 'Value Report Static Link : ' + 'Return Code : ' + vrDataObjectsResultsFinal.api_code + ' ' + vrDataObjectsResultsFinal.api_code_description);
        }                
        }            
    }
////////////////////////////    
 public static String callOut(String method, String parameter) 
 	{
        HttpResponse response = new HttpResponse();
        HttpRequest request = new httpRequest();
        request.setTimeout(60000);
    	request.setMethod(method);
        request.setEndpoint('callout:HouseCanary'+parameter);
        response = new Http().send(request);
   		if (response.getstatuscode() == 200)
        {
        return response.getBody();
        }
		Else
		{
        System.CalloutException e = new System.CalloutException();
        e.setMessage(response.getStatusCode() + ': ' + response.getStatus());
        String ErrorMessage = 'Error' + '**' + 'HouseCanary Status Code :' + response.getStatusCode() + '**' + 'HouseCanary Status Message :' + response.getStatus();        
        /*if (settings[0].Enable_HouseCanary_API_Response_Logging__c == True && settings[0].Enable_HouseCanary_API_Error_Response_Logging__c == True)
        {        
          request.setBody('{"call":"HouseCanary Call"}');
          response.setBody('{"call":"HouseCanary Call in Error"}');
          System.enqueueJob(new APILoggerQueueable(request, response, id, e));
        }*/
            return ErrorMessage;
    	}		        
    }
    
    public static void insertPropertyAVM(List<Property__c> props) 
    {
        List<Property_AVM__c> avmList = new List<Property_AVM__c>();
        List<Property_Mortgage_lien_all__c> propMortLienallList = new List<Property_Mortgage_lien_all__c>();
        List<Property_Sales_history__c> propSalesHistoryList	= new List<Property_Sales_history__c>(); 
        List<Property_Tax_History__c> propTaxHistoryList = new List<Property_Tax_History__c>();
        //List<HouseCanaryForReporting__c> HCReportingList = new List<HouseCanaryForReporting__c>();
        //List<Property__c> PropList = New List<Property__c>();
        Boolean validResponseAVM = False;
        if (valueReportOnly)
        {
        for (Integer i=0;i<props.size();i++)
        {
           Property_AVM__c avm=new Property_AVM__c();
           If (vrDataObjectsResultsFinal?.api_code == 200)
           {
            validResponseAVM = True;   
            if (vrDataObjectsResultsFinal.Result_ValueReport?.link != null)    
            {
			avm.id = propertiesAVM[0].id;                
			avm.value_report_static_Link__c	= vrDataObjectsResultsFinal.Result_ValueReport.link;                                         
            }
            avmList.add(avm);               
           }
        }
        }
        Else
        {
       for (Integer i=0;i<props.size();i++)
       {
       	   Property_AVM__c avm=new Property_AVM__c();
           validResponseAVM = False;
           If (responseCodes[0] == 0)
           {
            validResponseAVM = True;
            if (vaDataObjectsResultsFinal.recommended_approach != null )
             avm.recommended_approach__c 	= vaDataObjectsResultsFinal.recommended_approach;               
             if (vaDataObjectsResultsFinal.hc_avm_value_analysis?.avm_value != null) 
             {
				avm.AVM_Calculated_Price__c 		= vaDataObjectsResultsFinal.hc_avm_value_analysis.avm_value;                 
                props[i].Calc_AveValue__c 			= vaDataObjectsResultsFinal.hc_avm_value_analysis.avm_value; 
				//props[i].Calc_AveValue__c 			= props[i].Calc_AveValue__c == null ? vaDataObjectsResultsFinal.hc_avm_value_analysis.avm_value : props[i].Calc_AveValue__c;                
             }
               
             if (vaDataObjectsResultsFinal.hc_avm_value_analysis?.avm_confidence != null)                
             avm.avm_confidence__c 			= vaDataObjectsResultsFinal.hc_avm_value_analysis.avm_confidence;
               
             if (vaDataObjectsResultsFinal.hc_avm_value_analysis.neighborhood_analysis?.avm_value_sqft != null) 
             	avm.avm_value_sqft__c  = vaDataObjectsResultsFinal.hc_avm_value_analysis.neighborhood_analysis?.avm_value_sqft;
        
             if (vaDataObjectsResultsFinal.hc_avm_value_analysis.comp_based_analysis?.number_of_comps != null)                
			 avm.AVM_number_of_comps__c 	= vaDataObjectsResultsFinal.hc_avm_value_analysis.comp_based_analysis?.number_of_comps;
           }
//////////////           
           If (rvDataObjectsResultsFinal?.api_code == 0)
           {
            validResponseAVM = True;   
            if (rvDataObjectsResultsFinal.Result_RetalValue?.price_mean != null) 
            {
            avm.Estimated_Rent__c 		= rvDataObjectsResultsFinal.Result_RetalValue.price_mean;
			props[i].Estimated_Rent__c 	=  rvDataObjectsResultsFinal.Result_RetalValue.price_mean;               
			//props[i].Estimated_Rent__c 	= props[i].Monthly_Rent__c == null ? rvDataObjectsResultsFinal.Result_RetalValue.price_mean : props[i].Monthly_Rent__c;                
            }  
            if (rvDataObjectsResultsFinal.Result_RetalValue?.price_upr != null)               
			avm.Estimated_Max_Rent__c 	= rvDataObjectsResultsFinal.Result_RetalValue.price_upr;
            if (rvDataObjectsResultsFinal.Result_RetalValue?.price_lwr != null)                 
			avm.Estimated_Min_Rent__c 	= rvDataObjectsResultsFinal.Result_RetalValue.price_lwr;
            if (rvDataObjectsResultsFinal.Result_RetalValue?.fsd != null)                  
			avm.fsd__c 					= rvDataObjectsResultsFinal.Result_RetalValue.fsd;
           }
////////////           
           If (pdDataObjectsResultsFinal?.api_code == 0)
           {
            validResponseAVM = True;   

            /*avm.AVM_Address__c = pdDataObjectsResultsFinal.Address_Info?.Address;
            props[i].Name 		= props[i].Name == null ? pdDataObjectsResultsFinal.Address_Info?.Address : props[i].Name; 
            avm.AVM_City__c 	= pdDataObjectsResultsFinal.Address_Info?.City;
			props[i].City__c 	= props[i].City__c == null ? pdDataObjectsResultsFinal.Address_Info?.City : props[i].City__c;               
            avm.AVM_State__c = pdDataObjectsResultsFinal.Address_Info?.State;
			props[i].State__c 	= props[i].State__c == null ? pdDataObjectsResultsFinal.Address_Info?.State : props[i].State__c;               
            avm.AVM_ZIP__c 	= pdDataObjectsResultsFinal.Address_Info?.Zipcode;
			props[i].ZipCode__c = props[i].ZipCode__c == null ? pdDataObjectsResultsFinal.Address_Info?.Zipcode : props[i].ZipCode__c;  */             
             
            avm.AVM_Address__c 	= props[i].Name;
            avm.AVM_City__c 	= props[i].City__c;
            avm.AVM_State__c 	= props[i].State__c;
            avm.AVM_ZIP__c 		= props[i].ZipCode__c;
               
            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail?.air_conditioning != null)                 
            avm.air_conditioning__c = pdDataObjectsResultsFinal.Result_Detail.propert_detail?.air_conditioning;
			if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.attic == null)
            {
            avm.attic__c = false;
            }
            Else
            {
            avm.attic__c = pdDataObjectsResultsFinal.Result_Detail?.propert_detail.attic;
            }
            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.basement != null)               
            avm.basement__c 				= pdDataObjectsResultsFinal.Result_Detail?.propert_detail.basement;
            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.building_area_sq_ft != null) 
            {
            avm.building_area_sq_ft__c 		= pdDataObjectsResultsFinal.Result_Detail.propert_detail?.building_area_sq_ft;
			avm.AVM_Square_Feet__c  = pdDataObjectsResultsFinal.Result_Detail.propert_detail?.building_area_sq_ft;
            //props[i].Square_Feet__c = String.Valueof(pdDataObjectsResultsFinal.Result_Detail.propert_detail?.building_area_sq_ft);
			props[i].Square_Feet__c = props[i].Square_Feet__c   == null ? String.valueOf(pdDataObjectsResultsFinal.Result_Detail.propert_detail?.building_area_sq_ft) : props[i].Square_Feet__c;                              
            }
            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.building_condition_score != null)                 
            avm.building_condition_score__c = pdDataObjectsResultsFinal.Result_Detail?.propert_detail.building_condition_score;
            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.building_quality_score != null)                 
            avm.building_quality_score__c 	= pdDataObjectsResultsFinal.Result_Detail.propert_detail.building_quality_score;
            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.construction_type != null)                
            avm.construction_type__c 		= pdDataObjectsResultsFinal.Result_Detail?.propert_detail.construction_type;
            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.exterior_walls != null)                
            avm.exterior_walls__c 			= pdDataObjectsResultsFinal.Result_Detail?.propert_detail.exterior_walls;
            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.fireplace != null)                
            avm.fireplace__c 				= pdDataObjectsResultsFinal.Result_Detail?.propert_detail.fireplace;
            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.full_bath_count != null)                
            {
            avm.AVM_Baths__c 			= pdDataObjectsResultsFinal.Result_Detail?.propert_detail.full_bath_count;
            }   
            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.garage_parking_of_cars != null)               
            avm.garage_parking_of_cars__c 	= pdDataObjectsResultsFinal.Result_Detail?.propert_detail.garage_parking_of_cars;
            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.garage_type_parking != null)                 
            avm.garage_type_parking__c 		= pdDataObjectsResultsFinal.Result_Detail?.propert_detail.garage_type_parking;
            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.heating != null)                 
            avm.heating__c 					= pdDataObjectsResultsFinal.Result_Detail?.propert_detail.heating;
            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.no_of_buildings != null)                
            avm.no_of_buildings__c 			= pdDataObjectsResultsFinal.Result_Detail?.propert_detail.no_of_buildings;
            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.no_of_stories != null)
            {
            avm.no_of_stories__c 			= pdDataObjectsResultsFinal.Result_Detail?.propert_detail.no_of_stories;
            //props[i].no_of_stories__c		= pdDataObjectsResultsFinal.Result_Detail?.propert_detail.no_of_stories;
            props[i].no_of_stories__c		= props[i].no_of_stories__c == null ? pdDataObjectsResultsFinal.Result_Detail?.propert_detail.no_of_stories : props[i].no_of_stories__c;               
            }                
            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.number_of_bedrooms != null)
            {
            avm.AVM_Beds__c 			= pdDataObjectsResultsFinal.Result_Detail?.propert_detail.number_of_bedrooms;
            avm.number_of_bedrooms__c 	= pdDataObjectsResultsFinal.Result_Detail?.propert_detail.number_of_bedrooms;
			//props[i].Number_of_Beds__c 	= pdDataObjectsResultsFinal.Result_Detail?.propert_detail.number_of_bedrooms;               
            props[i].Number_of_Beds__c 	= props[i].Number_of_Beds__c == null ? pdDataObjectsResultsFinal.Result_Detail?.propert_detail.number_of_bedrooms : props[i].Number_of_Beds__c;
			}                
            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.number_of_units != null)                
            avm.number_of_units__c 			= pdDataObjectsResultsFinal.Result_Detail?.propert_detail.number_of_units;
            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.partial_bath_count != null)                 
            avm.partial_bath_count__c 		= pdDataObjectsResultsFinal.Result_Detail?.propert_detail.partial_bath_count;
			if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.pool == null)
            {
            avm.pool__c = false;
            }
            Else
            {
            avm.pool__c = pdDataObjectsResultsFinal.Result_Detail?.propert_detail.pool;
            }               
            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.property_type != null) 
            {
                if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.property_type == 'Single Family Residential')
                {
                    avm.property_type__c	= 'SFR';
                }
                Else
                {
            		avm.property_type__c	= pdDataObjectsResultsFinal.Result_Detail?.propert_detail.property_type;
                }
             }
            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.roof_cover != null)               
            avm.roof_cover__c 			= pdDataObjectsResultsFinal.Result_Detail?.propert_detail.roof_cover;
            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.roof_type != null)                
            avm.roof_type__c 			= pdDataObjectsResultsFinal.Result_Detail?.propert_detail.roof_type;
            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.sewer != null)                 
            avm.sewer__c 				= pdDataObjectsResultsFinal.Result_Detail?.propert_detail.sewer;
            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.site_area_acres != null)                  
            avm.site_area_acres__c 		= pdDataObjectsResultsFinal.Result_Detail?.propert_detail.site_area_acres;
            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.style != null)                 
            avm.style__c 				= pdDataObjectsResultsFinal.Result_Detail?.propert_detail.style;
            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.subdivision != null)                
            avm.subdivision__c 			= pdDataObjectsResultsFinal.Result_Detail?.propert_detail.subdivision;
            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.total_bath_count != null) 
            {
            avm.total_bath_count__c 	= pdDataObjectsResultsFinal.Result_Detail?.propert_detail.total_bath_count;                
            //props[i].Number_of_Bath__c	= pdDataObjectsResultsFinal.Result_Detail?.propert_detail.total_bath_count;
			props[i].Number_of_Bath__c 	= props[i].Number_of_Bath__c == null ?pdDataObjectsResultsFinal.Result_Detail?.propert_detail.total_bath_count : props[i].Number_of_Bath__c;               
                
            }                

            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.water != null)                  
            avm.water__c 				= pdDataObjectsResultsFinal.Result_Detail?.propert_detail.water;
            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.year_built != null)
            {
            avm.AVM_Year_Built__c 		= String.valueOf(pdDataObjectsResultsFinal.Result_Detail?.propert_detail.year_built);
			//props[i].Year_Built__c 		= String.valueOf(pdDataObjectsResultsFinal.Result_Detail?.propert_detail.year_built);               
			props[i].Year_Built__c 		= props[i].Year_Built__c == null ? String.valueOf(pdDataObjectsResultsFinal.Result_Detail?.propert_detail.year_built) : props[i].Year_Built__c;               
			}                                
            if (pdDataObjectsResultsFinal.Result_Detail?.propert_detail.zoning != null)                
            avm.zoning__c 				= pdDataObjectsResultsFinal.Result_Detail?.propert_detail.zoning;
            if (pdDataObjectsResultsFinal.Result_Detail?.assessment.apn != null)
            {
            avm.apn__c 		= pdDataObjectsResultsFinal.Result_Detail?.assessment.apn;
			//props[i].APN__c = pdDataObjectsResultsFinal.Result_Detail?.assessment.apn;                
			props[i].APN__c 	= props[i].APN__c == null ? pdDataObjectsResultsFinal.Result_Detail?.assessment.apn : props[i].APN__c;     
			}                                
            if (pdDataObjectsResultsFinal.Result_Detail?.assessment.assessment_year != null)                
            avm.assessment_year__c 		= pdDataObjectsResultsFinal.Result_Detail?.assessment.assessment_year;
            if (pdDataObjectsResultsFinal.Result_Detail?.assessment.tax_amount != null)                
             avm.tax_amount__c 			= pdDataObjectsResultsFinal.Result_Detail?.assessment.tax_amount;
            if (pdDataObjectsResultsFinal.Result_Detail?.assessment.tax_year != null)                
            avm.tax_year__c 			= pdDataObjectsResultsFinal.Result_Detail?.assessment.tax_year;
           if (pdDataObjectsResultsFinal.Result_Detail?.assessment.total_assessed_value != null)                 
            avm.total_assessed_value__c = pdDataObjectsResultsFinal.Result_Detail?.assessment.total_assessed_value;
           }
//////////       
 
           If (mlaDataObjectsResultsFinal?.api_code == 0)
           {
            for (Integer j = 0;j < mlaDataObjectsResultsFinal.result_mortgage_lien_all.size();j++ )
            {
           	Property_Mortgage_lien_all__c propMortLienall = new Property_Mortgage_lien_all__c(); 
            propMortLienall.RelatedProperty__c		= props[i].Id;
            propMortLienall.amount__c 				= mlaDataObjectsResultsFinal.result_mortgage_lien_all[j]?.amount;
         	propMortLienall.apn__c 					= mlaDataObjectsResultsFinal.result_mortgage_lien_all[j]?.apn;
            propMortLienall.arm_index__c 			= mlaDataObjectsResultsFinal.result_mortgage_lien_all[j]?.arm_index;
            if (mlaDataObjectsResultsFinal.result_mortgage_lien_all[j]?.due_date != Null)
            propMortLienall.due_date__c 			= date.valueOf(mlaDataObjectsResultsFinal.result_mortgage_lien_all[j]?.due_date);
            propMortLienall.event_type__c 			= mlaDataObjectsResultsFinal.result_mortgage_lien_all[j]?.event_type;
            propMortLienall.fifteen_yr__c 			= mlaDataObjectsResultsFinal.result_mortgage_lien_all[j]?.fifteen_yr;
            propMortLienall.fips__c 				= mlaDataObjectsResultsFinal.result_mortgage_lien_all[j]?.fips;
            propMortLienall.grantee_1__c 			= mlaDataObjectsResultsFinal.result_mortgage_lien_all[j]?.grantee_1;
            propMortLienall.grantee_1_forenames__c 	= mlaDataObjectsResultsFinal.result_mortgage_lien_all[j]?.grantee_1_forenames;
            propMortLienall.grantee_2__c 			= mlaDataObjectsResultsFinal.result_mortgage_lien_all[j]?.grantee_2;
            propMortLienall.grantee_2_forenames__c 	= mlaDataObjectsResultsFinal.result_mortgage_lien_all[j]?.grantee_2_forenames;
            propMortLienall.grantor_1__c 			= mlaDataObjectsResultsFinal.result_mortgage_lien_all[j]?.grantor_1;
            propMortLienall.grantor_2__c 			= mlaDataObjectsResultsFinal.result_mortgage_lien_all[j]?.grantor_2;
            propMortLienall.hc_interest_rate__c 	= mlaDataObjectsResultsFinal.result_mortgage_lien_all[j]?.hc_interest_rate;
            propMortLienall.heloc__c 				= mlaDataObjectsResultsFinal.result_mortgage_lien_all[j]?.heloc;
            propMortLienall.interest_rate__c 		= mlaDataObjectsResultsFinal.result_mortgage_lien_all[j]?.interest_rate;
            propMortLienall.lender_type__c 			= mlaDataObjectsResultsFinal.result_mortgage_lien_all[j]?.lender_type;
            propMortLienall.lien_type__c 			= mlaDataObjectsResultsFinal.result_mortgage_lien_all[j]?.lien_type;
            propMortLienall.mortgage_years__c 		= mlaDataObjectsResultsFinal.result_mortgage_lien_all[j]?.mortgage_years;
            propMortLienall.record_book__c 			= mlaDataObjectsResultsFinal.result_mortgage_lien_all[j]?.record_book;
			if (mlaDataObjectsResultsFinal.result_mortgage_lien_all[j]?.record_date != Null)                
            propMortLienall.record_date__c 			= date.valueOf(mlaDataObjectsResultsFinal.result_mortgage_lien_all[j]?.record_date);
            propMortLienall.record_doc__c 			= mlaDataObjectsResultsFinal.result_mortgage_lien_all[j]?.record_doc;
            propMortLienall.record_page__c 			= mlaDataObjectsResultsFinal.result_mortgage_lien_all[j]?.record_page;
            propMortLienall.stand_alone_refi__c 	= mlaDataObjectsResultsFinal.result_mortgage_lien_all[j]?.stand_alone_refi;
            propMortLienall.thirty_yr__c 			= mlaDataObjectsResultsFinal.result_mortgage_lien_all[j]?.thirty_yr;
            avm.Mortgage_Lien_Data_Present__c		= true;
            propMortLienallList.add(propMortLienall);
           }
           }

///////////////           
           If (shDataObjectsResultsFinal?.api_code  == 0)
           {
                
            for (Integer k = 0;k < shDataObjectsResultsFinal.result_sales_history?.size();k++ )
            {
            if (k == 0) 
            {
             props[i].AVM_Last_Sale_Price__c 	= shDataObjectsResultsFinal.result_sales_history[k]?.amount;
             props[i].AVM_Last_Sale_Date__c 	= date.valueOf(shDataObjectsResultsFinal.result_sales_history[k]?.record_date);
             avm.AVM_Last_Sale_Price__c			= shDataObjectsResultsFinal.result_sales_history[k]?.amount;
             avm.AVM_Last_Sale_Date__c			= date.valueOf(shDataObjectsResultsFinal.result_sales_history[k]?.record_date);
             avm.Sale_History_Data_Present__c	= true;
            }   
            Property_Sales_history__c propSalesHistory	= new Property_Sales_history__c();                 
            propSalesHistory.RelatedProperty__c 	= props[i].Id;  
            propSalesHistory.amount__c 				= shDataObjectsResultsFinal.result_sales_history[k]?.amount;
            propSalesHistory.apn__c 				= shDataObjectsResultsFinal.result_sales_history[k]?.apn;
            propSalesHistory.event_type__c 			= shDataObjectsResultsFinal.result_sales_history[k]?.event_type;
            propSalesHistory.fips__c 				= shDataObjectsResultsFinal.result_sales_history[k]?.fips;
            propSalesHistory.grantee_1_forenames__c = shDataObjectsResultsFinal.result_sales_history[k]?.grantee_1_forenames;
            propSalesHistory.grantee_2_forenames__c = shDataObjectsResultsFinal.result_sales_history[k]?.grantee_2_forenames;
            propSalesHistory.grantee_1__c 			= shDataObjectsResultsFinal.result_sales_history[k]?.grantee_1;
            propSalesHistory.grantee_2__c 			= shDataObjectsResultsFinal.result_sales_history[k]?.grantee_2;
            propSalesHistory.grantor_1__c 			= shDataObjectsResultsFinal.result_sales_history[k]?.grantor_1;
            propSalesHistory.grantor_2__c 			= shDataObjectsResultsFinal.result_sales_history[k]?.grantor_2;
            propSalesHistory.record_book__c 		= shDataObjectsResultsFinal.result_sales_history[k]?.record_book;
			if (shDataObjectsResultsFinal.result_sales_history[k]?.record_date != Null)                 
            propSalesHistory.record_date__c 		= date.valueOf(shDataObjectsResultsFinal.result_sales_history[k]?.record_date);
            propSalesHistory.record_doc__c 			= shDataObjectsResultsFinal.result_sales_history[k]?.record_doc;
            propSalesHistory.record_page__c 		= shDataObjectsResultsFinal.result_sales_history[k]?.record_page;
            propSalesHistoryList.add(propSalesHistory);
             }
           }
///////////////           
           If (fldDataObjectsResultsFinal?.api_code == 0)
           {
            validResponseAVM = True;
			if (fldDataObjectsResultsFinal.result_flood?.effective_date != Null)                
            avm.effective_date__c 	=  date.valueOf(fldDataObjectsResultsFinal.result_flood?.effective_date);
            if (fldDataObjectsResultsFinal.result_flood?.flood_risk != null)               
			avm.flood_risk__c 		= fldDataObjectsResultsFinal.result_flood?.flood_risk;
            if (fldDataObjectsResultsFinal.result_flood?.zone != null)                
			avm.zone__c 			= fldDataObjectsResultsFinal.result_flood?.zone;
            if (fldDataObjectsResultsFinal.result_flood?.panel_number != null)                 
			avm.panel_number__c 	= fldDataObjectsResultsFinal.result_flood?.panel_number;                  
           }
//////////////           
           If (bcDataObjectsResultsFinal?.api_code == 0)
           {
            validResponseAVM = True;   
            if (bcDataObjectsResultsFinal.result_block_crime?.all.incidents != null)               
            avm.all_incidents__c 				= bcDataObjectsResultsFinal.result_block_crime?.all.incidents;
            if (bcDataObjectsResultsFinal.result_block_crime?.all.county_percentile != null)                
            avm.all_county_percentile__c 		= bcDataObjectsResultsFinal.result_block_crime?.all.county_percentile;
            if (bcDataObjectsResultsFinal.result_block_crime?.all.nation_percentile != null)                
            avm.all_nation_percentile__c 		= bcDataObjectsResultsFinal.result_block_crime?.all.nation_percentile;
            if (bcDataObjectsResultsFinal.result_block_crime?.property.incidents != null)                
            avm.property_incidents__c 			= bcDataObjectsResultsFinal.result_block_crime?.property.incidents;
            if (bcDataObjectsResultsFinal.result_block_crime?.property.county_percentile != null)                 
            avm.property_county_percentile__c 	= bcDataObjectsResultsFinal.result_block_crime?.property.county_percentile;
            if (bcDataObjectsResultsFinal.result_block_crime?.property.nation_percentile != null)                
            avm.property_nation_percentile__c 	= bcDataObjectsResultsFinal.result_block_crime?.property.nation_percentile;
            if (bcDataObjectsResultsFinal.result_block_crime?.violent.incidents != null)                
            avm.violent_incidents__c 			= bcDataObjectsResultsFinal.result_block_crime?.violent.incidents;
            if (bcDataObjectsResultsFinal.result_block_crime?.violent.county_percentile != null)                
            avm.violent_county_percentile__c 	= bcDataObjectsResultsFinal.result_block_crime.violent?.county_percentile;
            if (bcDataObjectsResultsFinal.result_block_crime?.violent.nation_percentile != null)               
            avm.violent_nation_percentile__c 	= bcDataObjectsResultsFinal.result_block_crime?.violent.nation_percentile;
            if (bcDataObjectsResultsFinal.result_block_crime?.other.incidents != null)               
            avm.other_incidents__c 				= bcDataObjectsResultsFinal.result_block_crime?.other.incidents;
            if (bcDataObjectsResultsFinal.result_block_crime?.other.county_percentile != null)                 
            avm.other_county_percentile__c 		= bcDataObjectsResultsFinal.result_block_crime?.other.county_percentile;
            if (bcDataObjectsResultsFinal.result_block_crime?.other.nation_percentile != null)                
            avm.other_nation_percentail__c 		= bcDataObjectsResultsFinal.result_block_crime?.other.nation_percentile;
			avm.Block_Crime_Data_Present__c	= True;              
           }
///////////           
           If (thDataObjectsResultsFinal?.api_code == 0) 
           { 
            validResponseAVM = True; 
            for (Integer j=0;j<thDataObjectsResultsFinal.result_tax_history.size();j++)
            {      
            Property_Tax_History__c propTaxHistory = new Property_Tax_History__c();
            if (j == 0)
            {
            if (thDataObjectsResultsFinal.result_tax_history[j]?.apn != null)
            {
            avm.Tax_History_APN__c 					= thDataObjectsResultsFinal.result_tax_history[j]?.apn;
            avm.Tax_History_Data_Present__c			= true;
			}
            if (thDataObjectsResultsFinal.result_tax_history[j]?.assessment_year != null)                
            avm.Tax_History_assessment_year__c 		= thDataObjectsResultsFinal.result_tax_history[j]?.assessment_year;
            if (thDataObjectsResultsFinal.result_tax_history[j]?.tax_amount != null)                
            avm.Tax_History_Tax_Amount__c 			= thDataObjectsResultsFinal.result_tax_history[j]?.tax_amount;
            if (thDataObjectsResultsFinal.result_tax_history[j]?.tax_year != null)                 
            avm.Tax_History_Tax_Year__c 			= thDataObjectsResultsFinal.result_tax_history[j]?.tax_year;
            if (thDataObjectsResultsFinal.result_tax_history[j]?.total_assessed_value != null)                
            avm.Tax_History_Total_Assessed_Value__c = thDataObjectsResultsFinal.result_tax_history[j]?.total_assessed_value;
            }
            propTaxHistory.RelatedProperty__c 	= props[i].Id;                  
            if (thDataObjectsResultsFinal.result_tax_history[j]?.apn != null)      
			propTaxHistory.apn__c     				= thDataObjectsResultsFinal.result_tax_history[j]?.apn;                 
            if (thDataObjectsResultsFinal.result_tax_history[j]?.assessment_year != null)                
            propTaxHistory.assessment_year__c 		= thDataObjectsResultsFinal.result_tax_history[j]?.assessment_year;
            if (thDataObjectsResultsFinal.result_tax_history[j]?.tax_amount != null)                
            propTaxHistory.tax_amount__c 			= thDataObjectsResultsFinal.result_tax_history[j]?.tax_amount;
            if (thDataObjectsResultsFinal.result_tax_history[j]?.tax_year != null)                 
            propTaxHistory.tax_year__c 			= thDataObjectsResultsFinal.result_tax_history[j]?.tax_year;
            if (thDataObjectsResultsFinal.result_tax_history[j]?.total_assessed_value != null)                
            propTaxHistory.total_assessed_value__c = thDataObjectsResultsFinal.result_tax_history[j]?.total_assessed_value;                
            propTaxHistoryList.add(propTaxHistory);
           }
           }
///////////////           
		 if (validResponseAVM)
         {
            //avm.AVM_Provider__c = 'HouseCanary';
            avm.recordtypeid = [SELECT Id FROM RecordType WHERE sobjecttype = 'Property_AVM__c' and DeveloperName  = 'HouseCanary_Rental_AVM'].Id;
			if(props[i].Property_AVMs__r.size()>0)
            {
            avm.Id = props[i].Property_AVMs__r[0].Id; //raj
        	} 
            else
            {
			avm.RelatedProperty__c = props[i].Id;
			}
            avmList.add(avm);
       	}
    	} //for
        } // else valueReportOnly
        if (avmList.size() > 0)
        {
	//	Database.insert(avmList,false);
		upsert avmList;
        }    
        if (propSalesHistoryList.size() > 0)
        {        
        Insert propSalesHistoryList;
        }
        
        if (propMortLienallList.size() > 0)
        {        
        Insert propMortLienallList;
        }
        if (propTaxHistoryList.size() > 0)
        {        
        Insert propTaxHistoryList;
        }        
        
        if (props.size() > 0)
        {
          update props;  
        }
	/*	for (Integer i=0;i<props.size();i++)     
        {
            for (Integer j=0;j<avmList.size();j++)
            {
              if (avmList[j].RelatedProperty__c == props[i].id)
              {
			  HouseCanaryForReporting__c HCRepo1 = new HouseCanaryForReporting__c();                   
			  HCRepo1.RelatedProperty__c = props[i].id;                  
              HCRepo1.Property_AVM__c = avmList[j].id;  
              HCReportingList.add(HCRepo1);
              }
            }
            for (Integer k=0;k<propSalesHistoryList.size();k++)
            {
			  if (propSalesHistoryList[k].RelatedProperty__c == props[i].id)
              {
			  HouseCanaryForReporting__c HCRepo2 = new HouseCanaryForReporting__c();                     
			  HCRepo2.RelatedProperty__c = props[i].id;                  
              HCRepo2.Property_Sales_history__c = propSalesHistoryList[k].id;  
              HCReportingList.add(HCRepo2);
              }
            }   
            for (Integer l=0;l<propMortLienallList.size();l++)
            {
			  if (propMortLienallList[l].RelatedProperty__c == props[i].id)
              {  
			  HouseCanaryForReporting__c HCRepo3 = new HouseCanaryForReporting__c();                    
			  HCRepo3.RelatedProperty__c = props[i].id;                  
              HCRepo3.Property_Mortgage_lien_all__c = propMortLienallList[l].id;  
              HCReportingList.add(HCRepo3);
              }
            }               
        }
        if (HCReportingList.size() > 0)
        {
            Insert HCReportingList;
        }*/
  } //insertPropertyAVM
}