public class CoreLogicBase {
  private static String preparedBody = '<MESSAGE MISMOReferenceModelIdentifier="3.4[B324]" xmlns="http://www.mismo.org/residential/2009/schemas" xmlns:cl="http://globalgateway.corelogic.com/order/2015" xmlns:xlink="http://www.w3.org/1999/xlink"><DEAL_SETS><DEAL_SET><DEALS><DEAL><LOANS><LOAN LoanRoleType="SubjectLoan"><ORIGINATION_SYSTEMS><ORIGINATION_SYSTEM><LoanOriginationSystemName>CVT</LoanOriginationSystemName></ORIGINATION_SYSTEM></ORIGINATION_SYSTEMS></LOAN></LOANS><PARTIES><PARTY SequenceNumber="1"><INDIVIDUAL><NAME><FirstName>{{FIRSTNAME}}</FirstName><LastName>{{LASTNAME}}</LastName></NAME></INDIVIDUAL><ROLES><ROLE xlink:label="Borrower01"><BORROWER><BORROWER_DETAIL><BorrowerBirthDate>{{BIRTHDATE}}</BorrowerBirthDate><BorrowerClassificationType>Primary</BorrowerClassificationType><BorrowerIsAnIndividualPersonIndicator>true</BorrowerIsAnIndividualPersonIndicator></BORROWER_DETAIL><RESIDENCES><RESIDENCE SequenceNumber="1"><ADDRESS><AddressFormatType>Individual</AddressFormatType><AddressType>Current</AddressType><CityName>{{CITY}}</CityName><CountryCode>{{COUNTRYCODE}}</CountryCode><PostalCode>{{POSTALCODE}}</PostalCode><StateCode>{{STATECODE}}</StateCode><StreetName>{{STREET}}</StreetName><StreetPrimaryNumberText>{{STREETPRIMARYNUMBER}}</StreetPrimaryNumberText><StreetSuffixText>{{STREETSUFFIX}}</StreetSuffixText></ADDRESS><RESIDENCE_DETAIL><BorrowerResidencyType>Current</BorrowerResidencyType></RESIDENCE_DETAIL></RESIDENCE></RESIDENCES></BORROWER><ROLE_DETAIL><PartyRoleType>Borrower</PartyRoleType></ROLE_DETAIL></ROLE></ROLES></PARTY></PARTIES><SERVICES><SERVICE><CREDIT><CREDIT_REQUEST><CREDIT_REQUEST_DATAS><CREDIT_REQUEST_DATA xlink:label="CreditRequest001"><CREDIT_REPOSITORY_INCLUDED><CreditRepositoryIncludedEquifaxIndicator>true</CreditRepositoryIncludedEquifaxIndicator><CreditRepositoryIncludedExperianIndicator>true</CreditRepositoryIncludedExperianIndicator><CreditRepositoryIncludedTransUnionIndicator>true</CreditRepositoryIncludedTransUnionIndicator></CREDIT_REPOSITORY_INCLUDED><CREDIT_REQUEST_DATA_DETAIL><CreditReportRequestActionType>Submit</CreditReportRequestActionType><CreditReportType>Other</CreditReportType><CreditReportTypeOtherDescription>Prequal</CreditReportTypeOtherDescription></CREDIT_REQUEST_DATA_DETAIL></CREDIT_REQUEST_DATA></CREDIT_REQUEST_DATAS></CREDIT_REQUEST></CREDIT><REPORTING_INFORMATION><ReportingInformationIdentifier>GG000498</ReportingInformationIdentifier><ReportingInformationName>GlobalGatewayLenderIdentifier</ReportingInformationName></REPORTING_INFORMATION></SERVICE></SERVICES></DEAL></DEALS></DEAL_SET><PARTIES><PARTY SequenceNumber="1"><ROLES><ROLE xlink:label="RequestingParty001"><RETURN_TO><PREFERRED_RESPONSES><PREFERRED_RESPONSE><PreferredResponseFormatType>PDF</PreferredResponseFormatType><PreferredResponseFormatTypeOtherDescription>PDF</PreferredResponseFormatTypeOtherDescription><PreferredResponseUseEmbeddedFileIndicator>true</PreferredResponseUseEmbeddedFileIndicator></PREFERRED_RESPONSE><PREFERRED_RESPONSE><PreferredResponseFormatType>XML</PreferredResponseFormatType><PreferredResponseUseEmbeddedFileIndicator>false</PreferredResponseUseEmbeddedFileIndicator></PREFERRED_RESPONSE></PREFERRED_RESPONSES></RETURN_TO><ROLE_DETAIL><PartyRoleType>RequestingParty</PartyRoleType></ROLE_DETAIL></ROLE><ROLE SequenceNumber="2" xlink:label="RequestingParty002"><REQUESTING_PARTY><InternalAccountIdentifier>{{IDENTIFIER}}</InternalAccountIdentifier><RequestedByName>BJHA</RequestedByName><RequestingPartyBranchIdentifier>34343</RequestingPartyBranchIdentifier><EXTENSION><OTHER><cl:REQUESTING_PARTY><cl:LoginAccountIdentifier>{{IDENTIFIER}}</cl:LoginAccountIdentifier><cl:LoginAccountPassword>{{PASSWORD}}</cl:LoginAccountPassword></cl:REQUESTING_PARTY></OTHER></EXTENSION></REQUESTING_PARTY></ROLE></ROLES></PARTY></PARTIES></DEAL_SETS></MESSAGE>';
  private class CoreLogicException extends Exception {
  }
  private class CoreLogicConfig {
    String sandbox_Username;
    String production_Username;

