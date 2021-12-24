public with sharing class ValidatedAddressController {
  public static Map<String, String> MERGE_MAP = new Map<String, String>{
    'VAddress1__c' => 'Name',
    'Vcity_name__c' => 'City__c',
    'Vstate_abbreviation__c' => 'State__c',
    'Vzipcode__c' => 'ZipCode__c',
    'Vcounty_name__c' => 'County__c'
  };

  public static Map<String, Schema.SObjectField> VALIDATEDADDRESS_FIELD_MAP = Schema.SObjectType.Validated_Property_Address__c.fields.getMap();
  public static Map<String, Schema.SObjectField> PROPERTY_FIELD_MAP = Schema.SObjectType.Property__c.fields.getMap();

  @AuraEnabled
  public static List<List<MergeWrapper>> initMergeScreen(String recordId) {
    String queryString = compileQueryString(recordId);

    List<MergeWrapper> wrappers = new List<MergeWrapper>();
    for (
      Validated_Property_Address__c validatedAddress : (List<Validated_Property_Address__c>) database.query(
        queryString
      )
    ) {
      wrappers.add(new MergeWrapper(validatedAddress));
    }

    Map<Id, List<MergeWrapper>> mergeMap = new Map<Id, List<MergeWrapper>>();
    for (MergeWrapper wrapper : wrappers) {
      if (!mergeMap.containsKey(wrapper.propertyId)) {
        mergeMap.put(wrapper.propertyId, new List<MergeWrapper>());
      }
      mergeMap.get(wrapper.propertyId).add(wrapper);
    }

    for (
      Property__c p : (List<Property__c>) database.query(
        compilePropertyQueryString(recordId)
      )
    ) {
      mergeMap.put(p.Id, new List<MergeWrapper>{ new MergeWrapper(p) });
    }

    return mergeMap.values();
  }

  public static string compileQueryString(String dealId) {
    String queryString = 'SELECT Id, ';
    for (String validatedAddressField : MERGE_MAP.keySet()) {
      queryString += validatedAddressField + ', ';
      if (String.isNotBlank(MERGE_MAP.get(validatedAddressField))) {
        queryString +=
          'Property__r.' +
          MERGE_MAP.get(validatedAddressField) +
          ', ';
      }
    }

    queryString += 'Property__c';

    //queryString = queryString.substringBeforeLast(',');

    queryString +=
      ' FROM Validated_Property_Address__c WHERE DealId__c =\'' +
      dealId +
      '\'';
    //queryString += ' AND Property__r.Is_Parent__c = false';
    queryString += ' AND Property__c != null';
    queryString += ' AND Property__r.Status__c NOT IN (\'Rescinded\',\'Cancelled\',\'Sold\',\'Inactive\')';
    queryString += ' AND Property__r.Is_Parent__c = false';
    queryString += ' AND Has_Same_Name__c = false';
    queryString += ' Order By CreatedDate DESC';
    //system.debug('--query string--');
    //system.debug(queryString);
    return queryString;
  }

  public static string compilePropertyQueryString(String dealId) {
    String queryString = 'SELECT Id, ';
    for (String validatedAddressField : MERGE_MAP.keySet()) {
      //queryString += validatedAddressField + ', ';
      if (String.isNotBlank(MERGE_MAP.get(validatedAddressField))) {
        queryString += MERGE_MAP.get(validatedAddressField) + ', ';
      }
    }

    //queryString += 'Property__c';

    queryString = queryString.substringBeforeLast(',');

    queryString += ' FROM Property__c WHERE Deal__c =\'' + dealId + '\'';
    queryString += ' AND ID NOT IN (select property__c from Validated_Property_Address__c) ';
    // queryString += ' AND Property__c != null';
    // queryString += ' AND Status__c = "Active"';
    queryString += ' AND Is_Parent__c = false';
    // queryString += ' AND Has_Same_Name__c = false';
    queryString += ' Order By CreatedDate DESC';
    return queryString;
  }

  public class MergeField {
    @AuraEnabled
    public String propertyFieldLabel;
    @AuraEnabled
    public String propertyAPIFieldName;
    @AuraEnabled
    public String propertyFieldType;
    @AuraEnabled
    public Object propertyValue;

    @AuraEnabled
    public String validatedAddressFieldLabel;
    @AuraEnabled
    public String validatedAddressAPIFieldName;
    @AuraEnabled
    public Object validatedAddressValue;
    @AuraEnabled
    public String validatedAddressFieldType;
  }

  public class MergeWrapper {
    @AuraEnabled
    public Boolean isEmpty = true;
    @AuraEnabled
    public List<MergeField> fields;
    @AuraEnabled
    public Boolean checked;
    @AuraEnabled
    public String validatedAddressId;
    @AuraEnabled
    public String propertyId;

    @AuraEnabled
    public String formId;

    MergeWrapper(Property__c invalidProperty) {
      // validatedAddressId = validatedAddress.Id;
      propertyId = invalidProperty.Id;
      checked = false;
      fields = new List<MergeField>();
      isEmpty = true;
      for (String validatedAddressField : MERGE_MAP.keySet()) {
        MergeField field = new MergeField();

        Schema.DescribeFieldResult validatedAddressDFR = VALIDATEDADDRESS_FIELD_MAP.get(
            validatedAddressField
          )
          .getDescribe();
        field.validatedAddressFieldType = validatedAddressDFR.getType().name();
        field.validatedAddressAPIFieldName = validatedAddressField;
        field.validatedAddressFieldLabel = validatedAddressDFR.getLabel();
        // field.validatedAddressValue = validatedAddress.get(validatedAddressField);

        if (String.isNotBlank(MERGE_MAP.get(validatedAddressField))) {
          Schema.DescribeFieldResult propertyDFR = PROPERTY_FIELD_MAP.get(
              MERGE_MAP.get(validatedAddressField)
            )
            .getDescribe();
          field.propertyFieldType = propertyDFR.getType().name();
          field.propertyAPIFieldName = MERGE_MAP.get(validatedAddressField);
          field.propertyFieldLabel = propertyDFR.getLabel();
          field.propertyValue = invalidProperty.get(
            MERGE_MAP.get(validatedAddressFIeld)
          );
        }

        if (field.validatedAddressFieldLabel == 'Created Date') {
          field.validatedAddressFieldLabel = 'Uploaded Date';
        }

        fields.add(field);
      }
    }

    MergeWrapper(Validated_Property_Address__c validatedAddress) {
      validatedAddressId = validatedAddress.Id;
      propertyId = validatedAddress.Property__c;
      checked = false;
      fields = new List<MergeField>();
      isEmpty = false;
      for (String validatedAddressField : MERGE_MAP.keySet()) {
        MergeField field = new MergeField();

        Schema.DescribeFieldResult validatedAddressDFR = VALIDATEDADDRESS_FIELD_MAP.get(
            validatedAddressField
          )
          .getDescribe();
        field.validatedAddressFieldType = validatedAddressDFR.getType().name();
        field.validatedAddressAPIFieldName = validatedAddressField;
        field.validatedAddressFieldLabel = validatedAddressDFR.getLabel();
        field.validatedAddressValue = validatedAddress.get(
          validatedAddressField
        );

        if (String.isNotBlank(MERGE_MAP.get(validatedAddressField))) {
          Schema.DescribeFieldResult propertyDFR = PROPERTY_FIELD_MAP.get(
              MERGE_MAP.get(validatedAddressField)
            )
            .getDescribe();
          field.propertyFieldType = propertyDFR.getType().name();
          field.propertyAPIFieldName = MERGE_MAP.get(validatedAddressField);
          field.propertyFieldLabel = propertyDFR.getLabel();
          field.propertyValue = validatedAddress.getSobject('Property__r')
            .get(MERGE_MAP.get(validatedAddressFIeld));
        }

        if (field.validatedAddressFieldLabel == 'Created Date') {
          field.validatedAddressFieldLabel = 'Uploaded Date';
        }

        fields.add(field);
      }
    }
  }

  @AuraEnabled
  public static void callSmartyStreets(List<Id> propertyIds) {
    system.debug('hit here?');
    List<Validated_Property_Address__c> validatedAddressess = SmartyStreetsAPI.doCallout(
      propertyIds
    );
    insert validatedAddressess;

    return;
  }
}