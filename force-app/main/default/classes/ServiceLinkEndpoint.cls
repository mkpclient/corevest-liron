@RestResource(urlMapping='/servicelink/*')
global without sharing class ServiceLinkEndpoint {
  public class ServiceLinkException extends Exception {
  }

  public static final Map<String, String> REQ_TO_DATEFIELD_MAP = new Map<String, String>{
    'CancelRequestConfirmation' => 'Cancelled_Date__c',
    'OrderChangeConfirmation' => 'Order_Change_Confirmation_Date__c',
    'OrderInquiryConfirmation' => 'Order_Inquiry_Confirmation_Date__c',
    'DocumentSubmissionConfirm' => 'Document_Submission_Confirmation_Date__c',
    'QuoteAcceptedConfirmation' => 'Quote_Accepted_Confirmation_Date__c',
    'LoanPortfolioChangeConfirm' => 'Loan_Portfolio_Confirmation_Date__c'
  };

  //these requests send a new order number so it won't be possible to query them just yet
  public static final List<String> NEW_ORDER_NUM_REQS = new List<String>{
    'OrderConfirmation'
  };

  public static final List<String> NEW_BULK_NUM = new List<String>{
    'QuoteReceivedConfirm'
  };

  @HttpPost
  global static void postMethod() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    Blob body = req.requestBody;
    String requestString = body.toString();
    res.addHeader('Content-Type', 'application/json');
    Map<String, String> resMap = new Map<String, String>();
    try {
      Map<String, ServiceLinkResponse> respMap = (Map<String, ServiceLinkResponse>) JSON.deserialize(
        requestString,
        Map<String, ServiceLinkResponse>.class
      );
      String reqType = new List<String>(respMap.keySet())[0];
      resMap.put('RequestType', reqType);

      List<Title_Order__c> titleOrders = queryTitleOrders(
        respMap.values()[0],
        NEW_ORDER_NUM_REQS.contains(reqType),
        NEW_BULK_NUM.contains(reqType)
      );
      if (titleOrders.size() == 0) {
        throwNullError();
      }

      switch on reqType {
        when 'QuoteReceivedConfirm' {
          resMap.put(
            'LoanNumber',
            processQuoteReceivedConfirm(respMap.values()[0], titleOrders[0])
          );
        }
        when 'QuoteResponse' {
          resMap.put(
            'LoanNumber',
            processQuoteResponse(respMap.values()[0], titleOrders[0])
          );
        }
        when 'OrderInquiryResponse' {
          resMap.put(
            'LoanNumber',
            processOrderInquiry(respMap.values()[0], titleOrders[0])
          );
        }
        when 'OrderConfirmation' {
          resMap.put(
            'LoanNumber',
            processOrderConfirmation(respMap.values()[0], titleOrders[0])
          );
        }
        when 'AllTitlesOrdered' {
          resMap.put(
            'LoanNumber',
            processAllQuotesOrdered(respMap.values()[0], titleOrders[0])
          );
        }
        when 'TitleCompleted',
          'TitleComplete', // servicelink sent inconsistent requests documentation
          'AllTitlesCompleted',
          'OriginalTitleCleared',
          'OriginalAllTitlesCleared' {
          resMap.put(
            'LoanNumber',
            processTitles(respMap.values()[0], titleOrders[0])
          );
        }
        when 'Document' {
          resMap.put(
            'LoanNumber',
            processDocumentReceived(respMap.values()[0], titleOrders[0])
          );
        }
        when 'TaxesOrdered',
          'AllTaxesOrdered',
          'TaxesCompleted',
          'AllTaxesCompleted' {
          resMap.put(
            'LoanNumber',
            processTaxes(respMap.values()[0], titleOrders[0])
          );
        }
        when 'HOAExists',
          'HOAOrdered',
          'AllHOAOrdered',
          'HOACompleted',
          'AllHOACompleted' {
          resMap.put(
            'LoanNumber',
            processHoa(respMap.values()[0], titleOrders[0], reqType)
          );
        }
        when 'PayOffExists',
          'PayoffOrdered',
          'AllPayoffsOrdered',
          'PayoffCompleted',
          'AllPayoffsCompleted' {
          resMap.put(
            'LoanNumber',
            processPayoff(respMap.values()[0], titleOrders[0], reqType)
          );
        }
        when 'ProblemCurativeItem' {
          resMap.put(
            'LoanNumber',
            processProblemCurativeItem(respMap.values()[0], titleOrders[0])
          );
        }
        when 'TitleUnCleared', 'LatestAllTitlesCleared', 'TitleReCleared' {
          resMap.put(
            'LoanNumber',
            processTitleClearing(respMap.values()[0], titleOrders[0])
          );
        }
        when 'DeedsOrdered', 'UnExecutedDeedsSent', 'AllClearedToClose' {
          resMap.put(
            'LoanNumber',
            processDeeds(respMap.values()[0], titleOrders[0])
          );
        }
        when 'LoanDocsReceived',
          'SignedDocsScannedDate',
          'ScannedDocsForwarded',
          'DocsEstArrivalToLender',
          'SignedDocsReceivedAtEscrow',
          'FileFundedDate' {
          resMap.put(
            'LoanNumber',
            processDocsDates(respMap.values()[0], titleOrders[0])
          );
        }
        when 'RecordingTracking' {
          resMap.put(
            'LoanNumber',
            processRecordingTracking(respMap.values()[0], titleOrders)
          );
        }
        when 'SigningAppointment' {
          resMap.put(
            'LoanNumber',
            processSigningAppointment(respMap.values()[0], titleOrders[0])
          );
        }
        when else {
          if (REQ_TO_DATEFIELD_MAP.keySet().contains(reqType)) {
            resMap.put(
              'LoanNumber',
              processRequestConfirmations(
                respMap.values()[0],
                titleOrders[0],
                reqType
              )
            );
          } else {
            ServiceLinkException err = new ServiceLinkException();
            err.setMessage('Unable to identify request ' + reqType + '.');
            throw err;
          }
        }
      }

      res.statusCode = 201;
      resMap.put('status', 'success');
      res.responseBody = Blob.valueOf(JSON.serialize(resMap));
    } catch (Exception err) {
      res.statusCode = 400;
      Map<String, String> errMap = new Map<String, String>{
        'status' => 'error',
        'message' => err.getMessage(),
        'lineNumber' => String.valueOf(err.getLineNumber()),
        'stackTrace' => err.getStackTraceString(),
        'exceptionType' => err.getTypeName()
      };
      if (err.getTypeName().containsIgnoreCase('dml')) {
        Integer numErrors = err.getNumDml();
        String fieldNames = '';
        for (Integer i = 0; i < numErrors; i++) {
          fieldNames += err.getDmlFieldNames(i) + ', ';
        }
        errMap.put('fieldNames', fieldNames);
      }

      res.responseBody = Blob.valueOf(JSON.serialize(errMap));
    }
    // List<String> params = Restcontext.request.requestURI.split('/');
  }

  public static String processRecordingTracking(
    ServiceLinkResponse resp,
    List<Title_Order__c> titleOrders
  ) {
    Record_Tracking__c rt = new Record_Tracking__c();
    rt.Title_Order__c = titleOrders[0].Id;
    rt.RecId__c = resp.RecId;
    rt.Recording_Date__c = parseDateString(resp.RecordingDate);
    rt.Recording_Order_Number__c = resp.RecordingOrderNumber;
    rt.Recording_State__c = resp.RecordingState;
    rt.Recording_County__c = resp.RecordingCounty;
    rt.Recording_Type__c = resp.RecordingType;
    rt.Recording_Desc__c = resp.RecordingDesc;
    rt.Instrument_Number__c = resp.InstrumentNumber;
    rt.Book_Number__c = resp.BookNumber;
    rt.Page_Number__c = resp.PageNumber;
    rt.Grantor__c = resp.Grantor;
    rt.Grantee__c = resp.Grantee;
    rt.Mortgagee__c = resp.Mortgagee;
    rt.Mortgagor__c = resp.Mortgagor;

    upsert rt RecId__c;

    return resp.LoanNumber;
  }

  public static String processSigningAppointment(
    ServiceLinkResponse resp,
    Title_Order__c to
  ) {
    Signing_Appointment__c sAppt = new Signing_Appointment__c();
    List<Signing_Attendee__c> sAtts = new List<Signing_Attendee__c>();
    List<String> attendeeNames = new List<String>();

    for (SigningAttendee sa : resp.Attendees) {
      if (sa.Name != null && String.isNotEmpty(sa.Name)) {
        attendeeNames.add(sa.Name);
      }
    }

    List<Deal_Contact__c> dealContacts = [
      SELECT Id, Contact__r.Name
      FROM Deal_Contact__c
      WHERE Contact__r.Name IN :attendeeNames AND Deal__c = :to.Deal__c
    ];

    sAppt.RecId__c = resp.RecId;
    sAppt.Appointment_Status__c = resp.AppointmentStatus;
    sAppt.Scheduled_Signing_Date__c = resp.ScheduledSigningDate != null &&
      String.isNotEmpty(resp.ScheduledSigningDate)
      ? DateTime.valueOf(resp.ScheduledSigningDate.replace('T', ' '))
      : null;
    sAppt.Cancelled_Date__c = parseDateString(resp.CancelledDate);
    sAppt.Closed_Date__c = parseDateString(resp.ClosedDate);
    SigningLocation sl = resp.SigningLocation;
    sAppt.Signing_Address1__c = sl.Address1;
    sAppt.Signing_Address2__c = sl.Address2;
    sAppt.Signing_City__c = sl.City;
    sAppt.Signing_State__c = sl.State;
    sAppt.Signing_Zip_Code__c = sl.Zipcode;
    sAppt.Title_Order__c = to.Id;

    upsert sAppt RecId__c;

    if (dealContacts.size() > 0) {
      for (Deal_Contact__c dc : dealContacts) {
        Signing_Attendee__c sAtt = new Signing_Attendee__c();
        sAtt.Signing_Appointment__c = sAppt.Id;
        sAtt.Deal_Contact__c = dc.Id;
        sAtt.Unique_Id__c = dc.Id + '-' + sAppt.Id;
        sAtt.Name = dc.Contact__r.Name;
        sAtts.add(sAtt);
      }

      upsert sAtts Unique_Id__c;
    }
    return resp.LoanNumber;
  }

  public static String processDocsDates(
    ServiceLinkResponse resp,
    Title_Order__c to
  ) {
    Date ldrDate = parseDateString(resp.LoanDocsReceivedDate);
    Date sdsDate = parseDateString(resp.SignedDocsScannedDate);
    Date sdfDate = parseDateString(resp.ScannedDocsForwardedDate);
    Date deaDate = parseDateString(resp.DocsEstArrivalDate);
    Date sdrDate = parseDateString(resp.SignedDocsReceivedDate);
    Date ffDate = parseDateString(resp.FileFundedDate);

    to.Loan_Docs_Received_Date__c = ldrDate != null
      ? ldrDate
      : to.Loan_Docs_Received_Date__c;
    to.Signed_Docs_Scanned_Date__c = sdsDate != null
      ? sdsDate
      : to.Signed_Docs_Scanned_Date__c;
    to.Scanned_Docs_Forwarded_Date__c = sdfDate != null
      ? sdfDate
      : to.Scanned_Docs_Forwarded_Date__c;
    to.Docs_Est_Arrival_Date__c = deaDate != null
      ? deaDate
      : to.Docs_Est_Arrival_Date__c;
    to.Signed_Docs_Received_Date__c = sdrDate != null
      ? sdrDate
      : to.Signed_Docs_Received_Date__c;
    to.File_Funded_Date__c = ffDate != null ? ffDate : to.File_Funded_Date__c;
    update to;

    return resp.LoanNumber;
  }

  public static String processDeeds(
    ServiceLinkResponse resp,
    Title_Order__c to
  ) {
    Date doDate = parseDateString(resp.DeedsOrderedDate);
    Date uedsDate = parseDateString(resp.UnExecDeedSentDate);
    Date actcDate = parseDateString(resp.AllClearedToCloseDate);

    to.Deeds_Ordered_Date__c = resp.DeedsOrderedDate != null
      ? doDate
      : to.Deeds_Ordered_Date__c;
    to.Un_Exec_Deed_Sent_Date__c = resp.UnExecDeedSentDate != null
      ? uedsDate
      : to.Un_Exec_Deed_Sent_Date__c;
    to.All_Cleared_To_Close_Date__c = resp.AllClearedToCloseDate != null
      ? actcDate
      : to.All_Cleared_To_Close_Date__c;

    update to;

    return resp.LoanNumber;
  }

  public static String processTitleClearing(
    ServiceLinkResponse resp,
    Title_Order__c to
  ) {
    Date ltcDate = parseDateString(resp.LatestTitleClearedDate);
    Date latcDate = parseDateString(resp.LatestAllTitlesClearedDate);

    Boolean isIndividualLevel =
      String.isNotBlank(resp.OrderNumber) &&
      resp.LatestTitleClearedDate != null;

    if (isIndividualLevel) {
      Property_Title__c pt = new Property_Title__c(
        OrderNumber__c = resp.OrderNumber,
        LatestTitleClearedDate__c = parseDateString(resp.LatestTitleClearedDate)
      );

      upsert pt OrderNumber__c;
    } else {
      to.Latest_All_Titles_Cleared_Date__c = parseDateString(
        resp.LatestAllTitlesClearedDate
      );
      update to;
    }

    return resp.LoanNumber;
  }

  public static String processProblemCurativeItem(
    ServiceLinkResponse resp,
    Title_Order__c to
  ) {
    Loan_Status__c loanNote = new Loan_Status__c();
    loanNote.Deal__c = to.Deal__c;
    loanNote.Title_Order__c = to.Id;
    loanNote.Servicelink_Item_Id__c = resp.ItemId;
    loanNote.Servicelink_Item_Type__c = resp.ItemType;
    loanNote.Subject__c = resp.ItemType + ' - ' + resp.ItemTypeDesc;
    loanNote.Comment__c =
      resp.ItemNoteText +
      '\nCannot Cure Reasons: ' +
      resp.CannotCureReasons;

    if (String.isNotBlank(resp.OrderNumber)) {
      loanNote.Property_Title__r.OrderNumber__c = resp.OrderNumber;
    }

    upsert loanNote Servicelink_Item_Id__c;

    return resp.LoanNumber;
  }

  public static String processPayoff(
    ServiceLinkResponse resp,
    Title_Order__c to,
    String reqType
  ) {
    Boolean isIndividualLevel =
      String.isNotBlank(resp.OrderNumber) &&
      (reqType == 'PayOffExists' ||
      resp.PayoffOrderedDate != null ||
      resp.PayoffCompletedDate != null);

    if (isIndividualLevel) {
      Property_Title__c pt = new Property_Title__c(
        OrderNumber__c = resp.OrderNumber
      );

      if (reqType == 'PayOffExists') {
        pt.PayoffExists__c = resp.PayoffExists == 'Y';
      } else if (resp.HOAOrderedDate != null) {
        pt.PayoffOrderedDate__c = parseDateString(resp.PayoffOrderedDate);
      } else if (resp.HOACompletedDate != null) {
        pt.PayoffCompletedDate__c = parseDateString(resp.PayoffCompletedDate);
      }

      upsert pt OrderNumber__c;
    } else {
      if (resp.AllPayoffsOrderedDate != null) {
        to.All_Payoffs_Ordered_Date__c = parseDateString(
          resp.AllPayoffsOrderedDate
        );
      } else if (resp.AllPayoffsCompletedDate != null) {
        to.All_Payoffs_Completed_Date__c = parseDateString(
          resp.AllPayoffsCompletedDate
        );
      }
      update to;
    }

    return resp.LoanNumber;
  }

  public static String processHoa(
    ServiceLinkResponse resp,
    Title_Order__c to,
    String reqType
  ) {
    Boolean isIndividualLevel =
      String.isNotBlank(resp.OrderNumber) &&
      (reqType == 'HOAExists' ||
      resp.HOAOrderedDate != null ||
      resp.HOACompletedDate != null);

    if (isIndividualLevel) {
      Property_Title__c pt = new Property_Title__c(
        OrderNumber__c = resp.OrderNumber
      );

      if (reqType == 'HOAExists') {
        pt.HOAExists__c = resp.HOAExists == 'Y';
      } else if (resp.HOAOrderedDate != null) {
        pt.HOAOrderedDate__c = parseDateString(resp.HOAOrderedDate);
      } else if (resp.HOACompletedDate != null) {
        pt.HOACompletedDate__c = parseDateString(resp.HOACompletedDate);
      }

      upsert pt OrderNumber__c;
    } else {
      if (resp.AllHOAOrderedDate != null) {
        to.All_HOA_Ordered_Date__c = parseDateString(resp.AllHOAOrderedDate);
      } else if (resp.AllHOACompletedDate != null) {
        to.All_HOA_Completed_Date__c = parseDateString(
          resp.AllHOACompletedDate
        );
      }
      update to;
    }

    return resp.LoanNumber;
  }

  public static String processTaxes(
    ServiceLinkResponse resp,
    Title_Order__c to
  ) {
    Boolean isIndividualLevel =
      String.isNotBlank(resp.OrderNumber) &&
      (resp.TaxesOrderedDate != null ||
      resp.TaxesCompletedDate != null);

    if (isIndividualLevel) {
      Property_Title__c pt = new Property_Title__c(
        OrderNumber__c = resp.OrderNumber
      );

      if (resp.TaxesOrderedDate != null) {
        pt.TaxesOrderedDate__c = parseDateString(resp.TaxesOrderedDate);
      } else if (resp.TaxesCompletedDate != null) {
        pt.TaxesCompletedDate__c = parseDateString(resp.TaxesCompletedDate);
      }

      upsert pt OrderNumber__c;
    } else {
      if (resp.AllTaxesCompletedDate != null) {
        to.All_Taxes_Completed_Date__c = parseDateString(
          resp.AllTaxesCompletedDate
        );
      } else if (resp.AllTaxesOrderedDate != null) {
        to.All_Taxes_Ordered_Date__c = parseDateString(
          resp.AllTaxesOrderedDate
        );
      }

      update to;
    }

    return resp.LoanNumber;
  }

  public static String processDocumentReceived(
    ServiceLinkResponse resp,
    Title_Order__c to
  ) {
    Boolean isIndividualLevel = String.isNotBlank(resp.OrderNumber);
    ServiceLinkAPI.TitleDocument doc = new ServiceLinkAPI.TitleDocument();
    doc.Base64FileData = resp.Base64FileData;
    doc.DocumentName = resp.DocumentName;
    doc.DocumentType = Servicelink_Schema__mdt.getInstance(
          resp.DocumentType.replaceAll('-', '_')
        )
        ?.Full_Name__c != null
      ? Servicelink_Schema__mdt.getInstance(
            resp.DocumentType.replaceAll('-', '_')
          )
          .Full_Name__c
      : resp.DocumentType;
    doc.Format = resp.Format;
    doc.Size = resp.Size;

    Property_Title__c pt = new Property_Title__c();

    if (isIndividualLevel) {
      pt = [
        SELECT Id, Property__c
        FROM Property_Title__c
        WHERE OrderNumber__c = :resp.OrderNumber
      ];
    }

    ContentVersion cv = createContentVersion(
      new List<ServiceLinkAPI.TitleDocument>{ doc },
      (isIndividualLevel && pt?.Property__c != null
        ? pt.Property__c
        : to.Deal__c)
    )[0];
    List<Deal_Document__c> dealDocs = new List<Deal_Document__c>();
    Deal_Document__c dealDoc = createDealDocument(
      doc,
      cv,
      to,
      isIndividualLevel && pt?.Property__c != null ? pt.Property__c : null
    );
    dealDoc.Service_Link_Id__c = resp.DocumentID + '-' + to.Id;
    dealDocs.add(dealDoc);

    upsert dealDoc Service_Link_Id__c;

    return resp.LoanNumber;
  }

  public static String processTitles(
    ServiceLinkResponse resp,
    Title_Order__c to
  ) {
    Boolean isIndividualLevel =
      String.isNotBlank(resp.OrderNumber) &&
      (resp.TitleCompleteDate != null ||
      resp.OriginalTitleClearedDate != null);

    if (isIndividualLevel) {
      Property_Title__c pt = new Property_Title__c(
        OrderNumber__c = resp.OrderNumber
      );
      if (resp.TitleCompleteDate != null) {
        pt.TitleCompleteDate__c = parseDateString(resp.TitleCompleteDate);
      } else if (resp.OriginalTitleClearedDate != null) {
        pt.OriginalTitleClearedDate__c = parseDateString(
          resp.OriginalTitleClearedDate
        );
      }

      upsert pt OrderNumber__c;
    } else {
      if (resp.AllTitlesCompletedDate != null) {
        to.All_Titles_Complete_Date__c = parseDateString(
          resp.AllTitlesCompletedDate
        );
      } else if (resp.OriginalAllTitlesClearedDate != null) {
        to.Original_All_Titles_Cleared_Date__c = parseDateString(
          resp.OriginalAllTitlesClearedDate
        );
      }
      update to;
    }

    return resp.LoanNumber;
  }

  public static String processAllQuotesOrdered(
    ServiceLinkResponse resp,
    Title_Order__c titleOrder
  ) {
    Title_Order__c updatedTo = new Title_Order__c(Id = titleOrder.Id);
    Boolean wasUpdated = false;
    if (String.isNotEmpty(resp.AllTitlesOrderedDate)) {
      Date updATODate = parseDateString(resp.AllTitlesOrderedDate);
      if (updATODate != titleOrder.All_Titles_Ordered_Date__c) {
        updatedTo.All_Titles_Ordered_Date__c = updATODate;
      }
      updatedTo.Status__c = 'All Titles Ordered';
      wasUpdated = true;
    } else if (
      String.isEmpty(resp.AllTitlesOrderedDate) &&
      titleOrder.All_Titles_Ordered_Date__c != null
    ) {
      updatedTo.All_Titles_Ordered_Date__c = null;
      updatedTo.Status__c = 'Order Confirmed';
      wasUpdated = true;
    }

    if (wasUpdated) {
      update updatedTo;
    }
    return resp.LoanNumber;
  }

  public static String processOrderInquiry(
    ServiceLinkResponse ordInq,
    Title_Order__c titleOrder
  ) {
    Id cvParentId = titleOrder.Deal__c;
    Loan_Status__c note = new Loan_Status__c();
    Property_Title__c propTitle = new Property_Title__c();
    note.OrderInquiryId__c = ordInq.CustInqId;
    note.OrderInquiryNoteId__c = ordInq.NoteId;
    note.Title_Order__c = titleOrder.Id;
    note.Deal__c = titleOrder.Deal__c;
    note.Subject__c =
      'Title Order Inquiry ' + System.now().format('yyyy-MM-dd h:mm a');
    note.Comment__c = ordInq.NoteText;

    if (ordInq.OrderNumber != null && String.isNotEmpty(ordInq.OrderNumber)) {
      propTitle = [
        SELECT Id, Property__c
        FROM Property_Title__c
        WHERE OrderNumber__c = :ordInq.OrderNumber
      ];
      note.Property_Title__c = propTitle.Id;
    }

    insert note;

    if (String.isNotEmpty(ordInq.AssetID)) {
      cvParentId = propTitle?.Id != null ? propTitle.Id : titleOrder.Id;
    }

    List<ContentVersion> contentVersions = ordInq.Documents != null &&
      ordInq.Documents.size() > 0
      ? createContentVersion(ordInq.Documents, cvParentId)
      : new List<ContentVersion>();

    List<Deal_Document__c> dealDocs = new List<Deal_Document__c>();

    if (contentVersions.size() > 0) {
      Map<String, ServiceLinkAPI.TitleDocument> docMap = new Map<String, ServiceLinkAPI.TitleDocument>();
      for (ServiceLinkAPI.TitleDocument doc : ordInq.Documents) {
        docMap.put(doc.DocumentName, doc);
      }

      for (ContentVersion cv : contentVersions) {
        Deal_Document__c dd = createDealDocument(
          docMap.get(cv.PathOnClient),
          cv,
          titleOrder,
          propTitle?.Property__c != null ? propTitle.Property__c : null
        );
        dealDocs.add(dd);
      }
      insert dealDocs;
    }

    List<Title_Order__c> updatedTitleOrders = new List<Title_Order__c>();

    update new Title_Order__c(
      Has_Order_Inquiry_Response__c = true,
      Has_Order_Inquiry__c = false,
      Id = titleOrder.Id
    );

    return ordInq.LoanNumber;
  }

  public static String processRequestConfirmations(
    ServiceLinkResponse sl,
    Title_Order__c titleOrder,
    String reqType
  ) {
    Title_Order__c to = new Title_Order__c(Id = titleOrder.Id);
    List<Property_Title__c> propertyTitles = new List<Property_Title__c>();

    if (sl.Status == 'SUCCESS') {
      to.put(REQ_TO_DATEFIELD_MAP.get(reqType), (DateTime) System.now());

      if (reqType == 'CancelRequestConfirmation') {
        to.Status__c = 'Cancelled';
        propertyTitles.add(
          new Property_Title__c(
            Status__c = 'Cancelled',
            OrderNumber__c = sl.OrderNumber
          )
        );
      } else if (reqType == 'QuoteAcceptedConfirmation') {
        to.Status__c = 'Quote Accepted Confirmed';
      } else if (
        reqType == 'OrderChangeConfirmation' &&
        sl.OrderNumber != null &&
        String.isNotEmpty(sl.OrderNumber)
      ) {
        propertyTitles.add(
          new Property_Title__c(
            Status__c = 'Order Change Confirmed',
            OrderNumber__c = sl.OrderNumber
          )
        );
      } else if (reqType == 'LoanPortfolioChangeConfirm') {
        to.Status__c = 'Loan Portfolio Change Confirmed';
      }

      // if (String.isNotEmpty(sl.AssetID)) {
      //   to.Asset_ID__c = sl.AssetID;
      // }
      // if (String.isNotEmpty(sl.OrderNumber)) {
      //   to.Order_Number__c = sl.OrderNumber;
      // }

      to.Error_Message__c = null;
    } else {
      to.Error_Message__c = sl.ErrorMessage;
      if (reqType == 'CancelRequestConfirmation') {
        to.Status__c = 'Cancel Request Failed';
      } else if (reqType == 'QuoteAcceptedConfirmation') {
        to.Status__c = 'Quote Accepted Failed';
      } else if (
        reqType == 'OrderChangeConfirmation' &&
        sl.OrderNumber != null &&
        String.isNotEmpty(sl.OrderNumber)
      ) {
        propertyTitles.add(
          new Property_Title__c(
            Status__c = 'Order Change Failed',
            OrderNumber__c = sl.OrderNumber
          )
        );
      } else if (reqType == 'LoanPortfolioChangeConfirm') {
        to.Status__c = 'Loan Portfolio Change Failed';
      } else if (reqType == 'DocumentSubmissionConfirm') {
        String docType = sl.ErrorMessage.substringBetween('=', '.');
        if (String.isNotBlank(docType)) {
          Servicelink_Schema__mdt schemaMd = Servicelink_Schema__mdt.getInstance(
            docType.replaceAll('-', '_')
          );
          if (schemaMd != null) {
            Deal_Document__c dealDoc = [
              SELECT Id, Submission_Failed__c
              FROM Deal_Document__c
              WHERE
                Type__c = :schemaMd.Full_Name__c
                AND Title_Order__c = :to.Id
                AND Deal__c = :to.Deal__c
                AND Submission_Failed__c = FALSE
              ORDER BY CreatedDate DESC
              LIMIT 1
            ];

            if (dealDoc != null) {
              dealDoc.Submission_Failed__c = true;
              update dealDoc;
            }
          }
        }
      }
    }

    update to;

    if (propertyTitles.size() > 0) {
      upsert propertyTitles OrderNumber__c;
    }

    return sl.LoanNumber;
  }

  public static String processOrderConfirmation(
    ServiceLinkResponse ordConf,
    Title_Order__c to
  ) {
    List<String> dateString = ordConf.OrderOpenedDate.split('-');
    DateTime orderOpenedDate = null;

    if (
      ordConf.OrderOpenedDate != null &&
      String.isNotEmpty(ordConf.OrderOpenedDate)
    ) {
      orderOpenedDate = DateTime.valueOf(
        ordConf.OrderOpenedDate.replace('T', ' ')
      );
    }

    //Order Confirmed

    Property_Title__c pt = [
      SELECT
        Id,
        Status__c,
        ErrorMessage__c,
        OrderNumber__c,
        OrderOpenedDate__c,
        Property__c,
        Property__r.Asset_ID__c,
        Vendor_Property_Status__c
      FROM Property_Title__c
      WHERE
        Property__r.Asset_ID__c = :ordConf.AssetId
        AND Title_Order__c = :to.Id
    ];

    if (ordConf.Status == 'SUCCESS') {
      pt.OrderNumber__c = ordConf.OrderNumber;
      pt.OrderOpenedDate__c = orderOpenedDate;
      pt.Status__c = 'Order Confirmed';
    } else {
      pt.ErrorMessage__c = ordConf.ErrorMessage;
      pt.Status__c = 'Loan Portfolio Change Required';
      pt.Vendor_Property_Status__c = 'Action Needed';
      ContentNote cn = new ContentNote();
      cn.Title = 'Order Confirmation Error Details';
      cn.Content = Blob.valueOf(ordConf.ErrorMessage);
      insert cn;

      ContentDocumentLink cdl = new ContentDocumentLink();
      cdl.ContentDocumentId = cn.Id;
      cdl.LinkedEntityId = pt.Id;
      cdl.ShareType = 'C';
      cdl.Visibility = 'AllUsers';
      insert cdl;
    }

    update pt;

    return ordConf.LoanNumber;
  }

  public static String processQuoteResponse(
    ServiceLinkResponse qteRes,
    Title_Order__c titleOrder
  ) {
    List<String> requiredFields = new List<String>{
      'DocumentType',
      'DocumentName',
      'Format',
      'Size',
      'Base64FileData'
    };

    if (qteRes.Document != null) {
      Map<String, Object> resDocument = (Map<String, Object>) JSON.deserializeUntyped(
        JSON.serialize(qteRes.Document)
      );
      verifyMissingFields(requiredFields, resDocument);
      ContentVersion cv = createContentVersion(
        new List<ServiceLinkAPI.TitleDocument>{ qteRes.Document },
        titleOrder.Deal__c
      )[0];
  
      List<Deal_Document__c> dealDocs = new List<Deal_Document__c>();
      ServiceLinkAPI.TitleDocument doc = qteRes.Document;
      Deal_Document__c dd = createDealDocument(doc, cv, titleOrder, null);
  
      insert dd;
  
    }

   
    update new Title_Order__c(
      Id = titleOrder.Id,
      Status__c = 'Quote Response Received'
    );

    return qteRes.LoanNumber;
  }

  public static Deal_Document__c createDealDocument(
    ServiceLinkAPI.TitleDocument doc,
    ContentVersion cv,
    Title_Order__c to,
    Id propId
  ) {
    return new Deal_Document__c(
      File_Name__c = cv.Title,
      ContentVersion_Id__c = cv.Id,
      Attachment_Id__c = cv.ContentDocumentId,
      Type__c = doc.DocumentType,
      Section__c = 'Title Orders',
      Document_Type__c = doc.DocumentType,
      Document_Loaded__c = true,
      Added_By__c = userInfo.getUserId(),
      Other_Document_Type__c = 'Title Order Documents',
      Deal__c = to.Deal__c,
      Property__c = propId != null ? propId : null,
      Title_Order__c = to.Id
    );
  }

  public static List<ContentVersion> createContentVersion(
    List<ServiceLinkAPI.TitleDocument> docs,
    Id parentId
  ) {
    List<ContentVersion> contentVersions = new List<ContentVersion>();

    for (ServiceLinkAPI.TitleDocument doc : docs) {
      ContentVersion cv = new ContentVersion();
      cv.VersionData = EncodingUtil.base64Decode(doc.Base64FileData);
      cv.Title = System.now().format('yyyy-MM-dd_h:mm_a_') + doc.DocumentName;
      cv.PathOnClient = doc.DocumentName;
      cv.Type__c = doc.DocumentType;
      contentVersions.add(cv);
    }

    insert contentVersions;

    List<ContentVersion> cvsQueried = [
      SELECT Id, VersionData, Title, PathOnClient, Type__c, ContentDocumentId
      FROM ContentVersion
      WHERE Id IN :contentVersions
    ];
    List<ContentDocumentLink> cdLinks = new List<ContentDocumentLink>();

    for (ContentVersion cv : cvsQueried) {
      ContentDocumentLink cdl = new ContentDocumentLink(
        ShareType = 'I',
        Visibility = 'AllUsers',
        LinkedEntityId = parentId,
        ContentDocumentId = cv.ContentDocumentId
      );
      cdLinks.add(cdl);
    }

    insert cdLinks;
    return cvsQueried;
  }

  public static String processQuoteReceivedConfirm(
    ServiceLinkResponse reqObj,
    Title_Order__c titleOrder
  ) {
    Title_Order__c updatedTitleOrder = new Title_Order__c(Id = titleOrder.Id);
    if (reqObj.Status == 'SUCCESS') {
      updatedTitleOrder.Order_Opened_Date__c = reqObj.OrderOpenedDate != null &&
        String.isNotEmpty(reqObj.OrderOpenedDate)
        ? DateTime.valueOf(reqObj.OrderOpenedDate.replace('T', ' '))
        : updatedTitleOrder.Order_Opened_Date__c;
      updatedTitleOrder.Bulk_Project_Order_Num__c = reqObj.BulkProjectOrderNum;
      updatedTitleOrder.Error_Message__c = null;
      updatedTitleOrder.Status__c = 'Quote Received Success';
    } else {
      updatedTitleOrder.Error_Message__c = reqObj.ErrorMessage;
      updatedTitleOrder.Status__c = 'Quote Received Failed';
    }

    update updatedTitleOrder;

    return reqObj.LoanNumber;
  }

  public static Date parseDateString(String dateString) {
    if (dateString == null || String.isEmpty(dateString)) {
      return null;
    }
    return Date.valueOf(dateString);
  }

  public static void throwNullError() {
    ServiceLinkException err = new ServiceLinkException();
    err.setMessage(
      'Unable to locate records. Please make sure that the relevant ID parameters are correct.'
    );
    throw err;
  }

  public static void throwMissingFieldError(List<String> fields) {
    ServiceLinkException err = new ServiceLinkException();
    err.setMessage(
      'The following fields are required: ' + String.join(fields, ', ')
    );
    throw err;
  }

  public static List<Title_Order__c> queryTitleOrders(
    ServiceLinkResponse resp,
    Boolean isNewOrderNumber,
    Boolean isNewBulkNum
  ) {
    Map<String, String> fieldValueMap = new Map<String, String>();

    if (resp.QuoteID != null && String.isNotEmpty(resp.QuoteID)) {
      fieldValueMap.put('Quote_ID__c', resp.QuoteID);
    }
    if (
      resp.BulkProjectOrderNum != null &&
      String.isNotEmpty(resp.BulkProjectOrderNum) &&
      !isNewBulkNum
    ) {
      fieldValueMap.put('Bulk_Project_Order_Num__c', resp.BulkProjectOrderNum);
    }

    if (resp.LoanNumber != null && String.isNotEmpty(resp.LoanNumber)) {
      fieldValueMap.put('Loan_Number__c', resp.LoanNumber);
    }
    // if (resp.AssetID != null && String.isNotEmpty(resp.AssetID)) {
    //   fieldValueMap.put('Asset_ID__c', resp.AssetID);
    // }
    // if (
    //   resp.OrderNumber != null &&
    //   String.isNotEmpty(resp.OrderNumber) &&
    //   !isNewOrderNumber
    // ) {
    //   fieldValueMap.put('Order_Number__c', resp.OrderNumber);
    // }
    // if (
    //   resp.RecordingOrderNumber != null &&
    //   String.isNotEmpty(resp.RecordingOrderNumber)
    // ) {
    //   fieldValueMap.put('Recording_Order_Number__c', resp.RecordingOrderNumber);
    // }

    if (fieldValueMap.size() > 0) {
      Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
      List<String> fieldList = new List<String>(
        schemaMap.get('Title_Order__c').getDescribe().fields.getMap().keySet()
      );

      String queryString =
        'SELECT ' +
        String.join(fieldList, ', ') +
        ' FROM Title_Order__c WHERE ';
      List<String> whereClauseList = new List<String>();
      for (String key : fieldValueMap.keySet()) {
        String val = String.escapeSingleQuotes(fieldValueMap.get(key));
        whereClauseList.add(key + ' = \'' + val + '\'');
      }
      queryString += String.join(whereClauseList, ' AND ');

      return Database.query(queryString);
    } else {
      return new List<Title_Order__c>();
    }
  }

  public static List<Property_Title__c> queryPropertyTitles(
    String orderNumber,
    Id titleOrderId,
    String bulkProjectOrderNum
  ) {
    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    List<String> fieldList = new List<String>(
      schemaMap.get('Property_Title__c').getDescribe().fields.getMap().keySet()
    );

    String queryString =
      'SELECT ' +
      String.join(fieldList, ', ') +
      ' FROM Property_Title__c';

    List<String> whereClauseList = new List<String>();

    if (orderNumber != null && String.isNotEmpty(orderNumber)) {
      whereClauseList.add('OrderNumber__c=\'' + orderNumber + '\'');
    }

    if (titleOrderId != null && String.isNotEmpty(titleOrderId)) {
      whereClauseList.add('Title_Order__c=\'' + titleOrderId + '\'');
    }

    if (bulkProjectOrderNum != null && String.isNotEmpty(bulkProjectOrderNum)) {
      whereClauseList.add(
        'Title_Order__r.Bulk_Project_Order_Num__c=\'' +
        bulkProjectOrderNum +
        '\''
      );
    }

    if (whereClauseList.size() > 0) {
      queryString += ' WHERE ' + String.join(whereClauseList, ' AND ');
    }

    return Database.query(queryString);
  }

  public static void verifyMissingFields(
    List<String> requiredFields,
    Map<String, Object> reqObject
  ) {
    List<String> missingFields = new List<String>();
    for (String field : requiredFields) {
      if (
        reqObject.get(field) == null ||
        String.isEmpty(String.valueOf(reqObject.get(field)))
      ) {
        missingFields.add(field);
      }
    }

    if (missingFields.size() > 0) {
      throwMissingFieldError(missingFields);
    }
  }

  public virtual class ServiceLinkBaseFields {
    public String LoanNumber;
    public String QuoteID;
    public String BulkProjectOrderNum;
    public String AssetID;
    public String OrderNumber;
    public String IncomingTransactionId;
  }

  public virtual class ServiceLinkAttachmentFields extends ServiceLinkBaseFields {
    public String CustInqId;
    public String NoteId;
    public String DocumentID;
    public String RecId;
    public String HOAOrderedDate;
    public String AllHOAOrderedDate;
    public String HOACompletedDate;
    public String AllHOACompletedDate;
    public String PayoffOrderedDate;
    public String AllPayoffsOrderedDate;
    public String PayoffCompletedDate;
    public String AllPayoffsCompletedDate;
    public String HOAExists;
    public String PayOffExists;
  }

  public virtual class ServiceLinkTitles extends ServiceLinkAttachmentFields {
    public String AllTitlesOrderedDate;
    public String TitleCompleteDate;
    public String AllTitlesCompletedDate;
    public String OriginalTitleClearedDate;
    public String OriginalAllTitlesClearedDate;
    public String LatestTitleClearedDate;
    public String LatestAllTitlesClearedDate;
  }

  public virtual class ServiceLinkTaxes extends ServiceLinkTitles {
    public String TaxesOrderedDate;
    public String AllTaxesOrderedDate;
    public String TaxesCompletedDate;
    public String AllTaxesCompletedDate;
  }

  public virtual class ServiceLinkMisc extends ServiceLinkTaxes {
    public String OrderOpenedDate;
    public String DeedsOrderedDate;
    public String UnExecDeedSentDate;
    public String ItemId;
    public String ItemType;
    public String ItemTypeDesc;
    public String ItemNoteText;
    public String CannotCureReasons;
    public String AllClearedToCloseDate;
    public String LoanDocsReceivedDate;
    public String SignedDocsScannedDate;
    public String ScannedDocsForwardedDate;
    public String DocsEstArrivalDate;
    public String SignedDocsReceivedDate;
    public String FileFundedDate;
  }

  public virtual class ServiceLinkRecordingTracking extends ServiceLinkMisc {
    public String RecordingDate;
    public String RecordingOrderNumber;
    public String RecordingState;
    public String RecordingCounty;
    public String RecordingType;
    public String RecordingDesc;
    public String InstrumentNumber;
    public String BookNumber;
    public String PageNumber;
    public String Grantor;
    public String Grantee;
    public String Mortgagor;
    public String Mortgagee;
  }

  public class SigningAttendee {
    public String Name;
  }

  public class SigningLocation {
    public String Address1;
    public String Address2;
    public String City;
    public String State;
    public String Zipcode;
  }

  public virtual class ServiceLinkSigningAppointment extends ServiceLinkRecordingTracking {
    public String AppointmentStatus;
    public String ScheduledSigningDate;
    public String CancelledDate;
    public String ClosedDate;
    public SigningLocation SigningLocation;
    public List<SigningAttendee> Attendees;
  }

  public class ServiceLinkResponse extends ServiceLinkSigningAppointment {
    public String Comments;
    public ServiceLinkAPI.TitleDocument Document;
    public String Status;
    public String ErrorMessage;
    public String NoteText;
    public List<ServiceLinkAPI.TitleDocument> Documents;
    public String DocumentType;
    public String DocumentName;
    public String Format;
    public Long Size;
    public String Base64FileData;
  }
}
