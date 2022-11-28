global class DrawAdvanceProcessHandler implements Messaging.InboundEmailHandler {
  public static final Id bridgeCustodinUserId = Settings__mdt.getInstance(
      'Universal_Settings'
    )
    .Bridge_Cptl_Market_Post_Closing_Custodin__c;
  public static final Id termCustodinUserId = Settings__mdt.getInstance(
      'Universal_Settings'
    )
    .Term_Captl_Markets_Post_Closing_Custodin__c;

  //string returnemails		= settings.Capital_Markets_Post_Closing_return_emai__c;
  Boolean errorsFound = false;
  String errorString = '';

  global Messaging.InboundEmailResult handleInboundEmail(
    Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope
  ) {
    String emailsubject = email.subject.normalizeSpace().toLowerCase();
    if (
      String.isNotBlank(emailsubject) &&
      (emailsubject.startsWithIgnoreCase('re:') ||
      emailsubject.startsWithIgnoreCase('fw:'))
    ) {
      // errorsFound = true;
      // errorString = 'Replied or Forwarded email cannot be processed';
    } else {
      String emailBody = email.plainTextBody.normalizeSpace().toLowerCase();
      Messaging.InboundEmail.TextAttachment[] tAttachments = email.textAttachments;
      Messaging.InboundEmail.BinaryAttachment[] bAttachments = email.BinaryAttachments;

      String csvbody = '';
      if (bAttachments != null) {
        System.debug('battachments not null');
        Boolean allAttachedFilesAreValidCsvs = true;
        for (Messaging.InboundEmail.BinaryAttachment btt : bAttachments) {
          if (!btt.filename.endsWithIgnoreCase('.csv')) {
            allAttachedFilesAreValidCsvs = false;
            errorsFound = true;
            errorString = 'Only CSV files name starting with bridge or term will be processed';
          } else {
            allAttachedFilesAreValidCsvs = true;
            errorsFound = false;
            errorString = '';
            break;
          }
        }

        if (allAttachedFilesAreValidCsvs) {
          List<DrawAdvance> drawAdvances = new List<DrawAdvance>();
          System.debug('all files valid csv');
          for (Messaging.InboundEmail.BinaryAttachment btt : bAttachments) {
            /////////////////////////Process Bridge file

            if (
              btt.filename.startsWithIgnoreCase('bridge') &&
              btt.filename.endsWithIgnoreCase('.csv')
            ) {
              DrawAdvance bridgeDA = new DrawAdvance();
              bridgeDA.fileHeaderLine = new List<String>();
              bridgeDA.subjectLine1 = btt.filename.toUpperCase()
                .substringBetween('BRIDGE', 'ASSETS')
                ?.normalizeSpace();

              bridgeDA.subjectLine2 =
                'DRAW ' +
                btt.filename.toUpperCase()
                  .substringBetween('DRAW', '.CSV')
                  ?.normalizeSpace();

              csvbody = btt.body.toString();
              bridgeDA.fileLines = csvbody.split('\r\n');
              bridgeDA.recType = 'bridge';
              drawAdvances.add(bridgeDA);

              /* 
              Boolean validHeaderLineFound = false;
              Boolean validBridgeLineFound = false;
              String errorStringfile = '\n Bridge File :';
              List<String> fileHeaderLine;
              for (integer i = 1; i < fileLineList.size(); i++) {
                String reformatedLine = ReformatLine(fileLineList[i]);
                List<String> fileLineFields = reformatedLine.split(',');

                if (fileLineFields.size() >= 10 && validHeaderLineFound) {
                  if (fileLineFields[10] == 'Y') {
                    id validAdvanceId = null;
                    if (fileLineFields[8] != null) {
                      validBridgeLineFound = true;
                      Custodial_File_Sent_to_Custodian = false;
                      validAdvanceId = ValidateAdvance(
                        fileLineFields[0],
                        fileLineFields[8]
                      ); //Validate Advance and deal id(loan idamazon)
                    }
                    if (
                      validAdvanceId != null &&
                      Custodial_File_Sent_to_Custodian == false
                    ) {
                      String description = '';
                      integer noOfColumns;

                      if (fileHeaderLine.size() < fileLineFields.size()) {
                        noOfColumns = fileHeaderLine.size();
                      } else {
                        noOfColumns = fileLineFields.size();
                      }

                      for (integer j = 0; j < noOfColumns; j++) {
                        description =
                          fileHeaderLine[j] +
                          ' : ' +
                          fileLineFields[j] +
                          ';\n' +
                          description;
                      }
                      CreateTask(
                        'B',
                        fileLineFields[0],
                        fileLineFields[8],
                        bridgeCustodinUserId,
                        validAdvanceId,
                        description
                      ); //Create a task if valid asset;
                    } else {
                      if (Custodial_File_Sent_to_Custodian == false) {
                        errorsFound = true;
                        errorString =
                          'Invalid Deal/Advance Id = ' +
                          fileLineFields[0] +
                          ' : ' +
                          fileLineFields[8] +
                          '; ' +
                          errorString;
                      }
                    }
                  } //if (fileLineFields[10] == 'Y')
                } //if (fileLineFields.size() >= 10 && validHeaderLineFound)

                if (
                  fileLineFields.size() >= 10 &&
                  validHeaderLineFound == false
                ) {
                  if (
                    fileLineFields[0] == 'Loan ID' &&
                    fileLineFields[8] == 'Advance #'
                  ) {
                    validHeaderLineFound = true;
                    fileHeaderLine = fileLineFields;
                  }
                }
              } //Lines loop - For

              if (validBridgeLineFound == false) {
                errorsFound = true;
                errorString = 'No Valid Line found in Bridge File';
              }
              if (errorsFound)
                errorString = errorStringfile + errorString;
                */
            } // Bridge Attachement - if

            /////////////////////////Process Term file
            if (
              btt.filename.startsWithIgnoreCase('term') &&
              btt.filename.endsWithIgnoreCase('.csv')
            ) {
              DrawAdvance termDA = new DrawAdvance();
              termDA.fileHeaderLine = new List<String>();
              termDA.subjectLine1 = btt.filename.toupperCase()
                .substringBetween('TERM', 'CUSTODIAN')
                ?.normalizeSpace();
              termDA.subjectLine2 =
                'DRAW ' +
                btt.filename.toUpperCase()
                  .substringBetween('DRAW', '.CSV')
                  ?.normalizeSpace();

              csvbody = btt.body.toString();
              termDA.fileLines = csvbody.split('\r\n');
              termDA.recType = 'term';
              drawAdvances.add(termDA);

              // Boolean validHeaderLineFound = false;
              // Boolean validTermLineFound = false;
              // String errorStringfile = 'Term File : ';
              // List<String> fileHeaderLine;
              // for (integer i = 1; i < fileLineList.size(); i++) {
              //   String reformatedLine = ReformatLine(fileLineList[i]);
              //   List<String> fileLineFields = reformatedLine.split(',');
              //   if (fileLineFields.size() >= 0 && validHeaderLineFound) {
              //     id validDealId = null;
              //     if (fileLineFields[0] != null) {
              //       validTermLineFound = true;
              //       validDealId = ValidateLoanID(fileLineFields[0]); //Validate loan id
              //     }
              //     if (validDealId != null) {
              //       String description = '';
              //       integer noOfColumns;

              //       if (fileHeaderLine.size() < fileLineFields.size()) {
              //         noOfColumns = fileHeaderLine.size();
              //       } else {
              //         noOfColumns = fileLineFields.size();
              //       }

              //       for (integer j = 0; j < noOfColumns; j++) {
              //         description =
              //           fileHeaderLine[j] +
              //           ' : ' +
              //           fileLineFields[j] +
              //           ';\n' +
              //           description;
              //         //description = fileLineFields[j] + ';' + description;
              //       }
              //       CreateTask(
              //         'T',
              //         fileLineFields[0],
              //         '',
              //         termCustodinUserId,
              //         validDealId,
              //         description
              //       ); //Create a task if valid asset;
              //     } else {
              //       errorsFound = true;
              //       errorString =
              //         'Invalid Loan Id = ' +
              //         fileLineFields[0] +
              //         '; ' +
              //         errorString;
              //     }
              //   }

              //   if (
              //     fileLineFields.size() >= 2 &&
              //     validHeaderLineFound == false
              //   ) {
              //     if (fileLineFields[0] == 'Loan_ID') {
              //       validHeaderLineFound = true;
              //       fileHeaderLine = fileLineFields;
              //     }
              //   }
              // } //Lines loop - For

              // if (validTermLineFound == false) {
              //   errorsFound = true;
              //   errorString = 'No Valid Line found in Bridge File';
              // }
              // if (errorsFound)
              //   errorString = errorStringfile + errorString;
            } // Term Attachement - if
          }
          Set<String> advanceNums = new Set<String>();
          Set<String> loanIds = new Set<String>();

          if (drawAdvances.size() > 0) {
            for (DrawAdvance da : drawAdvances) {
              da.validFieldLines = new List<List<String>>();
              for (Integer i = 1; i < da.fileLines.size(); i++) {
                List<String> fileLineFields = reformatLine(da.fileLines[i])
                  .split(',');
                if (
                 ((fileLineFields.size() >= 10 &&
                  da.recType == 'bridge') ||
                  (fileLineFields.size() >= 0 &&
                  da.recType == 'term'))
                  && da.fileHeaderLine.size() > 0
                ) {
                  if (fileLineFields[10] == 'Y' || da.recType == 'term') {
                    da.validFieldLines.add(fileLineFields);
                    if (fileLineFields[8] != null && da.recType == 'bridge') {
                      advanceNums.add(fileLineFields[8]);
                      da.advanceNum = fileLineFields[8];
                    }

                    if (fileLineFields[0] != null) {
                      loanIds.add(fileLineFields[0]);
                      da.loanId = fileLineFields[0];
                    }
                  }
                } else if (
                  da.fileHeaderLine.size() == 0 &&
                  fileLineFields[0] == 'Loan ID' &&
                  ((fileLineFields.size() >= 10 &&
                  fileLineFields[8] == 'Advance #' &&
                  da.recType == 'bridge') ||
                  (fileLineFields.size() >= 2 &&
                  da.recType == 'term'))
                ) {
                  da.fileHeaderLine = fileLineFields;
                }
              }
            }
            // dev notes: use "valid field lines for re-parsing after validation of advance and deal
            Map<String, Opportunity> validatedDealsMap = new Map<String, Opportunity>();
            Map<String, Map<String, Advance__c>> validatedAdvancesMap = new Map<String, Map<String, Advance__c>>();
            // deal loan number => { advanceNum => advance record }
            if (loanIds.size() > 0 && advanceNums.size() == 0) {
              for (Opportunity o : [
                SELECT Id, Deal_Loan_Number__c
                FROM Opportunity
                WHERE Deal_Loan_Number__c IN :loanIds
              ]) {
                validatedDealsMap.put(o.Deal_Loan_Number__c, o);
              }
            } else if (loanIds.size() > 0 && advanceNums.size() > 0) {
              for (Opportunity o : [
                SELECT
                  Id,
                  Deal_Loan_Number__c,
                  (
                    SELECT
                      Id,
                      Name,
                      Deal__r.Deal_Loan_Number__c,
                      Custodial_File_Sent_to_Custodian__c
                    FROM Advances__r
                    WHERE
                      Name IN :advanceNums
                      AND Custodial_File_Sent_to_Custodian__c = NULL
                  )
                FROM Opportunity
                WHERE Deal_Loan_Number__c IN :loanIds
              ]) {
                Map<String, Advance__c> advancesMap = new Map<String, Advance__c>();
                if (o?.Advances__r != null && o.Advances__r.size() > 0) {
                  for (Advance__c a : o.Advances__r) {
                    advancesMap.put(a.Name, a);
                  }
                }
                validatedAdvancesMap.put(o.Deal_Loan_Number__c, advancesMap);
              }
            }
            Id taskRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
              .get('Draw_Request')
              .getRecordTypeId();

            Map<Id, Task> taskMap = new Map<Id, Task>();

            for (DrawAdvance da : drawAdvances) {
              if (da.validFieldLines.size() > 0) {
                if (
                  (da.recType == 'term' &&
                  !validatedDealsMap.containsKey(da.loanId)) ||
                  da.recType == 'bridge' &&
                  (!validatedAdvancesMap.containsKey(da.loanId) ||
                  !validatedAdvancesMap.get(da.loanId)
                    .containsKey(da.advanceNum))
                ) {
                  continue;
                }

                for (Integer i = 1; i < da.validFieldLines.size(); i++) {
                  Integer numOfCols = da.fileHeaderLine.size() <
                    da.validFieldLines.size()
                    ? da.fileHeaderLine.size()
                    : da.validFieldLines.size();
                  String description = '';

                  for (Integer j = 0; j < numOfCols; j++) {
                    description =
                      da.fileHeaderLine[j] +
                      ' : ' +
                      da.validFieldLines[j] +
                      ';\n' +
                      description;
                  }

                  Id whatId = da.recType == 'term'
                    ? validatedDealsMap.get(da.loanId).Id
                    : validatedAdvancesMap.get(da.loanId).get(da.advanceNum).Id;
                  Id ownerId = da.recType == 'term'
                    ? termCustodinUserId
                    : bridgeCustodinUserId;

                  if (taskMap.containsKey(whatId)) {
                    taskMap.get(whatId).Description =
                      taskMap.get(whatId).Description +
                      '\n' +
                      '----------------------------------------' +
                      '\n' +
                      description;
                  } else {
                    taskMap.put(
                      whatId,
                      createTask(
                        da,
                        description,
                        whatId,
                        ownerId,
                        taskRecTypeId
                      )
                    );
                  }
                }
              }
            }
            System.debug(taskMap.values());
            if(taskMap.size() > 0) {
              Database.executeBatch(new UpsertBatch(taskMap.values()), 1);
            }
          }
        }
      }

      // if (!errorsFound && taskMap.size() > 0) {
      //   for (id id : taskMap.keySet()) {
      //     taskList.add(taskMap.get(id));
      //   }
      //   if (taskList.size() > 0)
      //     insert taskList;
      // }

      // System.Debug('taskList :' + taskList);
    } // else of RE or FD emails

    if (errorsFound) {
      sendEmailMessage(email, errorString);
    }
    return new Messaging.InboundEmailResult();
  } //method

  // id ValidateLoanID(string loanID) {
  //   if (!string.isBlank(loanID)) {
  //     List<Opportunity> validLoadDeal = [
  //       SELECT Id
  //       FROM opportunity
  //       WHERE Deal_Loan_Number__c = :loanID
  //     ];

  //     if (validLoadDeal.size() > 0) {
  //       return validLoadDeal[0].id;
  //     }
  //   }
  //   return null;
  // }

  // id ValidateAdvance(string loanID, string advance) {
  //   if (!String.isblank(loanID) && !String.isBlank(advance)) {
  //     Integer advanceNo = 0;
  //     if (advance.isNumeric())
  //       advanceNo = Integer.valueOf(advance);
  //     List<Opportunity> validLoadDeal = [
  //       SELECT Id
  //       FROM opportunity
  //       WHERE Deal_Loan_Number__c = :loanID
  //     ];

  //     if (validLoadDeal.size() > 0) {
  //       List<Advance__c> validAdvance = [
  //         SELECT Id, Custodial_File_Sent_to_Custodian__c
  //         FROM Advance__c
  //         WHERE Advance_Num__c = :advanceNo AND deal__c = :validLoadDeal[0].id
  //       ];
  //       if (validAdvance.size() > 0) {
  //         if (validAdvance[0].Custodial_File_Sent_to_Custodian__c != null) {
  //           Custodial_File_Sent_to_Custodian = true;
  //         } else {
  //           Custodial_File_Sent_to_Custodian = false;
  //         }
  //         if (validAdvance.size() > 0) {
  //           return validAdvance[0].id;
  //         }
  //       }
  //     }
  //   }
  //   return null;
  // }

  public static String reformatLine(String currentLine) {
    String processedLine = '';
    Boolean foundDblQt = false;
    List<string> linecharacters = currentLine.split('');

    for (string eachChar : linecharacters) {
      if (eachChar == '"') {
        if (foundDblQt) {
          foundDblQt = false;
        } else {
          foundDblQt = true;
        }
      }

      if (foundDblQt) {
        if (eachChar != ',' && eachChar != '"') {
          processedLine = processedLine + eachChar;
        }
      } else {
        if (eachChar != '"')
          processedLine = processedLine + eachChar;
      }
    }

    return processedLine;
  }

  public static Task createTask(
    DrawAdvance da,
    String description,
    Id whatId,
    Id ownerId,
    Id recTypeId
  ) {
    String subject =
      da.subjectLine1 +
      ' ' +
      da.subjectLine2 +
      ' Request for Deal #' +
      da.loanId;
    if (String.isNotBlank(da.advanceNum)) {
      subject += ' and Advance no : ' + da.advanceNum;
    }

    return new Task(
      Subject = subject,
      Status = 'Open',
      Priority = 'Normal',
      WhatId = whatId,
      OwnerId = ownerId,
      ActivityDate = System.today().addDays(1),
      Description = description,
      RecordTypeId = recTypeId
    );
  }

  // public static Task createTaskX(
  //   String fileType,
  //   String loanId,
  //   String advanceID,
  //   Id ownerId,
  //   Id whatId,
  //   String description,
  //   Id recTypeId
  // ) {
  //   if (whatId != null) {
  //     if (!taskMap.containsKey(whatId)) {
  //       Task tsk = new Task();
  //       String Subject;

  //       if (!String.isBlank(loanId) && FileType == 'T') {
  //         Subject =
  //           termeSubjectLine +
  //           ' ' +
  //           termeSubjectLine2 +
  //           ' Request for Deal #' +
  //           loanId;
  //       }

  //       if (!String.isBlank(advanceID) && FileType == 'B') {
  //         Subject =
  //           bridgeSubjectLine1 +
  //           ' ' +
  //           bridgeSubjectLine2 +
  //           ' Request for Deal #' +
  //           loanId +
  //           ' and Advance No : ' +
  //           advanceID;
  //       }
  //       tsk.Subject = Subject;
  //       tsk.Status = 'Open';
  //       tsk.Priority = 'Normal';
  //       tsk.WhatId = whatId;
  //       tsk.OwnerId = ownerId;
  //       tsk.ActivityDate = date.today() + 1;
  //       tsk.Description = description;
  //       tsk.RecordTypeId = recTypeId;
  //       taskMap.put(whatId, tsk);
  //     } else {
  //       taskMap.Get(whatId).Description =
  //         taskMap.Get(whatId).Description +
  //         '\n' +
  //         '----------------------------------------' +
  //         '\n' +
  //         description;
  //     }
  //   }
  // }

  public static void sendEmailMessage(
    Messaging.InboundEmail email,
    String rateerror
  ) {
    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    //  message.ToAddresses = new List<String>{'raj.sirivolu@cvest.com'};
    message.ToAddresses = new List<String>{
      // 'support@cvest.com',email.fromAddress
      email.fromAddress
    };
    message.subject =
      'Errors found in the Draw/Advance Process Email from ' + date.today();
    message.plainTextBody = 'Following errors were found in the Draw/Advance Process Email. \n \n';
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

  public class DrawAdvance {
    public List<String> fileLines;
    public String subjectLine1;
    public String subjectLine2;
    public String recType;
    public List<List<String>> validFieldLines;
    public List<String> fileHeaderLine;
    public String loanId;
    public String advanceNum;
  }
}