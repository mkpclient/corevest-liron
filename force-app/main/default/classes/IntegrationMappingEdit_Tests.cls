@isTest
global class IntegrationMappingEdit_Tests {
	static testMethod void Integration_Mapping_UnitTest() {
		Test.startTest();
		Integration_Mapping__c accountMapping = new Integration_Mapping__c(Salesforce_Object__c='Account', Salesforce_Field__c='Id', Integration_Object__c='customer', Integration_Field__c='sf_id', Active__c=true, Required__c=false, Key__c='Account');
		Integration_Mapping__c accountMapping2 = new Integration_Mapping__c(Salesforce_Object__c='Account', Salesforce_Field__c='FAKE', Integration_Object__c='customer', Integration_Field__c='sf_id', Active__c=true, Required__c=false, Key__c='');
		Integration_Mapping__c accountMapping3 = new Integration_Mapping__c(Salesforce_Object__c='Account', Salesforce_Field__c='Name', Integration_Object__c='customer', Integration_Field__c='sf_id', Active__c=true, Required__c=false, Key__c='');
		insert accountMapping;
		insert accountMapping2;
		insert accountMapping3;
		IntegrationMappingEdit_Extension ext = new IntegrationMappingEdit_Extension();
		ext.selectedObject = 'Account';
		ext.selectedAdd = 'Name';
		//ext.addMapping();
		ext.selectedDelete = 'Id';
		ext.deleteMapping();
		ext.selectedDelete = 'FAKE';
		ext.deleteBadMapping();
		ext.doSave();
		ext.getObjectOptions();
		Test.stopTest();
	}
}