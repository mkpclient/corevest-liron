@isTest
private class AccountHelperTest {
  @isTest
  static void AccountHelperTest() {
    RecordType vendorRecordType = [
      SELECT Id
      FROM RecordType
      WHERE DeveloperName LIKE '%vendor%'
      LIMIT 1
    ];
    account myAcc = new account();
    myAcc.name = 'test acc rec';
    myAcc.phone = '1234567890';
    myAcc.Alternate_Phone__c = '1234567890';
    myAcc.Do_Not_Lend__c = false;
    myAcc.recordTypeId = vendorRecordType.Id;
    myAcc.Non_Borrower_Account_Type__c = 'Title and Escrow';

    insert myAcc;

    contact myCon = new contact();
    myCon.FirstName = 'test';
    myCon.LastName = 'testlast';
    myCon.AccountId = myAcc.id;

    insert myCon;

    myAcc.phone = '1235456881';
    myAcc.Alternate_Phone__c = '5678523457';
    myAcc.Do_Not_Lend__c = true;

    update myAcc;

    myAcc.Do_Not_Lend__c = false;
    myAcc.Yardi_Vendor_Code__c = null;

    update myAcc;
  }
}