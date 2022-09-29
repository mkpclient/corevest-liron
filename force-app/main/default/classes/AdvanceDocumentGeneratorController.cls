public class AdvanceDocumentGeneratorController {
    @AuraEnabled
    public static User getCurrentUserDetails() {
        return [Select Id, Name, Email, Title, Department, Phone, Street, City, State, Country, PostalCode from User where Id=:userInfo.getUserId() limit 1];
    }
    @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId, Boolean allChunksComplete, String emailAddress, String ccAddress, String bccAddress, String subject, String emailBody, List<String> attachedFileIds) {
        System.debug('fileName' +fileName);
        if(!allChunksComplete){
            if(fileId == ''){
                fileId = saveTheFile(parentId, fileName, base64Data, contentType);
            }else {
                appendToFile(fileId, base64Data);
            }
            return Id.valueOf(fileId);
        }else{
            saveTheCompleteFile(parentId, fileName, fileId, emailAddress, ccAddress, bccAddress, subject,  emailBody, attachedFileIds);
            return null;
        }
        
        
    }

    @AuraEnabled
    public static void saveProofOfFunds(Id parentId, String fileName, String base64Data, String contentType){
        try {
            
            Opportunity opp = [
                SELECT Id, OwnerId
                FROM Opportunity
                WHERE Id = : parentId
            ];
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S';
            cv.VersionData = EncodingUtil.base64Decode(base64Data);
            cv.Title = fileName;
            cv.PathOnClient = fileName;

            insert cv;

            ContentVersion cv2 = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id
            LIMIT 1
            ];

            Deal_Document__c dealDoc = new Deal_Document__c();
            dealDoc.File_Name__c = fileName;
            dealDoc.ContentVersion_Id__c = cv.Id;
            dealDoc.Attachment_Id__c = cv2.ContentDocumentId;
            dealDoc.Deal__c = parentId;
            
            dealDoc.Document_Loaded__c = true;
            dealDoc.Added_By__c = UserInfo.getUserId();
            dealDoc.Added_On__c = system.now();
            dealDoc.Type__c = 'Misc Documents'; 
            dealDoc.Document_Type__c = 'Proof of Funds';

            insert dealDoc;

            Task task = new Task();
            task.Status = 'Open';
            task.Subject = 'Proof of Funds Letter Expiration';
            task.Description = 'Proof of Funds Letter has Expired. Please reach out to the borrower to see if they need a new one.';
            task.ActivityDate = System.today().addDays(90);
            task.Priority = 'Normal';
            task.WhatId = parentId;
            task.Type = 'Reminder';
            task.IsReminderSet = true;
            task.OwnerId = opp.OwnerId;
            

            insert task;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' Line: ' + e.getLineNumber());
        }
    }
    
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment oAttachment = new Attachment();
    oAttachment.parentId = parentId;
        
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = 'fileName';
        oAttachment.ContentType = contentType;
        
        insert oAttachment;
        
        return oAttachment.Id;
    }
    
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id =: fileId
        ];
        
        String existingBody = EncodingUtil.base64Encode(a.Body);
        
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
        
        update a;
    }
    
    public static void saveTheCompleteFile(Id parentId, String fileName, Id attachId, String emailAddress, String ccAddress, String bccAddress, String subject, String emailBody, List<String> attachedFileIds) {
        List<Messaging.EmailFileAttachment> attachFiles=new List<Messaging.EmailFileAttachment>();
    
        Attachment att = [
            SELECT Id, Body,parentId 
            FROM Attachment
            WHERE Id =: attachId
        ];
    
        Messaging.EmailFileAttachment fAtt = new Messaging.EmailFileAttachment();
        fAtt.setFileName('Bridge_Intake_Form.Docx');
        fAtt.setBody(att.Body);
        attachFiles.add(fAtt);
    
        List<ContentDocument> cds=[SELECT Id, Title,FileExtension, LatestPublishedVersion.VersionData FROM ContentDocument WHERE Id IN : attachedFileIds];
        if(cds!=null && !cds.isEmpty()) {
            for(ContentDocument cd : cds) {
                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
          
                attach.setFileName(cd.Title+'.'+cd.FileExtension);
                attach.setBody(cd.LatestPublishedVersion.VersionData);
                attachFiles.add(attach);
            }
        }
    
        
        List<Opportunity> deal=[Select Id, Name, Deal_Loan_Number__c, LOC_Loan_Type__c, Product_Sub_Type__c, LOC_Commitment__c from opportunity where Id=: parentId];
        if(deal!=null && !deal.isEmpty()) {
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            String loanAmountInString;
            
            semail.setFileAttachments(attachFiles);
            
            //add to addresses
            List<String> toAddresses = new List<String>();
            if(String.isNotBlank(emailAddress)) {
                toAddresses=emailAddress.split(';');
            }
            semail.setToAddresses(toAddresses);
            
            //add cc addresses
            List<String> ccAddresses = new List<String>();
            if(String.isNotBlank(ccAddress)) {
                ccAddresses=ccAddress.split(';');
            }
            semail.setccAddresses(ccAddresses);
            
            //add bcc addresses
            List<String> bccAddresses = new List<String>();
            if(String.isNotBlank(bccAddress)) {
                bccAddresses=bccAddress.split(';');
            }
            semail.setbccAddresses(bccAddresses);
            
            semail.setSubject(Subject);
      		semail.setHtmlBody(emailBody);
            //semail.setPlainTextBody('Hello,\n\nPlease see the attached intake form for '+deal[0].Name+'. '+deal[0].LOC_Loan_Type__c+'/'+deal[0].Product_Sub_Type__c+' loan of $' +loanAmountInString+'. Happy to discuss.\n\nThank you');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
			
			
			User curretUser=[Select id,Name,Email from USer where Id=:UserInfo.getUserId()];
			//log send email
			EmailMessage myemail = new EmailMessage();

			myemail.RelatedToId = parentId;
			myemail.FromAddress = curretUser.Email;
			myemail.Subject = Subject;
			myemail.HtmlBody = emailBody;
			myemail.FromName = curretUser.Name;
			//myemail.HasAttachment = true;

			myemail.Status = '3';
			myemail.ToAddress = !toAddresses.isEmpty() ? toAddresses[0] : '';
			myemail.CcAddress = !ccAddresses.isEmpty() ? ccAddresses[0] : '';
			myemail.BccAddress = !bccAddresses.isEmpty() ? bccAddresses[0] : '';
			
			myemail.Incoming = true;
			//myemail.IncomingSpecified = true;
			//DateTime dt = Convert.ToDateTime(objSalesLoftEmail.sent_at);
			//DateTime SendDate = Convert.ToDateTime(dt.ToString("MM/dd/yyyy hh:mm tt"));
 
			myemail.MessageDate = System.Now() ;
			//MessageDateSpecified = true
			insert myemail;

			//SaveResult[] sr = binding.create(new sObject[] { myemail });
			
        }
    
        delete att;
        delete cds;
    }
    
    @auraEnabled
    public static String deleteFile(List<String> fileIds){
        String response = '';
        try{
            //Delete file 
            delete [select id from ContentDocument where Id IN: fileIds];
            response = 'Success';
        }catch(Exception ex ){ 
            response = ex.getMessage();
        }
        return response;
    }
}