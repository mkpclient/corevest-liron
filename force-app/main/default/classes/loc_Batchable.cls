global class loc_Batchable implements Database.Batchable<sObject> {
  global final String queryString;

  public loc_Batchable() {
    queryString = 'SELECT Id, StageName, Current_Line_Maturity_Date__c, Expiration_Date__c, Name FROM Opportunity WHERE ((Expiration_Date__c < TODAY AND StageName = \'Closed Won\') OR (Current_Line_Maturity_Date__c < TODAY AND (StageName = \'Expired\' OR StageName = \'Closed Won\'))) AND RecordType.DeveloperName = \'LOC_Loan\'';
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(queryString);
  }

  public void execute(Database.BatchableContext bc, List<sObject> scope) {
    List<Opportunity> expiredOps = new List<Opportunity>();
    List<Opportunity> maturedOps = new List<Opportunity>();

    List<Opportunity> allOps = new List<Opportunity>();
    for (Opportunity op : (List<Opportunity>) scope) {
      if (
        (op.StageName == 'Expired' || op.StageName == 'Closed Won') &&
        op.Current_Line_Maturity_Date__c <= system.today()
      ) {
        op.StageName = 'Matured';
        maturedOps.add(op);
      } else if (
        op.StageName == 'Closed Won' &&
        op.Expiration_Date__c <= system.today()
      ) {
        op.StageName = 'Expired';
        expiredOps.add(op);
      }
    }

    messaging.singleEmailMessage em = new messaging.SingleEmailMessage();
    String expiredHTML = '';
    String maturedHTML = '';

    for (Opportunity op : maturedOps) {
      maturedHTML += '<tr>';
      maturedHTML += '<td>' + op.Id + '</td>';
      maturedHTML += '<td>' + op.Name + '</td>';
      //maturedHTML += '<td>' + op.Deal_Loan_Number__c + '</td>';
      maturedHTML += '<td>' + op.StageName + '</td>';
      maturedHTML += '<td>' + op.Expiration_Date__c.format() + '</td>';
      maturedHTML +=
        '<td>' +
        op.Current_Line_Maturity_Date__c.format() +
        '</td>';
      maturedHTML += '</tr>';
    }

    for (Opportunity op : expiredOps) {
      expiredHTML += '<tr>';
      expiredHTML += '<td>' + op.Id + '</td>';
      expiredHTML += '<td>' + op.Name + '</td>';
      //expiredHTML += '<td>' + op.Deal_Loan_Number__c + '</td>';
      expiredHTML += '<td>' + op.StageName + '</td>';
      expiredHTML += '<td>' + op.Expiration_Date__c.format() + '</td>';
      expiredHTML +=
        '<td>' +
        op.Current_Line_Maturity_Date__c.format() +
        '</td>';
      expiredHTML += '</tr>';
    }

    if (String.isNotBlank(maturedHTML)) {
      maturedHTML =
        '<table><tr><th>Id</th><th>Deal Name</th><th>Deal Number</th><th>Stage</th><th>Expiration Date</th><th>Current Line Maturity Date</th></tr>' +
        maturedHTML +
        '</table>';
    }

    if (String.isNotBlank(expiredHTML)) {
      expiredHTML =
        '<table><tr><th>Id</th><th>Deal Name</th><th>Deal Number</th><th>Stage</th><th>Expiration Date</th><th>Current Line Maturity Date</th></tr>' +
        expiredHTML +
        '</table>';
    }

    em.setHtmlBody(maturedHTML + expiredHTML);
    em.setToAddresses(
      new List<String>{ 'mcastillo@mkpartners.com', 'bryon@cvest.com' }
    );
    em.setSubject('LOC Stage Updates');

    //Messaging.sendEmail(new Messaging.SingleEmailMessage[]{em});

    allOps.addAll(expiredOps);
    allOps.addAll(maturedOps);

    update allOps;
  }

  public void finish(Database.BatchableContext bc) {
    //reschedule(15);

    system.debug('success');
  }

  public static void reschedule(Integer minutesFromNow) {
    //Set<String> nextIds = new Set<String>();
    // Generate the next list of IDs to be processed

    //String jobName = 'Batch Job for ' + system.now().addMinutes(minutesFromNow).format();
    //System.scheduleBatch(new loc_Batchable( nextIds ), jobName, minutesFromNow, 50);
  }

  public static void processIds(List<String> ids) {
    // Handle the records
  }
}