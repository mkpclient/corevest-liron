public without sharing class YardiEmailSubmissionController {
  public static List<String> fields = new List<String>{
    'Opportunity.Owner.Email',
    'Name',
    'Record_Type_Name__c',
    'LOC_Program_Type__c',
    'Product_Sub_Type__c',
    'Amount',
    'Underwriter__r.Email',
    'Loan_Coordinator__r.Email',
    'Closer__r.Email',
    'IC_Approval__c',
    'StageName'
  };

  public static final List<String> DOCTYPES = new List<String>{
    'DS Funding Package'
  };

  public static List<EmailTemplate> queryEmailTemplate(String templateName) {
    return [
      SELECT Id, Body
      FROM EmailTemplate
      WHERE DeveloperName = :templateName
      LIMIT 1
    ];
  }

  @AuraEnabled
  public static String returnDeal(Id recordId) {
    Map<String, Object> m = new Map<String, List<Object>>();
    String qs = 'SELECT ';
    qs += String.join(fields, ', ');
    qs += ' FROM Opportunity WHERE Id = :recordId LIMIT 1';

    List<Opportunity> deal = [
      SELECT Id, StageName
      FROM Opportunity
      WHERE Id = :recordId
    ];

    system.debug(deal);
    system.debug(recordId);
    if (deal.size() > 0) {
      Id dealId = deal[0].Id;
      if (deal[0].StageName != 'Approved by Committee') {
        m.put(
          'Error',
          new List<Object>{ 'Deal needs to be in Approved by Committee.' }
        );
        return JSON.serialize(m);
      }
    } else {
      m.put('Error', new List<Object>{ 'Unable to process Deal.' });
      return JSON.serialize(m);
    }

    Integer versionNumber = 0;
    List<Deal_Document__c> ddList = [
      SELECT ContentVersion_Id__c, Attachment_Id__c, Type__c, Document_Type__c
      FROM Deal_Document__c
      WHERE
        Deal__c = :recordId
        AND ContentVersion_Id__c != NULL
        AND Document_Loaded__c = TRUE
        AND Is_Deleted__c = FALSE
        AND Type__c IN :DOCTYPES
    ];

    List<Id> ddCvIds = new List<Id>();
    Set<Id> icMemoIds = new Set<Id>();
    if (null != ddList && ddList.size() > 0) {
      for (Deal_Document__c ddc : ddList) {
        if (null != ddc.ContentVersion_Id__c) {
          ddCvIds.add(ddc.ContentVersion_Id__c);
        }
      }
    }

    List<ContentVersion> cvList = [
      SELECT Id, PathOnClient, Description
      FROM ContentVersion
      WHERE Id IN :ddCvIds
    ];

    // String oRecordType;
    List<Person> p = new List<Person>{ new Person().currentUser() };
    EmailTemplate e;

    List<EmailTemplate> eList = queryEmailTemplate('Send_to_Accounting');
    m.put('eList', eList);
    if (eList.size() > 0) {
      e = eList[0];
    }

    if (deal.size() > 0 && null != e) {
      Messaging.SingleEmailMessage mail;
      mail = Messaging.renderStoredEmailTemplate(
        e.Id,
        null,
        (Id) deal[0].get('Id')
      );
      m.put('EmailContents', new List<Object>{ mail.getHTMLBody() });
      m.put('Subject', new List<Object>{ mail.getSubject() });
    }
    m.put('Recipients', new List<Object>{ 'cafaccounting@cvest.com' });
    m.put('CC', new List<Object>{ 'kaitlyn.vuong@cvest.com' });

    // m.put('Recipients', new List<Object>{ 'jonathan.lay@cvest.com' });
    // m.put('CC', new List<Object>{ 'mcastillo@mkpartners.com' });

    m.put('ContentVersions', cvList);
    m.put('CurrentUser', p);
    return JSON.serialize(m, true);
  }

  @AuraEnabled
  public static String sendEmail(String s, String attachIds) {
    Map<String, String> m = (Map<String, String>) JSON.deserialize(
      s,
      Map<String, String>.class
    );

    List<String> recipientEmails = m.get('recipients').split(';');
    List<String> ccEmails = String.isNotEmpty(m.get('cc'))
      ? m.get('cc').split(';')
      : new List<String>();

    List<Id> aIds = (List<Id>) JSON.deserialize(attachIds, List<Id>.class);
    List<Messaging.EmailFileAttachment> attachmentsList = new List<Messaging.EmailFileAttachment>();
    for (ContentVersion a : queryContentVersions(aIds)) {
      attachmentsList.add(constructFileAttachment(a));
    }

    List<String> addresses = new List<String>();
    addresses.addAll(recipientEmails);

    String body = m.get('emailBody');

    // body += ;

    try {
      sendMail(
        addresses,
        m.get('subject'),
        body,
        attachmentsList,
        ccEmails,
        m.get('user'),
        null,
        null,
        null,
        null,
        m.get('recordId')
      );
    } catch (Exception err) {
      Map<String, String> e = new Map<String, String>{
        'Error' => 'FROM SEND MAIL' + err.getMessage()
      };
      return JSON.serialize(e);
    }
    Map<String, String> r = new Map<String, String>{
      'Success' => 'Email Sent'
    };
    return JSON.serialize(r);
  }

  public static Messaging.EmailFileAttachment constructFileAttachment(
    ContentVersion cv
  ) {
    Messaging.EmailFileAttachment file = new Messaging.EmailFileAttachment();
    if (cv != null) {
      file.setFileName(cv.PathOnClient);
      if (null != cv.FileType) {
        file.setContentType('application/' + cv.FileType.toLowerCase());
      }
      file.setBody(cv.VersionData);
    }

    return file;
  }

  public static Messaging.SingleEmailMessage sendMail(
    List<String> toAddresses,
    String subject,
    String htmlBody,
    List<Messaging.EmailFileAttachment> fileAttachments,
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
    if (fileAttachments != null && fileAttachments.size() > 0) {
      mail.setFileAttachments(fileAttachments);
    }
    if (ccAddresses != null && ccAddresses.size() > 0) {
      mail.setCcAddresses(ccAddresses);
    }
    if (String.isNotBlank(senderDislayName)) {
      mail.setSenderDisplayName(senderDislayName);
    }
    if (useSignature != null) {
      mail.setUseSignature(false);
    }
    if (saveAsActivity != null) {
      mail.setSaveAsActivity(saveAsActivity);
    }
    // if (targetObjectId != null) {
    //   mail.setTargetObjectId(targetObjectId);
    // }
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
      system.enqueueJob(new YardiQueueable('termXML', new List<Id>{ whatId }));
    }

    return mail;
  }

  public static List<ContentVersion> queryContentVersions(List<Id> cIds) {
    return [
      SELECT PathOnClient, VersionData, FileType
      FROM ContentVersion
      WHERE Id IN :cIds
    ];
  }

  public class Person {
    public Id Id;
    public String Name;
    public String Email;

    public Person currentUser() {
      Id = UserInfo.getUserId();
      Name = UserInfo.getUserId();
      Email = UserInfo.getUseremail();
      return this;
    }
  }
}