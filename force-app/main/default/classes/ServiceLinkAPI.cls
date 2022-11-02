public without sharing class ServiceLinkAPI {
  public static final Map<String,String> PROP_TYPE_MAP = new Map<String, String> {
    'sfr' => 'SINGLE_FAM',
    'townhome' => 'TOWN',
    'condo' => 'CONDO',
    'mixed use' => 'MIX',
    'commercial' => 'COMM',
    'pud' => 'PUD',
    'other' => 'OTH',
    'multifamily' => 'MULTI_FAM',
    'manufactured housing' => 'MANUF',
    'land/lot' => 'VACANT',
    'land' => 'VACANT',
    'lot' => 'VACANT',
    '2-4 unit,2' => 'DUPLEX',
    '2-4 unit,3' => 'TRIPLEX',
    '2-4 unit,4' => 'FOURPLEX'
  };

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
    public String Name;
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

    public Borrower(Deal_Contact__c dc) {
      // 1 - individual, 2 - business entity, 3- trust
      this.BorrowerType = dc.Deal_Contact_Type__c == 'Entity' ? '2' : '1';
      this.Name = '';
      this.FirstName = '';
      this.MiddleName = '';
      this.LastName = '';
      this.Address1 = '';
      this.Address2 = '';
      this.City = '';
      this.State = '';
      this.Zipcode = '';
      this.EmailAddress = '';
      this.MobilePhone = '';
      this.TrustDate = '';
      this.Trustee1Name = '';
      this.Trustee2Name = '';
      this.Trustee3Name = '';
      this.Trustee4Name = '';

      Contact c = dc?.Contact__r;
      Account a = dc?.Account__r;

      if (dc.Deal_Contact_Type__c == 'Entity' && a != null) {
        this.Name = a.Name;
        this.Address1 = stringEval(a.BillingStreet);
        this.City = stringEval(a.BillingCity);
        this.State = stringEval(a.BillingState);
        this.Zipcode = stringEval(a.BillingPostalCode);
        this.EmailAddress = stringEval(dc.Email__c);
        this.MobilePhone = stringEval(a.Phone);
      } else if (c != null) {
        this.FirstName = stringEval(c.FirstName);
        this.MiddleName = stringEval(c.MiddleName);
        this.LastName = stringEval(c.LastName);
        this.Address1 = stringEval(c.MailingStreet);
        this.City = stringEval(c.MailingCity);
        this.State = stringEval(c.MailingState);
        this.Zipcode = stringEval(c.MailingPostalCode);
        this.EmailAddress = stringEval(c.Email);
        this.MobilePhone = stringEval(c.MobilePhone, c.Phone);
      }
    }
  }

  public class PropertyAddress extends BaseAddress {
    public String PropertyType;
    public String PropertyAPN;
    public PropertyAddress(Property__c p) {
      String propTypeKey = p.Property_Type__c.toLowerCase();

      if(p.Number_of_Units__c != null && propTypeKey == '2-4 unit') {
        propTypeKey = propTypeKey + ',' + p.Number_of_Units__c;
      }
      this.Address1 = p.Name;
      this.Address2 = '';
      this.City = p.City__c;
      this.State = p.State__c;
      this.County = p.County__c;
      this.Zipcode = p.ZipCode__c;
      this.PropertyAPN = String.isNotEmpty(p.APN__c) ? p.APN__c : '';
      this.PropertyType = PROP_TYPE_MAP.containsKey(propTypeKey) ? PROP_TYPE_MAP.get(propTypeKey) : 'OTH';
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

      String propTypeKey = p.Property_Type__c.toLowerCase();

      if(p.Number_of_Units__c != null && propTypeKey == '2-4 unit') {
        propTypeKey = propTypeKey + ',' + p.Number_of_Units__c;
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
      this.PropertyType = PROP_TYPE_MAP.containsKey(propTypeKey) ? PROP_TYPE_MAP.get(propTypeKey) : 'OTH';
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
      ContentVersion cv,
      String quoteId,
      String comments
    ) {
      this.Document = new TitleDocument().generateDocument(cv, 'QUOTEREQUEST');
      this.SourcePartyID = 'COREVEST-SFR';
      this.DestinationPartyID = 'COREVEST-QUOTE';
      this.QuoteID =quoteId;
      this.LoanNumber = deal.Deal_Loan_Number__c;
      this.LoanAmount = deal.Current_Loan_Amount__c;
      this.LoanPortfolioName = deal.Name;
      this.Comments = comments;
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
      this.loanAmount = to.Deal__r.Current_Loan_Amount__c;
      this.AnticipatedCloseDate = to.Anticipated_Close_Date__c != null
        ? to.Anticipated_Close_Date__c.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss') +
          '+00:00'
        : '';
      this.Document = new TitleDocument().generateDocument(cv, 'DATATAPE');
      this.Contacts = new List<ServiceLinkContact>();

      List<Deal_Contact__c> dealContacts = deal?.Deal_Contacts__r;

      if(deal.Closer__r != null) {
        this.Contacts.add(new ServiceLinkContact(deal.Closer__r, 'LOANCLOSER'));
      }

      if(deal.Underwriter__r != null) {
        this.Contacts.add(new ServiceLinkContact(deal.Underwriter__r, 'LOANUNDERWRITER'));
      }

      if(deal.Loan_Coordinator__r != null) {
        this.Contacts.add(new ServiceLinkContact(deal.Loan_Coordinator__r, 'LOANMANAGER'));
      }

      if(deal.Owner != null) {
        this.Contacts.add(new ServiceLinkContact(deal.Owner, 'LOANORIGINATOR'));
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
    public TitleDocument Document;
    public List<ServicelinkContact> Contacts;
    public List<Borrower> BorrowerDetails;
    public List<Property> Properties;
    public LoanPortfolioChangeRequest(
      Title_Order__c to,
      ContentVersion cv,
      List<Property__c> props,
      Map<Id, List<Property__c>> parentToChildMap,
      Map<String, Deal_Contact__c> typeDealContactMap,
      Map<String, User> typeUserMap
    ) {
      this.BulkProjectOrderNum = to.Bulk_Project_Order_Num__c;
      this.LoanNumber = to.Loan_Number__c;
      this.LoanAmount = to.Deal__r.Current_Loan_Amount__c;
      this.AnticipatedCloseDate = to.Anticipated_Close_Date__c != null
        ? to.Anticipated_Close_Date__c.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss') +
          '+00:00'
        : '';
      this.Document = new TitleDocument().generateDocument(cv, 'DATATAPE');

      this.Contacts = new List<ServiceLinkContact>();
      this.BorrowerDetails = new List<Borrower>();

      if(typeDealContactMap.size() > 0) {
        for(String type : typeDealContactMap.keySet()) {
          if(type == 'BORROWER') {
            this.BorrowerDetails.add(new Borrower(typeDealContactMap.get(type)));
          } else {
            this.Contacts.add(new ServiceLinkContact(typeDealContactMap.get(type), type));
          }
        }
      }

      if(typeUserMap.size() > 0) {
        for(String type : typeUserMap.keySet()) {
          this.Contacts.add(new ServiceLinkContact(typeUserMap.get(type), type));
        }
       }


      this.Properties = new List<Property>();
      if(props.size() > 0) {
        for (Property__c p : props) {
          this.Properties.add(new Property(p, parentToChildMap));
        }
      }
    }
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
    public OrderChangeRequest(Property_Title__c pt, String incTransacId) {
      Title_Order__c to = pt.Title_Order__r;
      Property__c p = pt.Property__r;
      this.BulkProjectOrderNum = to.Bulk_Project_Order_Num__c;
      this.LoanNumber = to.Loan_Number__c;
      this.AssetID = p.Asset_ID__c;
      this.OrderNumber = pt.OrderNumber__c;
      this.IncomingTransactionId = incTransacId;
      this.AllocatedLoanAmount = p.ALA__c;
      this.PropertyAddress = new PropertyAddress(p);
    }
  }

  public class OrderInquiry extends ServiceLinkBase {
    public String InquiryType;
    public String Comments;
    public String RequestorEmail;
    public List<TitleDocument> Documents;
    public OrderInquiry(
      Title_Order__c to,
      ContentVersion cv,
      String inquiryType,
      String comments,
      String incTransacId,
      Property_Title__c pt
    ) {
      this.BulkProjectOrderNum = to.Bulk_Project_Order_Num__c;
      this.LoanNumber = to.Loan_Number__c;
      this.IncomingTransactionId = incTransacId;
      this.AssetID = pt?.Property__r.Asset_ID__c != null ? pt.Property__r.Asset_ID__c : '';
      this.OrderNumber = pt?.OrderNumber__c != null ? pt.OrderNumber__c : '' ;
      this.InquiryType = inquiryType;
      this.Comments = comments;
      this.RequestorEmail = UserInfo.getUserEmail();
      this.Documents = new List<TitleDocument>();
      if (inquiryType == 'REVISEDQUO') {
        this.Documents.add(
          new TitleDocument().generateDocument(cv, 'REVQUOTEREQ')
        );  
      }
    }
  }

  public static String stringEval(String v, String w) {
    return v != null && String.isNotEmpty(v) ? v : w;
  }

  public static String stringEval(String v) {
    return v != null && String.isNotEmpty(v) ? v : '';
  }
}