public without sharing class UserHelper {
  public static void afterUpdate(List<User> newList, List<User> oldList) {
    List<Id> userIds = new List<Id>();

    for (Integer i = 0; i < newList.size(); i++) {
      if (
        String.isBlank(newList[i].Portal_Id__c) &&
        newList[i].Create_Operations_Portal_User__c &&
        newList[i].Create_Operations_Portal_User__c !=
        oldList[i].Create_Operations_Portal_User__c
      ) {
        userIds.add(newList[i].Id);
      }
    }

    if (userIds.size() > 0) {
      system.enqueueJob(
        new UpdatePortalUserQueueable(userIds, 'createOperationsUser')
      );
    }
  }
}