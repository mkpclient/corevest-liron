public without sharing class AdvanceFundingMemoController {
    public String actualDscr {get; set; }
    public Decimal actualLtv { get; set; }
    public Decimal actualDebtYield { get; set; }
    public Advance__c record { get; set; }

    public AdvanceFundingMemoController(ApexPages.standardController standardController) {
        this.record = (Advance__c) standardController.getRecord();
        this.actualLtv = Decimal.valueOf(ApexPages.currentPage().getParameters().get('actualLtv'));
        this.actualDebtYield = Decimal.valueOf(ApexPages.currentPage().getParameters().get('actualDebtYield'));
        this.actualDscr = ApexPages.currentPage().getParameters().get('actualDscr');
        
    }
}
