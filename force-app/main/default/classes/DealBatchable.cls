global class DealBatchable implements Database.Batchable<sObject> {
  global final string templateDevName = 'Maturity_Date_Set_90_Days_From_Closing_1629747499258';

  global Database.QueryLocator start(Database.BatchableContext context) {
    Date dateLimit = Date.today().addDays(-90);
    return Database.getQueryLocator(
      ('SELECT Id, LOC_Term__c, Advance_Period__c' +
      ' FROM Opportunity' +
      ' WHERE' +
      ' Maturity_Date_Calculation_Type__c = \'Fixed at First Advance\'' +
      ' AND Stated_Maturity_Date__c = NULL' +
      ' AND CloseDate <= ' +
      Datetime.newInstance(dateLimit.year(), dateLimit.month(), dateLimit.day())
        .format('yyy-MM-dd'))
    );
  }

  public void execute(
    Database.BatchableContext context,
    List<Opportunity> deals
  ) {
    List<Opportunity> updatedDeals = new List<Opportunity>();
    List<Id> dealIds = new List<Id>();

    System.debug('Scheduled process starts here with deals : ' + deals);
    for (Opportunity deal : deals) {
      Opportunity updDeal = new Opportunity();
      Integer locTerm = Integer.valueOf(deal.LOC_Term__c.split(' ')[0]);
      updDeal.Id = deal.Id;
      updDeal.Stated_Maturity_Date__c = deal.CloseDate.addDays(locTerm);
      updDeal.Updated_Loan_Maturity_Date__c = deal.CloseDate.addDays(locTerm);
      updDeal.Modified_Expiration_Date__c = deal.CloseDate
        .addDays(Integer.valueOf(deal.Advance_Period__c));
      dealIds.add(deal.Id);
      updatedDeals.add(updDeal);
    }

    update updatedDeals;

    EmailTemplate tpl = [
      SELECT Id
      FROM EmailTemplate
      WHERE DeveloperName = :templateDevName
      LIMIT 1
    ];

    for (Opportunity deal : updatedDeals) {
      System.debug('Scheduled process loops through email method here.');
      AdvanceDealTriggerHelper.sendEmailForDealTrigger(deal.Id, tpl.Id);
    }

    System.debug('Scheduled process ends here');
  }

  public void finish(Database.BatchableContext context) {
    system.debug('Scheduled process success');
  }
}