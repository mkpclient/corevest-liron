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
      'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(username + ':' + sisma))
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

  public static ServiceLinkRequest performRequest(
    String reqType,
    String sr
  ) {
    String url =
      'https://betaapps.servicelinkdtc.com/DataConnectorAPI/CoreVest/' +
      reqType;
    String username = 'tmbeta_corevest@svclnk.com';
    String sisma = 'W0rkL!f3=ity';
    HttpRequest req = new HttpRequest();
    req.setBody(
      sr
    );
    req.setEndpoint(url);
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('Content-Length', String.valueOf(req.getBody().length()));
    req.setHeader(
      'Authorization',
      'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(username + ':' + sisma))
    );

    req.setTimeout(120000);

    Integer statusCode = 200;
    String body = '';

    HttpResponse res = new Http().send(req);
    system.debug(res.getBody());
    system.debug(res.getStatus());
    system.debug(res.getStatusCode());
    if(Integer.valueOf(res.getStatusCode()) >= 400) {
      throw new ServiceLinkEndpoint.ServiceLinkException(res.getBody());
    }
    body = res.getBody();
    ServiceLinkRequest parsedBody = (ServiceLinkRequest) JSON.deserialize(
      body,
      ServiceLinkRequest.class
    );
    return parsedBody;
  }

  public static QuoteRequest generateQuoteRequest(
      Opportunity deal,
      Deal_Document__c doc,
      ContentVersion cv,
      Integer sequenceNumber
    ) {
      QuoteRequest qr = new QuoteRequest();
      qr.Document = new TitleDocument();
      qr.SourcePartyID = 'COREVEST-SFR';
      qr.DestinationPartyID = 'COREVEST-QUOTE';
      qr.QuoteID =
        deal.Id +
        '-' +
        String.valueOf(sequenceNumber).leftPad(3, '0');
      qr.LoanNumber = deal.Deal_Loan_Number__c;
      qr.LoanAmount = deal.Current_Loan_Amount__c;
      qr.LoanPortfolioName = deal.Name;
      qr.Comments = '';
      qr.Document.DocumentType = 'QUOTEREQUEST';
      qr.Document.DocumentName = doc.File_Name__c;
      qr.Document.Format = 'XLSX';
      qr.Document.Size = cv.ContentSize;
      qr.Document.Base64FileData = EncodingUtil.base64Encode(cv.VersionData);
      return qr;
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
      this.BulkProjectOrderNum = String.isNotEmpty(
          titleOrder.Bulk_Project_Order_Num__c
        )
        ? titleOrder.Bulk_Project_Order_Num__c
        : '';
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
    public Decimal NumberOfUnits;
    public String Address1;
    public String Address2;
    public String City;
    public String State;
    public String County;
    public String Zipcode;
    public String APN;
    public String PropertyType;
    public Decimal AllocatedLoanAmount;
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
    public List<ServicelinkContact> Contacts { get; set; }
    public List<Property> Properties { get; set; }

    public void generateQuoteAcceptedRequest(
      Title_Order__c to,
      ContentVersion cv,
      List<Property__c> props,
      Map<Id, List<Property__c>> parentToChildMap
    ) {
      this.BulkProjectOrderNum = to.Bulk_Project_Order_Num__c;
      this.QuoteID = to.Quote_ID__c;
      this.LoanNumber = to.Loan_Number__c;
      this.AnticipatedCloseDate = to.Anticipated_Close_Date__c != null
        ? to.Anticipated_Close_Date__c.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss') +
          '+00:00'
        : '';
      this.Document = new TitleDocument();
      this.Document.DocumentType = 'DATATAPE';
      this.Document.Format = 'XLSX';
      this.Document.DocumentName = cv.Title;
      this.Document.Size = cv.ContentSize;
      this.Document.Base64FileData = EncodingUtil.base64Encode(cv.VersionData);
      this.Contacts = new List<ServiceLinkContact>();
      ServiceLinkContact lenderAtty = new ServiceLinkContact();

      Contact dealContact = to.Deal__r.Contact__r;
      lenderAtty.ContactType = 'LENDERATTORNEY';
      lenderAtty.CompanyName = to.Deal__r.Account.Name;
      lenderAtty.FirstName = dealContact.FirstName;
      lenderAtty.LastName = dealContact.LastName;
      lenderAtty.ContactEmail = dealContact.Email;
      lenderAtty.Address1 = dealContact.MailingStreet;
      lenderAtty.City = dealContact.MailingCity;
      lenderAtty.State = dealContact.MailingState;
      lenderAtty.Zipcode = dealContact.MailingPostalCode;
      lenderAtty.Phone = dealContact.Phone;
      lenderAtty.MobilePhone = dealContact.MobilePhone;
      this.Contacts.add(lenderAtty);
      this.Properties = new List<Property>();
      for (Property__c p : props) {
        Property sp = new Property();
        List<String> childAddresses = new List<String>();
        if (parentToChildMap.containsKey(p.Id)) {
          for (Property__c child : parentToChildMap.get(p.Id)) {
            String address = child.Name;
            if (String.isNotEmpty(child.City__c)) {
              address += ' ' + child.City__c;
            }

            String countyString = '';

            if (
              (!child.County__c.containsIgnoreCase('county') ||
              !child.County__c.containsIgnoreCase('parish') ||
              !child.County__c.containsIgnoreCase('city')) &&
              !new List<String>{
                  'VA',
                  'Virginia',
                  'DC',
                  'District of Columbia',
                  'Alaska'
                }
                .contains(child.State__c)
            ) {
              countyString = new List<String>{ 'LA', 'Louisiana' }
                  .contains(child.State__c)
                ? ' Parish'
                : ' County';
            }
            if (String.isNotEmpty(child.County__c)) {
              address += ', ' + child.County__c + countyString;
            }

            if (String.isNotEmpty(child.State__c)) {
              address += ', ' + child.State__c;
            }

            if (String.isNotEmpty(child.ZipCode__c)) {
              address += ' ' + child.ZipCode__c;
            }
            childAddresses.add(address);
          }
        }

        sp.AssetID = p.Asset_ID__c;
        sp.DestinationPartyID = p.Refinance_Acquisition__c == 'Refinance'
          ? 'COREVEST-REFI'
          : 'COREVEST-PURCHASE';
        sp.NumberOfUnits = p.Number_of_Units__c;
        sp.Address1 = p.Name;
        sp.Address2 = '';
        sp.City = p.City__c;
        sp.State = p.State__c;
        sp.County = p.County__c;
        sp.Zipcode = p.ZipCode__c;
        sp.APN = p.APN__c;
        sp.PropertyType = p.Property_Type__c;
        sp.AllocatedLoanAmount = p.ALA__c;
        sp.ParentProperty = p.Is_Parent__c ? 'Y' : 'N';
        sp.Remarks = p.Is_Parent__c ? String.join(childAddresses, '; ') : '';
        sp.HOAExists = p.Is_HOA__c == 'Yes' ? 'Y' : 'N';
        sp.HOAAmount = p.Is_HOA__c == 'Yes' ? p.Monthly_HOA_Fee__c : 0;
        sp.SpecialAssessmentsAmt = p.Special_Assesments_CFD_Mello_Roos_etc__c;
        sp.ExistingDebtAmt = p.Existing_Debt__c;
        this.Properties.add(sp);
      }
    }
  }

  public virtual class ServiceLinkRequest extends QuoteAccepted {
  }
}