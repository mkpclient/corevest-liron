public class parseCSV_Queueable implements Queueable{
	
	private Map<String, sObject> records;
	private List<mapWrapper> mappings;
	private List<List<String>> rows;
	private Integer rowsToParse;
	private String externalKey;

	public parseCSV_Queueable(Map<String, sobject> records, List<List<String>> rows, List<mapWrapper> mappings, Integer rowsToParse, String externalKey ){
		this.records = records;
		this.mappings = mappings;
		this.rowsToParse = rowsToParse;
		this.rows = rows;
		this.externalKey = externalKey;

	}

	public void execute(queueableContext context){
        		String sobjectType = mappings[0].mapping.sobject__c;


		Schema.SObjectType objectType = Schema.getGlobalDescribe().get( sobjectType );
        Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();

        Integer originalSize = rows.size();
        Integer stoppingRow = originalSize >= rowsToParse ? (originalSize - rowsToParse) : 0;

        for(Integer i = originalSize - 1; i >= stoppingRow; i-- ){
        	sObject record = Schema.getGlobalDescribe().get(sobjectType).newSObject();
        	for(mapWrapper wrapper  : mappings){
        	    String fieldType = String.valueOf(fieldMap.get( wrapper.mapping.Field_Name__c ).getDescribe().getType());
 
        	    if (fieldType == 'STRING' || fieldType == 'ID' || fieldType == 'URL' || fieldType == 'EMAIL' || fieldType == 'PHONE' || fieldType == 'TEXTAREA' || fieldType == 'REFERENCE' || fieldType == 'PICKLIST') {
        	        record.put( wrapper.mapping.Field_Name__c, String.valueOf( rows[i][wrapper.index] ) );
        	    }
        	    else if (fieldType == 'INTEGER') {
        	        record.put( wrapper.mapping.Field_Name__c, Integer.valueOf( rows[i][wrapper.index] ) );
        	    }
        	    else if (fieldType == 'DOUBLE' || fieldType == 'CURRENCY' || fieldType == 'PERCENT') {
        	        //if(s == 'Rate__c'){
        	        //  record.put( integrationToSalesforceFieldMap.get( s ), Double.valueOf( valueMap.get( s.replace('%', '') ) ) );
        	        //}else{
        	        if(rows[i][wrapper.index] != null && rows[i][wrapper.index] != '\N'){
        	            record.put( wrapper.mapping.Field_Name__c, Double.valueOf( String.valueOf(rows[i][wrapper.index]).replace('%', '') ) );
        	        }else{
        	            record.put( wrapper.mapping.Field_Name__c, Double.valueOf( rows[i][wrapper.index] ) );
        	        } 
        	        //}
        	        
        	    }
        	    else if (fieldType == 'DATE' && String.valueOf( rows[i][wrapper.index] ) != null && String.valueOf( rows[i][wrapper.index] ) != '\N'  && String.valueOf( rows[i][wrapper.index] ) != '\\N'   ) {
        	        

                    String val = rows[i][wrapper.index];
                    //system.debug(val + ' ' + i + ' ' + wrapper.index);
                    
                    if(String.isNotBlank(val)){
                        if(val.contains(' ')){
                            val = val.split(' ')[0];
                        }

                        
                        if(val.contains('/')){
                            List<String> splits = val.split('/');
                            if(splits[0].length() == 1 || splits[0].length() == 2){
                                String val1 = splits[2];
                                String val2 = splits[0].length() == 1 ? ('0' + splits[0]) : splits[0];
                                String val3 = splits[1].length() == 1 ? ('0' + splits[1]) : splits[1];

                                val = val1 + '-' + val2 + '-' + val3; 
                            }
                        }

                        record.put( wrapper.mapping.Field_Name__c, Date.valueOf( String.valueOf( val ) ) );
                    }else{
                        record.put( wrapper.mapping.Field_Name__c, null );
                    }
                    
        	    }
        	    else if (fieldType == 'DATETIME') {
        	        record.put( wrapper.mapping.Field_Name__c, Datetime.valueOf( rows[i][wrapper.index] ) );
        	    }
        	    else if (fieldType == 'BOOLEAN') {
        	        record.put( wrapper.mapping.Field_Name__c, Boolean.valueOf( rows[i][wrapper.index] ) );
        	    }
        	}

        	record.put('Last_Servicer_Import__c', system.today());
            //system.debug(record);

        	records.put(String.valueOf(record.get(externalKey)), record);
        	//records.add(record);
            //system.debug(records);
        	rows.remove(i);
        }

        if(rows.size() > 0){
            system.debug(JSON.serialize(mappings));
            system.debug(externalKey);

        	system.debug('enqueing another job');
        	System.enqueueJob(new parseCSV_Queueable( records, rows, mappings, 1000, externalKey ));

        }else{
        	//system.debug(LoggingLevel.WARN, 'done');
        	//system.debug(LOGGINGLEVEL.WARN, records.size());
        	//Map<String, List<sObject>> sobjectMap = new Map<String, List<sObject>>();

        	//String externalId = 

        	String queryString = 'SELECT Id, ' + externalKey + ' FROM ' + sobjectType + ' WHERE ' + externalKey + ' IN (';
        	for(String val : records.keySet()){
        		queryString += '\'' + val + '\',';
        	}

        	queryString = queryString.subStringBeforeLast(',');
        	queryString += ')';

        	//: records.keySet()';
        	system.debug(queryString);
        	for(sobject r : database.query(queryString) ){
        		//Id i = r.get('Id');
        		records.get((String)r.get(externalKey)).put('Id', r.get('Id'));
        	}

        	Database.update(records.values(), false);



        }

        //system.debug(LoggingLevel.WARN, JSON.serialize(records));


	}


	public class mapWrapper{
        public Import_Configuration__mdt mapping;
        public Integer index;

        public mapWrapper(){

        }

        public mapWrapper(Import_Configuration__mdt mapping, Integer index){
            this.mapping = mapping;
            this.index = index;
        }
    }

}