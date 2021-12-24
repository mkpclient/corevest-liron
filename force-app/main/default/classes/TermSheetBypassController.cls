public without sharing class TermSheetBypassController {

    // Opportunity.OwnerId, CAF Originator (Lookup on User)
    // Opportunity.Closer__c, Closer (Lookup on User)
    // Opportunity.Guarantor__c, Guarantor (Lookup on Contact)
    // Opportunity.Internal_Referral__c, Internal Referral (Lookup on User)
    // Opportunity.Loan_Coordinator__c, Loan Coordinator (Lookup on User)
    // Opportunity.Primary_Contact__c, Primary Contact (Lookup on Contact)
    // Opportunity.Underwriter__c, Underwriter (Lookup on User)

    // Opportunity.Counsel__c, Counsel (Lookup on Account)
    // Opportunity.Insurance__c, Insurance__c (Lookup on Account)
    // Opportunity.Title__c, Title__c (Lookup on Account)
    // Opportunity.PNC__c (Lookup on Account)

    // public static final String emailAddress = 'dealapprovalhandler@1rcof8n96wj6plns2owu5ajq75yd8wlpy914j3zbt9jk5bfree.2f-crgzuas.cs91.apex.sandbox.salesforce.com';

    // public static final String emailAddress = 'deal_approval_handler@1-2ubmvsr19x7o406nnymb5zkfzbl7wsflro23z72qyy25g7hr6z.5c-8jnxuay.cs62.apex.sandbox.salesforce.com';

    // public static final String BRIDGE_LIST = 'caf.test@cvest.com';
    // public static final String TERM_LIST = 'caf.test@cvest.com';



    // public static final String termDistList = m.get('Term Sheet Request').Email_Address__c;
    // public static final String bridgeDistList = m.get('Bridge Term Sheet Request').Email_Address__c;

    // public static Map<String,Email_Addresses__c> m = Email_Addresses__c.getAll();
    // public static final String emailAddress = m.get('dealApprovalHandler').Value__c;
    // public static final String termDistList = m.get('Term Sheet Request').Value__c;
    // public static final String bridgeDistList = m.get('Bridge Term Sheet Request').Value__c;
    //
    // User userBeth = [
    //     SELECT Id,Email
    //     FROM User
    //     WHERE Name = 'Beth O\'Brien'
    //     LIMIT 1
    // ];
    //
    // User userRyan = [
    //     SELECT Id,Email
    //     FROM User
    //     WHERE Name = 'Ryan McBride'
    //     LIMIT 1
    // ];
    // public static final String BETH = userBeth.Email;
    // public static final String RYAN = userRyan.Email;

    public static List<String> fields = new List<String>{
        // 'Opportunity.OwnerId',
        // 'Opportunity.Closer__c',
        // 'Opportunity.Internal_Referral__c',
        // 'Opportunity.Loan_Coordinator__c',
        // 'Opportunity.Contact__c',
        // 'Opportunity.Underwriter__c',

        'Opportunity.Owner.Email',
        // 'Opportunity.Closer__r.Email',
        // 'Opportunity.Internal_Referral__r.Email',
        // 'Opportunity.Loan_Coordinator__r.Email',
        // 'Opportunity.Contact__r.Email',
        // 'Opportunity.Underwriter__r.Email',

        // 'Opportunity.Owner.Name',
        // 'Opportunity.Closer__r.Name',
        // 'Opportunity.Internal_Referral__r.Name',
        // 'Opportunity.Loan_Coordinator__r.Name',
        // 'Opportunity.Contact__r.Name',
        // 'Opportunity.Underwriter__r.Name',
        'Name',
        'Record_Type_Name__c',
        'LOC_Program_Type__c',
        'Product_Sub_Type__c'
    };

    // public static Map<String,String> loansToTemplate = new Map<String,String>{
    //     'Term Loan' => 'TERM_Term_Sheet_Request',
    //     'LOC Loan Outside Guidelines' => 'BRIDGE_Term_Sheet_Request',
    //     'LOC Loan Within Guidelines' => 'BRIDGE_Term_Sheet_Request_Within_Pricing_Guidelines'
    // };


    @AuraEnabled
    public static String returnDeal(Id recordId){
        Map<String,Object> m = new Map<String,List<Object>>();
        String qs = 'SELECT ';
        qs += String.join(fields,', ');
        qs += ' FROM Opportunity WHERE Id = :recordId';

        List<sObject> oList = Database.query(qs);
        Opportunity o;


        Integer versionNumber = 0;
        List<Deal_Document__c> ddList = [
            SELECT ContentVersion_Id__c,Attachment_Id__c,Type__c
            FROM Deal_Document__c
            WHERE Deal__c = :recordId
            AND File_Name__c LIKE '%.pdf'
            AND ContentVersion_Id__c != null
            AND Document_Loaded__c = true
            AND Is_Deleted__c = false
            AND Type__c = 'Term Sheet'
        ];

        List<Id> ddCvIds = new List<Id>();
        if (null != ddList && ddList.size() > 0){
            for (Deal_Document__c ddc : ddList){
                if ('Term Sheet' == ddc.Type__c){
                    versionNumber += 1;
                }
                if (null != ddc.ContentVersion_Id__c){
                    ddCvIds.add(ddc.ContentVersion_Id__c);
                }
            }
        }


        //
        // System.debug('this is ddList');
        // System.debug(ddList);
        // System.debug('these are ddCvIds');
        // System.debug(ddCvIds);
        //
        // List<ContentVersion> compiledCv = new List<ContentVersion>();
        List<ContentVersion> cvList = [
            SELECT Id,PathOnClient
            FROM ContentVersion
            WHERE Id IN :ddCvIds
        ];

        if (versionNumber == 0){
            // m.put('Error', new List<String>{'true'});
            m.put('TermSheetError', new List<String>{'true'});
            return JSON.serialize(m, true);
        }

        // }

        //m.put('ContentVersions', cvList);
        return JSON.serialize(m, true);
    }

    @AuraEnabled
    public static String bypassDeal(String recordId){
        try{
            Deal_Document__c termSheet = [
                SELECT ContentVersion_Id__c,Attachment_Id__c,Type__c, File_Name__c
                FROM Deal_Document__c
                WHERE Deal__c = :recordId
                AND File_Name__c LIKE '%.pdf'
                AND ContentVersion_Id__c != null
                AND Document_Loaded__c = true
                AND Is_Deleted__c = false
                AND Type__c = 'Term Sheet'
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];

            Attachment a = createAttachmentFromCv(termSheet.ContentVersion_Id__c);
            a.ParentId = recordId;
            insert a;

            Opportunity o = new Opportunity(Id = recordId, Bypass_To_Underwriting__c = true, 
                                            Approved_Term_Sheet__c = termSheet.ContentVersion_Id__c, 
                                            Approved_Term_Sheet_Name__c = termSheet.File_Name__c);

            update o;
            



            return 'This record has successfully been bypassed';
        }catch(DmlException e){
            throw new AuraException(e.getMessage());
        }
    }

    public static Attachment createAttachmentFromCV(Id contentVersionId){
        
        ContentVersion cv = [SELECT Id, PathOnClient, VersionData  FROM ContentVersion WHERE Id =: contentVersionId];

        return new Attachment(Name = cv.PathOnClient, Body = cv.VersionData);

    }

    // close Return the Deal

}