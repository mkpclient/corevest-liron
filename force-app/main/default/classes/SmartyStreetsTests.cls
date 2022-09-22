@isTest
private class SmartyStreetsTests {

    static testMethod void unittest(){
        test_Helper.createDealLoanNumber();
        Account acc = test_Helper.createAccount();
        Contact cont = test_Helper.createContact( acc );
        Opportunity opp = test_Helper.createOpportunity( acc, cont );
        opp.StageName = 'Submitted to Underwriting';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Term Loan').getRecordTypeId();

        Property__c prop = new Property__c();
        prop.Property_Type__c = 'SFR';
        prop.Deal__c = opp.Id;
        prop.Calc_AveValue__c = 100000;
        prop.Name = 'test';
        prop.Property_Name__c = 'test Street';
        prop.City__c = 'test';
        prop.State__c = 'test';
        prop.ZipCode__c = 'test';

        insert prop;

        Test.startTest();
            System.enqueueJob(new SmartyStreetsQueueable(new List<Id>{prop.Id}));
        Test.stopTest();
    }

    static testMethod void unitTest2(){
        test_Helper.createDealLoanNumber();
        Account acc = Test_Helper.createAccount();
        Contact cont = Test_Helper.createContact( acc );
        Opportunity opp = Test_Helper.createOpportunity( acc, cont );
        opp.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Term_Loan' and sobjecttype = 'Opportunity'].Id;
        List<Property__c> properties = Test_Helper.createProperties(opp);
        Appraisal__c appraisal = Test_Helper.createAppraisal(opp, properties[0]);

        Test.startTest();
            ValidatedAddressController.initMergeScreen(opp.Id);
        Test.stopTest();
    }

}