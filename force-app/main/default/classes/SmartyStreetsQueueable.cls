public class SmartyStreetsQueueable implements Queueable, Database.AllowsCallouts {
    List<Id> calloutIds;
    List<Id> queuedCalloutIds;

    public SmartyStreetsQueueable(List<Id> propertyIds) {
        if(propertyIds.size() > 50){
            calloutIds = new List<Id>();
           Integer len = propertyIds.size();
            for(Integer i = propertyIds.size() - 1; i > len - 50; i--){
                calloutIds.add( propertyIds.remove(i) );
            }
            queuedCalloutIds = propertyIds;
        }else{
            calloutIds = propertyIds;
        }
    }

    public void execute(QueueableContext context) {
        Settings__mdt setting = [Select Id, Enable_SmartyStreets_API__c FROM Settings__mdt WHERE DeveloperName = 'Universal_Settings' LIMIT 1];
        if(Test.isRunningTest() || setting.Enable_SmartyStreets_API__c){
            List<Validated_Property_Address__c> validatedAddressess = SmartyStreetsAPI.doCallout(calloutIds);
            try{
                insert validatedAddressess;
            }catch(Exception e){

            }
            
        }
        

        if(queuedCalloutIds != null && queuedCalloutIds.size() > 0){
            System.enqueueJob(new SmartyStreetsQueueable(queuedCalloutIds));
        }

    }
}