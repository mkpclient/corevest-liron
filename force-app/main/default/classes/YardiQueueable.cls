public without sharing class YardiQueueable implements Queueable, Database.AllowsCallouts {
  public String yardiType;
  public List<Id> recordIds;

  public YardiQueueable(String type, List<Id> recordIds) {
    this.yardiType = type;
    this.recordIds = recordIds;
  }

  public void execute(QueueableContext context) {
    // Set<Id> idSet //= this.recordIds.remove(0);

    if (this.yardiType == 'termXML' || this.yardiType == 'advanceXML') {
      // List<Id> idList = new List<Id>(idSet);

      Id recordId = recordIds.remove(0);
      List<String> xmls = YardiAPI.createInvoiceRegisters(recordId);
      for (String xml : xmls) {
        YardiAPI.sendInvoiceRegister(xml, recordId);
      }
    } else if (this.yardiType == 'propertyCSV') {
      YardiAPI.sendPropertyCSV(recordIds);

      recordIds.clear();
    } else if (this.yardiType == 'termCSV') {
      YardiAPI.sendTermCSV(recordIds);

      recordIds.clear();
    }

    if (this.recordIds.size() > 0) {
      system.enqueueJob(new YardiQueueable(this.yardiType, this.recordIds));
    }
  }
}