    String sandbox_Password;
    String production_Password;

    String sandbox_Client_Certificate_Name;
    String production_Client_Certificate_Name;

    String sandbox_Endpoint;
    String production_Endpoint;

    CoreLogicConfig() {
      this.sandbox_Username = '4003938';
      this.sandbox_Password = '328JHZ5V';
      this.sandbox_Client_Certificate_Name = 'corelogicsandbox'; //alias name of added certificate @ Certificate and Key Management.
      this.sandbox_Endpoint = 'https://uat1.globalgateway.corelogic.com/order/creditservicerequest/credit?action=Submit';

      this.production_Username = '';
      this.production_Password = '';
      this.production_Client_Certificate_Name = '';
      this.production_Endpoint = '';
    }
  }

  public static Boolean orgIsSandbox {
    get {
      if (orgIsSandbox == null) {
        orgIsSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
      }
      return orgIsSandbox;
    }
    set;
  }

  private class PersonInfo {
    String firstName;
    String lastName;
    String birthDate;
    String street;
    String zipPostalCode;
    String city;
    String stateCode;
    String streetPrimaryNumber;
    String streetSuffix;
    String country;
  }

  //generate HTTP request
  public static HttpRequest generateRequest(PersonInfo pInfo) {
    HttpRequest req = new HttpRequest();

    preparedBody = preparedBody.replace('{{FIRSTNAME}}', pInfo.firstName);
    preparedBody = preparedBody.replace('{{LASTNAME}}', pInfo.lastName);
    preparedBody = preparedBody.replace('{{BIRTHDATE}}', pInfo.birthDate);
    preparedBody = preparedBody.replace('{{CITY}}', pInfo.city);
    preparedBody = preparedBody.replace('{{POSTALCODE}}', pInfo.zipPostalCode);
    preparedBody = preparedBody.replace('{{STATECODE}}', pInfo.stateCode);
    preparedBody = preparedBody.replace('{{STREET}}', pInfo.street);
    preparedBody = preparedBody.replace(
      '{{STREETPRIMARYNUMBER}}',
      pInfo.streetPrimaryNumber
    );
    preparedBody = preparedBody.replace('{{STREETSUFFIX}}', pInfo.streetSuffix);
    preparedBody = preparedBody.replace('{{COUNTRYCODE}}', pInfo.country);

    try {
      CoreLogicConfig mCoreLogicConfig = new CoreLogicConfig();
      Blob header;
      String endpt = '';
      String str = '';
      if (orgIsSandbox) {
        header = Blob.valueOf(
          mCoreLogicConfig.Sandbox_Username +
          ':' +
          mCoreLogicConfig.Sandbox_Password
        );
        req.setClientCertificateName(
          mCoreLogicConfig.Sandbox_Client_Certificate_Name
        );
        req.setEndpoint(mCoreLogicConfig.sandbox_Endpoint);
        System.debug(
          'Requesting-Party-Login-Account-Identifier:::' +
          mCoreLogicConfig.Sandbox_Username
        );
        System.debug(
          'Requesting-Party-Login-Account-Password:::' +
          mCoreLogicConfig.Sandbox_Password
        );
        req.setHeader(
          'Requesting-Party-Login-Account-Identifier',
          mCoreLogicConfig.Sandbox_Username
        );
        req.setHeader(
          'Requesting-Party-Login-Account-Password',
          mCoreLogicConfig.Sandbox_Password
        );
        preparedBody = preparedBody.replace(
          '{{IDENTIFIER}}',
          mCoreLogicConfig.Sandbox_Username
        );
        preparedBody = preparedBody.replace(
          '{{PASSWORD}}',
          mCoreLogicConfig.Sandbox_Password
        );
      } else {
        header = Blob.valueOf(
          mCoreLogicConfig.Production_Username +
          ':' +
          mCoreLogicConfig.Production_Password
        );
        req.setClientCertificateName(
          mCoreLogicConfig.Production_Client_Certificate_Name
        );
        req.setEndpoint(mCoreLogicConfig.production_Endpoint);
        System.debug(
          'Requesting-Party-Login-Account-Identifier:::' +
          mCoreLogicConfig.production_Username
        );
        System.debug(
          'Requesting-Party-Login-Account-Password:::' +
          mCoreLogicConfig.production_Password
        );
        req.setHeader(
          'Requesting-Party-Login-Account-Identifier',
          mCoreLogicConfig.production_Username
        );
        req.setHeader(
          'Requesting-Party-Login-Account-Password',
          mCoreLogicConfig.production_Password
        );
        preparedBody = preparedBody.replace(
          '{{IDENTIFIER}}',
          mCoreLogicConfig.production_Username
        );
        preparedBody = preparedBody.replace(
          '{{PASSWORD}}',
          mCoreLogicConfig.production_Password
        );
      }
      System.debug('preparedBody:::' + preparedBody);
      req.setBody(preparedBody);
      req.setMethod('POST');
      req.setTimeout(120000);
      req.setHeader('Content-Type', 'application/xml');
      req.setHeader('Accept', 'application/xml');
      return req;
    } catch (exception e) {
      throw new CoreLogicException(
        'The following exception has occurred: ' +
        e.getMessage() +
        ', & Line Number:' +
        e.getLinenumber()
      );
    }
  }

