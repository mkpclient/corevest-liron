public with sharing class SABDealMemoExtension {
    public Property__c property {get;set;}
    public Deal_Contact__c sponsor {get; set;}
    public Opportunity record {get; set;}
    public sponsorsWrapper wrap {get; set;}
    public guarantorsWrapper wrap1 {get; set;}
    public List<Deal_Contact__c> guarantors {get; set;}

    public SABDealMemoExtension(ApexPages.standardController standardController){
        guarantors=new List<Deal_Contact__c>();
        this.record = (Opportunity)standardController.getRecord();
        property = new Property__c();
        sponsor = new Deal_Contact__c();
        if ( record.Id != null ){
            String propWhereClause = 'Deal__c =\''  + this.record.Id + '\'';
            List<Property__c> properties = (List<Property__c>)util.queryRecords('Property__c', propWhereClause, 'CreatedDate Desc');

            if(properties.size() > 0){
                property = properties[0];
            }

            // String guarantorWhereClause = 'Deal__c =\''  + this.record.Id + '\'';
            // guarantorWhereClause += ' AND entity_type__c = \'Guarantor\' AND Percentage_Owned__c != null';

            // String guarantorOrder = 'Percentage_Owned__c Desc, Middle_Credit_Score__c DESC';
            // List<Deal_Contact__c> sponsors = (List<Deal_Contact__c>)util.queryRecords('Deal_Contact__c', guarantorWhereClause, guarantorOrder);
            String recordId = this.record.Id;
            String sponsorQuery = 'SELECT Id, Contact__c, Name, Rental_Units_Owned__c, Cash_Equivalent__c, Cash_Position__c, Net_Worth__c, Annual_Income_Last_Year__c, Annual_Income_2_Years_Ago__c, Middle_Credit_Score__c, Contact__r.Middle_Credit_Score__c, Contact__r.Name, Contact__r.Phone, Contact__r.Email, Contact__r.Experience__c, Contact__r.Liquidity__c, Contact__r.Sponsor_Tier__c, Contact__r.Deliquency_History__c, Contact__r.Years_of_Experience__c, Years_of_Experience__c, Contact__r.Repeat_Borrower__c FROM Deal_Contact__c WHERE Deal__c = : recordId  AND entity_type__c = \'Sponsor\' ORDER BY Percentage_Owned__c Desc, Middle_Credit_Score__c Desc';
            List<Deal_Contact__c> sponsors = (List<Deal_Contact__c>)database.query(sponsorQuery);
            if(sponsors.size() > 0){
                sponsor = sponsors[0];
            }
            // String guarantorQuery = 'SELECT Id, Contact__r.Name, Contact__r.Phone, Contact__r.FICO_Avg__c, ';
            // guarantorQuery = ' Contact__r.Experience__c, Contact__r.Liquidity__c, Deal_Contact__r.Contact__r.Sponsor_Tier__c, ';
            // guarantorQuery = ' Contact__r.Deliquency_History__c';
            // guarantorQuery ' FROM Deal_Contact__c '
            
            //Add all data for multi sponsors changes
            wrap=new sponsorsWrapper(sponsors);
            
            
            //add guarantors 
            String guarantorsQuery = 'SELECT Id, Contact__c, Name, Rental_Units_Owned__c, Cash_Equivalent__c, Cash_Position__c, Net_Worth__c, Annual_Income_Last_Year__c, Annual_Income_2_Years_Ago__c, Middle_Credit_Score__c, Contact__r.Middle_Credit_Score__c, Contact__r.Name, Contact__r.Phone, Contact__r.Email, Contact__r.Experience__c, Contact__r.Liquidity__c, Contact__r.Sponsor_Tier__c, Contact__r.Deliquency_History__c, Contact__r.Years_of_Experience__c, Years_of_Experience__c, Contact__r.Repeat_Borrower__c FROM Deal_Contact__c WHERE Deal__c = : recordId  AND entity_type__c = \'Guarantor\' ORDER BY Percentage_Owned__c Desc, Middle_Credit_Score__c Desc';
            guarantors = (List<Deal_Contact__c>)database.query(guarantorsQuery);
            wrap1=new guarantorsWrapper(guarantors);
            System.debug('guarantors---> '+guarantors);
            
        }
    }
    
    public class sponsorsWrapper{
        public List<Deal_Contact__c> sponsors {get; set;}
        public Decimal netWorth {get; set;}
        public Decimal annualIncomeLastYear {get; set;}
        public Decimal annualIncome2YearAgo {get; set;}
        public Decimal cashPosition {get; set;}
        public Decimal cashEquivalent {get; set;}
        //public Decimal creditScore {get; set;}
        public Integer yearsExperience {get; set;}
        public sponsorsWrapper(List<Deal_Contact__c> sponsors){
            this.sponsors=sponsors;
            
           this.netWorth=0;
            this.annualIncomeLastYear=0;
            this.annualIncome2YearAgo=0;
            this.cashPosition=0;
            this.cashEquivalent=0;
            //this.creditScore=0;
            this.yearsExperience=0;
            for(Deal_Contact__c sponsor : sponsors){
                this.netWorth+=sponsor.Net_Worth__c!=null ? sponsor.Net_Worth__c : 0;
                this.annualIncomeLastYear+=sponsor.Annual_Income_Last_Year__c!=null ? sponsor.Annual_Income_Last_Year__c : 0;
                this.annualIncome2YearAgo+=sponsor.Annual_Income_2_Years_Ago__c!=null ? sponsor.Annual_Income_2_Years_Ago__c : 0;
                this.cashPosition+=sponsor.Cash_Position__c!=null ? sponsor.Cash_Position__c : 0;
                this.cashEquivalent+=sponsor.Cash_Equivalent__c!=null ? sponsor.Cash_Equivalent__c : 0;
                //this.creditScore+=sponsor.Contact__r.Middle_Credit_Score__c!=null ? sponsor.Contact__r.Middle_Credit_Score__c : 0;
                this.yearsExperience+=sponsor.Years_of_Experience__c!=null ? Integer.valueOf(sponsor.Years_of_Experience__c) : 0;
            }
            
            
        }
        
    }
    public class guarantorsWrapper{
        public List<Deal_Contact__c> guarantors {get; set;}
        public Decimal netWorth {get; set;}
        public guarantorsWrapper(List<Deal_Contact__c> guarantors){
            this.guarantors=guarantors;
            this.netWorth=0;
            for(Deal_Contact__c guarantor : guarantors){
                this.netWorth+=guarantor.Net_Worth__c!=null ? guarantor.Net_Worth__c : 0;
    }
  }  
 }
}