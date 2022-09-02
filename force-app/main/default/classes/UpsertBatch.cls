public class UpsertBatch implements Database.Batchable<sObject> {
    sObject[] source;
    public UpsertBatch(sObject[] records) {
      source = records;
    }
    public sObject[] start(Database.BatchableContext context) {
      return source;
    }
    public void execute(Database.BatchableContext context, sObject[] scope) {
      upsert scope;
    }
    public void finish(Database.BatchableContext context) {
    }
  }