@isTest
private class OutOfOfficeSchedulableTests {

    @TestSetup
    static void makeData(){
        // Janati_RR__Round_Robin_Assignment__c assignment = new Janati_RR__Round_Robin_Assignment__c();
        // assignment.Name = 'test';
        // insert assignment;



        // Janati_RR__Round_Robin_Group_Member__c gm = new Janati_RR__Round_Robin_Group_Member__c();
        // gm.Janati_RR__User_Rep__c = UserInfo.getUserId();
        // gm.Janati_RR__Assignment_Active__c = true;
        // gm.Janati_RR__Round_Robin_Assignment__c = assignment.Id;

        // insert gm;
    }

    @IsTest
    static void methodName(){
        User u = [SELECT Id FROM User WHERE Profile.Name = 'Relationship Manager' LIMIT 1];
        Test.startTest();
            Out_of_Office__c oof = new Out_Of_Office__c();
            oof.Start_Date__C = system.today();
            oof.End_Date__c = system.today().addDays(1);
           oof.User__c = u.Id;
            insert oof;

        Test.stopTest();
        
    }
@IsTest
    static void unitTest2(){
        User u = [SELECT Id FROM User WHERE Profile.Name = 'Relationship Manager' LIMIT 1];
        Test.startTest();
            Out_of_Office__c oof = new Out_Of_Office__c();
            oof.Start_Date__C = system.today().addDays(-1);
            oof.End_Date__c = system.today().addDays(-1);
            oof.User__c = u.Id;
            insert oof;

            OutOfOfficeSchedulable.checkOOF();

        Test.stopTest();
    }
@IsTest
    static void unitTest1(){
        User u = [SELECT Id FROM User WHERE Profile.Name = 'Relationship Manager' LIMIT 1];
        Test.startTest();
            Out_of_Office__c oof = new Out_Of_Office__c();
            oof.Start_Date__C = system.today().addDays(1);
            oof.End_Date__c = system.today().addDays(1);
            oof.User__c = u.Id;
            insert oof;

            OutOfOfficeSchedulable.checkOOF();

        Test.stopTest();
    }
}