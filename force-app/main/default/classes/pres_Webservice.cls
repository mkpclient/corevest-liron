@RestResource(urlMapping='/pres/*')
global with sharing class pres_Webservice {

	/**
    * @description Method to receive data from Precise RE
    */
	@HttpPost
	global static SObject preciseRE() {
		// Get body from POST request
		RestRequest request = RestContext.request;
		System.Debug(request);
		String body = EncodingUtil.base64Decode( EncodingUtil.base64Encode( request.requestBody ) ).toString();
		System.Debug(body);
		// Create map of body
		Map<String, Object> bodyWrapper = (Map<String, Object>)JSON.deserializeUntyped( body );

		// Initialize update list
		List<SObject> recordUpdates = new List<SObject>();

		// Extract key elementals and list of fields
		String objectName = String.valueOf( bodyWrapper.get('ObjectName') );
		String salesforceObjectName = objectName.replace('TermLoan','Opportunity');
		String keyField = String.valueOf( bodyWrapper.get('KeyField') );
		List<Object> valueList = (List<Object>)bodyWrapper.get('data');

		// Get schema information from key elements
		Schema.SObjectType objectType = Schema.getGlobalDescribe().get( salesforceObjectName );
		Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();

		// Get list of mappings for this sObject
		List<Integration_Mapping__c> mappingList =
		[
			SELECT Id, Active__c, Required__c, Key__c,
				Salesforce_Field__c, Salesforce_Object__c,
				Integration_Field__c, Integration_Object__c
			FROM Integration_Mapping__c
			WHERE Salesforce_Object__c =: objectName
				AND Active__c = true
		];
		// Create map of field mappings for this sObject
		Map<String, String> integrationToSalesforceFieldMap = new Map<String, String>();
		for ( Integration_Mapping__c mapping : mappingList ) {
			integrationToSalesforceFieldMap.put( mapping.Integration_Field__c, mapping.Salesforce_Field__c );
		}
		if ( objectName == 'TermLoan' ) {
			integrationToSalesforceFieldMap.put( 'Applicant', 'Name' );
			integrationToSalesforceFieldMap.put( 'CloseDate', 'CloseDate' );
			integrationToSalesforceFieldMap.put( 'PrimaryContactName', 'Primary_Contact_Name__c' );
		}
		// Loop through each record
		for ( Object value : valueList ) {
			// Create a map of the fields
			Map<String, Object> valueMap = (Map<String, Object>)value;
			// Create a new record to update using the ID field.
			SObject record = objectType.newSObject( String.valueOf( valueMap.get( 'Id' ) ) );

			// Loop through each field in the JSON
			for ( String s : valueMap.keySet() ) {
				// Proceed if the field is in the mapping
				if ( integrationToSalesforceFieldMap.containsKey( s ) && fieldMap.get(integrationToSalesforceFieldMap.get( s )).getDescribe().isUpdateable() ) {

					// Get field type
					String fieldType = String.valueOf(fieldMap.get( integrationToSalesforceFieldMap.get( s ) ).getDescribe().getType());
					System.Debug('fieldType: ' + fieldType);

					// Update this field on the record using the correct type conversion.
					if (fieldType == 'STRING' || fieldType == 'ID' || fieldType == 'URL' || fieldType == 'EMAIL' || fieldType == 'PHONE' || fieldType == 'TEXTAREA' || fieldType == 'REFERENCE' || fieldType == 'PICKLIST') {
						record.put( integrationToSalesforceFieldMap.get( s ), String.valueOf( valueMap.get( s ) ) );
					}
					else if (fieldType == 'INTEGER') {
						record.put( integrationToSalesforceFieldMap.get( s ), Integer.valueOf( valueMap.get( s ) ) );
					}
					else if (fieldType == 'DOUBLE' || fieldType == 'CURRENCY' || fieldType == 'PERCENT') {
						//if(s == 'Rate__c'){
						//	record.put( integrationToSalesforceFieldMap.get( s ), Double.valueOf( valueMap.get( s.replace('%', '') ) ) );
						//}else{
						if(String.valueOf( valueMap.get( s ) ) != null){
							record.put( integrationToSalesforceFieldMap.get( s ), Double.valueOf( String.valueOf(valueMap.get( s )).replace('%', '') ) );
						}else{
							record.put( integrationToSalesforceFieldMap.get( s ), Double.valueOf( valueMap.get( s ) ) );
						} 
						//}
						
					}
					else if (fieldType == 'DATE' && String.valueOf( valueMap.get( s ) ) != null ) {
						record.put( integrationToSalesforceFieldMap.get( s ), Date.valueOf( String.valueOf( valueMap.get( s ) ) ) );
					}
					else if (fieldType == 'DATETIME') {
						record.put( integrationToSalesforceFieldMap.get( s ), Datetime.valueOf( valueMap.get( s ) ) );
					}
					else if (fieldType == 'BOOLEAN') {
						record.put( integrationToSalesforceFieldMap.get( s ), Boolean.valueOf( valueMap.get( s ) ) );
					}

				}
			}
			// Add record to list to be updated
			recordUpdates.add( record );
		}

		// Update records
		System.Debug(recordUpdates);
		System.Debug(Schema.getGlobalDescribe().get(salesforceObjectName).getDescribe().fields.getMap().get(integrationToSalesforceFieldMap.get(keyField)));
		if ( objectName == 'TermLoan' || objectName == 'Opportunity' ) {
			Opportunity[] opportunities = new Opportunity[] {};
			for ( SObject r : recordUpdates ) {
				Opportunity o = (Opportunity) r;
				if ( objectName == 'TermLoan' && o.Pres_Deal_ID__c.isNumeric()  ) {
					o.Pres_Deal_ID__c = 'TermLoan' + o.Pres_Deal_ID__c;
				}
				if ( objectName == 'Opportunity' && o.Pres_Deal_ID__c.isNumeric() ) {
					o.Pres_Deal_ID__c = 'LOC' + o.Pres_Deal_ID__c;
				}
				opportunities.add( o );
			}
			if ( Test.isRunningTest() == false ) {
				Database.upsert( opportunities, Opportunity.Pres_Deal_ID__c );	
			}
		} else {
			Database.update( recordUpdates );
		}
		return null;
	}

}