  @AuraEnabled
  public static String fetchCreditReport(Id dealContactId, Id dealID) {
    Map<String, String> returnValue = new Map<String, String>();
    try {
      system.debug('dealContactId::::' + dealContactId);
      map<string, string> contactIDVSDealContactID = new Map<string, string>();
      list<string> ContactIDList = new List<string>();
      for (Deal_Contact__c dc : [
        SELECT id, name, Contact__c
        FROM Deal_Contact__c
        WHERE id = :dealContactId
        LIMIT 1
      ]) {
        ContactIDList.add(dc.Contact__c);
        contactIDVSDealContactID.put(dc.Contact__c, dc.id);
      }
      system.debug('ContactIDList:::::' + ContactIDList);

      List<Contact> mContactList = new List<Contact>(
        [
          SELECT
            ID,
            FIRSTNAME,
            LASTNAME,
            name,
            Birthdate,
            MailingCountry,
            MailingStreet,
            MailingCity,
            MailingPostalCode,
            MailingState,
            MailingCountryCode,
            MailingStateCode
          FROM Contact
          WHERE Id = :ContactIDList
          LIMIT 1
        ]
      );
      system.debug('mContactList::::' + mContactList);
      if (mContactList.isEmpty()) {
        returnValue.put('error', 'User not found.');
        return json.serialize(returnValue);
      }
      Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
      Schema.SObjectType leadSchema = schemaMap.get('Contact');
      Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe()
        .fields.getMap();
      List<String> fieldNames = new List<String>{
        'FIRSTNAME',
        'LASTNAME',
        'Birthdate',
        'MailingCountryCode',
        'MailingStreet',
        'MailingCity',
        'MailingPostalCode'
      };
      for (String fName : fieldNames) {
        if (String.isBlank(String.valueOf(mContactList[0].get(fName)))) {
          throw new CoreLogicException(
            'Your contact record is missing a ' +
            fieldMap.get(fName).getDescribe().getLabel() +
            '.'
          );
        }
      }
      PersonInfo pInfo = new PersonInfo();
      pInfo.firstName = mContactList[0].FIRSTNAME;
      pInfo.lastName = mContactList[0].LASTNAME;
      pInfo.birthDate = string.valueof(mContactList[0].Birthdate);
      pInfo.country = mContactList[0].MailingCountryCode;
      pInfo.street = mContactList[0].MailingStreet;
      pInfo.city = mContactList[0].MailingCity;
      pInfo.zipPostalCode = mContactList[0].MailingPostalCode;
      String regex = '[a-zA-Z]{1,}|\\-';
      System.debug(
        'mContactList[0].MailingStreet:::::::' + mContactList[0].MailingStreet
      );
      String tmpStreetPrimaryNumber = mContactList[0].MailingStreet != null
        ? String.valueof(mContactList[0].MailingStreet).replaceAll(regex, '')
        : '';
      System.debug('tmpStreetPrimaryNumber:::::::' + tmpStreetPrimaryNumber);
      pInfo.streetPrimaryNumber = tmpStreetPrimaryNumber.trim();
      pInfo.stateCode = mContactList[0].MailingStateCode;
      pInfo.streetSuffix = '';
      Http http = new Http();
      HTTPResponse res = new HTTPResponse();
      HttpRequest req = CoreLogicBase.generateRequest(pInfo);

      try {
        res = http.send(req);
        system.debug(res.getStatusCode());
        system.debug(JSON.serialize(res.getBody()));
        if (res.getStatusCode() == 200) {
          System.debug('RESPONSECODE:::::' + res.getStatusCode());
          System.debug('BODY:::::' + res.getBody());
          Contact updateContact = new Contact();
          updateContact.Id = mContactList[0].Id;
          Dom.Document doc = new Dom.Document();
          doc.load(res.getBody());
          Dom.XMLNode message = doc.getRootElement();
          // XMLParserClass obj = new XMLParserClass();
          // obj.parserXML(XMLParser.sampleresp);
          // System.debug(obj.xmlDataMap);
          list<contact> contactListForUpdate = new List<contact>();
          Map<String, String> creditScoresMap = new Map<String, String>();
          string xmlContent = '';
          //DOCUMENT_SETS>DOCUMENT_SET>DOCUMENTS>DOCUMENT>DEAL_SETS>DEAL_SET>DEALS>DEAL>SERVICES>SERVICE>CREDIT>CREDIT_RESPONSE>CREDIT_SCORES>CREDIT_SCORE
          for (Dom.XMLNode messageChild : message.getChildElements()) {
            if (messageChild.getName() == 'DOCUMENT_SETS') {
              for (Dom.XMLNode docSetChilds : messageChild.getChildElements()) {
                if (docSetChilds.getName() == 'DOCUMENT_SET') {
                  for (
                    Dom.XMLNode dealSetChilds : docSetChilds.getChildElements()
                  ) {
                    if (dealSetChilds.getName() == 'DOCUMENTS') {
                      for (
                        Dom.XMLNode dealsChilds : dealSetChilds.getChildElements()
                      ) {
                        if (dealsChilds.getName() == 'DOCUMENT') {
                          for (
                            Dom.XMLNode dealChilds : dealsChilds.getChildElements()
                          ) {
                            if (dealChilds.getName() == 'DEAL_SETS') {
                              for (
                                Dom.XMLNode servicesChilds : dealChilds.getChildElements()
                              ) {
                                if (servicesChilds.getName() == 'DEAL_SET') {
                                  for (
                                    Dom.XMLNode serviceChilds : servicesChilds.getChildElements()
                                  ) {
                                    if (serviceChilds.getName() == 'DEALS') {
                                      for (
                                        Dom.XMLNode dealChildsDoc : serviceChilds.getChildElements()
                                      ) {
                                        if (dealChildsDoc.getName() == 'DEAL') {
                                          for (
                                            Dom.XMLNode doc1 : dealChildsDoc.getChildElements()
                                          ) {
                                            if (doc1.getName() == 'SERVICES') {
                                              for (
                                                Dom.XMLNode doc2 : doc1.getChildElements()
                                              ) {
                                                if (
                                                  doc2.getName() == 'SERVICE'
                                                ) {
                                                  for (
                                                    Dom.XMLNode doc3 : doc2.getChildElements()
                                                  ) {
                                                    if (
                                                      doc3.getName() == 'CREDIT'
                                                    ) {
                                                      for (
                                                        Dom.XMLNode doc4 : doc3.getChildElements()
                                                      ) {
                                                        if (
                                                          doc4.getName() ==
                                                          'CREDIT_RESPONSE'
                                                        ) {
                                                          for (
                                                            Dom.XMLNode doc5 : doc4.getChildElements()
                                                          ) {
                                                            if (
                                                              doc5.getName() ==
                                                              'CREDIT_SCORES'
                                                            ) {
                                                              for (
                                                                Dom.XMLNode doc6 : doc5.getChildElements()
                                                              ) {
                                                                if (
                                                                  doc6.getName() ==
                                                                  'CREDIT_SCORE'
                                                                ) {
                                                                  for (
                                                                    Dom.XMLNode doc7 : doc6.getChildElements()
                                                                  ) {
                                                                    System.debug(
                                                                      'doc7::' +
                                                                      doc7.getName()
                                                                    );
                                                                    if (
                                                                      doc7.getName() ==
                                                                      'CREDIT_SCORE_DETAIL'
                                                                    ) {
                                                                      String issuer = '';
                                                                      String score = '';
                                                                      for (
                                                                        Dom.XMLNode doc8 : doc7.getChildElements()
                                                                      ) {
                                                                        if (
                                                                          doc8.getName() ==
                                                                          'CreditRepositorySourceType'
                                                                        ) {
                                                                          issuer = doc8.getText();
                                                                        }
                                                                        if (
                                                                          doc8.getName() ==
                                                                          'CreditScoreValue'
                                                                        ) {
                                                                          score = doc8.getText();
                                                                        }
                                                                      }
                                                                      if (
                                                                        score !=
                                                                        ''
                                                                      ) {
                                                                        creditScoresMap.put(
                                                                          issuer,
                                                                          score
                                                                        );
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            if (dealChilds.getName() == 'VIEWS') {
                              for (
                                Dom.XMLNode viewsChilds : dealChilds.getChildElements()
                              ) {
                                if (viewsChilds.getName() == 'VIEW') {
                                  for (
                                    Dom.XMLNode viewChilds : viewsChilds.getChildElements()
                                  ) {
                                    if (viewChilds.getName() == 'VIEW_FILES') {
                                      for (
                                        Dom.XMLNode viewFiles : viewChilds.getChildElements()
                                      ) {
                                        if (
                                          viewFiles.getName() == 'VIEW_FILE'
                                        ) {
                                          for (
                                            Dom.XMLNode foreignObj : viewFiles.getChildElements()
                                          ) {
                                            if (
                                              foreignObj.getName() ==
                                              'FOREIGN_OBJECT'
                                            ) {
                                              for (
                                                Dom.XMLNode contentXML : foreignObj.getChildElements()
                                              ) {
                                                if (
                                                  contentXML.getName() ==
                                                  'EmbeddedContentXML'
                                                ) {
                                                  xmlContent = contentXML.getText();
                                                  system.debug(
                                                    'xmlContent::::' +
                                                    xmlContent
                                                  );
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }

          list<Deal_Document__c> dealDocList = new List<Deal_Document__c>();
          list<Deal_Document__c> dealDocumentList = [
            SELECT id, Contact__c
            FROM Deal_Document__c
            WHERE Contact__c = :mContactList[0].id
          ];
          system.debug('dealDocumentList::::' + dealDocumentList);

          if (dealDocumentList != null && dealDocumentList.size() > 0) {
            if (xmlContent != null && xmlContent != '') {
              ContentVersion cv = new ContentVersion();
              cv.Title =
                'Credco ' +
                mContactList[0].name +
                system.today() +
                '.pdf';
              cv.PathOnClient =
                'Credco ' +
                mContactList[0].name +
                system.today() +
                '.pdf';
              cv.VersionData = EncodingUtil.base64Decode(xmlContent);
              insert cv;

              ContentVersion cvRecord = [
                SELECT Id, ContentDocumentId
                FROM ContentVersion
                WHERE Id = :cv.Id
              ];
              ContentDocumentLink cl = new ContentDocumentLink();
              cl.ContentDocumentId = cvRecord.ContentDocumentId;
              cl.LinkedEntityId = dealDocumentList[0].id;
              cl.ShareType = 'V';
              cl.Visibility = 'AllUsers';
              insert cl;

              Deal_Document__c dealDOcObj = new Deal_Document__c();
              dealDOcObj.id = dealDocumentList[0].id;
              dealDOcObj.Attachment_Id__c = cvRecord.ContentDocumentId;
              update dealDOcObj;

              /*  Attachment attach = new Attachment();
                        attach.contentType = 'application/pdf';
                        attach.name = 'SoftPull_ '+ mContactList[0].name+ '.pdf';
                        attach.parentId = dealDocumentList[0].id;
                        attach.body = EncodingUtil.base64Decode(xmlContent);
                        insert attach; */
            }
          } else {
            Deal_Document__c dealDoc = new Deal_Document__c();
            dealDoc.Deal__c = dealID;
            dealDoc.Type__c = 'Diligence Documents';
            dealDoc.Section__c = 'Background and Credit Search';
            dealDoc.Document_Type__c = 'Background and Credit Search';
            dealDoc.Contact__c = mContactList[0].id;
            dealDoc.Document_Loaded__c = true;
            dealDoc.Added_By__c = UserInfo.getUserId();
            dealDoc.Added_On__c = Datetime.now();

            dealDocList.add(dealDoc);
          }

          if (dealDocList != null && dealDocList.size() > 0) {
            Database.UpsertResult[] srList = Database.upsert(
              dealDocList,
              false
            );

            for (Database.UpsertResult sr : srList) {
              if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted.  ID: ' + sr.getId());
                if (xmlContent != null && xmlContent != '') {
                  ContentVersion cv = new ContentVersion();
                  cv.Title =
                    'Credco ' +
                    mContactList[0].name +
                    system.today() +
                    '.pdf';
                  cv.PathOnClient =
                    'Credco ' +
                    mContactList[0].name +
                    system.today() +
                    '.pdf';
                  cv.VersionData = EncodingUtil.base64Decode(xmlContent);
                  insert cv;

                  ContentVersion cvRecord = [
                    SELECT Id, ContentDocumentId
                    FROM ContentVersion
                    WHERE Id = :cv.Id
                  ];
                  ContentDocumentLink cl = new ContentDocumentLink();
                  cl.ContentDocumentId = cvRecord.ContentDocumentId;
                  cl.LinkedEntityId = sr.getId();
                  cl.ShareType = 'V';
                  cl.Visibility = 'AllUsers';
                  insert cl;

                  Deal_Document__c dealDOcObj = new Deal_Document__c();
                  dealDOcObj.id = sr.getId();
                  dealDOcObj.Attachment_Id__c = cvRecord.ContentDocumentId;
                  update dealDOcObj;
                }

                /* Attachment attach = new Attachment();
                            attach.contentType = 'application/pdf';
                            attach.name = 'SoftPull_ '+ mContactList[0].name+ '.pdf';
                            attach.parentId = sr.getId();
                            attach.body = EncodingUtil.base64Decode(xmlContent);
                            insert attach; */
              } else {
                // Operation failed, so get all errors
                for (Database.Error err : sr.getErrors()) {
                  System.debug('The following error has occurred.');
                  System.debug(err.getStatusCode() + ': ' + err.getMessage());
                  System.debug(
                    'fields that affected this error: ' + err.getFields()
                  );
                }
              }
            }
          }

          list<Deal_Contact__c> dealContactListForUpdate = new List<Deal_Contact__c>();
          Deal_Contact__c dc = new Deal_Contact__c();
          dc.id = contactIDVSDealContactID.get(mContactList[0].id);
          if (creditScoresMap != null && creditScoresMap.size() > 0) {
            if (creditScoresMap.containsKey('Equifax')) {
              updateContact.Equifax__c = integer.valueOf(
                creditScoresMap.get('Equifax')
              );
              dc.Equifax__c = integer.valueOf(creditScoresMap.get('Equifax'));
            }
            if (creditScoresMap.containsKey('Experian')) {
              updateContact.Experian__c = integer.valueOf(
                creditScoresMap.get('Experian')
              );
              dc.Experian__c = integer.valueOf(creditScoresMap.get('Experian'));
            }
            if (creditScoresMap.containsKey('TransUnion')) {
              updateContact.TransUnion__c = integer.valueOf(
                creditScoresMap.get('TransUnion')
              );
              dc.TransUnion__c = integer.valueOf(
                creditScoresMap.get('TransUnion')
              );
            }
          }
          dealContactListForUpdate.add(dc);
          contactListForUpdate.add(updateContact);
          //CoreLogicBase.fetchCreditReport('0037i00000kB13T');
          System.debug('creditScoresMap:::' + creditScoresMap);
          System.debug('contactListForUpdate:::' + contactListForUpdate);
          System.debug(
            'dealContactListForUpdate:::' + dealContactListForUpdate
          );

          if (contactListForUpdate != null && contactListForUpdate.size() > 0) {
            update contactListForUpdate;
          }
          if (
            dealContactListForUpdate != null &&
            dealContactListForUpdate.size() > 0
          ) {
            update dealContactListForUpdate;
          }
        }
        returnValue.put('success', '');
        System.enqueueJob(
          new APILoggerQueueable(req, res, dealContactId, false)
        );
        return json.serialize(returnValue);
      } catch (Exception err) {
        System.enqueueJob(new APILoggerQueueable(req, res, dealContactId, err));
        throw err;
      }
    } catch (Exception e) {
      returnValue.put('error', e.getMessage());
      System.debug(
        'Exception:' +
        e.getMessage() +
        ', & Line Number: ' +
        e.getLinenumber()
      );
      return json.serialize(returnValue);
    }
  }

  @AuraEnabled
  public static Boolean getConsentFromContact(list<string> contactId) {
    Boolean isConsent = false;

    if (contactId != null || contactId.size() > 0) {
      for (contact crList : [
        SELECT id, Consent__c
        FROM contact
        WHERE id = :contactId
        LIMIT 1
      ]) {
        system.debug('crList:::' + crList);
        if (crList.Consent__c) {
          isConsent = true;
        } else {
          isConsent = false;
        }
      }
    }
    system.debug('isConsent:::' + isConsent);
    return isConsent;
  }
}