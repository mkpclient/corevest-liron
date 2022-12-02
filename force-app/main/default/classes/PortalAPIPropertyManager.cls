@RestResource(urlMapping='/portal/propertymanager/*')
global without sharing class PortalAPIPropertyManager {
  public static PortalAPIUser.PortalUser user;

  @HttpGet
  global static void doGet() {
    RestRequest req = RestContext.request;
    RestResponse res = Restcontext.response;

    List<String> params = Restcontext.request.requestURI.split('/');
    system.debug(params);
    if (params[3] == 'propertyId' || params[3] == 'dealId') {
    } else if (params[3] == 'dashboard') {
      String portalId = params[4];

      user = new PortalAPIUser.PortalUser(portalId);

      Dashboard dashboard = new Dashboard(user);
      res.responseBody = Blob.valueOf(JSON.serialize(dashboard, true));
    } else if (params[3] == 'questionnaire') {
      if (params[4] == 'prefill') {
        Id dealId = params[5];
        Opportunity deal = [
          SELECT
            Id,
            Name,
            Contact__c,
            Contact__r.Name,
            Contact__r.Alchemy_Portal_Id__c
          FROM Opportunity
          WHERE Id = :dealId
        ];

        Questionnaire questionnaire = new Questionnaire(deal);

        if (params.size() > 6 && params[6].contains('-')) {
          String propertyManagerId = params[6];
          PortalAPIUser.PortalUser user = new PortalAPIUser.PortalUser(
            propertyManagerId
          );

          questionnaire.propertyManagementCompanyName = user.companyName;
          questionnaire.propertyManagerName =
            user.firstname +
            ' ' +
            user.lastname;
          questionnaire.propertyManagerEmail = user.email;
          questionnaire.propertyManagerPhoneNumber = user.businessphone;
        }

        res.responseBody = Blob.valueOf(JSON.serialize(questionnaire, true));
      } else {
        Id questionnaireId = params[4];
        Property_Manager_Questionnaire__c questionnaire = queryQuestionnaire(
          questionnaireId
        );
        if (questionnaire != null) {
          Questionnaire ques = new Questionnaire(questionnaire);
          res.responseBody = Blob.valueOf(JSON.serialize(ques, true));
        }
      }
    }
    res.addHeader('Content-Type', 'application/json');
  }

  @HttpPost
  global static void doPost() {
    RestRequest req = RestContext.request;
    RestResponse res = Restcontext.response;

    List<String> params = Restcontext.request.requestURI.split('/');

    if (params[3] == 'invite') {
      // String borrowerId = (String) body.get('borrowerId');
      // String propertyManagerId = (String) body.get('propertyManagerId');
      // String dealId = (String) body.get('dealId');
      // String propertyManagerEmail = (String) body.get('propertyManagerEmail');
      // String propertyManagerFirstName = (String) body.get(
      //   'propertyManagerFirstName'
      // );
      // String propertyManagerLastName = (String) body.get(
      //   'propertyManagerLastName'
      // );

      // String companyName = (String) body.get('propertyManagerCompany');

      // Id contactId;
      // Id accountId;
      // List<Contact> existingContacts = [
      //   SELECT Id, AccountId
      //   FROM Contact
      //   WHERE Alchemy_Portal_Id__c = :propertyManagerId
      // ];

      // if (existingContacts.size() > 0) {
      //   contactId = existingContacts[0].Id;
      //   accountId = existingContacts[0].AccountId;
      // }

      // if (contactId == null) {
      //   RecordType vendorRecordType = [
      //     SELECT Id
      //     FROM RecordType
      //     WHERE DeveloperName LIKE '%vendor%'
      //     LIMIT 1
      //   ];
      //   Account propertyManagerAccount = new Account();
      //   acc.Name = companyName;

      //   acc.Do_Not_Lend__c = false;
      //   acc.recordTypeId = vendorRecordType.Id;
      //   acc.Non_Borrower_Account_Type__c = 'Property Manager';

      //   insert account;

      //   Contact propertyManagerContact = new Contact();
      //   propertyManagerContact.FirstName = propertyManagerFirstName;
      //   propertyManagerContact.LastName = propertyManagerLastName;

      //   insert contact;
      //   contactId = contact;
      // }

      // Deal_Contact__c dc = new Deal_Contact__c;
      // dc.Deal__c = dealId;
      // dc.Contact__c = contactId;
      // dc.Deal_Contact_Type__c = 'Vendor';
      // dc.Account__c = acc.Id;
      // dc.Vendor_Type__c = 'Property Manager';
    } else if (params[3] == 'questionnaire') {
      Questionnaire questionnaire = (Questionnaire) JSON.deserialize(
        req.requestBody.toString(),
        Questionnaire.class
      );

      Property_Manager_Questionnaire__c questionnaireRecord = questionnaire.getRecord();

      if (
        questionnaireRecord.Borrower__c == null &&
        questionnaireRecord.Borrower_Portal_Id__c != null
      ) {
        Contact borrower = [
          SELECT Id
          FROM Contact
          WHERE
            Alchemy_Portal_Id__c = :questionnaireRecord.Borrower_Portal_Id__c
          LIMIT 1
        ];
        questionnaireRecord.Borrower__c = borrower.Id;
      }

      if (
        questionnaireRecord.Property_Manager__c == null &&
        questionnaireRecord.Property_Manager_Portal_Id__c != null
      ) {
        Contact propManager = [
          SELECT Id
          FROM Contact
          WHERE
            Alchemy_Portal_Id__c = :questionnaireRecord.Property_Manager_Portal_Id__c
          LIMIT 1
        ];
        questionnaireRecord.Property_Manager__c = propManager.Id;
      }

      if (
        questionnaireRecord.Deal__c == null &&
        questionnaireRecord.Property__c != null
      ) {
        Property__c prop = [
          SELECT Id, Deal__c
          FROM Property__c
          WHERE Id = :questionnaireRecord.Property__c
          LIMIT 1
        ];
        questionnaireRecord.Deal__c = questionnaireRecord.Deal__c = prop.Deal__c;
      }
      questionnaireRecord.Status__c = 'Pending';
      insert questionnaireRecord;

      questionnaire.id = questionnaireRecord.Id;
      // List<Questionnaire> extensions = new List<Questionnaire>();
      // for (Property_Manager_Questionnaire__c extensionRecord : questionnaireRecords) {
      //   extensions.add(new Questionnaire(extensionRecord));
      // }

      res.addHeader('Content-Type', 'application/json');
      res.responseBody = Blob.valueOf(JSON.serialize(questionnaire, true));
    }
  }

  @HttpPatch
  global static void doPatch() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;

    List<String> params = Restcontext.request.requestURI.split('/');

    Id questionnaireId = params[4];

    Property_Manager_Questionnaire__c questionnaire = queryQuestionnaire(
      questionnaireId
    );
    system.debug(req.requestBody.toString());
    if (questionnaire != null) {
      //String loanType = application.Loan_Type__c;

      Questionnaire ques = (Questionnaire) System.JSON.deserialize(
        req.requestBody.toString(),
        Questionnaire.class
      );

      ques.id = params[4];

      questionnaire = ques.getRecord();
      Map<String, Object> fieldsToValue = questionnaire.getPopulatedFieldsAsMap();
      questionnaire = new Property_Manager_Questionnaire__c();
      for (String fieldName : fieldsToValue.keySet()) {
        if (fieldsToValue.get(fieldName) != null) {
          questionnaire.put(fieldName, fieldsToValue.get(fieldName));
        }
      }
      update questionnaire;
      ques = (Questionnaire) JSON.deserialize(
        req.requestBody.toString(),
        Questionnaire.class
      );

      ques.id = questionnaire.Id;
      res.addHeader('Content-Type', 'application/json');
      res.responseBody = Blob.valueOf(JSON.serialize(ques, true));
    } else {
      Map<String, String> respBody = new Map<String, String>();

      res.addHeader('Content-Type', 'application/json');
      respBody.put('status', 'error');
      respBody.put('message', 'Application Id Not Found');
      res.responseBody = Blob.valueOf(JSON.serialize(respBody, true));
    }
  }

  @HttpDelete
  global static void doDelete() {
    RestRequest req = RestContext.request;
    RestResponse res = Restcontext.response;

    List<String> params = Restcontext.request.requestURI.split('/');

    String questionnaireId = params[4];

    List<Property_Manager_Questionnaire__c> questionnaire = [
      SELECT Id
      FROM Property_Manager_Questionnaire__c
      WHERE Id = :questionnaireId
    ];

    if (questionnaire.size() > 0) {
      delete questionnaire;

      Map<String, String> responseBody = new Map<String, String>();
      responseBody.put('status', 'success');
      responseBody.put('message', 'resource deleted');
      res.statusCode = 200;
      res.responseBody = Blob.valueOf(JSON.serialize(responseBody, true));
      res.addHeader('Content-Type', 'application/json');
    } else {
      res.addHeader('Content-Type', 'application/json');
      Map<String, String> responseBody = new Map<String, String>();
      responseBody.put('status', 'error');
      responseBody.put('message', 'resource not found');
      res.statusCode = 404;
      res.responseBody = Blob.valueOf(JSON.serialize(responseBody, true));
    }
  }

  public static Property_Manager_Questionnaire__c queryQuestionnaire(
    Id questionnaireId
  ) {
    Set<String> fieldNames = util.getAllFieldNamesForObject(
      'Property_Manager_Questionnaire__c'
    );

    String queryString = 'SELECT ';
    queryString += String.join(new List<String>(fieldNames), ',');
    queryString += ', Borrower__r.Name, Property_Manager__r.Name, Property_Manager__r.Account.Name, Property_Manager__r.Email, Property_Manager__r.Phone, Deal__r.Name FROM Property_Manager_Questionnaire__c';
    queryString += ' WHERE Id =: questionnaireId ';

    List<Property_Manager_Questionnaire__c> questionnaires = (List<Property_Manager_Questionnaire__c>) database.query(
      queryString
    );

    if (questionnaires.size() > 0) {
      return questionnaires[0];
    } else {
      return null;
    }
  }

  class Dashboard {
    List<Borrower> borrowers;

    Dashboard(PortalAPIUser.PortalUser propertyManager) {
      this.borrowers = new List<Borrower>();

      Set<Id> dealIds = AlchemyAPI.getDealIds(user);
      system.debug(dealIds);
      Date today7 = system.today().addDays(7);
      Map<Id, List<Opportunity>> borrowerDealMap = new Map<Id, List<Opportunity>>();
      for (
        Opportunity deal : [
          SELECT
            Id,
            Name,
            Deal_Loan_Number__c,
            StageName,
            Type,
            Final_Loan_Amount__c,
            Current_Loan_AMount__c,
            LOC_Loan_Type__c,
            Product_Sub_Type__c,
            Project_Strategy__c,
            CloseDate,
            Updated_Loan_Maturity_Date__c,
            Aggregate_Funding__c,
            Outstanding_Facility_Amount__c,
            Total_Properties__c,
            Term_Loan_Type__c,
            LOC_Term__c,
            Loan_Size__c,
            Account.Name,
            RecordType.Name,
            LOC_Commitment__c,
            Term_Loan_Type_Months__c,
            Contact__r.Alchemy_Portal_Id__c,
            Contact__r.Name,
            Contact__c,
            Contact__r.Account.Name,
            Contact__r.Phone,
            // Account.Name,
            Contact__r.Email,
            (
              SELECT Id, Status__c, Date_of_Questionnaire__c
              FROM Property_Manager_Questionnaires__r
              WHERE Property_Manager_Portal_Id__c = :user.id
            )
          FROM Opportunity
          WHERE
            Id IN :dealIds
            AND StageName NOT IN (
              'Matured',
              'Expired',
              'Withdrawn',
              'Rejected',
              'Paid Off'
            )
            AND (StageName != 'Closed Won'
            OR (StageName = 'Closed Won'
            AND CloseDate >= :today7))
          ORDER BY CloseDate DESC, Name ASC
        ]
      ) {
        if (!borrowerDealMap.containsKey(deal.Contact__c)) {
          borrowerDealMap.put(deal.Contact__c, new List<Opportunity>());
        }
        borrowerDealMap.get(deal.Contact__c).add(deal);
      }

      for (Id contactId : borrowerDealMap.keySet()) {
        this.borrowers.add(new Borrower(borrowerDealMap.get(contactId)));
      }
    }
  }

  class Borrower {
    List<Map<String, Object>> loans;
    String borrowerName;
    String borrowerId;

    Borrower(List<Opportunity> deals) {
      this.borrowerId = deals[0].Contact__r.Alchemy_Portal_Id__c;
      this.borrowerName = deals[0].Contact__r.Name;
      this.loans = new List<Map<String, Object>>();

      for (Opportunity opp : deals) {
        Map<String, Object> loan = new Map<String, Object>();

        String loanType = '';
        if (opp.LOC_Loan_Type__c == 'Term Loan') {
          loanType = 'Rental Portfolio';
        }
        if (
          opp.LOC_Loan_Type__c == 'Credit Line' &&
          opp.Project_Strategy__c != 'Fix and Flip'
        ) {
          loanType = 'Credit Line';
        }
        if (
          opp.LOC_Loan_Type__c == 'Credit Line' &&
          opp.Project_Strategy__c == 'Fix and Flip'
        ) {
          loanType = 'Credit Line';
        }

        if (
          opp.LOC_Loan_Type__c == 'Credit Line' &&
          opp.Product_Sub_Type__c == 'Build to Rent'
        ) {
          loanType = 'Build For Rent';
        }

        if (opp.LOC_Loan_Type__c == 'Build to Rent') {
          loanType = 'Build For Rent';
        }

        if (
          opp.LOC_Loan_Type__c == 'Single Asset (1-4 Unit)' ||
          opp.LOC_Loan_Type__c == 'Single Asset (5-10 Unit)'
        ) {
          loanType = 'Single Asset Bridge Loan';
        }
        if (opp.Loc_Loan_Type__c == 'Multifamily/CRE') {
          loanType = 'Multifamily';
        }

        if (opp.LOC_Loan_Type__c == 'Model Home Release') {
          loanType = 'Model Home Release';
        }

        if (opp.LOC_Loan_Type__c == 'Single Asset Rental') {
          loanType = 'Single Rental';
        }

        if (opp.LOC_Loan_Type__c == 'Single Rental Loan') {
          loanType = 'Single Rental';
        }

        loan.put('id', opp.Id);
        loan.put('loanName', opp.Name);
        loan.put('loanType', loanType);
        loan.put('dateOfQuestionnaire', null);
        loan.put('contactName', deals[0].Contact__r.Name);
        loan.put('accountName', deals[0].Account.Name);
        loan.put('contactEmailAddress', deals[0].Contact__r.Email);
        loan.put('contactPhone', deals[0].Contact__r.Phone);
        // loan.put('closeDate', opp.CloseDate);
        // loan.put('totalProperties', opp.Total_Properties__c);
        Id questionnaireId;
        String questionnaireStatus = 'Pending';
        if (opp.Property_Manager_Questionnaires__r.size() > 0) {
          questionnaireId = opp.Property_Manager_Questionnaires__r[0].Id;
          if (
            String.isNotBlank(
              opp.Property_Manager_Questionnaires__r[0].Status__c
            )
          ) {
            questionnaireStatus = opp.Property_Manager_Questionnaires__r[0]
              .Status__c;
          }
          loan.put(
            'dateOfQuestionnaire',
            opp.Property_Manager_Questionnaires__r[0].Date_of_Questionnaire__c
          );
        }
        loan.put('accountName', opp.Contact__r.Account.Name);
        loan.put('questionnaireId', questionnaireId);
        loan.put('questionnaireStatus', questionnaireStatus);

        this.loans.add(loan);
      }
    }
  }

  class Questionnaire {
    Id id;
    Id dealId;
    Id propertyId;
    String status;
    String borrowerId;
    String propertyManagerId;
    String dealName;
    Date questionnaireDate;
    String borrowerName;
    String propertyManagementCompanyName;
    String propertyManagerName;
    String propertyManagerEmail;
    String propertyManagerPhoneNumber;
    Decimal companyCommercialPropertiesYears;
    Decimal mainCommercialPropertiesYears;
    Decimal underManagementUnits;
    Decimal borrowerOrSelfUnits;

    String mainCommercialRentalYears;

    Decimal totalNumberOfMSA;
    List<Map<String, String>> allMSA;
    // Boolean licensedInMSA;
    String licenseNumber;
    Decimal propertyManagementFee;
    Decimal averageLeaseUp;
    // Decimal averageMarketingFee;
    Decimal averageLeaseUpandMarketingFee;
    Decimal sfrAverageMonthlyRent;
    Decimal rentGrowth;
    Decimal sfrRepairandMaintenanceWithoutHOA;
    Decimal sfrTurnoverMaintenanceWithoutHOA;
    Decimal sfrCapitalExpenditureWithoutHOA;
    Decimal mfRepairandMaintenance;
    Decimal mfTurnoverMaintenance;
    Decimal mfCapitalExpenditure;
    Decimal sfrRepairandMaintenanceWithHOA;
    Decimal sfrTurnoverMaintenanceWithHOA;
    Decimal sfrCapitalExpenditureWithHOA;
    Decimal avgOccupancyRate;
    String avgTimeTenancy;
    String sec8AvgTimeTenancy;
    String avgTimeLeaseProperty;
    String avgTimeRenovation;
    Decimal collectionRate;
    Decimal tenantsLateFeePercentage;
    Decimal minCreditScore;
    String bankruptcyHistory;
    String evictionHistory;
    String incomeToRentRatio;
    String otherCriteria;
    Decimal borPropFillingsforEvct;
    String borPropEvictionCureRt;
    String borPropAvgTotTimeCompleteEvct;
    Decimal propFillingsforEvct;
    String propEvictionCureRt;
    String propAvgTotTimelineCompleteEvct;
    String insuranceType;
    String bbbComplaints;
    String bbbComplaintsExplanation;
    Decimal percentageNewLease;
    String marketingResOne;
    String marketingResTwo;
    String marketingResThree;
    String propertyManagerAssettoCAF;
    String propertyManagerAssettoCAFComment;
    Decimal borrowerManagedYears;

    Decimal annualPropertyMtncAndCapEx; //Annual_Maintenance_CapEx_expenses__c
    String propertyType; //Property_Type__c
    Decimal repairandMaintenanceSelectAllVal; //Repair_Maintenance_Select_All_Val
    Decimal turnoverMaintenanceSelectAllVal; //Turnover_Maintenance_Select_All_Val
    Decimal capitalExpenditureSelectAllVal; //Capital_Expenditure_Select_All_Val
    Boolean repairandMaintenanceSelectAll; //Repair_and_Maintenance_Select_All
    Boolean turnoverMaintenanceSelectAll; //Turnover_Maintenance_Select_All__c
    Boolean capitalExpenditureSelectAll; //Capital_Expenditure_Select_All

    Decimal avgTotalNumMF;
    Decimal avgTotalNumCondoAsc;

    List<String> propType;

    Questionnaire(Opportunity deal) {
      this.dealId = deal.Id;
      this.dealName = deal.Name;
      this.borrowerId = deal.Contact__r.Alchemy_Portal_Id__c;
      this.borrowerName = deal.Contact__r.Name;
      this.questionnaireDate = system.today();
      this.status = 'Pending';
    }

    Questionnaire(Property_Manager_Questionnaire__c questionnaire) {
      this.id = questionnaire.Id;
      this.status = questionnaire.Status__c;
      this.dealId = questionnaire.Deal__c;
      this.propertyId = questionnaire.Property__c;
      this.borrowerId = questionnaire.Borrower_Portal_Id__c;
      this.propertyManagerId = questionnaire.Property_Manager_Portal_Id__c;
      this.dealName = questionnaire.Deal__r.Name;
      this.questionnaireDate = questionnaire.Date_of_Questionnaire__c;
      this.borrowerName = questionnaire.Borrower__r.Name;
      this.propertyManagementCompanyName = questionnaire.Property_Manager__r.Name;
      this.propertyManagerName = questionnaire.Property_Manager__r.Name;
      this.propertyManagerEmail = questionnaire.Property_Manager__r.Email;
      this.propertyManagerPhoneNumber = questionnaire.Property_Manager__r.Phone;
      this.companyCommercialPropertiesYears = questionnaire.Years_Company_Managing_Commercial_Props__c;
      // this.mainCommercialPropertiesYears = questionnaire.Years_in_CPM_Management__c;
      this.underManagementUnits = questionnaire.Number_of_Units_in_Management__c;
      this.borrowerOrSelfUnits = questionnaire.Number_of_Units_Manage_for_BorrowerSelf__c;
      this.mainCommercialRentalYears = questionnaire.Years_in_CRM_Business__c;
      this.totalNumberOfMSA = questionnaire.Total_Number_of_MSAs__c;
      this.borrowerManagedYears = questionnaire.Years_Managed_for_BorrowerSelf__c;
      // this.allMSA = questionnaire.MSAs__c;
      // this.licensedInMSA = questionnaire.MSA_License_Number__c;
      this.propertyManagementFee = questionnaire.Property_Management_Fee__c;
      this.averageLeaseUp = questionnaire.Property_Management_Fee__c;
      this.averageLeaseUpandMarketingFee = questionnaire.Average_Lease_upMarketing_Fees_Turnover__c;
      this.sfrAverageMonthlyRent = questionnaire.Average_Monthly_Rent_SFR__c;
      this.rentGrowth = questionnaire.Average_Rent_Growth__c;
      this.sfrRepairandMaintenanceWithoutHOA = questionnaire.SFR_Repair_Maintenance_without_HOA__c;
      this.sfrTurnoverMaintenanceWithoutHOA = questionnaire.SFR_Turnover_Maintenance_without_HOA__c;
      this.sfrCapitalExpenditureWithoutHOA = questionnaire.SFR_Capital_Expenditures_without_HOA__c;
      this.mfRepairandMaintenance = questionnaire.Multifamily_Repair_Maintenance__c;
      this.mfTurnoverMaintenance = questionnaire.Multifamily_Turnover_Maintenance__c;
      this.mfCapitalExpenditure = questionnaire.Multifamily_Capital_Expenditures__c;
      this.sfrRepairandMaintenanceWithHOA = questionnaire.SFR_Repair_Maintenance_with_HOA__c;
      this.sfrTurnoverMaintenanceWithHOA = questionnaire.SFR_Turnover_Maintenance_with_HOA__c;
      this.sfrCapitalExpenditureWithHOA = questionnaire.SFR_Capital_Expenditures_with_HOA__c;
      this.avgOccupancyRate = questionnaire.Average_Occupany_Rate__c;
      this.avgTimeTenancy = questionnaire.Average_Time_of_Tenancy__c;
      this.sec8AvgTimeTenancy = questionnaire.Average_Time_of_Tenancy_Section_8_Tenant__c;
      this.avgTimeLeaseProperty = questionnaire.Average_Time_to_Lease_a_Property__c;
      this.avgTimeRenovation = questionnaire.Average_Time_for_Renovations__c;
      this.collectionRate = questionnaire.Collection_Rate__c;
      this.tenantsLateFeePercentage = questionnaire.Tenants_Charged_a_Late_Fee__c;
      this.minCreditScore = questionnaire.Minimum_Credit_Score__c;
      this.bankruptcyHistory = questionnaire.Bankruptcy_History__c;
      this.evictionHistory = questionnaire.Eviction_History__c;
      this.incomeToRentRatio = questionnaire.Income_to_Rent_Ratio__c;
      this.otherCriteria = questionnaire.Other_Criteria__c;
      this.borPropFillingsforEvct = questionnaire.Borrower_Evictions_Last_12_Months__c;
      this.borPropEvictionCureRt = questionnaire.Borrower_Cure_Rate_for_Eviction_Notices__c;
      this.borPropAvgTotTimeCompleteEvct = questionnaire.Borrower_Average_Timeline_for_Eviction__c;
      this.propFillingsforEvct = questionnaire.Total_Evictions_Last_12_Months__c;
      this.propEvictionCureRt = questionnaire.Total_Cure_Rate_for_Eviction_Notices__c;
      this.propAvgTotTimelineCompleteEvct = questionnaire.Total_Average_Timeline_for_Eviction__c;
      this.insuranceType = questionnaire.Type_of_Insurance_and_Coverage__c;
      this.bbbComplaints = questionnaire.Received_BBBsimilar_complaints__c;
      this.bbbComplaintsExplanation = questionnaire.BBB_Complaints_Explanation__c;
      this.percentageNewLease = questionnaire.New_Leases_Found_By_Internal_v_External__c;
      this.marketingResOne = questionnaire.Marketing_Resource_1__c;
      this.marketingResTwo = questionnaire.Marketing_Resource_2__c;
      this.marketingResThree = questionnaire.Marketing_Resource_3__c;
      this.propertyManagerAssettoCAF = questionnaire.Additional_Factors_Comment__c;
      this.propertyManagerAssettoCAFComment = questionnaire.Additional_Factors_to_provide__c;

      this.annualPropertyMtncAndCapEx = questionnaire.Annual_Maintenance_CapEx_expenses__c; //Annual_Maintenance_CapEx_expenses__c
      // this.propertyType = questionnaire.Property_Type__c; //Property_Type__c
      this.repairandMaintenanceSelectAllVal = questionnaire.Repair_Maintenance_Select_All_Val__c; //Repair_Maintenance_Select_All_Val
      this.turnoverMaintenanceSelectAllVal = questionnaire.Turnover_Maintenance_Select_All_Val__c; //Turnover_Maintenance_Select_All_Val
      this.capitalExpenditureSelectAllVal = questionnaire.Capital_Expenditure_Select_All_Val__c; //Capital_Expenditure_Select_All_Val
      this.repairandMaintenanceSelectAll = questionnaire.Repair_and_Maintenance_Select_All__c; //Repair_and_Maintenance_Select_All
      this.turnoverMaintenanceSelectAll = questionnaire.Turnover_Maintenance_Select_All__c; //Turnover_Maintenance_Select_All__c
      this.capitalExpenditureSelectAll = questionnaire.Capital_Expenditure_Select_All__c;
      this.avgTotalNumCondoAsc = questionnaire.Average_Total_Number_Condo_Asc__c;
      this.avgTotalNumMF = questionnaire.Average_Total_Number_MF__c;

      if (String.isNotBlank(questionnaire.Property_Type__c)) {
        this.propType = questionnaire.Property_Type__c.split(';');
      }
    }

    public Property_Manager_Questionnaire__c getRecord() {
      Boolean repairandMaintenanceSelectAll; //Repair_and_Maintenance_Select_All
      Boolean turnoverMaintenanceSelectAll; //Turnover_Maintenance_Select_All__c
      Boolean capitalExpenditureSelectAll;

      Property_Manager_Questionnaire__c questionnaire = new Property_Manager_Questionnaire__c();

      questionnaire.Id = this.id;
      if (questionnaire.Id == null) {
        questionnaire.Deal__c = this.dealId;
      }
      questionnaire.Status__c = this.status;
      questionnaire.Property__c = this.propertyId;
      questionnaire.Borrower_Portal_Id__c = this.borrowerId;
      questionnaire.Property_Manager_Portal_Id__c = this.propertyManagerId;
      // questionnaire.Deal__r.Name = this.dealName;
      questionnaire.Date_of_Questionnaire__c = this.questionnaireDate;
      // questionnaire.Borrower__r.Name = this.borrowerName;
      // questionnaire.Property_Manager__r.Name = this.propertyManagementCompanyName;
      // questionnaire.Property_Manager__r.Name = this.propertyManagerName;
      // questionnaire.Property_Manager__r.Email = this.propertyManagerEmail;
      // questionnaire.Property_Manager__r.Phone = this.propertyManagerPhoneNumber;
      questionnaire.Years_Company_Managing_Commercial_Props__c = this.companyCommercialPropertiesYears;
      questionnaire.Years_in_CPM_Management__c = this.mainCommercialPropertiesYears;
      questionnaire.Number_of_Units_in_Management__c = this.underManagementUnits;
      questionnaire.Number_of_Units_Manage_for_BorrowerSelf__c = this.borrowerOrSelfUnits;
      questionnaire.Years_in_CRM_Business__c = this.mainCommercialRentalYears;
      questionnaire.Total_Number_of_MSAs__c = this.totalNumberOfMSA;

      // questionnaire.MSAs__c = this.allMSA;
      // questionnaire.MSA_License_Number__c = this.licensedInMSA;
      questionnaire.Property_Management_Fee__c = this.propertyManagementFee;
      // questionnaire.Property_Management_Fee__c = this.averageLeaseUp;
      questionnaire.Years_Managed_for_BorrowerSelf__c = borrowerManagedYears;
      questionnaire.Average_Lease_upMarketing_Fees_Turnover__c = this.averageLeaseUpandMarketingFee;
      questionnaire.Average_Monthly_Rent_SFR__c = this.sfrAverageMonthlyRent;
      questionnaire.Average_Rent_Growth__c = this.rentGrowth;
      questionnaire.SFR_Repair_Maintenance_without_HOA__c = this.sfrRepairandMaintenanceWithoutHOA;
      questionnaire.SFR_Turnover_Maintenance_without_HOA__c = this.sfrTurnoverMaintenanceWithoutHOA;
      questionnaire.SFR_Capital_Expenditures_without_HOA__c = this.sfrCapitalExpenditureWithoutHOA;
      questionnaire.Multifamily_Repair_Maintenance__c = this.mfRepairandMaintenance;
      questionnaire.Multifamily_Turnover_Maintenance__c = this.mfTurnoverMaintenance;
      questionnaire.Multifamily_Capital_Expenditures__c = this.mfCapitalExpenditure;
      questionnaire.SFR_Repair_Maintenance_with_HOA__c = this.sfrRepairandMaintenanceWithHOA;
      questionnaire.SFR_Turnover_Maintenance_with_HOA__c = this.sfrTurnoverMaintenanceWithHOA;
      questionnaire.SFR_Capital_Expenditures_with_HOA__c = this.sfrCapitalExpenditureWithHOA;
      questionnaire.Average_Occupany_Rate__c = this.avgOccupancyRate;
      questionnaire.Average_Time_of_Tenancy__c = this.avgTimeTenancy;
      questionnaire.Average_Time_of_Tenancy_Section_8_Tenant__c = this.sec8AvgTimeTenancy;
      questionnaire.Average_Time_to_Lease_a_Property__c = this.avgTimeLeaseProperty;
      questionnaire.Average_Time_for_Renovations__c = this.avgTimeRenovation;
      questionnaire.Collection_Rate__c = this.collectionRate;
      questionnaire.Tenants_Charged_a_Late_Fee__c = this.tenantsLateFeePercentage;
      questionnaire.Minimum_Credit_Score__c = this.minCreditScore;
      questionnaire.Bankruptcy_History__c = this.bankruptcyHistory;
      questionnaire.Eviction_History__c = this.evictionHistory;
      questionnaire.Income_to_Rent_Ratio__c = this.incomeToRentRatio;
      questionnaire.Other_Criteria__c = this.otherCriteria;
      questionnaire.Borrower_Evictions_Last_12_Months__c = this.borPropFillingsforEvct;
      questionnaire.Borrower_Cure_Rate_for_Eviction_Notices__c = this.borPropEvictionCureRt;
      questionnaire.Borrower_Average_Timeline_for_Eviction__c = this.borPropAvgTotTimeCompleteEvct;
      questionnaire.Total_Evictions_Last_12_Months__c = this.propFillingsforEvct;
      questionnaire.Total_Cure_Rate_for_Eviction_Notices__c = this.propEvictionCureRt;
      questionnaire.Total_Average_Timeline_for_Eviction__c = this.propAvgTotTimelineCompleteEvct;
      questionnaire.Type_of_Insurance_and_Coverage__c = this.insuranceType;
      questionnaire.Received_BBBsimilar_complaints__c = this.bbbComplaints;
      questionnaire.BBB_Complaints_Explanation__c = this.bbbComplaintsExplanation;
      questionnaire.New_Leases_Found_By_Internal_v_External__c = this.percentageNewLease;
      questionnaire.Marketing_Resource_1__c = this.marketingResOne;
      questionnaire.Marketing_Resource_2__c = this.marketingResTwo;
      questionnaire.Marketing_Resource_3__c = this.marketingResThree;
      questionnaire.Additional_Factors_Comment__c = this.propertyManagerAssettoCAF;
      questionnaire.Additional_Factors_to_provide__c = this.propertyManagerAssettoCAFComment;

      questionnaire.Annual_Maintenance_CapEx_expenses__c = this.annualPropertyMtncAndCapEx; //Annual_Maintenance_CapEx_expenses__c
      // questionnaire.Property_Type__c = this.propertyType; //Property_Type__c
      questionnaire.Repair_Maintenance_Select_All_Val__c = this.repairandMaintenanceSelectAllVal; //Repair_Maintenance_Select_All_Val
      questionnaire.Turnover_Maintenance_Select_All_Val__c = this.turnoverMaintenanceSelectAllVal; //Turnover_Maintenance_Select_All_Val
      questionnaire.Capital_Expenditure_Select_All_Val__c = this.capitalExpenditureSelectAllVal; //Capital_Expenditure_Select_All_Val

      questionnaire.Average_Total_Number_Condo_Asc__c = this.avgTotalNumCondoAsc;
      questionnaire.Average_Total_Number_MF__c = this.avgTotalNumMF;
      if (this.repairandMaintenanceSelectAll != null) {
        questionnaire.Repair_and_Maintenance_Select_All__c = this.repairandMaintenanceSelectAll; //Repair_and_Maintenance_Select_All
      }

      if (this.turnoverMaintenanceSelectAll != null) {
        questionnaire.Turnover_Maintenance_Select_All__c = this.turnoverMaintenanceSelectAll; //Turnover_Maintenance_Select_All__c
      }

      if (this.capitalExpenditureSelectAll != null) {
        questionnaire.Capital_Expenditure_Select_All__c = this.capitalExpenditureSelectAll;
      }

      if (this.propType != null) {
        questionnaire.Property_Type__c = String.join(this.propType, ';');
      }

      if (this.allMSA != null) {
        questionnaire.MSAs__c = JSON.serialize(this.allMSA);
      }

      return questionnaire;
    }
  }
}