@RestResource(urlMapping='/portal/user/*')
global without sharing class PortalAPIUser {
  public static String portalId;
  public static Integer paginationStart;
  public static Integer paginationEnd;
  public static Boolean usePagination;

  @HttpGet
  global static void doGet() {
    RestRequest req = RestContext.request;
    RestResponse res = Restcontext.response;

    List<String> params = Restcontext.request.requestURI.split('/');

    String pageSizeParam = RestContext.request.params.get('pageSize');
    Integer pageSize = null;
    if (String.isNotBlank(pageSizeParam)) {
      pageSize = Integer.valueOf(pageSizeParam);
    }

    Integer page = null;
    String pageParam = RestContext.request.params.get('page');
    if (String.isNotBlank(pageParam)) {
      page = Integer.valueOf(pageParam);
    }

    usePagination = false;
    if (pageSize != null && page != null) {
      paginationStart = (page - 1) * pageSize; //2
      paginationEnd = page * pageSize; //3
      usePagination = true;
    }

    if (params[3] == 'entryId') {
      String entryId = params[4];
      List<Lead> leads = [
        SELECT
          Id,
          FirstName,
          LastName,
          Alchemy_Portal_Id__c,
          Email,
          Form_Title__c,
          Phone,
          Entry_Id__c
        FROM Lead
        WHERE
          Entry_Id__c = :entryId
          AND Alchemy_Portal_Id__c != NULL
          AND Alchemy_Portal_Id__c != 'xx'
      ];

      if (!Test.isRunningTest()) {
        while (leads.size() == 0) {
          Long startTime = DateTime.now().getTime();
          Long finishTime = DateTime.now().getTime();
          while ((finishTime - startTime) < 9000) {
            //sleep for 9s
            finishTime = DateTime.now().getTime();
          }

          leads = [
            SELECT
              Id,
              FirstName,
              LastName,
              Alchemy_Portal_Id__c,
              Email,
              Form_Title__c,
              Phone,
              Entry_Id__c
            FROM Lead
            WHERE
              Entry_Id__c = :entryId
              AND Alchemy_Portal_Id__c != NULL
              AND Alchemy_Portal_Id__c != 'xx'
          ];
        }
      }

      if (leads.size() > 0) {
        Map<String, String> responseBody = new Map<String, String>();
        responseBody.put('userId', leads[0].Alchemy_Portal_Id__c);
        // responseBody.put('name', leads[0].Name);
        responseBody.put('firstName', leads[0].FIrstName);
        responseBody.put('lastName', leads[0].LastName);
        responseBody.put('email', leads[0].Email);
        responseBody.put('formTitle', leads[0].Form_Title__c);
        responseBody.put('entryId', leads[0].Entry_Id__c);

        system.debug(responseBody);

        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(responseBody, true));
      } else {
        Map<String, String> responseBody = new Map<String, String>();
        responseBody.put('status', 'error');
        responseBody.put('message', 'Entry Id not found');

        res.addHeader('Content-Type', 'application/json');
        res.statusCode = 404;
        res.responseBody = Blob.valueOf(JSON.serialize(responseBody, true));
      }
    } else if (params[3] == 'operations') {
      portalId = params[4];

      List<User> user = [SELECT Id FROM User WHERE Portal_Id__c = :portalId];

      if (user.size() > 0) {
        Id userId = user[0].Id;

        Set<String> borrowerIds = new Set<String>();
        for (Contact c : [
          SELECT Id, Alchemy_Portal_Id__c
          FROM Contact
          WHERE
            OwnerId = :userId
            AND RecordType.DeveloperName = 'Borrower'
            AND Alchemy_Portal_Id__c != NULL
        ]) {
          borrowerIds.add(c.alchemy_portal_id__c);
        }

        for (Lead l : [
          SELECT Id, Alchemy_Portal_Id__c
          FROM Lead
          WHERE
            OwnerId = :userId
            AND IsConverted = FALSE
            AND Alchemy_Portal_Id__c != NULL
        ]) {
          borrowerIds.add(l.Alchemy_Portal_Id__c);
        }

        for (OpportunityTeamMember otm : [
          SELECT Id, Opportunity.Contact__r.Alchemy_Portal_Id__c
          FROM OpportunityTeamMember
          WHERE
            UserId = :userId
            AND Opportunity.Contact__r.RecordType.DeveloperName = 'Borrower'
            AND Opportunity.Contact__r.Alchemy_Portal_Id__c != NULL
        ]) {
          borrowerIds.add(otm.Opportunity.Contact__r.Alchemy_Portal_Id__c);
        }

        List<Borrower> borrowers = new List<Borrower>();
        for (Lead l : [
          SELECT
            Id,
            Alchemy_Portal_Id__c,
            CreatedDate,
            Portal_Last_Login__c,
            LastName,
            FirstName,
            Email
          FROM Lead
          WHERE Alchemy_Portal_Id__c IN :borrowerIds AND IsConverted = FALSE
        ]) {
          borrowers.add(new Borrower(l));
        }

        for (Contact c : [
          SELECT
            Id,
            Alchemy_Portal_Id__c,
            CreatedDate,
            Portal_Last_Login__c,
            FirstName,
            LastName,
            Email
          FROM Contact
          WHERE Alchemy_Portal_Id__c IN :borrowerIds
        ]) {
          borrowers.add(new Borrower(c));
        }

        borrowers.sort();

        if (params.size() > 6 && params[6] == 'count') {
          Map<String, Object> responseBody = new Map<String, Object>();
          responseBody.put('count', borrowers.size());
          res.addHeader('Content-Type', 'application/json');
          res.responseBody = Blob.valueOf(JSON.serialize(responseBody));
        } else {
          List<Borrower> borrowersToSend = new List<Borrower>();
          if (usePagination) {
            for (Integer i = paginationStart; i < paginationEnd; i++) {
              if (i < borrowers.size()) {
                borrowersToSend.add(borrowers[i]);
              }
            }
          } else {
            borrowersToSend = borrowers;
          }

          res.addHeader('Content-Type', 'application/json');
          res.responseBody = Blob.valueOf(JSON.serialize(borrowersToSend));
        }
      } else {
        Map<String, String> responseBody = new Map<String, String>();
        responseBody.put('status', 'error');
        responseBody.put('message', 'User Id not found');

        res.addHeader('Content-Type', 'application/json');
        res.statusCode = 404;
        res.responseBody = Blob.valueOf(JSON.serialize(responseBody, true));
      }
    } else {
      portalId = params[3];
      PortalUser user = new PortalUser(portalId);
      if (user.id != null) {
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(user));
      } else {
        Map<String, String> responseBody = new Map<String, String>();
        responseBody.put('status', 'error');
        responseBody.put('message', 'Entry Id not found');

        res.addHeader('Content-Type', 'application/json');
        res.statusCode = 404;
        res.responseBody = Blob.valueOf(JSON.serialize(responseBody, true));
      }
    }
  }

  @HttpPatch
  global static void doPatch() {
    RestRequest req = RestContext.request;
    RestResponse res = Restcontext.response;

    List<String> params = Restcontext.request.requestURI.split('/');
    portalId = params[3];
    PortalUser user = new PortalUser(portalId);

    system.debug(portalId);
    if (user.id != null) {
      PortalUser userCopy = (PortalUser) JSON.deserialize(
        req.requestBody.toString(),
        PortalUser.class
      );

      String sobjectType = 'Lead';
      if (user.contactId != null) {
        sobjectType = 'Contact';
      } else if (user.leadId != null) {
        sobjectType = 'Lead';
      } else {
        sobjectType = 'User';
      }
      if (sobjectType != 'User') {
        sObject record = userCopy.getRecord(sobjectType);
        // system.debug(record);
        Map<String, Object> fieldsToValue = record.getPopulatedFieldsAsMap();
        record = user.getRecord(); //record.Id.getSObjectType().newSObject(record.Id);
        // system.debug(fieldsToValue);
        for (String fieldName : fieldsToValue.keySet()) {
          if (fieldsToValue.get(fieldName) != null) {
            record.put(fieldName, fieldsToValue.get(fieldName));
          }
        }

        update record;
        //user.updateUser();
        user = new PortalUser(portalId);
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(user, true));
      }
    } else {
      Map<String, String> responseBody = new Map<String, String>();
      responseBody.put('status', 'error');
      responseBody.put('message', 'User not found');
      res.statusCode = 404;
      res.addHeader('Content-Type', 'application/json');
      res.responseBody = Blob.valueOf(JSON.serialize(responseBody, true));
    }
  }

  public class PortalUser {
    public String firstName;
    public String lastName;
    public String fax;
    public String mobilePhone;
    public String businessPhone;
    public String email;
    public String portalUsername;
    public String homeStreetAddress;
    public String homeCity;
    public String homeState;
    public String homeZip;
    public String homeCountry;
    public String businessStreetAddress;
    public String businessCity;
    public String businessState;
    public String businessStateCode;
    public String businessCountry;
    public String businessZip;
    public String leadId;
    public String userType;
    public String id;
    public String contactId;
    public String accountId;
    public String accountType;
    public String companyName;

    public String title;
    public String alternativeEmail;
    public String licenseNo;
    public Decimal yearsOfExperience;

    public DateTime lastLogin;

    public PortalUser(String portalId) {
      Id contactId = AlchemyAPI.getContactIdByAlchemyId(portalId);
      Id leadId = AlchemyAPI.getLeadIdByAlchemyId(portalId);
      Id userId = AlchemyAPI.getUserIdByPortalId(portalId);

      if (contactId != null) {
        Contact c = [
          SELECT
            Id,
            FirstName,
            LastName,
            Fax,
            MobilePhone,
            Phone,
            Email,
            Portal_Username__c,
            MailingStreet,
            MailingCity,
            MailingState,
            MailingStateCode,
            MailingPostalCode,
            MailingCountry,
            Alchemy_Portal_Id__c,
            SponsorHomeAddress__c,
            SponsorCity__c,
            SponsorZipCode__c,
            Home_Country__c,
            SponsorState__c,
            AccountId,
            Alternative_Email__c,
            License_No__c,
            Years_of_Experience__c,
            Account.Name,
            Account.RecordType.DeveloperName,
            Account.Non_Borrower_Account_Type__c,
            Title,
            Portal_Last_Login__c
          FROM Contact
          WHERE Id = :contactId
          LIMIT 1
        ];
        this.id = c.Alchemy_Portal_Id__c;
        this.firstName = c.FirstName;
        this.lastName = c.LastName;
        this.Fax = c.Fax;
        this.mobilePhone = c.MobilePhone;
        this.businessphone = c.Phone;
        this.email = c.Email;
        this.portalUserName = c.Portal_Username__c;
        this.businessStreetAddress = c.MailingStreet;
        this.businessCity = c.MailingCity;
        this.businessStreetAddress = c.MailingStreet;
        this.businessState = c.MailingState;
        this.businessStateCode = c.MailingStateCode;
        this.businessZip = c.MailingPostalCode;
        this.businessCountry = c.MailingCountry;
        this.contactId = c.Id;

        this.homeStreetAddress = c.SPonsorHomeAddress__c;
        this.homeCity = c.SPonsorCity__c;
        this.homeState = c.SponsorState__c;
        this.homeCountry = c.Home_Country__c;
        this.homeZip = c.SponsorZipCode__c;
        this.accountId = c.AccountId;
        this.accountType = c.Account.Non_Borrower_Account_Type__c;
        if (c.Account.RecordType.DeveloperName == 'vendor') {
          this.userType = 'vendor';
        }

        this.title = c.Title;
        this.alternativeEmail = c.Alternative_Email__c;
        this.licenseNo = c.License_No__c;
        this.yearsOfExperience = c.Years_of_Experience__c;
        this.companyName = c.Account.Name;
        this.lastLogin = c.Portal_Last_Login__c;
      } else if (leadId != null) {
        Lead l = [
          SELECT
            Id,
            FirstName,
            LastName,
            Fax,
            Phone,
            MobilePhone,
            Email,
            Portal_Username__c,
            Street,
            City,
            State,
            StateCode,
            PostalCode,
            Country,
            Alchemy_Portal_Id__c,
            Home_Street_Address__c,
            Home_City__c,
            Home_State__c,
            Home_Zip__c,
            Home_Country__c,
            Company,
            Portal_Last_Login__c
          FROM Lead
          WHERE Id = :leadId
          LIMIT 1
        ];

        this.leadId = l.Id;
        this.id = l.Alchemy_Portal_Id__c;
        this.firstName = l.FirstName;
        this.lastName = l.LastName;
        this.fax = l.Fax;
        this.MobilePhone = l.MobilePhone;
        this.BusinessPhone = l.Phone;
        this.email = l.Email;
        this.portalUsername = l.Portal_Username__c;
        this.businessStreetAddress = l.Street;
        this.businessCity = l.City;
        this.businessState = l.State;
        this.businessStateCode = l.StateCode;
        this.businessCountry = l.country;
        this.businessZip = l.PostalCode;
        this.homeStreetAddress = l.Home_Street_Address__c;
        this.homeCity = l.Home_City__c;
        this.homeState = l.Home_State__c;
        this.homeCountry = l.Home_Country__c;
        this.homeZip = l.Home_Zip__c;
        this.companyName = l.Company;
        this.lastLogin = l.Portal_Last_Login__c;
      } else if (portalId != null) {
        User u = [
          SELECT Id, FirstName, LastName, Portal_Id__c, Email
          FROM User
          WHERE Id = :userId
          LIMIT 1
        ];
        this.id = u.Portal_Id__c;
        this.firstName = u.FirstName;
        this.lastName = u.LastName;
        this.email = u.Email;
      }
    }

    // public void updateUser() {
    //   if (this.contactId != null) {
    // Contact c = new Contact(Id = this.contactId);
    // c.FirstName = this.firstName;
    // c.LastName = this.lastName;
    // c.Fax = this.Fax;
    // c.MobilePhone = this.mobilePhone;
    // c.Phone = this.businessphone;
    // c.Email = this.email;
    // c.Portal_Username__c = this.portalUserName;
    // c.MailingStreet = this.businessStreetAddress;
    // c.MailingCity = this.businessCity;
    // c.MailingStreet = this.businessStreetAddress;
    // c.MailingState = this.businessState;
    // c.MailingStateCode = this.businessStateCode;
    // c.MailingPostalCode = this.businessZip;
    // c.MailingCountry = this.businessCountry;

    //     update c;
    //   } else if (this.leadId != null) {
    //     Lead l = new Lead(Id = this.leadId);

    //     l.FirstName = this.firstName;
    //     l.LastName = this.lastName;
    //     l.Fax = this.fax;
    //     l.MobilePhone = this.mobilePhone;
    //     l.Phone = this.BusinessPhone;
    //     l.Email = this.email;
    //     l.Portal_Username__c = this.portalUsername;
    //     l.Street = this.businessStreetAddress;
    //     l.City = this.businessCity;
    //     l.State = this.businessState;
    //     l.StateCode = this.businessStateCode;
    //     l.country = this.businessCountry;

    //     update l;
    //   }
    // }
    public sObject getRecord() {
      sObject record;
      // system.debug(this.contactId);
      // system.debug(this.leadId);
      if (this.contactId != null) {
        Contact c = new Contact(Id = this.contactId);
        c.FirstName = this.firstName;
        c.LastName = this.lastName;
        c.Fax = this.Fax;
        c.MobilePhone = this.mobilePhone;
        c.Phone = this.businessphone;
        c.Email = this.email;
        c.Portal_Username__c = this.portalUserName;
        c.MailingStreet = this.businessStreetAddress;
        c.MailingCity = this.businessCity;
        c.MailingStreet = this.businessStreetAddress;
        c.MailingState = this.businessState;
        c.MailingStateCode = this.businessStateCode;
        c.MailingPostalCode = this.businessZip;
        c.MailingCountry = this.businessCountry;

        c.SponsorHomeAddress__c = this.homeStreetAddress;
        c.SponsorCity__c = this.homeCity;
        c.SponsorState__c = this.homeState;
        c.SponsorZipCode__c = this.homeZip;
        c.Home_Country__c = this.homeCountry;

        c.Title = this.title;
        c.Alternative_Email__c = this.alternativeEmail;
        c.License_No__c = this.licenseNo;
        c.Years_of_Experience__c = this.yearsOfExperience;
        c.Portal_Last_Login__c = this.lastLogin;

        record = c;
      } else if (this.leadId != null) {
        Lead l = new Lead(Id = this.leadId);
        l.FirstName = this.firstName;
        l.LastName = this.lastName;
        l.Fax = this.fax;
        l.MobilePhone = this.mobilePhone;
        l.Phone = this.BusinessPhone;
        l.Email = this.email;
        l.Portal_Username__c = this.portalUsername;
        l.Street = this.businessStreetAddress;
        l.City = this.businessCity;
        l.State = this.businessState;
        l.StateCode = this.businessStateCode;
        l.country = this.businessCountry;
        system.debug(businessZip);
        l.PostalCode = this.businessZip;
        l.Home_Street_Address__c = this.homeStreetAddress;
        l.Home_City__c = this.homeCity;
        l.Home_Zip__c = this.homeZip;
        l.Home_Country__c = this.homeCountry;
        l.Home_State__c = this.homeState;
        l.Portal_Last_Login__c = this.lastLogin;

        record = l;
      }

      return record;
    }

    public sObject getRecord(String sobjectType) {
      sObject record;
      // system.debug(this.contactId);
      // system.debug(this.leadId);
      if (sobjectType == 'Contact') {
        Contact c = new Contact();
        c.FirstName = this.firstName;
        c.LastName = this.lastName;
        c.Fax = this.Fax;
        c.MobilePhone = this.mobilePhone;
        c.Phone = this.businessphone;
        c.Email = this.email;
        c.Portal_Username__c = this.portalUserName;
        c.MailingStreet = this.businessStreetAddress;
        c.MailingCity = this.businessCity;
        c.MailingStreet = this.businessStreetAddress;
        c.MailingState = this.businessState;
        c.MailingStateCode = this.businessStateCode;
        c.MailingPostalCode = this.businessZip;
        c.MailingCountry = this.businessCountry;

        c.SponsorHomeAddress__c = this.homeStreetAddress;
        c.SponsorCity__c = this.homeCity;
        c.SponsorState__c = this.homeState;
        c.SponsorZipCode__c = this.homeZip;
        c.Home_Country__c = this.homeCountry;

        c.Title = this.title;
        c.Alternative_Email__c = this.alternativeEmail;
        c.License_No__c = this.licenseNo;
        c.Years_of_Experience__c = this.yearsOfExperience;
        c.Portal_Last_Login__c = this.lastLogin;

        record = c;
      } else if (sobjectType == 'Lead') {
        Lead l = new Lead();
        l.FirstName = this.firstName;
        l.LastName = this.lastName;
        l.Fax = this.fax;
        l.MobilePhone = this.mobilePhone;
        l.Phone = this.BusinessPhone;
        l.Email = this.email;
        l.Portal_Username__c = this.portalUsername;
        l.Street = this.businessStreetAddress;
        l.City = this.businessCity;
        l.State = this.businessState;
        l.StateCode = this.businessStateCode;
        l.country = this.businessCountry;
        system.debug(this.businessZip);
        l.PostalCode = this.businessZip;

        l.Home_Street_Address__c = this.homeStreetAddress;
        l.Home_City__c = this.homeCity;
        l.Home_Zip__c = this.homeZip;
        l.Home_Country__c = this.homeCountry;
        l.Home_State__c = this.homeState;
        l.Portal_Last_Login__c = this.lastLogin;

        record = l;
      }

      return record;
    }
  }

  class Borrower implements Comparable {
    String userId;
    String email;
    DateTime createdDate;
    DateTime lastLoginDate;
    String firstName;
    String lastName;

    public Integer compareTo(Object compareTo) {
      Borrower compareToBor = (Borrower) compareTo;
      if (this.createdDate == compareToBor.createdDate)
        return 0;
      if (this.createdDate > compareToBor.createdDate)
        return -1;
      return 1;
    }

    Borrower(Contact c) {
      this.firstName = c.FirstName;
      this.lastName = c.LastName;

      this.email = c.Email;
      this.createdDate = c.CreatedDate;
      this.lastLoginDate = c.Portal_Last_Login__c;
      this.userId = c.Alchemy_Portal_Id__c;
    }

    Borrower(Lead l) {
      this.firstName = l.FirstName;
      this.lastName = l.lastName;

      this.email = l.Email;
      this.userId = l.Alchemy_Portal_Id__c;
      this.createdDate = l.CreatedDate;
      this.lastLoginDate = l.Portal_Last_Login__c;
    }
  }
}