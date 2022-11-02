public with sharing class InsuranceReserveCalcExtension {

    public Opportunity record {get;set;}
    public List<Property__c> properties {get;set;}
    public Decimal premiumRollup {get;set;}
    public Decimal reserveOnClosingRollup {get;set;}

    public InsuranceReserveCalcExtension(){
        
    }

    public InsuranceReserveCalcExtension(ApexPages.standardController standardController) {

        this.record = (Opportunity)standardController.getRecord();
        this.properties = new List<Property__c>();
        this.premiumRollup = 0;
        this.reserveOnClosingRollup = 0;

        if(this.record.Id != null) {

            this.properties = getProperties(this.record.Id);
        }

        for(Property__c prop : this.properties) {

            this.premiumRollup += prop.Premium_Amount__c != null ? prop.Premium_Amount__c : 0;
            this.reserveOnClosingRollup += prop.Reserve_On_Closing_Statement__c != null ? prop.Reserve_On_Closing_Statement__c : 0;
        }
        System.debug('Premium and reserve rollups');
        System.debug(this.premiumRollup);
        System.debug(this.reserveOnClosingRollup);
    }

    @AuraEnabled(cacheable=true)
    public static List<Property__c> getProperties(Id recordId){

        return [SELECT Id, Name, Premium_Amount__c, Renewal_Date__c, Total_Monthly_Reserve_Required__c, Monthly_Premium__c, Reserve_On_Closing_Statement__c 
                    FROM Property__c 
                    WHERE Deal__c =: recordId];
    }

    @AuraEnabled(cacheable=true)
    public static Opportunity getDeal(Id recordId){
        return [SELECT Id, Name, First_Payment_Date__c
                FROM Opportunity
                WHERE Id =: recordId];
    }

    @AuraEnabled
    public static List<sObject> upsertData(List<sObject> records){
        return lightning_Controller.upsertRecords(records);
    }

}