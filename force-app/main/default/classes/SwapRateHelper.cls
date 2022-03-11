public without sharing class SwapRateHelper {
  public static void beforeInsert(List<Swap_Rate__c> newList) {
    for (Swap_Rate__c sr : newList) {
      if (sr.Name == null) {
        sr.Name = 'Swap-' + System.today();
      }
    }
  }
}