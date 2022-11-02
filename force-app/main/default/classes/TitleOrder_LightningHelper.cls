public without sharing class TitleOrder_LightningHelper {
  public static final String DOCUMENT_TYPE = 'Title Order';
  public static final List<String> DEAL_DOC_FIELDS = new List<String>{
    'Id',
    'Deal__c',
    'Title_Order__c',
    'Service_Link_Id__c',
    'Type__c',
    'Document_Type__c',
    'File_Name__c',
    'Attachment_Id__c',
    'ContentVersion_Id__c'
  };
  public static final List<String> DEAL_FIELDS = new List<String>{
    'Deal_Loan_Number__c',
    'Id',
    'Current_Loan_Amount__c',
    'Name'
  };

  public static final Map<String, String> DATATAPE_FIELD_MAP = new Map<String, String>{
    'Asset_ID__c' => 'Asset ID',
    'Property_Name__c' => 'Property Name (Parent Property)',
    'APN__c' => 'APN',
    'Property_Type__c' => 'Property Type',
    'Name' => 'Address',
    'City__c' => 'City',
    'State__c' => 'State',
    'ZipCode__c' => 'ZIP',
    'County__c' => 'County',
    'Number_of_Units__c' => '# of Units',
    'Number_of_Beds__c' => 'BD',
    'Number_of_Bath__c' => 'BA',
    'Square_Feet__c' => 'SF',
    'No_of_Stories__c' => '# of Stories',
    'Year_Built__c' => 'Year Built',
    'Air_Conditioning__c' => 'A/C',
    'Pool__c' => 'Pool',
    'Section_8__c' => 'Section 8',
    'Condition__c' => 'Condition',
    'Zoning_Compliance__c' => 'Legally Conforming',
    'Acquisition_Date__c' => 'Acquisition Date',
    'Acquisition_Price__c' => 'Acquisition Price',
    'Acquisition_Type__c' => 'Acquisition Type',
    'Transaction_Costs__c' => 'Transaction Costs',
    'Rehab_Costs__c' => 'Rehab Costs',
    'Rehab_Completion_Date__c' => 'Rehab Completion Date',
    'Total_Basis__c' => 'Total Basis',
    'Borrower_Opinion_of_Current_Value__c' => 'Borrower Opinion of Current Market Value',
    'Calc_AveValue__c' => 'Red Bell Calc AveValue',
    'Appraisal_Form__c' => 'Appraisal Form',
    'BPO_Appraisal_Date__c' => 'Effective Date',
    'Appraised_Value_Amount__c' => 'Appraisal Value',
    'Currently_Leased__c' => 'Currently Leased? (Y/N)',
    'Lease_Ready__c' => 'Lease Ready',
    'Lease_Start_Date__c' => 'Lease Start Date',
    'Lease_End_Date__c' => 'Lease End Date',
    'Lease_Term__c' => 'Lease Term',
    'Monthly_Rent__c' => 'Monthly Rent',
    'Estimated_Rent__c' => 'Monthly Estimated Rent',
    'Security_Deposit__c' => 'Security Deposit',
    'Other_Income__c' => 'Other Income',
    'Annual_HOA_Fee__c' => 'HOA',
    'Special_Assesments_CFD_Mello_Roos_etc__c' => 'Special Assessments',
    'Annual_Taxes__c' => 'Taxes',
    'Annual_Insurance__c' => 'Insurance',
    'Annual_Managment_Fee__c' => 'Property Management',
    'Maintenance_Repairs__c' => 'Maintenance/ Repairs',
    'Owner_Paid_Utilities__c' => 'Owner Paid Utilities',
    'Annual_Landscaping_Expense__c' => 'Landscaping Expense',
    'Other_Expenses__c' => 'Other Expenses',
    'Lease_Up_Marketing__c' => 'Lease Up/Marketing',
    'Vacancy_Repairs__c' => 'Vacancy Repairs/Maintenance',
    'Credit_Loss__c' => 'Credit Loss',
    'Annual_Total_Expenses__c' => 'Total Expenses',
    'Cap_Ex_Reserves__c' => 'CapEx Reserves',
    'Other_Reserves__c' => 'Other Reserves',
    'Annual_NOI__c' => 'NOI',
    'Property_Manager__c' => 'Assigned PM Company (By property)',
    'Interior_Access_POC__c' => 'Interior Access POC',
    'Interior_Access_POC_Phone__c' => 'Interior Access POC Phone',
    'Interior_Access_POC_Email__c' => 'Interior Access POC Email',
    'Existing_Debt__c' => 'Existing Debt',
    'Asset_Maturity_Date_Override__c' => 'Date of Maturity',
    'Current_Interest_Rate__c' => 'Interest Rate',
    'Are_Payments_Current__c' => 'Are payments current',
    'Refinance_Acquisition__c' => 'Refinance / Acquisition',
    'ALA__c' => 'ALA',
    'Appraisal_Replacement_Cost_Value__c' => 'Appraisal Replacement Cost Value'
  };

  public static Deal_Document__c createDealDocument(
    String type,
    ContentVersion cv,
    Id dealId
  ) {
    Deal_Document__c dealDoc = new Deal_Document__c();
    dealDoc.Type__c = type;
    dealDoc.File_Name__c = cv.Title;
    dealDoc.ContentVersion_Id__c = cv.Id;
    dealDoc.Document_Type__c = DOCUMENT_TYPE;
    dealDoc.Attachment_Id__c = cv.ContentDocumentId;
    dealDoc.Deal__c = dealId;

    insert dealDoc;
    return dealDoc;
  }
  public static ContentVersion queryCv(Id cdId) {
    return [
      SELECT
        Id,
        ContentSize,
        VersionData,
        Title,
        FileExtension,
        ContentDocumentId
      FROM ContentVersion
      WHERE ContentDocumentId = :cdId
    ];
  }

  @AuraEnabled
  public static List<Title_Order__c> queryTitleOrders(Id dealId) {
    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    Set<String> propFields = schemaMap.get('Property__c')
      .getDescribe()
      .fields.getMap()
      .keySet();
    Set<String> toFields = schemaMap.get('Title_Order__c')
      .getDescribe()
      .fields.getMap()
      .keySet();

    String queryString =
      'SELECT ' +
      String.join(new List<String>(toFields), ',') +
      ',Property__r.' +
      String.join(new List<String>(propFields), ',Property__r.');

    queryString += ' FROM Title_Order__c WHERE Deal__c = :dealId ORDER BY Quote_ID__c';

    List<Title_Order__c> titleOrders = Database.query(queryString);

    return titleOrders;
  }

  @AuraEnabled
  public static String saveGeneratedFile(
    String base64Data,
    String fileName,
    String parentId
  ) {
    try {
      ContentVersion cv = new ContentVersion();
      cv.VersionData = EncodingUtil.base64Decode(base64Data);
      cv.Title = fileName;
      cv.PathOnClient = fileName;

      insert cv;

      cv = [
        SELECT
          Id,
          ContentDocumentId,
          ContentSize,
          VersionData,
          Title,
          FileExtension
        FROM ContentVersion
        WHERE Id = :cv.Id
      ];

      ContentDocumentLink cdl = new ContentDocumentLink(
        ShareType = 'I',
        Visibility = 'AllUsers',
        LinkedEntityId = parentId,
        ContentDocumentId = cv.ContentDocumentId
      );

      insert cdl;

      return cv.ContentDocumentId;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static Map<String, List<String>> retrieveSchemas() {
    try {
      return new Map<String, List<String>>{
        'inquiryType' => new List<String>{
          'REVISEDQUO',
          'SIGNINGREQ',
          'CURINQUIRY',
          'CLOSINGINQ'
        },
        'documentType' => new List<String>{
          'EXECESCLTR',
          'LLC',
          'LNDINST',
          'THRDPRTYINV',
          'TRCKTOATTY',
          'UEQCERT',
          'UESCRLTR',
          'UMTGDOT',
          'UNEXSIGPG',
          'UNFILEDUCC'
        }
      };
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static String retrieveData(Id dealId) {
    try {
      List<ReturnObject> returnObj = new List<ReturnObject>();
      List<Property__c> props = [
        SELECT
          Id,
          Name,
          City__c,
          Property_Type__c,
          Number_of_Units__c,
          Status__c,
          (
            SELECT
              Id,
              Status__c,
              Order_Opened_Date__c,
              Title_Complete_Date__c,
              Original_Title_Cleared_Date__c,
              All_Cleared_To_Close_Date__c,
              Comments__c,
              Title_Vendor__c,
              Order_Number__c,
              Quote_ID__c,
              Bulk_Project_Order_Num__c,
              Error_Message__c,
              Has_Order_Inquiry__c,
              Has_Order_Inquiry_Response__c
            FROM Title_Orders__r
            WHERE Status__c != 'Cancelled'
            ORDER BY CreatedDate DESC
          )
        FROM Property__c
        WHERE Deal__c = :dealId AND Is_Sub_Unit__c = FALSE
      ];

      for (Property__c p : props) {
        ReturnObject retVal = new ReturnObject();
        retVal.parseData(p, p.Title_Orders__r);
        returnObj.add(retVal);
      }

      return JSON.serialize(returnObj);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static List<Deal_Document__c> retrieveDocuments(
    Id dealId,
    List<Id> titleOrderIds
  ) {
    try {
      String queryString =
        'SELECT ' +
        String.join(DEAL_DOC_FIELDS, ',') +
        ' FROM Deal_Document__c';
      queryString += ' WHERE Document_Type__c = :DOCUMENT_TYPE AND Deal__c= :dealId';
      if (titleOrderIds.size() > 0) {
        queryString += ' AND Title_Order__c IN :titleOrderIds';
      }
      List<Deal_Document__c> dealDocs = Database.query(queryString);

      return dealDocs;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static String returnDataTapeJson(List<Id> propertyIds) {
    String query =
      'SELECT ' +
      String.join(new List<String>(DATATAPE_FIELD_MAP.keySet()), ', ') +
      ' FROM Property__c WHERE Id IN :propertyIds';

    List<Property__c> props = Database.query(query);
    List<Map<String, Object>> returnList = new List<Map<String, Object>>();

    for (Property__c p : props) {
      Map<String, Object> objMap = new Map<String, Object>();
      List<String> keySet = new List<String>(DATATAPE_FIELD_MAP.keySet());
      for (Integer i = keySet.size() - 1; i >= 0; i--) {
        String key = keySet[i];
        objMap.put(DATATAPE_FIELD_MAP.get(key), p.get(key));
      }
      returnList.add(objMap);
    }

    return JSON.serialize(returnList);
  }

  @AuraEnabled
  public static String sendRequest(
    String requestType,
    Id dealId,
    Id cdId,
    String comments,
    Title_Order__c to,
    String inquiryType,
    List<Id> propIds,
    List<Id> propTitleIds
  ) {
    if (requestType == 'QuoteRequest') {
      return quoteRequest(dealId, cdId, comments);
    } else if (requestType == 'OrderInquiry') {
      return orderInquiry(
        to,
        cdId,
        inquiryType,
        comments,
        dealId,
        propIds,
        propTitleIds
      );
    } else if (requestType == 'OrderChangeRequest') {
      return orderChangeRequest(propTitleIds[0]);
    } else {
      return '';
    }
  }

  @AuraEnabled
  public static String quoteRequest(Id dealId, Id cdId, String comments) {
    Set<Id> propertyIds = new Map<Id, Property__c>(
        [
          SELECT Id
          FROM Property__c
          WHERE
            Deal__c = :dealId
            AND Is_Sub_Unit__c = FALSE
            AND Status__c != 'Inactive'
            AND Status__c != 'Cancelled'
        ]
      )
      .keySet();
    TitleOrderQuoteId__c toQuoteSetting = TitleOrderQuoteId__c.getOrgDefaults();
    String quoteId = toQuoteSetting.Next_Quote_ID__c;
    ContentVersion cv = queryCv(cdId);

    System.debug(cv);

    String queryString =
      'SELECT ' +
      String.join(DEAL_FIELDS, ',') +
      ' FROM Opportunity WHERE Id = :dealId';
    Opportunity deal = Database.query(queryString);

    ServiceLinkAPI.QuoteRequest qRequest = new ServiceLinkAPI.QuoteRequest(
      deal,
      cv,
      quoteId,
      comments
    );
    try {
      ServiceLinkAPI.performRequest('QuoteRequest', JSON.serialize(qRequest));
    } catch (Exception ex) {
      return ex.getMessage();
    }

    createDealDocument('Data Tape', cv, dealId);

    List<Property_Title__c> propertyTitles = new List<Property_Title__c>();
    Title_Order__c titleOrder = new Title_Order__c(
      Source_Party_ID__c = qRequest.SourcePartyID,
      Destination_Party_ID__c = qRequest.DestinationPartyID,
      Quote_ID__c = qRequest.QuoteID,
      Loan_Number__c = qRequest.LoanNumber,
      Loan_Portfolio_Name__c = qRequest.LoanPortfolioName,
      Loan_Amount__c = qRequest.LoanAmount,
      Comments__c = 'QuoteRequest Comments: ' + qRequest.Comments + '\n',
      Document_Name__c = qRequest.Document.DocumentName,
      Document_Type__c = qRequest.Document.DocumentType,
      Deal__c = dealId,
      Status__c = 'Quote Requested',
      Title_Vendor__c = 'Servicelink'
    );

    insert titleOrder;

    for (Id propId : propertyIds) {
      propertyTitles.add(
        new Property_Title__c(
          Property__c = propId,
          Title_Order__c = titleOrder.Id
        )
      );
    }

    insert propertyTitles;

    toQuoteSetting.Next_Quote_ID__c = String.valueOf(
        Integer.valueOf(quoteId) + 1
      )
      .leftPad(quoteId.length(), '0');

    upsert toQuoteSetting;

    return JSON.serialize(
      new Map<String, String>{
        'result' => 'SUCCESS',
        'message' => 'Your Quote Request has been submitted. Your Quote ID is ' +
        qRequest.QuoteID
      }
    );
  }

  @AuraEnabled
  public static void quoteAccepted(Id toId, Id dealId, Id cdId) {
    try {
      Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
      Set<String> propFields = schemaMap.get('Property__c')
        .getDescribe()
        .fields.getMap()
        .keySet();
      Set<String> toFields = schemaMap.get('Title_Order__c')
        .getDescribe()
        .fields.getMap()
        .keySet();

      ContentVersion cv = queryCv(cdId);

      String queryString =
        'SELECT Deal__r.Current_Loan_Amount__c,' +
        String.join(new List<String>(toFields), ',') +
        ',(SELECT Id, Property__c, Property__r.' +
        String.join(new List<String>(propFields), ',Property__r.');

      queryString +=
        'FROM Property_Titles__r) FROM Title_Order__c WHERE Id =' +
        toId +
        ' ORDER BY Quote_ID__c';

      Title_Order__c titleOrder = Database.query(queryString);

      Map<Id, List<Property__c>> parentChildMap = new Map<Id, List<Property__c>>();
      List<Property__c> props = new List<Property__c>();

      Map<Id, Property__c> childProps = new Map<Id, Property__c>(
        [
          SELECT
            Id,
            (
              SELECT Id, Name, City__c, County__c, State__c, ZipCode__c
              FROM Properties__r
            )
          FROM Property__c
          WHERE Deal__c = :dealId AND Is_Parent__c = TRUE
        ]
      );

      Opportunity deal = queryDealContacts(dealId);

      for (Property_Title__c pt : titleOrder.Property_Titles__r) {
        Property__c p = pt.Property__r;

        props.add(p);

        if (
          childProps.containsKey(pt.Property__c) &&
          childProps.get(pt.Property__c).Properties__r != null &&
          childProps.get(pt.Property__c).Properties__r.size() > 0
        ) {
          parentChildMap.put(
            pt.Property__c,
            childProps.get(pt.Property__c).Properties__r
          );
        }
      }

      ServiceLinkAPI.QuoteAccepted qR = new ServiceLinkAPI.QuoteAccepted(
        titleOrder,
        cv,
        props,
        parentChildMap,
        deal
      );

      ServiceLinkAPI.performRequest('QuoteAccepted', JSON.serialize(qR));

      update new Title_Order__c(Id = toId, Status__c = 'Quote Accepted');
    } catch (Exception e) {
      System.debug(e.getMessage());
      System.debug(e.getLineNumber());
      System.debug(e.getStackTraceString());
      throw new AuraHandledException(e.getMessage() + ' ' + e.getLineNumber());
    }
  }

  @AuraEnabled
  public static void loanPortfolioChangeRequest(
    Id titleOrderId,
    Id dealId,
    Id cdId,
    List<Id> ptIds,
    Map<String, Id> dealContactIds, // Contact Type => Deal Contact ID,
    Map<String, Id> userIds // Contact Type => userID
  ) {
    try {
      Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
      Set<String> propFields = schemaMap.get('Property__c')
        .getDescribe()
        .fields.getMap()
        .keySet();
      Set<String> toFields = schemaMap.get('Title_Order__c')
        .getDescribe()
        .fields.getMap()
        .keySet();

      ContentVersion cv = queryCv(cdId);

      String queryString =
        'SELECT Deal__r.Current_Loan_Amount__c, ' +
        String.join(new List<String>(toFields), ',');

      if (ptIds.size() > 0) {
        queryString +=
          ',(SELECT Id, Property__c, Property__r.' +
          String.join(new List<String>(propFields), ',Property__r.') +
          ' FROM Property_Titles__r WHERE Id IN (\'' +
          String.join(ptIds, '\',\'') +
          '\'))';
      }

      queryString +=
        ' FROM Title_Order__c WHERE Id =\'' +
        titleOrderId +
        '\' ORDER BY Quote_ID__c';

      Title_Order__c titleOrder = Database.query(queryString);

      List<Property__c> props = new List<Property__c>();
      Map<Id, List<Property__c>> parentChildMap = new Map<Id, List<Property__c>>();
      Map<Id, Property__c> childProps = new Map<Id, Property__c>();
      Map<String, Deal_Contact__c> dealContactAndTypeMap = new Map<String, Deal_Contact__c>();
      Map<String, User> userAndTypeMap = new Map<String, User>();

      if (dealContactIds.size() > 0) {
        Map<Id, Deal_Contact__c> dealContactMap = queryDealContactsMap(
          dealContactIds.values()
        );

        for (String type : dealContactIds.keySet()) {
          dealContactAndTypeMap.put(
            type,
            dealContactMap.get(dealContactIds.get(type))
          );
        }
      }

      if (userIds.size() > 0) {
        Map<Id, User> usersMap = queryUsersMap(userIds.values());

        for (String type : userIds.keySet()) {
          userAndTypeMap.put(type, usersMap.get(userIds.get(type)));
        }
      }

      if (
        ptIds.size() > 0 &&
        titleOrder.Property_Titles__r != null &&
        titleOrder.Property_Titles__r.size() > 0
      ) {
        childProps = new Map<Id, Property__c>(
          [
            SELECT
              Id,
              (
                SELECT Id, Name, City__c, County__c, State__c, ZipCode__c
                FROM Properties__r
              )
            FROM Property__c
            WHERE Deal__c = :dealId AND Is_Parent__c = TRUE
          ]
        );
        for (Property_Title__c pt : titleOrder.Property_Titles__r) {
          props.add(pt.Property__r);

          if (
            childProps.containsKey(pt.Property__c) &&
            childProps.get(pt.Property__c).Properties__r != null &&
            childProps.get(pt.Property__c).Properties__r.size() > 0
          ) {
            parentChildMap.put(
              pt.Property__c,
              childProps.get(pt.Property__c).Properties__r
            );
          }
        }
      }

      ServiceLinkAPI.LoanPortfolioChangeRequest qR = new ServiceLinkAPI.LoanPortfolioChangeRequest(
        titleOrder,
        cv,
        props,
        parentChildMap,
        dealContactAndTypeMap,
        userAndTypeMap
      );

      ServiceLinkAPI.performRequest(
        'LoanPortfolioChangeRequest',
        JSON.serialize(qr)
      );

      update new Title_Order__c(
        Id = titleOrderId,
        Status__c = 'Loan Portfolio Change Submitted'
      );
    } catch (Exception e) {
      System.debug(e.getMessage());
      System.debug(e.getLineNumber());
      System.debug(e.getStackTraceString());
      throw new AuraHandledException(e.getMessage() + ' ' + e.getLineNumber());
    }
  }

  public static String orderChangeRequest(Id ptId) {
    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    Set<String> propTitleFields = schemaMap.get('Property_Title__c')
      .getDescribe()
      .fields.getMap()
      .keySet();
    Set<String> propFields = schemaMap.get('Property__c')
      .getDescribe()
      .fields.getMap()
      .keySet();
    Set<String> toFields = schemaMap.get('Title_Order__c')
      .getDescribe()
      .fields.getMap()
      .keySet();

    String queryString =
      'SELECT ' + String.join(new List<String>(propTitleFields), ',');
    queryString +=
      ',Property__r.' +
      String.join(new List<String>( propFields ), ',Property__r.');
    queryString +=
      ',Title_Order__r.' +
      String.join(new List<String>( toFields ), ', Title_Order__r.');
    queryString += ' FROM Property_Title__c WHERE Id=\'' + ptId + '\'';

    Property_Title__c pt = Database.query(queryString);
    String incTransacId = (pt.Title_Order__c +
      '-' +
      System.now() +
      '-OIQ')
      .replaceAll(':', '')
      .deleteWhitespace();

    ServiceLinkAPI.OrderChangeRequest ocr = new ServiceLinkAPI.OrderChangeRequest(
      pt,
      incTransacId
    );

    try {
      ServiceLinkAPI.performRequest('OrderChangeRequest', JSON.serialize(ocr));


      update new Property_Title__c(Id = ptId, Status__c = 'Order Change Requested');

      return JSON.serialize(
        new Map<String, String>{
          'result' => 'SUCCESS',
          'message' => 'Your Change Request has been submitted.'
        }
      );
    } catch (Exception err) {
      return err.getMessage();
    }
  }

  @AuraEnabled
  public static void cancelRequest(List<Id> titleOrderIds) {
    try {
      List<ServiceLinkAPI.CancelRequest> cancelReqs = new List<ServiceLinkAPI.CancelRequest>();
      List<Title_Order__c> tos = [
        SELECT
          Id,
          Bulk_Project_Order_Num__c,
          Incoming_Transaction_Id__c,
          Loan_Number__c,
          Status__c,
          Deal__c
        FROM Title_Order__c
        WHERE Id IN :titleOrderIds
      ];
      String transacId;
      for (Title_Order__c to : tos) {
        transacId = (to.Deal__c +
          '-' +
          System.now() +
          '-CRQ')
          .replaceAll(':', '')
          .deleteWhitespace();
        to.Incoming_Transaction_Id__c = transacId;
        to.Status__c = 'Cancel Requested';
        cancelReqs.add(new ServiceLinkAPI.CancelRequest(to));
      }

      for (ServiceLinkAPI.CancelRequest cr : cancelReqs) {
        ServiceLinkAPI.performRequest('CancelRequest', JSON.serialize(cr));
      }

      update tos;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public static String orderInquiry(
    Title_Order__c to,
    Id cdId,
    String inquiryType,
    String comments,
    Id dealId,
    List<Id> propIds,
    List<Id> propTitleIds
  ) {
    ContentVersion cv = new ContentVersion();
    if (inquiryType == 'REVISEDQUO') {
      cv = queryCv(cdId);
    }

    String incTransacId = (dealId +
      '-' +
      System.now() +
      '-OIQ')
      .replaceAll(':', '')
      .deleteWhitespace();

    ServiceLinkAPI.OrderInquiry orderInq = new ServiceLinkAPI.OrderInquiry(
      to,
      cv,
      inquiryType,
      comments,
      incTransacId,
      propTitleIds.size() > 0
        ? [
            SELECT Id, Property__c, Property__r.Asset_ID__c, OrderNumber__c
            FROM Property_Title__c
            WHERE Id = :propTitleIds[0]
          ]
        : new Property_Title__c()
    );

    try {
      ServiceLinkAPI.performRequest('OrderInquiry', JSON.serialize(orderInq));
    } catch (Exception ex) {
      return ex.getMessage();
    }

    update new Title_Order__c(
      Id = to.Id,
      Has_Order_Inquiry__c = true,
      Incoming_Transaction_Id__c = incTransacId
    );

    if (inquiryType == 'REVISEDQUO' && propIds.size() > 0) {
      List<Property_Title__c> propTitles = new List<Property_Title__c>();

      for (Id pId : propIds) {
        propTitles.add(
          new Property_Title__c(Title_Order__c = to.Id, Property__c = pId)
        );
      }

      insert propTitles;
    }

    return JSON.serialize(
      new Map<String, String>{
        'result' => 'SUCCESS',
        'message' => 'Your Order Inquiry has been successfully submitted'
      }
    );
  }

  public static Map<Id, Deal_Contact__c> queryDealContactsMap(
    List<Id> dealContactIds
  ) {
    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();

    List<String> contactFields = new List<String>(
      schemaMap.get('Contact').getDescribe().fields.getMap().keySet()
    );
    List<String> dealContactFields = new List<String>(
      schemaMap.get('Deal_Contact__c').getDescribe().fields.getMap().keySet()
    );

    dealContactFields.addAll(new Set<String>{ 'Account__r.Name' });

    String queryString = 'SELECT ';
    queryString +=
      String.join(dealContactFields, ',') +
      ',Contact__r.' +
      String.join(contactFields, ',Contact__r.');
    queryString += ' FROM Deal_Contact__c WHERE Id IN :dealContactIds';

    return new Map<Id, Deal_Contact__c>(
      (List<Deal_Contact__c>) Database.query(queryString)
    );
  }

  public static Map<Id, User> queryUsersMap(List<Id> userIds) {
    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();

    List<String> userFields = new List<String>(
      schemaMap.get('User').getDescribe().fields.getMap().keySet()
    );

    String queryString =
      'SELECT ' +
      String.join(userFields, ',') +
      ' FROM User WHERE Id IN :userIds';

    return new Map<Id, User>((List<User>) Database.query(queryString));
  }

  public static Opportunity queryDealContacts(Id dealId) {
    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    List<String> userFields = new List<String>(
      schemaMap.get('User').getDescribe().fields.getMap().keySet()
    );
    Set<String> contactFields = schemaMap.get('Contact')
      .getDescribe()
      .fields.getMap()
      .keySet();
    List<String> dealContactFields = new List<String>(
      schemaMap.get('Deal_Contact__c').getDescribe().fields.getMap().keySet()
    );

    dealContactFields.addAll(new Set<String>{ 'Account__r.Name' });

    for (String cf : contactFields) {
      dealContactFields.add('Contact__r.' + cf);
    }

    String queryString = 'SELECT Id,';
    queryString += 'Closer__r.' + String.join(userFields, ', Closer__r.');
    queryString +=
      ',Underwriter__r.' + String.join(userFields, ', Underwriter__r.');
    queryString +=
      ',Loan_Coordinator__r.' +
      String.join(userFields, ',Loan_Coordinator__r.');
    queryString += ',Owner.' + String.join(userFields, ',Owner.');
    queryString +=
      ',(SELECT ' +
      String.join(dealContactFields, ',') +
      ' FROM Deal_Contacts__r WHERE Contact__r.Name != null AND Vendor_Type__c IN (\'Lender Legal Counsel\', \'Lender Local Legal Counsel	\'))';
    queryString += ' FROM Opportunity WHERE Id=\'' + dealId + '\'';

    return Database.query(queryString);
  }

  public static Opportunity queryBorrowers(Id dealId) {
    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    Set<String> contactFields = schemaMap.get('Contact')
      .getDescribe()
      .fields.getMap()
      .keySet();
    Set<String> accountFields = schemaMap.get('Account')
      .getDescribe()
      .fields.getMap()
      .keySet();
    List<String> dealContactFields = new List<String>(
      schemaMap.get('Deal_Contact__c').getDescribe().fields.getMap().keySet()
    );

    for (String af : accountFields) {
      dealContactFields.add('Account__r.' + af);
    }

    for (String cf : contactFields) {
      dealContactFields.add('Contact__r.' + cf);
    }

    String queryString = 'SELECT Id,';
    queryString +=
      '(SELECT ' +
      String.join(dealContactFields, ',') +
      ' FROM Deal_Contacts__r WHERE (Contact__r.Name != null OR Account__r.Name != null) AND Entity_Type__c INCLUDES (\'Borrower\'))';
    queryString += ' FROM Opportunity WHERE Id=\'' + dealId + '\'';

    return Database.query(queryString);
  }

  @future
  public static void performDmlFuture(String sobjectJson) {
    List<Title_Order__c> titleOrders = (List<Title_Order__c>) JSON.deserialize(
      sobjectJson,
      List<Title_Order__c>.class
    );
    upsert titleOrders;
  }

  public class TitleOrderObject {
    public String titleOrderId { get; set; }
    public String titleVendor { get; set; }
    public DateTime orderDate { get; set; }
    public Date titleCompleted { get; set; }
    public Date originalTitleCleared { get; set; }
    public DateTime allClearedToClose { get; set; }
    public String titleOrderStatus { get; set; }
    public String comments { get; set; }
    public Boolean showCheckbox { get; set; }
    public Boolean showURL { get; set; }
    public String linkUrl { get; set; }
    public String errorMessage { get; set; }
    public Boolean hasOrderInquiry { get; set; }
    public Boolean hasOrderInquiryResponse { get; set; }
  }

  public class ReturnObject {
    public String propertyId { get; set; }
    public String address { get; set; }
    public String city { get; set; }
    public String propertyType { get; set; }
    public Decimal noOfUnits { get; set; }
    public String propertyStatus { get; set; }
    public String linkUrl { get; set; }
    public List<TitleOrderObject> titleOrders { get; set; }

    public void parseData(
      Property__c property,
      List<Title_Order__c> titleOrders
    ) {
      if (property != null) {
        this.propertyId = property.Id;
        this.address = property.Name;
        this.city = property.City__c;
        this.propertyType = property.Property_Type__c;
        this.noOfUnits = property.Number_of_Units__c;
        this.propertyStatus = property.Status__c;
        this.linkUrl =
          System.URL.getSalesforceBaseUrl().toExternalForm() +
          '/' +
          property.Id;
      }
      List<TitleOrderObject> titleOrdersLocal = new List<TitleOrderObject>();
      if (titleOrders != null && titleOrders.size() > 0) {
        for (Title_Order__c titleOrder : titleOrders) {
          TitleOrderObject titleOrderval = new TitleOrderObject();
          titleOrderval.titleOrderId = titleOrder.Id;
          titleOrderval.titleOrderStatus = titleOrder.Status__c;
          titleOrderval.titleVendor = String.isNotEmpty(
              titleOrder.Title_Vendor__c
            )
            ? titleOrder.Title_Vendor__c
            : null;
          titleOrderval.orderDate = titleOrder.Order_Opened_Date__c != null
            ? titleOrder.Order_Opened_Date__c
            : null;
          titleOrderval.titleCompleted = titleOrder.Title_Complete_Date__c !=
            null
            ? titleOrder.Title_Complete_Date__c
            : null;
          titleOrderval.originalTitleCleared = titleOrder.Original_Title_Cleared_Date__c !=
            null
            ? titleOrder.Original_Title_Cleared_Date__c
            : null;
          titleOrderval.allClearedToClose = titleOrder.All_Cleared_To_Close_Date__c !=
            null
            ? titleOrder.All_Cleared_To_Close_Date__c
            : null;
          titleOrderval.comments = String.isNotEmpty(titleOrder.Comments__c)
            ? titleOrder.Comments__c
            : null;
          titleOrderval.showCheckbox = true;
          titleOrderval.showURL = true;
          titleOrderval.linkUrl =
            System.URL.getSalesforceBaseUrl().toExternalForm() +
            '/' +
            titleOrder.Id;
          titleOrderval.errorMessage = String.isNotEmpty(
              titleOrder.Error_Message__c
            )
            ? titleOrder.Error_Message__c
            : titleOrder.Error_Message__c;
          titleOrderval.hasOrderInquiry = titleOrder.Has_Order_Inquiry__c;
          titleOrderval.hasOrderInquiryResponse = titleOrder.Has_Order_Inquiry_Response__c;
          titleOrdersLocal.add(titleOrderval);
        }
      } else {
        TitleOrderObject titleOrder = new TitleOrderObject();
        titleOrder.titleOrderStatus = 'Unordered';
        titleOrder.showCheckbox = false;
        titleOrder.showURL = false;
        titleOrder.titleOrderId = property.Id;
        titleOrdersLocal.add(titleOrder);
      }
      this.titleOrders = titleOrdersLocal;
    }
  }
}