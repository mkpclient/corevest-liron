global class AdvanceBatchApprovalEmailHandler implements Messaging.InboundEmailHandler {
  static final String HANDLERADDRESS = retrieveEmailServiceAddress();
  //Advance_Batch_Approvers

  Map<Id, User> USERINFO_MAP = queryUserInfo('Advance_Batch_Approvers');

  public static final Set<String> EMAIL_ADDRESSES = queryEmailAddresses(
    'Advance_Batch_Approvers'
  );

  global Messaging.InboundEmailResult handleInboundEmail(
    Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope
  ) {
    Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
    String batchName = email.subject.substringBetween('#', ' ');
    String fromAddress = email.fromAddress;

    Set<String> alreadySentTo = new Set<String>();
    Set<String> setEmails = new Set<String>();
    Set<String> approverEmails = new Set<String>();

    if (null != email.toAddresses && email.toAddresses.size() > 0) {
      for (String e : email.toAddresses) {
        alreadySentTo.add(e);
      }
    }

    String htmlBody = '';
    String originalBody = '';

    if (String.isEmpty(email.htmlBody)) {
      htmlBody = email.plainTextBody;
      originalBody = email.plainTextBody;
    } else {
      htmlBody = email.htmlBody;
      originalBody = email.htmlBody;
    }

    htmlBody = htmlBody.replace('<wbr>', '');

    Set<String> alreadyCcs = new Set<String>();
    Set<String> setCcs = new Set<String>();

    if (null != email.ccAddresses && email.ccAddresses.size() > 0) {
      for (String c : email.ccAddresses) {
        alreadyCcs.add(c);
      }
    }

    if (
      !alreadySentTo.equals(EMAIL_ADDRESSES) &&
      !alreadyCcs.equals(EMAIL_ADDRESSES)
    ) {
      setCcs.addAll(EMAIL_ADDRESSES);
    }

    List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

    Integer characterLim = 6 + email.Subject.length() <= 80
      ? email.Subject.length()
      : 80 - 6;
    Integer contentLim = originalBody.length() <= 131072
      ? originalBody.length()
      : 131072;

    List<String> recips = new List<String>();
    List<String> ccs = new List<String>();

    recips.addAll(alreadySentTo);
    ccs.addAll(alreadyCcs);

    List<Batch_Approval__c> batchApproval = [
      SELECT Id, OwnerId, Owner.Email
      FROM Batch_Approval__c
      WHERE Name = :batchName
    ];

    if (batchApproval.size() > 0) {
      String alternateAddress = '';
      if (fromAddress.contains('@cvest.com')) {
        alternateAddress = fromAddress.replace(
          '@cvest.com',
          '@colonyamericanfinance.com'
        );
      }

      for (Id key : USERINFO_MAP.keySet()) {
        approverEmails.add(USERINFO_MAP.get(key).Email);
      }

      Batch_Approver__c batchApprover = [
        SELECT
          Id,
          Status__c,
          Comments__c,
          Approver__c,
          Approver__r.Name,
          Approver__r.Email,
          Batch_Approval__c
        FROM Batch_Approver__c
        WHERE
          Batch_Approval__r.Name = :batchName
          AND (Approver__r.Email = :fromAddress
          OR Approver__r.Email = :alternateAddress)
      ];

      if (
        (fromAddress == batchApproval[0].Owner.Email ||
        alternateAddress == batchApproval[0].Owner.Email) &&
        batchApprover == null
      ) {
        System.debug('Received email from submitter who is not an approver.');

        List<String> emailAddressesList = new List<String>();
        List<String> ccAddressesList = new List<String>();

        for (String email1 : approverEmails) {
          if (!alreadySentTo.contains(email1) && !alreadyCcs.contains(email1)) {
            setEmails.add(email1);
          }
        }

        if (setEmails.size() > 0) {
          emailAddressesList.addAll(setEmails);
        }
        if (setCcs.size() > 0) {
          ccAddressesList.addAll(setCcs);
        }

        if (emailAddressesList.size() > 0 && ccAddressesList.size() > 0) {
          sendEmail(
            email,
            batchApproval[0],
            emailAddressesList,
            ccAddressesList
          );
        } else if (emailAddressesList.size() > 0) {
          sendEmail(email, batchApproval[0], emailAddressesList, null);
        } else if (ccAddressesList.size() > 0) {
          sendEmail(email, batchApproval[0], ccAddressesList, null);
        }

        List<String> listEmails = new List<String>();
        if (alreadySentTo.size() > 0) {
          listEmails.addAll(alreadySentTo);
        }
        if (setEmails.size() > 0) {
          listEmails.addAll(setEmails);
        }

        List<String> listCcs = new List<String>();
        if (alreadyCcs.size() > 0) {
          listEmails.addAll(alreadyCcs);
        }
        if (setCcs.size() > 0) {
          listCcs.addAll(setCcs);
        }

        createEmailHistory(
          email,
          batchApproval[0],
          listEmails,
          listCcs,
          new List<Id>(USERINFO_MAP.keySet()),
          batchApproval[0].OwnerId,
          false
        );
      } else {
        System.debug(
          'Received email from an approver or someone else not submitter.'
        );
        Boolean approved = false;
        if (
          !alreadySentTo.contains(batchApproval[0].Owner.Email) &&
          !alreadyCcs.contains(batchApproval[0].Owner.Email)
        ) {
          setEmails.add(batchApproval[0].Owner.Email);
        }

        Id toId;

        if (batchApprover != null) {
          User fromUser = new User();
          for (Id key : USERINFO_MAP.keySet()) {
            if (
              (USERINFO_MAP.get(key).Email.toLowerCase() == fromAddress ||
              USERINFO_MAP.get(key).Email.toLowerCase() == alternateAddress) &&
              htmlBody.toLowerCase()
                .contains(USERINFO_MAP.get(key).Approver_Code__c.toLowerCase())
            ) {
              toId = key;
              fromUser = USERINFO_MAP.get(key);
              break;
            }
          }
          System.debug('FROM USER :: ');
          System.debug(fromUser);

          if (null != fromUser.Approver_Code__c) {
            String rejectCode = fromUser.Approver_Code__c.replace(
              'Approve',
              'Reject'
            );
            Boolean isApprover =
              htmlBody.toLowerCase()
                .contains(fromUser.Approver_Code__c.toLowerCase()) ||
              htmlBody.toLowerCase().contains(rejectCode.toLowerCase());

            Boolean isApproved = htmlBody.toLowerCase()
              .contains(fromUser.Approver_Code__c.toLowerCase());

            if (isApprover) {
              approved = approveRejectBatch(
                fromUser.Id,
                batchApprover,
                isApproved
              );
            }
          }

          List<String> emailAddressesList = new List<String>();
          List<String> ccAddressesList = new List<String>();
          if (setEmails.size() > 0) {
            emailAddressesList.addAll(setEmails);
          }
          if (setCcs.size() > 0) {
            ccAddressesList.addAll(setCcs);
          }

          if (emailAddressesList.size() > 0 && ccAddressesList.size() > 0) {
            sendEmail(
              email,
              batchApproval[0],
              emailAddressesList,
              ccAddressesList
            );
            System.debug(
              'these are the people getting cced on the handler email'
            );
            System.debug(ccAddressesList);
            System.debug('these are the people getting sent the handler email');
            System.debug(emailAddressesList);
          } else if (emailAddressesList.size() > 0) {
            sendEmail(email, batchApproval[0], emailAddressesList, null);
            System.debug('these are the people getting sent the handler email');
            System.debug(emailAddressesList);
          } else if (ccAddressesList.size() > 0) {
            sendEmail(email, batchApproval[0], ccAddressesList, null);
            System.debug(
              'these are people who should be CCed getting sent the handler email b/c only new CCs appeared'
            );
            System.debug(emailAddressesList);
          }

          List<String> listEmails = new List<String>();
          if (alreadySentTo.size() > 0) {
            listEmails.addAll(alreadySentTo);
          }
          if (setEmails.size() > 0) {
            listEmails.addAll(setEmails);
          }

          List<String> listCcs = new List<String>();
          if (alreadyCcs.size() > 0) {
            listEmails.addAll(alreadyCcs);
          }
          if (setCcs.size() > 0) {
            listCcs.addAll(setCcs);
          }
          createEmailHistory(
            email,
            batchApproval[0],
            listEmails,
            listCcs,
            new List<Id>{ batchApproval[0].OwnerId },
            toId,
            approved
          );
        }
      }
    } else {
      result.success = false;
      result.message =
        'Error sending the email. No existing Approval Batch #' +
        batchName +
        ' found.';
    }
    return result;
  }

  public static void sendEmail(
    Messaging.InboundEmail em,
    Batch_Approval__c ba,
    List<String> recipients,
    List<String> ccUsers
  ) {
    System.debug('inside sendEmail');
    Messaging.InboundEmail.BinaryAttachment[] binaryList = em.binaryattachments;
    Messaging.InboundEmail.TextAttachment[] textList = em.textAttachments;

    String subject = em.Subject;
    String htmlBody = em.htmlBody.replace('<img src="">', '')
      .replace('<img s', '<img width="500" s');

    if (
      em.htmlBody.indexOf(
        'CoreVest American Finance Lender LLC. All Rights Reserved.'
      ) != -1
    ) {
      String oneFooter = em.htmlBody.substring(
        0,
        em.htmlBody.indexOf(
          'CoreVest American Finance Lender LLC. All Rights Reserved.'
        )
      );
      htmlBody = oneFooter;
    }
    String fromAddress = em.fromAddress;

    System.debug('ccUsers inside sendEmail: ');
    System.debug(ccUsers);
    Messaging.SingleEmailMessage sem = new Messaging.SingleEmailMessage();
    sem.setCcAddresses(ccUsers);
    sem.setSubject(subject);
    sem.setReplyTo(handlerAddress);
    sem.setToAddresses(recipients);
    sem.setSenderDisplayName(fromAddress);
    sem.setHtmlBody(htmlBody);

    List<Messaging.EmailFileAttachment> attachmentsList = new List<Messaging.EmailFileAttachment>();
    if (null != textList && textList.size() > 0) {
      for (Messaging.InboundEmail.TextAttachment t : textList) {
        attachmentsList.add(constructFileAttachment(t));
      }
      sem.setFileAttachments(attachmentsList);
    }
    if (null != binaryList && binaryList.size() > 0) {
      for (Messaging.InboundEmail.BinaryAttachment b : binaryList) {
        attachmentsList.add(constructFileAttachment(b));
      }
      sem.setFileAttachments(attachmentsList);
    }

    try {
      Messaging.SendEmailResult[] results = Messaging.sendEmail(
        new List<Messaging.SingleEmailMessage>{ sem }
      );
    } catch (Exception e) {
      System.debug(
        'error sending email' +
        e.getMessage() +
        ' ' +
        e.getLineNumber()
      );
      String errorMessage = '';
      errorMessage += JSON.serialize(recipients);
      errorMessage += '<br/>' + ccUsers == null
        ? 'null'
        : JSON.serialize(ccUsers);
      errorMessage += '<br/>' + JSON.serialize(fromAddress);
      Messaging.SingleEmailMessage em1 = new Messaging.SingleEmailMessage();
      em1.setSubject('mail error');
      em1.setToAddresses(new List<String>{ 'ldecastro@mkpartners.com' });
      em1.setHtmlBody('<html><body>' + errorMessage + '</html></body>');
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ em1 });
    }
  }

  public static Map<Id, User> queryUserInfo(String name) {
    List<Id> userIds = new List<Id>();
    Group gp = [
      SELECT DeveloperName, (SELECT UserOrGroupId FROM GroupMembers)
      FROM Group
      WHERE DeveloperName = :name
    ];

    for (GroupMember gm : gp.GroupMembers) {
      userIds.add(gm.UserOrGroupId);
    }

    if (Test.isRunningTest()) {
      userIds.add(UserInfo.getUserId());
    }

    Map<Id, User> userMap = new Map<Id, User>(
      [
        SELECT Id, Email, Approver_Code__c, Department, Name
        FROM User
        WHERE Id IN :userIds
      ]
    );

    List<String> names = new List<String>();
    if (userMap.size() > 0) {
      for (Id key : userMap.keySet()) {
        String name2 = userMap.get(key).Name;
        names.add(name2);
      }
    }

    if (names.size() > 0 && userMap.size() > 0) {
      Map<String, Email_Addresses__c> settings = querySettings(names);

      if (settings.size() > 0) {
        for (Id key : userMap.keySet()) {
          User userInfo = userMap.get(key);
          String name3 = userInfo.Name;
          if (String.isNotEmpty(settings.get(name3).Email_Address__c)) {
            userInfo.Email = settings.get(name3).Email_Address__c;
          }
          if (String.isNotEmpty(settings.get(name3).Approver_Code__c)) {
            userInfo.Approver_Code__c = settings.get(name3)
              .Approver_Code__c.toLowerCase();
          }
          userMap.put(key, userInfo);
        }
      }

      return userMap;
    } else {
      return new Map<Id, User>();
    }
  }

  public static Set<String> queryEmailAddresses(String name) {
    Set<String> emailAdds = new Set<String>();
    Set<Id> userIds = new Set<Id>();
    Group gp = [
      SELECT (SELECT UserOrGroupId FROM GroupMembers)
      FROM Group
      WHERE DeveloperName = :name
    ];
    for (GroupMember gm : gp.GroupMembers) {
      userIds.add(gm.UserOrGroupId);
    }
    List<User> userList = [SELECT Email FROM User WHERE Id IN :userIds];
    for (User u : userList) {
      emailAdds.add(u.Email);
    }
    return emailAdds;
  }

  public static Map<String, Email_Addresses__c> querySettings(
    List<String> names
  ) {
    Map<String, Email_Addresses__c> allSettings = new Map<String, Email_Addresses__c>();
    for (String name : names) {
      Email_Addresses__c setting = Email_Addresses__c.getInstance(name);
      if (setting == null || setting.id == null) {
        setting = new Email_Addresses__c(
          Name = name,
          Email_Address__c = '',
          Approver_Code__c = ''
        );
        if (Test.isRunningTest()) {
          setting.Email_Address__c = UserInfo.getUserEmail();
          setting.Approver_Code__c = 'test';
          allSettings.put(name, setting);
        }
      }

      allSettings.put(name, setting);
    }
    System.debug(alLSettings);
    return allSettings;
  }

  public static String retrieveEmailServiceAddress() {
    EmailServicesFunction emailFunction = [
      SELECT Id
      FROM EmailServicesFunction
      WHERE FunctionName = 'BatchApprovalHandler'
    ];

    EmailServicesAddress emailServicesAddress = [
      SELECT Id, LocalPart, EmailDomainName
      FROM EmailServicesAddress
      WHERE FunctionId = :emailFunction.Id
    ];

    return (emailServicesAddress.LocalPart +
    '@' +
    emailServicesAddress.EmailDomainName);
  }

  public static Messaging.EmailFileAttachment constructFileAttachment(
    Messaging.InboundEmail.TextAttachment t
  ) {
    Messaging.EmailFileAttachment a = new Messaging.EmailFileAttachment();
    a.setFileName(t.fileName);
    a.setContentType(t.mimeTypeSubType);
    a.setBody(Blob.valueOf(t.body));
    return a;
  }

  public static Messaging.EmailFileAttachment constructFileAttachment(
    Messaging.InboundEmail.BinaryAttachment b
  ) {
    Messaging.EmailFileAttachment a = new Messaging.EmailFileAttachment();
    a.setFileName(b.fileName);
    a.setContentType(b.mimeTypeSubType);
    a.setBody(b.body);
    return a;
  }

  public static void createEmailHistory(
    Messaging.InboundEmail em,
    Batch_Approval__c ba,
    List<String> recipients,
    List<String> ccEmails,
    List<Id> recipientIds,
    Id uId,
    Boolean approved
  ) {
    System.debug('createEmailHistory start');
    String cvIds = '';
    String htmlBody = ''; //em.htmlBody;
    String originalBody = '';

    if (String.isNotBlank(em.htmlBody)) {
      htmlBody = em.htmlBody;
      originalBody = em.htmlBody;
    } else {
      htmlBody = em.plainTextBody;
      originalBody = em.plainTextBody;
    }

    if (htmlBody.contains('<wbr>')) {
      htmlBody = htmlBody.replace('<wbr>', '');
    }

    System.Savepoint sp = Database.setSavepoint();

    List<Id> ccEmailIds = new List<Id>();
    List<Id> recipientEmailIds = new List<Id>();
    Set<String> recipientEmailSet = new Set<String>();
    if (null != recipients && recipients.size() > 0) {
      recipientEmailSet.addAll(recipients);
    }
    Set<String> ccEmailSet = new Set<String>();
    if (null != ccEmails && ccEmails.size() > 0) {
      ccEmailSet.addAll(ccEmails);
    }

    List<User> uList = new List<User>();
    try {
      uList = [
        SELECT Id, Email
        FROM User
        WHERE Email IN :ccEmails OR Email IN :recipients
      ];
    } catch (Exception ex) {
      System.debug('error in looking for users');
      System.debug(ex.getMessage());
      sendExceptionEmails(ex);
    }
    if (uList.size() > 0) {
      for (User u : uList) {
        if (recipientEmailSet.contains(u.Email)) {
          recipientEmailIds.add(u.Id);
        } else if (ccEmailSet.contains(u.Email)) {
          ccEmailIds.add(u.Id);
        }
      }
    }

    String recipientStr = '';
    System.debug('these are the recipients');
    System.debug(recipients);
    if (null != recipients && recipients.size() > 0) {
      recipientStr = String.join(recipients, '; ');
    }
    String newToIds = '';
    if (null != recipientIds && recipientIds.size() > 0) {
      newToIds = String.join(recipientIds, '; ');
    }
    System.debug('this is newToIds');
    System.debug(newToIds);
    String ccStr = '';
    if (null != ccEmails && ccEmails.size() > 0) {
      for (String cc : ccEmails) {
        ccStr += cc + '; ';
      }
    }
    ccStr.substringBeforeLast(';');

    System.debug('this is the string value of recipients');
    System.debug(String.valueOf(recipients));

    System.debug('these are the headers');
    System.debug(em.headers);
    DateTime emailDate;
    if (em.headers != null) {
      for (Messaging.InboundEmail.Header ieh : em.headers) {
        if (ieh.name == 'Date') {
          System.debug('check the date');
          System.debug(ieh.value);
          emailDate = system.now();
        }
      }
    }
    List<EmailMessage> emailMessages = new List<EmailMessage>();

    EmailMessage emm = new EmailMessage(
      FromAddress = em.fromAddress,
      FromName = em.fromName,
      MessageDate = emailDate,
      Subject = em.Subject,
      HtmlBody = em.htmlBody,
      TextBody = em.plainTextBody,
      ToAddress = recipientStr,
      RelatedToId = ba.Id,
      Status = '3'
    );
    if (null != ccStr && ccStr.length() > 0) {
      emm.CcAddress = ccStr;
    }
    if (null != ccEmails && ccEmailIds.size() > 0) {
      emm.CcIds = ccEmailIds;
    }

    emailMessages.add(emm);

    List<Advance__c> relatedAdvances = [
      SELECT Id
      FROM Advance__c
      WHERE Batch_Approval__c = :ba.Id
    ];

    for (Advance__c adv : relatedAdvances) {
      EmailMessage advEmm = new EmailMessage(
        FromAddress = em.fromAddress,
        FromName = em.fromName,
        MessageDate = emailDate,
        Subject = em.Subject,
        HtmlBody = em.htmlBody,
        TextBody = em.plainTextBody,
        ToAddress = recipientStr,
        RelatedToId = adv.Id,
        Status = '3'
      );
      if (null != ccStr && ccStr.length() > 0) {
        advEmm.CcAddress = ccStr;
      }
      if (null != ccEmails && ccEmailIds.size() > 0) {
        advEmm.CcIds = ccEmailIds;
      }

      emailMessages.add(advEmm);
    }

    try {
      Database.executeBatch(new UpsertBatch(emailMessages), 100);
    } catch (Exception ex) {
      System.debug('insert emailMessage exception');
      System.debug(ex.getLineNumber());
      System.debug(ex.getStackTraceString());
      System.debug(ex.getTypeName());
      System.debug(ex.getMessage());
      Database.rollback(sp);
      sendExceptionEmails(ex);
    }

    List<EmailMessageRelation> emrInserts = new List<EmailMessageRelation>();
    Id recipientId;
    if (recipientIds.size() > 0) {
      recipientId = recipientIds[0];
    }

    for (EmailMessage em1 : emailMessages) {
      emrInserts.add(
        constructEmailMessageRelation(
          em1.Id,
          recipients[0],
          recipientId,
          'ToAddress'
        )
      );

      emrInserts.add(
        constructEmailMessageRelation(
          em1.Id,
          em.FromAddress,
          uId,
          'FromAddress'
        )
      );
    }

    try {
      Database.executeBatch(new UpsertBatch(emrInserts), 100);
    } catch (Exception ex) {
      System.debug('insert emailMessageRelation exception');
      System.debug(ex.getLineNumber());
      System.debug(ex.getStackTraceString());
      System.debug(ex.getTypeName());
      System.debug(ex.getMessage());

      Database.rollback(sp);
      sendExceptionEmails(ex);
    }
  }

  public static void sendExceptionEmails(Exception ex) {
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

    email.setToAddresses(
      new List<String>{ 'ldecastro@mkpartners.com', 'bryon@cvest.com' }
    );

    String body = '';
    body += 'Line Number: ' + ex.getLineNumber();
    body += '\nStacktrace: ' + ex.getStackTraceString();
    body += '\nType: ' + ex.getTypeName();
    body += '\nMessage:  ' + ex.getMessage();
    email.setPlainTextbody(body);
    email.setSubject('Advance Batch Approval Handler Error');

    Messaging.sendEmail(new List<Messaging.SIngleEmailMessage>{ email });
  }

  public static EmailMessageRelation constructEmailMessageRelation(
    Id messageId,
    String relAddress,
    Id relId,
    String type
  ) {
    EmailMessageRelation emr = new EmailMessageRelation();
    emr.EmailMessageId = messageId;
    emr.RelationAddress = relAddress;
    emr.RelationId = relId;
    emr.RelationType = type;
    return emr;
  }

  public static Boolean approveRejectBatch(
    Id userId,
    Batch_Approver__c ba,
    Boolean approved
  ) {
    ba.Status__c = approved ? 'Approved' : 'Rejected';
    ba.Comments__c =
      ba.Status__c +
      ' from Email by ' +
      ba.Approver__r.Name +
      '\nApproval Comment: ' +
      ba.Comments__c;

    insert ba;

    List<Batch_Approver__c> unapprovedBas = [
      SELECT Id
      FROM Batch_Approver__c
      WHERE
        Batch_Approval__c = :ba.Batch_Approval__c
        AND Status__c != 'Approved'
    ];

    return unapprovedBas.size() == 0;
  }
}
