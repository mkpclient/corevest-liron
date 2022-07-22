global class OutOfOfficeSchedulable implements Schedulable {
    public OutOfOfficeSchedulable() {

    }
// Enter "OutOfOfficeSchedulable.checkOOF();" into the Anonymous Window to manually run this Apex Scheduled Job
    global void execute(SchedulableContext context){
        
        checkOOF();

    }

    public static void checkOOF(){
        Set<Id> activeIds = new Set<Id>();
        Set<Id> inactiveIds = new Set<Id>();

        final Date TOMORROW = System.today().addDays(1);
        final Date YESTERDAY = System.today().addDays(-1);
		final Date TODAY = System.today();
        for(Out_of_Office__c oof : [SELECT Id, User__c, Start_Date__c, End_Date__c 
                                    FROM Out_Of_Office__c 
                                    WHERE Start_Date__c <= : TOMORROW AND End_Date__c >= : YESTERDAY]){
            if(oof.Start_Date__c <= TOMORROW && oof.End_Date__c > TODAY){
                inactiveIds.add(oof.User__c);
            }

            if(oof.End_Date__c == YESTERDAY){
                activeIds.add(oof.User__c);
            }
        }

        List<Janati_RR__Round_Robin_Group_Member__c> toUpdate = new List<Janati_RR__Round_Robin_Group_Member__c>();

        for(Janati_RR__Round_Robin_Group_Member__c rrMember : [SELECT Id, Janati_RR__Assignment_Active__c, Janati_RR__User_Rep__c
                                                                FROM Janati_RR__Round_Robin_Group_Member__c
                                                                WHERE Janati_RR__User_Rep__c IN : activeIds OR Janati_RR__User_Rep__c IN : inactiveIds]){
            
            if(activeIds.contains(rrMember.Janati_RR__User_Rep__c)){
                rrMember.Janati_RR__Assignment_Active__c = true;
            }

            if(inactiveIds.contains(rrMember.Janati_RR__User_Rep__c)){
                rrMember.Janati_RR__Assignment_Active__c = false;
            }

            toUpdate.add(rrMember);

        }

        if(toUpdate.size() > 0){
            update toUpdate;
        }
    }

}