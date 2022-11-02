@isTest
public with sharing class AdvanceFundingMemoControllerTests {
    @TestSetup
    static void makeData(){
        Test_Helper.createDealLoanNumber();
        Account a = Test_Helper.createAccount();
        Contact c = Test_Helper.createContact(a);
        Opportunity o = Test_Helper.createBridgeDeal(a, c);
        List<Property__c> props = Test_Helper.createProperties(o);

        Advance__c adv =  new Advance__c(Deal__c = o.Id);
        insert adv;
        insert new Property_Advance__c(Advance__c = adv.Id, Property__c = props[0].Id);
        
    }

    @isTest
    public static void unitTest1() {
        Advance__c adv =[SELECT Id FROM Advance__c];

        Map<String,String> details = new Map<String,String>{
            'actualDscr' => '1x',
            'actualLtv' => '2',
            'actualDebtYield' => '2',
            'proformaRent' => '3321',
            'recordId' => adv.Id
        };

        AdvanceFundingMemoController.downloadFile(JSON.serialize(details)); 

        ApexPages.currentPage().getParameters().put('id', details.get('recordId'));
        ApexPages.currentPage().getParameters().put('actualDscr', details.get('actualDscr'));
        ApexPages.currentPage().getParameters().put('actualLtv', details.get('actualLtv'));
        ApexPages.currentPage().getParameters().put('actualDebtYield', details.get('actualDebtYield'));
        ApexPages.currentPage().getParameters().put('proformaRent', details.get('proformaRent'));
        
        ApexPages.StandardController sc = new ApexPages.StandardController(adv);
        AdvanceFundingMemoController afmc = new AdvanceFundingMemoController(sc);
        AdvanceFundingMemoController.PropertyDetails pd = afmc.propertyDetails;
    }
}