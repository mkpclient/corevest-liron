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

        for (Property__c p : [
            SELECT Id, Refinance_Acquisition__c,Acquisition_Date__c, Property_Type__c,Number_of_Units__c,Occupancy_Pct__c,Year_Built__c,BPO_Appraisal_Date__c
            FROM Property__c
            WHERE Id IN (SELECT Property__c FROM Property_Advance__c WHERE Advance__c = :this.record.Id)
        ]) {
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