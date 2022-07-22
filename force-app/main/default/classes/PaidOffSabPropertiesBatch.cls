public without sharing class PaidOffSabPropertiesBatch implements Database.Batchable<sObject> {
  public Database.QueryLocator start(Database.BatchableContext bc) {
    String queryString = 'SELECT Deal__r.Payoff_Date__c, Id, Status__c, Deal__c, Inactive_Date__c ';
    queryString += 'FROM Property__c WHERE ';
    queryString += 'Deal__r.Record_Type_Name__c = \'Single_Asset_Bridge_Loan\' AND ';
    queryString += 'Deal__r.StageName = \'Paid Off\' AND ';
    queryString += 'Deal__r.LOC_Loan_Type__c =\'Single Asset (1-4 Unit)\' AND ';
    queryString += 'Status__c != \'Paid Off\'';
    return Database.getQueryLocator(queryString);
  }
  public void execute(
    Database.BatchableContext bc,
    List<Property__c> properties
  ) {
    if (properties != null && properties.size() > 0) {
      for (Property__c p : properties) {
        p.Status__c = 'Paid Off';
        p.Inactive_Date__c = p.Deal__r.Payoff_Date__c;
      }

      update properties;
    }
  }
  public void finish(Database.BatchableContext BC) {
    List<AsyncApexJob> jobs = [
      SELECT
        Id,
        status,
        createddate,
        NumberOfErrors,
        JobItemsProcessed,
        TotalJobItems,
        CompletedDate
      FROM AsyncApexJob
      WHERE
        Id = :BC.getJobId()
        AND completeddate > :Datetime.now().addMinutes(-2)
        AND Status IN ('Aborted', 'Completed')
        AND JobType != 'BatchApexWorker'
      ORDER BY createddate DESC
      LIMIT 1
    ];

    if (jobs.size() > 0) {
      sendCompletedEmail(jobs[0]);
    }
  }

  public static void sendCompletedEmail(AsyncApexJob job) {
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

    email.setToAddresses(
      new List<String>{
        'ldecastro@mkpartners.com',
        'logins+cvest@mkpartners.com'
        ,
        'integrations@cvest.com',
        'jonathan.lay@cvest.com',
        'bryon.harland@cvest.com'
      }
    );
    OrgWideEmailAddress owea = new OrgWideEmailAddress();
    owea = [
      SELECT Id, Address, DisplayName
      FROM OrgWideEmailAddress
      WHERE DisplayName = 'Integrations User'
    ];


    String body = 'Batch ' + job.Status + '.\n';
    body += '\nTotal Job Items: ' + job.TotalJobItems;
    body += '\nJob Items Processed: ' + job.JobItemsProcessed;
    body += '\nNumber of Errors: ' + job.NumberOfErrors;
    body += '\nStatus: ' + job.Status;
    body +=
      '\nStarted Date: ' +
      job.CreatedDate.format('MM/dd/yyyy HH:mm:ss', 'America/Los_Angeles');
    body +=
      '\nCompleted Date: ' +
      job.CompletedDate.format('MM/dd/yyyy HH:mm:ss', 'America/Los_Angeles');
    // if (job.NumberOfErrors > 0) {
    //   body += '\n\nPlease refer to separate email with details about the error.';
    // }
    if (owea != null) {
      email.setOrgWideEmailAddressId(owea.Id);
    }

    email.setPlainTextbody(body);
    email.setSubject('Paid Off SAB Properties Batch  ' + job.Status);

    Messaging.sendEmail(new List<Messaging.SIngleEmailMessage>{ email });
  }
}