public without sharing class ConstructionAndClosingController {

  @AuraEnabled
    public static Map<String,Decimal> calculateTotal(String dealId){
        Map<String,Decimal> calcutatedTotal = new Map<String,Decimal>();
        system.debug('dealId=>'+dealId);
        if(dealId !=null) {
            Decimal purchasePrice = 0;
            Decimal BPOApp = 0;
            Decimal maxLTC = 0;
            Decimal maxLTV = 0;
            Decimal approvedAdv = 0;
            Decimal advanceFee = 0;
            Decimal BPOAppraisal = 0;
            Decimal docPrep = 0;
            Decimal netFunding = 0;
            Decimal renovationRes = 0;
            Decimal disbursementTotal = 0;
            
            for(Advance__c objAdvance:[SELECT id,Purchase_Price_Total__c,BPO_Appraisal_Value_Total__c,Max_LTC_Total__c,Max_LTV_Total__c,Approved_Advance_Amount_Total__c,Advance_Fee_Total__c,BPO_Appraisal_Fee_Total__c,Doc_Prep_Fee_Total__c,Net_Funding_Total__c,Renovation_Reserve_Total__c,Initial_Disbursement_Total__c FROM Advance__c WHERE Deal__c =:dealId AND Status__c='Completed']){
                
                system.debug('objAdvance=>'+objAdvance);
                purchasePrice += objAdvance.Purchase_Price_Total__c;
                BPOApp += objAdvance.BPO_Appraisal_Value_Total__c;
                maxLTC += objAdvance.Max_LTC_Total__c;
                maxLTV += objAdvance.Max_LTV_Total__c;
                approvedAdv += objAdvance.Approved_Advance_Amount_Total__c;
                advanceFee += objAdvance.Advance_Fee_Total__c;
                BPOAppraisal += objAdvance.BPO_Appraisal_Fee_Total__c;
                docPrep += objAdvance.Doc_Prep_Fee_Total__c;
                netFunding += objAdvance.Net_Funding_Total__c;
                renovationRes += objAdvance.Renovation_Reserve_Total__c;
                disbursementTotal += objAdvance.Initial_Disbursement_Total__c;
            }
            
            calcutatedTotal.put('purchasePrice',purchasePrice);
            calcutatedTotal.put('BPOApp',BPOApp);
            calcutatedTotal.put('maxLTC',maxLTC);
            calcutatedTotal.put('maxLTV',maxLTV);
            calcutatedTotal.put('approvedAdv',approvedAdv);
            calcutatedTotal.put('advanceFee',advanceFee);
            calcutatedTotal.put('BPOAppraisal',BPOAppraisal);
            calcutatedTotal.put('docPrep',docPrep);
            calcutatedTotal.put('netFunding',netFunding);
            calcutatedTotal.put('renovationRes',renovationRes);
            calcutatedTotal.put('disbursementTotal',disbursementTotal);
            system.debug('calcutatedTotal=>'+calcutatedTotal);
        }
        return calcutatedTotal;
    } 

    @AuraEnabled
    public static String reparentAttachment(String attachmentId, String parentId){
        Attachment a = [SELECT Name, Body FROM Attachment WHERE Id = : attachmentId];
        Attachment b = New Attachment(Name = a.Name, Body = a.Body, ParentId = parentId);
        insert b;
        delete a;

        return b.Id;
    }

    @AuraEnabled
    public static String getSession(){
        Map<String, String> res = new Map<String, String>();
        if(!Test.isRunningTest()){
            res.put('sessionId', util.getSessionIdFromVFPage(Page.fileUpload));
        }else{
            res.put('sessionId', '1231');
        }

        res.put('endpoint', 'https://' + ('.'+System.URL.getSalesforceBaseURL().getHost()).subStringBefore('.com').replace('.salesforce','').replace('.force','').replace('.my','').replace('.visual','').subStringAfterLast('.') +'.salesforce.com/');
        if(res.get('endpoint') == 'https://colonyamericanfinance.salesforce.com/' || res.get('endpoint') == 'https://cvest.salesforce.com/'){
            res.put('endpoint', 'https://na54.salesforce.com');
        }

        return JSON.serialize(res);
    }

    @AuraEnabled
    public static String getLoanApplication(String i){
        String queryString = 'SELECT Id, Loan_Application_JSON__c FROM Opportunity WHERE Id =\'' + i + '\' LIMIT 1';

        return JSON.serialize(database.query(queryString)[0]);
    }

    @AuraEnabled
    public static String getRecord(String i){
        return JSON.serialize(util.queryRecordAllFields(Id.valueOf(i)));
    }

    @AuraEnabled
    public static Integer getRelatedListCount(String parentId, String parentFieldName, String sobjectType, String whereClause){
        String queryString = 'SELECT count(Id) cnt FROM ' + sobjectType + ' WHERE ' + parentFieldName + ' = \'' + parentId + '\'';
        if(String.isNotBlank(whereClause)){
            queryString += ' AND ' + whereClause;
        }

        system.debug(queryString);
        AggregateResult ar = database.query(queryString);
        //system.debug(ar.get('cnt'));
        return (Integer)ar.get('cnt');
    }

    @AuraEnabled
    public static String getRecordTypeName(String i){
        if ( String.isNotBlank(i) && i instanceof Id ){
            String queryString = 'SELECT Id, RecordType.DeveloperName FROM ' + String.valueOf(Id.ValueOf(i).getSObjectType()) + ' WHERE Id =\'' + i + '\' AND RecordTypeId != null LIMIT 1';
            List<sObject> sobjList = database.query(queryString);
            if ( sobjList.size() > 0 ){
                return (String)sobjList[0].getsObject('RecordType').get('DeveloperName');
            }
        }
        return 'Master';
    }

    @AuraEnabled
    public static List<sObject> getRecordList(String parentId, String parentFieldName, String sobjectType, List<String> fields, String sortCol, String sortDir, String whereClause, String orderBy){

        //Integer skipRecords = Integer.valueOf( ( page - 1 ) * pageSize );
        //Integer maxRecords = Integer.valueOf( pageSize );

        String queryString = 'SELECT ';
        for(String field : fields){
            queryString += field + ', ';
        }

        queryString = queryString.substringBeforeLast(',');
        queryString += ' FROM ' + sobjectType;


        queryString += ' WHERE '; //+  parentFieldName + ' = \'' + parentId + '\'';

        if(String.isNotBlank(parentFieldName) && String.isNotBlank(parentId) ){
            queryString += parentFieldName + ' = \'' + parentId + '\'';
            if(String.isNotBlank(whereClause)){
                queryString += ' AND ';
            }
        }

        if(String.isNotBlank(whereClause)){
            queryString += whereClause;
        }


        if(String.isNotBlank(orderBy)){
            queryString += ' Order BY ' + orderBy;
        }else if(String.isNotBlank( sortCol )){
            queryString += ' ORDER BY ' + sortCol + ' ' + sortDir;
        }

        //queryString += ' LIMIT ' + maxRecords;
        //queryString += ' OFFSET ' + skipRecords;

        system.debug(queryString);
        //List<sObject> objs = database.query(queryString);
        //system.debug(objs);
        //return JSON.serialize(database.query(queryString));
        return database.query(queryString);

    }


    @AuraEnabled
    public static List<sobject> getRecords(String parentId, String parentFieldName, String sobjectType, List<String> fields, Decimal page, Decimal pageSize, String sortCol, String sortDir, String whereClause, String orderBy){

        Integer skipRecords = Integer.valueOf( ( page - 1 ) * pageSize );
        Integer maxRecords = Integer.valueOf( pageSize );

        String queryString = 'SELECT ';
        for(String field : fields){
            queryString += field + ', ';
        }

        queryString = queryString.substringBeforeLast(',');
        queryString += ' FROM ' + sobjectType;


        queryString += ' WHERE ' +  parentFieldName + ' = \'' + parentId + '\'';
        if(String.isNotBlank(whereClause)){
            queryString += ' AND ' + whereClause;
        }


        if(String.isNotBlank(orderBy)){
            queryString += ' Order BY ' + orderBy;
        }else if(String.isNotBlank( sortCol )){
            queryString += ' ORDER BY ' + sortCol + ' ' + sortDir;
        }

        queryString += ' LIMIT ' + maxRecords;
        queryString += ' OFFSET ' + skipRecords;

        //system.debug(queryString);
        //List<sObject> objs = database.query(queryString);
        //system.debug(objs);
        return database.query(queryString);

    }


    @AuraEnabled
    public static List<sObject> getRelatedList(String parentId, String parentFieldName, String sobjectType, String whereClause, String orderClause){
        String queryString = 'SELECT ';

        for(String field : util.getAllFieldNamesForObject(sobjectType)){
            queryString += field + ', ';
        }
        queryString = queryString.substringBeforeLast(',');
        queryString += ' FROM ' + sobjectType;

        queryString += ' WHERE ' +  parentFieldName + ' = \'' + parentId + '\'';
        if(String.isNotBlank(whereClause)){
            queryString += ' AND ' + whereClause;
        }

        if(String.isNotBlank( orderClause )){
            queryString += ' ORDER BY ' + orderClause;
        }
        system.debug(queryString);
        //queryString += ' LIMIT ' + maxRecords;
        //queryString += ' OFFSET ' + skipRecords;

        //List<sObject> objs = database.query(queryString);

        return database.query(queryString);
    }

    @AuraEnabled
    public static List<sObject> upsertRecords(List<sObject> records){
        return lightning_Util.upsertRecords(records);

    }

    @AuraEnabled
    public static sObject upsertRecord(sObject record){
        try{
            upsert record;
        }catch(DMLException e){
            throw new AuraHandledException(e.getDmlMessage(0));
        }

        return record;//util.queryRecordAllFields((Id)record.get('Id'));
    }

    @AuraEnabled
    public static List<SObject> searchRecords(String searchTerm, String sObjectName, String whereClause, Integer lim){
        List<String> sObjectNames = new List<String>{sobjectName};
        if ( lim == null ){
            lim = 100;
        }
        String queryString = 'FIND \''+searchTerm+'*\' IN ALL FIELDS RETURNING ';
        for ( String s : sObjectNames ){
            queryString += s+'(id,name';
            if ( String.isNotBlank(whereClause) ){
                queryString += ' WHERE '+whereClause;
            }
            queryString += ' LIMIT ' + lim + '),';
        }
        queryString = queryString.subStringBeforeLast(',');
        system.debug(queryString);
        List<sObject> results = new List<sObject>();
        for ( List<SObject> s : search.query(queryString) ){
            results.addAll(s);
        }
        results.sort();
        //system.debug(results);
        return results;
    }

    @AuraEnabled
    public static String getUserId(){
        return UserInfo.getUserId();
    }

    @AuraEnabled
    public static Id saveAttachment(Id parentId, String fileName, String base64Data, String contentType) {
        //base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

        system.debug(parentId);
        system.debug(fileName);
        system.debug(contentType);

        Attachment a = new Attachment();
        a.parentId = parentId;

        a.Body = EncodingUtil.base64Decode(base64Data);
        a.Name = fileName;
        a.ContentType = contentType;

        insert a;
        return a.Id;

        //return null;

    }

    @AuraEnabled
    public static Id saveTheChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        if (fileId == '') {
            fileId = saveAttachment(parentId, fileName, base64Data, contentType);
        } else {
            appendToAttachment(fileId, base64Data);
        }

        return Id.valueOf(fileId);
    }

    private static void appendToAttachment(Id fileId, String base64Data){
        Attachment attch = [SELECT Id, body FROM Attachment WHERE Id =: fileId];
        attch.Body = EncodingUtil.base64Decode(EncodingUtil.base64Encode(attch.Body) + base64Data);

        upsert attch;
    }

    @AuraEnabled
    public static Boolean deleteRecord(sObject record){
        try{
            delete record;
        }catch(DmlException e){
            throw new AuraHandledException('Failed to delete');
        }

        return true;
    }

    @AuraEnabled
    public static Boolean deleteRecords(List<sObject> records){
        try{
            delete records;
        }catch(DmlException e){
            throw new AuraHandledException('Failed to delete');
        }

        return true;
    }

    @AuraEnabled
    public static String saveDataTape(String data, String dealId){

        //try {
            List<Property__c> records = (List<Property__c>)JSON.deserialize(data, List<Property__c>.class);

            List<Property__c> toDelete = new List<Property__c>();
            for(Integer i = records.size()-1; i >= 0; --i){
                if(records[i].IsDeleted){
                    toDelete.add(records.remove(i));
                }
            }

            if(toDelete.size() > 0){
                delete toDelete;
            }

            Map<String, List<Property__c>> unitMap = new Map<String, List<Property__c>>();

            List<Property__c> properties = new List<Property__c>();
            for(Integer i = 0; i < records.size(); i++){
                //if(records[i].Name == null || String.isBlank(records[i].Name])){

                //}

                if(records[i].Name != records[i].Property_Name__c && String.isNotBlank(records[i].Property_Name__c) && records[i].Parent_Property__c == null){
                    if( !unitMap.containsKey(records[i].Property_Name__c) ){
                        unitMap.put(records[i].Property_Name__c, new List<Property__c>());
                    }
                    unitMap.get(records[i].Property_Name__c).add(records[i]);
                }
                //if(records[i].Property_Type__c == 'Parent'){
                //    records.remove(i);
                //}

                if(records[i].Name != null && String.isNotBlank(records[i].Name) && records[i].Property_Type__c != 'Parent'){
                    properties.add(records[i]);
                }

            }

            for(Property__c parentProperty : [SELECT Id, Name FROM Property__c WHERE Deal__c =: dealId and Name IN: unitMap.keySet() AND Is_Parent__c = true]){
        
                for(Property__c p : unitMap.get(parentProperty.Name)){
                    p.Parent_Property__c = parentProperty.Id;
                    p.Is_Sub_Unit__c = true;
                }

                unitMap.remove(parentProperty.Name);
            }

            List<Property__c> parents = new List<Property__c>();
            for(String propertyName : unitMap.keySet()){
                parents.add(new Property__c(Name = propertyName, Deal__c = dealId, Property_Name__c = propertyName, Status__c='Active', Is_Parent__c = true));
            }

            if(parents.size() > 0){
                //insert parents;
                parents = (List<Property__c>)lightning_Util.upsertRecords(parents);
                //propUpdate = (List<Property__c>)lightning_Util.upsertRecords(propUpdate);
            }
            for(Property__c parent : parents){
                for(Property__c p : unitMap.get(parent.Name)){
                    p.Parent_Property__c = parent.Id;
                    p.Is_Sub_Unit__c = true;
                }
            }

            //system.debug(properties.size());

            List<Property__c> propInsert = new List<Property__c>();
            List<Property__c> propUpdate = new List<Property__c>();

            Map<String, Schema.SobjectField> propertyFieldMap = Schema.getGlobalDescribe().get('Property__c').getDescribe().fields.getMap();

            for(Property__c p : properties){
                if(p.Id == null){
                    Map<String, Object> fieldMap = p.getPopulatedFieldsAsMap();
                    Property__c p2 = new Property__c();
                    for(String field : fieldMap.keySet()){

                        if(fieldMap.get(field) != null && propertyFieldMap.get(field).getDescribe().isCreateable()){
                            p2.put(field, fieldMap.get(field));
                        }
                        
                    }

                    propInsert.add(p2);

                    //propInsert.add((Property__c) fieldMap);

                }else{
                    propUpdate.add(p);
                }
            }

            //insert propInsert;
            //update propUpdate;

            propInsert = (List<Property__c>)lightning_Util.upsertRecords(propInsert);
            propUpdate = (List<Property__c>)lightning_Util.upsertRecords(propUpdate);


            //upsert properties;

            propUpdate.addAll(propInsert);

            return JSON.serialize(propUpdate);
        //}catch(Exception e){
            
            //throw new AuraHandledException('Line Number: ' + e.getLineNumber() + ' ' + e.getMessage());
        //}


        //system.debug(unitMap.keySet());

        //system.debug(records[0]);
        //return 'success';
    }

    @AuraEnabled
    public static String getTemplate(String fileName){
        System.debug(0);
        ContentDocument doc = [SELECT Id, Title FROM ContentDocument WHERE Title = : fileName LIMIT 1];
        System.debug(1);
        ContentVersion cv = [select id, versiondata, createddate from contentversion where contentdocumentid= :doc.Id order by createddate desc LIMIT 1];

        return JSON.serialize(cv.versiondata);
    }

    @AuraEnabled
    public static String givePortalAccess(String recordId){
        Set<Id> contactIds = new Set<Id>();
        for(Opportunity o : [SELECT Id, Contact__c, (SELECT Id, Contact__c FROM Deal_Contacts__r WHERE Contact__c != null AND Entity_Type__c='Portal Access') FROM Opportunity WHERE Id = : recordId]){
            system.debug(o);
            contactIds.add(o.Contact__c);
            if(o.Deal_Contacts__r != null){
                for(Deal_Contact__c c : o.Deal_Contacts__r){
                    contactIds.add(c.Contact__c);
                }
            }
        }

        system.debug(contactIds);

        List<User> portalUsers = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Customer Portal User' LIMIT 1];

        for(User u : [SELECT Id, ContactId FROM User WHERE ContactId IN : contactIds]){
            contactIds.remove(u.ContactId);
        }

        for(Contact c : [SELECT Id, Email, FirstName, LastName FROM Contact WHERE Id IN : contactIds]){
            User u = new User(ContactId=c.Id, username = c.Email, firstName = c.FirstName, lastName = c.LastName, email=c.Email,
                                communityNIckName = c.LastName + '_' + c.FirstName, alias = string.valueof(c.FirstName.substring(0,1) + c.LastName.substring(0,1)),
                                profileid = p.Id, emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles');

            portalUsers.add(u);


        }

        system.debug(portalUsers);

        Database.DMLOptions dlo = new Database.DMLOptions();
            dlo.EmailHeader.triggerUserEmail = true;

            List<Database.saveResult> sr = Database.Insert(portalUsers, dlo);

        return JSON.serialize(portalUsers);
    }

    @AuraEnabled
    public static Map<String, Object> getDocumentData(String contentVersionId){

        ContentVersion cv = [SELECT Id, VersionData, Title, ContentSize FROM ContentVersion WHERE Id = : contentVersionId];
        Map<String, Object> resp = new Map<String, Object>();

        resp.put('title', cv.Title);
        resp.put('data', EncodingUtil.base64Encode(cv.VersionData));
        resp.put('size', cv.ContentSize);

        return resp;
    }

    @AuraEnabled
    public static String getDocuments(String recordId, String userType, String accountId, String accountType){
        String queryString = '';


        if(userType == 'internal'){
            queryString = 'SELECT Id, Deal__r.Name, Deal__r.Deal_Loan_Number__c, Folder_String__c, ContentVersion_Id__c, Attachment_Id__c, ';
            queryString += 'Vendor_Type_Access__c, Property__r.Name, Property__c, Document_Type__c FROM Deal_Document__c ';
            queryString += 'WHERE Deal__c = \'' + recordId + '\' AND Attachment_Id__c != null AND ContentVersion_Id__c != null';
        }else if(userType == 'vendor'){
            queryString = 'SELECT Id, Deal__r.Name, Deal__r.Deal_Loan_Number__c, Folder_String__c, ContentVersion_Id__c, Attachment_Id__c, ';
            queryString += 'Vendor_Type_Access__c, Property__r.Name, Property__c, Document_Type__c FROM Deal_Document__c ';
            queryString += 'WHERE Deal__c = \'' + recordId + '\' AND Attachment_Id__c != null AND ContentVersion_Id__c != null AND Vendor_Access__c = true AND Confidential__c = false AND Is_Viewable__c = true';
        }else if(userType == 'borrower'){
            queryString = 'SELECT Id, Deal__r.Name, Deal__r.Deal_Loan_Number__c, Folder_String__c, ContentVersion_Id__c, Attachment_Id__c, ';
            queryString += 'Vendor_Type_Access__c, Property__r.Name, Property__c, Document_Type__c FROM Deal_Document__c ';
            queryString += 'WHERE Deal__c = \'' + recordId + '\' AND Attachment_Id__c != null AND ContentVersion_Id__c != null AND Borrower_Access__c = true AND Confidential__c = false AND Is_Viewable__c = true';
        }

        List<Deal_Document__c> docs = (List<Deal_Document__c>)database.query(queryString);
        if(userType == 'vendor'){
            for(Integer i = docs.size() - 1; i >= 0; i--){
                Boolean isVisible = true;
                if(String.isNotBlank(docs[i].Vendor_Type_Access__c)){
                    Set<String> filterSet = new Set<String>(docs[i].Vendor_Type_Access__c.split(';'));
                    isVisible = filterSet.contains(accountId) || filterSet.contains(accountType);
                }

                if(!isVisible){
                    docs.remove(i);
                }
            }



        }else if(userType == 'borrower'){

        }

        Map<Id, Deal_Document__C> docMap = new Map<Id, Deal_Document__c>();
        for(Deal_Document__c doc : docs){
            docMap.put(doc.ContentVersion_Id__c, doc);
        }

        for(ContentVersion cv : [SELECT Id, FileExtension FROM ContentVersion WHERE ID IN: docMap.keySet()]){
            if(cv.FileExtension == 'xml'){
                docMap.remove(cv.Id);
            }
        }


        return JSON.serialize(docMap.values());
    }

}