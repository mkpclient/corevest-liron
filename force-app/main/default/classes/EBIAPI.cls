public class EBIAPI {

   public static string submitOrder(
    List<Property__c> listProperties,
    String comments,
    Boolean rushOrder,
    List<Appraisal__c> listAppraisal
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
      
    Map<String, String> reqBody = new Map<String, String>();
    String bodyString = '[';
    for (Property__c property : listProperties)
    {
	string 	account_id = AccountT;
    //account_id = AccountC;
	reqBody.put('account_id',account_id);   
    reqBody.put('zip', property.ZipCode__c);      
   // reqBody.put('construction_date', null); 
	reqBody.put('rush order', rushOrder ? 'True' : 'False');      
    reqBody.put('number_of_tenants', '1');      
    reqBody.put('rentable_square_footage', String.Valueof(property.Square_Feet_value__c));      
    reqBody.put('year_built', property.Year_Built__c);       
    reqBody.put('address', property.Name);
    reqBody.put('city', property.City__c);
    reqBody.put('state', property.State__c);
   // reqBody.put('county', property.County__c);
   // reqBody.put('transaction_manager_email','?????');
	reqBody.put('site_contact_number', property.Interior_Access_POC_Phone__c);
	reqBody.put('site_contact_email', property.Interior_Access_POC_Email__c);
	reqBody.put('site_contact', property.Interior_Access_POC__c);
	reqBody.put('seller_name', Null);
    String property_type = 'Other';      
    reqBody.put('property_type', property_type); 
    String project_type = 'Other'; 
    reqBody.put('project_type', project_type);         
	String project_scope = '["ESA AAI-ASTM2021", "PCS", "Zoning Report",  "RDNSMP" ]';
	//project_scope = '[{"name":"CMR", "quantity":"1",  "number_of_services": "6"},{"name":"CPCR", "quantity":"1"}]';     
	project_scope = '["ESA AAI-ASTM2013", "PCS" ]';
    reqBody.put('project_scope', project_scope); 
    reqBody.put('order_number', property.Deal__r.Deal_Loan_Number__c);       
    reqBody.put('order_owner_email', UserInfo.getUserEmail());
    reqBody.put('order_owner_name', UserInfo.getFirstName() + ' ' + UserInfo.getLastName());
    reqBody.put('b2b_opportunity_owner_email', UserInfo.getUserEmail());
   // reqBody.put('operations_manager_email', property.Deal__r.Deal_Loan_Number__c);
    reqBody.put('notes', comments);
    reqBody.put('asset_due_diligence_folder', comments);
    reqBody.put('name', 'RK_QA B2B Holiday skip 0330022 01');
    reqBody.put('external_object_id', listAppraisal[0].id);
    reqBody.put('delivery_request', '15');  
	String generatedBody = generateBody(reqBody);   
    System.debug('RS999 generatedBody : ' +generatedBody);        
    bodyString += generatedBody + ',';
	}
            
    bodyString = bodyString.removeEnd(',');      
    bodyString += ']';
    String generatedBody  = base64URLencode(Blob.valueOf(bodyString));
    System.debug('RS999 bodyString : ' +bodyString);     
      
    Map<String, String> reqHeader = new Map<String, String>();
    reqHeader.put('alg', 'HS256'); 
	reqHeader.put('typ', 'JWT');   
    //reqHeader.put('Content-Type','application/json');
	String generatedHeader = generateBody(reqHeader); 
    generatedHeader = base64URLencode(Blob.valueOf(generatedHeader));
    String encodedString = generatedHeader + '.' + generatedBody;
	Blob hash = Crypto.generateMac('HmacSHA256', Blob.valueOf(bodyString),blob.valueof(APIKeyT));
    encodedString += '.' + base64URLencode(hash); 
    encodedString = '{"jwtString":"' + encodedString + '"}'; 
    System.debug('RS999 encodedString : ' +encodedString); 
    callout(encodedString,EndPoint);     
    return 'sucess';
  }

@future(callout = true)
public static void callout(string encodedString,String EndPoint)
{
	System.debug('RS999 EndPoint : ' +EndPoint);
	System.debug('RS999 encodedString : ' +encodedString);    
    HttpRequest req = new HttpRequest();
    req.setEndpoint(EndPoint);
    req.setMethod('POST');      
    req.setTimeout(120000);
    req.setHeader('alg', 'HS256');
	req.setHeader('typ', 'JWT');   
    req.setHeader('Content-Type','application/json');
    req.setBody(encodedString); //(body);
   // String body = '{"success":true,"appraisal_id":7967,"sequence_number":"1", "file_number":"xyz293", "loan_number":"LN12345678"}';
    if (!Test.isRunningTest()) 
    {
     HttpResponse resp = new Http().send(req);
     String retBody = resp.getBody();
     System.debug('RS999 retBody : ' +retBody);  
    }
 
   /* Map<String, Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(
      body
    );
    if (!(Boolean) respMap.get('success')) {
      system.debug((String) respMap.get('error_code'));
      system.debug((String) respMap.get('error_msg'));
      throw new AuraHandledException(
        'Error: ' +
        (String) respMap.get('error_code') +
        ' ' +
        (String) respMap.get('error_msg')
      );
    }*/    
}
    
public static string generateBody(
    Map<String, String> reqMap
  ) {
      String body = '{';
    for (String key : reqMap.keySet()) {
      if (key == 'project_scope' || key == 'delivery_request' || key == 'year_built' || key == 'number_of_tenants')
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
	//String output = base64URLencode(Blob.valueOf(body));      
    //System.debug('RS999 output(base64Encode) :' +output);
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