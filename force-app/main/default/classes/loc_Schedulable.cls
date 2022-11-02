global class loc_Schedulable implements Schedulable {

	global void execute(SchedulableContext SC){
		Database.executeBatch(new loc_Batchable(),5); //RS.10/17/2022.CIP-2788. Changed Batch size.
	}

}