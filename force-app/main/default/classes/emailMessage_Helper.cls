public class emailMessage_Helper {

    public static Map<String, Schema.SObjectField> FIELD_MAP = Schema.SObjectType.EmailMessage.fields.getMap();

    /**
    * @name beforeInsert
    * @description
    * @param
    **/
    //public static void beforeInsert(List<EmailMessage> newList){
    //    for ( Integer i=0;i<newList.size();i++ ){

    //    }
    //}

    /**
    * @name afterInsert
    * @description
    * @param
    **/
    public static void afterInsert(List<EmailMessage> newList){
        //Set<Id> oppIds = new Set<Id>();
        //for ( EmailMessage e : newList){
        //    if(e.Subject == 'Welcome Email' && e.RelatedToId != null &&  e.RelatedToId.getSobjectType() == Schema.Opportunity.SObjectType ){
        //        oppIds.add(e.relatedToId);
        //    }
        //}

        //for(EmailMessage e : newList){

        //}

        //system.debug(oppIds);

        //Set<Id> contactIds = new Set<Id>();
        //for(Opportunity o : [SELECT Id, Contact__c, (SELECT Id, Contact__c FROM Deal_Contacts__r WHERE Contact__c != null AND Entity_Type__c='Portal Access') FROM Opportunity WHERE Id IN : oppIds]){
        //    system.debug(o);
        //    contactIds.add(o.Contact__c);
        //    if(o.Deal_Contacts__r != null){
        //        for(Deal_Contact__c c : o.Deal_Contacts__r){
        //            contactIds.add(c.Contact__c);
        //        }
        //    }
        //}

        //system.debug(contactIds);

        //List<User> portalUsers = new List<User>();
        //Profile p = [SELECT Id FROM Profile WHERE Name = 'Customer Portal User' LIMIT 1];

        //for(User u : [SELECT Id, ContactId FROM User WHERE ContactId IN : contactIds]){
        //    contactIds.remove(u.ContactId);
        //}

        //for(Contact c : [SELECT Id, Email, FirstName, LastName FROM Contact WHERE Id IN : contactIds]){
        //    User u = new User(ContactId=c.Id, username = c.Email, firstName = c.FirstName, lastName = c.LastName, email=c.Email, 
        //                        communityNIckName = c.LastName + '_' + c.FirstName, alias = string.valueof(c.FirstName.substring(0,1) + c.LastName.substring(0,1)), 
        //                        profileid = p.Id, emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles');

        //    portalUsers.add(u);
            

        //}

        //system.debug(portalUsers);

        //Database.DMLOptions dlo = new Database.DMLOptions();
        //    dlo.EmailHeader.triggerUserEmail = true;

        //    List<Database.saveResult> sr = Database.Insert(portalUsers, dlo);



    }

    /**
    * @name beforeUpdate
    * @description
    * @param
    **/
    //public static void beforeUpdate(List<EmailMessage> newList, List<EmailMessage> oldList){
    //    for ( Integer i=0;i<newList.size();i++ ){

    //    }
    //}

    /**
    * @name afterUpdate
    * @description
    * @param
    **/
    //public static void afterUpdate(List<EmailMessage> newList, List<EmailMessage> oldList){
    //    for ( Integer i=0;i<newList.size();i++ ){

    //    }
    //}

    /**
    * @name beforeDelete
    * @description
    * @param
    **/
    //public static void beforeDelete(List<EmailMessage> newList){
    //    for ( Integer i=0;i<newList.size();i++ ){

    //    }
    //}

    /**
    * @name afterDelete
    * @description
    * @param
    **/
    //public static void afterDelete(List<EmailMessage> newList, List<EmailMessage> oldList){
    //    for ( Integer i=0;i<newList.size();i++ ){

    //    }
    //}

    /**
    * @name afterUndelete
    * @description
    * @param
    **/
    //public static void afterUndelete(List<EmailMessage> oldList){
    //    for ( Integer i=0;i<oldList.size();i++ ){

    //    }
    //}

}