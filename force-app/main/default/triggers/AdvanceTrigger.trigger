trigger AdvanceTrigger on Advance__c(before insert, before update) {
    for (Advance__c adv : Trigger.new) {
    if(Trigger.isUpdate){
        
            if(adv.Advance_Documents_Received__c != Trigger.oldMap.get(adv.Id).Advance_Documents_Received__c)
            { 
				String AdvanceDocumentsReceivedOld=Trigger.oldMap.get(adv.Id).Advance_Documents_Received__c !=null ?  Datetime.newInstance(Trigger.oldMap.get(adv.Id).Advance_Documents_Received__c.year(), Trigger.oldMap.get(adv.Id).Advance_Documents_Received__c.month(),Trigger.oldMap.get(adv.Id).Advance_Documents_Received__c.day()).format('yyyy-MM-dd') : null;
				String AdvanceDocumentsReceivedNew=adv.Advance_Documents_Received__c !=null ? Datetime.newInstance(adv.Advance_Documents_Received__c.year(), adv.Advance_Documents_Received__c.month(),adv.Advance_Documents_Received__c.day()).format('yyyy-MM-dd') : null;
			
                adv.Deal_Field_History__c=adv.Deal_Field_History__c!=null ? (adv.Deal_Field_History__c+'\nAdvance Documents Received Date: ' +UserInfo.getName()+ ' changed Date from ' +AdvanceDocumentsReceivedOld+' to '+AdvanceDocumentsReceivedNew+ ' on ' +Datetime.now().format('yyyy-MM-dd')) : ('Advance Documents Received Date: '+UserInfo.getName()+' changed Date from ' +AdvanceDocumentsReceivedOld+' to '+AdvanceDocumentsReceivedNew+ ' on ' +Datetime.now().format('yyyy-MM-dd')); 
            } 
            
            if(adv.Custodial_File_Sent_to_Custodian__c != Trigger.oldMap.get(adv.Id).Custodial_File_Sent_to_Custodian__c)
            { 
				String custodialFileOld=Trigger.oldMap.get(adv.Id).Custodial_File_Sent_to_Custodian__c !=null ?  Datetime.newInstance(Trigger.oldMap.get(adv.Id).Custodial_File_Sent_to_Custodian__c.year(), Trigger.oldMap.get(adv.Id).Custodial_File_Sent_to_Custodian__c.month(),Trigger.oldMap.get(adv.Id).Custodial_File_Sent_to_Custodian__c.day()).format('yyyy-MM-dd') : null;
				String custodialFileNew=adv.Custodial_File_Sent_to_Custodian__c !=null ? Datetime.newInstance(adv.Custodial_File_Sent_to_Custodian__c.year(), adv.Custodial_File_Sent_to_Custodian__c.month(),adv.Custodial_File_Sent_to_Custodian__c.day()).format('yyyy-MM-dd') : null;
				
                adv.Deal_Field_History__c=adv.Deal_Field_History__c!=null ? (adv.Deal_Field_History__c+'\nCustodial File Sent to Custodian Date: ' +UserInfo.getName()+ ' changed Date from ' +custodialFileOld+' to '+custodialFileNew+ ' on ' +Datetime.now().format('yyyy-MM-dd')) : ('Custodial File Sent to Custodian Date: '+UserInfo.getName()+' changed Date from ' +custodialFileOld+' to '+custodialFileNew+ ' on ' +Datetime.now().format('yyyy-MM-dd'));   
            } 
            if(adv.Onboarding_File_Sent_to_Servicer__c != Trigger.oldMap.get(adv.Id).Onboarding_File_Sent_to_Servicer__c)
            { 
				String onboardingFileOld=Trigger.oldMap.get(adv.Id).Onboarding_File_Sent_to_Servicer__c !=null ?  Datetime.newInstance(Trigger.oldMap.get(adv.Id).Onboarding_File_Sent_to_Servicer__c.year(), Trigger.oldMap.get(adv.Id).Onboarding_File_Sent_to_Servicer__c.month(),Trigger.oldMap.get(adv.Id).Onboarding_File_Sent_to_Servicer__c.day()).format('yyyy-MM-dd') : null;
				String onboardingFileNew=adv.Onboarding_File_Sent_to_Servicer__c !=null ? Datetime.newInstance(adv.Onboarding_File_Sent_to_Servicer__c.year(), adv.Onboarding_File_Sent_to_Servicer__c.month(),adv.Onboarding_File_Sent_to_Servicer__c.day()).format('yyyy-MM-dd') : null;
				
                adv.Deal_Field_History__c=adv.Deal_Field_History__c!=null ? (adv.Deal_Field_History__c+'\nOnboarding File Sent to Servicer Date: ' +UserInfo.getName()+ ' changed Date from ' +onboardingFileOld+' to '+onboardingFileNew+ ' on ' +Datetime.now().format('yyyy-MM-dd')) : ('Onboarding File Sent to Servicer Date: '+UserInfo.getName()+' changed Date from ' +onboardingFileOld+' to '+onboardingFileNew+ ' on ' +Datetime.now().format('yyyy-MM-dd'));  
            } 
            if(adv.Onboarded_at_Servicer__c != Trigger.oldMap.get(adv.Id).Onboarded_at_Servicer__c)
            { 
				String onboardingat_ServicerOld=Trigger.oldMap.get(adv.Id).Onboarded_at_Servicer__c !=null ?  Datetime.newInstance(Trigger.oldMap.get(adv.Id).Onboarded_at_Servicer__c.year(), Trigger.oldMap.get(adv.Id).Onboarded_at_Servicer__c.month(),Trigger.oldMap.get(adv.Id).Onboarded_at_Servicer__c.day()).format('yyyy-MM-dd') : null;
				String onboardingat_ServicerNew=adv.Onboarded_at_Servicer__c !=null ? Datetime.newInstance(adv.Onboarded_at_Servicer__c.year(), adv.Onboarded_at_Servicer__c.month(),adv.Onboarded_at_Servicer__c.day()).format('yyyy-MM-dd') : null;
				
            adv.Deal_Field_History__c=adv.Deal_Field_History__c!=null ? (adv.Deal_Field_History__c+'\nOnboarded at Servicer Date: ' +UserInfo.getName()+ ' changed Date from ' +onboardingat_ServicerOld+' to '+onboardingat_ServicerNew+ ' on ' +Datetime.now().format('yyyy-MM-dd')) : ('Onboarded at Servicer Date: '+UserInfo.getName()+' changed Datefrom ' +onboardingat_ServicerOld+' to '+onboardingat_ServicerNew+ ' on ' +Datetime.now().format('yyyy-MM-dd'));             } 
            
        }
    }
}