global class UpdateClosedDateSchedulable implements Schedulable {
  global void execute(SchedulableContext context) {
    Database.executeBatch(new UpdateCloseDateBatch('Term'), 10);
    //Database.executeBatch(new UpdateCloseDateBatch('Bridge'));
    //Database.executeBatch(new UpdateCloseDateBatch('Single Asset Bridge'));
  }
}