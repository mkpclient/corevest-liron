public with sharing class opportunity_Extension {
	
	public opportunity_Extension() {
		
	}

	//public Opportunity thisOpportunity {get; set;}
	//public Account thisAccount {get; set;}
	//public Contact thisContact {get; set;}

	//public String requestMessage {get; set;}
	//public String responseMessage {get; set;}

	//public opportunity_Extension( ApexPages.StandardController stdController ) {
	//	thisOpportunity = (Opportunity)util.getFullObjectById( 'Opportunity', stdController.getId() );
	//	thisAccount = (Account)util.getFullObjectById( 'Account', thisOpportunity.AccountId );
	//	if ( thisOpportunity.Contact__c != null ) {
	//		thisContact = (Contact)util.getFullObjectById( 'Contact', thisOpportunity.Contact__c );
	//	}
	//}

	//public void sendToPreciseRE() {
	//	if ( String.isNotBlank(thisOpportunity.Pres_Deal_ID__c) ) {
	//		responseMessage = 'Cannot send this record because it already has a Pres Deal ID.';
	//	} else {
	//		String preciseRequest = generateJSONWrapper();
	//		requestMessage = 'Request to Precise RE: <br/>' + preciseRequest.replace('\n','<br/>').replace('\t','&nbsp;&nbsp;&nbsp;&nbsp;');
	//		String preciseResponse = preciseRE_API.calloutHelper(preciseRequest, 'INITIAL');
	//		responseMessage = 'Response from Precise RE: <br/>' + preciseResponse;

	//		Map<String,Object> o = (Map<String,Object>)JSON.deserializeUntyped(preciseResponse);
	//		responseMessage = String.valueOf(o.get('Code'));
	//		if ( String.valueOf(o.get('Code')) == '200' ) {
	//			responseMessage = 'Success!  Data was successfully sent to PRES.';
	//		} else {
	//			responseMessage = 'There was an error: ' + String.valueOf(o.get('Message'));
	//		}	
	//	}
		
	//}

	//public String generateJSONWrapper() {
	//	String result = '{ \n';
	//	result += ' "FullData":[ \n';
	//	result += generateJSON( new List<Opportunity> { thisOpportunity } );
	//	result += ', \n';
	//	result += generateJSON( new List<Account> { thisAccount } );
	//	result += ', \n';
	//	result += generateJSON( new List<Contact> { thisContact } );
	//	result += ' ] \n';
	//	result += '}';
	//	return result;
	//}

	//public static String generateJSON( List<SObject> records ) {

	//	// Get type of sObject hitting the trigger
	//	String objectName = String.valueOf(records.getSObjectType());
	//	String objectNameInPrecise = '';
	//	String keyField = '';
	//	Set<String> requiredFields = new Set<String>();

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

	//	// Loop through each mapping on this object
	//	for (Integration_Mapping__c mapping : mappingList) {
	//		// Add required fields
	//		if (mapping.Required__c == true) {
	//			requiredFields.add(mapping.Salesforce_Field__c);
	//		}
	//		// Find Key
	//		if (String.isNotBlank(mapping.Key__c)) {
	//			keyField = mapping.Integration_Field__c;
	//		}
	//	}

	//	// Create JSON Generator (true => pretty format)
 //       JSONGenerator gen = JSON.createGenerator(true);

 //       // Start JSON
 //       gen.writeStartObject();
 //       gen.writeStringField('ObjectName', objectName);
 //       gen.writeStringField('KeyField', keyField);
 //       gen.writeFieldName('data');
 //       gen.writeStartArray();

 //       for ( SObject record : records ) {
 //       	// Check for all Required Fields
 //       	Boolean passedRequiredFields = true;
 //       	for (String s : requiredFields) {
 //       		if (record.get(s) == null) {
 //       			passedRequiredFields = false;
 //       		}
 //       	}
 //       	if ( record != null && passedRequiredFields == true ) {
 //       		// Create JSON Object for this Record
	//        	gen.writeStartObject();

	//        	// Loop through each field for this Record
	//        	for (Integration_Mapping__c mapping : mappingList) {

 //       			// Get value for this field
 //       			System.Debug(mapping);
 //       			System.Debug(mapping.Salesforce_Field__c);
 //       			System.Debug(record);
 //       			System.Debug(record.get(mapping.Salesforce_Field__c));
	//        		Object fieldValue = record.get(mapping.Salesforce_Field__c);

 //       			// Get Field Type and generate corresponding JSON field
 //       			if (fieldValue == null) {
 //       				gen.writeNullField(mapping.Integration_Field__c);
 //       			}
 //       			else if (fieldValue instanceof String) {
	//        			gen.writeStringField(mapping.Integration_Field__c, String.valueOf(fieldValue));
	//        		}
	//        		else if (fieldValue instanceof Integer) {
	//        			gen.writeNumberField(mapping.Integration_Field__c, Integer.valueOf(fieldValue));
	//        		}
	//        		else if (fieldValue instanceof Double) {
	//        			gen.writeNumberField(mapping.Integration_Field__c, Double.valueOf(fieldValue));
	//        		}
	//        		else if (fieldValue instanceof Date) {
	//        			gen.writeDateField(mapping.Integration_Field__c, Date.valueOf(fieldValue));
	//        		}
	//        		else if (fieldValue instanceof Datetime) {
	//        			gen.writeDateTimeField(mapping.Integration_Field__c, Datetime.valueOf(fieldValue));
	//        		}
	//        		else if (fieldValue instanceof Boolean) {
	//        			String boolField = (Boolean.valueOf(fieldValue) == true) ? 'Y' : 'N';
	//        			gen.writeStringField(mapping.Integration_Field__c, boolField);
	//        		}
	        		
	//        	}
	//        	// End list of fields for this sObject
	//        	gen.writeEndObject();
 //       	}
 //       }
 //       // End array of records
	//	gen.writeEndArray();
        
 //       // End JSON
	//    gen.writeEndObject();

 //      // for ()
 //      return gen.getAsString();
	//}
}