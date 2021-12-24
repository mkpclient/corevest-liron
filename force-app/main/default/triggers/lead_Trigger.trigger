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
      Lead_Helper.UpdateLeadTrueSource(Trigger.New);
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

      //  Lead_Helper.afterUpdate(Trigger.New, Trigger.Old);
      /*system.debug('===LeadIdConvertList==='+LeadIdConvertList);
        
      if(LeadIdConvertList!= null && LeadIdConvertList.size() > 0)
      {
        Lead_Helper.updateIsconvertedLead(LeadIdConvertList);
      }*/
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
      /*
        Map<id,lead> leadMap = new map<id,lead>();
        if(oldlead!=null && oldlead.size()>0)
        {   
             for(lead lobj : oldlead)
                {
                    //lead templ = leadMap.get(lobj.MasterRecordId);
                    if(leadMap.get(lobj.MasterRecordId)!=null)
                    {
                        lead l = leadMap.get(lobj.MasterRecordId);
                        if(lobj.CreatedDate > l.CreatedDate)
                        {
                            leadMap.put(lobj.MasterRecordId,lobj);  
                        }       
                        
                    }
                    else
                    {
                        leadMap.put(lobj.MasterRecordId,lobj);  
                    }       
                }
           
            system.debug('leadMap=='+leadMap);
            list<lead> lList = [select id,Introduction_Source__c,Introduction_Subsource__c from lead where id In: leadMap.keyset()] ;
            list<lead> lfinallist = new  list<lead>();
            system.debug('lList####'+lList);
            for(lead l :lList)
            {
                lead lobj = leadMap.get(l.id);
                if(l.id==lobj.MasterRecordId)
                {
                    system.debug('inside if####');  
                    l.Introduction_Source__c=lobj.Introduction_Source__c;
                    l.Introduction_Subsource__c=lobj.Introduction_Subsource__c;
                    lfinallist.add(l);
                } 
                    
            }
            system.debug('lfinallist=='+lfinallist);
            update  lfinallist;
        }*/
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