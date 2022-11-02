public without sharing class YardiAPI {
  // static final String USERNAME = 'SFitf';
  // static final String PASSWORD = 'PyL9JXi`c-eRz&gt;B';
  // static final String SERVER_NAME = 'dcqtadfdm_CAF_Pilot';
  // static final String DATABASE = 'dcqtadfdm_CAF_Pilot';
  // static final String PLATFORM = 'SQL Server';
  // static final String INTERFACE_ENTITY = 'CoreVest Loan Interface';
  static final String INTERFACE_LICENSE = 'MIIBEAYJKwYBBAGCN1gDoIIBATCB/gYKKwYBBAGCN1gDAaCB7zCB7AIDAgABAgJoAQICAIAEAAQQzhEWqkdnFLc52mo5Fj0SiwSByKWbrHWWNpYruAm/OaOaJ2/EQd2t2fHQyKiCUyWdQpci/bAH1B6KhpjwTAfJPMVwot4Y7cMisnawcbBPqJyqcytHJ0pIxLmQlbGohLupESGsUDbET3vmJdSrrKF904JfvNHtNFeuRxA0htRszRslQ3qrtRtDiy7/jLCkikuUFJmowM1Nf9kYvdgPSuYy0IZ+9qFtibLSzwYDb0s9zMeJrYp+ZLv7IdaT1EYp1vaUD6HDjDIi3ChbXCmTvF5I73MuG40kiD6VgjbC';
  // static final String URL = 'https://www.yardiaspla2.com';

  // static final String TERM_FOLDER_ID = '147042016627';
  // static final String BRIDGE_FOLDER_ID = '147041409626';

  public static Settings__mdt SETTINGS = Settings__mdt.getInstance(
    'Universal_Settings'
  );

  // @AuraEnabled
  // public static List<String> createSampleData(Id recordId) {
  //   List<String> xmls = createInvoiceRegisters(recordId);

  //   system.debug(xmls);
  //   List<ContentVersion> notes = new List<ContentVersion>();
  //   for (String xml : xmls) {
  //     ContentVersion note = new ContentVersion();
  //     note.Title = 'Sample Invoice Register XML';
  //     note.PathOnClient = note.title + '.snote';
  //     note.VersionData = Blob.valueOf(xml.escapeHtml4());
  //     note.FirstPublishLocationId = recordId;

  //     sendInvoiceRegister(xml, recordId);

  //     //notes.add(note);
  //   }
  //   //insert notes;

  //   return xmls;
  // }

  @future(callout=true)
  public static void sendInvoiceRegister(String xml, Id recordId) {
    HttpRequest request;
    HttpResponse response;
    try {
      String endpoint =
        SETTINGS.Yardi_URL__c + '/25587caf/WebServices/itfvendorinvoicing.asmx';

      String requestBody = '<?xml version="1.0" encoding="utf-8"?>';
      requestBody += '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"';
      requestBody += ' xmlns:xsd="http://www.w3.org/2001/XMLSchema"';
      requestBody += ' xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">';
      requestBody += '<soap:Body>';
      requestBody += '<ImportInvoiceRegister';
      requestBody += ' xmlns="http://tempuri.org/YSI.Interfaces.WebServices/ysiItfVendorInvoicing">';
      requestBody += '<UserName>' + SETTINGS.Yardi_Username__c + '</UserName>';
      requestBody += '<Password>' + SETTINGS.Yardi_Password__c + '</Password>';
      requestBody +=
        '<ServerName>' +
        SETTINGS.Yardi_Server_Name__c +
        '</ServerName>';
      requestBody += '<Database>' + SETTINGS.Yardi_Database__c + '</Database>';
      requestBody += '<Platform>' + SETTINGS.Yardi_Platform__c + '</Platform>';
      requestBody +=
        '<InterfaceEntity>' +
        SETTINGS.Yardi_Interface_Entity__c +
        '</InterfaceEntity>';
      requestBody +=
        '<InterfaceLicense>' +
        INTERFACE_LICENSE +
        // SETTINGS.Yardi_Interface_License_Long__c +
        '</InterfaceLicense>';
      requestBody += '<InvoicRegisterDoc>' + xml + '</InvoicRegisterDoc>';
      requestBody += '</ImportInvoiceRegister>';
      requestBody += '</soap:Body>';
      requestBody += '</soap:Envelope>';
      system.debug(requestBody);
      request = new HttpRequest();
      request.setEndpoint(endpoint);
      request.setHeader('Content-Type', 'text/xml; charset=utf-8');
      request.setHeader(
        'SOAPAction',
        'http://tempuri.org/YSI.Interfaces.WebServices/ysiItfVendorInvoicing/ImportInvoiceRegister'
      );
      request.setHeader('Content-Length', String.valueOf(requestBody.length()));
      request.setMethod('POST');
      request.setBody(requestBody);

      if (!Test.isRunningTest()) {
        response = new Http().send(request);
      }

      System.enqueueJob(
        new APILoggerQueueable(request, response, recordId, false)
      );
    } catch (Exception e) {
      System.enqueueJob(new APILoggerQueueable(request, response, recordId, e));
    }

    //
  }

  public static void sendTermCSV(List<Id> recordIds) {
    List<String> csvs = new List<String>();
    csvs.add(createVendorCSVTerm(recordIds));
    csvs.add(createPropCsvTerm(recordIds));

    String folderId = SETTINGS.Box_Yardi_Term_Folder_Id__c;

    String fileString = String.valueOf(system.now()).replaceAll(' ', '_');

    uploadFile(
      Blob.valueOf(csvs[0]),
      'ETL_SFSTAGELOANVENDOR' +
      fileString +
      '.csv',
      folderId,
      null
    );

    uploadFile(
      Blob.valueOf(csvs[1]),
      'ETL_SFSTAGELOANPROP' +
      fileString +
      '.csv',
      folderId,
      null
    );
  }

  public static void sendPropertyCSV(List<Id> recordIds) {
    List<String> csvs = new List<String>();
    csvs.add(createVendorCSVProperty(recordIds));
    csvs.add(createPropCsvProperty(recordIds));

    String folderId = SETTINGS.Box_Yardi_Bridge_Folder_Id__c;

    String fileString = String.valueOf(system.now()).replaceAll(' ', '_');

    uploadFile(
      Blob.valueOf(csvs[0]),
      'ETL_SFSTAGELOANVENDOR' +
      fileString +
      '.csv',
      folderId,
      null
    );

    uploadFile(
      Blob.valueOf(csvs[1]),
      'ETL_SFSTAGELOANPROP' +
      fileString +
      '.csv',
      folderId,
      null
    );
  }

  public static String createVendorCSVTerm(List<Id> recordIds) {
    List<Opportunity> deals = [
      SELECT
        Id,
        Title__c,
        Title__r.BillingStreet,
        Title__r.BillingCity,
        Title__r.BillingState,
        Title__r.BillingCountryCode,
        Title__r.BillingStateCode,
        Title__r.BillingPostalCode,
        Title__r.Yardi_Vendor_Code__c,
        Title__r.ABA__c,
        Title__r.Bank_Account__c,
        Title__r.Name,
        Title__r.Payment_Instructions__c,
        Third_Party_Title__c,
        Third_Party_Title__r.BillingStreet,
        Third_Party_Title__r.BillingCity,
        Third_Party_Title__r.BillingState,
        Third_Party_Title__r.BillingCountryCode,
        Third_Party_Title__r.BillingStateCode,
        Third_Party_Title__r.BillingPostalCode,
        Third_Party_Title__r.Yardi_Vendor_Code__c,
        Third_Party_Title__r.ABA__c,
        Third_Party_Title__r.Bank_Account__c,
        Third_Party_Title__r.Name,
        Third_Party_Title__r.Payment_Instructions__c
      FROM Opportunity
      WHERE Id IN :recordIds
    ];

    Map<String, Account> vendorMap = new Map<String, Account>();
    for (Opportunity deal : deals) {
      if (
        deal.Title__c != null &&
        !vendorMap.containsKey(deal.Title__r.Yardi_Vendor_Code__c)
      ) {
        Account acc = deal.Title__r;
        vendorMap.put(deal.Title__r.Yardi_Vendor_Code__c, acc);
      }

      if (
        deal.Third_Party_Title__c != null &&
        !vendorMap.containsKey(deal.Title__r.Yardi_Vendor_Code__c)
      ) {
        Account acc = deal.Title__r;
        vendorMap.put(deal.Title__r.Yardi_Vendor_Code__c, acc);
      }
    }

    String csv = 'CommonCustomTables,,,,,,,,,,,,,,,\r\n';
    csv += 'TableName,dtdate,sVENDcode,sVENDname,sVENDCATEGORY,sfedid,sfurthercreditto,SVENDABA,SVENDBANKACCT,sVENDaddr1,sVENDaddr2,sVENDaddr3,sVENDaddrCity,svendst,svendzip,saddrCountry,svendphone\r\n';
    csv += 'SFSTAGEVENDOR,date,string,string,string,string,string,string,string,string,string,string,string,string,string,string,string\r\n';

    for (String vendorYardiCode : vendorMap.keySet()) {
      Account acc = vendorMap.get(vendorYardiCode);

      if (String.isNotBlank(acc.Payment_Instructions__c)) {
        acc.Payment_Instructions__c = acc.Payment_Instructions__c.replaceAll(
            '\r',
            ' '
          )
          .replaceAll('\n', ' ');
      }

      acc.Payment_Instructions__c = '';

      String billingStreet = '"' + acc.BillingStreet + '"';
      String name = '"' + acc.Name + '"';
      csv += 'SFSTAGEVENDOR,';
      csv += system.today().format() + ',';
      csv += vendorYardiCode + ',';
      csv += name + ',';
      //csv += acc.Name + ',';
      csv += 'FUNDING,,';
      csv += '"' + acc.Payment_Instructions__c + '"' + ',';
      csv += acc.ABA__c + ',';
      csv += acc.Bank_Account__c + ',';
      csv += billingStreet + ',';
      csv += ',,';
      csv += acc.BillingCity + ',';
      csv += acc.BillingStateCode + ',';
      csv += acc.BillingPostalCode + ',';
      csv += ',,\r\n';
      // csv += prop.Escrow_Agent__r.BillingCounty + ',\r\n';
    }

    return csv;
  }

  public static String createPropCsvTerm(List<Id> recordIds) {
    String csv = 'CommonCustomTables,,,,,,,,,,,\r\n';
    csv += 'TableName,dtdate,spropcode,spropname,sloantype,saddr1,saddr2,saddr3,saddrCity,saddrSt,saddrZip,saddrCounty\r\n';
    csv += 'SFSTAGELOAN,date,string,string,string,string,string,string,string,string,string,string\r\n';

    for (Opportunity deal : [
      SELECT Id, Name, Yardi_Id__c, Borrower_Entity__r.Name
      FROM Opportunity
      WHERE Id IN :recordIds
    ]) {
      String entityName = deal.Name; //+ ' (' + deal.Borrower_Entity__r.Name + ')';
      if (String.isNotBlank(deal.Borrower_Entity__r.Name)) {
        entityName += ' (' + deal.Borrower_Entity__r.Name + ')';
      }
      if (entityName.contains(',')) {
        entityName = '"' + entityName + '"';
      }

      csv += 'SFSTAGELOAN,';
      csv += system.today().format() + ',';
      csv += deal.Yardi_Id__c + ',';
      csv += entityName + ',';
      csv += 'Term,';
      csv += entityName + ',';
      csv += ',,';
      csv += ',';
      csv += ',';
      csv += ',';
      csv += ',\r\n';
    }

    return csv;
  }

  public static String createPropCsvProperty(List<Id> propertyIds) {
    List<Property__c> properties = [
      SELECT
        Id,
        Deal__r.Owner.Originating_COmpany__c,
        Deal__r.LOC_Loan_Type__c,
        Title_Company__r.BillingStreet,
        Title_Company__r.BillingCity,
        Title_Company__r.BillingState,
        Title_Company__r.BillingCountryCode,
        Title_Company__r.BillingPostalCode,
        Title_Company__r.BillingStateCode,
        Title_Company__r.Yardi_Vendor_Code__c,
        Escrow_Agent__c,
        Name,
        Yardi_Id__c,
        City__c,
        State__c,
        County__c,
        ZipCode__c,
        Address_2__c
      FROM Property__c
      WHERE Id IN :propertyIds
    ];

    Map<String, List<Property__c>> vendorMap = new Map<String, List<Property__c>>();
    for (Property__c property : properties) {
      if (
        !vendorMap.containsKey(property.Title_Company__r.Yardi_Vendor_Code__c)
      ) {
        vendorMap.put(
          property.Title_Company__r.Yardi_Vendor_Code__c,
          new List<Property__c>()
        );
      }

      vendorMap.get(property.Title_Company__r.Yardi_Vendor_Code__c)
        .add(property);
    }

    String csv = 'CommonCustomTables,,,,,,,,,,,\r\n';
    csv += 'TableName,dtdate,spropcode,spropname,sloantype,saddr1,saddr2,saddr3,saddrCity,saddrSt,saddrZip,saddrCounty\r\n';
    csv += 'SFSTAGELOAN,date,string,string,string,string,string,string,string,string,string,string\r\n';

    for (String vendorYardiCode : vendorMap.keySet()) {
      for (Property__c prop : vendorMap.get(vendorYardiCode)) {
        String propName = prop.Name;
        String propAddr = prop.Address_2__c;

        if (propName == null) {
          propName = '';
        } else if (propName.contains(',')) {
          propName = '"' + propName + '"';
        }

        csv += 'SFSTAGELOAN,';
        csv += system.today().format() + ',';
        csv += prop.Yardi_Id__c + ',';
        csv += propName + ',';
        if (
          prop.Deal__r.Owner.Originating_Company__c == 'Riverbend' &&
          (prop.Deal__r.LOC_Loan_Type__c == 'Single Asset (1-4 Unit)' ||
          prop.Deal__r.LOC_Loan_Type__C == 'Single Asset (5-10 Unit)')
        ) {
          csv += 'Term,';
        } else {
          csv += 'Bridge,';
        }
        csv += propName + ',';

        if (propAddr == null) {
          propAddr = '';
        } else if (propAddr.contains(',')) {
          propAddr = '"' + propAddr + '"';
        }

        csv += propAddr + ',';
        csv += ',';
        csv += prop.City__c + ',';
        csv += prop.State__c + ',';
        csv += prop.ZipCode__c + ',';
        csv += prop.County__c + ',';
        csv += '\r\n';
      }
    }

    return csv;
  }

  public static String createVendorCSVProperty(List<Id> recordIds) {
    Map<String, Account> vendorMap = new Map<String, Account>();
    for (Property__c property : [
      SELECT
        Id,
        Title_Company__r.BillingStreet,
        Title_Company__r.BillingCity,
        Title_Company__r.BillingState,
        Title_Company__r.BillingCountryCode,
        Title_Company__r.BillingStateCode,
        Title_Company__r.BillingPostalCode,
        Title_Company__r.Yardi_Vendor_Code__c,
        Title_Company__c,
        Title_Company__r.ABA__c,
        Title_Company__r.Bank_Account__c,
        Title_Company__r.Name,
        Title_Company__r.Payment_Instructions__c,
        Name
      FROM Property__c
      WHERE Id IN :recordIds
    ]) {
      if (
        !vendorMap.containsKey(property.Title_Company__r.Yardi_Vendor_Code__c)
      ) {
        vendorMap.put(
          property.Title_Company__r.Yardi_Vendor_Code__c,
          property.Title_Company__r
        );
      }
    }

    String csv = 'CommonCustomTables,,,,,,,,,,,,,,,\r\n';
    csv += 'TableName,dtdate,sVENDcode,sVENDname,sVENDCATEGORY,sfedid,sfurthercreditto,SVENDABA,SVENDBANKACCT,sVENDaddr1,sVENDaddr2,sVENDaddr3,sVENDaddrCity,svendst,svendzip,saddrCountry,svendphone\r\n';
    csv += 'SFSTAGEVENDOR,date,string,string,string,string,string,string,string,string,string,string,string,string,string,string,string\r\n';

    for (String vendorYardiCode : vendorMap.keySet()) {
      Account acc = vendorMap.get(vendorYardiCode);

      if (String.isNotBlank(acc.Payment_Instructions__c)) {
        acc.Payment_Instructions__c = acc.Payment_Instructions__c.replaceAll(
            '\r',
            ' '
          )
          .replaceAll('\n', ' ');
      }

      acc.Payment_Instructions__c = '';

      String billingStreet = '"' + acc.BillingStreet + '"';
      String name = '"acc.Name"';
      csv += 'SFSTAGEVENDOR,';
      csv += system.today().format() + ',';
      csv += vendorYardiCode + ',';
      csv += name + ',';
      // csv += acc.Name + ',';
      csv += 'FUNDING,,';
      csv += '"' + acc.Payment_Instructions__c + '"' + ',';
      csv += acc.ABA__c + ',';
      csv += acc.Bank_Account__c + ',';
      csv += billingStreet + ',';
      csv += ',,';
      csv += acc.BillingCity + ',';
      csv += acc.BillingStateCode + ',';
      csv += acc.BillingPostalCode + ',';
      csv += ',,\r\n';
      // csv += prop.Escrow_Agent__r.BillingCounty + ',\r\n';
    }

    return csv;
  }

  // @AuraEnabled
  // public static List<String> createSampleCSV(Id recordId) {
  //   List<String> csvs = new List<String>();
  //   //system.debug(csvs);
  //   csvs.add(createVendorCSV(recordId));

  //   String propCsv = createPropCsv(recordId);
  //   if (String.isNotBlank(propCsv)) {
  //     csvs.add(propCsv);
  //   }

  //   String loanNumber = '';
  //   String folderId = '';
  //   if (recordId.getSObjectType().getDescribe().getName() == 'Advance__c') {
  //     Advance__c adv = [
  //       SELECT Id, Deal__r.Deal_Loan_Number__c
  //       FROM Advance__c
  //       WHERE Id = :recordId
  //       LIMIT 1
  //     ];
  //     folderId = BRIDGE_FOLDER_ID;
  //     loanNumber = adv.Deal__r.Deal_Loan_Number__c;
  //   } else {
  //     folderId = TERM_FOLDER_ID;
  //     Opportunity opp = [
  //       SELECT Id, Deal_Loan_Number__c
  //       FROM Opportunity
  //       WHERE Id = :recordId
  //       LIMIT 1
  //     ];
  //     loanNumber = opp.Deal_Loan_Number__c;
  //   }

  //   String fileString =
  //     '_' +
  //     loanNumber +
  //     '_' +
  //     String.valueOf(system.now()).replaceAll(' ', '_');

  //   uploadFile(
  //     Blob.valueOf(csvs[0]),
  //     'ETL_SFSTAGELOANVENDOR' +
  //     fileString +
  //     '.csv',
  //     folderId,
  //     recordId
  //   );

  //   if (csvs.size() > 1) {
  //     uploadFile(
  //       Blob.valueOf(csvs[1]),
  //       'ETL_SFSTAGELOANPROP' +
  //       fileString +
  //       '.csv',
  //       folderId,
  //       recordId
  //     );
  //   }

  //   return csvs;
  // }

  @future(callout=true)
  public static void uploadFile(
    Blob file,
    String fileName,
    String folderId,
    Id recordId
  ) {
    BOXAPI.uploadFile(file, fileName, folderId, recordId);
  }

  // public static String createVendorCSVAdvance(Id advanceId) {
  //   Advance__c advance = [
  //     SELECT
  //       Id,
  //       (
  //         SELECT
  //           Id,
  //           Escrow_Agent__r.BillingStreet,
  //           Escrow_Agent__r.BillingCity,
  //           Escrow_Agent__r.BillingState,
  //           Escrow_Agent__r.BillingCountryCode,
  //           Escrow_Agent__r.BillingStateCode,
  //           Escrow_Agent__r.BillingPostalCode,
  //           Escrow_Agent__r.Yardi_Vendor_Code__c,
  //           Escrow_Agent__c,
  //           Escrow_Agent__r.ABA__c,
  //           Escrow_Agent__r.Bank_Account__c,
  //           Escrow_Agent__r.Name,
  //           Escrow_Agent__r.Payment_Instructions__c,
  //           Property__r.Name
  //         FROM Property_Advances__r
  //       )
  //     FROM Advance__c
  //     WHERE Id = :advanceId
  //   ];

  //   Map<String, List<Property_Advance__c>> vendorMap = new Map<String, List<Property_Advance__c>>();
  //   for (Property_Advance__c property : advance.Property_Advances__r) {
  //     if (
  //       !vendorMap.containsKey(property.Escrow_Agent__r.Yardi_Vendor_Code__c)
  //     ) {
  //       vendorMap.put(
  //         property.Escrow_Agent__r.Yardi_Vendor_Code__c,
  //         new List<Property_Advance__c>()
  //       );
  //     }

  //     vendorMap.get(property.Escrow_Agent__r.Yardi_Vendor_Code__c)
  //       .add(property);
  //   }

  //   String csv = 'CommonCustomTables,,,,,,,,,,,,,,,\r\n';
  //   csv += 'TableName,dtdate,sVENDcode,sVENDname,sVENDCATEGORY,sfedid,sfurthercreditto,SVENDABA,SVENDBANKACCT,sVENDaddr1,sVENDaddr2,sVENDaddr3,sVENDaddrCity,svendst,svendzip,saddrCountry,svendphone\r\n';
  //   csv += 'SFSTAGEVENDOR,date,string,string,string,string,string,string,string,string,string,string,string,string,string,string,string\r\n';

  //   for (String vendorYardiCode : vendorMap.keySet()) {
  //     Property_Advance__c prop = vendorMap.get(vendorYardiCode)[0];

  //     if (String.isNotBlank(prop.Escrow_Agent__r.Payment_Instructions__c)) {
  //       prop.Escrow_Agent__r.Payment_Instructions__c = prop.Escrow_Agent__r.Payment_Instructions__c.replaceAll(
  //           '\r',
  //           ' '
  //         )
  //         .replaceAll('\n', ' ');
  //     }

  //     csv += 'SFSTAGEVENDOR,';
  //     csv += system.today().format() + ',';
  //     csv += vendorYardiCode + ',';
  //     csv += prop.Escrow_Agent__r.Name + ',';
  //     csv += 'FUNDING,,';
  //     csv += '"' + prop.Escrow_Agent__r.Payment_Instructions__c + '"' + ',';
  //     csv += prop.Escrow_Agent__r.ABA__c + ',';
  //     csv += prop.Escrow_Agent__r.Bank_Account__c + ',';
  //     csv += prop.Escrow_Agent__r.BillingStreet + ',';
  //     csv += ',,';
  //     csv += prop.Escrow_Agent__r.BillingCity + ',';
  //     csv += prop.Escrow_Agent__r.BillingStateCode + ',';
  //     csv += prop.Escrow_Agent__r.BillingPostalCode + ',';
  //     csv += ',,\r\n';
  //     // csv += prop.Escrow_Agent__r.BillingCounty + ',\r\n';
  //   }

  //   return csv;
  // }

  // public static String createVendorCSVTerm(Id dealId) {
  //   Opportunity deal = [
  //     SELECT
  //       Id,
  //       (
  //         SELECT
  //           Id,
  //           Vendor__c,
  //           Vendor__r.BillingStreet,
  //           Vendor__r.BillingCity,
  //           Vendor__r.BillingState,
  //           Vendor__r.BillingCountryCode,
  //           Vendor__r.BillingStateCode,
  //           Vendor__r.BillingPostalCode,
  //           Vendor__r.Yardi_Vendor_Code__c,
  //           Vendor__r.ABA__c,
  //           Vendor__r.Bank_Account__c,
  //           Vendor__r.Name,
  //           Vendor__r.Payment_Instructions__c
  //         FROM Loan_Fees__r
  //       )
  //     FROM Opportunity
  //     WHERE Id = :dealId
  //   ];

  //   Map<String, List<Loan_Fee__c>> vendorMap = new Map<String, List<Loan_Fee__c>>();
  //   for (Loan_Fee__c fee : deal.Loan_Fees__r) {
  //     if (!vendorMap.containsKey(fee.Vendor__r.Yardi_Vendor_Code__c)) {
  //       vendorMap.put(
  //         fee.Vendor__r.Yardi_Vendor_Code__c,
  //         new List<Loan_Fee__c>()
  //       );
  //     }

  //     vendorMap.get(fee.Vendor__r.Yardi_Vendor_Code__c).add(fee);
  //   }

  //   String csv = 'CommonCustomTables,,,,,,,,,,,,,,,\r\n';
  //   csv += 'TableName,dtdate,sVENDcode,sVENDname,sVENDCATEGORY,sfedid,sfurthercreditto,SVENDABA,SVENDBANKACCT,sVENDaddr1,sVENDaddr2,sVENDaddr3,sVENDaddrCity,svendst,svendzip,saddrCountry,svendphone\r\n';
  //   csv += 'SFSTAGEVENDOR,date,string,string,string,string,string,string,string,string,string,string,string,string,string,string,string\r\n';

  //   for (String vendorYardiCode : vendorMap.keySet()) {
  //     Loan_Fee__c fee = vendorMap.get(vendorYardiCode)[0];

  //     if (String.isNotBlank(fee.Vendor__r.Payment_Instructions__c)) {
  //       fee.Vendor__r.Payment_Instructions__c = fee.Vendor__r.Payment_Instructions__c.replaceAll(
  //           '\r',
  //           ' '
  //         )
  //         .replaceAll('\n', ' ');
  //     }

  //     csv += 'SFSTAGEVENDOR,';
  //     csv += system.today().format() + ',';
  //     csv += vendorYardiCode + ',';
  //     csv += fee.Vendor__r.Name + ',';
  //     csv += 'FUNDING,,';
  //     csv += '"' + fee.Vendor__r.Payment_Instructions__c + '"' + ',';
  //     csv += fee.Vendor__r.ABA__c + ',';
  //     csv += fee.Vendor__r.Bank_Account__c + ',';
  //     csv += fee.Vendor__r.BillingStreet + ',';
  //     csv += ',,';
  //     csv += fee.Vendor__r.BillingCity + ',';
  //     csv += fee.Vendor__r.BillingStateCode + ',';
  //     csv += fee.Vendor__r.BillingPostalCode + ',';
  //     csv += ',,\r\n';
  //     // csv += prop.Escrow_Agent__r.BillingCounty + ',\r\n';
  //   }

  //   return csv;
  // }

  // public static String createVendorCSV(Id recordId) {
  //   String csv;

  //   if (recordId.getSObjectType().getDescribe().getName() == 'Advance__c') {
  //     csv = createVendorCsvAdvance(recordId);
  //   } else {
  //     csv = createVendorCsvTerm(recordId);
  //   }

  //   return csv;
  // }

  // public static String createPropCsvAdvance(Set<Id> propertyIds) {
  //   List<Property__c> properties = [
  //     SELECT
  //       Id,
  //       Escrow_Agent__r.BillingStreet,
  //       Escrow_Agent__r.BillingCity,
  //       Escrow_Agent__r.BillingState,
  //       Escrow_Agent__r.BillingCountryCode,
  //       Escrow_Agent__r.BillingPostalCode,
  //       Escrow_Agent__r.BillingStateCode,
  //       Escrow_Agent__r.Yardi_Vendor_Code__c,
  //       Escrow_Agent__c,
  //       Name,
  //       Yardi_Id__c,
  //       City__c,
  //       State__c,
  //       County__c,
  //       ZipCode__c,
  //       Address_2__c
  //     FROM Property__c
  //     WHERE Id IN :propertyIds
  //   ];

  //   Map<String, List<Property__c>> vendorMap = new Map<String, List<Property__c>>();
  //   for (Property__c property : properties) {
  //     if (
  //       !vendorMap.containsKey(property.Escrow_Agent__r.Yardi_Vendor_Code__c)
  //     ) {
  //       vendorMap.put(
  //         property.Escrow_Agent__r.Yardi_Vendor_Code__c,
  //         new List<Property__c>()
  //       );
  //     }

  //     vendorMap.get(property.Escrow_Agent__r.Yardi_Vendor_Code__c)
  //       .add(property);
  //   }

  //   String csv = 'CommonCustomTables,,,,,,,,,,,\r\n';
  //   csv += 'TableName,dtdate,spropcode,spropname,sloantype,saddr1,saddr2,saddr3,saddrCity,saddrSt,saddrZip,saddrCounty\r\n';
  //   csv += 'SFSTAGELOAN,date,string,string,string,string,string,string,string,string,string,string\r\n';

  //   for (String vendorYardiCode : vendorMap.keySet()) {
  //     for (Property__c prop : vendorMap.get(vendorYardiCode)) {
  //       csv += 'SFSTAGELOAN,';
  //       csv += system.today().format() + ',';
  //       csv += prop.Yardi_Id__c + ',';
  //       csv += prop.Name + ',';
  //       csv += 'Bridge,';
  //       csv += prop.Name + ',';

  //       if (prop.Address_2__c == null) {
  //         prop.Address_2__c = '';
  //       }

  //       csv += prop.Address_2__c + ',';
  //       csv += ',';
  //       csv += prop.City__c + ',';
  //       csv += prop.State__c + ',';
  //       csv += prop.ZipCode__c + ',';
  //       csv += prop.County__c + ',';
  //       csv += '\r\n';
  //     }
  //   }

  //   return csv;
  // }

  // public static String createPropCsvAdvance(Id advanceId) {
  //   Advance__c advance = [
  //     SELECT
  //       Id,
  //       Name,
  //       (
  //         SELECT
  //           Id,
  //           Escrow_Agent__r.BillingStreet,
  //           Escrow_Agent__r.BillingCity,
  //           Escrow_Agent__r.BillingState,
  //           Escrow_Agent__r.BillingCountryCode,
  //           Escrow_Agent__r.BillingPostalCode,
  //           Escrow_Agent__r.BillingStateCode,
  //           Escrow_Agent__r.Yardi_Vendor_Code__c,
  //           Escrow_Agent__c,
  //           Property__r.Name,
  //           Property__r.Yardi_Id__c,
  //           Property__r.City__c,
  //           Property__r.State__c,
  //           Property__r.County__c,
  //           Property__r.ZipCode__c,
  //           Property__r.Address_2__c
  //         FROM Property_Advances__r
  //       )
  //     FROM Advance__c
  //     WHERE Id = :advanceId
  //   ];

  //   Map<String, List<Property_Advance__c>> vendorMap = new Map<String, List<Property_Advance__c>>();
  //   for (Property_Advance__c property : advance.Property_Advances__r) {
  //     if (
  //       !vendorMap.containsKey(property.Escrow_Agent__r.Yardi_Vendor_Code__c)
  //     ) {
  //       vendorMap.put(
  //         property.Escrow_Agent__r.Yardi_Vendor_Code__c,
  //         new List<Property_Advance__c>()
  //       );
  //     }

  //     vendorMap.get(property.Escrow_Agent__r.Yardi_Vendor_Code__c)
  //       .add(property);
  //   }

  //   String csv = 'CommonCustomTables,,,,,,,,,,,\r\n';
  //   csv += 'TableName,dtdate,spropcode,spropname,sloantype,saddr1,saddr2,saddr3,saddrCity,saddrSt,saddrZip,saddrCounty\r\n';
  //   csv += 'SFSTAGELOAN,date,string,string,string,string,string,string,string,string,string,string\r\n';

  //   for (String vendorYardiCode : vendorMap.keySet()) {
  //     for (Property_Advance__c prop : vendorMap.get(vendorYardiCode)) {
  //       csv += 'SFSTAGELOAN,';
  //       csv += system.today().format() + ',';
  //       csv += prop.Property__r.Yardi_Id__c + ',';
  //       csv += prop.Property__r.Name + ',';
  //       csv += 'Bridge,';
  //       csv += prop.Property__r.Name + ',';

  //       if (prop.Property__r.Address_2__c == null) {
  //         prop.Property__r.Address_2__c = '';
  //       }

  //       csv += prop.Property__r.Address_2__c + ',';
  //       csv += ',';
  //       csv += prop.Property__r.City__c + ',';
  //       csv += prop.Property__r.State__c + ',';
  //       csv += prop.Property__r.ZipCode__c + ',';
  //       csv += prop.Property__r.County__c + ',';
  //       csv += '\r\n';
  //     }

  //     // Property_Advance__c prop = vendorMap.get(vendorYardiCode)[0];

  //     // csv += prop.Escrow_Agent__r.BillingCounty + ',\r\n';
  //   }

  //   return csv;
  // }

  // public static String createPropCsvTerm(Set<Id> dealContactIds){

  // }

  // public static String createPropCsvTerm(Id dealId) {
  //   Opportunity deal = [
  //     SELECT Id, Name, Yardi_Id__c, Borrower_Entity__r.Name
  //     FROM Opportunity
  //     WHERE Id = :dealId
  //   ];

  //   String csv = 'CommonCustomTables,,,,,,,,,,,\r\n';
  //   csv += 'TableName,dtdate,spropcode,spropname,sloantype,saddr1,saddr2,saddr3,saddrCity,saddrSt,saddrZip,saddrCounty\r\n';
  //   csv += 'SFSTAGELOAN,date,string,string,string,string,string,string,string,string,string,string\r\n';

  //   String entityName = deal.Name + ' (' + deal.Borrower_Entity__r.Name + ')';

  //   if (entityName.contains(',')) {
  //     entityName = '"' + entityName + '"';
  //   }

  //   csv += 'SFSTAGELOAN,';
  //   csv += system.today().format() + ',';
  //   csv += deal.Yardi_Id__c + ',';
  //   csv += entityName + ',';
  //   csv += 'Term,';
  //   csv += entityName + ',';
  //   csv += ',,';
  //   csv += ',';
  //   csv += ',';
  //   csv += ',';
  //   csv += ',\r\n';

  //   return csv;
  // }

  // public static String createPropCsv(Id recordID) {
  //   String csv;

  //   if (recordId.getSObjectType().getDescribe().getName() == 'Advance__c') {
  //     csv = createPropCsvAdvance(recordId);
  //   } else {
  //     csv = createPropCsvTerm(recordId);
  //   }

  //   return csv;
  // }

  public static List<String> createInvoiceRegistersAdvance(Id advanceId) {
    Advance__c advance = [
      SELECT
        Id,
        Deal__c,
        Origination_Fee_Adjustment__c,
        Advance_Fee_Adjustment__c,
        BlackSquare_Fee_Adjustment__c,
        BPO_Appraisal_Fee_Adjustment__c,
        Doc_Prep_Fee_Adjustment__c,
        Daily_Interest_Rate_Adjustment__c,
        BlackSquare_Fee_Total__c,
        Notes__c,
        Deal__r.Deposit_Notes__c,
        Origination_Fee_Subtotal__c,
        Deal__r.Owner.Originating_Company__c,
        Deal__r.Loc_Loan_Type__c,
        (
          SELECT
            Id,
            Property__r.Yardi_Id__c,
            Property__r.Approved_Advance_Amount__c,
            Advance_Fee__c,
            BPO_Appraisal_Fee__c,
            Doc_Prep_Fee__c,
            Broker_Advance_Fee__c,
            Property__r.Title_Company__r.Yardi_Vendor_Code__c,
            Property__r.Title_Company__c,
            Property__r.Name,
            BlackSquare_Fee__c,
            Origination_Fee__c
          FROM Property_Advances__r
        )
      FROM Advance__c
      WHERE Id = :advanceId
      LIMIT 1
    ];

    String bridgeFundingString = '2201 Bridge Funding';

    if (
      advance.Deal__r.Owner.Originating_Company__c == 'Riverbend' &&
      (advance.Deal__r.LOC_Loan_Type__c == 'Single Asset (1-4 Unit)' ||
      advance.Deal__r.LOC_Loan_Type__C == 'Single Asset (5-10 Unit)')
    ) {
      bridgeFundingString = '2241 Bridge Funding RB';
    }

    if (advance.Notes__c == null) {
      advance.Notes__c = '';
    }
    //if (advance.Origination_Fee_Subtotal__c == null) {
    //advance.Origination_Fee_Subtotal__c = 0;
    //}

    if (advance.Origination_Fee_Adjustment__c == null) {
      advance.Origination_Fee_Adjustment__c = 0;
    }

    if (advance.Advance_Fee_Adjustment__c == null) {
      advance.Advance_Fee_Adjustment__c = 0;
    }

    if (advance.BlackSquare_Fee_Adjustment__c == null) {
      advance.BlackSquare_Fee_Adjustment__c = 0;
    }

    if (advance.BPO_Appraisal_Fee_Adjustment__c == null) {
      advance.BPO_Appraisal_Fee_Adjustment__c = 0;
    }

    if (advance.Doc_Prep_Fee_Adjustment__c == null) {
      advance.Doc_Prep_Fee_Adjustment__c = 0;
    }

    if (advance.Daily_Interest_Rate_Adjustment__c == null) {
      advance.Daily_Interest_Rate_Adjustment__c = 0;
    }

    Map<String, List<Property_Advance__c>> vendorMap = new Map<String, List<Property_Advance__c>>();
    for (Property_Advance__c property : advance.Property_Advances__r) {
      if (
        !vendorMap.containsKey(
          property.Property__r.Title_Company__r.Yardi_Vendor_Code__c
        )
      ) {
        vendorMap.put(
          property.Property__r.Title_Company__r.Yardi_Vendor_Code__c,
          new List<Property_Advance__c>()
        );
      }

      vendorMap.get(property.Property__r.Title_Company__r.Yardi_Vendor_Code__c)
        .add(property);
    }

    List<String> xmls = new List<String>();

    for (String vendorYardiCode : vendorMap.keySet()) {
      Decimal approvedAdvanceAmount = 0;
      // approvedAdvanceAmount += advance.Origination_Fee_Subtotal__c;
      approvedAdvanceAmount -= advance.Origination_Fee_Adjustment__c;
      approvedAdvanceAmount -= advance.Advance_Fee_Adjustment__c;
      approvedAdvanceAmount -= advance.BlackSquare_Fee_Adjustment__c;
      approvedAdvanceAmount -= advance.BPO_Appraisal_Fee_Adjustment__c;
      approvedAdvanceAmount -= advance.Daily_Interest_Rate_Adjustment__c;
      approvedAdvanceAmount -= advance.Doc_Prep_Fee_Adjustment__c;
      // approvedAdvanceAmount -= advance.BlackSquare_Fee_Total__c;

      String yardiPropertyId = '';
      Decimal advAmtMax = null;
      for (Property_Advance__c property : vendorMap.get(vendorYardiCode)) {
        approvedAdvanceAmount += property.property__r.Approved_Advance_Amount__c !=
          null
          ? property.Property__r.Approved_Advance_Amount__c
          : 0;

        approvedAdvanceAmount += property.Advance_Fee__c != null
          ? -property.Advance_Fee__c
          : 0;

        approvedAdvanceAmount += property.BPO_Appraisal_Fee__c != null
          ? -property.BPO_Appraisal_Fee__c
          : 0;

        approvedAdvanceAmount += property.Doc_Prep_Fee__c != null
          ? -property.Doc_Prep_Fee__c
          : 0;

        // approvedAdvanceAmount += property.Broker_Advance_Fee__c != null
        //   ? -property.Broker_Advance_Fee__c
        //   : 0;

        approvedAdvanceAmount += property.BlackSquare_Fee__c != null
          ? -property.BlackSquare_Fee__c
          : 0;

        approvedAdvanceAmount += property.Origination_Fee__c != null
          ? -property.Origination_Fee__c
          : 0;

        if (
          advAmtMax == null ||
          advAmtMax < property.Property__r.Approved_Advance_Amount__c
        ) {
          advAmtMax = property.Property__r.Approved_Advance_Amount__c;
          yardiPropertyId = property.Property__r.Yardi_ID__c;
        }
      }

      String invoiceRegister = '<InvoiceRegisters xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="Itf_InvoiceRegister.xsd" xmlns="">';
      invoiceRegister += '<Invoices>';
      invoiceRegister += '<Payable>';
      invoiceRegister += '<PersonId>' + vendorYardiCode + '</PersonId>';
      invoiceRegister +=
        '<InvoiceNumber>Inv_' +
        vendorYardiCode +
        '_' +
        String.valueOf(system.now()).replaceAll(' ', '_') +
        '</InvoiceNumber>';
      invoiceRegister += '<CashAccountId></CashAccountId>';
      invoiceRegister += '<ApAccountId></ApAccountId>';
      // invoiceRegister += '<PostMonth></PostMonth>';
      invoiceRegister +=
        '<InvoiceDate>' +
        String.valueOf(system.today()) +
        'T00:00:00</InvoiceDate>';
      invoiceRegister +=
        '<DueDate>' +
        String.valueOf(system.today()) +
        'T00:00:00</DueDate>';
      invoiceRegister +=
        '<DiscountDate>' +
        String.valueOf(system.today()) +
        'T00:00:00</DiscountDate>';
      invoiceRegister += '<IsUnpaid>true</IsUnpaid>';
      invoiceRegister +=
        '<TotalAmount>' +
        String.valueOf(approvedAdvanceAmount) +
        '</TotalAmount>';
      invoiceRegister += '<AmountPaid>0</AmountPaid>';
      invoiceRegister += '<DisplayType>IR Display Type</DisplayType>';
      invoiceRegister += '<ExpenseType>Bridge Funding</ExpenseType>';
      invoiceRegister += '<Status>Approved</Status>';
      invoiceRegister += '<Details>';

      for (Property_Advance__c property : vendorMap.get(vendorYardiCode)) {
        if (
          property.property__r.Approved_Advance_Amount__c != null &&
          property.property__r.Approved_Advance_Amount__c != 0
        ) {
          invoiceRegister += '<Detail>';
          invoiceRegister +=
            '<Amount>' +
            String.valueOf(property.property__r.Approved_Advance_Amount__c) +
            '</Amount>';
          invoiceRegister += '<AccountId>1631-0000</AccountId>';
          invoiceRegister += '<CashAccountId></CashAccountId>';
          invoiceRegister +=
            '<PropertyId>' +
            property.Property__r.Yardi_Id__c +
            '</PropertyId>';
          invoiceRegister += '<Notes>' + property.Property__r.Name + '</Notes>';
          // invoiceRegister += '<Segment1>2201 Bridge Funding</Segment1>';
          invoiceRegister += '<Segment1>' + bridgeFundingString + '</Segment1>';

          invoiceRegister += '</Detail>';
        }

        if (property.Advance_Fee__c != null && property.Advance_Fee__c != 0) {
          invoiceRegister += '<Detail>';
          invoiceRegister +=
            '<Amount>-' +
            String.valueOf(property.Advance_Fee__c) +
            '</Amount>';
          invoiceRegister += '<AccountId>4622-0000</AccountId>';
          invoiceRegister += '<CashAccountId></CashAccountId>';
          invoiceRegister +=
            '<PropertyId>' +
            property.Property__r.Yardi_Id__c +
            '</PropertyId>';
          invoiceRegister += '<Notes>' + property.Property__r.Name + '</Notes>';
          // invoiceRegister += '<Segment1>2201 Bridge Funding</Segment1>';
          invoiceRegister += '<Segment1>' + bridgeFundingString + '</Segment1>';

          invoiceRegister += '</Detail>';
        }

        if (
          property.BPO_Appraisal_Fee__c != null &&
          property.BPO_Appraisal_Fee__c != 0
        ) {
          invoiceRegister += '<Detail>';
          invoiceRegister +=
            '<Amount>-' +
            String.valueOf(property.BPO_Appraisal_Fee__c) +
            '</Amount>';
          invoiceRegister += '<AccountId>2188-0000</AccountId>';
          invoiceRegister += '<CashAccountId></CashAccountId>';
          invoiceRegister +=
            '<PropertyId>' +
            property.Property__r.Yardi_Id__c +
            '</PropertyId>';
          invoiceRegister +=
            '<Notes>' +
            advance.Deal__r.Deposit_Notes__c +
            '</Notes>';
          // invoiceRegister += '<Segment1>2201 Bridge Funding</Segment1>';
          invoiceRegister += '<Segment1>' + bridgeFundingString + '</Segment1>';

          invoiceRegister += '</Detail>';
        }

        if (property.Doc_Prep_Fee__c != null && property.Doc_Prep_Fee__c != 0) {
          invoiceRegister += '<Detail>';
          invoiceRegister +=
            '<Amount>-' +
            String.valueOf(property.Doc_Prep_Fee__c) +
            '</Amount>';
          invoiceRegister += '<AccountId>4621-0000</AccountId>';
          invoiceRegister += '<CashAccountId></CashAccountId>';
          invoiceRegister +=
            '<PropertyId>' +
            property.Property__r.Yardi_Id__c +
            '</PropertyId>';
          invoiceRegister += '<Notes>' + property.Property__r.Name + '</Notes>';
          // invoiceRegister += '<Segment1>2201 Bridge Funding</Segment1>';
          invoiceRegister += '<Segment1>' + bridgeFundingString + '</Segment1>';

          invoiceRegister += '</Detail>';
        }

        // if (
        //   property.Broker_Advance_Fee__c != null &&
        //   property.Broker_Advance_Fee__c != 0
        // ) {
        //   invoiceRegister += '<Detail>';
        //   invoiceRegister +=
        //     '<Amount>-' +
        //     String.valueOf(property.Broker_Advance_Fee__c) +
        //     '</Amount>';
        //   invoiceRegister += '<AccountId>5100-5000</AccountId>';
        //   invoiceRegister += '<CashAccountId></CashAccountId>';
        //   invoiceRegister +=
        //     '<PropertyId>' +
        //     property.Property__r.Yardi_Id__c +
        //     '</PropertyId>';
        //   invoiceRegister += '<Notes>' + property.Property__r.Name + '</Notes>';
        //   invoiceRegister += '<Segment1>2201 Bridge Funding</Segment1>';
        //   invoiceRegister += '</Detail>';
        // }

        if (
          property.BlackSquare_Fee__c != null &&
          property.BlackSquare_Fee__c != 0
        ) {
          invoiceRegister += '<Detail>';
          invoiceRegister +=
            '<Amount>-' +
            String.valueOf(property.BlackSquare_Fee__c) +
            '</Amount>';
          invoiceRegister += '<AccountId>2188-0000</AccountId>';
          invoiceRegister += '<CashAccountId></CashAccountId>';
          invoiceRegister +=
            '<PropertyId>' +
            property.Property__r.Yardi_Id__c +
            '</PropertyId>';
          invoiceRegister += '<Notes>' + property.Property__r.Name + '</Notes>';
          // invoiceRegister += '<Segment1>2201 Bridge Funding</Segment1>';
          invoiceRegister += '<Segment1>' + bridgeFundingString + '</Segment1>';

          invoiceRegister += '</Detail>';
        }

        if (
          property.Origination_Fee__c != null &&
          property.Origination_Fee__c != 0
        ) {
          invoiceRegister += '<Detail>';
          invoiceRegister +=
            '<Amount>-' +
            String.valueOf(property.Origination_Fee__c) +
            '</Amount>';
          invoiceRegister += '<AccountId>4622-0000</AccountId>';
          invoiceRegister += '<CashAccountId></CashAccountId>';
          invoiceRegister +=
            '<PropertyId>' +
            property.Property__r.Yardi_Id__c +
            '</PropertyId>';
          invoiceRegister += '<Notes>' + property.Property__r.Name + '</Notes>';
          // invoiceRegister += '<Segment1>2201 Bridge Funding</Segment1>';
          invoiceRegister += '<Segment1>' + bridgeFundingString + '</Segment1>';

          invoiceRegister += '</Detail>';
        }
      }

      //Origination_Fee_Adjustment__c
      if (
        advance.Origination_Fee_Adjustment__c != null &&
        advance.Origination_Fee_Adjustment__c != 0
      ) {
        invoiceRegister += '<Detail>';
        invoiceRegister +=
          '<Amount>' +
          String.valueOf(-advance.Origination_Fee_Adjustment__c) +
          '</Amount>';
        invoiceRegister += '<AccountId>1103-1000</AccountId>';
        invoiceRegister += '<CashAccountId></CashAccountId>';
        invoiceRegister += '<PropertyId>' + yardiPropertyId + '</PropertyId>';
        invoiceRegister += '<Notes>Origination Fee Adjustment</Notes>';
        // invoiceRegister += '<Segment1>2201 Bridge Funding</Segment1>';
        invoiceRegister += '<Segment1>' + bridgeFundingString + '</Segment1>';

        invoiceRegister += '</Detail>';
      }

      // if (
      //   advance.Origination_Fee_Subtotal__c != null &&
      //   advance.Origination_Fee_Subtotal__c != 0
      // ) {
      //   invoiceRegister += '<Detail>';
      //   invoiceRegister +=
      //     '<Amount>' +
      //     String.valueOf(advance.Origination_Fee_Subtotal__c) +
      //     '</Amount>';
      //   invoiceRegister += '<AccountId>1103-1000</AccountId>';
      //   invoiceRegister += '<CashAccountId></CashAccountId>';
      //   invoiceRegister += '<PropertyId>' + yardiPropertyId + '</PropertyId>';
      //   invoiceRegister += '<Notes>Origination Fee Adjustment</Notes>';
      //   invoiceRegister += '<Segment1>2201 Bridge Funding</Segment1>';
      //   invoiceRegister += '</Detail>';
      // }

      if (
        advance.Advance_Fee_Adjustment__c != null &&
        advance.Advance_Fee_Adjustment__c != 0
      ) {
        invoiceRegister += '<Detail>';
        invoiceRegister +=
          '<Amount>' +
          String.valueOf(-advance.Advance_Fee_Adjustment__c) +
          '</Amount>';
        invoiceRegister += '<AccountId>1103-1000</AccountId>';
        invoiceRegister += '<CashAccountId></CashAccountId>';
        invoiceRegister += '<PropertyId>' + yardiPropertyId + '</PropertyId>';
        invoiceRegister += '<Notes>Advance Fee Adjustment</Notes>';
        // invoiceRegister += '<Segment1>2201 Bridge Funding</Segment1>';
        invoiceRegister += '<Segment1>' + bridgeFundingString + '</Segment1>';

        invoiceRegister += '</Detail>';
      }

      //BlackSquare_Fee_Adjustment__c
      if (
        advance.BlackSquare_Fee_Adjustment__c != null &&
        advance.BlackSquare_Fee_Adjustment__c != 0
      ) {
        invoiceRegister += '<Detail>';
        invoiceRegister +=
          '<Amount>' +
          String.valueOf(-advance.BlackSquare_Fee_Adjustment__c) +
          '</Amount>';
        invoiceRegister += '<AccountId>1103-1000</AccountId>';
        invoiceRegister += '<CashAccountId></CashAccountId>';
        invoiceRegister += '<PropertyId>' + yardiPropertyId + '</PropertyId>';
        invoiceRegister += '<Notes>Onboarding Fee Adjustment</Notes>';
        // invoiceRegister += '<Segment1>2201 Bridge Funding</Segment1>';
        invoiceRegister += '<Segment1>' + bridgeFundingString + '</Segment1>';

        invoiceRegister += '</Detail>';
      }
      //BPO_Appraisal_Fee_Adjustment__c
      if (
        advance.BPO_Appraisal_Fee_Adjustment__c != null &&
        advance.BPO_Appraisal_Fee_Adjustment__c != 0
      ) {
        invoiceRegister += '<Detail>';
        invoiceRegister +=
          '<Amount>' +
          String.valueOf(-advance.BPO_Appraisal_Fee_Adjustment__c) +
          '</Amount>';
        invoiceRegister += '<AccountId>1103-1000</AccountId>';
        invoiceRegister += '<CashAccountId></CashAccountId>';
        invoiceRegister += '<PropertyId>' + yardiPropertyId + '</PropertyId>';
        invoiceRegister += '<Notes>Appraisal Fee Adjustment</Notes>';
        // invoiceRegister += '<Segment1>2201 Bridge Funding</Segment1>';
        invoiceRegister += '<Segment1>' + bridgeFundingString + '</Segment1>';

        invoiceRegister += '</Detail>';
      }
      //Doc_Prep_Fee_Adjustment__c
      if (
        advance.Doc_Prep_Fee_Adjustment__c != null &&
        advance.Doc_Prep_Fee_Adjustment__c != 0
      ) {
        invoiceRegister += '<Detail>';
        invoiceRegister +=
          '<Amount>' +
          String.valueOf(-advance.Doc_Prep_Fee_Adjustment__c) +
          '</Amount>';
        invoiceRegister += '<AccountId>1103-1000</AccountId>';
        invoiceRegister += '<CashAccountId></CashAccountId>';
        invoiceRegister += '<PropertyId>' + yardiPropertyId + '</PropertyId>';
        invoiceRegister += '<Notes>Doc Prep Fee Adjustment</Notes>';
        // invoiceRegister += '<Segment1>2201 Bridge Funding</Segment1>';
        invoiceRegister += '<Segment1>' + bridgeFundingString + '</Segment1>';

        invoiceRegister += '</Detail>';
      }
      //Daily_Interest_Rate_Adjustment__c
      if (
        advance.Daily_Interest_Rate_Adjustment__c != null &&
        advance.Daily_Interest_Rate_Adjustment__c != 0
      ) {
        invoiceRegister += '<Detail>';
        invoiceRegister +=
          '<Amount>' +
          String.valueOf(-advance.Daily_Interest_Rate_Adjustment__c) +
          '</Amount>';
        invoiceRegister += '<AccountId>1103-1000</AccountId>';
        invoiceRegister += '<CashAccountId></CashAccountId>';
        invoiceRegister += '<PropertyId>' + yardiPropertyId + '</PropertyId>';
        invoiceRegister += '<Notes>Daily Interest Rate Adjustment</Notes>';
        // invoiceRegister += '<Segment1>2201 Bridge Funding</Segment1>';
        invoiceRegister += '<Segment1>' + bridgeFundingString + '</Segment1>';

        invoiceRegister += '</Detail>';
      }
      //BlackSquare_Fee_Total__c
      // if (
      //   advance.BlackSquare_Fee_Total__c != null &&
      //   advance.BlackSquare_Fee_Total__c != 0
      // ) {
      //   invoiceRegister += '<Detail>';
      //   invoiceRegister +=
      //     '<Amount>-' +
      //     String.valueOf(advance.BlackSquare_Fee_Total__c) +
      //     '</Amount>';
      //   invoiceRegister += '<AccountId>2188-0000</AccountId>';
      //   invoiceRegister += '<CashAccountId></CashAccountId>';
      //   invoiceRegister += '<PropertyId>' + yardiPropertyId + '</PropertyId>';
      //   invoiceRegister += '<Notes>Onboarding Fee Total</Notes>';
      //   invoiceRegister += '<Segment1>2201 Bridge Funding</Segment1>';
      //   invoiceRegister += '</Detail>';
      // }
      invoiceRegister += '</Details>';

      invoiceRegister += '</Payable>';
      invoiceRegister += '</Invoices>';
      invoiceRegister += '</InvoiceRegisters>';

      xmls.add(invoiceRegister);
    }

    return xmls;
  }

  public static List<String> createInvoiceRegistersTerm(Id dealId) {
    system.debug(dealId);
    Opportunity deal = [
      SELECT
        Id,
        Current_Loan_Amount__c,
        Yardi_ID__c,
        Origination_Fee__c,
        Deposit_Lender_Out_of_Pocket__c,
        Name,
        Borrower_Entity__r.Name,
        Deposit_Amount__c,
        Title__c,
        Third_Party_Title__c,
        Title__r.Yardi_Vendor_Code__c,
        Third_Party_Title__r.Yardi_Vendor_Code__c,
        (
          SELECT
            Id,
            Deposit_Lender_Out_of_Pocket__c,
            Stub_Interest__c,
            Origination_Fee__c,
            Deposit_Amount__c,
            Bridge_Payoff__c,
            Installment_Comment__c,
            Legal_Fee__c,
            Discount_Fee_Number__c
          FROM Loan_Versions__r
          WHERE
            RecordType.DeveloperName = 'Schedule_of_Lender_Cost'
            AND Finalized__c = TRUE
        )
      FROM Opportunity
      WHERE Id = :dealId
    ];

    Loan_Version__c schedule = new Loan_Version__c();
    schedule.Installment_Comment__c = '';
    if (deal.Loan_Versions__r.size() == 0) {
      List<Loan_Version__c> schedules = [
        SELECT
          Id,
          Deposit_Lender_Out_of_Pocket__c,
          Stub_Interest__c,
          Origination_Fee__c,
          Deposit_Amount__c,
          Bridge_Payoff__c,
          Installment_Comment__c,
          Legal_Fee__c,
          Discount_Fee_Number__c
        FROM Loan_Version__c
        WHERE Deal__c = :deal.Id
        ORDER BY CreatedDate DESC
      ];
      if (schedules.size() > 0) {
        schedule = schedules[0];
      }
    } else {
      schedule = deal.Loan_Versions__r[0];
    }
    // )

    List<String> xmls = new List<String>();

    // for (Loan_Fee__c fee : deal.Loan_Fees__r) {
    Decimal totalAmount = 0;

    totalAmount += deal.Current_Loan_Amount__c != null
      ? deal.Current_Loan_Amount__c
      : 0;
    totalAmount -= schedule.Origination_Fee__c != null
      ? schedule.Origination_Fee__c
      : 0;
    totalAmount -= schedule.Deposit_Lender_Out_of_Pocket__c != null
      ? schedule.Deposit_Lender_Out_of_Pocket__c
      : 0;
    totalAmount += schedule.Deposit_Amount__c != null
      ? schedule.Deposit_Amount__c
      : 0;

    totalAmount -= schedule.Bridge_Payoff__c != null
      ? schedule.Bridge_Payoff__c
      : 0;

    totalAmount -= schedule.Stub_Interest__c != null
      ? schedule.Stub_Interest__c
      : 0;

    totalAmount -= schedule.Legal_Fee__c != null ? schedule.Legal_Fee__c : 0;
    totalAmount -= schedule.Discount_Fee_Number__c != null
      ? schedule.Discount_Fee_Number__c
      : 0;

    String vendorYardiId = '';
    if (deal.Third_Party_Title__c != null) {
      vendorYardiId = deal.Third_Party_Title__r.Yardi_Vendor_Code__c;
    } else if (deal.Title__c != null) {
      vendorYardiId = deal.Title__r.Yardi_Vendor_Code__c;
    }
    String invoiceRegister = '<InvoiceRegisters xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="Itf_InvoiceRegister.xsd" xmlns="">';
    invoiceRegister += '<Invoices>';
    invoiceRegister += '<Payable>';
    invoiceRegister += '<PersonId>' + vendorYardiId + '</PersonId>';
    invoiceRegister +=
      '<InvoiceNumber>Inv_' +
      vendorYardiId +
      '_' +
      String.valueOf(system.now()).replaceAll(' ', '_') +
      '</InvoiceNumber>';
    invoiceRegister += '<CashAccountId></CashAccountId>';
    invoiceRegister += '<ApAccountId></ApAccountId>';
    // invoiceRegister += '<PostMonth></PostMonth>';
    invoiceRegister +=
      '<InvoiceDate>' +
      String.valueOf(system.today()) +
      'T00:00:00</InvoiceDate>';
    invoiceRegister +=
      '<DueDate>' +
      String.valueOf(system.today()) +
      'T00:00:00</DueDate>';
    invoiceRegister +=
      '<DiscountDate>' +
      String.valueOf(system.today()) +
      'T00:00:00</DiscountDate>';
    invoiceRegister += '<IsUnpaid>true</IsUnpaid>';

    invoiceRegister +=
      '<TotalAmount>' +
      String.valueOf(totalAmount) +
      '</TotalAmount>';

    invoiceRegister += '<AmountPaid>0</AmountPaid>';
    // invoiceRegister += '<Notes />';
    // invoiceRegister += '<IsCreditMemo></IsCreditMemo>';
    // invoiceRegister += '<IsAdjustment></IsAdjustment>';
    // invoiceRegister += '<IsConsolidateChecks></IsConsolidateChecks>';
    // invoiceRegister += '<ExemptFrom1099></ExemptFrom1099>';
    // invoiceRegister += '<UserDefinedFields_2></UserDefinedFields_2>';
    // invoiceRegister += '<UserDefinedFields_3></UserDefinedFields_3>';
    invoiceRegister += '<DisplayType>IR Display Type</DisplayType>';
    invoiceRegister += '<ExpenseType>Term Funding</ExpenseType>';
    invoiceRegister += '<Status>Approved</Status>';
    invoiceRegister += '<Details>';
    invoiceRegister += '<Detail>';

    String entityName = deal.Name;
    if (String.isNotBlank(deal.Borrower_Entity__r.Name)) {
      entityName += '(' + deal.Borrower_Entity__r.Name + ')';
    }

    if (deal.Current_Loan_Amount__c != null) {
      invoiceRegister +=
        '<Amount>' +
        String.valueOf(deal.Current_Loan_Amount__c) +
        '</Amount>';
      invoiceRegister += '<AccountId>1631-0002</AccountId>';
      invoiceRegister += '<CashAccountId></CashAccountId>';
      invoiceRegister += '<PropertyId>' + deal.Yardi_ID__c + '</PropertyId>';
      invoiceRegister += '<Notes>' + entityName + '</Notes>';
      invoiceRegister += '<Segment1>2101 Term Funding</Segment1>';
      invoiceRegister += '</Detail>';
    }

    if (schedule != null && schedule.Origination_Fee__c != null) {
      invoiceRegister += '<Detail>';
      invoiceRegister +=
        '<Amount>-' +
        String.valueOf(schedule.Origination_Fee__c) +
        '</Amount>';
      invoiceRegister += '<AccountId>4622-0000</AccountId>';
      invoiceRegister += '<CashAccountId></CashAccountId>';
      invoiceRegister += '<PropertyId>' + deal.Yardi_ID__c + '</PropertyId>';
      invoiceRegister += '<Notes>' + entityName + '</Notes>';
      invoiceRegister += '<Segment1>2101 Term Funding</Segment1>';
      invoiceRegister += '</Detail>';
    }

    if (schedule != null && schedule.Bridge_Payoff__c != null) {
      invoiceRegister += '<Detail>';
      invoiceRegister +=
        '<Amount>-' +
        String.valueOf(schedule.Bridge_Payoff__c) +
        '</Amount>';
      invoiceRegister += '<AccountId>1103-1000</AccountId>';
      invoiceRegister += '<CashAccountId></CashAccountId>';
      invoiceRegister += '<PropertyId>' + deal.Yardi_ID__c + '</PropertyId>';
      invoiceRegister += '<Notes>' + entityName + '</Notes>';
      invoiceRegister += '<Segment1>2101 Term Funding</Segment1>';
      invoiceRegister += '</Detail>';
    }

    if (schedule != null && schedule.Deposit_Lender_Out_of_Pocket__c != null) {
      invoiceRegister += '<Detail>';
      invoiceRegister +=
        '<Amount>-' +
        String.valueOf(schedule.Deposit_Lender_Out_of_Pocket__c) +
        '</Amount>';
      invoiceRegister += '<AccountId>4621-0000</AccountId>';
      invoiceRegister += '<CashAccountId></CashAccountId>';
      invoiceRegister += '<PropertyId>' + deal.Yardi_ID__c + '</PropertyId>';
      invoiceRegister += '<Notes>' + entityName + '</Notes>';
      invoiceRegister += '<Segment1>2101 Term Funding</Segment1>';
      invoiceRegister += '</Detail>';
    }

    if (schedule != null && schedule.Stub_Interest__c != null) {
      invoiceRegister += '<Detail>';
      invoiceRegister +=
        '<Amount>-' +
        String.valueOf(schedule.Stub_Interest__c) +
        '</Amount>';
      invoiceRegister += '<AccountId>1647-1000</AccountId>';
      invoiceRegister += '<CashAccountId></CashAccountId>';
      invoiceRegister += '<PropertyId>' + deal.Yardi_ID__c + '</PropertyId>';
      invoiceRegister += '<Notes>' + entityName + '</Notes>';
      invoiceRegister += '<Segment1>2101 Term Funding</Segment1>';
      invoiceRegister += '</Detail>';
    }

    if (schedule != null && schedule.Deposit_Amount__c != null) {
      invoiceRegister += '<Detail>';
      invoiceRegister +=
        '<Amount>' +
        String.valueOf(schedule.Deposit_Amount__c) +
        '</Amount>';
      invoiceRegister += '<AccountId>1295-0000</AccountId>';
      invoiceRegister += '<CashAccountId></CashAccountId>';
      invoiceRegister += '<PropertyId>' + deal.Yardi_ID__c + '</PropertyId>';
      invoiceRegister += '<Notes>' + entityName + '</Notes>';
      invoiceRegister += '<Segment1>2101 Term Funding</Segment1>';
      invoiceRegister += '</Detail>';
    }

    if (schedule != null && schedule.Legal_Fee__c != null) {
      invoiceRegister += '<Detail>';
      invoiceRegister +=
        '<Amount>-' +
        String.valueOf(schedule.Legal_Fee__c) +
        '</Amount>';
      invoiceRegister += '<AccountId>4627-0000</AccountId>';
      invoiceRegister += '<CashAccountId></CashAccountId>';
      invoiceRegister += '<PropertyId>' + deal.Yardi_ID__c + '</PropertyId>';
      invoiceRegister += '<Notes>' + entityName + '</Notes>';
      invoiceRegister += '<Segment1>2101 Term Funding</Segment1>';
      invoiceRegister += '</Detail>';
    }

    if (schedule != null && schedule.Discount_Fee_Number__c != null) {
      invoiceRegister += '<Detail>';
      invoiceRegister +=
        '<Amount>-' +
        String.valueOf(schedule.Discount_Fee_Number__c) +
        '</Amount>';
      invoiceRegister += '<AccountId>9737-0000</AccountId>';
      invoiceRegister += '<CashAccountId></CashAccountId>';
      invoiceRegister += '<PropertyId>' + deal.Yardi_ID__c + '</PropertyId>';
      invoiceRegister += '<Notes>' + entityName + ' - Rate Buydown</Notes>';
      invoiceRegister += '<Segment1>2101 Term Funding</Segment1>';
      invoiceRegister += '</Detail>';
    }

    invoiceRegister += '</Details>';

    invoiceRegister += '</Payable>';
    invoiceRegister += '</Invoices>';
    invoiceRegister += '</InvoiceRegisters>';

    xmls.add(invoiceRegister);
    // }

    return xmls;
  }

  public static List<String> createInvoiceRegisters(Id recordId) {
    List<String> xmls;

    if (recordId.getSObjectType().getDescribe().getName() == 'Advance__c') {
      xmls = createInvoiceRegistersAdvance(recordId);
    } else {
      xmls = createInvoiceRegistersTerm(recordId);
    }

    return xmls;
  }
}