// @ Author Trivikram
public class DashboardDetailsController {
    /*@AuraEnabled
    public static Boolean updateDashboardDisplay(String dealId){
        
        Opportunity objOpp =[SELECT id,Display_Dashboard__c FROM Opportunity WHERE id=:dealId];
        if(objOpp.Display_Dashboard__c){
            objOpp.Display_Dashboard__c = false;
        }else{
            objOpp.Display_Dashboard__c = true;
        }
        update objOpp;
        return objOpp.Display_Dashboard__c;
    }
    */
    @AuraEnabled
    public static Map<String, String> getDashboardDisplay(/*String dealId*/){
        Map<String, String> response=new Map<String, String>();
        
        /*Boolean  displayDashBoard=[SELECT id,Display_Dashboard__c FROM Opportunity WHERE id=:dealId].Display_Dashboard__c;*/
        
        //response.put('displayDashBoard', Json.serialize(displayDashBoard));
        response.put('displayDensity', getCurrentUserDisplayDensity());
        
        return response;
    }
    
    private static string getCurrentUserDisplayDensity(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        
        request.setEndpoint('callout:MySalesforce/services/data/v44.0/ui-api/themes/active');
        
        HttpResponse response;
        if(!Test.isRunningTest()){
            response = http.send(request);
        }else{
            response=new  HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"brandColor":"#0070D2","brandImage":{"largeUrl":"/_slds/images/themes/lightning_blue/lightning_blue_logo_3x.png","mediumUrl":"/_slds/images/themes/lightning_blue/lightning_blue_logo_2x.png","smallUrl":"/_slds/images/themes/lightning_blue/lightning_blue_logo_1x.png"},"defaultGroupBanner":{"fullSizeUrl":"/_slds/images/themes/lightning_blue/lightning_blue_group.png"},"defaultGroupImage":{"largeUrl":"/_slds/images/themes/lightning_blue/lightning_blue_group_icon_200.png","mediumUrl":"/_slds/images/themes/lightning_blue/lightning_blue_group_icon_160.png","smallUrl":"/_slds/images/themes/lightning_blue/lightning_blue_group_icon_96.png"},"defaultPageBanner":{"fullSizeUrl":"/_slds/images/themes/lightning_blue/lightning_blue_background.png"},"defaultUserBanner":{"fullSizeUrl":"/_slds/images/themes/lightning_blue/lightning_blue_profile.png"},"defaultUserImage":{"largeUrl":"/_slds/images/themes/lightning_blue/lightning_blue_profile_avatar_200.png","mediumUrl":"/_slds/images/themes/lightning_blue/lightning_blue_profile_avatar_160.png","smallUrl":"/_slds/images/themes/lightning_blue/lightning_blue_profile_avatar_96.png"},"density":"ViewTwo","headerColor":"#FFFFFF","linkColor":null,"pageColor":"#B0C4DF"}');
            response.setStatusCode(200);
            response.setStatus('Success');
        }
        System.debug('Response Body--->'+response.getBody());
        
        if (response.getStatusCode() == 200) {
            Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            String density = (String)root.get('density');
            system.debug('density---------'+density);
            return (density=='ViewOne' ? 'Comfy' : 'Compact');
        }else{
            return 'Comfy';
        }
    }
}