public with sharing class pres_Extension {

    // Query strings for Accounts, Contacts, and Opportunities
    String accountQueryString = 'SELECT ' + String.join(new List<String>(Schema.SObjectType.Account.fields.getMap().keySet()),',')  + ' FROM Account WHERE Id = :accountId LIMIT 1';
    String contactQueryString = 'SELECT ' + String.join(new List<String>(Schema.SObjectType.Contact.fields.getMap().keySet()),',')  + ' FROM Contact WHERE Id = :contactId LIMIT 1';
    String opportunityQueryString = 'SELECT ' + String.join(new List<String>(Schema.SObjectType.Opportunity.fields.getMap().keySet()),',')  + ', RecordType.Name FROM Opportunity WHERE Id = :opportunityId LIMIT 1';

    // The IDs of this deal
    public Id opportunityId;
    public Id accountId;
    public Id contactId;

    // The page message to display to users when attempting to send data to PRES.
    public String pageMessage {get; set;}

    /**
    * @description Constructor for visualforce page.  Reached from custom button.
    */
    public pres_Extension(ApexPages.standardController standardController){
        opportunityId = standardController.getId();
    }

    /**
    * @description Sends loan information to PRES.  Called on page load.
    */
    public void sendToPres() {

        Opportunity opportunity = Database.query( opportunityQueryString );
        accountId = opportunity.AccountId;
        contactId = opportunity.Contact__c;

        if ( String.isNotBlank( opportunity.Pres_Deal_ID__c ) ) {
            pageMessage = 'Cannot send this record because it already has a Pres Deal ID.';
            return;
        }

        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        request.setMethod( 'POST' );
        request.setTimeout( 120000 );
        request.setHeader( 'Accept', 'application/json' );
        request.setHeader( 'Content-Type', 'application/json' );

        PRES_Settings__c settings;
        if ( opportunity.RecordType.Name == 'LOC Loan' ) {
            settings = PRES_Settings__c.getInstance('LOC');
            request.setBody( getLocLoanRequestString( opportunity ) );
        } else if ( opportunity.RecordType.Name == 'Term Loan' ) {
            settings = PRES_Settings__c.getInstance('TERM');
            request.setBody( getTermLoanRequestString( opportunity ) );
        }

        request.setHeader( 'Authorization', 'Basic ' + encodingUtil.base64Encode( blob.valueOf( settings.Username__c + ':' + settings.Password__c ) ) );
        request.setHeader( 'Content-Length', '' + request.getBody().length() );
        request.setEndpoint( settings.URL__c );

        if ( Test.isRunningTest() ) {
            response.setBody('{ "Data":[ { "ObjectName":"Account","KeyField":"Id","data":[ { "PresId":"5870","Id":"0011100000sL6ynAAC4","AccountName":"MK PARTNERS TEST","BillingAddress":null,"Fax":"(098) 765-4321","Phone":"1234567890","Website":"salesforce.com"}]}],"Code":200,"Message":"Ok"}');
        } else {
            response = new http().send( request );
        }
        response.setBody( response.getBody().replace('\uFEFF','') );
        System.Debug(request.getBody());
        System.Debug(response.getBody());
        // Create wrapper map
        Map<String, Object> responseWrapper = (Map<String, Object>)JSON.deserializeUntyped( response.getBody() );

        // Success! We have a Data List
        if ( String.valueOf(responseWrapper.get('Code')) == '200' ) {
            // Get each object in the Data List
            List<Object> dataList = (List<Object>)responseWrapper.get('Data');
            Map<String, String> salesforceAccountIdToPresIdMap = new Map<String,String>();
            Map<String, String> salesforceContactIdToPresIdMap = new Map<String, String>();
            Map<String, String> salesforceOpportunityIdToPresIdMap = new Map<String,String>();

            // Loop through each dataMap and pull out the IDs to update Salesforce records
            for ( Object data : dataList ) {
                Map<String, Object> dataMap = (Map<String, Object>)data;
                List<Object> valueList = (List<Object>)dataMap.get( 'data' );

                if ( valueList != null && valueList.size() > 0 ) {
                    Map<String, Object> valueMap = (Map<String, Object>)valueList[0];

                    // Track Pres_Id on the Accounts
                    if ( dataMap.get( 'ObjectName' ) == 'Account' ) {
                        salesforceAccountIdToPresIdMap.put( String.valueOf(valueMap.get( 'Id' )), String.valueOf(valueMap.get( 'PresId' )) );
                    }
                    // Track Pres_Deal_Id on the Opporunities
                    else if ( dataMap.get( 'ObjectName' ) == 'Opportunity' ) {
                        salesforceOpportunityIdToPresIdMap.put( String.valueOf(valueMap.get( 'Id' )), String.valueOf(valueMap.get( 'PresDealId' )) );
                    }
                    else if ( dataMap.get( 'ObjectName' ) == 'TermLoan' ) {
                        salesforceOpportunityIdToPresIdMap.put( String.valueOf(valueMap.get( 'SalesforceId' )), String.valueOf(valueMap.get( 'PresId' )) );
                    }
                    else if ( dataMap.get( 'ObjectName' ) == 'Contact' ) {
                        salesforceContactIdToPresIdMap.put( String.valueOf(valueMap.get( 'Id' )), String.valueOf(valueMap.get( 'PresContactId' )) );
                    }
                }
            }

            // Get records to update
            List<Account> accountUpdates = [SELECT Id, Pres_ID__c FROM Account WHERE Id IN :salesforceAccountIdToPresIdMap.keySet() ];
            List<Opportunity> opportunityUpdates = [SELECT Id, Pres_Deal_ID__c FROM Opportunity WHERE Id IN :salesforceOpportunityIdToPresIdMap.keySet() ];
            List<Contact> contactUpdates = [SELECT Id, Pres_Contact_ID__c FROM Contact WHERE Id IN :salesforceContactIdToPresIdMap.keySet() ];

            // Set the External PRES IDs
            for ( Account a : accountUpdates ) {
                a.Pres_Id__c = salesforceAccountIdToPresIdMap.get( a.Id );
            }
            for ( Opportunity o : opportunityUpdates ) {
                o.Pres_Deal_Id__c = salesforceOpportunityIdToPresIdMap.get( o.Id );
            }
            for ( Contact c : contactUpdates ) {
                c.Pres_Contact_ID__c = salesforceContactIdToPresIdMap.get( c.Id );
            }

            // Update records
            update accountUpdates;
            update opportunityUpdates;
            update contactUpdates;
        } else {
            pageMessage = 'There was an error: ' + String.valueOf(responseWrapper.get('Message'));
            return;
        }
        // createIntegrationLog( request.getBody(), response.getBody(), 'SALESFORCE ');
        // return response.getBody();
        pageMessage = 'Success!  Data was successfully sent to PRES.';
        return;
    }

    /**
    * @description Returns JSON String for LOC Loan Requests to PRES.
    * @param opportunity The opportunity being sent to PRES.
    */
    public String getLocLoanRequestString( Opportunity opportunity ) {
                
        Account account = Database.query( accountQueryString );
        Contact contact = ( String.isNotBlank(contactId) ) ? Database.query( contactQueryString ) : null;

        String result = '{ \n "FullData":[ \n';
        result += recordToJSON( opportunity, 'Opportunity' ) + ', \n';
        result += recordToJSON( account, 'Account' ) + ', \n';
        result += recordToJSON( contact, 'Contact' ) + ' ] \n}';
        return result;
    }

    /**
    * @description Returns JSON String for TERM Loan Requests to PRES.
    * @param opportunity The opportunity being sent to PRES.
    */
    public String getTermLoanRequestString( Opportunity opportunity ) {
        String result = '{ \n "FullData":[ \n';
        result += recordToJSON( opportunity, 'TermLoan' ) + ' ] \n}';
        return result;
    }

    /**
    * @description Uses integration mapping object to convert record to JSON.
    * @param record The record being sent to PRES.
    * @param mappingTable The name of the integration mapping table.
    */
    public String recordToJSON( SObject record, String mappingTable ) {
        if ( record == null ) {
            return '';
        }

        String keyField = '';
        Set<String> requiredFields = new Set<String>();

        List<Integration_Mapping__c> mappingList =
        [
            SELECT Id, Active__c, Required__c, Key__c, Salesforce_Field__c, Salesforce_Object__c, Integration_Field__c, Integration_Object__c
            FROM Integration_Mapping__c
            WHERE Salesforce_Object__c =: mappingTable
                AND Active__c = true
            ORDER BY Integration_Field__c
        ];

        for (Integration_Mapping__c mapping : mappingList) {
            // Add required fields
            if ( mapping.Required__c == true ) {
                requiredFields.add(mapping.Salesforce_Field__c);
            }
            // Find Key
            if ( String.isNotBlank(mapping.Key__c) ) {
                keyField = mapping.Integration_Field__c;
            }
        }

        JSONGenerator gen = JSON.createGenerator(true);

        // Start JSON
        gen.writeStartObject();
        gen.writeStringField('ObjectName', mappingTable);
        gen.writeStringField('KeyField', keyField);
        gen.writeFieldName('data');
        gen.writeStartArray();

        
        // Check for all Required Fields
        Boolean passedRequiredFields = true;
        for (String s : requiredFields) {
            if (record.get(s) == null) {
                passedRequiredFields = false;
            }
        }
        if ( record != null && passedRequiredFields == true ) {
            // Create JSON Object for this Record
            gen.writeStartObject();

            // Loop through each field for this Record
            for (Integration_Mapping__c mapping : mappingList) {

                // Get value for this field
                Object fieldValue = record.get(mapping.Salesforce_Field__c);

                // Get Field Type and generate corresponding JSON field
                if (fieldValue == null) {
                    gen.writeNullField(mapping.Integration_Field__c);
                }
                else if (fieldValue instanceof String) {
                    gen.writeStringField(mapping.Integration_Field__c, String.valueOf(fieldValue));
                }
                else if (fieldValue instanceof Integer) {
                    gen.writeNumberField(mapping.Integration_Field__c, Integer.valueOf(fieldValue));
                }
                else if (fieldValue instanceof Double) {
                    gen.writeNumberField(mapping.Integration_Field__c, Double.valueOf(fieldValue));
                }
                else if (fieldValue instanceof Date) {
                    gen.writeDateField(mapping.Integration_Field__c, Date.valueOf(fieldValue));
                }
                else if (fieldValue instanceof Datetime) {
                    gen.writeDateTimeField(mapping.Integration_Field__c, Datetime.valueOf(fieldValue));
                }
                else if (fieldValue instanceof Boolean) {
                    String boolField = (Boolean.valueOf(fieldValue) == true) ? 'Y' : 'N';
                    gen.writeStringField(mapping.Integration_Field__c, boolField);
                }

            }
            // End list of fields for this sObject
            gen.writeEndObject();
        }
        
        // End array of records
        gen.writeEndArray();

        // End JSON
        gen.writeEndObject();

       // for ()
       return gen.getAsString();
    }
}