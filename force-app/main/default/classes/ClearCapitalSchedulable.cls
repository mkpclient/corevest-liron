global class ClearCapitalSchedulable implements Schedulable {
    global void execute(SchedulableContext SC){
        Database.executeBatch(new ClearCapitalBatch(), 1);
    }
}