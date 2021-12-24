global class opportunityTaskScheduled implements Schedulable{
    global void execute(SchedulableContext SC) {

        Id tskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Task').getRecordTypeId();
        List<Task> tskToCreate = new List<Task>();

        list<Opportunity> oppLoanProcessing = new list<Opportunity>([SELECT Id, StageName, CloseDate, Loan_Coordinator__c
        FROM Opportunity 
        WHERE StageName ='Loan Processing' 
        AND CloseDate <: System.today()
        AND Loan_Coordinator__c != null]);
system.debug('see here' +oppLoanProcessing.size());
        
        list<Opportunity> oppUnderwriting = new list<Opportunity>([SELECT Id, StageName, CloseDate, Underwriter__c
        FROM Opportunity 
        WHERE StageName ='Underwriting' 
        AND CloseDate <: System.today()
        AND Underwriter__c != null]);
        system.debug('see here' + oppUnderwriting.size());
        
        list<Opportunity> oppApprovedByComm = new list<Opportunity>([SELECT Id, StageName, CloseDate, Closer__c
        FROM Opportunity 
        WHERE StageName ='Approved by Committee' 
        AND CloseDate <: System.today()
        AND Closer__c != null]);
        system.debug('see here' + oppUnderwriting.size());

        if(oppLoanProcessing.size()>0){
            for(Opportunity op : oppLoanProcessing){
                Task t = new Task();
                t.Subject = 'Update Deal Close Date';
                t.RecordTypeId = tskRecordTypeId;
                t.type = 'Other';
                t.OwnerId = op.Loan_Coordinator__c;
                t.WhatId = op.id;
                t.ActivityDate = System.today();

                tskToCreate.add(t);


            }
        }

        if(oppUnderwriting.size()>0){
            for(Opportunity op : oppUnderwriting){
                Task t = new Task();
                t.Subject = 'Update Deal Close Date';
                t.RecordTypeId = tskRecordTypeId;
                t.type = 'Other';
                t.OwnerId = op.Underwriter__c;
                t.WhatId = op.id;
                t.ActivityDate = System.today();
                
                tskToCreate.add(t);



            }
        }
               if(oppApprovedByComm.size()>0){
            for(Opportunity op : oppApprovedByComm){
                Task t = new Task();
                t.Subject = 'Update Deal Close Date';
                t.RecordTypeId = tskRecordTypeId;
                t.type = 'Other';
                t.OwnerId = op.Closer__c;
                t.WhatId = op.id;
                t.ActivityDate = System.today();
                
                tskToCreate.add(t);



            }
        }
        
        if(tskToCreate.size()>0){
            system.debug('see here' + tskToCreate.size());
            insert tskToCreate;
        }

    }
}