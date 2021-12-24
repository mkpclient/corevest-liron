public class contentDocument_Helper {

    public static Map<String, Schema.SObjectField> FIELD_MAP = Schema.SObjectType.ContentDocument.fields.getMap();

    /**
    * @name beforeInsert
    * @description
    * @param
    **/
    //public static void beforeInsert(List<ContentDocument> newList){
    //    for ( Integer i=0;i<newList.size();i++ ){

    //    }
    //}

    ///**
    //* @name afterInsert
    //* @description
    //* @param
    //**/
    //public static void afterInsert(List<ContentDocument> newList){
    //    for ( Integer i=0;i<newList.size();i++ ){

    //    }
    //}

    ///**
    //* @name beforeUpdate
    //* @description
    //* @param
    //**/
    //public static void beforeUpdate(List<ContentDocument> newList, List<ContentDocument> oldList){
    //    for ( Integer i=0;i<newList.size();i++ ){

    //    }
    //}

    ///**
    //* @name afterUpdate
    //* @description
    //* @param
    //**/
    //public static void afterUpdate(List<ContentDocument> newList, List<ContentDocument> oldList){
    //    for ( Integer i=0;i<newList.size();i++ ){

    //    }
    //}

    ///**
    //* @name beforeDelete
    //* @description
    //* @param
    //**/
    //public static void beforeDelete(List<ContentDocument> newList){
    //    for ( Integer i=0;i<newList.size();i++ ){

    //    }
    //}

    /**
    * @name afterDelete
    * @description
    * @param
    **/
    //public static void afterDelete(List<ContentDocument> oldList){
    //    Set<String> ids = new Set<String>();
    //    for ( Integer i=0;i<oldList.size();i++ ){
    //        ids.add(oldList[i].Id);
    //    } 
    //    delete [SELECT Id FROM Deal_Document__c WHERE document_Loaded__c = true AND attachment_Id__c != null AND Attachment_Id__c IN : ids];
        
    //}

    ///**
    //* @name afterUndelete
    //* @description
    //* @param
    //**/
    //public static void afterUndelete(List<ContentDocument> oldList){
    //    for ( Integer i=0;i<oldList.size();i++ ){

    //    }
    //}

}