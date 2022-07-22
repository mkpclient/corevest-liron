public class getFieldType {
    
    public static String getType(){
    String objType='Account';
    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    Schema.SObjectType leadSchema = schemaMap.get(objType);
    Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
    
    for (String fieldName: fieldMap.keySet()) {
      Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
    }
        return JSON.Serialize(fieldMap);
    }
    
    public static String getFieldDataType(String objectName){
    return [SELECT DataType 
            FROM FieldDefinition 
            WHERE EntityDefinitionId=:objectName 
            LIMIT 1].DataType;
}
    
}