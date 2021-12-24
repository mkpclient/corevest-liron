public class pardot_Batchable implements Database.Batchable<sObject>, Database.AllowsCallouts {
	static final String NS_SOAP = 'http://schemas.xmlsoap.org/soap/envelope/';
	static final String NS_SF = 'urn:partner.soap.sforce.com';
	static final String orgId = userInfo.getOrganizationId().left(15);
	static final String orgUrl = 'https://na16.salesforce.com/services/Soap/u/9.0/';
	static final String username = 'serena.yang@colonyamericanfinance.com';
	static final String password = 'Colony0222';
	static final String DEFAULT_LEAD_QUERY = 'Select Id, Email from Lead where pi__url__c = null and Email != null';
	static final String DEFAULT_CONTACT_QUERY = 'Select Id, Email from Contact where pi__url__c = null and Email != null';
	String query;
	
	public pardot_Batchable(String queryString) {
		if ( String.isBlank(queryString) ){
			queryString = DEFAULT_LEAD_QUERY;
			if ( Test.isRunningTest() ){
				queryString += ' LIMIT 1';
			}
		}
		query = queryString;
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	public void execute(Database.BatchableContext BC, List<sObject> scope) {
		String sessionId = getSessionId();
		for ( sObject s : scope ){
			pushToPardot(sessionId, s.Id, (String)s.get('email') );
		}
	}
	
	public void finish(Database.BatchableContext BC) {
		
	}

	public static String getSessionId(){
		HttpRequest req = new HttpRequest();
		req.setMethod('POST');   
		req.setEndpoint('https://www.salesforce.com/services/Soap/u/29.0');
		req.setHeader('Content-Type', 'text/xml;charset=UTF-8');        
		req.setHeader('SOAPAction', '""');
		req.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' +username+ '</username><password>' + password + '</password></login></Body></Envelope>');
        HttpResponse res = new HttpResponse();
        if ( test.isRunningTest() ){
            res.setStatusCode(200);
            String responseString = '<?xml version="1.0" encoding="utf-8"?>';
            responseString += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="urn:partner.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
            responseString += '<soapenv:Body>';
            responseString += '<loginResponse>';
            responseString += '<result>';
            responseString += '<sessionId>QwWsHJyTPW.1pd0_jXlNKOSU</sessionId>';
            responseString += '</result>';
            responseString += '</loginResponse>';
            responseString += '</soapenv:Body>';
            responseString += '</soapenv:Envelope>';
            res.setBody(responseString);
        } else {
            res = new Http().send(req);
        }
        if(res.getStatusCode() != 200){
            Dom.Document responseDocument = res.getBodyDocument();
            Dom.Xmlnode rootElm = responseDocument.getRootElement(); // soapenv:Envelope
            Dom.Xmlnode bodyElm = rootElm.getChildElement('Body', NS_SOAP); // soapenv:Body 
            Dom.Xmlnode faultElm = bodyElm.getChildElement('Fault', NS_SOAP); // soapenv:Fault
            Dom.Xmlnode faultStringElm = faultElm.getChildElement('faultstring', null); // faultstring          
            throw new SalesforceLoginException(faultStringElm.getText()); 
        }
        Dom.Document responseDocument = res.getBodyDocument();
        Dom.Xmlnode rootElm = responseDocument.getRootElement(); // soapenv:Envelope
        Dom.Xmlnode bodyElm = rootElm.getChildElement('Body', NS_SOAP); // soapenv:Body 
        Dom.Xmlnode loginResponseElm = bodyElm.getChildElement('loginResponse', NS_SF); // loginResponse
        Dom.Xmlnode resultElm = loginResponseElm.getChildElement('result', NS_SF); // result
        Dom.Xmlnode sessionIdElm = resultElm.getChildElement('sessionId', NS_SF); // sessionId
        return sessionIdElm.getText();
	}

	public static void pushToPardot(String sessionId, Id contactId, String contactEmail){
	    PageReference p = new PageReference('https://pi.pardot.com/prospect/sync/email/'+encodingUtil.urlEncode(contactEmail, 'UTF-8'));
	    p.getParameters().put('contact_id',contactId);
	    p.getParameters().put('sessionid',sessionId);
	    p.getParameters().put('serverurl',orgUrl+orgId);
	    p.getParameters().put('redirect_location','https://na16.salesforce.com/'+contactId);
	    String endpoint = p.getUrl();
	    httpRequest req = new httprequest();
	    req.setMethod('GET');
	    req.setEndpoint(endpoint);
	    req.setHeader('Accept','text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8');
	    req.setHeader('Accept-Encoding','gzip, deflate, sdch');
	    req.setHeader('Accept-Language','en-US,en;q=0.8');
	    req.setHeader('Connection','keep-alive');
        HttpResponse res = new HttpResponse();
        res.setStatusCode(302);
        res.setBody('Success');
        if ( !Test.isRunningTest() ){
	        res = new http().send(req);
        }
	    if ( res.getStatusCode() != 302 ){
	        throw new PardotPushException(res.getBody());
	    }
	}
    public class SalesforceLoginException extends Exception {}  
    public class PardotPushException extends Exception {}  
}