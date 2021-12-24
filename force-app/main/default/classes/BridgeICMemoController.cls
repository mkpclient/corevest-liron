public without sharing class BridgeICMemoController {
    public boolean printReady {get; set;}
    public String filtersJSON{get; set;}
    public WrapperData unsavedObj{get; set;}
    public Property__c property {get;set;}
    public Deal_Contact__c sponsor {get; set;}
    public Opportunity Opportunity {get; set;}
    public sponsorsWrapper wrap {get; set;}
    public guarantorsWrapper wrap1 {get; set;}
    public List<Deal_Contact__c> guarantors {get; set;}
    public String states{get; set;}
    
    public void  getData(){
        printReady=false;
        
        if(filtersJSON.substring(0,1) != '$'){
            if(String.isNotBlank(filtersJSON))
            {
                try{
                    System.debug('filtersJSON---> '+filtersJSON);
                    unsavedObj = (WrapperData)JSON.deserialize(filtersJSON, WrapperData.class);
                    String dealId=unsavedObj.dealId;
                    
                    guarantors=new List<Deal_Contact__c>();
                    Opportunity = [SELECT Id,Index__c,Index_Floor__c,Final_Sponsor_Tier__c,Deal_Loan_Number__c,Borrower_Entity__r.Name,Foreign_National__c,Country__c,Account.Repeat_Borrower__c,
                                   Account.Total_Borrowed__c,Account.Borrowed_on_Bridge_Loans__c,Account.Borrowed_on_Term_Loans__c,Account.Prior_Utilization__c,LOC_Loan_Type__c,Full_Draw_Percentage__c, Full_Draw__c,Liquidity_Based_Percentage__c,
                                   Liquidity_Based__c,Business_Plan_Percentage__c,Business_Plan__c,Notes__c,Product_Sub_Type__c,Project_Strategy__c,Renovation_Funding__c,Active_States__c,
                                   Deal_Intro_Source__c,Account_Introduction_Source__c,Owner_Name__c,Underwriter__r.Name, Broker_Fees__c,Referral_Source_Contact__c,Referral_Source_Contact__r.Name,
                                   LOC_Commitment__c,Rate__c,Fee__c,Interest_Rate_Type__c,CAF_Upfront_Fee__c,Exit_Fee__c,Reno_Funding_Type__c,Loan_Size__c,LOC_Term__c,Index_Margin__c,
                                   Advance_Period_Days_In_Months__c,Repayment_Period__c,Revolving1__c,Recourse__c,Partial_Release__c,LTC__c,LTV__c,Total_Loan_LTC__c,Total_ARV_LTV__c,
                                   Max_Reno_Cost_Reimbursement__c,Renovation_Limit__c,Exception__c,Exception_Reason__c,GLC_Approved__c,GLC_Approval_Date__c,IC_Approval_Date__c,Advance_Period__c FROM Opportunity WHERE Id=:dealId];
                    
                    if(Opportunity!=null && String.isNotBlank(Opportunity.Active_States__c)){
                        List<String> activeStates=Opportunity.Active_States__c.split(';');
                        states=String.join(activeStates,' ; ');
                    }
                    property = new Property__c();
                    sponsor = new Deal_Contact__c();
                    if ( dealId != null ){
                        String propWhereClause = 'Deal__c =\''  + dealId + '\'';
                        List<Property__c> properties = (List<Property__c>)util.queryRecords('Property__c', propWhereClause, 'CreatedDate Desc');
                        
                        if(properties.size() > 0){
                            property = properties[0];
                        }
                        
                        String recordId = dealId;
                        String sponsorQuery = 'SELECT Id, Contact__c, Name, Rental_Units_Owned__c, Cash_Equivalent__c, Cash_Position__c, Net_Worth__c, Annual_Income_Last_Year__c, Annual_Income_2_Years_Ago__c, Middle_Credit_Score__c, Contact__r.Middle_Credit_Score__c, Contact__r.Name, Contact__r.Phone, Contact__r.Email, Contact__r.Experience__c, Contact__r.Liquidity__c, Contact__r.Sponsor_Tier__c, Contact__r.Deliquency_History__c, Contact__r.Years_of_Experience__c, Years_of_Experience__c, Contact__r.Repeat_Borrower__c FROM Deal_Contact__c WHERE Deal__c = : recordId  AND entity_type__c = \'Sponsor\' ORDER BY Percentage_Owned__c Desc, Middle_Credit_Score__c Desc';
                        List<Deal_Contact__c> sponsors = (List<Deal_Contact__c>)database.query(sponsorQuery);
                        if(sponsors.size() > 0){
                            sponsor = sponsors[0];
                        }
                        
                        
                        //Add all data for multi sponsors changes
                        wrap=new sponsorsWrapper(sponsors);
                        
                        
                        //add guarantors 
                        String guarantorsQuery = 'SELECT Id, Contact__c, Name, Rental_Units_Owned__c, Cash_Equivalent__c, Cash_Position__c, Net_Worth__c, Annual_Income_Last_Year__c, Annual_Income_2_Years_Ago__c, Middle_Credit_Score__c, Contact__r.Middle_Credit_Score__c, Contact__r.Name, Contact__r.Phone, Contact__r.Email, Contact__r.Experience__c, Contact__r.Liquidity__c, Contact__r.Sponsor_Tier__c, Contact__r.Deliquency_History__c, Contact__r.Years_of_Experience__c, Years_of_Experience__c, Contact__r.Repeat_Borrower__c FROM Deal_Contact__c WHERE Deal__c = : recordId  AND entity_type__c = \'Guarantor\' ORDER BY Percentage_Owned__c Desc, Middle_Credit_Score__c Desc';
                        guarantors = (List<Deal_Contact__c>)database.query(guarantorsQuery);
                        wrap1=new guarantorsWrapper(guarantors);
                        System.debug('guarantors---> '+guarantors);
                    }
                }
                catch(Exception ex){
                    unsavedObj=new WrapperData();
                    System.debug('Invalid JSON string passed. Unable to deserialize.');
                }
            }
            printReady=true;
        }
    }
    
    @AuraEnabled
    public static Opportunity getData(String recordId){
        List<Opportunity> deals=[SELECT Id,Index__c,Index_Floor__c,Final_Sponsor_Tier__c,Deal_Loan_Number__c,Borrower_Entity__r.Name,Foreign_National__c,Country__c,Account.Repeat_Borrower__c,
                                   Account.Total_Borrowed__c,Account.Borrowed_on_Bridge_Loans__c,Account.Borrowed_on_Term_Loans__c,Account.Prior_Utilization__c,LOC_Loan_Type__c,Full_Draw_Percentage__c, Full_Draw__c,Liquidity_Based_Percentage__c,
                                   Liquidity_Based__c,Business_Plan_Percentage__c,Business_Plan__c,Notes__c,Product_Sub_Type__c,Project_Strategy__c,Renovation_Funding__c,Active_States__c,
                                   Deal_Intro_Source__c,Account_Introduction_Source__c,Owner_Name__c,Underwriter__r.Name, Broker_Fees__c,Referral_Source_Contact__c,Referral_Source_Contact__r.Name,
                                   LOC_Commitment__c,Rate__c,Fee__c,Interest_Rate_Type__c,CAF_Upfront_Fee__c,Exit_Fee__c,Reno_Funding_Type__c,Loan_Size__c,LOC_Term__c,Index_Margin__c,
                                   Advance_Period_Days_In_Months__c,Repayment_Period__c,Revolving1__c,Recourse__c,Partial_Release__c,LTC__c,LTV__c,Total_Loan_LTC__c,Total_ARV_LTV__c,
                                   Max_Reno_Cost_Reimbursement__c,Renovation_Limit__c,Exception__c,Exception_Reason__c,GLC_Approved__c,GLC_Approval_Date__c,IC_Approval_Date__c,Advance_Period__c FROM Opportunity WHERE Id=:recordId];
        
        return deals[0];
    } 
    
    @AuraEnabled
    public static String getUrlAndInstance() {
        
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        return baseUrl + '/apex/bridgeicmemovfp';
    }
    
    public class sponsorsWrapper{
        public List<Deal_Contact__c> sponsors {get; set;}
        public Decimal netWorth {get; set;}
     //   public Decimal annualIncomeLastYear {get; set;}
      //  public Decimal annualIncome2YearAgo {get; set;}
        public Decimal cashPosition {get; set;}
        public Decimal cashEquivalent {get; set;}
        //public Decimal creditScore {get; set;}
        public Integer yearsExperience {get; set;}
        public sponsorsWrapper(List<Deal_Contact__c> sponsors){
            this.sponsors=sponsors;
            
            this.netWorth=0;
         //   this.annualIncomeLastYear=0;
         //   this.annualIncome2YearAgo=0;
            this.cashPosition=0;
            this.cashEquivalent=0;
            //this.creditScore=0;
            this.yearsExperience=0;
            for(Deal_Contact__c sponsor : sponsors){
                this.netWorth+=sponsor.Net_Worth__c!=null ? sponsor.Net_Worth__c : 0;
             //   this.annualIncomeLastYear+=sponsor.Annual_Income_Last_Year__c!=null ? sponsor.Annual_Income_Last_Year__c : 0;
             //   this.annualIncome2YearAgo+=sponsor.Annual_Income_2_Years_Ago__c!=null ? sponsor.Annual_Income_2_Years_Ago__c : 0;
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
    
    public class WrapperData {
        public string dealId{get;set;}
        public string annualincomeyear{get;set;}
        public string annualincome{get;set;}
        public string repeatborrower{get;set;}
        public string recourse{get;set;}
        public string glcapproveddate{get;set;}
        public string fundedborrower{get;set;}
        public string deliquencyhistory{get;set;}
        public string valuepsf{get;set;}
        public string valueperunit{get;set;}
        public string sponsorcostpsf{get;set;}
        public string sponsorcpu{get;set;}
        public string loanpsf{get;set;}
        public string loanperunit{get;set;}
    }
}