public class EBIAPI {

   public static string submitOrder(
    List<Property__c> listProperties,
    String comments,
    Boolean rushOrder,
    List<Appraisal__c> listAppraisal,
    Map<String,String> mapEBIData
  ) {

   EBI_API_Setting__c apiSettings = EBI_API_Setting__c.getInstance();
   String EndPoint = apiSettings.EBI_EndPoint__c;
   String APIKeyT = apiSettings.EBI_API_KeyT__c;
   String APIKeyC = apiSettings.EBI_API_KeyC__c;
   String AccountT = apiSettings.EBI_AccountT__c;
   String AccountC = apiSettings.EBI_AccountC__c; 

    System.debug('RS999 APIKeyT :' +APIKeyT);      
	System.debug('RS999 APIKeyC :' +APIKeyC);      
	System.debug('RS999 AccountT :' +AccountT);      
	System.debug('RS999 AccountC :' +AccountC); 
	System.debug('RS999 EndPoint :' +EndPoint);       
      
    System.Debug('RS999 listProperties :' +listProperties) ;
      
    Map<String, String> reqBody = new Map<String, String>();
    String bodyString = '[';
    for (Property__c property : listProperties)
    {
	string 	account_id = AccountT;
	reqBody.put('account_id',account_id);   
    reqBody.put('address', (property.Name== null ? '' :property.Name));
    reqBody.put('city', (property.City__c== null ? '' :property.City__c));
    reqBody.put('state', (property.State_Full__c== null ? '' :property.State_Full__c));        
    reqBody.put('zip', property.ZipCode__c);      
	reqBody.put('rush order', rushOrder ? 'True' : 'False');   
	reqBody.put('site_contact_number', (property.Interior_Access_POC_Phone__c== null ? '' :property.Interior_Access_POC_Phone__c.replace('+1','')));
	reqBody.put('site_contact_email', (property.Interior_Access_POC_Email__c== null ? '' :property.Interior_Access_POC_Email__c));
	reqBody.put('site_contact', (property.Interior_Access_POC__c == null ? '' :property.Interior_Access_POC__c));        
    String property_type = 'Other';      
    reqBody.put('property_type', property_type); 
    String project_type = 'Other'; 
    reqBody.put('project_type', project_type);         
	String project_scope = '["ESA AAI-ASTM2021","PCS","Zoning Report","RDNSMP"]';
	//project_scope = '["ESA AAI-ASTM2013", "PCS" ]';
	//project_scope = '["ESA AAI-ASTM2021", "PCS" ]';
    reqBody.put('project_scope', project_scope); 
    reqBody.put('order_number', property.Deal__r.Deal_Loan_Number__c);       
    reqBody.put('order_owner_email', UserInfo.getUserEmail());
    reqBody.put('order_owner_name', UserInfo.getFirstName() + ' ' + UserInfo.getLastName());
    reqBody.put('b2b_opportunity_owner_email', UserInfo.getUserEmail());
    reqBody.put('name', 'RK_QA B2B Holiday skip 0330022 01');   
    String eBIId = mapEBIData.get(property.id);
    reqBody.put('external_object_id',eBIId);
	reqBody.put('parent_external_id',property.Deal__c);       
    reqBody.put('delivery_request', '15');
	reqBody.put('number_of_tenants', '1');  
    if (property.Square_Feet_value__c != null ) reqBody.put('rentable_square_footage', String.Valueof(property.Square_Feet_value__c));  
	if (property.Year_Built__c != null ) reqBody.put('year_built', property.Year_Built__c); 
	reqBody.put('seller_name', '');          
    reqBody.put('notes', comments);
  //  reqBody.put('asset_due_diligence_folder', comments);
	String generatedBody = generateBody(reqBody);   
    System.debug('RS999 generatedBody : ' +generatedBody);        
    bodyString += generatedBody + ',';
	}
    bodyString = bodyString.removeEnd(',');      
    bodyString += ']';
   // bodyString  = '[{"account_id":"0011R00002V5CJfQAN","zip":"07501","rush order":"True","number_of_tenants":"1","rentable_square_footage":"14777.00","year_built":2022,"address":"225-227 and 229 Graham Avenue","city":"Paterson","state":"","site_contact_number":"","site_contact_email":"","site_contact":"","seller_name":"","property_type":"Other","project_type":"Other","project_scope":["ESA AAI-ASTM2013", "PCS" ],"order_number":"41123","order_owner_email":"raj.sirivolu@cvest.com","order_owner_name":"Raj Sirivolu","b2b_opportunity_owner_email":"raj.sirivolu@cvest.com","notes":"ebi test","asset_due_diligence_folder":"ebi test","name":"RK_QA B2B Holiday skip 0330022 01","external_object_id":"a0J8B0000002KSYUA2","delivery_request":15}]';
    String generatedBody  = base64URLencode(Blob.valueOf(bodyString));
    System.debug('RS999 bodyString : ' +bodyString);     
    Map<String, String> reqHeader = new Map<String, String>();
    reqHeader.put('alg', 'HS256'); 
	reqHeader.put('typ', 'JWT');   
	String generatedHeader = generateBody(reqHeader); 
    generatedHeader = base64URLencode(Blob.valueOf(generatedHeader));
    String encodedString = generatedHeader + '.' + generatedBody;
	Blob hash = Crypto.generateMac('HmacSHA256', Blob.valueOf(encodedString),blob.valueof(APIKeyT));
    encodedString += '.' + base64URLencode(hash); 
    encodedString = '{"jwtString":"' + encodedString + '"}'; 
    System.debug('RS999 encodedString : ' +encodedString); 
    callout(encodedString,EndPoint);     
    return 'sucess';
  }

@future(callout = true)
public static void callout(string encodedString,String EndPoint)
{
    HttpRequest req = new HttpRequest();
	System.debug('RS999 EndPoint : ' +EndPoint);
	System.debug('RS999 encodedString : ' +encodedString);    
    req.setEndpoint(EndPoint);
    req.setMethod('POST');      
    req.setTimeout(120000);
    req.setHeader('alg', 'HS256');
	req.setHeader('typ', 'JWT');   
    req.setHeader('Content-Type','application/json');
    //encodedString = '{"jwtString":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.W3siYWNjb3VudF9pZCI6IjAwMTFSMDAwMDJWNUNKZlFBTiIsInppcCI6IjA3NTAxIiwicnVzaCBvcmRlciI6IlRydWUiLCJudW1iZXJfb2ZfdGVuYW50cyI6IjEiLCJyZW50YWJsZV9zcXVhcmVfZm9vdGFnZSI6IjE0Nzc3LjAwIiwieWVhcl9idWlsdCI6MjAyMiwiYWRkcmVzcyI6IjIyNS0yMjcgYW5kIDIyOSBHcmFoYW0gQXZlbnVlIiwiY2l0eSI6IlBhdGVyc29uIiwic3RhdGUiOiIiLCJzaXRlX2NvbnRhY3RfbnVtYmVyIjoiIiwic2l0ZV9jb250YWN0X2VtYWlsIjoiIiwic2l0ZV9jb250YWN0IjoiIiwic2VsbGVyX25hbWUiOiIiLCJwcm9wZXJ0eV90eXBlIjoiT3RoZXIiLCJwcm9qZWN0X3R5cGUiOiJPdGhlciIsInByb2plY3Rfc2NvcGUiOlsiRVNBIEFBSS1BU1RNMjAxMyIsIlBDUyJdLCJvcmRlcl9udW1iZXIiOiI0MTEyMyIsIm9yZGVyX293bmVyX2VtYWlsIjoicmFqLnNpcml2b2x1QGN2ZXN0LmNvbSIsIm9yZGVyX293bmVyX25hbWUiOiJSYWogU2lyaXZvbHUiLCJiMmJfb3Bwb3J0dW5pdHlfb3duZXJfZW1haWwiOiJyYWouc2lyaXZvbHVAY3Zlc3QuY29tIiwibm90ZXMiOiJlYmkgdGVzdCIsImFzc2V0X2R1ZV9kaWxpZ2VuY2VfZm9sZGVyIjoiZWJpIHRlc3QiLCJuYW1lIjoiUktfUUEgQjJCIEhvbGlkYXkgc2tpcCAwMzMwMDIyIDAxIiwiZXh0ZXJuYWxfb2JqZWN0X2lkIjoiYTBKOEIwMDAwMDAyS1NZVUEyIiwiZGVsaXZlcnlfcmVxdWVzdCI6MTV9XQ.galQHvUVfXu8bCcumSZZwnpqBoDN4HNolb6hDXMny3s"}';
    req.setBody(encodedString); //(body);
   // String body = '{"success":true,"appraisal_id":7967,"sequence_number":"1", "file_number":"xyz293", "loan_number":"LN12345678"}';
    if (!Test.isRunningTest()) 
    {
     HttpResponse resp = new Http().send(req);
     String retBody = resp.getBody();
     System.debug('RS999 retBody : ' +retBody);  
    }
}
    
public static string generateBody(
    Map<String, String> reqMap
  ) {
      String body = '{';
    for (String key : reqMap.keySet()) {
      if (key == 'project_scope' || key == 'delivery_request' || key == 'year_built' )
      {
       body += '"' + key + '"'  + ':' + reqMap.get(key) +',' ;   
      }
      Else
      {
      body += '"' + key + '"'  + ':' + '"' + reqMap.get(key) +'",' ;
      }
    }
      body = body.removeEnd(',') + '}';
      
    System.debug('RS999 body :' +body);
    return body;
  }

public static String base64URLencode(Blob input){ 
    String output = encodingUtil.base64Encode(input);
    output = output.replace('+', '-');
    output = output.replace('/', '_');
    while ( output.endsWith('=')){
        output = output.subString(0,output.length()-1);
    }
    return output;
}    
 
} //class