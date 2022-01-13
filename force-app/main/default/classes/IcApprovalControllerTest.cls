@isTest
private class IcApprovalControllerTest {


    static void setupTestData(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u){
            List<EmailTemplate> emailTemplates = test_Helper.createEmailTemplates(new List<String>{
                'Bridge_IC_Approval'
                , 'Term_IC_Approval'
                , 'Term_Sub_IC_Approval'
            });
        }
    }

    static TestMethod void IcApprovalControllerTest_UnitTest(){
        List<RecordType> opptyRecordTypes = [SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity'];
        
        Id termLoanRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Term Loan').getRecordTypeId();
        Id bridgeLoanRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Bridge Loan').getRecordTypeId();

        
        Account acc = test_Helper.createAccount();
        Contact cont = test_Helper.createContact( acc );
        Opportunity opp = test_Helper.createOpportunity( acc, cont );
        opp.RecordTypeId = opptyRecordTypes[0].Id;
        opp.Loan_Effective_Date__c = system.today();
        update opp;

        Attachment a = new Attachment(Name='Test',ParentId=opp.Id,Body=blob.valueOf('test'));

        Test.startTest();
        IcApprovalController.Person person = new IcApprovalController.Person().CurrentUser();
        IcApprovalController.returnDeal(opp.Id);

        if (opptyRecordTypes.size() > 1){
            opp.RecordTypeId = termLoanRecordTypeId;
            opp.LOC_Program_Type__c = 'Custom';
            update opp;
            
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(opp.Id);
            Approval.ProcessResult result = Approval.process(req);
            
            List<ProcessInstance> pList = [SELECT Id,(Select Id From Workitems), Status, TargetObjectId, ProcessDefinition.Name FROM ProcessInstance WHERE TargetObjectId = : opp.Id ORDER BY CreatedDate DESC LIMIT 10 ];
            List<Id> newWorkItemIds = new List<Id>();
            if(pList != null && !pList.isEmpty()) {

                for (List<ProcessInstanceWorkitem> wis : pList[0].Workitems) {
                    for (ProcessInstanceWorkitem wi : wis ) {
                        newWorkItemIds.add(wi.id);
                    }
                }

                // Instantiate the new ProcessWorkitemRequest object and populate it
                Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                req2.setComments('Approving request.');
                req2.setAction('Approve');
                req2.setWorkitemId(newWorkItemIds.get(0));
                
                Approval.ProcessResult result2 =  Approval.process(req2);
                
                pList = [SELECT Id, (Select Id From Workitems), Status, TargetObjectId, ProcessDefinition.Name FROM ProcessInstance WHERE TargetObjectId = : opp.Id ORDER BY CreatedDate DESC LIMIT 10 ];
                
            }

            IcApprovalController.returnDeal(opp.Id);
        }

        if (opptyRecordTypes.size() > 2){
            opp.RecordTypeId = opptyRecordTypes[2].Id;
            update opp;
            IcApprovalController.returnDeal(opp.Id);
        }
        List<EmailTemplate> e = IcApprovalController.queryEmailTemplate('Term_IC_Approval');
        IcApprovalController.queryContentVersions( new List<Id>{UserInfo.getUserId()});

        ContentVersion cv = new ContentVersion();
        cv.PathOnClient='/';
        cv.VersionData=blob.valueOf('test');
        IcApprovalController.constructFileAttachment(cv);

        Map<String,String> m = new Map<String,String>();
        m.put('recipients', 'test@test.com');
        m.put('cc', 'test@test.com');
        List<Id> aIds = new List<Id>();
        List<Id> cIds = new List<Id>();

        try {
            Messaging.reserveSingleEmailCapacity(2);
            IcApprovalController.sendMail(
            new List<String>{'test@test.com'}, 'Subject','html', new List<Messaging.EmailFileAttachment>(),
            new List<String>{'test@test.com'}, 'Test', null, null, null, null, null
            );

            IcApprovalController.sendMail(
            new String[]{'logins+cvest@mkpartners.com'}, null, null, null, null,
            'MKP', false, false, cont.Id, e[0].Id, opp.Id
            );
            IcApprovalController.sendEmail(JSON.serialize(m), JSON.serialize(cIds));

        } catch (Exception exc){
            System.debug(exc);
        }
        Test.stopTest();
    }

}