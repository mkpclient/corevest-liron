public with sharing class advancePrint_Extension {
  public static List<String> OPTIONALFIELDS = new List<String>{
    'Advance_Fee_Total__c',
    'Origination_Fee_Subtotal__c',
    'Broker_Advance_Fee_Subtotal__c',
    'Daily_Interest_Rate_Total__c'
  };
  public Advance__c record { get; set; }
  public List<Property_Advance__c> properties { get; set; }
  public List<Wire__c> wires { get; set; }
  public Boolean approvedAdvanceAmountCondition { get; set; }
  public advancePrint_Extension(
    ApexPages.standardController standardController
  ) {
    this.record = (Advance__c) standardController.getRecord();
    this.approvedAdvanceAmountCondition = false;
    if (record.Id != null) {
      // record = (Advance__c)util.queryRecord(record.Id);
      List<String> propertyFieldsList = new List<String>{
        'Property__r.Asset_ID__c',
        'Wire__r.Wire_Number__c',
        'Property__r.APN__c',
        'Property__r.Name',
        'Property__r.City__c',
        'Property__r.State__c',
        'Property__r.ZipCode__c',
        'Property__r.County__c',
        'Property__r.Rehab_Budget__c',
        'Property__r.Yardi_Id__c',
        'Escrow_Agent__r.Name',
        'Property__r.Title_Company__r.Name',
        'Property__r.Title_Contact_Name__c',
        'Property__r.Title_Company__r.BillingStreet',
        'Property__r.Title_Company__r.BillingCity',
        'Property__r.Title_Company__r.BillingState',
        'Property__r.Title_Company__r.BillingPostalCode',
        'Property__r.Lender_Comments__c',
        'Property__r.Approved_Advance_Amount_Max__c'
      };
      List<String> wireFieldsList = new List<String>{ 'Escrow_Agent__r.Name' };
      properties = (List<Property_Advance__c>) queryChildren(
        'Property_Advance__c',
        propertyFieldsList,
        'Advance__c',
        record.Id
      );
      

      //   system.debug(this.record.Approved_Advance_Amount_Max_Total__c);
      Decimal advanceAmountMaxSum = 0;
      for (Property_Advance__c pAdvance : properties) {
        advanceAmountMaxSum += pAdvance.Property__r.Approved_Advance_Amount_Max__c;
      }
      //   system.debug(advanceAmountMaxSum);
      this.approvedAdvanceAmountCondition =
        advanceAmountMaxSum == this.record.Approved_Advance_Amount_Max_Total__c;
      // query property advances and fields
      wires = (List<Wire__c>) queryChildren(
        'Wire__c',
        wireFieldsList,
        'Advance__c',
        record.Id
      );
    }
  }

  public Integer renoColspan {
    get {
      Integer val = 14;
      List<String> privateOptFields = new List<String>{'Inspection_Fee_Total__c'};
      privateOptFields.addAll(OPTIONALFIELDS);
      for(String field : privateOptFields) {
        if(record.get(field) != null && record.get(field) != 0) {
          val += 1;
        }
      }

      return val;
    } 
    private set;
  }

  public Integer nonRenocolspan { 
    get {
      Integer val = 16;

      if(record != null) {
        for(String field : OPTIONALFIELDS) {
          if(record.get(field) != null && record.get(field) != 0) {
            val += 1;
          }
        }
      }

      return val;
    } 
    private set; }


  public static List<sObject> queryChildren(
    String objectName,
    List<String> additionalFields,
    String lookupField,
    Id recordId
  ) {
    Set<String> fieldNamesSet = util.getAllFieldNamesForObject(objectName);
    List<String> fieldNames = new List<String>();
    fieldNames.addAll(fieldNamesSet);

    String qs = 'SELECT ';
    for (Integer i = 0; i < fieldNames.size(); i++) {
      qs += fieldNames[i];
      if (i < fieldNames.size() - 1) {
        qs += ', ';
      }
    }

    if (additionalFields != null) {
      for (String s : additionalFields) {
        qs += ', ' + s;
      }
    }

    qs +=
      ' FROM ' +
      objectName +
      ' WHERE ' +
      lookupField +
      ' = \'' +
      recordId +
      '\'';

    List<sObject> l = Database.query(qs);

    return l;
  }

  public PageReference goBack() {
    PageReference pg = new PageReference('/' + this.record.Id);
    pg.setRedirect(true);

    return pg;
  }
}