public class AllCTMtoLeadBatchable implements Database.Batchable<sObject>, Database.AllowsCallouts {

	public Date startDate;
	public Date endDate;
	public Date lastDate;
	public Boolean globalJob;

	public AllCTMtoLeadBatchable() {
		endDate = System.today();
		startDate = endDate.addDays(-10);
		lastDate = Date.newInstance(2015, 1, 1);
		globalJob = False;
	}

	public List<User> start(Database.BatchableContext BC) {
		System.debug('start');
		List<User> users = [SELECT Id FROM User LIMIT 1];
		return users;
	}

	public void execute(Database.BatchableContext BC, List<sObject> scope) {
		System.debug('execute');
		CTMtoLead.updateLeads(startDate, endDate, globalJob);
	}

	public void finish(Database.BatchableContext BC){
		System.debug('finish');
		if (startDate != null && endDate != null && lastDate != null && endDate > lastDate) {
			System.debug('reschedule');
			AllCTMtoLeadBatchable b = new AllCTMtoLeadBatchable();
			b.endDate = startDate.addDays(-1);
			b.startDate = b.endDate.addDays(-10);
			System.debug(b.endDate);
			System.debug(b.startDate);
			b.lastDate = lastDate;
			System.scheduleBatch(b, 'AllCTMtoLeadBatchable ' + Math.random()+system.now().addMinutes(1).format(), 1);
		}
	}

}