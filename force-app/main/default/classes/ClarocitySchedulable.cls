global class ClarocitySchedulable implements Schedulable {
    global void execute(SchedulableContext SC){
        Database.executeBatch(new ClarocityBatch(), 1);
    }
}