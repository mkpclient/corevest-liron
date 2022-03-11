global class UpdateCloseDateBatch implements Database.Batchable<sObject>{
    String queryString;
    String recordType;
    Map<String, Integer> termDaysMap = new Map<String, Integer>{
        'Initial Review' => 100,
        'Data Tape Received' => 80,
        'Term Sheet Issued' => 65,
        'Term Sheet Signed/Deposit Collected' => 60
    };

    Map<String, Integer> bridgeDaysMap = new Map<String, Integer>{
        'Initial Review' => 65,
        'Term Sheet Issued' => 40,
        'Term Sheet Signed/Deposit Collected' => 30
    }; 

    Map<String, Integer> sabDaysMap = new Map<String, Integer>{
        'Initial Review' => 12
    };

    Map<String, Integer> selectedDaysMap;

    public UpdateCloseDateBatch(String recordType) {
        String queryString = 'SELECT Id, CloseDate, Anticipated_Closing_Date__c, StageName FROM Opportunity WHERE';
        this.recordType = recordType;
        if(recordType == 'Term'){
            this.selectedDaysMap = termDaysMap;
            queryString += ' RecordType.DeveloperName = \'Term_Loan\'';
        }else if(recordType == 'Bridge'){
            this.selectedDaysMap = bridgeDaysMap;
            queryString += ' RecordType.DeveloperName = \'LOC_Loan\'';
        }else if(recordType == 'Single Asset Bridge'){
            this.selectedDaysMap = sabDaysMap;
            queryString += ' RecordType.DeveloperName = \'Single_Asset_Bridge_Loan\'';
        }

        //queryString += ' AND StageName IN : selectedDaysMap.keySet()';
        queryString += ' AND StageName IN (';
        for(String stageName : selectedDaysMap.keySet()){
            queryString += '\'' + stageName + '\','; 
        }

        queryString = queryString.substringBeforeLast(',');
        queryString += ') ORDER BY CloseDate ASC';
        //queryString += ' FOR UPDATE ';
        // queryString += ' AND In_Litigation__c = false';
        // queryString += ' AND Account.In_Litigation__c = false';
        // queryString += ' AND Contact__r.In_Litigation__c = false';
        this.queryString = queryString;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug(queryString);
        return Database.getQueryLocator(this.queryString);

    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        // List<Opportunity> oppsToUpdate = new List<Opportunity>
        for(Opportunity deal : (List<Opportunity>)scope){
            deal.CloseDate = system.today().addDays(selectedDaysMap.get(deal.StageName));
            deal.Anticipated_Closing_Date__c = system.today().addDays(selectedDaysMap.get(deal.StageName));
        }
        // system.debug(scope);
        // system.debug(scope.size());
        update scope;
    }

    global void finish(Database.BatchableContext BC){
        if(this.recordType == 'Term'){
            Database.executeBatch(new UpdateCloseDateBatch('Bridge'), 10);
        }else if(this.recordType == 'Bridge'){
            Database.executeBatch(new UpdateCloseDateBatch('Single Asset Bridge'), 10);
        }
    }

}