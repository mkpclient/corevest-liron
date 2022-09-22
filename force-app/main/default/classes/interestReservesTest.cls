@isTest

private class interestReservesTest {
    @isTest static void interestReservesTest1(){
        test_Helper.createDealLoanNumber();
 Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
    Opportunity opp = test_Helper.createOpportunity(acc, cont);
system.debug('deal created'+opp.id);
        
    Property__c property = new Property__c();
    property.Name = 'Test1';
    property.Deal__c = opp.Id;
    property.Escrow_Company_text__c = 'ESCROW';
    property.Insurance_Company_text__c = 'INSURANCE';
    property.Status__c = 'Pending';
    property.Override_Origination_Fee__c = 1000;
    property.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE
        sobjecttype = 'Property__c'
        AND DeveloperName = 'Bridge_No_Renovation'
    ]
    .Id;

    insert property;
    system.debug('prop1 created'+property.id);

    
        Test.startTest();
    Interest_Reserves__c ir = new Interest_Reserves__c();
    				 ir.Property__c = property.id;
    				 ir.Date__c = system.today();
    				 ir.Interest_Reserves_Payment__c = 1000;
    insert ir;
    system.debug('ir created'+ir.id);
        
   Property__c property2 = new Property__c();
    property2.Name = 'Test123';
    property2.Deal__c = opp.Id;
    property2.Escrow_Company_text__c = 'ESCROW';
    property2.Insurance_Company_text__c = 'INSURANCE';
    property2.Status__c = 'Pending';
    property2.Override_Origination_Fee__c = 1000;
    property2.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE
        sobjecttype = 'Property__c'
        AND DeveloperName = 'Bridge_No_Renovation'
    ]
    .Id;

    insert property2;
        
    system.debug('prop2 created'+property2.id);
   Interest_Reserves__c irToUpdate = [SELECT ID, Property__c FROM Interest_Reserves__c WHERE Id =:ir.Id ];
        system.debug('irToUpdate'+irToUpdate.id);
    irToUpdate.Property__c = property2.id;
    update irToUpdate;
test.stopTest();
    }
}