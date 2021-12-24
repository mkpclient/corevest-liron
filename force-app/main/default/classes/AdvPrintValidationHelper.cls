public with sharing class AdvPrintValidationHelper {
  @auraEnabled
  public static List<Object> describePicklist(
    String sobjectType,
    String fieldName
  ) {
    Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sobjectType);
    Schema.DescribeFieldResult fieldResult = targetType.getDescribe()
      .fields.getMap()
      .get(fieldName)
      .getDescribe();
    List<Schema.PicklistEntry> PL = fieldResult.getPicklistValues();
    return (List<Object>) JSON.deserializeUntyped(JSON.serialize(pl));
  }

  @auraEnabled
  public static List<List<Object>> doQueries(List<String> queryStrings) {
    List<List<Object>> results = new List<List<Object>>();
    for (String queryString : queryStrings) {
      if (queryString.startsWith('DESCRIBEFIELD')) {
        String sobjectType = queryString.subStringBetween('DESCRIBEFIELD', '.')
          .trim();
        String fieldName = queryString.subStringAfter('.').trim();
        results.add(describePicklist(sobjectType, fieldName));
      } else {
        List<sObject> r = database.query(queryString);
        if (r.size() > 0 && r[0] instanceof StaticResource) {
          results.add(
            new List<String>{ ((StaticResource) r[0]).Body.toString() }
          );
        } else {
          results.add(r);
        }
      }
    }
    return results;
  }
}