public without sharing class AdvanceFundingMemoController {
  public String actualDscr { get; set; }
  public Decimal actualLtv { get; set; }
  public Decimal actualDebtYield { get; set; }
  public Decimal proformaRent { get; set; }
  public Advance__c record { get; set; }

  public AdvanceFundingMemoController(
    ApexPages.standardController standardController
  ) {
    this.record = (Advance__c) standardController.getRecord();
    this.actualLtv = ApexPages.currentPage().getParameters().containsKey('actualLtv') && String.isNotBlank(ApexPages.currentPage().getParameters().get('actualLtv')) ? Decimal.valueOf(
      ApexPages.currentPage().getParameters().get('actualLtv')
    ) : null;
    this.actualDebtYield = ApexPages.currentPage().getParameters().containsKey('actualDebtYield') && String.isNotBlank(ApexPages.currentPage().getParameters().get('actualDebtYield')) ? Decimal.valueOf(
      ApexPages.currentPage().getParameters().get('actualDebtYield')
    ) : null;
    this.actualDscr = ApexPages.currentPage().getParameters().containsKey('actualDscr') &&  String.isNotBlank(ApexPages.currentPage().getParameters().get('actualDscr')) ? ApexPages.currentPage().getParameters().get('actualDscr') : 'N/A';
    this.proformaRent = ApexPages.currentPage().getParameters().containsKey('proformaRent') && String.isNotBlank(ApexPages.currentPage().getParameters().get('proformaRent')) ? Decimal.valueOf(ApexPages.currentPage().getParameters().get('proformaRent')) : null;
  }

  public PropertyDetails propertyDetails {
    get {
      PropertyDetails pd = new PropertyDetails();

      if (this.record != null) {
        Set<String> transacTypes = new Set<String>();
        Set<String> propTypes = new Set<String>();
        pd.unitCount = 0;
        pd.propertyCount = 0;
        pd.occupancy = 0;
        Decimal occupancyTotal = 0;
        Decimal validOccCount = 0;
        Decimal yearBuiltTotal = 0;
        Decimal validYearBuiltCount = 0;
        Decimal totalDaysBetween = 0;
        Decimal validTotalDays = 0;
        Decimal totalAppraisalDays = 0;
        Decimal validAppraisalDays = 0;
        Decimal rehabBudgetTotal = 0;
        Decimal validRehabBudget = 0;
        for (Property_Advance__c pa : [
            SELECT Id, Perc_of_Rehab_Budget__c, Property__r.Refinance_Acquisition__c, Property__r.Acquisition_Date__c, Property__r.Property_Type__c, Property__r.Number_of_Units__c, Property__r.Occupancy_Pct__c, Property__r.Year_Built__c, Property__r.BPO_Appraisal_Date__c
            FROM Property_Advance__c
            WHERE Advance__c = :this.record.Id
            AND Property__c != null
        ]) {
          Property__c p = pa.Property__r;
          pd.propertyCount++;
          if (String.isNotBlank(p.Refinance_Acquisition__c)) {
            transacTypes.add(p.Refinance_Acquisition__c);
          }
          if (String.isNotBlank(p.Property_Type__c)) {
            propTypes.add(p.Property_Type__c);
          }

          if (p.Number_of_Units__c != null) {
            pd.unitCount += p.Number_of_Units__c;
          }

          if (p.Occupancy_Pct__c != null) {
            occupancyTotal += p.Occupancy_Pct__c;
            validOccCount++;
          }

          if (String.isNotBlank(p.Year_Built__c)) {
            yearBuiltTotal += Decimal.valueOf(p.Year_Built__c);
            validYearBuiltCount++;
          }

          if(p.Acquisition_Date__c != null) {
            totalDaysBetween = p.Acquisition_Date__c.daysBetween(System.today());
            validTotalDays++;
          }

          if(p.BPO_Appraisal_Date__c != null) {
            totalAppraisalDays = p.BPO_Appraisal_Date__c.daysBetween(System.today());
            validAppraisalDays++;
          }

          if(pa.Perc_of_Rehab_Budget__c != null) {
            rehabBudgetTotal += pa.Perc_of_Rehab_Budget__c;
            validRehabBudget++;
          } 
        }

        pd.transactionType = String.join(new List<String>(transacTypes), ', ');
        pd.propertyType = String.join(new List<String>(propTypes), ', ');
        if(validOccCount > 0) {
            pd.occupancy = occupancyTotal / validOccCount;

        }
        if( validYearBuiltCount > 0) {
            pd.avgYearBuilt = yearBuiltTotal / validYearBuiltCount;
        }

        if (validTotalDays > 0) {
          pd.acquisitionDate = System.today().addDays(0 - (Integer.valueOf(totalDaysBetween / validTotalDays)));
        }

        if(validAppraisalDays > 0) {
          pd.appraisalDate = System.today().addDays(0 - (Integer.valueOf(totalAppraisalDays / validAppraisalDays)));
        }

        if(validRehabBudget > 0) {
          pd.rehabBudgetPct = rehabBudgetTotal / validRehabBudget;
        }
      }

      return pd;
    }
    private set;
  }

  public class PropertyDetails {
    public String transactionType {get; set;}
    public String propertyType {get; set;}
    public Decimal propertyCount {get; set;}
    public Decimal unitCount {get; set;}
    public Decimal occupancy {get; set;}
    public Decimal avgYearBuilt {get; set;}
    public Date acquisitionDate { get; set; }
    public Date appraisalDate { get; set; }
    public Decimal rehabBudgetPct { get; set; }
  }

  @AuraEnabled
  public static string downloadFile(String jsonDetails){
    try {
      Map<String, Object> details = (Map<String,Object>) JSON.deserializeUntyped(jsonDetails);

      PageReference pageRef = Page.advanceFundingMemo;
      pageRef.getParameters().put('id', String.valueOf(details.get('recordId')));
      pageRef.getParameters().put('actualDscr', String.valueOf(details.get('actualDscr')));
      pageRef.getParameters().put('actualLtv', String.valueOf(details.get('actualLtv')));
      pageRef.getParameters().put('actualDebtYield', String.valueOf(details.get('actualDebtYield')));
      pageRef.getParameters().put('proformaRent', String.valueOf(details.get('proformaRent')));

      return !Test.isRunningTest() ? EncodingUtil.base64Encode(pageRef.getContentAsPdf()) : '';

    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}