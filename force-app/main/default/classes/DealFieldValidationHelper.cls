public without sharing class DealFieldValidationHelper {
  public static Map<String, Map<String, Deal_Field_Validations__mdt>> dealFieldValidationMapRF;
  public static Map<String, Map<String, Deal_Field_Validations__mdt>> dealFieldValidationMapRE;

  public static void compileDFVMap() {
    dealFieldValidationMapRF = new Map<String, Map<String, Deal_Field_Validations__mdt>>();
    dealFieldValidationMapRE = new Map<String, Map<String, Deal_Field_Validations__mdt>>();

    for (Deal_Field_Validations__mdt mdt : [
      SELECT
        ObjectName__c,
        RecordType__c,
        FromStage__c,
        ToStage__c,
        FieldLabels__c,
        FieldNames__c,
        Active__c,
        Validation_Type__c,
        Filter_Criteria__c
      FROM Deal_Field_Validations__mdt
      WHERE Active__c = TRUE
    ]) {
      if (mdt.Active__c || (!mdt.Active__c && Test.isRunningTest())) {
        if (mdt.Validation_Type__c == 'Required Fields') {
          if (
            dealFieldValidationMapRF.containsKey(
              mdt.RecordType__c +
              '|' +
              mdt.ObjectName__c
            )
          ) {
            dealFieldValidationMapRF.get(
                mdt.RecordType__c +
                '|' +
                mdt.ObjectName__c
              )
              .put(mdt.FromStage__c + '~~' + mdt.ToStage__c, mdt);
          } else {
            dealFieldValidationMapRF.put(
              mdt.RecordType__c +
              '|' +
              mdt.ObjectName__c,
              new Map<String, Deal_Field_Validations__mdt>{
                mdt.FromStage__c +
                '~~' +
                mdt.ToStage__c => mdt
              }
            );
          }
        } else if (mdt.Validation_Type__c == 'Record Exists') {
          if (
            dealFieldValidationMapRE.containsKey(
              mdt.RecordType__c +
              '|' +
              mdt.ObjectName__c
            )
          ) {
            dealFieldValidationMapRE.get(
                mdt.RecordType__c +
                '|' +
                mdt.ObjectName__c
              )
              .put(mdt.FromStage__c + '~~' + mdt.ToStage__c, mdt);
          } else {
            dealFieldValidationMapRE.put(
              mdt.RecordType__c +
              '|' +
              mdt.ObjectName__c,
              new Map<String, Deal_Field_Validations__mdt>{
                mdt.FromStage__c +
                '~~' +
                mdt.ToStage__c => mdt
              }
            );
          }
        }
      }
    }
  }

  public static String validateDeals(
    Map<Id, Opportunity> oldDealMap,
    Map<Id, Opportunity> newDealMap,
    Map<Id, List<Property__c>> dealPropertyMap,
    Map<Id, List<Business_Entity__c>> businessEntityMap,
    Map<Id, List<Deal_Document__c>> dealDocumentMap
  ) {
    //String errorMsg = '';

    if (dealFieldValidationMapRF == null || dealFieldValidationMapRE == null) {
      compileDFVMap();
    }

    // system.debug(JSON.serialize(dealFieldValidationMap));
    String invalidDealId = '';
    String errorMsg = '';
    String returnVal = '';
    for (Opportunity deal : newDealMap.values()) {
      String dealId = deal.Id;
      // system.debug(deal.StageName);
      // system.debug(oldDealMap.get(deal.Id).StageName);

      // system.debug(
      //   String.isNotBlank(invalidDealId) &&
      //   deal.StageName != oldDealMap.get(deal.Id).StageName
      // );

      String recordType = deal.Record_Type_Name__c;
      String stageName = deal.StageName;
      String oldStageName = oldDealMap.get(deal.Id).StageName;

      system.debug('validator');
      system.debug(recordType);
      system.debug(stageName);
      system.debug(oldStageName);

      if (String.isBlank(invalidDealId) && stageName != oldStageName) {
        String initialRecordTypeDealKey = recordType + '|Deal';
        String initialRecordTypePropertyKey = recordType + '|Property';
        String initialRecordTypeBusinessEntityKey =
          recordType + '|Business Entity';

        String initialRecordTypeDealDocument = recordType + '|Deal_Document__c';
        String stageNameChangeKey = oldStageName + '~~' + stageName;
        system.debug(
          'String.isBlank(invalidDealId)==' + String.isBlank(invalidDealId)
        );
        system.debug('initialRecordTypeDealKey' + initialRecordTypeDealKey);
        system.debug(
          'dealFieldValidationMapRF.containsKey(initialRecordTypeDealKey)==' +
          dealFieldValidationMapRF.containsKey(initialRecordTypeDealKey)
        );
        system.debug('stageNameChangeKey==' + stageNameChangeKey);
        system.debug('dealFieldValidationMapRF==' + dealFieldValidationMapRF);
        system.debug('initialRecordTypeDealKey==' + initialRecordTypeDealKey);
        system.debug('stageNameChangeKey==' + stageNameChangeKey);
        if (
          String.isBlank(invalidDealId) &&
          dealFieldValidationMapRF.containsKey(initialRecordTypeDealKey) &&
          dealFieldValidationMapRF.get(initialRecordTypeDealKey)
            .containsKey(stageNameChangeKey)
        ) {
          Deal_Field_Validations__mdt fieldValidation = dealFieldValidationMapRF.get(
              initialRecordTypeDealKey
            )
            .get(stageNameChangeKey);
          system.debug('validateFields deal');
          errorMsg = validateFields(fieldValidation, deal);

          if (String.isNotBlank(errorMsg)) {
            invalidDealId = dealId;
          }
        }
        system.debug(
          'String.isBlank(invalidDealId)==' + String.isBlank(invalidDealId)
        );
        system.debug(
          'initialRecordTypePropertyKey==' + initialRecordTypePropertyKey
        );
        system.debug('dealFieldValidationMapRF==' + dealFieldValidationMapRF);
        system.debug(
          'dealFieldValidationMapRF.containsKey(initialRecordTypePropertyKey)==' +
          dealFieldValidationMapRF.containsKey(initialRecordTypePropertyKey)
        );
        system.debug(
          'dealPropertyMap.containsKey(dealId)==' +
          dealPropertyMap.containsKey(dealId)
        );
        system.debug('dealId==' + dealId);
        if (
          String.isBlank(invalidDealId) &&
          dealFieldValidationMapRF.containsKey(initialRecordTypePropertyKey) &&
          dealFieldValidationMapRF.get(initialRecordTypePropertyKey)
            .containsKey(stageNameChangeKey) &&
          dealPropertyMap.containsKey(dealId)
        ) {
          Deal_Field_Validations__mdt fieldValidation = dealFieldValidationMapRF.get(
              initialRecordTypeDealKey
            )
            .get(stageNameChangeKey);

          for (Property__c property : dealPropertyMap.get(dealId)) {
            system.debug('validateFields property');
            errorMsg = validateFields(fieldValidation, property);

            if (String.isNotBlank(errorMsg)) {
              invalidDealId = dealId;
              break;
            }
          }
        }

        if (
          String.isNotBlank(invalidDealId) &&
          dealFieldValidationMapRF.containsKey(
            initialRecordTypeBusinessEntityKey
          ) &&
          dealFieldValidationMapRF.get(initialRecordTypeBusinessEntityKey)
            .containsKey(stageNameChangeKey) &&
          businessEntityMap.containsKey(dealId)
        ) {
          Deal_Field_Validations__mdt fieldValidation = dealFieldValidationMapRF.get(
              initialRecordTypeBusinessEntityKey
            )
            .get(stageNameChangeKey);

          for (
            Business_Entity__c businessEntity : businessEntityMap.get(dealId)
          ) {
            system.debug('validateFields businessEntity');
            errorMsg = validateFields(fieldValidation, businessEntity);

            if (String.isNotBlank(errorMsg)) {
              invalidDealId = dealId;
              break;
            }
          }
        }

        if (
          String.isNotBlank(invalidDealId) &&
          dealFieldValidationMapRF.containsKey(initialRecordTypeDealDocument) &&
          dealFieldValidationMapRF.get(initialRecordTypeDealDocument)
            .containsKey(stageNameChangeKey) &&
          dealDocumentMap.containsKey(dealId)
        ) {
          Deal_Field_Validations__mdt fieldValidation = dealFieldValidationMapRF.get(
              initialRecordTypeDealDocument
            )
            .get(stageNameChangeKey);

          for (Deal_Document__c dealDoc : dealDocumentMap.get(dealId)) {
            system.debug('validateFields businessEntity');
            errorMsg = validateFields(fieldValidation, dealDoc);

            if (String.isNotBlank(errorMsg)) {
              invalidDealId = dealId;
              break;
            }
          }
        }

        if (
          String.isBlank(invalidDealId) &&
          dealFieldValidationMapRE.containsKey(initialRecordTypeDealDocument) &&
          dealFieldValidationMapRE.get(initialRecordTypeDealDocument)
            .containsKey(stageNameChangeKey)
        ) {
          Deal_Field_Validations__mdt fieldValidation = dealFieldValidationMapRE.get(
              initialRecordTypeDealDocument
            )
            .get(stageNameChangeKey);

          List<Deal_Document__c> dealDocs = dealDocumentMap.get(dealId);

          system.debug(dealDocs);
          system.debug('in record exists');

          errorMsg = validateRecordExists(
            fieldValidation,
            dealDocs,
            'Deal Document'
          );

          if (String.isNotBlank(errorMsg)) {
            invalidDealId = dealId;
            break;
          }
        }
      }
    }

    if (String.isNotBlank(invalidDealId)) {
      returnVal = errorMsg = invalidDealId + '~~' + errorMsg;
    }

    return returnVal;
  }

  public static String validateRecordExists(
    Deal_Field_Validations__mdt mtdt,
    List<Sobject> records,
    String sobjectType
  ) {
    String errorMsg = '';

    try {
      List<String> filterCriterias = String.isNotBlank(mtdt.Filter_Criteria__c)
        ? ((String) mtdt.Filter_Criteria__c).split(',')
        : new List<String>();

      // String allCriteriasValidated = true;

      system.debug('--filter criterias--');
      system.debug(filterCriterias);

      for (String criteria : filterCriterias) {
        List<String> criteriaSplit = criteria.split('=');
        String fieldName = criteriaSplit[0];
        String fieldValue = criteriaSplit[1];

        system.debug(fieldName);
        system.debug(fieldValue);

        Boolean criteriaValidated = false;

        system.debug(records);

        if (records != null) {
          for (Sobject record : records) {
            system.debug('record value');
            system.debug(record.get(fieldName));

            if ((String) record.get(fieldName) == fieldValue) {
              criteriaValidated = true;
            }
          }
        }

        system.debug(criteriaValidated);
        if (!criteriaValidated) {
          // allCriteriasValidated = false;

          errorMsg += fieldValue + ' ' + sobjectType + ' is missing. ';
        }

        system.debug('--------');
      }

      return errorMsg;
    } catch (Exception ex) {
      system.debug('Error ==>' + ex.getMessage());
      system.debug('Error ==>' + ex.getLineNumber());
      system.debug('Error ==>' + ex.getStacktraceString());
      return 'Error Occurred';
    }
  }

  public static string validateFields(
    Deal_Field_Validations__mdt mtdt,
    Sobject sobj
  ) {
    system.debug('sobj==' + sobj);
    String errorMsg = '';

    try {
      String objectname = String.valueOf(mtdt.ObjectName__c);
      system.debug('INSIDE validateDealFields' + objectname);
      if (objectname == 'Deal') {
        objectname = 'Opportunity';
      }
      List<String> fieldLabels = !String.isEmpty(mtdt.FieldLabels__c)
        ? ((String) mtdt.FieldLabels__c).split(',')
        : new List<String>();
      System.debug(
        'fieldLabels size: ' +
        fieldLabels.size() +
        ' , ' +
        fieldLabels
      );

      List<String> fieldNames = !String.isEmpty(mtdt.FieldNames__c)
        ? ((String) mtdt.FieldNames__c).split(',')
        : new List<String>();
      System.debug(
        'fieldNames szie: ' +
        fieldNames.size() +
        ' , ' +
        fieldNames
      );

      if (
        fieldLabels.size() > 0 &&
        fieldNames.size() > 0 &&
        fieldLabels.size() == fieldNames.size()
      ) {
        System.debug('Inside fieldLabels and fieldNames if condition....');
        for (String fldName : fieldNames) {
          System.debug(
            'sobj.getSObjectType().getDescribe().getName()=====' +
            sobj.getSObjectType().getDescribe().getName()
          );
          System.debug(
            sobj.getSObjectType().getDescribe().getName() != 'Opportunity'
          );
          //system.debug('String.valueOf(sobj.get(fldName)=='+String.valueOf(sobj.get(fldName)));
          if (fldName.indexOf('__r') > -1) {
            String[] flds = fldName.split('\\.');

            // System.debug('FieldsTest===='+flds[0]+'==='+flds[1]);
            if (sobj.getSObject(flds[0]) != null) {
              if (
                String.isEmpty(
                  String.valueOf(sobj.getSObject(flds[0]).get(flds[1]))
                )
              ) {
                errorMsg = String.isEmpty(errorMsg)
                  ? fieldLabels[fieldNames.indexOf(fldName)]
                  : errorMsg + ', ' + fieldLabels[fieldNames.indexOf(fldName)];
              }
            }
          } else if (
            objectname == sobj.getSObjectType().getDescribe().getName()
          ) {
            if (
              String.isEmpty(String.valueOf(sobj.get(fldName))) ||
              (String.valueOf(fldName) == 'Appraisal_Ordered__c' &&
              String.valueOf(sobj.get(fldName)) != 'true') ||
              (String.valueOf(fldName) == 'Background_Check_Completed__c' &&
              String.valueOf(sobj.get(fldName)) != 'true') ||
              (String.valueOf(fldName) == 'Credit_Check_Completed__c' &&
              String.valueOf(sobj.get(fldName)) != 'true')
            ) {
              System.debug('fldName errorMsg' + fldName);
              errorMsg = String.isEmpty(errorMsg)
                ? fieldLabels[fieldNames.indexOf(fldName)]
                : errorMsg + ', ' + fieldLabels[fieldNames.indexOf(fldName)];
            }
          }
        }
      }
      system.debug('errorMsg ==>' + errorMsg);
      return errorMsg;
    } catch (Exception ex) {
      system.debug('Error ==>' + ex.getMessage());
      system.debug('Error ==>' + ex.getLineNumber());
      system.debug('Error ==>' + ex.getStacktraceString());
      return 'Error Occurred';
    }
  }
}