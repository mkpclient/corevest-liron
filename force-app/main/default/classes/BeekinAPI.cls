public without sharing class BeekinAPI {
    public static Beekin_Settings__c BeekinSettings = Beekin_Settings__c.getInstance();
    static String BASE_URL = BeekinSettings.Endpoint__c;
    static String ACCESS_TOKEN = BeekinSettings.APIKey__c;
    static Boolean RETRIED_AUTH = False;
	public static List<Settings__mdt> settings = [ SELECT Enable_Beekin_API_Response_Logging__c,Enable_Beekin_API_Error_Response_Logging__c 
                                     FROM Settings__mdt  WHERE DeveloperName = 'Universal_Settings' Limit 1 ];  
    @auraEnabled
    public static Map<String, Object> getProperties(Id recordId) {
        Map<String, Object> response = new Map<String, Object>();
        
        List<Property__c> properties = [SELECT Id, Name, City__c, State__c, ZipCode__c, Status__c, Number_of_Beds__c, Number_of_Bath__c
                                        , Square_Feet__c, Year_Built__c, Pool__c, Property_Type__c, Invalid_Address__c,Monthly_Rent__c,//Estimated_Rent__c,Estimated_Min_Rent__c,Estimated_Max_Rent__c,
											(SELECT AVM_Address__c,Estimated_Rent__c,Estimated_Min_Rent__c,Estimated_Max_Rent__c
											 FROM Property_AVMs__r where recordtypeid in (SELECT Id FROM RecordType WHERE sobjecttype = 'Property_AVM__c' 
                                                                                        and DeveloperName  = 'Beekin_Rental_AVM') order by CreatedDate desc Limit 1)
                                        FROM Property__c
                                        WHERE Deal__r.StageName IN ('Data Tape Received' , 'Term Sheet Issued' , 'Term Sheet Signed/Deposit Collected' 
                                                                    , 'Submitted to Underwriting' , 'Underwriting' , 'UW Hold' , 'Approved by Committee')
                                            AND Property__c.Deal__c = :recordId AND Status__c NOT IN ('Inactive','Cancelled','Rescinded')
                                        	AND Property__c.ZipCode__c != null AND 
                                            Property__c.Property_Type__c IN ('SFR' , 'Condo','Townhome','2-4 Unit','Multifamily')
                                            AND Property__c.Is_Parent__c = False AND deal__r.RecordType__c = 'Term' ORDER BY Property_Name__c];
      response.put('properties', properties);
      return response;
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

    Public class AveResDataMsg {
        AveResData Response;
        String Message;
        String Code;
    }
    
    public class AveResData {
        String address;
        Integer estimated_rent;
        geolocation geolocation;
        Integer lower;
        Integer upper;
        }
    
    public class geolocation {
        double lat;
        double lng;
    }    

    public static void throwError(String errorMsg) {
        AuraHandledException ex = new AuraHandledException(errorMsg);
        ex.setMessage(errorMsg);
        throw ex;
    }

    //Called from property insert trigger
    //@future(callout=true)
    @auraEnabled
 	public static Void callBeekin(List<Property__c> property) 
    {
	If (property.Size() > 0)                                             
	{
	 List<Settings__mdt> settings = [ SELECT Enable_Beekin_API_Response_Logging__c,Enable_Beekin_API_Error_Response_Logging__c 
                                     FROM Settings__mdt  WHERE DeveloperName = 'Universal_Settings' ];     
     List<AveResDataMsg> ResponseDataMsg = New List<AveResDataMsg>();      
     for (Property__c prop : property)
        {
        ResponseDataMsg.add(getAveData(prop));
        }
     
	 populatePropertyWithFields(property, ResponseDataMsg); 	         
    }
    }
/////////////////////////////
    @auraEnabled
    public static Map<String, Object> callBeekinSingle(Property__c property, Id recordId) 
    {
       List<AveResDataMsg> ResponseDataMsg = New List<AveResDataMsg>();
       List<Property__c> prop = new List<property__C>();
       prop.add(property);
       ResponseDataMsg.add(getAveData(property));
       if (ResponseDataMsg[0].Message.substring(0,5) !='Error')
       {
         populatePropertyWithFields(prop, ResponseDataMsg);  
       }
       Else
       {
           throw new AuraHandledException(ResponseDataMsg[0].Message);
          // throw new Error(ResponseDataMsg[0].Message);
       }
       return getProperties(recordId);
    }
///////////////////
  public static AveResDataMsg getAveData(Property__c prop) 
  {
        Map<String, String> parameters;
        Map<String, String> headers;
        String endpoint;
        String method;
        String body;
        String rawJSON;
        AveResData Response;

        AveResDataMsg ResponseDataMsg = New AveResDataMsg();
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
             when 'Townhome' {
                 propertytype = '0';
             }
             when 'SFR' {
                 propertytype = '1';
             }
             when 'Multifamily' {
                 propertytype = '2';
             }
             when '2-4 Unit' {
                 propertytype = '2';
             }             
             when 'Condo' {
                 propertytype = '3';
             }             
        }

        headers = new Map<String, String>();
        headers.put('x-api-key', ACCESS_TOKEN);
        headers.put('Content-Type', 'application/json');
      
        String parameter = '';
      
      	if (prop.City__c == Null || prop.State__c == Null || prop.ZipCode__c == Null || sqft == null || noofbeds == null || noofbath == null || propertytype == null)
        {
           		ResponseDataMsg.Message = 'Error - You have selected a Property that is missing City, State, Zip, Bed Count, Bath Count and/or Square Feet. These fields are required to run Beekin Rent Analysis' ;
        		ResponseDataMsg.Code = '-1'; 
        }
        Else
        {
        if (prop.Name != null)
        {
         String address = prop.Name + ',' + prop.City__c + ','+ prop.State__c + ' ' + prop.ZipCode__c;
         parameter = '?address='+ EncodingUtil.urlEncode(address, 'UTF-8');
        }
    
        if (sqft != null)
        {
        parameter = parameter + '&sqft=' + EncodingUtil.urlEncode(sqft, 'UTF-8');
        }
      
        if (noofbeds != null)
        {
        parameter = parameter + '&beds=' + EncodingUtil.urlEncode(noofbeds, 'UTF-8');
        }
      
        if (noofbath != null)
        {
        parameter = parameter + '&baths=' + EncodingUtil.urlEncode(noofbath, 'UTF-8');
        } 
      
        if (propertytype != null)
        {
        parameter = parameter + '&property_type=' + EncodingUtil.urlEncode(propertytype, 'UTF-8');
        }
        endpoint = BASE_URL + '/rent-estimate' + parameter;
        method = 'GET';
      
       rawJSON = callOut(method, endpoint, headers,prop.id);
      
        if (rawJSON.Substring(0,5) != 'Error')
        {
        Response = (AveResData)JSON.deserialize(rawJSON, AveResData.class);
        ResponseDataMsg.Response = Response;
        ResponseDataMsg.Message ='Not in Error';
        ResponseDataMsg.Code = '0';
        }
       Else
       {
		ResponseDataMsg.Message = rawJSON;
        ResponseDataMsg.Code = '-1';
       }
       }
		return ResponseDataMsg;
     }
///////////////////////
    public static void populatePropertyWithFields(List<Property__c> props, List<AveResDataMsg> aveResponseMsg) 
    {
        List<Property_AVM__c> avmList = new List<Property_AVM__c>();
        List<Property__c> PropList = New List<Property__c>();
        
       for (Integer i=0;i<props.size();i++)
       {
        if (aveResponseMsg[i].Message.substring(0,5) !='Error')
        {
        Property_AVM__c avm=new Property_AVM__c();
        AveResData aveResponse = new AveResData();
        aveResponse = aveResponseMsg[i].Response;
           
        if(props[i].Property_AVMs__r.size()>0){
            avm.Id=props[i].Property_AVMs__r[0].Id;
        } else{
			avm.RelatedProperty__c=props[i].Id;
		}
        avm.recordtypeid = [SELECT Id FROM RecordType WHERE sobjecttype = 'Property_AVM__c' and DeveloperName  = 'Beekin_Rental_AVM'].Id;
        //avm.AVM_Provider__c = 'Beekin';
		avm.RelatedProperty__c = props[i].Id;
        avm.AVM_Address__c = aveResponse.address;
	    avm.Estimated_Max_Rent__c = aveResponse.upper ;
        avm.Estimated_Min_Rent__c =  aveResponse.lower;
        avm.Estimated_Rent__c =  aveResponse.estimated_rent; 
        avmList.add(avm);
       // props[i].Estimated_Max_Rent__c = aveResponse.upper ; //Commented updated to property fields
       // props[i].Estimated_Min_Rent__c =  aveResponse.lower;
       // props[i].Estimated_Rent__c =  aveResponse.estimated_rent; 
       // PropList.add(props[i]);
        } // != Error
        } //For

	if (avmList.size() > 0)
    {
        Database.Upsert(avmList,false);
       // Database.Update(PropList,false);        
    }
        
    }

public static String callOut(String method, String endpoint, Map<String, String> headers,id id) 
	{
    
   HttpResponse response = new HttpResponse();
   HttpRequest request = new httpRequest();
   request.setEndpoint(endpoint);
   request.setMethod(method);    
   request.setEndpoint(endpoint);
        if (headers != null) {
            for (String key : headers.keySet()) {
                request.setHeader(key, headers.get(key));
            }
        }

    request.setTimeout(60000);  
     response = new Http().send(request);
    try {

    if (response.getstatuscode() == 200)
      {
        System.CalloutException e = new System.CalloutException();
		if (settings[0].Enable_Beekin_API_Response_Logging__c == True && settings[0].Enable_Beekin_API_Error_Response_Logging__c == False)          
        {
         request.setBody('{"call":"Beekin Call"}');
         //System.enqueueJob(new APILoggerQueueable(request, response, id, e));     
		}            
        return response.getBody();
      }
    else
    {
        System.CalloutException e = new System.CalloutException();
        e.setMessage(response.getStatusCode() + ': ' + response.getStatus());
        String ErrorMessage = 'Error' + '**' + 'Beekin Status Code :' + response.getStatusCode() + '**' + 'Beekin Status Message :' + response.getStatus();        
		if (settings[0].Enable_Beekin_API_Response_Logging__c == True && settings[0].Enable_Beekin_API_Error_Response_Logging__c == True)          
        {        
        request.setBody('{"call":"Beekin Call"}');
        response.setBody('{"call":"Beekin Call in Error"}');
       // System.enqueueJob(new APILoggerQueueable(request, response, id, e));
        }
		return ErrorMessage;
    }
    }
    catch (Exception e) {
   // System.enqueueJob(new APILoggerQueueable(request, response, id, e));
     throw e;
    }
   }
 }