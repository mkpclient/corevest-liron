@RestResource(urlMapping='/presOld/*')
global class preciseRE_API {

	global preciseRE_API() {

	}

	//public static final String username = IntegrationSetting__c.getInstance( 'PRECISERE_USERNAME' ).Value__c;
	//public static final String password = IntegrationSetting__c.getInstance( 'PRECISERE_PASSWORD' ).Value__c;
	//public static final String logsEnabled = IntegrationSetting__c.getInstance( 'ENABLE_LOGGING' ).Value__c;
	//public static final String authToken = 'Basic ' + encodingUtil.base64Encode( blob.valueOf( username + ':' + password ) ); 
	//public static final String preciseEndpoint = IntegrationSetting__c.getInstance( 'PRECISERE_ENDPOINT' ).Value__c;

	///**	
 //   * @description Method to receive data from Precise RE
 //   */
	@HttpPost
	global static SObject preciseRE() {
		return null;
	}
	//	// Get body from POST request
	//	RestRequest request = RestContext.request;
	//	System.Debug(request);
	//	String body = EncodingUtil.base64Decode( EncodingUtil.base64Encode( request.requestBody ) ).toString();
	//	System.Debug(body);
	//	// Create map of body
	//	Map<String, Object> bodyWrapper = (Map<String, Object>)JSON.deserializeUntyped( body );

	//	// Initialize update list
	//	List<SObject> recordUpdates = new List<SObject>();

	//	// Extract key elementals and list of fields
	//	String objectName = String.valueOf( bodyWrapper.get('ObjectName') );
	//	String salesforceObjectName = objectName.replace('TermLoan','Opportunity');
	//	String keyField = String.valueOf( bodyWrapper.get('KeyField') );
	//	List<Object> valueList = (List<Object>)bodyWrapper.get('data');

	//	// Get schema information from key elements
	//	Schema.SObjectType objectType = Schema.getGlobalDescribe().get( salesforceObjectName );
	//	Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();

	//	// Get list of mappings for this sObject
	//	List<Integration_Mapping__c> mappingList = 
	//	[	
	//		SELECT Id, Active__c, Required__c, Key__c,
	//			Salesforce_Field__c, Salesforce_Object__c, 
	//			Integration_Field__c, Integration_Object__c
	//		FROM Integration_Mapping__c 
	//		WHERE Salesforce_Object__c =: objectName
	//			AND Active__c = true
	//	];
	//	// Create map of field mappings for this sObject
	//	Map<String, String> integrationToSalesforceFieldMap = new Map<String, String>();
	//	for ( Integration_Mapping__c mapping : mappingList ) {
	//		integrationToSalesforceFieldMap.put( mapping.Integration_Field__c, mapping.Salesforce_Field__c );
	//	}
	//	if ( objectName == 'TermLoan' ) {
	//		integrationToSalesforceFieldMap.put( 'Applicant', 'Name' );
	//		integrationToSalesforceFieldMap.put( 'CloseDate', 'CloseDate' );
	//	}
	//	// Loop through each record
	//	for ( Object value : valueList ) {
	//		// Create a map of the fields
	//		Map<String, Object> valueMap = (Map<String, Object>)value;
	//		// Create a new record to update using the ID field.   
	//		// TODO: Make this use the KeyField element
	//		SObject record = objectType.newSObject( String.valueOf( valueMap.get( 'Id' ) ) );

	//		// Loop through each field in the JSON
	//		for ( String s : valueMap.keySet() ) {
	//			// Proceed if the field is in the mapping
	//			if ( integrationToSalesforceFieldMap.containsKey( s ) && fieldMap.get(integrationToSalesforceFieldMap.get( s )).getDescribe().isUpdateable() ) {

	//				// Get field type
	//				String fieldType = String.valueOf(fieldMap.get( integrationToSalesforceFieldMap.get( s ) ).getDescribe().getType());
	//				System.Debug('fieldType: ' + fieldType);

	//				// Update this field on the record using the correct type conversion.
	//				if (fieldType == 'STRING' || fieldType == 'ID' || fieldType == 'URL' || fieldType == 'EMAIL' || fieldType == 'PHONE' || fieldType == 'TEXTAREA' || fieldType == 'REFERENCE' || fieldType == 'PICKLIST') {
	//					record.put( integrationToSalesforceFieldMap.get( s ), String.valueOf( valueMap.get( s ) ) );
	//				}
	//				else if (fieldType == 'INTEGER') {
	//					record.put( integrationToSalesforceFieldMap.get( s ), Integer.valueOf( valueMap.get( s ) ) );
	//				}
	//				else if (fieldType == 'DOUBLE' || fieldType == 'CURRENCY' || fieldType == 'PERCENT') {
	//					record.put( integrationToSalesforceFieldMap.get( s ), Double.valueOf( valueMap.get( s ) ) );
	//				}
	//				else if (fieldType == 'DATE' && String.valueOf( valueMap.get( s ) ) != null ) {
	//					record.put( integrationToSalesforceFieldMap.get( s ), Date.valueOf( String.valueOf( valueMap.get( s ) ) ) );
	//				}
	//				else if (fieldType == 'DATETIME') {
	//					record.put( integrationToSalesforceFieldMap.get( s ), Datetime.valueOf( valueMap.get( s ) ) );
	//				}
	//				else if (fieldType == 'BOOLEAN') {
	//					record.put( integrationToSalesforceFieldMap.get( s ), Boolean.valueOf( valueMap.get( s ) ) );
	//				}

	//			}
	//		}
	//		// Add record to list to be updated
	//		recordUpdates.add( record );
	//	}

	//	// Update records
	//	System.Debug(recordUpdates);
	//	System.Debug(Schema.getGlobalDescribe().get(salesforceObjectName).getDescribe().fields.getMap().get(integrationToSalesforceFieldMap.get(keyField)));
	//	Database.SaveResult[] saves = Database.update(recordUpdates, Schema.getGlobalDescribe().get(salesforceObjectName).getDescribe().fields.getMap().get(integrationToSalesforceFieldMap.get(keyField)));
	//	System.Debug(saves);
	//	createIntegrationLog( body, 'fill me in', 'PRES ');

	//	return null;
	//}


	///**	
 //   * @description Method to send data to Precise RE webservice
 //   * @param body The Body of the HTTP Request
 //   * @param objectName The Salesforce Object Name ### MIGHT BE OVERKILL
 //   */
	//public static String calloutHelper( String body, String objectName) {
	//	// Construct HTTP Request and get Response
	//	HttpResponse response = new HttpResponse();
	//	HttpRequest request = constructReqeust( preciseEndpoint, 'POST', body );
	//	if( Test.isRunningTest() ) {
	//		response.setBody('{ "Data":[ { "ObjectName":"Account","KeyField":"Id","data":[ { "PresId":"5870","Id":"0011100000sL6ynAAC4","AccountName":"MK PARTNERS TEST","BillingAddress":null,"Fax":"(098) 765-4321","Phone":"1234567890","Website":"salesforce.com"}]}],"Code":200,"Message":"Ok"}');
	//	} else {
	//		response = new http().send( request );	
	//	}

	//	// Replace Zero-Width whitespace
	//	response.setBody( response.getBody().replace('\uFEFF','') );
	//	System.Debug(constructReqeust(preciseEndpoint,'POST',body).getBody());
	//	System.Debug(response.getBody());
	//	// Create wrapper map
	//	Map<String, Object> responseWrapper = (Map<String, Object>)JSON.deserializeUntyped( response.getBody() );
		
	//	// Success! We have a Data List
	//	if ( String.valueOf(responseWrapper.get('Code')) == '200' ) {
	//		// Get each object in the Data List
	//		List<Object> dataList = (List<Object>)responseWrapper.get('Data');	
	//		Map<String, String> salesforceAccountIdToPresIdMap = new Map<String,String>();
	//		Map<String, String> salesforceContactIdToPresIdMap = new Map<String, String>();
	//		Map<String, String> salesforceOpportunityIdToPresIdMap = new Map<String,String>();

	//		// Loop through each dataMap and pull out the IDs to update Salesforce records
	//		for ( Object data : dataList ) {
	//			Map<String, Object> dataMap = (Map<String, Object>)data;
	//			List<Object> valueList = (List<Object>)dataMap.get( 'data' );

	//			if ( valueList != null && valueList.size() > 0 ) {
	//				Map<String, Object> valueMap = (Map<String, Object>)valueList[0];

	//				// Track Pres_Id on the Accounts
	//				if ( dataMap.get( 'ObjectName' ) == 'Account' ) {
	//					salesforceAccountIdToPresIdMap.put( String.valueOf(valueMap.get( 'Id' )), String.valueOf(valueMap.get( 'PresId' )) );
	//				}
	//				// Track Pres_Deal_Id on the Opporunities
	//				else if ( dataMap.get( 'ObjectName' ) == 'Opportunity' ) {
	//					salesforceOpportunityIdToPresIdMap.put( String.valueOf(valueMap.get( 'Id' )), String.valueOf(valueMap.get( 'PresDealId' )) );
	//				}
	//				else if ( dataMap.get( 'ObjectName' ) == 'Contact' ) {
	//					salesforceContactIdToPresIdMap.put( String.valueOf(valueMap.get( 'Id' )), String.valueOf(valueMap.get( 'PresContactId' )) );
	//				}
	//			}
	//		}

	//		// Get records to update
	//		List<Account> accountUpdates = [SELECT Id, Pres_ID__c FROM Account WHERE Id IN :salesforceAccountIdToPresIdMap.keySet() ];
	//		List<Opportunity> opportunityUpdates = [SELECT Id, Pres_Deal_ID__c FROM Opportunity WHERE Id IN :salesforceOpportunityIdToPresIdMap.keySet() ];
	//		List<Contact> contactUpdates = [SELECT Id, Pres_Contact_ID__c FROM Contact WHERE Id IN :salesforceContactIdToPresIdMap.keySet() ];

	//		// Set the External PRES IDs
	//		for ( Account a : accountUpdates ) {
	//			a.Pres_Id__c = salesforceAccountIdToPresIdMap.get( a.Id );
	//		}
	//		for ( Opportunity o : opportunityUpdates ) {
	//			o.Pres_Deal_Id__c = salesforceOpportunityIdToPresIdMap.get( o.Id );
	//		}
	//		for ( Contact c : contactUpdates ) {
	//			c.Pres_Contact_ID__c = salesforceContactIdToPresIdMap.get( c.Id );
	//		}

	//		// Update records
	//		update accountUpdates;
	//		update opportunityUpdates;
	//		update contactUpdates;
	//	}
	//	createIntegrationLog( request.getBody(), response.getBody(), 'SALESFORCE ');
	//	return response.getBody();
	//}

	///**	
 //   * @description Helper method to construct an HTTP Request
 //   * @param endpoint The URL of the endpoint to hit.
 //   * @param method The HTTP Method to use
 //   * @param body The Body of the HTTP Request
 //   */
	//public static HttpRequest constructReqeust( String endpoint, String method, String body ) {
	//	HttpRequest request = new HttpRequest();
	//	request.setMethod( method );
	//	request.setEndpoint( endpoint );
	//	request.setBody( body );
	//	request.setTimeout(120000);
	//	request.setHeader( 'Accept', 'application/json' );
	//	request.setHeader( 'Content-Type', 'application/json' );
	//	request.setHeader( 'Content-Length', '' + body.length() ); 
	//	request.setHeader( 'Authorization', authToken ); 
	//	return request;
	//}

	///**	
 //   * @description Helper method to create and insert debug logs 
 //   * @param request The JSON of the HTTP Request
 //   * @param response The JSON of the HTTP Response
 //   * @param prefix The type of debug log this is
 //   */
	//public static void createIntegrationLog( String request, String response, String prefix ) {
	//	IntegrationSetting__c enabledLogs = IntegrationSetting__c.getInstance('ENABLE_LOGGING');
	//	if ( enabledLogs != null && enabledLogs.Value__c == 'true') {
	//		List<Integration_Log__c> debugRecords = new List<Integration_Log__c> { 
	//			new Integration_Log__c(
	//				Name = prefix + ' Integration Log: ' + String.valueOf(Datetime.now())
	//			,	JSON_Request__c = request
	//			,	JSON_Response__c = response
	//		) };
	//		List<Database.SaveResult> debugInsert = Database.insert(debugRecords, false);
	//		for (Database.SaveResult sr : debugInsert) {
	//			System.Debug('Save result: ' + sr);
	//			if (sr.isSuccess() == true) {
	//		        System.debug('Successfully inserted ' +  sr.getId());
	//		    }
	//		    else {
	//		        // Operation failed, so get all errors                
	//		        for(Database.Error err : sr.getErrors()) {
	//		            System.debug('The following error has occurred.');                    
	//		            System.debug(err.getStatusCode() + ': ' + err.getMessage());
	//		        }
	//		    }
	//		}
	//	}
	//}

}