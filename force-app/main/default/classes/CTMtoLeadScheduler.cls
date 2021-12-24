public class CTMtoLeadScheduler implements Schedulable {

  public void execute(SchedulableContext sc) {
    AllCTMtoLeadBatchable b = new AllCTMtoLeadBatchable();
    Date yesterday = System.today().addDays(-1);
    b.startDate = yesterday;
    b.lastDate = yesterday;
    b.endDate = yesterday;
    Database.executeBatch(b);
  }

}