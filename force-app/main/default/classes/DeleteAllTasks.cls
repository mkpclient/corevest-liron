global class DeleteAllTasks implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        return Database.getQueryLocator('SELECT Id FROM Task');
      }
      public void execute(Database.BatchableContext bc, List<Task> scope) {
        delete scope;
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
            'jonathan.lay@cvest.com'
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
        email.setSubject('Delete Tasks ' + job.Status);
    
        Messaging.sendEmail(new List<Messaging.SIngleEmailMessage>{ email });
      }
}