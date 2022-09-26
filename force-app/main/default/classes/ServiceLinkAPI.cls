public without sharing class ServiceLinkAPI {
  public static ServiceLinkRequest performQuoteRequest(ServiceLinkRequest sr) {
    String url = 'https://betaapps.servicelinkdtc.com/DataConnectorAPI';
    String username = 'tmbeta_corevest@svclnk.com';
    String sisma = 'W0rkL!f3=ity';
    HttpRequest req = new HttpRequest();
    req.setBody(
      JSON.serialize(
        new Map<String, ServiceLinkRequest>{ 'QuoteRequest' => sr },
        true
      )
    );
    req.setEndpoint(url);
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('Content-Length', String.valueOf(req.getBody().length()));
    req.setHeader(
      'Authorization',
      'Basic ' +
      EncodingUtil.base64Encode(Blob.valueOf(username + ':' + sisma))
    );

    req.setTimeout(120000);

    Integer statusCode = 200;
    String body = '';

    HttpResponse res = new Http().send(req);
    system.debug(res.getBody());
    system.debug(res.getStatus());
    system.debug(res.getStatusCode());
    body = res.getBody();
    Map<String, ServiceLinkRequest> parsedBody = (Map<String, ServiceLinkRequest>) JSON.deserialize(
      body,
      Map<String, ServiceLinkRequest>.class
    );
    return parsedBody.values()[0];
  }

  public static ServiceLinkRequest performRequest(String reqType, ServiceLinkRequest sr) {
    String url = 'https://betaapps.servicelinkdtc.com/DataConnectorAPI/CoreVest/' + reqType;
    String username = 'tmbeta_corevest@svclnk.com';
    String sisma = 'W0rkL!f3=ity';
    HttpRequest req = new HttpRequest();
    req.setBody(
      JSON.serialize(
        new Map<String, ServiceLinkRequest>{ reqType => sr },
        true
      )
    );
    req.setEndpoint(url);
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('Content-Length', String.valueOf(req.getBody().length()));
    req.setHeader(
      'Authorization',
      'Basic ' +
      EncodingUtil.base64Encode(Blob.valueOf(username + ':' + sisma))
    );

    req.setTimeout(120000);

    Integer statusCode = 200;
    String body = '';

    HttpResponse res = new Http().send(req);
    system.debug(res.getBody());
    system.debug(res.getStatus());
    system.debug(res.getStatusCode());
    body = res.getBody();
    ServiceLinkRequest parsedBody = (ServiceLinkRequest) JSON.deserialize(
      body,
      ServiceLinkRequest.class
    );
    return parsedBody;
  }

  public class TitleDocument {
    public String DocumentType { get; set; }
    public String DocumentName { get; set; }
    public String Format { get; set; }
    public Long Size { get; set; }
    public String Base64FileData { get; set; }
  }
  public virtual class QuoteRequest {
    public String timeStamp { get; set; }
    public String SourcePartyID { get; set; }
    public String DestinationPartyID { get; set; }
    public String QuoteID { get; set; } // CV unique ID for quote request
    public String LoanNumber { get; set; } // CV Loan Number
    public String LoanPortfolioName { get; set; } // CV Loan Portfolio Name
    public Decimal LoanAmount { get; set; }
    public String Comments { get; set; }
    public TitleDocument Document { get; set; } // type is QUOTEREQUEST and send XLSX format. "Data Tape" of properties for the quote request

    public void generateRequest(
      Opportunity deal,
      Deal_Document__c doc,
      ContentVersion cv,
      Integer sequenceNumber
    ) {
      this.Document = new TitleDocument();
      this.SourcePartyID = 'COREVEST-SFR';
      this.DestinationPartyID = 'COREVEST-QUOTE';
      this.QuoteID = deal.id + '-' + String.valueOf(sequenceNumber).leftPad(3, '0');
      this.LoanNumber = deal.Deal_Loan_Number__c;
      this.LoanAmount = deal.Current_Loan_Amount__c;
      this.LoanPortfolioName = deal.Name;
      this.Comments = '';
      this.Document.DocumentType = 'QUOTEREQUEST';
      this.Document.DocumentName = doc.File_Name__c;
      this.Document.Format = 'XLSX';
      this.Document.Size = cv.ContentSize;
      this.Document.Base64FileData = EncodingUtil.base64Encode(cv.VersionData);
    }
  }

  public virtual class OrderInquiry extends QuoteRequest {
    public String BulkProjectOrderNum { get; set; }
    public String IncomingTransactionId { get; set; }
    public String AssetID { get; set; }
    public String OrderNumber { get; set; }
    public String InquiryType { get; set; }
    public String RequestorEmail { get; set; }
    public List<TitleDocument> Documents { get; set; }

    public void generateRequest(Title_Order__c titleOrder) {
      this.BulkProjectOrderNum = String.isNotEmpty(titleOrder.Bulk_Project_Order_Num__c) ? titleOrder.Bulk_Project_Order_Num__c : '';
      this.IncomingTransactionId = titleOrder.Property__r.Deal__c;
      this.OrderNumber = titleOrder.Order_Number__c;
      this.AssetID = titleOrder.Asset_ID__c;
      this.InquiryType = 'REVISEDQUO';
      this.RequestorEmail = UserInfo.getUserEmail();
    }
    

    
  }

  public class ServicelinkContact {
    public String ContactType;
    public String CompanyName;
    public String FirstName;
    public String LastName;
    public String ContactEmail;
    public String Address1;
    public String Address2;
    public String City;
    public String State;
    public String Zipcode;
    public String Phone;
    public String MobilePhone;
  }

  public class Property {
    public String AssetID;
    public String DestinationPartyID;
    public Integer NumberOfUnits;
    public String Address1;
    public String Address2;
    public String City;
    public String State;
    public String County;
    public String Zipcode;
    public String APN;
    public String PropertyType;
    public String AllocatedLoanAmount;
    public String ParentProperty;
    public String Remarks;
    public String HOAExists;
    public Decimal HOAAmount;
    public Decimal SpecialAssessmentsAmt;
    public Decimal ExistingDebtAmt;
  }

  public virtual class QuoteAccepted extends OrderInquiry {
    public String AnticipatedCloseDate { get; set; }
    public TitleDocument Document { get; set; }
    public List<ServicelinkContact> Contacts { get; set;}
    public List<Property> Properties { get; set; }
     
    public void generateQuoteAcceptedRequest(Title_Order__c to, ContentVersion cv, List<Property__c> props) {
      this.BulkProjectOrderNum = to.Bulk_Project_Order_Num__c;
      this.QuoteID = to.Quote_ID__c;
      this.LoanNumber = to.Loan_Number__c;
      this.AnticipatedCloseDate = to.Anticipated_Close_Date__c != null ? to.Anticipated_Close_Date__c.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss') + '+00:00' : '';
      this.Document.DocumentType = 'DATATAPE';
      this.Document.Format = 'XLSX';
      this.Document.DocumentName = cv.Title;
      this.Document.Size = cv.ContentSize;
      this.Document.Base64FileData = EncodingUtil.base64Encode(cv.VersionData);
      
    }
  }

  public virtual class ServiceLinkRequest extends QuoteAccepted {
  
  }
}