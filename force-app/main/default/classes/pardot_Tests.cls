@isTest
private class pardot_Tests {

	static testMethod void pardot_Batchable_UnitTest(){
		Lead l = new Lead();
		l.Email = 'testCoverage@mkpartners.com';
		l.LastName = 'Test';
		l.Company = 'Test';
		insert l;

		test.startTest();
			Database.executeBatch( new pardot_Batchable('') );
			system.assert( 'QwWsHJyTPW.1pd0_jXlNKOSU' == pardot_Batchable.getSessionId() );
		test.stopTest();
	}

}