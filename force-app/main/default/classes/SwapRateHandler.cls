global class SwapRateHandler implements Messaging.InboundEmailHandler {
  global Messaging.InboundEmailResult handleInboundEmail(
    Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope
  ) {
    string rateerror = '';
    Decimal rate_5;
    Decimal rate_7;
    Decimal rate_10;
    Decimal rate_30;
    Boolean rate_5_valid = false;
    Boolean rate_7_valid = false;
    Boolean rate_10_valid = false;
    Boolean rate_30_valid = false;

    String emailBody = email.plainTextBody.normalizeSpace().toLowerCase();

    String rate_5yr = emailBody.substringBetween('5yr:', '(').normalizeSpace();

    System.debug('rate_5yr  : ' + rate_5yr);

    if (!string.isBlank(rate_5yr)) {
      rate_5yr = rate_5yr.replace(' ', '');
      if (isNumericOrDecimal(rate_5yr)) {
        rate_5 = Decimal.ValueOf(rate_5yr);
        rate_5_valid = true;
      } else {
        rateerror = 'Invalid 5 years rate :' + rate_5yr;
      }
    } else {
      rateerror = 'Invalid 5 years rate :' + rate_5yr;
    }

    String rate_7yr = emailBody.substringBetween('7yr:', '(').normalizeSpace();
    if (!string.isBlank(rate_7yr)) {
      rate_7yr = rate_7yr.replace(' ', '');
      if (isNumericOrDecimal(rate_7yr)) {
        rate_7 = Decimal.ValueOf(rate_7yr);
        rate_7_valid = true;
      } else {
        rateerror = rateerror + '\n' + 'Invalid 7 years rate :' + rate_7yr;
      }
    } else {
      rateerror = rateerror + '\n' + 'Invalid 7 years rate :' + rate_7yr;
    }

    String rate_10yr = emailBody.substringBetween('10yr:', '(')
      .normalizeSpace();
    if (!string.isBlank(rate_10yr)) {
      rate_10yr = rate_10yr.replace(' ', '');
      if (isNumericOrDecimal(rate_10yr)) {
        rate_10 = Decimal.ValueOf(rate_10yr);
        rate_10_valid = true;
      } else {
        rateerror = rateerror + '\n' + 'Invalid 10 years rate :' + rate_10yr;
      }
    } else {
      rateerror = rateerror + '\n' + 'Invalid 10 years rate :' + rate_10yr;
    }

    String rate_30yr = emailBody.substringBetween('30yr:', '(')
      .normalizeSpace();
    if (!string.isBlank(rate_30yr)) {
      rate_30yr = rate_30yr.replace(' ', '');
      if (isNumericOrDecimal(rate_30yr)) {
        rate_30 = Decimal.ValueOf(rate_30yr);
        rate_30_valid = true;
      } else {
        rateerror = rateerror + '\n' + 'Invalid 30 years rate :' + rate_30yr;
      }
    } else {
      rateerror = rateerror + '\n' + 'Invalid 30 years rate :' + rate_30yr;
    }

    Swap_Rate__c S = new Swap_Rate__c();
    if (rate_5_valid)
      S.Five_Year_Swap__c = rate_5;
    else
      S.Five_Year_Swap__c = null;
    if (rate_7_valid)
      S.Seven_Year_Swap__c = rate_7;
    else
      S.Seven_Year_Swap__c = null;
    if (rate_10_valid)
      S.Ten_Year_Swap__c = rate_10;
    else
      S.Ten_Year_Swap__c = null;
    if (rate_30_valid)
      S.Thirty_Year_Swap__c = rate_30;
    else
      S.Thirty_Year_Swap__c = null;

    S.CreatedDateTime__c = DateTime.now();
    try {
      insert S;
    } catch (DmlException e) {
      System.debug('Error Inserting Swap Rates' + e.getMessage());
    }

    if (rate_5_valid && rate_7_valid && rate_10_valid && rate_30_valid) {
    } else {
      System.debug(' rateerror : ' + rateerror);
      sendEmailMessage(email, rateerror);
    }

    dealSwapRateUpdate updateDeal = new dealSwapRateUpdate();
    Id batchId = Database.executeBatch(updateDeal, 25);

    return new Messaging.InboundEmailResult();
  } //method

  public Boolean isNumericOrDecimal(String s) {
    if (s == null)
      return false;
    else if (s.contains('.') && s.indexOf('.') == s.lastIndexOf('.'))
      s = s.replace('.', '');
    return s.isNumeric();
  }

  public static void sendEmailMessage(
    Messaging.InboundEmail email,
    String rateerror
  ) {
    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    List<String> ccAddresses = email.ccAddresses != null
      ? email.ccAddresses
      : new List<String>();
    List<String> toAddresses = email.toAddresses != null
      ? email.toAddresses
      : new List<String>();
    OrgWideEmailAddress[] owea = [
      SELECT Id
      FROM OrgWideEmailAddress
      WHERE DisplayName = 'Integrations User'
    ];
    message.OrgWideEmailAddressId = owea[0].id;
    message.ToAddresses = new List<String>{
      email.fromAddress,
      'support@cvest.com'
    };
    message.CcAddresses = ccAddresses;
    message.subject =
      'Errors found in the Swap Rate Email from ' + date.today();
    message.plainTextBody = 'Following errors were found in the Swap Rate Email. \n \n';
    message.plainTextBody = message.plainTextBody + rateerror;
    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{
      message
    };
    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

    if (results[0].success) {
      System.debug('The email was sent successfully.');
    } else {
      System.debug('The email failed to send: ' + results[0].errors[0].message);
    }
  }
}