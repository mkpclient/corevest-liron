global class AppraisalNationSchedulable implements Schedulable {
    global void execute(SchedulableContext SC){
        Database.executeBatch(new AppraisalNationBatch(), 1);
    }
}