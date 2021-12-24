public without sharing class LoanVersionValidatorController {
  // public static Map<String, Map<String, SObjectField>> sobjectFieldMap;

  @AuraEnabled
  public static String initScreen(String docStructureId) {
    // Set<String> fieldNames = new Set<String>();
    // Map<String, Document_Validation__mdt> validatorMap = new Map<String, Document_Validation__mdt>();
    // Set<String> sobjectNames = new Set<String>();

    Map<String, Map<String, SObjectField>> sobjectFieldDescribeMap = new Map<String, Map<String, SObjectField>>();

    Map<String, LoanVersionSection> sectionMap = new Map<String, LoanVersionSection>();

    List<Document_Validation__mdt> validators = new List<Document_Validation__mdt>();

    for (Document_Validation__mdt validator : [
      SELECT
        Id,
        Field_Name__c,
        Field_Label__c,
        Sort__c,
        Check_Only__c,
        sObjectName__c,
        Section_Header_Label__c,
        Filters__c
      FROM Document_Validation__mdt
      WHERE Document_Structure__c = :docStructureId
      ORDER BY Sort__c ASC
    ]) {
      // validatorMap.put(validator.Field_Name__c, validator);
      if (!sobjectFieldDescribeMap.containsKey(validator.sObjectName__c)) {
        DescribeSObjectResult sobjectDescribe = Schema.getGlobalDescribe()
          .get(validator.sobjectName__c)
          .getDescribe();
        sobjectFieldDescribeMap.put(
          validator.sobjectName__c,
          sobjectDescribe.fields.getMap()
        );
      }

      validators.add(validator);
    }

    // for (String s : validatorMap.keySet()) {
    for (Document_Validation__mdt validator : validators) {
      // Document_Validation__mdt validator = validatorMap.get(s);
      String fieldName = validator.FIeld_Name__c;
      if (fieldName.contains('.')) {
        // system.debug(s);
        fieldName = (fieldName.split('\\.'))[0];

        if (fieldName.contains('__r')) {
          fieldName = fieldName.replace('__r', '__c');
        }
      }

      // system.debug(s);

      SObjectField fieldToken = sobjectFieldDescribeMap.get(
          validator.sobjectName__c
        )
        .get(fieldName);

      system.debug(fieldToken);
      system.debug(validator.sobjectName__c);
      system.debug(fieldName);
      DescribeFieldResult selectedField = fieldToken.getDescribe();

      String sectionHeader = String.isNotBlank(
          validator.Section_Header_Label__c
        )
        ? validator.Section_Header_Label__c
        : '';

      if (!sectionMap.containsKey(sectionHeader)) {
        sectionMap.put(sectionHeader, new LoanVersionSection(sectionHeader));
      }

      sectionMap.get(sectionHeader)
        .addField(new LoanVersionField(validator, selectedField));
    }

    return JSON.serialize(sectionMap.values());
  }

  class LoanVersionSection {
    String headerLabel;
    List<LoanVersionField> fields;

    LoanVersionSection(String headerLabel) {
      this.headerLabel = headerLabel;

      this.fields = new List<LoanVersionField>();
    }

    public void addField(LoanVersionField field) {
      this.fields.add(field);
    }
  }

  class LoanVersionField {
    String sobjectType;
    String label;
    String fieldName;
    // Object value;
    String fieldType;
    Boolean checkOnly = false;
    Decimal scale = 1;
    Integer precision = 1;
    Boolean isDisplayed = false;
    String filter;

    LoanVersionField(
      Document_Validation__mdt validator,
      DescribeFieldResult fieldDescribe
    ) {
      this.label = String.isBlank(validator.Field_Label__c)
        ? fieldDescribe.getLabel()
        : validator.Field_Label__c;
      this.fieldName = validator.Field_Name__c; //fieldDescribe.getName();
      this.checkOnly = validator.Check_Only__c;
      this.sobjectType = validator.SobjectName__c;
      Schema.DisplayType fieldType = fieldDescribe.getType();

      if (fieldType == Schema.DisplayType.TEXTAREA) {
        this.fieldType = 'text';
      } else if (fieldType == Schema.DisplayType.Date) {
        this.fieldType = 'date';
      } else if (fieldType == Schema.DisplayType.DateTime) {
        this.fieldType = 'datetime';
      } else if (fieldType == Schema.DisplayType.Double) {
        this.fieldType = 'number';
        this.scale = fieldDescribe.getScale();
        this.precision = fieldDescribe.getPrecision();

        // if(this.scale != 0){
        this.scale = 1 / Math.pow(10, fieldDescribe.getScale());
        // }
      } else if (fieldType == Schema.DisplayType.Currency) {
        this.fieldType = 'currency';
        this.scale = 1 / Math.pow(10, fieldDescribe.getScale());
        this.precision = fieldDescribe.getPrecision();
      } else if (fieldType == Schema.DisplayType.INTEGER) {
        // this.scale = 1/Math.pow(10, fieldDescribe.getScale());
        this.fieldType = 'number';
      } else if (fieldType == Schema.DisplayType.PERCENT) {
        this.fieldType = 'percent';
        this.scale = 1 / Math.pow(10, fieldDescribe.getScale());
        this.precision = fieldDescribe.getPrecision();
      } else if (fieldType == Schema.DisplayType.PICKLIST) {
        this.fieldType = 'text';
      } else if (fieldType == Schema.DisplayType.String) {
        this.fieldType = 'text';
      } else {
        this.fieldType = 'text';
      }

      this.filter = validator.Filters__c;

      //this.filters = new List<List<String>>();

      // if (String.isNotBlank(validator.Filters__c)) {
      //   //List<String> validator.Filters__c.split(';');
      //   for (String expression : validator.Filters__c.split('!')) {
      //     this.filters.add(expression.split('-'));
      //   }
      // }
    }

    // LoanVersionField(
    //   String label,
    //   String fieldName,
    //   DescribeFieldResult fieldDescribe,
    //   Boolean checkOnly
    // ) {
    //   this.label = label;
    //   this.fieldName = fieldName;
    //   this.checkOnly = checkOnly;
    //   Schema.DisplayType fieldType = fieldDescribe.getType();
    //   // this.
    // }
  }

  // public class CriteriaNode {
  //   public List<Expression> expressions;
  //   public String logicalOperator;
  //   public Boolean result;
  //   public CriteriaNode parent;
  // }

  // public class Expression {
  //   public String fieldName;
  //   public String operand;
  //   public Object value;
  //   public String fieldType;
  // }
}