global class loc_Schedulable implements Schedulable {

	global void execute(SchedulableContext SC){
		Database.executeBatch(new loc_Batchable());
	}

}