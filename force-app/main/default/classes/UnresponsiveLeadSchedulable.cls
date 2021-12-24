global class UnresponsiveLeadSchedulable implements Schedulable {
    global void execute(SchedulableContext context){

        updateLeads();

    }
    // Run the below line in the Anonymous Window to run this job
    // UnresponsiveLeadSchedulable.updateLeads();
    global static void updateLeads(){
        Date daysAgo = system.today().addDays(-20);
        if(Test.isRunningTest()){
            daysAgo = system.today().addDays(1);
        }
        List<Lead> updates = new List<Lead>();

        for(Lead l : [SELECT Id FROM Lead WHERE Status = 'Contacted' AND Do_Not_Re_Assign__c = FALSE AND CreatedDate < : daysAgo]){
            l.Status = 'Unresponsive';
            l.Disposition__c = 'No Response';
            l.OwnerId = '0050a00000LMH2UAAX';

            updates.add(l);
        }

        if(updates.size() > 0){
            update updates;
        }
    }
}