@isTest
public with sharing class AppraisalNationSchedulableTest {
  public static testMethod void AppraisalNationSchedulableTest() {
    List<AsyncApexJob> jobsBefore = [
      SELECT Id, ApexClassID, ApexClass.Name, Status, JobType
      FROM AsyncApexJob
    ];
    System.assertEquals(0, jobsBefore.size(), 'not expecting any asyncjobs');
    Test.startTest();
    AppraisalNationSchedulable testSchedule = new AppraisalNationSchedulable();
    String sch = '0 0 23 * * ?';
    String jobId = system.schedule(
      'Appraisal schedule batch test',
      sch,
      testSchedule
    );
    Test.stopTest();
    List<AsyncApexJob> jobsScheduled = [
      SELECT Id, ApexClassID, ApexClass.Name, Status, JobType
      FROM AsyncApexJob
      WHERE JobType = 'ScheduledApex'
    ];
    System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
    System.assertEquals(
      'AppraisalNationSchedulable',
      jobsScheduled[0].ApexClass.Name,
      'expecting specific scheduled job'
    );
    List<AsyncApexJob> jobsApexBatch = [
      SELECT Id, ApexClassID, ApexClass.Name, Status, JobType
      FROM AsyncApexJob
      WHERE JobType = 'BatchApex'
    ];
    System.assertEquals(
      1,
      jobsApexBatch.size(),
      'expecting one apex batch job'
    );
    System.assertEquals(
      'AppraisalNationBatch',
      jobsApexBatch[0].ApexClass.Name,
      'expecting specific batch job'
    );
  }
  public static testMethod void AppraisalNationBatchTest() {
    Account acc = Test_Helper.createAccount();
    Contact cont = Test_Helper.createContact(acc);
    Opportunity opp = Test_Helper.createOpportunity(acc, cont);
    opp.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE DeveloperName = 'Term_Loan' AND sobjecttype = 'Opportunity'
    ]
    .Id;
    update opp;
    List<Property__c> properties = Test_Helper.createProperties(opp);
    Appraisal__c appraisal = Test_Helper.createAppraisal(opp, properties[0]);
    appraisal.Vendor_Ordered_From__c = 'Appraisal Nation';
    appraisal.Prevent_Auto_Refresh__c = false;
    appraisal.Appraisal_Firm_Transaction_ID__c = '30078381';
    update appraisal;
    Test.startTest();
        AppraisalNationBatch testBatch = new AppraisalNationBatch();
        Database.executeBatch(testBatch);
    Test.stopTest();
  }
}