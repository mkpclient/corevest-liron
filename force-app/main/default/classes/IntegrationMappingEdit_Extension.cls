/**
* @author MK Partners Inc.
* @date 2015-05-14
*
* @description Apex Class Helper to IntegrationMappingEdit page that generates mapping lists for Mass Edit.
*/
public with sharing class IntegrationMappingEdit_Extension {
	
	public String selectedObject {get; set;} // Variable set by Visualforce picklist
	public String selectedAdd {get; set;} // Variable set by Visualforce Add button
    public String selectedDelete {get; set;} // Variable set by Visualforce Delete button

    public Set<String> mappedObjectTypes {get; set;} // Set containing the names from Integration_Mapping__c Salesforce_Object__c picklist values
    public Map<String, Set<String>> objectFieldNameMap {get; set;} // Map linking sObject name to Set of field names for that sObject
    public Map<String, String> objectQueryMap {get; set;} // Map linking sObject name to Query String
    public Map<String, List<Integration_Mapping__c>> objectIntegrationMapping {get; set;} // Map linking sObject name to List of related Integration_Mapping__c records

    public Map<String, Set<String>> objectMappedFieldsMap {get; set;} // Map linking sObject name to Set of Mapped Field Names
    public Map<String, Set<String>> objectUnmappedFieldsMap {get; set;} // Map linking sObject name to Set of Unmapped Field Names
    public Map<String, Set<String>> objectMisMappedFieldsMap {get; set;} // Map linking sObject name to Set of Mismapped Field Names

    public Map<String, List<rowWrapper>> objectMappedRowMap {get; set;} // Map linking sObject name to List of Mapped Wrapper Rows
    public Map<String, List<rowWrapper>> objectUnmappedRowMap {get; set;} // Map linking sObject name to List of Unmapped Wrapper Rows
    public Map<String, List<rowWrapper>> objectMismappedRowMap {get; set;} // Map linking sObject name to List of Mismapped Wrapper Rows


	public IntegrationMappingEdit_Extension() {

        // Get Mapped Object Names
        mappedObjectTypes = new Set<String>();
        Schema.DescribeFieldResult fieldResult = Integration_Mapping__c.Salesforce_Object__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple) {
            mappedObjectTypes.add(f.getLabel());
        }

        // Initialize Containers
        objectFieldNameMap = new Map<String, Set<String>>();
        objectQueryMap = new Map<String, String>();
        objectIntegrationMapping = new Map<String, List<Integration_Mapping__c>>();

        objectMappedFieldsMap = new Map<String, Set<String>>();
        objectUnmappedFieldsMap = new Map<String, Set<String>>();
        objectMisMappedFieldsMap = new Map<String, Set<String>>();

        objectMappedRowMap = new Map<String, List<rowWrapper>>();
        objectUnmappedRowMap = new Map<String, List<rowWrapper>>();
        objectMismappedRowMap = new Map<String, List<rowWrapper>>();

        // Loop through each mapped object
        for (String obj : mappedObjectTypes) {
            // Populate Containers
            objectFieldNameMap.put(obj, getFieldNames(obj));
            objectQueryMap.put(obj, getQueryString(obj));
            objectIntegrationMapping.put(obj, Database.query(objectQueryMap.get(obj)));
            objectMappedFieldsMap.put(obj, new Set<String>());
            objectUnmappedFieldsMap.put(obj, new Set<String>());
            objectMisMappedFieldsMap.put(obj, new Set<String>());
            objectMappedRowMap.put(obj, new List<rowWrapper>());
            objectUnmappedRowMap.put(obj, new List<rowWrapper>());
            objectMismappedRowMap.put(obj, new List<rowWrapper>());            

            // Loop through each mapping for this object
            for (Integration_Mapping__c mapping : objectIntegrationMapping.get(obj)) {

                // Generate Mapped Field Rows
                if (objectFieldNameMap.get(obj).contains(mapping.Salesforce_Field__c)) {
                    objectMappedFieldsMap.get(obj).add(mapping.Salesforce_Field__c);
                    objectMappedRowMap.get(obj).add(new rowWrapper(mapping));
                }
                // Generate Mismapped Field Rows
                else {
                    objectMisMappedFieldsMap.get(obj).add(mapping.Salesforce_Field__c);
                    objectMismappedRowMap.get(obj).add(new rowWrapper(mapping));
                }
            }

            // Generate Unmapped Field Rows
            for (String s : objectFieldNameMap.get(obj)) {
                if (objectMappedFieldsMap.get(obj).contains(s) == false) {
                    objectUnmappedRowMap.get(obj).add(new rowWrapper(s));
                }
            }
        }
    }

    /**	
    * @description Called from "Add" button in a row from "Unmapped Fields" section. Creates a new Integration_Mapping__c record with the values specified on the row.
    */
    public void addMapping() {
    	Integer index = 0;
    	Integer foundIndex = 0;
    	for (rowWrapper rw : objectUnmappedRowMap.get(selectedObject)) {
    		if (rw.SalesforceField.equals(selectedAdd)) {
    			Integration_Mapping__c newMapping = new Integration_Mapping__c();
    			newMapping.Name = selectedObject + ' ' + rw.SalesforceField;
    			newMapping.Salesforce_Field__c = rw.SalesforceField;
    			newMapping.Salesforce_Object__c = selectedObject;
    			newMapping.Integration_Object__c = rw.DestinationTable;
    			newMapping.Integration_Field__c = rw.DestinationField;
    			newMapping.Active__c = rw.Active;
    			newMapping.Required__c = rw.Required;
                newMapping.Key__c = (rw.Key == false) ? '' : selectedObject;

    			insert newMapping;
    			objectMappedRowMap.get(selectedObject).add(new rowWrapper(newMapping));
    			foundIndex = index;
    		}
    		index++;
    	}
    	objectUnmappedRowMap.get(selectedObject).remove(foundIndex);
    }

    /** 
    * @description Called from "Delete" button.  Removes row and deletes mapping entry.
    */
    public void deleteBadMapping() {
        Integer index = 0;
        Integer foundIndex = 0;
        for (rowWrapper rw : objectMismappedRowMap.get(selectedObject)) {
            if (rw.SalesforceField.equals(selectedDelete)) {
                Integration_Mapping__c newMapping = new Integration_Mapping__c(Id = rw.Id);
                delete newMapping;
                foundIndex = index;
            }
            index++;
        }
        objectMismappedRowMap.get(selectedObject).remove(foundIndex);
    }

    /** 
    * @description Called from "Delete" button.  Removes row and deletes mapping entry.
    */
    public void deleteMapping() {
        Integer index = 0;
        Integer foundIndex = 0;
        for (rowWrapper rw : objectMappedRowMap.get(selectedObject)) {
            if (rw.SalesforceField.equals(selectedDelete)) {
                Integration_Mapping__c newMapping = new Integration_Mapping__c(Id = rw.Id);
                delete newMapping;
                objectUnmappedRowMap.get(selectedObject).add(new rowWrapper(selectedDelete));
                foundIndex = index;
            }
            index++;
        }
        objectMappedRowMap.get(selectedObject).remove(foundIndex);
    }

    /** 
    * @description Called from "Save" button.  Saves any changes to all Mapped fields
    */
    public void doSave() {

        List<Integration_Mapping__c> records = new List<Integration_Mapping__c>();
        for (rowWrapper rw : objectMappedRowMap.get(selectedObject)) {
            Integration_Mapping__c newMapping = new Integration_Mapping__c(Id = rw.Id);
            newMapping.Name = selectedObject + ' ' + rw.SalesforceField;
            newMapping.Salesforce_Field__c = rw.SalesforceField;
            newMapping.Salesforce_Object__c = selectedObject;
            newMapping.Integration_Object__c = rw.DestinationTable;
            newMapping.Integration_Field__c = rw.DestinationField;
            newMapping.Active__c = rw.Active;
            newMapping.Required__c = rw.Required;
            newMapping.Key__c = (rw.Key == false) ? '' : selectedObject;
            records.add(newMapping);
        }
        String message = '';
        ApexPages.Severity severity;
        List<Database.SaveResult> results = Database.update(records, false);
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess() == false) {
                message = 'There were some errors.  Please review your Mapped Fields.  Note only one field may be the Key.';
                severity = ApexPages.Severity.ERROR;
            }
        }
        if (String.isBlank(message)) {
            message = 'Successfully updated Mapped Fields.';
            severity = ApexPages.Severity.CONFIRM;
        }
        ApexPages.Message myMsg = new ApexPages.Message(severity, message);
        ApexPages.addMessage(myMsg);
    }

    /**	
    * @description Generic method for retrieving list of Field Names from a given sObject type.
    * @param objectName Name of object to get fields from
    */
    public Set<String> getFieldNames(String n) {
        String objectName = n.replace('TermLoan', 'Opportunity');
    	Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
    	Set<String> selectFields = new Set<String>();
        selectFields.add('Id');
    	if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                //if (fd.isUpdateable()){ // field is updateable
                    selectFields.add(fd.getName());
                //}
            }
        }
        return selectFields;
    }

    /** 
    * @description Generic method for retrieving SOQL query string for a particular sObject
    * @param objectName Name of object to get query string for
    */
    public String getQueryString(String o) {
        //String objectName = o.replace('TermLoan', 'Opportunity');
        String result = 'SELECT Id, Active__c, Required__c, Salesforce_Field__c, Salesforce_Object__c, Integration_Field__c, Integration_Object__c, Key__c';
        result +=' FROM Integration_Mapping__c';
        result +=' WHERE Salesforce_Object__c = \'' + o + '\'';
        result +=' ORDER BY Salesforce_Field__c';
        return result;
    }

    /**	
    * @description Static helper method to be called from outside this class.  
    * @param objectName Name of object to get fields from
    */
    public static Set<String> getFieldNamesHelper(String objectName) {
    	IntegrationMappingEdit_Extension helper = new IntegrationMappingEdit_Extension();
    	return helper.getFieldNames(objectName);
    }

    public static String getSelectHelper(String objectName) {
        IntegrationMappingEdit_Extension helper = new IntegrationMappingEdit_Extension();
        return helper.getSelect(objectName);
    }

    public String getSelect(String o) {
        String objectName = o.replace('TermLoan', 'Opportunity');
    	String selects = '';
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        List<String> selectFields = new List<String>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                //if (fd.isUpdateable()){ // field is updateable
                    selectFields.add(fd.getName());
                //}
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(','))
            {
            	selects = selects.substring(0,selects.lastIndexOf(','));
            }
             
        }
        return selects;
    }

    public List<SelectOption> getObjectOptions() {
        List<SelectOption> results = new List<SelectOption>();
        results.add(new SelectOption('',''));
        for(String s : mappedObjectTypes){
            results.add(new SelectOption(s,s));
        }
    	return results;
    }


    public class rowWrapper {

    	public String Id {get; set;}
    	public String SalesforceTable {get; set;}
    	public String SalesforceField {get; set;}
    	public String DestinationTable {get; set;}
    	public String DestinationField {get; set;}
    	public String Type {get; set;}
    	public Boolean Active {get; set;}
    	public Boolean Required {get; set;}
        public Boolean Key {get; set;}
    	

    	public rowWrapper(Integration_Mapping__c im) {
    		Id = im.Id;
    		SalesforceTable = im.Salesforce_Object__c;
    		SalesforceField = im.Salesforce_Field__c;
    		DestinationTable = im.Integration_Object__c;
    		DestinationField = im.Integration_Field__c;
    		Active = im.Active__c;
    		Required = im.Required__c;
            Key = String.isBlank(im.Key__c) ? false : true;
    	}

    	public rowWrapper(String s) {
    		SalesforceField = s;
    	}
    }
}