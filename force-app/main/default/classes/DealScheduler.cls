global class DealScheduler implements Schedulable {
  global void execute(SchedulableContext context) {
    System.debug('Schedulable process is executed');
    Database.executeBatch(new DealBatchable());
  }
}