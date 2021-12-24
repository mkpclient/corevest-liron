public class Advance_Test_Data_Factory {

    public static List<sObject> queryChildren(String objectName, List<String> additionalFields, String lookupField, Id recordId){
		Set<String> fieldNamesSet = util.getAllFieldNamesForObject(objectName);
		List<String> fieldNames = new List<String>();
		fieldNames.addAll(fieldNamesSet);

		String qs = 'SELECT ';
		for (Integer i = 0; i < fieldNames.size(); i++){
			qs += fieldNames[i];
			if (i < fieldNames.size() - 1){
				qs += ', ';
			}
		}

		if (additionalFields != null){
			for (String s : additionalFields){
				qs += ', ' + s;
			}
		}

		qs += ' FROM ' + objectName + ' WHERE ' + lookupField + ' = \'' + recordId + '\'';

		List<sObject> l = Database.query(qs);

		return l;
	}


}