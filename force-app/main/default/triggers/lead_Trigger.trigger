trigger lead_Trigger on Lead(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete,
  after undelete
) {
  //public Map<id,Lead> UpdateMap = new Map<id,Lead>();
  public List<lead> LeadIdConvertList;
  public Map<id, Lead> maplead;
  Settings__mdt settings = Settings__mdt.getInstance('Universal_Settings');
  if (!settings.Disable_Lead_Trigger__c) {
    if (Trigger.isBefore && Trigger.isInsert) {
      Lead_Helper.beforeInsert(Trigger.New);
      // Lead_Helper.UpdateLeadTrueSource(Trigger.New);
    }
    if (Trigger.isAfter && Trigger.isInsert) {
      Lead_Helper.afterInsert(Trigger.New);
      Lead_Helper.CreateSource(Trigger.New);
    }
    if (Trigger.isBefore && Trigger.isUpdate) {
      list<lead> LeadIdConvertList = new List<lead>();
      system.debug('isbefore== Trigger.new==' + Trigger.New);
      for (lead l : Trigger.new) {
        if (l.IsConverted) {
          LeadIdConvertList.add(l);
        }
      }
      if (LeadIdConvertList != null && LeadIdConvertList.size() > 0) {
        Lead_Helper.sourceUpdateonleadConvert(LeadIdConvertList);
      }
      Lead_Helper.beforeUpdate(Trigger.New, Trigger.Old);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
      system.debug('Trigger.Old===' + Trigger.Old);
      list<lead> LeadIdConvertList = new List<lead>();
      for (lead l : Trigger.new) {
        if ((!(l.IsConverted)) && l.LastName != 'Unknown') {
          LeadIdConvertList.add(l);
        }
      }
      system.debug('LeadIdConvertList::::' + LeadIdConvertList);
      Lead_Helper.updateSource(LeadIdConvertList);
    }
    if (Trigger.isBefore && Trigger.isDelete) {
      //  Lead_Helper.beforeDelete(Trigger.New);
    }
    if (Trigger.isAfter && Trigger.isDelete) {
      //  Lead_Helper.afterDelete(Trigger.New, Trigger.Old);

      list<lead> oldlead = new List<lead>();
      for (Lead ld : Trigger.old) {
        system.debug(':::::::::::::::::::::::Lead:BJHA==' + ld.MasterRecordId);

        if (ld.MasterRecordId != null) {
          oldlead.add(ld);
        }
      }

      if (oldlead != null && oldlead.size() > 0) {
        String JSONlead = JSON.serialize(oldlead);
        lead_Helper.updateleadonMarge(JSONlead);
      }
      // system.debug('leadMap=='+leadMap);
    }
    if (Trigger.isAfter && Trigger.isUndelete) {
      //  Lead_Helper.afterUndelete(Trigger.Old);
    }
  }
}