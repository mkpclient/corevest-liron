public without sharing class SwapRateHelper {
  public static void beforeInsert(List<Swap_Rate__c> newList) {
    for (Swap_Rate__c sr : newList) {
      if (sr.Name == null) {
        sr.Name = 'Swap-' + System.today();
      }
    }
  }

  // public static void afterInsert(List<Swap_Rate__c> newList) {
  //     List<Opportunity> dealList = new List<Opportunity>();

  //     dealList = [SELECT Id, Type, Swap_Rate__c FROM Opportunity WHERE Id = '0067f000009HsYAAA0'];

  //     for (Swap_Rate__c sr : newList) {
  //         dealList
  //     }
  // }

  // public static void updateSwapRate(Map<String, List<Opportunity>> swapRateMap) {

  // }
}