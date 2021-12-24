public class AccountHelper {
  // function to run before insertting an Account record

  public static Map<String, RecordType> RECORDTYPE_MAP = util.compileRecordTypeMap(
    'Account'
  );

  private static RecordType vendorRecordType = [
    SELECT Id
    FROM RecordType
    WHERE DeveloperName LIKE '%vendor%'
    LIMIT 1
  ];

  public static void beforeInsert(List<Account> newList) {
    Set<String> accountNameStarts = new Set<String>();
    for (Integer i = 0; i < newList.size(); i++) {
      if (yardiVendorNeedsUpdate(newList[i])) {
        String firstThree = getFirstThree(newList[i].Name);
        accountNameStarts.add(firstThree);
        newList[i].Yardi_Vendor_Code_Initials__c = firstThree;
      }
      if (String.isNotBlank(newList[i].Phone)) {
        newList[i].Phone = util.formatPhone(newList[i].Phone);
      }
      if (String.isNotBlank(newList[i].Alternate_Phone__c)) {
        newList[i].Alternate_Phone__c = util.formatPhone(
          newList[i].Alternate_Phone__c
        );
      }
      if (newList[i].Applicant_Type_From_Lead__c == 'Borrower') {
        newList[i].RecordTypeId = RECORDTYPE_MAP.get('Borrower').Id;
      } else if (newList[i].Applicant_Type_From_Lead__c == 'Broker') {
        newList[i].RecordTypeId = RECORDTYPE_MAP.get('Broker').Id;
      } else if (newList[i].Applicant_Type_From_Lead__c == 'Lender') {
        newList[i].RecordTypeId = RECORDTYPE_MAP.get('Lender').Id;
      }
    }
    Map<String, Decimal> highestNumberMap = queryAccountsForYardiVendor(
      accountNameStarts
    );
    for (Integer i = 0; i < newList.size(); i++) {
      if (yardiVendorNeedsUpdate(newList[i])) {
        newList[i].Yardi_Vendor_Code_Number__c =
          highestNumberMap.get(newList[i].Yardi_Vendor_Code_Initials__c) + 1;
        newList[i].Yardi_Vendor_Code__c =
          'SF' +
          newList[i].Yardi_Vendor_Code_Initials__c +
          ('0' + newList[i].Yardi_Vendor_Code_Number__c).right(2);
        highestNumberMap.put(
          newList[i].Yardi_Vendor_Code_Initials__c,
          newList[i].Yardi_Vendor_Code_Number__c
        );
      }
    }
  }

  // function to run before an Account is edited
  public static void beforeUpdate(
    List<Account> newList,
    List<Account> oldList
  ) {
    Set<String> accountNameStarts = new Set<String>();
    for (Integer i = 0; i < newList.size(); i++) {
      if (yardiVendorNeedsUpdate(newList[i])) {
        String firstThree = getFirstThree(newList[i].Name);
        accountNameStarts.add(firstThree);
        newList[i].Yardi_Vendor_Code_Initials__c = firstThree;
      }
      if (newList[i].Phone != oldList[i].Phone) {
        if (String.isNotBlank(newList[i].Phone)) {
          newList[i].Phone = util.formatPhone(newList[i].Phone);
        }
      }
      if (newList[i].Alternate_Phone__c != oldList[i].Alternate_Phone__c) {
        if (String.isNotBlank(newList[i].Alternate_Phone__c)) {
          newList[i].Alternate_Phone__c = util.formatPhone(
            newList[i].Alternate_Phone__c
          );
        }
      }
    }
    Map<String, Decimal> highestNumberMap = queryAccountsForYardiVendor(
      accountNameStarts
    );
    for (Integer i = 0; i < newList.size(); i++) {
      if (yardiVendorNeedsUpdate(newList[i])) {
        system.debug('MAP:::' + json.serializePretty(highestNumberMap));
        newList[i].Yardi_Vendor_Code_Number__c =
          highestNumberMap.get(newList[i].Yardi_Vendor_Code_Initials__c) + 1;
        newList[i].Yardi_Vendor_Code__c =
          'SF' +
          newList[i].Yardi_Vendor_Code_Initials__c +
          ('0' + newList[i].Yardi_Vendor_Code_Number__c).right(2);
        highestNumberMap.put(
          newList[i].Yardi_Vendor_Code_Initials__c,
          newList[i].Yardi_Vendor_Code_Number__c
        );
      }
    }
  }

  public static void afterUpdate(List<Account> newList) {
    list<contact> contactList = new List<contact>();
    list<id> doNotLendList = new List<id>();
    list<id> lendList = new List<id>();

    for (account acc : newList) {
      if (acc.Do_Not_Lend__c == true) {
        doNotLendList.add(acc.id);
      } else if (acc.Do_Not_Lend__c == false) {
        lendList.add(acc.id);
      }
    }

    if (doNotLendList.size() > 0) {
      contactList = [
        SELECT id, HasOptedOutOfEmail
        FROM contact
        WHERE HasOptedOutOfEmail != TRUE AND AccountId IN :doNotLendList
      ];
      if (contactList.size() > 0) {
        for (contact con : contactList) {
          con.HasOptedOutOfEmail = true;
          con.DNE_Updated_by_Trigger__c = true;
        }
        update contactList;
      }
    } else if (lendList.size() > 0) {
      contactList = [
        SELECT id, HasOptedOutOfEmail
        FROM contact
        WHERE DNE_Updated_by_Trigger__c = TRUE AND AccountId IN :lendList
      ];
      if (contactList.size() > 0) {
        for (contact con : contactList) {
          con.HasOptedOutOfEmail = false;
          con.DNE_Updated_by_Trigger__c = false;
        }
        update contactList;
      }
    }
  }

  private static String getFirstThree(String name) {
    String modifiedName = name.replaceAll('[^a-zA-Z\\s+]', '');
    System.debug(modifiedName);
    List<String> nameList = modifiedName.split(' ');
    for (Integer i = (nameList.size() - 1); i >= 0; i--) {
      String s = nameList[i];
      if (String.isBlank(s)) {
        nameList.remove(i);
      }
    }
    System.debug(nameList);
    String returnName = '';
    if (nameList.size() == 1) {
      returnName += nameList[0].left(3).toUpperCase();
    } else if (nameList.size() == 2) {
      returnName += (nameList[0].left(1) + nameList[1].left(2)).toUpperCase();
    } else {
      returnName += (nameList[0].left(1) +
        nameList[1].left(1) +
        nameList[2].left(1))
        .toUpperCase();
    }

    return returnName;
  }

  private static Boolean yardiVendorNeedsUpdate(Account a) {
    return (a.RecordTypeId == vendorRecordType.Id &&
    a.Non_Borrower_Account_Type__c == 'Title and Escrow' &&
    String.isBlank(a.Yardi_Vendor_Code__c));
  }

  private static Map<String, Decimal> queryAccountsForYardiVendor(
    Set<String> nameStarts
  ) {
    List<AggregateResult> res = [
      SELECT
        MAX(Yardi_Vendor_Code_Number__c) num,
        Yardi_Vendor_Code_Initials__c prefix
      FROM Account
      WHERE
        Yardi_Vendor_Code_Initials__c IN :nameStarts
        AND Yardi_Vendor_Code_Number__c != NULL
      GROUP BY Yardi_Vendor_Code_Initials__c
    ];
    Map<String, Decimal> resMap = new Map<String, Decimal>();
    if (res.size() > 0) {
      for (AggregateResult ar : res) {
        resMap.put(
          String.valueOf(ar.get('prefix')).toUpperCase(),
          (Decimal) ar.get('num')
        );
      }
    } else {
      for (String name : nameStarts) {
        resMap.put(name, 0);
      }
    }

    return resMap;
  }
}