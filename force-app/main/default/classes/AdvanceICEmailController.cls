public without sharing class AdvanceICEmailController {
  public Id recordId { get; set; }

  public String refiAcquisition {
    get {
      if (recordId == null) {
        return null;
      } else {
        return calculateRefiAcquisition();
      }
    }
    private set;
  }

  public Advance__c advance {
    get {
      if (recordId == null) {
        return null;
      } else {
        return queryAdvance();
      }
    }
    private set;
  }

  public Advance__c queryAdvance() {
    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    Set<String> dealFieldSet = schemaMap.get('Opportunity')
      .getDescribe()
      .fields.getMap()
      .keySet();
    List<String> allFields = new List<String>(
      schemaMap.get('Advance__c').getDescribe().fields.getMap().keySet()
    );

    for (String f : dealFieldSet) {
      allFields.add('Deal__r.' + f);
    }
    String queryString =
      'SELECT ' +
      String.join(allFields, ',') +
      ' FROM Advance__c WHERE Id=\'' +
      recordId +
      '\'';

    return Database.query(queryString);
  }

  public String calculateRefiAcquisition() {
    Integer refi = 0;
    Integer acq = 0;

    for (Property_Advance__c pa : [
      SELECT Property__r.Refinance_Acquisition__c
      FROM Property_Advance__c
      WHERE Advance__c = :recordId
    ]) {
      if (pa.Property__r.Refinance_Acquisition__c == 'Refinance') {
        refi++;
      } else if (pa.Property__r.Refinance_Acquisition__c == 'Acquisition') {
        acq++;
      }
    }

    return 'Refinance (' + refi + ') / Acquisition (' + acq + ')';
  }
}