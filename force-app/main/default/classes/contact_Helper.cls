public class contact_Helper {
  public static Map<String, Schema.SObjectField> FIELD_MAP = Schema.SObjectType.Contact.fields.getMap();

  /**
   * @name beforeInsert
   * @description
   * @param
   **/
    public static void beforeInsert(List<Contact> newList) {
        for (Integer i = 0; i < newList.size(); i++) {
            if (String.isNotBlank(newList[i].Phone)) {
                newList[i].Phone = util.formatPhone(newList[i].Phone);
            }

            if (String.isNotBlank(newList[i].MobilePhone)) {
                newList[i].MobilePhone = util.formatPhone(newList[i].MobilePhone);
            }
        }
    }

  /**
   * @name afterInsert
   * @description
   * @param
   **/
  //public static void afterInsert(List<Contact> newList){
  //    for ( Integer i=0;i<newList.size();i++ ){

  //    }
  //}

  /**
   * @name beforeUpdate
   * @description
   * @param
   **/
    public static void beforeUpdate(
        List<Contact> newList,
        List<Contact> oldList
        ) {
        for (Integer i = 0; i < newList.size(); i++) {
            if (newList[i].Phone != oldList[i].Phone) {
                if (String.isNotBlank(newList[i].Phone)) {
                  newList[i].Phone = util.formatPhone(newList[i].Phone);
                }
            }

            if (newList[i].MobilePhone != oldList[i].MobilePhone) {
                if (String.isNotBlank(newList[i].MobilePhone)) {
                  newList[i].MobilePhone = util.formatPhone(newList[i].MobilePhone);
                }
            }
        }
    }

    public static void afterUpdate(List<Contact> newList){
    //Related account list
        list<id> myAcc = new list<id>();
        for(Contact con : newList){
            if (con.In_Litigation__c == true){
                myAcc.add(con.AccountId);
            }
        }
        if(myAcc.size()>0){
            list<account> myAccs = new list<account>();
            list<account> accToUpdate = [SELECT Do_Not_Lend__c from Account where ID in :myAcc];
            for(account acc : accToUpdate){
                acc.In_Litigation__c = true;
            }
            if(accToUpdate.size()>0){
                update accToUpdate;
            }
        }
    }


    public static void isAfter(set<Id> parentIdsSet) {
        List<Account> accountListToUpdate = new List<Account>();
        List<Account> accountList = new List<Account>(
            [
                SELECT id, Name, Number_of_Contacts__c, (SELECT id, Name FROM Contacts)
                FROM Account
                WHERE id IN :parentIdsSet
            ]
        );
        for (Account acc : accountList) {
            List<Contact> contactList = acc.Contacts;
            acc.Number_of_Contacts__c = acc.Contacts.size();
            accountListToUpdate.add(acc);
        }
        system.debug('accountListToUpdate:::' + accountListToUpdate);
        try {
            if (accountListToUpdate != null && accountListToUpdate.size() > 0) {
                update accountListToUpdate;
            }
        } catch (System.Exception e) {
            system.debug('Exception::::::' + e.getLineNumber());
        }
    }

  /**
   * @name afterUpdate
   * @description
   * @param
   **/
  //public static void afterUpdate(List<Contact> newList, List<Contact> oldList){

  //   Map<Id, Id> contactOwnerMap = new Map<Id, Id>();

  //   for ( Integer i=0;i<newList.size();i++ ){

  //       if(newList[i].OwnerId != oldList[i].OwnerId){
  //           contactOwnerMap.put(newList[i].Id, newList[i].OwnerId);
  //       }
  //   }
  //   if(contactOwnerMap.values().size() > 0){
  //       updateLeadOwners(contactOwnerMap);
  //   }
  //}

  /**
   * @name beforeDelete
   * @description
   * @param
   **/
  //public static void beforeDelete(List<Contact> newList){
  //    for ( Integer i=0;i<newList.size();i++ ){

  //    }
  //}

  /**
   * @name afterDelete
   * @description
   * @param
   **/
  //public static void afterDelete(List<Contact> newList, List<Contact> oldList){
  //}

  /**
   * @name afterUndelete
   * @description
   * @param
   **/
  //public static void afterUndelete(List<Contact> oldList){
  //    for ( Integer i=0;i<oldList.size();i++ ){

  //    }
  //}

  //public static void updateLeadOwners(Map<Id, Id> contactOwnerMap){
  //    List<Lead> leads = new List<Lead>();
  //    for(Lead l : [SELECT Id, ConvertedContactId, OwnerId FROM Lead where ConvertedContactId IN : contactOwnerMap.keySet()]){
  //        l.ownerId = contactOwnerMap.get(l.ConvertedContactId);
  //       leads.add(l);
  //   }

  //   upsert leads;
  //}
}