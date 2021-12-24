public class DrawHelper {

    public static Map<String, Schema.SObjectField> FIELD_MAP = Schema.SObjectType.Draw__c.fields.getMap();

    /**
    * @author MK Partners, Inc.
    * @date
    * @group
    * @group-content
    * @name beforeInsert
    * @description
    * @param {List<Draw__c>} newList
    * @return void
    **/
    public static void beforeInsert(List<Draw__c> newList){
        Map<Id, List<Draw__c>> propertyMap = new Map<Id, List<Draw__c>>();

        for ( Integer i=0;i<newList.size();i++ ){
            if(!propertyMap.containsKey(newList[i].Property__c)){
                propertyMap.put(newList[i].Property__c, new List<Draw__c>());
            }

            propertyMap.get(newList[i].Property__c).add(newList[i]);

        }

        for(Property__c property : [SELECT Id, (SELECT Id, Draw_Number__c FROM Draws__r WHERE Draw_Number__c != null Order BY Draw_Number__c desc) FROM Property__c WHERE Id IN : propertyMap.keySet()]){
            for(Draw__c draw : propertyMap.get(property.Id)){
                if(String.isBlank(draw.Name)){
                    if(property.Draws__r.size() > 0){
                        draw.Name = String.valueOf(property.Draws__r[0].Draw_Number__c + 1);
                    }else{
                        draw.Name = '1';
                    }
                }
            }
        }

    }

    /**
    * @author MK Partners, Inc.
    * @date
    * @group
    * @group-content
    * @name afterInsert
    * @description
    * @param {List<Draw__c>} newList
    * @return void
    **/
    public static void afterInsert(List<Draw__c> newList){
        for ( Integer i=0;i<newList.size();i++ ){

        }
    }


}