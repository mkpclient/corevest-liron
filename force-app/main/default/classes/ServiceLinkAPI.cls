public without sharing class ServiceLinkAPI {
  public static void performRequest(String reqType, String sr) {
    String url =
      'https://betaapps.servicelinkdtc.com/DataConnectorAPI/CoreVest/' +
      reqType;
    String username = 'tmbeta_corevest@svclnk.com';
    String sisma = 'W0rkL!f3=ity';
    HttpRequest req = new HttpRequest();
    req.setBody(sr);
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
    if (Integer.valueOf(res.getStatusCode()) >= 400) {
      throw new ServiceLinkEndpoint.ServiceLinkException(res.getBody());
    }
  }

  public class TitleDocument {
    public String DocumentType;
    public String DocumentName;
    public String Format;
    public Long Size;
    public String Base64FileData;
    public TitleDocument generateDocument(ContentVersion cv, String docType) {
      this.DocumentType = docType;
      this.DocumentName = cv.Title;
      this.Format = cv.FileExtension.toUpperCase();
      this.Size = cv.ContentSize;
      this.Base64FileData = EncodingUtil.base64Encode(cv.VersionData);
      return this;
    }
  }

  public virtual class BaseAddress {
    public String Address1;
    public String Address2;
    public String City;
    public String State;
    public String County;
    public String Zipcode;
  }

  public class ServicelinkContact extends BaseAddress {
    public String ContactType;
    public String CompanyName;
    public String FirstName;
    public String LastName;
    public String ContactEmail;
    public String Phone;
    public String MobilePhone;
    public ServiceLinkContact(sObject p, String cType) {
      Boolean isUser =
        p.getSObjectType() == Schema.OpportunityTeamMember.getSObjectType();
      this.ContactType = cType;
      this.Address2 = '';
      sObject contactUser;
      if (isUser) {
        User u = (User) ((OpportunityTeamMember) p).User;
        System.debug(u);
        this.CompanyName = u.CompanyName;
        this.Address1 = u.Street;
        this.City = u.City;
        this.State = u.State;
        this.Zipcode = u.PostalCode;
        contactUser = u;
      } else {
        Deal_Contact__c dc = (Deal_Contact__c) p;
        Contact c = dc.Contact__r;
        System.debug(c);
        this.CompanyName = dc.Account__r?.Name;
        this.Address1 = c.MailingStreet;
        this.City = c.MailingCity;
        this.State = c.MailingState;
        this.Zipcode = c.MailingPostalCode;

        contactUser = c;
      }

      this.FirstName = (String) contactUser.get('FirstName');
      this.LastName = (String) contactUser.get('LastName');
      this.ContactEmail = (String) contactUser.get('Email');
      this.Phone = (String) contactUser.get('Phone');
      this.MobilePhone = (String) contactUser.get('MobilePhone');
      if (String.isEmpty(this.MobilePhone)) {
        this.MobilePhone = '';
      }
    }
  }

  public class Borrower extends BaseAddress {
    public String BorrowerType;
    public String FirstName;
    public String MiddleName;
    public String LastName;
    public String EmailAddress;
    public String MobilePhone;
    public String TrustDate;
    public String Trustee1Name;
    public String Trustee2Name;
    public String Trustee3Name;
    public String Trustee4Name;
  }

  public class PropertyAddress extends BaseAddress {
    public String PropertyType;
    public String PropertyAPN;
    public PropertyAddress(Property__c p) {
      this.Address1 = p.Name;
      this.Address2 = '';
      this.City = p.City__c;
      this.State = p.State__c;
      this.County = p.County__c;
      this.Zipcode = p.ZipCode__c;
      this.PropertyAPN = p.APN__c;
      this.PropertyType = p.Property_Type__c;
    }
  }

  public class Property extends BaseAddress {
    public String AssetID;
    public String DestinationPartyID;
    public Decimal NumberOfUnits;
    public String PropertyType;
    public String APN;
    public Decimal AllocatedLoanAmount;
    public String ParentProperty;
    public String Remarks;
    public String HOAExists;
    public Decimal HOAAmount;
    public Decimal SpecialAssessmentsAmt;
    public Decimal ExistingDebtAmt;

    public Property(
      Property__c p,
      Map<Id, List<Property__c>> parentToChildMap
    ) {
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

      this.AssetID = p.Asset_ID__c;
      this.DestinationPartyID = p.Refinance_Acquisition__c == 'Refinance'
        ? 'COREVEST-REFI'
        : 'COREVEST-PURCHASE';
      this.NumberOfUnits = p.Number_of_Units__c;
      this.Address1 = p.Name;
      this.Address2 = '';
      this.City = p.City__c;
      this.State = p.State__c;
      this.County = p.County__c;
      this.Zipcode = p.ZipCode__c;
      this.APN = p.APN__c;
      this.PropertyType = p.Property_Type__c;
      this.AllocatedLoanAmount = p.ALA__c;
      this.ParentProperty = p.Is_Parent__c ? 'Y' : 'N';
      this.Remarks = p.Is_Parent__c ? String.join(childAddresses, '; ') : '';
      this.HOAExists = p.Is_HOA__c == 'Yes' ? 'Y' : 'N';
      this.HOAAmount = p.Is_HOA__c == 'Yes' ? p.Monthly_HOA_Fee__c : 0;
      this.SpecialAssessmentsAmt = p.Special_Assesments_CFD_Mello_Roos_etc__c;
      this.ExistingDebtAmt = p.Existing_Debt__c;
    }
  }

  public virtual class ServicelinkBase {
    public String QuoteID; // CV unique ID for quote request
    public String LoanNumber; // CV Loan Number
    public String BulkProjectOrderNum;
    public Decimal LoanAmount;
    public String IncomingTransactionId;
    public String AssetID;
    public String OrderNumber;
  }

  public class QuoteRequest extends ServicelinkBase {
    public String timeStamp;
    public String SourcePartyID;
    public String DestinationPartyID;
    public String LoanPortfolioName; // CV Loan Portfolio Name
    public String Comments;
    public TitleDocument Document; // type is QUOTEREQUEST and send XLSX format. "Data Tape" of properties for the quote request
    public QuoteRequest(
      Opportunity deal,
      Deal_Document__c doc,
      ContentVersion cv,
      Integer sequenceNumber
    ) {
      this.Document = new TitleDocument().generateDocument(cv, 'QUOTEREQUEST');
      this.SourcePartyID = 'COREVEST-SFR';
      this.DestinationPartyID = 'COREVEST-QUOTE';
      this.QuoteID =
        deal.Id +
        '-' +
        String.valueOf(sequenceNumber).leftPad(3, '0');
      this.LoanNumber = deal.Deal_Loan_Number__c;
      this.LoanAmount = deal.Current_Loan_Amount__c;
      this.LoanPortfolioName = deal.Name;
      this.Comments = '';
    }
  }

  public class CancelRequest extends ServicelinkBase {
    public String CancellationDate;
    public String CancelledByFirstName;
    public String CancelledByLastName;
    public CancelRequest(Title_Order__c to) {
      this.BulkProjectOrderNum = to.Bulk_Project_Order_Num__c;
      this.LoanNumber = to.Loan_Number__c;
      this.IncomingTransactionId = to.Incoming_Transaction_Id__c;
      this.CancellationDate = System.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');
      this.CancelledByFirstName = UserInfo.getFirstName();
      this.CancelledByLastName = UserInfo.getLastName();
    }
  }

  public class QuoteAccepted extends ServicelinkBase {
    public String AnticipatedCloseDate;
    public TitleDocument Document;
    public List<ServicelinkContact> Contacts;
    public List<Property> Properties;

    public QuoteAccepted(
      Title_Order__c to,
      ContentVersion cv,
      List<Property__c> props,
      Map<Id, List<Property__c>> parentToChildMap,
      Opportunity deal
    ) {
      this.BulkProjectOrderNum = to.Bulk_Project_Order_Num__c;
      this.QuoteID = to.Quote_ID__c;
      this.LoanNumber = to.Loan_Number__c;
      this.loanAmount = to.Loan_Amount__c;
      this.AnticipatedCloseDate = to.Anticipated_Close_Date__c != null
        ? to.Anticipated_Close_Date__c.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss') +
          '+00:00'
        : '';
      this.Document = new TitleDocument().generateDocument(cv, 'DATATAPE');
      this.Contacts = new List<ServiceLinkContact>();

      List<OpportunityTeamMember> otms = deal?.OpportunityTeamMembers;
      List<Deal_Contact__c> dealContacts = deal?.Deal_Contacts__r;

      for (OpportunityTeamMember otm : otms) {
        this.Contacts.add(new ServiceLinkContact(otm, 'LENDERATTORNEY'));
      }

      for (Deal_Contact__c dc : dealContacts) {
        this.Contacts.add(new ServiceLinkContact(dc, 'LENDERATTORNEY'));
      }

      this.Properties = new List<Property>();
      for (Property__c p : props) {
        this.Properties.add(new Property(p, parentToChildMap));
      }
    }
  }

  public class LoanPortfolioChangeRequest extends ServiceLinkBase {
    public String AnticipatedCloseDate;
    // jonathan will circle back
  }

  public class DocumentSubmission extends ServiceLinkBase {
    public String ClientContractId;
    List<TitleDocument> Documents;
    public DocumentSubmission(
      Title_Order__c to,
      Map<Id, String> cvToDocTypeMap,
      List<ContentVersion> cvs
    ) {
      this.BulkProjectOrderNum = to.Bulk_Project_Order_Num__c;
      this.LoanNumber = to.Loan_Number__c;
      this.OrderNumber = to.Order_Number__c;
      this.AssetID = to.Asset_ID__c;
      this.IncomingTransactionId = to.Incoming_Transaction_Id__c;
      this.ClientContractId = to.Client_Contract_ID__c;
      this.Documents = new List<TitleDocument>();
      for (ContentVersion cv : cvs) {
        String dType = cvToDocTypeMap.get(cv.Id);
        this.Documents.add(new TitleDocument().generateDocument(cv, dType));
      }
    }
  }

  public class OrderChangeRequest extends ServiceLinkBase {
    public Decimal AllocatedLoanAmount;
    public PropertyAddress PropertyAddress;
    public OrderChangeRequest(Title_Order__c to) {
      Property__c p = to.Property__r;
      this.BulkProjectOrderNum = to.Bulk_Project_Order_Num__c;
      this.LoanNumber = to.Loan_Number__c;
      this.AssetID = to.Asset_ID__c;
      this.OrderNumber = to.Order_Number__c;
      this.IncomingTransactionId = to.Incoming_Transaction_Id__c;
      this.PropertyAddress = new PropertyAddress(p);
    }
  }

  public class OrderInquiry extends ServiceLinkBase {
    public String InquiryType;
    public String Comments;
    public String RequestorEmail;
    public List<TitleDocument> Documents;
    public OrderInquiry (Title_Order__c to, List<ContentVersion> cvs, Map<Id,String> cvToDocType, String inquiryType, String comments) {
      this.BulkProjectOrderNum = to.Bulk_Project_Order_Num__c;
      this.LoanNumber = to.Loan_Number__c;
      this.IncomingTransactionId = to.Incoming_Transaction_Id__c;
      this.AssetID = to.Asset_ID__c;
      this.OrderNumber = to.Order_Number__c;
      this.InquiryType = inquiryType;
      this.Comments = comments;
      this.RequestorEmail = UserInfo.getUserEmail();
      this.Documents = new List<TitleDocument>();
      for(ContentVersion cv :cvs) {
        this.Documents.add(new TitleDocument().generateDocument(cv, cvToDocType.get(cv.Id)));
      }
      
    }
  }
  
}