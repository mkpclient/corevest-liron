public without sharing class EmailComposerController {
  public EmailComposerController() {
  }

  @AuraEnabled
  public static void SendEmail(Map<String, Object> inputs) {
    System.debug('Send Email Ran');
    System.debug('emails =>');
    System.debug(inputs);

    // List<String> toAddresses = new List<String>();
    // List<String> toAddresses = ((String)inputs.get('to')).split(',');
    // System.debug('toAddresses =>');
    // System.debug(toAddresses);

    // List<String> ccAddresses = ((String)inputs.get('cc')).split(',');
    // System.debug('toAddresses =>');
    // System.debug(ccAddresses);

    // List<String> bccAddresses = ((String)inputs.get('bcc')).split(',');
    // System.debug('toAddresses =>');
    // System.debug(bccAddresses);

    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

    List<String> toAddress = new List<String>();
    List<String> bccAddress = new List<String>();
    List<String> ccAddress = new List<String>();

    List<String> fileIds = new List<String>();

    for (Object s : (List<Object>) inputs.get('to')) {
      toAddress.add((String) s);
    }

    for (Object s : (List<Object>) inputs.get('cc')) {
      ccAddress.add((String) s);
    }

    for (Object s : (List<Object>) inputs.get('bcc')) {
      bccAddress.add((String) s);
    }

    for (Object s : (List<Object>) inputs.get('fileIds')) {
      fileIds.add((String) s);

      //for(ContentDocument cd : [SELECT Id FROM ContentDocument WHERE Id IN :  ])
    }

    mail.setToAddresses(toAddress);

    if (ccAddress.size() > 0) {
      mail.setCcAddresses(ccAddress);
    }

    if (bccAddress.size() > 0) {
      mail.setbCcAddresses(bccAddress);
    }

    if (fileIds.size() > 0) {
      List<Id> fileVersions = new List<Id>();

      for (ContentDocument cd : [
        SELECT Id, latestpublishedversionid
        FROM ContentDocument
        WHERE Id IN :fileIds
      ]) {
        fileVersions.add(cd.LatestPublishedVersionId);
      }
      mail.setEntityAttachments(fileVersions);
    }

    // mail.setToAddresses((List<String>)inputs.get('to'));

    // if (((List<String>)inputs.get('cc')).size() > 0) {
    //     mail.setCcAddresses((List<String>)inputs.get('cc'));
    // }

    mail.setReplyTo((String) inputs.get('from'));
    mail.setSubject((String) inputs.get('subject'));
    mail.setHtmlBody((String) inputs.get('body'));
    // mail.setWhatId((String)inputs.recordId);
    // mail.setTemplateId(et.Id);
    // mail.setTargetObjectId();
    // mail.setWhatId();
    // mail.setSaveAsActivity();
    // Set who the email is sent from
    // mail.setSenderDisplayName();
    // mail.setFileAttachments();

    // if (((List<String>)inputs.get('fileIds')).size() > 0) {
    //     mail.setEntityAttachments((List<String>)inputs.get('fileIds'));
    // }

    mail.setWhatId((String) inputs.get('recordId'));
    mail.setUseSignature(false);

    try {
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
      System.debug('Email sent!');
    } catch (Exception e) {
      System.debug(e.getMessage());
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static List<String> GetOrgWideEmailAddresses() {
    List<OrgWideEmailAddress> emailAddresses = [
      SELECT Id, Address
      FROM OrgWideEmailAddress
    ];
    // System.debug('emailAddresses =>');
    // System.debug(emailAddresses);

    List<String> addresses = new List<String>();

    for (OrgWideEmailAddress email : emailAddresses) {
      addresses.add(email.Address);
    }

    return addresses;
  }

  @AuraEnabled
  public static String GetUserEmailAddress(String userId) {
    if (String.isBlank(userId)) {
      userId = userinfo.getUserId();
    }

    List<User> user = [SELECT Id, Name, Email FROM User WHERE Id = :userId];

    String userEmail = '';

    for (User u : user) {
      userEmail = u.Email;
    }

    return userEmail;
  }

  @AuraEnabled
  public static String renderEmailTemplate(String templateId, String whatId) {
    Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(
      templateId,
      UserInfo.getUserId(),
      whatId
    );

    return email.getHtmlBody();
  }

  @AuraEnabled
  public static String queryFiles(String filter) {
    String queryString = 'SELECT Id, Title, FileExtension, Owner.Name, LatestPublishedVersionId FROM ContentDocument Order By CreatedDate Desc';
    return JSON.serialize(Database.query(queryString));
  }

  @AuraEnabled
  public static string queryFilesOnDeal(String recordId) {
    // List<Map<String, String>> files = new List<Map<String, String>>();

    // Set<String> contentDocIds = new Set<String>();
    Map<String, String> fileMap = new Map<String, String>();
    for (Deal_Document__c dealDoc : [
      SELECT Id, Attachment_Id__c, Document_Type__c
      FROM Deal_Document__c
      WHERE Attachment_Id__c != NULL AND Deal__c = :recordId
    ]) {
      // contentDocIds.add(dealDoc.Attachment_Id__c);
      fileMap.put(dealDoc.Attachment_Id__c, dealDoc.Document_Type__c);
    }

    List<ContentDocument> files = new List<ContentDocument>();
    // String queryString = 'SELECT Id, Title, FileExtension, Owner.Name, LatestPublishedVersionId FROM ContentDocument WHERE Id IN : contentDocIds Order By CreatedDate Desc';
    for (ContentDocument file : [
      SELECT Id, Title, FileExtension, Owner.Name, LatestPublishedVersionId
      FROM ContentDocument
      WHERE Id IN :fileMap.keySet()
      ORDER BY CreatedDate DESC
    ]) {
      file.Title = fileMap.get(file.Id) + ' - ' + file.Title;
      files.add(file);
    }

    return JSON.serialize(files);
  }
}