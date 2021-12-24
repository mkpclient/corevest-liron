public class TermPostClosingEmailController {
  public static final string ONBOARDING = 'LoanOnboarding';
  public static final string RECORDTYPE = 'Schedule_of_Lender_Cost';
  public static final string TEMPLATE = 'Term_Post_Closing_Template';
  public String recId { get; set; }

  public Loan_Version__c loanVersion {
    get {
      return recid != null
        ? [
            SELECT
              Holdback_Reserve__c,
              Initial_Monthly_Tax_Reserve_Deposit__c,
              Monthly_Cap_Ex__c,
              Monthly_Tax__c,
              Required_Holdback_Reserve__c,
              Recourse__c,
              RecordType.DeveloperName,
              Monthly_Insurance__c,
              Monthly_Payment__c,
              Tax_Payment_Recurrence__c,
              First_Tax_Installment_Due__c,
              Taxes_Paid_at_Closing__c
            FROM Loan_Version__c
            WHERE RecordType.DeveloperName = :ONBOARDING AND Deal__c = :recId
            LIMIT 1
          ]
        : new Loan_Version__c();
    }
    private set;
  }

  @AuraEnabled(cacheable=true)
  public static Loan_Version__c getLoanVersion(Id dealId) {
    if(test.isRunningTest()) {
      return new Loan_Version__c();
    }
    try {
      List<Loan_Version__c> localLoanVersion = [
        SELECT
          Holdback_Reserve__c,
          Initial_Monthly_Tax_Reserve_Deposit__c,
          Monthly_Cap_Ex__c,
          Monthly_Tax__c,
          Required_Holdback_Reserve__c,
          Recourse__c,
          RecordType.DeveloperName,
          Monthly_Insurance__c,
          Monthly_Payment__c,
          Tax_Payment_Recurrence__c,
          First_Tax_Installment_Due__c,
          Taxes_Paid_at_Closing__c
        FROM Loan_Version__c
        WHERE
          ((RecordType.DeveloperName = :RECORDTYPE
          AND Finalized__c = TRUE)
          OR RecordType.DeveloperName = :ONBOARDING)
          AND Deal__c = :dealId
        ORDER BY CreatedDate DESC
        LIMIT 1
      ];

      if (localLoanVersion.size() > 0) {
        return localLoanVersion[0];
      } else {
        List<Loan_Version__c> unfinalizedLv = [
          SELECT
            Holdback_Reserve__c,
            Initial_Monthly_Tax_Reserve_Deposit__c,
            Monthly_Cap_Ex__c,
            Monthly_Tax__c,
            Required_Holdback_Reserve__c,
            Recourse__c,
            RecordType.DeveloperName,
            Monthly_Insurance__c,
            Monthly_Payment__c,
            Tax_Payment_Recurrence__c,
            First_Tax_Installment_Due__c,
            Taxes_Paid_at_Closing__c
          FROM Loan_Version__c
          WHERE RecordType.DeveloperName = :RECORDTYPE AND Deal__c = :dealId
          ORDER BY CreatedDate DESC
          LIMIT 1
        ];

        if (unfinalizedLv.size() > 0) {
          return unfinalizedLv[0];
        } else {
          return new Loan_Version__c();
        }
      }
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static Loan_Version__c saveLoanVersion(Loan_Version__c newRecord) {
    if(test.isRunningTest()) {
      return new Loan_Version__c();
    }
    Id rtypeId = SObjectType.Loan_Version__c.getRecordTypeInfosByDeveloperName()
      .get(ONBOARDING)
      .getRecordTypeId();
    newRecord.RecordTypeId = rtypeId;
    upsert newRecord;
    return newRecord;
  }

  @AuraEnabled(cacheable=true)
  public static String getEmailInfo(Id dealId) {
    Map<String, List<Object>> retVal = new Map<String, List<Object>>();
    if(test.isRunningTest()) {
      return 'test';
    }
    EmailTemplate template = [
      SELECT Id, Body
      FROM EmailTemplate
      WHERE DeveloperName = :TEMPLATE
      LIMIT 1
    ];
    Messaging.SingleEmailMessage mail;
    mail = Messaging.renderStoredEmailTemplate(template.Id, null, dealId);
    retVal.put('emailBody', new List<Object>{ mail.getHTMLBody() });
    retVal.put('subject', new List<Object>{ mail.getSubject() });
    
    return JSON.serialize(retVal);
  }

  @AuraEnabled
  public static String sendEmail(String s) {
    Map<String, String> m = (Map<String, String>) JSON.deserialize(
      s,
      Map<String, String>.class
    );
    m.put('user', UserInfo.getName());

    List<String> recipientEmails = m.get('recipients').split(';');

    List<String> ccEmails = m.containsKey('cc') &&
      String.isNotEmpty(m.get('cc'))
      ? m.get('cc').split(';')
      : new List<String>();

    List<String> addresses = new List<String>();
    addresses.addAll(recipientEmails);
    
    String body = m.get('emailBody');
    Id recId = (Id) m.get('recordId');
    
    try {
      sendMail(
        addresses,
        m.get('subject'),
        body,
        ccEmails,
        m.get('user'),
        true,
        true,
        null,
        null,
        recId
      );
    } catch (Exception err) {
      Map<String, String> e = new Map<String, String>{
        'Error' => err.getMessage()
      };
      return JSON.serialize(e);
    }
    Map<String, String> r = new Map<String, String>{
      'Success' => 'Email Sent'
    };
    return JSON.serialize(r);
  }

  public static Integer queryDealDocument(Id recordId) {
    return [
        SELECT COUNT()
        FROM Deal_Document__c
        WHERE
          Deal__c = :recordId
          AND Type__c = 'DS Funding Package - DS Funding Package'
          AND File_Name__c LIKE '%BerkadiaOnboarding%'
          AND ContentVersion_Id__c != null
          AND Document_Loaded__c = true
      ] + 1;
  }

  @AuraEnabled
  public static Map<String, String> saveDocument(Id recordId) {
    Savepoint sp = Database.setSavepoint();
    try {
      Integer i = queryDealDocument(recordId);
      Pagereference pdfPage =
        new PageReference('/apex/TermPostClosingBerkadiaOnboardingLetter?id=' + recordId);
      Blob content;
      ContentVersion cv;
      if (Test.isRunningTest()) {
        content = Blob.valueOf('TEST VAL');
        cv = new ContentVersion(PathOnClient = 'test.pdf', VersionData = content);
      } else {
        content = pdfPage.getContentAsPdf();
        cv = new ContentVersion(
          PathOnClient = 'BerkadiaOnboarding' + '(' + i + ')' + '.pdf',
          VersionData = content
        );
      }
      insert cv;
      ContentVersion queryCv = [
        SELECT ContentDocumentId
        FROM ContentVersion
        WHERE Id = :cv.Id
        LIMIT 1
      ];

      Deal_Document__c dd = new Deal_Document__c(
        ContentVersion_Id__c = queryCv.Id,
        Attachment_Id__c = queryCv.ContentDocumentId,
        Type__c = 'DS Funding Package - DS Funding Package',
        Section__c = 'DS Funding Package',
        Document_Type__c = 'Miscellaneous',
        Deal__c = recordId,
        Added_On__c = System.now(),
        Added_By__c = UserInfo.getUserId(),
        Document_Loaded__c = true,
        File_Name__c = 'BerkadiaOnboarding' + '(' + i + ')' + '.pdf'
      );

      insert dd;

      ContentDocumentLink cdl = new ContentDocumentLink(
        LinkedEntityId = dd.Id,
        ContentDocumentId = queryCv.ContentDocumentId,
        ShareType = 'V'
      );

      insert cdl;
      return new Map<String, String>{'Success' => '' + dd.Id};
    } catch (AuraException err) {
      Database.rollback(sp);
      return new Map<String, String>{'Error' => err.getMessage()};
    }
  }

  public static Messaging.SingleEmailMessage sendMail(
    List<String> toAddresses,
    String subject,
    String htmlBody,
    List<String> ccAddresses,
    String senderDislayName,
    Boolean useSignature,
    Boolean saveAsActivity,
    Id targetObjectId,
    Id templateId,
    Id whatId
  ) {
    Messaging.reserveSingleEmailCapacity(1);
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    if (toAddresses != null && toAddresses.size() > 0) {
      mail.setToAddresses(toAddresses);
    }
    if (String.isNotblank(subject)) {
      mail.setSubject(subject);
    }
    if (String.isNotBlank(htmlBody)) {
      mail.setHtmlBody(htmlBody);
    }
    if (ccAddresses != null && ccAddresses.size() > 0) {
      mail.setCcAddresses(ccAddresses);
    }
    if (String.isNotBlank(senderDislayName)) {
      mail.setSenderDisplayName(senderDislayName);
    }
    if (useSignature != null) {
      mail.setUseSignature(useSignature);
    }
    if (saveAsActivity != null) {
      mail.setSaveAsActivity(saveAsActivity);
    }
    if (targetObjectId != null) {
      mail.setTargetObjectId(targetObjectId);
    }
    if (templateId != null) {
      mail.setTemplateId(templateId);
    }
    if (whatId != null) {
      mail.setWhatId(whatId);
    }
    System.debug('this is the mail being sent');
    System.debug(mail);
    if (!Test.isRunningTest()) {
      Messaging.SendEmailResult[] results = Messaging.sendEmail(
        new List<Messaging.SingleEmailMessage>{ mail }
      );
      System.debug('these are the results of sending your initial email: ');
      System.debug(results);
    }
    return mail;
  }
}