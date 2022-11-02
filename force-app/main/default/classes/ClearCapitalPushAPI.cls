@RestResource(urlMapping='/clearcapital/*')
global without sharing class ClearCapitalPushAPI {
  @HttpPost
  global static void doPost() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;

    //system.debug(req.requestBody.toString());
    try {
      //system.debug(req.requestBody.size());
      //String formBody = req.requestBody.toString();

      if (req.requestBody.size() > 5700000) {
        parseBodyFuture(req.requestBody);
      } else {
        String formBody = req.requestBody.tostring();
        if (formBody.contains('ClearVal')) {
          parseClearVal(formBody);
        } else if (formBody.contains('inspection_type="BPO"')) {
          parseBPO(formBody);
        } else {
          parseAppraisal(formBody);
        }
      }

      String successAck = createSuccessAck();

      res.statusCode = 200;
      res.addHeader('Content-Type', 'text/xml');
      res.responseBody = Blob.valueOf(successAck);
    } catch (Exception e) {
      system.debug(e.getLineNumber());
      String errorAck = createErrorAck(e);

      res.statusCode = 200;
      res.addHeader('Content-Type', 'text/xml');
      res.responseBody = Blob.valueOf(errorAck);
    }
  }

  @future
  public static void parseBodyFuture(Blob body) {
    try {
      String formBody = body.tostring();
      if (formBody.contains('ClearVal')) {
        parseClearVal(formBody);
      } else if (formBody.contains('inspection_type="BPO"')) {
        parseBPO(formBody);
      } else {
        parseAppraisal(formBody);
      }
    } catch (Exception e) {
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      email.setSubject('Clear Capital XML Failed');

      String htmlbody = e.getMessage();
      // htmlbody += ;

      email.setHTMLBody(htmlBody);
      email.setToAddresses(new List<String>{ 'Bryon.Harland@cvest.com' });
      email.setCCAddresses(new List<String>{ 'mcastillo@mkpartners.com' });

      List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
      Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
      efa.setBody(body);
      efa.setFileName('clearcapital.xml');
      efa.setContentType('text/xml');
      attachments.add(efa);

      email.setFileAttachments(attachments);
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
    }
  }

  public static void parseClearVal(String body) {
    Appraisal__c appraisal = new Appraisal__c();
    appraisal.appraisal_firm_transaction_id__c = body.substringBetween(
      '<transaction_id>',
      '</transaction_id>'
    );

    String propertyString = body.substringBetween('<property>', '</property>');
    String addressString = propertyString.substringBetween(
      '<address>',
      '</address>'
    );

    appraisal.City__c = addressString.substringBetween('<city>', '</city>');
    appraisal.Property_State__c = addressString.substringBetween('<state>', '</state>');
    appraisal.Zip__c = addressString.substringBetween('<zip>', '</zip>');
    appraisal.County__c = propertyString.substringBetween(
      '<county>',
      '</county>'
    );
    appraisal.APN_Assessor_s_Parcel__c = propertyString.substringBetween(
      '<apn>',
      '</apn>'
    );
    appraisal.Legal_Description__c = propertyString.substringBetween(
      '<legal_descr>',
      '</legal_descr>'
    );

    String zoningString = propertyString.substringBetween(
      '<zoning>',
      '</zoning'
    );
    appraisal.Zoning_Classification__c = zoningString.substringBetween(
      '<classification>',
      '</classification>'
    );
    appraisal.Zoning_Description__c = zoningString.substringBetween(
      '<description>',
      '</description>'
    );
    appraisal.Zoning_Compliance__c = zoningString.substringBetween(
      '<compliance>',
      '</compliance'
    );

    String floodString = propertyString.substringBetween('<flood>', '</flood>');
    appraisal.Flood_Zone__c = floodString.substringBetween('<zone>', '</zone>');
    appraisal.Special_Flood_Hazard_Area__c = floodString.substringBetween(
      '<No>',
      '</No>'
    );

    String characteristicsString = propertyString.substringBetween(
      '<characteristics>',
      '</characteristics>'
    );
    appraisal.Car_Storage__c = characteristicsString.substringBetween(
      '<garage_type>',
      '</garage_type'
    );
    appraisal.Garage_of_Cars__c = Decimal.valueOf(
      characteristicsString.substringBetween(
        '<garage_stalls>',
        '</garage_stalls>'
      )
    );
    appraisal.Lot_Area__c = characteristicsString.substringBetween(
      '<lot_size_acres>',
      '</lot_size_acres>'
    );

    appraisal.Gross_Living_Area__c = Decimal.valueOf(
      characteristicsString.substringBetween(
          '<gross_living_area>',
          '</gross_living_area>'
        )
        .replaceAll(',', '')
    );
    appraisal.Year_Built__c = characteristicsString.substringBetween(
      '<year_built>',
      '</year_built>'
    );
    appraisal.Design_Style__c = characteristicsString.substringBetween(
      '<style_design>',
      '</style_design>'
    );
    appraisal.Condition__c = characteristicsString.substringBetween(
      '<condition>',
      '</condition>'
    );
    appraisal.Bedrooms__c = Decimal.valueOf(
      characteristicsString.substringBetween(
        '<bedroom_count>',
        '</bedroom_count>'
      )
    );
    Decimal bath_count = Decimal.valueOf(
      characteristicsString.substringBetween(
        '<bathroom_count>',
        '</bathroom_count>'
      )
    );
    Decimal halfbath_count = Decimal.valueOf(
      characteristicsString.substringBetween(
        '<half_bath_count>',
        '</half_bath_count>'
      )
    );
    appraisal.Baths__c = bath_count + halfbath_count;

    characteristicsString = null;

    String hoaString = propertyString.substringBetween('<hoa>', '</hoa>')
      .substringBetween('<fees>', '</fees>');
    if (
      String.isNotEmpty(hoaString.substringBetween('<amount>', '</amount>'))
    ) {
      appraisal.HOA__c = Decimal.valueOf(
        hoaString.substringBetween('<amount>', '</amount>')
      );
    }

    appraisal.HOA_Frequency__c = hoaString.substringBetween(
      '<frequency>',
      '</frequency>'
    );
    hoaString = null;

    String inspectionCharacteristicsString = propertyString.substringBetween(
        '<inspection>',
        '</inspection>'
      )
      .substringBetween('<characteristics>', '</characteristics>');
    appraisal.Units__c = Decimal.valueOf(
      inspectionCharacteristicsString.substringBetween(
        '<number_units>',
        '</number_units>'
      )
    );
    // String repairs
    inspectionCharacteristicsString = null;
    propertyString = null;

    String valuesString = body.substringBetween('<values>', '</values>');
    appraisal.Appraised_Value_Amount__c = Decimal.valueOf(
      valuesString.substringBetween('<as_is>', '</as_is>').replaceAll(',', '')
    );
    appraisal.Appraisal_Effective_Date__c = Date.valueOf(
      valuesString.substringBetween('<effective_date>', '</effective_date>')
        .replaceAll(',', '')
    );

    Appraisal__c appraisalOriginal = [
      SELECT Id, Property_Address__c, Property__c, Property__r.Deal__c
      FROM Appraisal__c
      WHERE
        appraisal_firm_transaction_id__c = :appraisal.appraisal_firm_transaction_id__c
      LIMIT 1
    ];

    appraisal.Id = appraisalOriginal.Id;

    ContentVersion cv = new ContentVersion();
    cv.ContentLocation = 'S';
    cv.VersionData = EncodingUtil.base64Decode(
      body.substringBetween(
        '<embedded encoding="base64" extension="pdf">',
        '</embedded>'
      )
    );
    cv.Title = appraisalOriginal.Property_Address__c + '.pdf';
    cv.PathOnClient = appraisalOriginal.Property_Address__c + '.pdf';
    insert cv;

    Id contentDocumentId = [
      SELECT Id, ContentDocumentId, FileExtension
      FROM ContentVersion
      WHERE Id = :cv.Id
      LIMIT 1
    ]
    .ContentDocumentId;

    ContentDocumentLink link = new ContentDocumentLink();
    link.ShareType = 'I';
    link.LinkedEntityId = appraisal.Id;
    link.ContentDocumentId = contentDocumentId;
    link.Visibility = 'AllUsers';

    insert link;

    List<Deal_Document__c> dealDocs = BorrowerChecklistController.createDealDocs(
      appraisal.Property__r.Deal__c,
      new List<String>{ contentDocumentId },
      'Diligence Documents;Property Level Documents|Valuations',
      appraisalOriginal.Property__c,
      appraisalOriginal.Id
    );

    appraisal.Status__c = 'Complete-Delivered';
    appraisal.Status_Description__c = null;
    update appraisal;
    //return appraisal;
  }

  public static void parseBPO(String body) {
    Appraisal__c appraisal = new Appraisal__c();
    appraisal.Appraisal_Firm_Transaction_ID__c = body.substringBetween(
      'property_id="',
      '"'
    );
    String subjectDataString = body.substringBetween(
      '<subject_data>',
      '</subject_data>'
    );
    // String addressString = subjectDataString.substringBetween('<address', '>');

    appraisal.Bedrooms__c = Decimal.valueOf(
      subjectDataString.substringBetween('<bedrooms>', '</bedrooms>')
    );
    appraisal.Baths__c = Decimal.valueOf(
      subjectDataString.substringBetween('<bathrooms>', '</bathrooms>')
    );
    appraisal.Baths__c += Decimal.valueOf(
      subjectDataString.substringBetween('<half_baths>', '</half_baths>')
    );

    appraisal.Units__c = Decimal.valueOf(
      subjectDataString.substringBetween('<units>', '</units>')
    );

    appraisal.Age__c = Decimal.valueOf(
      subjectDataString.substringBetween('<age>', '</age>')
    );

    String hoa = subjectDataString.substringBetween('<hoa>', '</hoa>');

    if (hoa == 'Yes') {
      String hoaString = subjectDataString.substringBetween(
        '<hoa_fees>',
        '</hoa_fees>'
      );

      Decimal hoaFee = Decimal.valueOf(hoaString.substringBefore(' /'));
      String hoaFrequency = hoaString.substringAfter('/ ');

      appraisal.HOA__c = hoaFee;
      appraisal.HOA_Frequency__c = hoaFrequency;
    }

    String valueString = subjectDataString.substringBetween(
      '<values>',
      '</values>'
    );
    appraisal.Appraised_Value_Amount__c = Decimal.valueOf(
      valueString.substringBetween('<as_is_value>', '</as_is_value>')
    );
    appraisal.Appraised_After_Repair_Value__c = Decimal.valueOf(
      valueString.substringBetween('<repaired_value>', '</repaired_value>')
    );

    String pool = subjectDataString.substringBetween('<pool>', '</pool>');
    appraisal.Pool__c = pool == 'Yes' ? true : false;

    String garageString = subjectDataString.substringBetween(
      '<garage>',
      '</garage>'
    );
    Decimal garageCars = Decimal.valueOf(garageString.substringBefore(' '));
    String garage = garageString.substringAfter(' ');
    appraisal.Garage__c = garage == 'None' ? false : true;
    appraisal.Garage_of_Cars__c = garageCars;
    appraisal.Status__c = 'Complete-Delivered';
    appraisal.Status_Description__c = null;

    Appraisal__c appraisalOriginal = [
      SELECT Id, Property_Address__c, Property__c, Property__r.Deal__c
      FROM Appraisal__c
      WHERE
        appraisal_firm_transaction_id__c = :appraisal.appraisal_firm_transaction_id__c
      LIMIT 1
    ];

    appraisal.Id = appraisalOriginal.Id;

    ContentVersion cv = new ContentVersion();
    cv.ContentLocation = 'S';
    cv.VersionData = EncodingUtil.base64Decode(
      body.substringBetween('<pdf_encoded>', '</pdf_encoded>')
    );
    cv.Title = appraisalOriginal.Property_Address__c + '.pdf';
    cv.PathOnClient = appraisalOriginal.Property_Address__c + '.pdf';
    insert cv;

    Id contentDocumentId = [
      SELECT Id, ContentDocumentId, FileExtension
      FROM ContentVersion
      WHERE Id = :cv.Id
      LIMIT 1
    ]
    .ContentDocumentId;

    ContentDocumentLink link = new ContentDocumentLink();
    link.ShareType = 'I';
    link.LinkedEntityId = appraisal.Id;
    link.ContentDocumentId = contentDocumentId;
    link.Visibility = 'AllUsers';

    insert link;

    List<Deal_Document__c> dealDocs = BorrowerChecklistController.createDealDocs(
      appraisal.Property__r.Deal__c,
      new List<String>{ contentDocumentId },
      'Diligence Documents;Property Level Documents|Valuations',
      appraisalOriginal.Property__c,
      appraisalOriginal.Id
    );

    update appraisal;
    //return appraisal;
  }

  public static void parseAppraisal(String body) {
    Appraisal__c appraisal = new Appraisal__c();
    appraisal.Appraisal_Firm_Transaction_Id__c = body.substringBetween(
      '<propertyID>',
      '</propertyID>'
    );

    String appraisedValue = body.substringBetween(
      '<asIsValue>',
      '</asIsValue>'
    );
    if (String.isNotBlank(appraisedValue)) {
      appraisal.Appraised_Value_Amount__c = Decimal.valueOf(appraisedValue);
    }

    String appraisedRepairValue = body.substringBetween(
      '<asRepairedValue>',
      '</asRepairedValue>'
    );
    if (String.isNotBlank(appraisedRepairValue)) {
      appraisal.Appraised_After_Repair_Value__c = Decimal.valueOf(
        appraisedRepairValue
      );
    }

    String appraisedDate = body.substringBetween(
      '<appraisalDate>',
      '</appraisalDate>'
    );
    if (String.isNotBlank(appraisedDate)) {
      List<String> dates = appraisedDate.split('/');
      appraisal.Appraisal_Effective_Date__c = Date.valueOF(
        dates[2] +
        '-' +
        dates[0] +
        '-' +
        dates[1]
      );
    }

    String units = body.substringBetween('<propertyUnits>', '</propertyUnits>');
    if (String.isNotBlank(units)) {
      appraisal.Units__c = Decimal.valueOf(units);
    }

    String grossLivingArea = body.substringBetween(
      '<grossLivingArea>',
      '</grossLivingArea>'
    );
    if (String.isNotBlank(grossLivingArea)) {
      grossLivingArea = grossLivingArea.replaceAll(',', '');
      appraisal.Gross_Living_Area__c = Decimal.valueOf(grossLivingArea);
    }

    String bedroomCount = body.substringBetween(
      '<bedroomCount>',
      '</bedroomCount>'
    );
    if (String.isNotBlank(bedroomCount)) {
      appraisal.Bedrooms__c = Decimal.valueOf(bedroomCount);
    }

    String bathroomCount = body.substringBetween(
      '<bathroomCount>',
      '</bathroomCount>'
    );
    if (String.isNotBlank(bathroomCount)) {
      appraisal.Baths__c = Decimal.valueOf(bathroomCount);
    }

    appraisal.Status__c = 'Complete-Delivered';
    appraisal.Status_Description__c = null;

    Appraisal__c appraisalOriginal = [
      SELECT Id, Property_Address__c, Property__c, Property__r.Deal__c
      FROM Appraisal__c
      WHERE
        appraisal_firm_transaction_id__c = :appraisal.appraisal_firm_transaction_id__c
      LIMIT 1
    ];

    appraisal.Id = appraisalOriginal.Id;

    // ContentVersion cv = new ContentVersion();
    // cv.ContentLocation = 'S';
    // cv.VersionData = EncodingUtil.base64Decode(
    //   body.substringBetween('<pdfBase64>', '</pdfBase64>')
    // );
    // cv.Title = appraisalOriginal.Property_Address__c + '.pdf';
    // cv.PathOnClient = appraisalOriginal.Property_Address__c + '.pdf';
    // insert cv;

    // Id contentDocumentId = [
    //   SELECT Id, ContentDocumentId, FileExtension
    //   FROM ContentVersion
    //   WHERE Id = :cv.Id
    //   LIMIT 1
    // ]
    // .ContentDocumentId;

    // ContentDocumentLink link = new ContentDocumentLink();
    // link.ShareType = 'I';
    // link.LinkedEntityId = appraisal.Id;
    // link.ContentDocumentId = contentDocumentId;
    // link.Visibility = 'AllUsers';

    // List<Deal_Document__c> dealDocs = BorrowerChecklistController.createDealDocs(
    //   appraisal.Property__r.Deal__c,
    //   new List<String>{ contentDocumentId },
    //   'Diligence Documents;Property Level Documents|Valuations',
    //   appraisalOriginal.Property__c,
    //   appraisalOriginal.Id
    // );

    // insert link;

    update appraisal;

    System.enqueueJob(new CheckStatus(appraisal.Id));
  }

  public static String createSuccessAck() {
    String ack = '<?xml version="1.0" encoding="UTF­8"?>';
    ack += '<response>';
    ack += ' <success>1</success>';
    ack += '  <message>Received Successfully</message>';
    ack += '</response>';

    return ack;
  }

  public static String createErrorAck(Exception e) {
    String ack = '<?xml version="1.0" encoding="UTF­8"?>';
    ack += '<response>';
    ack += ' <success>0</success>';
    ack += '  <message>' + e.getMessage() + '</message>';
    ack += '</response>';

    return ack;
  }

  public class CheckStatus implements System.Queueable, Database.AllowsCallouts {
    Id appraisalId;
    CheckStatus(Id appraisalId) {
      this.appraisalId = appraisalId;
    }

    public void execute(QueueableContext qc) {
      AppraisalMergeController.checkStatusClearCapital(appraisalId);
    }
  }
}