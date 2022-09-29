public without sharing class AdvanceFundingMemoController {
  public String actualDscr { get; set; }
  public Decimal actualLtv { get; set; }
  public Decimal actualDebtYield { get; set; }
  public Advance__c record { get; set; }

  public AdvanceFundingMemoController(
    ApexPages.standardController standardController
  ) {
    this.record = (Advance__c) standardController.getRecord();
    this.actualLtv = Decimal.valueOf(
      ApexPages.currentPage().getParameters().get('actualLtv')
    );
    this.actualDebtYield = Decimal.valueOf(
      ApexPages.currentPage().getParameters().get('actualDebtYield')
    );
    this.actualDscr = ApexPages.currentPage().getParameters().get('actualDscr');
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

        for (Property__c p : [
            SELECT Id, Refinance_Acquisition__c,Property_Type__c,Number_of_Units__c,Occupancy_Pct__c,Year_Built__c
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
        }

        pd.transactionType = String.join(new List<String>(transacTypes), ', ');
        pd.propertyType = String.join(new List<String>(propTypes), ', ');
        if(validOccCount > 0) {
            pd.occupancy = occupancyTotal / validOccCount;

        }
        if( validYearBuiltCount > 0) {
            pd.avgYearBuilt = yearBuiltTotal / validYearBuiltCount;
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
  }
}