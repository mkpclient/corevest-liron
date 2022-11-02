public with sharing class AppraisalTriggerHelper {
  public static void afterInsert(List<Appraisal__c> newList) {
    List<Property__c> props = new List<Property__c>();
    for (Integer i = 0; i < newList.size(); i++) {
      Property__c prop = new Property__c();
      Boolean shouldUpdate = false;
      if (
        newList[i].Appraisal_Fee__c != null &&
        newList[i].Property__c != null &&
        newList[i].Delivery_Method__c == 'User Created' &&
        !newList[i].Appraisal_Review_Indication__c
      ) {
        prop.BPO_Appraisal_Fee__c = newList[i].Appraisal_Fee__c;
        shouldUpdate = true;
      }
      if (
        newList[i].Estimated_Completion_Date__c != null &&
        newList[i].Property__c != null &&
        newList[i].Delivery_Method__c == 'User Created' &&
        !newList[i].Appraisal_Review_Indication__c
      ) {
        prop.Appraisal_Due_Date__c = newList[i]
          .Estimated_Completion_Date__c.date();
        shouldUpdate = true;
      }

      if (
        newList[i].Order_Received_Date__c != null &&
        newList[i].Property__c != null &&
        newList[i].Delivery_Method__c == 'User Created' &&
        !newList[i].Appraisal_Review_Indication__c
      ) {
        prop.BPO_Appraisal_Order_Date__c = newList[i]
          .Order_Received_Date__c.date();
        shouldUpdate = true;
      }

      if (shouldUpdate) {
        prop.Id = newList[i].Property__c;
        props.add(prop);
      }
    }

    if (props.size() > 0) {
      updatePropertyFields(props);
    }
    //Property__c
  }

  public static void afterUpdate(
    List<Appraisal__c> oldList,
    List<Appraisal__c> newList
  ) {
    List<Property__c> props = new List<Property__c>();
    for (Integer i = 0; i < newList.size(); i++) {
      Property__c prop = new Property__c();
      Boolean shouldUpdate = false;
      if (
        oldList[i].Appraisal_Fee__c != newList[i].Appraisal_Fee__c &&
        newList[i].Property__c != null &&
        !newList[i].Appraisal_Review_Indication__c
      ) {
        prop.BPO_Appraisal_Fee__c = newList[i].Appraisal_Fee__c;
        shouldUpdate = true;
      }
      if (
        oldList[i].Estimated_Completion_Date__c !=
        newList[i].Estimated_Completion_Date__c &&
        newList[i].Property__c != null &&
        !newList[i].Appraisal_Review_Indication__c
      ) {
        prop.Appraisal_Due_Date__c = newList[i]
          .Estimated_Completion_Date__c.date();
        shouldUpdate = true;
      }

      if (
        oldList[i].Order_Received_Date__c !=
        newList[i].Order_Received_Date__c &&
        newList[i].Property__c != null &&
        !newList[i].Appraisal_Review_Indication__c
      ) {
        prop.BPO_Appraisal_Order_Date__c = newList[i]
          .Order_Received_Date__c.date();
        shouldUpdate = true;
      }

      if (shouldUpdate) {
        prop.Id = newList[i].Property__c;
        props.add(prop);
      }
    }

    if (props.size() > 0) {
      updatePropertyFields(props);
    }
    //Property__c
  }

  public static void updatePropertyFields(List<Property__c> props) {
    Database.update(props, false);
  }
}