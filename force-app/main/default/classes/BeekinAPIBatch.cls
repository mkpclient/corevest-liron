public class BeekinAPIBatch implements Queueable, Database.AllowsCallouts {
     Public List<Property__c> property;
      public BeekinAPIBatch(List<Property__c> prop)
     {
         this.property  = [SELECT id,Name,Number_of_Beds__c,Number_of_Bath__c,Square_Feet__c,pool__c,Property_Type__c,
                           Estimated_Rent__c,Estimated_Min_Rent__c,Estimated_Max_Rent__c FROM Property__c 
                           WHERE id in :prop AND Deal__r.StageName IN ('Data Tape Received' , 'Term Sheet Issued' , 'Term Sheet Signed/Deposit Collected' 
                                                                    , 'Submitted to Underwriting' , 'Underwriting' , 'UW Hold' , 'Approved by Committee')
                                            AND Status__c NOT IN ('Inactive','Cancelled','Rescinded')
                                        	AND Property__c.ZipCode__c != null AND 
                                            Property__c.Property_Type__c IN ('SFR' , 'Condo','Townhome','2-4 Unit','Multifamily')
                                            AND Property__c.Is_Parent__c = False AND deal__r.RecordType__c = 'Term' ORDER BY Property_Name__c];
     }
     
    public void execute(QueueableContext context) {
        if (property.size() > 0)
        {
		BeekinAPI.callBeekin(property); 
		}            
    }
}