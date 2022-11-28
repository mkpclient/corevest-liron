trigger contact_Trigger on Contact(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete,
  after undelete
) {
  if (Trigger.isBefore && Trigger.isInsert) {
    Contact_Helper.beforeInsert(Trigger.New);
  }

  if (Trigger.isBefore && Trigger.isUpdate) {
    Contact_Helper.beforeUpdate(Trigger.New, Trigger.Old);
  }
  if (Trigger.isBefore && Trigger.isDelete) {
    //  Contact_Helper.beforeDelete(Trigger.New);
  }
  if (Trigger.isAfter && Trigger.isUpdate) {
    Contact_Helper.afterUpdate(Trigger.new, Trigger.Old);
  }
  /* if ( Trigger.isAfter && Trigger.isInsert ) {
        // Contact_Helper.afterInsert(Trigger.New);
    }
    if ( Trigger.isAfter && Trigger.isUpdate ) {
      //  Contact_Helper.afterUpdate(Trigger.New, Trigger.Old);
    }
    if ( Trigger.isAfter && Trigger.isDelete ) {
      //  Contact_Helper.afterDelete(Trigger.New, Trigger.Old);
    }
    if ( Trigger.isAfter && Trigger.isUndelete ) {
      //  Contact_Helper.afterUndelete(Trigger.Old);
    } */

  if (Trigger.IsAfter) {
    set<Id> parentIdsSet = new Set<Id>();
    if (Trigger.IsInsert || Trigger.IsUndelete) {
      for (Contact c : Trigger.new) {
        if (c.AccountId != null) {
          parentIdsSet.add(c.AccountId);
        }
      }
      Contact_Helper.isAfter(parentIdsSet);
    }
    if (Trigger.IsDelete) {
      for (Contact c : Trigger.Old) {
        if (c.AccountId != null) {
          parentIdsSet.add(c.AccountId);
        }
      }
      Contact_Helper.isAfter(parentIdsSet);
    }
    if (Trigger.IsUpdate) {
      Contact_Helper.afterUpdate(Trigger.oldMap, Trigger.new);
      for (Contact c : Trigger.new) {
        if (c.AccountId != null) {
          parentIdsSet.add(c.AccountId);
        }
      }
      for (Contact con : Trigger.Old) {
        if (con.AccountId != null) {
          parentIdsSet.add(con.AccountId);
        }
      }
      Contact_Helper.isAfter(parentIdsSet);
      system.debug('Trigger.Old:::::' + Trigger.Old);
    }
  }
}