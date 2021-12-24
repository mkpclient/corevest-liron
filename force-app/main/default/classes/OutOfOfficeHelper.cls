public class OutOfOfficeHelper {
  public static void afterInsert(List<Out_of_Office__c> newList) {
    Set<Id> ids = new Set<Id>();

    final Date TOMORROW = System.today().addDays(1);
    final Date YESTERDAY = System.today().addDays(-1);
    final Date TODAY = System.today();
    for (Out_Of_Office__c oof : newList) {
      if (oof.Start_Date__c <= TODAY && oof.End_Date__c >= YESTERDAY) {
        ids.add(oof.User__c);
      }
    }

    if (ids.size() > 0) {
      updateUsers(ids);
    }
  }

  public static void updateUsers(Set<Id> userIds) {
    List<Janati_RR__Round_Robin_Group_Member__c> toUpdate = new List<Janati_RR__Round_Robin_Group_Member__c>();

    for (Janati_RR__Round_Robin_Group_Member__c rrMember : [
      SELECT Id, Janati_RR__Assignment_Active__c, Janati_RR__User_Rep__c
      FROM Janati_RR__Round_Robin_Group_Member__c
      WHERE Janati_RR__User_Rep__c IN :userIds
    ]) {
      rrMember.Janati_RR__Assignment_Active__c = false;

      toUpdate.add(rrMember);
    }

    if (toUpdate.size() > 0) {
      update toUpdate;
    }
  }
}