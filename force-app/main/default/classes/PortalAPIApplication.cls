@RestResource(urlMapping='/portal/application/*')
global without sharing class PortalAPIApplication {
  public static String portalId;
  public static Id applicationId;
  public static Id contactId;
  public static Id leadId;
  public static String brokerId;
  public static Id brokerContactId;

  @HttpPost
  global static void doPost() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;

    // Map<String, Object> applicationBody = (Map<String, Object>) System.JSON.deserializeUntyped(
    //   req.requestBody.toString()
    // );

    Application app = (Application) JSON.deserialize(
      req.requestBody.toString(),
      Application.class
    );
    portalId = app.user_id;
    brokerId = app.broker_id;
    if (portalId != null) {
      contactId = AlchemyAPI.getContactIdByAlchemyId(portalId);
      leadId = AlchemyAPI.getLeadIdByAlchemyId(portalId);
    }

    if (brokerId != null) {
      brokerContactId = AlchemyAPI.getContactIdByAlchemyId(brokerId);
    }

    if (leadId != null || contactId != null || brokerContactId != null) {
      // Application__c application = new Application__c();
      // application.Lead__c = leadId;
      // application.Contact__c = contactId;
      // application.Alchemy_User_Id__c = portalId;
      // application.Loan_Type__c = applicationBody.get('loanType');
      // // application.
      // insert application;

      // applicationBody.put('id', application.Id);

      Application__c application = app.getRecord();
      Map<String, Object> fieldsToValue = application.getPopulatedFieldsAsMap();
      application = new Application__c();
      for (String fieldName : fieldsToValue.keySet()) {
        if (fieldsToValue.get(fieldName) != null) {
          application.put(fieldName, fieldsToValue.get(fieldName));
        }
      }

      //Application__c appNoNulls = JSON.serialize(app.getRecord(), true);
      //system.debug(appNoNulls);

      // Application__c application = (Application__c) JSON.deserialize(
      //   JSON.serialize(app.getRecord(), true),
      //   Application__c.class
      // );

      //system.debug(application);

      application.Lead__c = leadId;
      application.Contact__c = contactId;
      application.Broker__c = brokerContactId;
      insert application;

      //Application appToSend = new Application(application);
      system.debug(JSON.serialize(req.requestBody.toString()));
      app = (Application) JSON.deserialize(
        req.requestBody.toString(),
        Application.class
      );

      app.id = application.Id;

      res.addHeader('Content-Type', 'application/json');
      res.responseBody = Blob.valueOf(JSON.serialize(app, true));
    } else {
      Map<String, String> respBody = new Map<String, String>();
      res.addHeader('Content-Type', 'application/json');
      respBody.put('status', 'error');
      respBody.put('message', 'User Id Not Found');
      res.responseBody = Blob.valueOf(JSON.serialize(respBody, true));
    }
  }

  @HttpPatch
  global static void doPatch() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;

    List<String> params = Restcontext.request.requestURI.split('/');

    Id applicationId = params[3];

    Application__c application = queryApplication(applicationId);
    system.debug(req.requestBody.toString());
    if (application != null) {
      //String loanType = application.Loan_Type__c;

      Application app = (Application) System.JSON.deserialize(
        req.requestBody.toString(),
        Application.class
      );

      app.id = params[3];

      application = app.getRecord();
      Map<String, Object> fieldsToValue = application.getPopulatedFieldsAsMap();
      application = new Application__c();
      for (String fieldName : fieldsToValue.keySet()) {
        system.debug(fieldName);
        system.debug(fieldsToValue.get(fieldName));
        if (fieldsToValue.get(fieldName) != null) {
          application.put(fieldName, fieldsToValue.get(fieldName));
        }
      }

      // app = (Application) System.JSON.deserialize(
      //   req.requestBody.toString(),
      //   Application.class
      // );

      // application = (Application__c) JSON.deserialize(
      //   JSON.serialize(app.getRecord(), true),
      //   Application__c.class
      // );
      update application;
      app = (Application) JSON.deserialize(
        req.requestBody.toString(),
        Application.class
      );

      app.id = application.Id;
      res.addHeader('Content-Type', 'application/json');
      res.responseBody = Blob.valueOf(JSON.serialize(app, true));
    } else {
      Map<String, String> respBody = new Map<String, String>();

      res.addHeader('Content-Type', 'application/json');
      respBody.put('status', 'error');
      respBody.put('message', 'Application Id Not Found');
      res.responseBody = Blob.valueOf(JSON.serialize(respBody, true));
    }
  }

  @HttpGet
  global static void doGet() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;

    List<String> params = Restcontext.request.requestURI.split('/');

    if (params[3].contains('-')) {
      portalId = params[3];

      if (params.size() > 4 && params[4] == 'prefill') {
        String loanType = params[5];
        PrefilledApplication application = new PrefilledApplication(
          portalId,
          loanType
        );
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(application));
      } else {
        List<Application> applications = new List<Application>();
        for (Application__c application : queryApplications(portalId)) {
          applications.add(new Application(application));
        }

        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(applications, true));
      }
    } else if (params[3] == 'dealId') {
      Id dealId = params[4];

      List<ApplicationSmall> applications = new List<ApplicationSmall>();
      for (Application__c application : queryApplications(dealId)) {
        // Application applicationWhole = new Application(application);

        // Application applicationSubset = new Application();
        // applicationSubset.dealId = applicationWhole.dealId;
        // applicationSubset.broker_id = applicationWhole.broker_id;
        // applicationSubset.id = applicationWhole.id;
        // applicationSubset.user_id = applicationWhole.user_id;
        // applicationSubset.status = applicationWhole.status;

        // applications.add(applicationSubset);
        applications.add(new ApplicationSmall(application));
      }

      res.addHeader('Content-Type', 'application/json');
      res.responseBody = Blob.valueOf(JSON.serialize(applications, true));
    } else {
      Id applicationId = params[3];
      Application__c app = queryApplication(applicationId);

      if (app != null) {
        Application application = new APplication(app);
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(application, true));
      } else {
        Map<String, String> respBody = new Map<String, String>();

        res.addHeader('Content-Type', 'application/json');
        respBody.put('status', 'error');
        respBody.put('message', 'Application Id Not Found');
        res.statusCode = 404;
        res.responseBody = Blob.valueOf(JSON.serialize(respBody, true));
      }
    }
  }

  public static Application__c queryApplication(Id applicationId) {
    Set<String> fieldNames = util.getAllFieldNamesForObject('Application__c');

    String queryString = 'SELECT ';
    queryString += String.join(new List<String>(fieldNames), ',');
    queryString += ', Deal__r.Name, Lead__r.Name, Contact__r.Name';
    queryString += ' FROM Application__c';
    queryString += ' WHERE Id =: applicationId ';

    List<Application__c> applications = (List<Application__c>) database.query(
      queryString
    );

    if (applications.size() > 0) {
      return applications[0];
    } else {
      return null;
    }
  }

  public static List<Application__c> queryApplications(String portalId) {
    Set<String> fieldNames = util.getAllFieldNamesForObject('Application__c');

    String queryString = 'SELECT ';
    queryString += String.join(new List<String>(fieldNames), ',');
    queryString += ', Deal__r.Name, Lead__r.Name, Contact__r.Name';
    queryString += ' FROM Application__c';
    queryString += ' WHERE Alchemy_User_Id__c =: portalId OR Broker_Alchemy_User_Id__c =: portalId OR Deal__c =: portalId';
    queryString += ' ORDER BY CreatedDate desc';
    List<Application__c> applications = (List<Application__c>) database.query(
      queryString
    );

    // List<Application__c> applications = new List<Application__c>();
    // for (
    //   Application__c application : (List<Application__c>) database.query(
    //     queryString
    //   )
    // ) {
    //   if (application.Broker_Alchemy_User_Id__c = portalId) {
    //     if (application.Alchemy_User_Id__c != null) {
    //       applications.add(application);
    //     }
    //   } else {
    //     applications.add(application);
    //   }
    // }

    return applications;
  }

  public class ApplicationSmall {
    public Id id;
    public String broker_id;
    public String user_id;
    public String status;
    public String dealId;
    public DateTime createdDate;
    public String loanType;
    public String leadId;
    public String dealName;
    public String leadName;
    public String applicationName;

    public ApplicationSmall(Application__c application) {
      Application applicationFull = new Application(application);
      this.id = applicationFull.id;
      this.broker_id = applicationFull.broker_id;
      this.user_id = applicationFull.user_id;
      this.status = applicationFull.status;
      this.dealId = applicationFull.dealId;
      this.loanType = applicationFull.loanType;
      this.createdDate = application.createdDate;
      this.leadId = application.Lead__c;
      this.dealName = application.Deal__r.Name;
      this.leadName = application.Lead__r.Name;

      if (this.leadName == null) {
        this.leadName = application.Contact__r.Name;
      }

      this.applicationName = application.Name;
      if (this.status == null) {
        this.status = 'Pending';
      }
    }
  }

  public class PrefilledApplication {
    //public

    public String felonyComments;
    public String onFinancialSanctionsListComments;
    public String delinquentOrDefaultOnAnyDebtComments;
    public String pendingLitigationsComments;
    public String propertyViolationsInvestigations5yrComments;
    public String isLawsuitDefendantComments;
    public String outstandingJudgementsComments;
    public String portfolioProperiesLitigationsComments;
    public String isUsCitizenComments;
    public String isPermanentResidentAlienComments;
    public String isForeignNationalComments;

    public String firstName;
    public String middleName;
    public String lastName;
    public String email;
    public Date dob;
    public String mobilePhone;
    public String martialStatus;
    public String homeAddress;
    public String pinfoCity;
    public String pinfoState;
    public String pinfoZip;
    public String businessContactCompanyName;
    public String businessContactEmail;
    public String businessContactCompanyAddress;
    public String businessContactWorkPhone;
    public String businessContactCity;
    public String businessContactState;
    public String businessContactZip;
    public String businessEntityName;
    public Date businessEntityDateOfFormation;
    public String businessEntityTypeOfCompany;
    public Boolean representedByAttorney;
    public String attorneyContactName; //Attorney_Contact_Name__c
    public String attorneyContactCompanyName; //Attorney_Contact_Company_Name__c
    public String attorneyContactAddress; //Attorney_Contact_Address__c
    public String attorneyContactEmailAddress; //Attorney_Contact_Mobile_Phone__c
    public String attorneyContactWorkPhone; //Attorney_Contact_Work_Phone__c
    public String attorneyContactMobilePhone; //Attorney_Contact_Mobile_Phone__c

    public String attorneyContactCity;
    public String attorneyContactState;
    public String attorneyContactZip;

    public Boolean optForCorevestInsuranceAgent;
    public String insuranceAgentName; //Insurance_Agent_Name__c
    public String insuranceAgentCompanyName; //Insurance_Agent_Company_Name__c
    public String insuranceAgentAddress; //Insurance_Agent_Address__c
    public String insuranceAgentEmailAddress; //Insurance_Agent_Email_Address__c
    public String insuranceAgentWorkPhone; //Insurance_Agent_Work_Phone__c
    public String insuranceAgentMobilePhone;
    public String insuranceAgentCity;
    public String insuranceAgentState;
    public String insuranceAgentZip;

    public Boolean willUseThirdPartyTitle;
    public String thirdPartyTitleContactName;
    public String thirdPartyTitleCompanyName;
    public String thirdPartyTitleAddress;
    public String thirdPartyTitleCity;
    public String thirdPartyTitleState;
    public String thirdPartyTitleZip;
    public String thirdPartyTitleWorkPhone;
    public String thirdPartyTitleMobilePhone;
    public String thirdPartyTitleEmail;

    public Boolean felony; //Felony__c
    public Boolean onFinancialSanctionsList; //On_Financial_Sanction_List__conFinancialSanctionsList
    public Boolean delinquentOrDefaultOnAnyDebt; //Deliquent_Or_Default_On_Any_Debt__c delinquentOrDefaultOnAnyDebt
    public Boolean pendingLitigations; //Pending_Litigations__c
    public Boolean propertyViolationsInvestigations5yr; //Property_Violations_Investigations_5yr__c
    public Boolean outstandingJudgements; //Outstanding_Judgements__c
    public Boolean isLawsuitDefendant; //Is_Lawsuit_Defendant__c
    public Boolean portfolioProperiesLitigations; //Portfolio_Properties_Litigations__c
    public Boolean isUsCitizen; //Is_US_Citizen__c
    public Boolean isPermanentResidentAlien; //Is_Permanent_Resident_Alien__c
    public Boolean isForeignNational;

    public String summary;
    public Decimal estimatedTotalAssetValue; //Estimated_Total_Asset_Value__c;
    public Decimal estimatedTotalLiabilityValue;
    public Decimal estimatedNetWorthValue; //Estimated_Net_Worth_Value__c
    public Decimal estimatedTotalLiquidAssetValue; //Estimated_Total_Liquid_Asset_Value__c
    public Date dateOfEstimation; //Date_of_Estimation__c//
    public Date payoffAmountAsOf; //Payoff_Amount_As_Of__c;

    public Decimal numberOfRentalPropertiesOwned; // Number_of_Rental_Properties_Owned__c numberOfRentalPropertiesOwned integer,
    public String howLongInvestingInRentalProperties; // How_Long_Investing_in_Rental_Properties__cstring,
    public List<String> typeOfPropertiesOwned; // Type_of_Rental_Properties_Owned__c[string],
    public List<String> sourceOfRentalProperties; //Source_of_the_Rental_Properties__c [string],
    public String howLongToHoldPortfolio; // How_Long_to_Hold_Portfolio__c[string],
    public String propertyManagement; // How_is_Property_Management_Handled__c[string],
    public String propertyManagementCompanies; // Property_Management_Companies__c[string],
    public String softwareUsed; //Software_Used__c string(more than 255 characters),
    public Decimal yearsExperience; //Years_Experience__c integer,

    public String propertiesToPurchase; //Properties_To_Purchase__c string,
    public List<String> typeOfProperties; //Type_Of_Properties__c [string],
    public List<String> operationalStates; //States_of_Operation__c // string(more than 255 characters),
    public String targetCities; //Target_Cities__c string(more than 255 characters),
    public List<String> sourceOfAcquisitions; //Sources_of_Acquisition__c [string],
    public Boolean reviewTitle; //Review_Title__c// boolean,
    public Boolean obtainTitleInsurance; //Obtain_Title_Insurance__c boolean,
    public String titleCompany; // Title_Company__cstring,
    public List<String> priceRangPurProperty;
    public String underwritedAcquisitions; // underwritedAcquisitions string,
    public String fairMarketValue; // Fair_Market_Value__c string,
    public String estimatedRenovationCosts; // Estimated_Renovation_Costs__c string,
    public List<String> costForAcquiredProperties; //Cost_for_Acquired_Properties__c [string],
    public String renovationWorkPerformer; // Renovation_Work_Performer__c string,
    public Boolean lostMoneyOrFixAndFlip; //Lost_Money_Or_Fix_and_Flip__c boolean,
    public String reasonForLosses; //Reason_For_Losses__c string(more than 255 characters),
    public Decimal propertiesOwnedAndOperatedAsPrincipal;
    public String felonyFileUploadedId;
    public String onFinancialSanctionsListFileUploadedId;

    public String pendingLitigationsFileUploadedId;
    public String delinquentOrDefaultOnAnyDebtFileUploadedId;

    public String outstandingJudgementsFileUploadedId;
    public String propertyViolationsInvestigations5yrFileUploadedId;
    public String isLawsuitDefendantFileUploadedId;
    public String portfolioProperiesLitigationsFileUploadedId;
    public String isPermanentResidentAlienFileUploadedId;
    public String isForeignNationalFileUploadedId;
    public String isUsCitizenFileUploadedId;
    // public String avgRenovateCost;
    // public String averagePurchasePrice;
    // public String averagePropertyHoldTime;
    public String propertiesAvgHoldTime;
    public String avgRenovateCost;
    public String propertiesAvgPurchasePrice;
    public String financingForEachProject;
    public String propertyStrategy;

    public String felonyFileName;
    public String onFinancialSanctionsListFileName;
    public String pendingLitigationsFileName;
    public String delinquentOrDefaultOnAnyDebtFileName;
    public String outstandingJudgementsFileName;
    public String propertyViolationsInvestigations5yrFileName;
    public String isLawsuitDefendantFileName;
    public String portfolioProperiesLitigationsFileName;
    public String isPermanentResidentAlienFileName;
    public String isForeignNationalFileName;
    public String isUsCitizenFileName;

    public Decimal numberOfPropertiesSelfManaged;
    public String spbInvestmentPropertiesSold;
    public String spbRentalPropertiesOwned;
    PrefilledApplication(String portalUserId, String loanType) {
      PortalAPIUser.PortalUser user = new PortalAPIUser.PortalUser(
        portalUserId
      );

      Application mostRecentCompleted;
      Application mostRecentCompletedLoanType;

      Map<String, String> loanTypeMapping = new Map<String, String>{
        'rental' => 'Rental Portfolio',
        'buildForRent' => 'Build For Rent',
        'creditLine' => 'Credit Line',
        'bridgeAndRental' => 'Bridge and Rental',
        'sab' => 'Single Asset Bridge Loan',
        'multifamily' => 'Multifamily'
      };

      String convertedLoanType = loanTypeMapping.get(loanType);

      // Map<String, Application> applicationMap = new Map<String, Application>();
      for (Application__c application : queryApplications(portalId)) {
        if (application.Status__c == 'Completed') {
          if (mostRecentCompleted == null) {
            mostRecentCompleted = new Application(application);
          }

          if (
            convertedLoanType == application.Loan_Type__c &&
            mostRecentCompletedLoanType == null
          ) {
            mostRecentCompletedLoanType = new Application(application);
          }
        }
      }

      if (mostRecentCompleted != null) {
        Map<String, String> fileIds = new Map<String, String>();
        if (mostRecentCompleted.felonyFileUploadedId != null) {
          fileIds.put(
            mostRecentCompleted.felonyFileUploadedId,
            'felonyFileUploadedId'
          );
        }

        if (
          mostRecentCompleted.onFinancialSanctionsListFileUploadedId != null
        ) {
          fileIds.put(
            mostRecentCompleted.onFinancialSanctionsListFileUploadedId,
            'onFinancialSanctionsListFileUploadedId'
          );
        }

        if (mostRecentCompleted.pendingLitigationsFileUploadedId != null) {
          fileIds.put(
            mostRecentCompleted.pendingLitigationsFileUploadedId,
            'pendingLitigationsFileUploadedId'
          );
        }

        if (
          mostRecentCompleted.delinquentOrDefaultOnAnyDebtFileUploadedId != null
        ) {
          fileIds.put(
            mostRecentCompleted.delinquentOrDefaultOnAnyDebtFileUploadedId,
            'delinquentOrDefaultOnAnyDebtFileUploadedId'
          );
        }

        if (mostRecentCompleted.outstandingJudgementsFileUploadedId != null) {
          fileIds.put(
            mostRecentCompleted.outstandingJudgementsFileUploadedId,
            'outstandingJudgementsFileUploadedId'
          );
        }

        if (
          mostRecentCompleted.propertyViolationsInvestigations5yrFileUploadedId !=
          null
        ) {
          fileIds.put(
            mostRecentCompleted.propertyViolationsInvestigations5yrFileUploadedId,
            'propertyViolationsInvestigations5yrFileUploadedId'
          );
        }

        if (mostRecentCompleted.isLawsuitDefendantFileUploadedId != null) {
          fileIds.put(
            mostRecentCompleted.isLawsuitDefendantFileUploadedId,
            'isLawsuitDefendantFileUploadedId'
          );
        }

        if (
          mostRecentCompleted.portfolioProperiesLitigationsFileUploadedId !=
          null
        ) {
          fileIds.put(
            mostRecentCompleted.portfolioProperiesLitigationsFileUploadedId,
            'portfolioProperiesLitigationsFileUploadedId'
          );
        }

        if (
          mostRecentCompleted.isPermanentResidentAlienFileUploadedId != null
        ) {
          fileIds.put(
            mostRecentCompleted.isPermanentResidentAlienFileUploadedId,
            'isPermanentResidentAlienFileUploadedId'
          );
        }

        if (mostRecentCompleted.isForeignNationalFileUploadedId != null) {
          fileIds.put(
            mostRecentCompleted.isForeignNationalFileUploadedId,
            'isForeignNationalFileUploadedId'
          );
        }

        if (mostRecentCompleted.isUsCitizenFileUploadedId != null) {
          fileIds.put(
            mostRecentCompleted.isUsCitizenFileUploadedId,
            'isUsCitizenFileUploadedId'
          );
        }
        system.debug(fileIds);
        // Map<String, String> fileNameMap = new Map<String, String>();
        for (ContentVersion cv : [
          SELECT Id, PathOnClient
          FROM ContentVersion
          WHERE Id IN :fileIds.keySet()
        ]) {
          String fieldName = fileIds.get(cv.Id);
          system.debug(fieldName);
          system.debug('--field name--');
          if (fieldName == 'felonyFileUploadedId') {
            this.felonyFileName = cv.PathOnClient;
          }

          if (fieldName == 'onFinancialSanctionsListFileUploadedId') {
            this.onFinancialSanctionsListFileName = cv.PathOnClient;
          }

          if (fieldName == 'pendingLitigationsFileUploadedId') {
            this.pendingLitigationsFileName = cv.PathOnClient;
          }

          if (fieldName == 'delinquentOrDefaultOnAnyDebtFileUploadedId') {
            this.delinquentOrDefaultOnAnyDebtFileName = cv.PathOnClient;
          }

          if (fieldName == 'outstandingJudgementsFileUploadedId') {
            this.outstandingJudgementsFileName = cv.PathOnClient;
          }

          if (
            fieldName == 'propertyViolationsInvestigations5yrFileUploadedId'
          ) {
            this.propertyViolationsInvestigations5yrFileName = cv.PathOnClient;
          }

          if (fieldName == 'isLawsuitDefendantFileUploadedId') {
            this.isLawsuitDefendantFileName = cv.PathOnClient;
          }

          if (fieldName == 'portfolioProperiesLitigationsFileUploadedId') {
            this.portfolioProperiesLitigationsFileName = cv.PathOnClient;
          }

          if (fieldName == 'isPermanentResidentAlienFileUploadedId') {
            this.isPermanentResidentAlienFileName = cv.PathOnClient;
          }

          if (fieldName == 'isForeignNationalFileUploadedId') {
            this.isForeignNationalFileName = cv.PathOnClient;
          }

          if (fieldName == 'isUsCitizenFileUploadedId') {
            this.isUsCitizenFileName = cv.PathOnClient;
          }
        }

        this.felonyFileUploadedId = mostRecentCompleted.felonyFileUploadedId;
        this.onFinancialSanctionsListFileUploadedId = mostRecentCompleted.onFinancialSanctionsListFileUploadedId;

        this.pendingLitigationsFileUploadedId = mostRecentCompleted.pendingLitigationsFileUploadedId;
        this.delinquentOrDefaultOnAnyDebtFileUploadedId = mostRecentCompleted.delinquentOrDefaultOnAnyDebtFileUploadedId;

        this.outstandingJudgementsFileUploadedId = mostRecentCompleted.outstandingJudgementsFileUploadedId;
        this.propertyViolationsInvestigations5yrFileUploadedId = mostRecentCompleted.propertyViolationsInvestigations5yrFileUploadedId;
        this.isLawsuitDefendantFileUploadedId = mostRecentCompleted.isLawsuitDefendantFileUploadedId;
        this.portfolioProperiesLitigationsFileUploadedId = mostRecentCompleted.portfolioProperiesLitigationsFileUploadedId;
        this.isPermanentResidentAlienFileUploadedId = mostRecentCompleted.isPermanentResidentAlienFileUploadedId;
        this.isForeignNationalFileUploadedId = mostRecentCompleted.isForeignNationalFileUploadedId;
        this.isUsCitizenFileUploadedId = mostRecentCompleted.isUsCitizenFileUploadedId;

        this.firstName = mostRecentCompleted.firstName;
        this.middleName = mostRecentCompleted.middleName;
        this.lastName = mostRecentCompleted.lastName;
        this.email = mostRecentCompleted.email;
        this.dob = mostRecentCompleted.dob;
        this.martialStatus = mostRecentCompleted.martialStatus;
        this.homeAddress = mostRecentCompleted.homeAddress;

        this.pinfoCity = mostRecentCompleted.pinfoCity;
        this.mobilePhone = mostRecentCompleted.mobilePhone;
        this.pinfoState = mostRecentCompleted.pinfoState;
        this.pinfoZip = mostRecentCompleted.pinfoZip;
        this.businessContactCity = mostRecentCompleted.businessContactCity;
        this.businessContactState = mostRecentCompleted.businessContactState;
        this.businessContactZip = mostRecentCompleted.businessContactZip;
        this.businessContactCompanyName = mostRecentCompleted.businessContactCompanyName;
        this.businessContactEmail = mostRecentCompleted.businessContactEmail;
        this.businessContactWorkPhone = mostRecentCompleted.businessContactWorkPhone;
        this.businessContactCompanyAddress = mostRecentCompleted.businessContactCompanyAddress;
        this.businessEntityName = mostRecentCompleted.businessEntityName;
        this.businessEntityDateOfFormation = mostRecentCompleted.businessEntityDateOfFormation;
        this.businessEntityTypeOfCompany = mostRecentCompleted.businessEntityTypeOfCompany;
        this.representedByAttorney = mostRecentCompleted.representedByAttorney;
        this.attorneyContactName = mostRecentCompleted.attorneyContactName; //Attorney_Contact_Name__c
        this.attorneyContactCompanyName = mostRecentCompleted.attorneyContactCompanyName; //Attorney_Contact_Company_Name__c
        this.attorneyContactAddress = mostRecentCompleted.attorneyContactAddress; //Attorney_Contact_Address__c
        this.attorneyContactEmailAddress = mostRecentCompleted.attorneyContactEmailAddress; //Attorney_Contact_Mobile_Phone__c
        this.attorneyContactWorkPhone = mostRecentCompleted.attorneyContactWorkPhone; //Attorney_Contact_Work_Phone__c
        this.attorneyContactMobilePhone = mostRecentCompleted.attorneyContactMobilePhone; //Attorney_Contact_Mobile_Phone__c
        this.attorneyContactCity = mostRecentCompleted.attorneyContactCity;
        this.attorneyContactState = mostRecentCompleted.attorneyContactState;
        this.attorneyContactZip = mostRecentCompleted.attorneyContactZip;

        this.optForCorevestInsuranceAgent = mostRecentCompleted.optForCorevestInsuranceAgent;
        this.insuranceAgentName = mostRecentCompleted.insuranceAgentName; //Insurance_Agent_Name__c
        this.insuranceAgentCompanyName = mostRecentCompleted.insuranceAgentCompanyName; //Insurance_Agent_Company_Name__c
        this.insuranceAgentAddress = mostRecentCompleted.insuranceAgentAddress; //Insurance_Agent_Address__c
        this.insuranceAgentEmailAddress = mostRecentCompleted.insuranceAgentEmailAddress; //Insurance_Agent_Email_Address__c
        this.insuranceAgentWorkPhone = mostRecentCompleted.insuranceAgentWorkPhone; //Insurance_Agent_Work_Phone__c
        this.insuranceAgentMobilePhone = mostRecentCompleted.insuranceAgentMobilePhone;

        this.insuranceAgentCity = mostRecentCompleted.insuranceAgentCity;
        this.insuranceAgentState = mostRecentCompleted.insuranceAgentState;
        this.insuranceAgentZip = mostRecentCompleted.insuranceAgentZip;

        this.willUseThirdPartyTitle = mostRecentCompleted.willUseThirdPartyTitle;
        this.thirdPartyTitleContactName = mostRecentCompleted.thirdPartyTitleContactName;
        this.thirdPartyTitleCompanyName = mostRecentCompleted.thirdPartyTitleCompanyName;
        this.thirdPartyTitleAddress = mostRecentCompleted.thirdPartyTitleAddress;
        this.thirdPartyTitleCity = mostRecentCompleted.thirdPartyTitleCity;
        this.thirdPartyTitleState = mostRecentCompleted.thirdPartyTitleState;
        this.thirdPartyTitleZip = mostRecentCompleted.thirdPartyTitleZip;
        this.thirdPartyTitleWorkPhone = mostRecentCompleted.thirdPartyTitleWorkPhone;
        this.thirdPartyTitleMobilePhone = mostRecentCompleted.thirdPartyTitleMobilePhone;
        this.thirdPartyTitleEmail = mostRecentCompleted.thirdPartyTitleEmail;

        this.felony = mostRecentCompleted.felony; //Felony__c
        this.onFinancialSanctionsList = mostRecentCompleted.onFinancialSanctionsList; //On_Financial_Sanction_List__conFinancialSanctionsList
        this.delinquentOrDefaultOnAnyDebt = mostRecentCompleted.delinquentOrDefaultOnAnyDebt; //Deliquent_Or_Default_On_Any_Debt__c delinquentOrDefaultOnAnyDebt
        this.pendingLitigations = mostRecentCompleted.pendingLitigations; //Pending_Litigations__c
        this.propertyViolationsInvestigations5yr = mostRecentCompleted.propertyViolationsInvestigations5yr; //Property_Violations_Investigations_5yr__c
        this.outstandingJudgements = mostRecentCompleted.outstandingJudgements; //Outstanding_Judgements__c
        this.isLawsuitDefendant = mostRecentCompleted.isLawsuitDefendant; //Is_Lawsuit_Defendant__c
        this.portfolioProperiesLitigations = mostRecentCompleted.portfolioProperiesLitigations; //Portfolio_Properties_Litigations__c
        this.isUsCitizen = mostRecentCompleted.isUsCitizen; //Is_US_Citizen__c
        this.isPermanentResidentAlien = mostRecentCompleted.isPermanentResidentAlien; //Is_Permanent_Resident_Alien__c
        this.isForeignNational = mostRecentCompleted.isForeignNational;

        this.felonyComments = mostRecentCompleted.felonyComments; //Felony__c
        this.onFinancialSanctionsListComments = mostRecentCompleted.onFinancialSanctionsListComments; //On_Financial_Sanction_List__conFinancialSanctionsList
        this.delinquentOrDefaultOnAnyDebtComments = mostRecentCompleted.delinquentOrDefaultOnAnyDebtComments; //Deliquent_Or_Default_On_Any_Debt__c delinquentOrDefaultOnAnyDebt
        this.pendingLitigationsComments = mostRecentCompleted.pendingLitigationsComments; //Pending_Litigations__c
        this.propertyViolationsInvestigations5yrComments = mostRecentCompleted.propertyViolationsInvestigations5yrComments; //Property_Violations_Investigations_5yr__c
        this.outstandingJudgementsComments = mostRecentCompleted.outstandingJudgementsComments; //Outstanding_Judgements__c
        this.isLawsuitDefendantComments = mostRecentCompleted.isLawsuitDefendantComments; //Is_Lawsuit_Defendant__c
        this.portfolioProperiesLitigationsComments = mostRecentCompleted.portfolioProperiesLitigationsComments; //Portfolio_Properties_Litigations__c
        this.isUsCitizenComments = mostRecentCompleted.isUsCitizenComments; //Is_US_Citizen__c
        this.isPermanentResidentAlienComments = mostRecentCompleted.isPermanentResidentAlienComments; //Is_Permanent_Resident_Alien__c
        this.isForeignNationalComments = mostRecentCompleted.isForeignNationalComments;

        this.summary = mostRecentCompleted.summary;
        this.estimatedTotalAssetValue = mostRecentCompleted.estimatedTotalAssetValue; //Estimated_Total_Asset_Value__c= mostRecentCompleted.;
        this.estimatedTotalLiabilityValue = mostRecentCompleted.estimatedTotalLiabilityValue;
        this.estimatedNetWorthValue = mostRecentCompleted.estimatedNetWorthValue; //Estimated_Net_Worth_Value__c
        this.estimatedTotalLiquidAssetValue = mostRecentCompleted.estimatedTotalLiquidAssetValue; //Estimated_Total_Liquid_Asset_Value__c
        this.dateOfEstimation = mostRecentCompleted.dateOfEstimation; //Date_of_Estimation__c//
        this.payoffAmountAsOf = mostRecentCompleted.payoffAmountAsOf; //Payoff_Amount_As_Of__c;
        this.propertiesOwnedAndOperatedAsPrincipal = mostRecentCompleted.propertiesOwnedAndOperatedAsPrincipal;

        if (this.onFinancialSanctionsList == null) {
          this.onFinancialSanctionsListFileUploadedId = mostRecentCompleted.onFinancialSanctionsListFileUploadedId;
        }

        if (this.pendingLitigationsFileUploadedId == null) {
          this.pendingLitigationsFileUploadedId = mostRecentCompleted.pendingLitigationsFileUploadedId;
        }

        if (this.delinquentOrDefaultOnAnyDebtFileUploadedId == null) {
          this.delinquentOrDefaultOnAnyDebtFileUploadedId = mostRecentCompleted.delinquentOrDefaultOnAnyDebtFileUploadedId;
        }

        if (this.outstandingJudgementsFileUploadedId == null) {
          this.outstandingJudgementsFileUploadedId = mostRecentCompleted.outstandingJudgementsFileUploadedId;
        }

        if (this.propertyViolationsInvestigations5yrFileUploadedId == null) {
          this.propertyViolationsInvestigations5yrFileUploadedId = mostRecentCompleted.propertyViolationsInvestigations5yrFileUploadedId;
        }

        if (this.isLawsuitDefendantFileUploadedId == null) {
          this.isLawsuitDefendantFileUploadedId = mostRecentCompleted.isLawsuitDefendantFileUploadedId;
        }

        if (this.portfolioProperiesLitigationsFileUploadedId == null) {
          this.portfolioProperiesLitigationsFileUploadedId = mostRecentCompleted.portfolioProperiesLitigationsFileUploadedId;
        }

        if (this.isForeignNationalFileUploadedId == null) {
          this.isForeignNationalFileUploadedId = mostRecentCompleted.isForeignNationalFileUploadedId;
        }

        if (this.isUsCitizenFileUploadedId == null) {
          this.isUsCitizenFileUploadedId = mostRecentCompleted.isUsCitizenFileUploadedId;
        }
      } else {
        this.firstName = user.firstName;
        this.lastName = user.lastName;
        this.email = user.email;
        this.businessContactCompanyName = user.companyName;
        this.mobilePhone = user.mobilePhone;
        this.businessContactWorkPhone = user.BusinessPhone;

        Lead l = new Lead();
      }

      if (mostRecentCompletedLoanType != null) {
        this.spbInvestmentPropertiesSold = mostRecentCompletedLoanType.spbInvestmentPropertiesSold;
        this.spbRentalPropertiesOwned = mostRecentCompletedLoanType.spbRentalPropertiesOwned;

        this.numberOfPropertiesSelfManaged = mostRecentCompletedLoanType.numberOfPropertiesSelfManaged;
        this.numberOfRentalPropertiesOwned = mostRecentCompletedLoanType.numberOfRentalPropertiesOwned; // Number_of_Rental_Properties_Owned__c numberOfRentalPropertiesOwned integer,
        this.howLongInvestingInRentalProperties = mostRecentCompletedLoanType.howLongInvestingInRentalProperties; // How_Long_Investing_in_Rental_Properties__cstring,
        this.typeOfPropertiesOwned = mostRecentCompletedLoanType.typeOfPropertiesOwned; // Type_of_Rental_Properties_Owned__c[string],
        this.sourceOfRentalProperties = mostRecentCompletedLoanType.sourceOfRentalProperties; //Source_of_the_Rental_Properties__c [string],
        this.howLongToHoldPortfolio = mostRecentCompletedLoanType.howLongToHoldPortfolio; // How_Long_to_Hold_Portfolio__c[string],
        this.propertyManagement = mostRecentCompletedLoanType.propertyManagement; // How_is_Property_Management_Handled__c[string],
        this.propertyManagementCompanies = mostRecentCompletedLoanType.propertyManagementCompanies; // Property_Management_Companies__c[string],
        this.softwareUsed = mostRecentCompletedLoanType.softwareUsed; //Software_Used__c string(more than 255 characters),
        this.yearsExperience = mostRecentCompletedLoanType.yearsExperience; //Years_Experience__c integer,
        this.financingForEachProject = mostRecentCompletedLoanType.financingForEachProject;
        this.propertiesToPurchase = mostRecentCompletedLoanType.propertiesToPurchase; //Properties_To_Purchase__c string,
        this.typeOfProperties = mostRecentCompletedLoanType.typeOfProperties; //Type_Of_Properties__c [string],
        //this.statesOfOperations = mostRecentCompletedLoanType.statesOfOperations; //States_of_Operation__c // string(more than 255 characters),
        this.targetCities = mostRecentCompletedLoanType.targetCities; //Target_Cities__c string(more than 255 characters),
        this.sourceOfAcquisitions = mostRecentCompletedLoanType.sourceOfAcquisitions; //Sources_of_Acquisition__c [string],
        this.reviewTitle = mostRecentCompletedLoanType.reviewTitle; //Review_Title__c// boolean,
        this.obtainTitleInsurance = mostRecentCompletedLoanType.obtainTitleInsurance; //Obtain_Title_Insurance__c boolean,
        this.titleCompany = mostRecentCompletedLoanType.titleCompany; // Title_Company__cstring,
        this.priceRangPurProperty = mostRecentCompletedLoanType.priceRangPurProperty;
        this.underwritedAcquisitions = mostRecentCompletedLoanType.underwritedAcquisitions; // underwritedAcquisitions string,
        this.fairMarketValue = mostRecentCompletedLoanType.fairMarketValue; // Fair_Market_Value__c string,
        this.estimatedRenovationCosts = mostRecentCompletedLoanType.estimatedRenovationCosts; // Estimated_Renovation_Costs__c string,
        this.costForAcquiredProperties = mostRecentCompletedLoanType.costForAcquiredProperties; //Cost_for_Acquired_Properties__c [string],
        this.renovationWorkPerformer = mostRecentCompletedLoanType.renovationWorkPerformer; // Renovation_Work_Performer__c string,
        this.lostMoneyOrFixAndFlip = mostRecentCompletedLoanType.lostMoneyOrFixAndFlip; //Lost_Money_Or_Fix_and_Flip__c boolean,
        this.reasonForLosses = mostRecentCompletedLoanType.reasonForLosses; //Reason_For_Losses__c string(more than 255 characters),
        this.operationalStates = mostRecentCompletedLoanType.operationalStates;
        this.avgRenovateCost = mostRecentCompletedLoanType.avgRenovateCost;
        this.propertyStrategy = mostRecentCompletedLoanType.propertyStrategy;
        // this.averagePropertyHoldTime = mostRecentCompletedLoanType.averagePropertyHoldTime;
        // this.averagePurchasePrice = mostRecentCompletedLoanType.averagePurchasePrice;
        this.propertiesAvgHoldTime = mostRecentCompletedLoanType.propertiesAvgHoldTime;
        // public String avgRenovateCost;
        // this.propertiesAvgPurchasePrice = mostRecentCompletedLoanType.propertiesAvgPurchasePrice;
        this.propertiesOwnedAndOperatedAsPrincipal = mostRecentCompletedLoanType.propertiesOwnedAndOperatedAsPrincipal;
        this.propertiesAvgPurchasePrice = mostRecentCompletedLoanType.propertiesAvgPurchasePrice;
      }

      //
    }
  }

  public virtual class Application {
    public Id id; //id
    public String status;
    public String loanType; // Loan_Type__cloanType
    public Decimal loanId; //Loan_Id__c
    public String user_id; //Alchemy_User_Id__c
    public String broker_id;
    public String dealId;

    public Boolean formCompleted;
    public String firstName; //First_Name__c
    public String middleName;
    public String lastName; //Last_Name__c
    public String homeAddress; //Home_Address__c
    public String email;
    public String mobilePhone; //Mobile_Phone__c
    public Date dob; //DOB
    public String martialStatus; //Marital_Status__c

    public String businessContactCity;
    public String businessContactState;
    public String businessContactZip;
    public String businessContactCompanyName; //Business_Contact_Company_Name__c;
    public String businessContactCompanyAddress; //Business_Contact_Company_Address__c;
    public String businessContactEmail; //Business_Contact_Email__c;
    public String businessContactWorkPhone;
    public String businessEntityName; //Business_Entity_Name__c;
    public Date businessEntityDateOfFormation; //Business_Entity_Date_Of_Formation__c
    public String businessEntityTypeOfCompany; //Business_Entity_Type_Of_Company__c

    public String pinfoCity;
    public String pinfoState;
    public String pinfoZip;
    public List<PrincipalInfo> principalInfos; //PrincipalInfos_JSON__c

    public String attorneyContactName; //Attorney_Contact_Name__c
    public String attorneyContactCompanyName; //Attorney_Contact_Company_Name__c
    public String attorneyContactAddress; //Attorney_Contact_Address__c
    public String attorneyContactEmailAddress; //Attorney_Contact_Mobile_Phone__c
    public String attorneyContactWorkPhone; //Attorney_Contact_Work_Phone__c
    public String attorneyContactMobilePhone; //Attorney_Contact_Mobile_Phone__c
    public String attorneyContactCity;
    public String attorneyContactState;
    public String attorneyContactZip;

    public String insuranceAgentName; //Insurance_Agent_Name__c
    public String insuranceAgentCompanyName; //Insurance_Agent_Company_Name__c
    public String insuranceAgentAddress; //Insurance_Agent_Address__c
    public String insuranceAgentEmailAddress; //Insurance_Agent_Email_Address__c
    public String insuranceAgentWorkPhone; //Insurance_Agent_Work_Phone__c
    public String insuranceAgentMobilePhone; //Insurance_Agent_Mobile_Phone__c
    public String insuranceAgentState;
    public String insuranceAgentCity;
    public String insuranceAgentZip;

    public Boolean felony; //Felony__c
    public Boolean onFinancialSanctionsList; //On_Financial_Sanction_List__conFinancialSanctionsList
    public Boolean delinquentOrDefaultOnAnyDebt; //Deliquent_Or_Default_On_Any_Debt__c delinquentOrDefaultOnAnyDebt
    public Boolean pendingLitigations; //Pending_Litigations__c
    public Boolean propertyViolationsInvestigations5yr; //Property_Violations_Investigations_5yr__c
    public Boolean outstandingJudgements; //Outstanding_Judgements__c
    public Boolean isLawsuitDefendant; //Is_Lawsuit_Defendant__c
    public Boolean portfolioProperiesLitigations; //Portfolio_Properties_Litigations__c
    public Boolean isUsCitizen; //Is_US_Citizen__c
    public Boolean isPermanentResidentAlien; //Is_Permanent_Resident_Alien__c
    public Boolean isForeignNational; //isForeignNational
    public String country; //Country__c

    public String summary; //Summary__c
    public Decimal estimatedTotalAssetValue; //Estimated_Total_Asset_Value__c;
    public Decimal estimatedTotalLiabilityValue; //Estimated_Total_Liability_Value__c
    public Decimal estimatedNetWorthValue; //Estimated_Net_Worth_Value__c
    public Decimal estimatedTotalLiquidAssetValue; //Estimated_Total_Liquid_Asset_Value__c
    public Date dateOfEstimation; //Date_of_Estimation__c//

    public Decimal loanDesiredAmount; //Loan_Desired_Amount__c;
    public List<String> loanPurpose; //Loan_Purpose__c;
    public Decimal lenderPayoffPropertyNumber; //Lender_Payoff_Property_Number__c;
    public Decimal estimatedPayoffAmount; //Estimated_Payoff_Amount__c;
    public Date payoffAmountAsOf; //Payoff_Amount_As_Of__c;
    public Decimal estimatedPrepaymentPenalties; //Estimated_Prepayment_Penalties__c;
    public Boolean interestRateCheckbox; //Interest_Rate_Checkbox__c;
    public String occupationStatement; //Occupation_Statement__c occupationStatement;

    public String signature; //Signature__c string(more than 255 characters),
    public String title; //Title__c string,
    public String name; //Name__c string,
    public Date signatureDate; //Signature_Date__c date,
    public String creditPullSignature; // Credit_Pull_Signature__cstring(more than 255 characters),
    public String creditPullSignName; // Credit_Pull_Sign_Name__cstring,
    public Date creditPullSignDate; //Credit_Pull_Sign_Date__c date,

    public List<String> ethnicity; //Ethnicity__c [string],
    public List<String> race; // Race__c[string],
    public String sex; // Sex__cstring,

    public Decimal numberOfRentalPropertiesOwned; // Number_of_Rental_Properties_Owned__c numberOfRentalPropertiesOwned integer,
    public String howLongInvestingInRentalProperties; // How_Long_Investing_in_Rental_Properties__cstring,
    public Decimal estimatedValueOfPortfolio; // Estimated_Value_of_Entire_Portfolio__c integer,
    public String propertiesAvgPurchasePrice; //Average_Rental_Property_Purchase_Price__c integer,
    public String propertiesAvgHoldTime; //Average_Hold_Time_of_Rental_Properties__c string,
    public String averagePurchasePrice;
    public String averagePropertyHoldTime;
    public String avgRenovateCost; // Average_Cost_of_Rental_Property_Reno__cinteger,
    public List<String> typeOfPropertiesOwned; // Type_of_Rental_Properties_Owned__c[string],
    public List<String> sourceOfRentalProperties; //Source_of_the_Rental_Properties__c [string],
    public String howLongToHoldPortfolio; // How_Long_to_Hold_Portfolio__c[string],
    public String propertyManagement; // How_is_Property_Management_Handled__c[string],
    public String propertyManagementCompanies; // Property_Management_Companies__c[string],
    public String softwareUsed; //Software_Used__c string(more than 255 characters),
    public Decimal yearsExperience; //Years_Experience__c integer,
    public Decimal numberOfPropertiesSelfManaged; //Number_of_Properties_Self_Managed__c integer,
    public Boolean hasLostMoney; //Has_Lost_Money_on_Property__c boolean,
    public String reasonMoneyLost; //Reason_for_Lost_Money__c string(more than 255 characters),

    public String propertiesToPurchase; //Properties_To_Purchase__c string,
    public List<String> typeOfProperties; //Type_Of_Properties__c [string],
    public List<String> operationalStates; //States_of_Operation__c // string(more than 255 characters),
    public String targetCities; //Target_Cities__c string(more than 255 characters),
    public List<String> sourceOfAcquisitions; //Sources_of_Acquisition__c [string],
    public Boolean reviewTitle; //Review_Title__c// boolean,
    public Boolean obtainTitleInsurance; //Obtain_Title_Insurance__c boolean,
    public String titleCompany; // Title_Company__cstring,
    //public String rangeOfProperties; //Range_of_Properties__c string,
    public List<String> priceRangPurProperty;
    public String underwritedAcquisitions; // underwritedAcquisitions string,
    public String fairMarketValue; // Fair_Market_Value__c string,
    public String estimatedRenovationCosts; // Estimated_Renovation_Costs__c string,
    public List<String> costForAcquiredProperties; //Cost_for_Acquired_Properties__c [string],
    public String renovationWorkPerformer; // Renovation_Work_Performer__c string,
    public String exitStrategy; // string,
    public String planToFixAndFlip; // Plan_To_Fix_and_Flip__c string,
    public String financingForEachProject; //Financing_For_Each_Project__c string,
    public Boolean planToPurchaseRefinancingProperties; //Plan_To_Purchase_Refinacing_Properties__c boolean,
    public Boolean lostMoneyOrFixAndFlip; //Lost_Money_Or_Fix_and_Flip__c boolean,
    public String reasonForLosses; //Reason_For_Losses__c string(more than 255 characters),

    public Boolean representedByAttorney;
    public String felonyComments;
    public String onFinancialSanctionsListComments;
    public String delinquentOrDefaultOnAnyDebtComments;
    public String pendingLitigationsComments;
    public String propertyViolationsInvestigations5yrComments;
    public String isLawsuitDefendantComments;
    public String outstandingJudgementsComments;
    public String portfolioProperiesLitigationsComments;
    public String isUsCitizenComments;
    public String isPermanentResidentAlienComments;
    public String isForeignNationalComments;
    public Boolean optForCorevestInsuranceAgent;

    public String spbTransactionType; //Transaction_Type__c
    public Decimal spbPurchasePrice; //
    public Date spbEstimatedClosingDate; //
    public Decimal spbEstimatedAsIsValue; //
    public String spbStreetAddress; //
    public String spbCity; //
    public String spbState; //
    public String spbZipCode; //
    public String spbPropertyType; //
    public Decimal spbNoUnits; //
    public Boolean spbPlanRehabProperty; //
    public String spbSummaryRehabWork; //
    public String spbPerformRehabWork; //
    // public Decimal spbEstimatedRehabCost; //Estimated_Renovation_Costs__c
    public Decimal spbEstimatedAsRepairedValue; //
    public Boolean spbApplyingPurposeInvestmentLoan; //
    // public Decimal spbTotalLoanAmountRequested; //
    public String spbLongLoanNeeded; //
    public Decimal spbCurrentPayoffAmount; //
    public String spbIntendToPayLoan; //
    public String spbInvestmentPropertiesSold; //
    public String spbRentalPropertiesOwned; //
    public Decimal propertiesOwnedAndOperatedAsPrincipal; //
    public Decimal propertiesOwnedAsPrincipal; //
    public Decimal constructionProjectsCompleted; //
    public Decimal renovationPrincipalRental; //
    public Decimal renovationPrincipalSale; //
    public String creOtherLoanPurpose; //
    public List<String> creLoanType; //
    public String creOtherLoanType; //
    public String projectType; //
    public String otherProjectType; //
    // public String creExitStrategy; //
    public String otherCreExitStrategy; //
    public List<String> refinanceStrategy; //
    public String otherRefinanceStrategy; //
    public String longPropertiesHold; //
    public String propertyStrategy;
    // public String handlePropertiesManagement; //
    // public String thirdPartyPropertiesManagement; //
    // public Decimal creYearsOfExperience; //
    // public Decimal creNumberOfPropertiesSelfManaged; //
    public String otherTypeOfProperties; //

    public boolean acknowledgementFinalLoanProceeds;

    public boolean willUseThirdPartyTitle;
    public String thirdPartyTitleCompanyName;
    public String thirdPartyTitleContactName;
    public String thirdPartyTitleAddress;
    public String thirdPartyTitleMobilePhone;
    public String thirdPartyTitleWorkPhone;
    public String thirdPartyTitleEmail;
    public String thirdPartyTitleState;
    public String thirdPartyTitleCity;
    public String thirdPartyTitleZip;

    public String lender;

    public String felonyFileUploadedId;
    public String onFinancialSanctionsListFileUploadedId;

    public String pendingLitigationsFileUploadedId;
    public String delinquentOrDefaultOnAnyDebtFileUploadedId;

    public String outstandingJudgementsFileUploadedId;
    public String propertyViolationsInvestigations5yrFileUploadedId;
    public String isLawsuitDefendantFileUploadedId;
    public String portfolioProperiesLitigationsFileUploadedId;
    public String isPermanentResidentAlienFileUploadedId;
    public String isForeignNationalFileUploadedId;
    public String isUsCitizenFileUploadedId;

    Application() {
    }

    Application(Application__c application) {
      this.willUseThirdPartyTitle = application.Will_Use_Third_Party_Title__c;
      this.thirdPartyTitleCompanyName = application.Third_Party_Title_Company_Name__c;
      this.thirdPartyTitleContactName = application.Third_Party_Title_Contact_Name__c;
      this.thirdPartyTitleAddress = application.Third_Party_Title_Address__c;
      this.thirdPartyTitleMobilePhone = application.Third_Party_Title_Mobile_Phone__c;
      this.thirdPartyTitleWorkPhone = application.Third_Party_Title_Work_Phone__c;
      this.thirdPartyTitleEmail = application.Third_Party_Title_Email__c;
      this.thirdPartyTitleCity = application.Third_Party_Title_City__c;
      this.thirdPartyTitleState = application.Third_party_title_State__c;
      this.thirdPartyTitleZip = application.Third_Party_Title_Zip__c;

      this.representedByAttorney = application.Represented_by_an_Attorney__c;
      this.felonyComments = application.Felony_Comments__c;
      this.delinquentOrDefaultOnAnyDebtComments = application.Deliquent_Or_Default_On_Any_Debt_Comment__c;
      this.onFinancialSanctionsListComments = application.On_Financial_Sanction_List_Comments__c;
      this.pendingLitigationsComments = application.Pending_Litigations_Comments__c;
      this.propertyViolationsInvestigations5yrComments = application.Violations_Investigations_Comments__c;
      this.isLawsuitDefendantComments = application.Is_Lawsuit_Defendant_Comments__c;
      this.outstandingJudgementsComments = application.Outstanding_Judgements_Comments__c;
      this.portfolioProperiesLitigationsComments = application.Portfolio_Properties_Litigations_Comment__c;
      this.isUsCitizenComments = application.Is_US_Citizen_Comments__c;
      this.isPermanentResidentAlienComments = application.Is_Permanent_Resident_Alien_Comments__c;
      this.isForeignNationalComments = application.Is_Foreign_National_Comments__c;

      this.status = application.Status__c;
      this.id = application.Id;
      this.dealId = application.Deal__c;
      this.loanType = application.Loan_Type__c;
      this.loanId = application.Loan_Id__c;

      this.user_id = application.Alchemy_User_Id__c;
      this.broker_id = application.Broker_Alchemy_User_Id__c;
      this.formCompleted = application.Form_Completed__c;
      this.firstName = application.First_Name__c;
      this.middleName = application.Middle_Name__c;
      this.lastName = application.Last_Name__c;
      this.homeAddress = application.Home_Address__c;
      this.email = application.Email__c;
      this.mobilePhone = application.Mobile_Phone__c;
      this.dob = application.DOB__c;
      this.martialStatus = application.Marital_Status__c;

      this.businessContactCity = application.Business_Contact_City__c;
      this.businessContactState = application.Business_Contact_State__c;
      this.businessContactZip = application.Business_Contact_Zip__c;
      this.businessContactEmail = application.BUsiness_Contact_Email__c;
      this.businessContactCompanyName = application.Business_Contact_Company_Name__c;
      this.businessContactCompanyAddress = application.Business_Contact_Company_Address__c;
      this.businessContactWorkPhone = application.Business_Contact_Work_Phone__c;
      this.businessEntityName = application.Business_Entity_Place_of_Formation__c; //Business_Entity_Name__c;
      this.businessEntityDateOfFormation = application.Business_Entity_Date_Of_Formation__c;
      this.businessEntityTypeOfCompany = application.Business_Entity_Type_Of_Company__c;

      this.pinfoCity = application.Principal_Info_City__c;
      this.pinfoState = application.Principal_Info_State__c;
      this.pinfoZip = application.Principal_Info_Zip__c;

      if (String.isNotBlank(application.PrincipalInfos_JSON__c)) {
        this.principalInfos = (List<PrincipalInfo>) Json.deserialize(
          application.PrincipalInfos_JSON__c,
          List<PrincipalInfo>.class
        );
      }
      this.attorneyContactName = application.Attorney_Contact_Name__c;
      this.attorneyContactCompanyName = application.Attorney_Contact_Company_Name__c;
      this.attorneyContactAddress = application.Attorney_Contact_Address__c;
      this.attorneyContactEmailAddress = application.Attorney_Contact_Email_Address__c;
      this.attorneyContactWorkPhone = application.Attorney_Contact_Work_Phone__c;
      this.attorneyContactMobilePhone = application.Attorney_Contact_Mobile_Phone__c;
      this.attorneyContactState = application.Attorney_Contact_State__c;
      this.attorneyContactCity = application.Attorney_Contact_City__c;
      this.attorneyContactZip = application.Attorney_Contact_Zip__c;

      this.insuranceAgentName = application.Insurance_Agent_Name__c;
      this.insuranceAgentCompanyName = application.Insurance_Agent_Company_Name__c;
      this.insuranceAgentAddress = application.Insurance_Agent_Address__c;
      this.insuranceAgentEmailAddress = application.Insurance_Agent_Email_Address__c;
      this.insuranceAgentWorkPhone = application.Insurance_Agent_Work_Phone__c;
      this.insuranceAgentMobilePhone = application.Insurance_Agent_Mobile_Phone__c;
      this.insuranceAgentCity = application.Insurance_Agent_City__c;
      this.insuranceAgentState = application.Insurance_Agent_State__c;
      this.insuranceAgentZip = application.Insurance_Agent_Zip__c;

      this.felony = application.Felony__c;
      this.onFinancialSanctionsList = application.On_Financial_Sanction_List__c;
      this.delinquentOrDefaultOnAnyDebt = application.Deliquent_Or_Default_On_Any_Debt__c;
      this.pendingLitigations = application.Pending_Litigations__c;
      this.propertyViolationsInvestigations5yr = application.Property_Violations_Investigations_5yr__c;
      this.outstandingJudgements = application.Outstanding_Judgements__c;
      this.isLawsuitDefendant = application.Is_Lawsuit_Defendant__c;
      this.portfolioProperiesLitigations = application.Portfolio_Properties_Litigations__c;
      this.isUsCitizen = application.Is_US_Citizen__c;
      this.isPermanentResidentAlien = application.Is_Permanent_Resident_Alien__c;
      this.isForeignNational = application.Is_Foreign_National__c;
      this.country = application.Country__c;
      this.summary = application.Summary__c;
      this.estimatedTotalAssetValue = application.Estimated_Total_Asset_Value__c;
      this.estimatedTotalLiabilityValue = application.Estimated_Total_Liability_Value__c;
      this.estimatedNetWorthValue = application.Estimated_Net_Worth_Value__c;
      this.estimatedTotalLiquidAssetValue = application.Estimated_Total_Liquid_Asset_Value__c;
      this.dateOfEstimation = application.Date_of_Estimation__c;
      this.loanDesiredAmount = application.Loan_Desired_Amount__c;
      if (String.isNotBlank(application.Loan_Purpose__c)) {
        this.loanPurpose = application.Loan_Purpose__c.split(';');
      }
      this.lenderPayoffPropertyNumber = application.Lender_Payoff_Property_Number__c;
      this.estimatedPayoffAmount = application.Estimated_Payoff_Amount__c;
      this.payoffAmountAsOf = application.Payoff_Amount_As_Of__c;
      this.estimatedPrepaymentPenalties = application.Estimated_Prepayment_Penalties__c;
      this.interestRateCheckbox = application.Interest_Rate_Checkbox__c;
      this.occupationStatement = application.Occupation_Statement__c;
      this.signature = application.Signature__c;
      this.title = application.Title__c;
      this.name = application.Name__c;
      this.signatureDate = application.Signature_Date__c;
      this.creditPullSignature = application.Credit_Pull_Signature__c;
      this.creditPullSignName = application.Credit_Pull_Sign_Name__c;
      this.creditPullSignDate = application.Credit_Pull_Sign_Date__c;
      if (String.isNotBlank(application.Ethnicity__c)) {
        this.ethnicity = application.Ethnicity__c.split(';');
      }
      this.propertyStrategy = application.Property_Strategy__c;
      this.lender = application.Lender__c;

      // if (String.isNotBlank(application.Sex__c)) {
      //   this.sex = application.Sex__c.split(';');
      // }

      this.sex = application.Sex__c;

      if (String.isNotBlank(application.Race__c)) {
        this.race = application.Race__c.split(';');
      }

      this.numberOfRentalPropertiesOwned = application.Number_of_Rental_Properties_Owned__c;
      this.howLongInvestingInRentalProperties = application.How_Long_Investing_in_Rental_Properties__c;
      this.estimatedValueOfPortfolio = application.Estimated_Value_of_Entire_Portfolio__c;
      this.propertiesAvgPurchasePrice = application.Average_Rental_Property_Purchase_Price__c;
      // this.averagePurchasePrice = application.Average_Rental_Property_Purchase_Price__c;
      // this.averagePropertyHoldTime = application.Average_Rental_Property_Purchase_Price__c;
      this.propertiesAvgHoldTime = application.Average_Hold_Time_of_Rental_Properties__c;
      this.avgRenovateCost = application.Average_Cost_of_Rental_Property_Reno__c;

      if (String.isNotBlank(application.Type_of_Rental_Properties_Owned__c)) {
        this.typeOfPropertiesOwned = application.Type_of_Rental_Properties_Owned__c.split(
          ';'
        );
      }
      if (String.isNotBlank(application.Source_of_the_Rental_Properties__c)) {
        this.sourceOfRentalProperties = application.Source_of_the_Rental_Properties__c.split(
          ';'
        );
      }

      // if (String.isNotBlank(application.How_Long_to_Hold_Portfolio__c)) {
      //   this.howLongToHoldPortfolio = application.How_Long_to_Hold_Portfolio__c.split(
      //     ';'
      //   );
      // }
      this.howLongToHoldPortfolio = application.How_Long_to_Hold_Portfolio__c;
      // if (
      //   String.isNotBlank(application.How_is_Property_Management_Handled__c)
      // ) {
      //   this.propertyManagement = application.How_is_Property_Management_Handled__c.split(
      //     ';'
      //   );
      // }

      this.propertyManagement = application.How_is_Property_Management_Handled__c;

      // if (String.isNotBlank(application.Property_Management_Companies__c)) {
      //   this.propertyManagementCompanies = application.Property_Management_Companies__c.split(
      //     ';'
      //   );
      // }

      this.propertyManagementCompanies = application.Property_Management_Companies__c;

      this.softwareUsed = application.Software_Used__c;
      this.yearsExperience = application.Years_Experience__c;
      this.numberOfPropertiesSelfManaged = application.Number_of_Properties_Self_Managed__c;
      this.hasLostMoney = application.Has_Lost_Money_on_Property__c;
      this.reasonMoneyLost = application.Reason_for_Lost_Money__c;
      this.propertiesToPurchase = application.Properties_To_Purchase__c;

      if (String.isNotBlank(application.Type_Of_Properties__c)) {
        this.typeOfProperties = application.Type_Of_Properties__c.split(';');
      }

      if (String.isNotBlank(application.States_of_Operation__c)) {
        this.operationalStates = application.States_of_Operation__c.split(';');
      }

      this.targetCities = application.Target_Cities__c;

      if (String.isNotBlank(application.Sources_of_Acquisition__c)) {
        this.sourceOfAcquisitions = application.Sources_of_Acquisition__c.split(
          ';'
        );
      }

      this.reviewTitle = application.Review_Title__c;
      this.obtainTitleInsurance = application.Obtain_Title_Insurance__c;
      this.titleCompany = application.Title_Company__c;
      //this.rangeOfProperties = application.Range_of_Properties__c;
      if (String.isNotBlank(application.Range_of_Properties__c)) {
        this.priceRangPurProperty = application.Range_of_Properties__c.split(
          ';'
        );
      }
      this.underwritedAcquisitions = application.Underwrited_Acquisitions__c;
      this.fairMarketValue = application.Fair_Market_Value__c;

      this.estimatedRenovationCosts = application.Estimated_Renovation_Costs__c;

      if (String.isNotBlank(application.Cost_for_Acquired_Properties__c)) {
        this.costForAcquiredProperties = application.Cost_for_Acquired_Properties__c.split(
          ';'
        );
      }

      this.renovationWorkPerformer = application.Renovation_Work_Performer__c;
      this.exitStrategy = application.Exit_Strategy__c;
      this.planToFixAndFlip = application.Plan_To_Fix_and_Flip__c;
      this.financingForEachProject = application.Financing_For_Each_Project__c;
      this.planToPurchaseRefinancingProperties = application.Plan_To_Purchase_Refinacing_Properties__c;
      this.lostMoneyOrFixAndFlip = application.Lost_Money_Or_Fix_and_Flip__c;
      this.reasonForLosses = application.Reason_For_Losses__c;

      this.optForCorevestInsuranceAgent = application.Opt_for_CoreVest_Insurance_Agent__c;

      this.felonyFileUploadedId = application.Felony_File_Id__c;
      this.onFinancialSanctionsListFileUploadedId = application.Financial_Sanctions_File_Id__c;

      this.pendingLitigationsFileUploadedId = application.Pending_Litigations_File_Id__c;
      this.delinquentOrDefaultOnAnyDebtFileUploadedId = application.Delinquent_Debt_File_Id__c;

      this.outstandingJudgementsFileUploadedId = application.Outstanding_Judgement_File_Id__c;
      this.propertyViolationsInvestigations5yrFileUploadedId = application.Property_Violations_File_Id__c;
      this.isLawsuitDefendantFileUploadedId = application.Lawsuit_Defendent_File_Id__c;
      this.portfolioProperiesLitigationsFileUploadedId = application.Portfolio_Properties_File_Id__c;
      this.isPermanentResidentAlienFileUploadedId = application.Permanent_Resident_File_Id__c;
      this.isForeignNationalFileUploadedId = application.Foreign_National_File_Id__c;
      this.isUsCitizenFileUploadedId = application.US_Citizen_File_Id__c;

      this.spbTransactionType = application.Transaction_Type__c;
      this.spbPurchasePrice = application.Purchase_Price__c;
      this.spbEstimatedClosingDate = application.Estimated_Closing_Date__c;
      this.spbEstimatedAsIsValue = application.Estimated_As_Is_Value__c;
      this.spbStreetAddress = application.Property_Street_Address__c;
      this.spbCity = application.Property_City__c;
      this.spbState = application.Property_State__c;
      this.spbZipCode = application.Property_Zip_Code__c;
      this.spbPropertyType = application.Property_Type__c;
      this.spbNoUnits = application.Number_of_Units__c;
      this.spbPlanRehabProperty = application.Plan_Rehab_on_Property__c;
      this.spbSummaryRehabWork = application.Summary_of_Rehab_Work__c;
      this.spbPerformRehabWork = application.Perform_Rehab_Work__c;
      // this.spbEstimatedRehabCost = application.Estimated_Renovation_Costs__c;
      this.spbEstimatedAsRepairedValue = application.Estimated_As_Repaired_Value__c;
      this.spbApplyingPurposeInvestmentLoan = application.Applying_Purpose_Investment_Loan__c;
      // this.spbTotalLoanAmountRequested = application.Loan_Desired_Amount__c;
      this.spbLongLoanNeeded = application.Long_Loan_Needed__c;
      this.spbCurrentPayoffAmount = application.Current_Payoff_Amount__c;
      this.spbIntendToPayLoan = application.Intend_To_Pay_Loan__c;
      this.spbInvestmentPropertiesSold = application.Investment_Properties_Sold__c;
      this.spbRentalPropertiesOwned = application.Rental_Properties_Owned__c;
      this.propertiesOwnedAndOperatedAsPrincipal = application.Properties_Owned_Operated_as_Principal__c;
      this.propertiesOwnedAsPrincipal = application.Properties_Owned_as_Principal__c;
      this.constructionProjectsCompleted = application.Construction_Projects_Completed__c;
      this.renovationPrincipalRental = application.Renovation_Principal_Rental__c;
      this.renovationPrincipalSale = application.Renovation_Principal_Sale__c;
      this.creOtherLoanPurpose = application.Other_Loan_Purpose__c;
      if (String.isNotBlank(application.CRE_Loan_Type__c)) {
        this.typeOfProperties = application.CRE_Loan_Type__c.split(';');
      }
      this.creOtherLoanType = application.Other_Loan_Type__c;
      this.projectType = application.Project_Type__c;
      this.otherProjectType = application.Other_Project_Type__c;
      // this.creExitStrategy = application.Exit_Strategy__c;
      this.otherCreExitStrategy = application.Other_Exit_Strategy__c;
      if (String.isNotBlank(application.Refinance_Strategy__c)) {
        this.refinanceStrategy = application.Refinance_Strategy__c.split(';');
      }
      this.otherRefinanceStrategy = application.Other_Refinance_Strategy__c;
      this.longPropertiesHold = application.Long_Properties_Hold__c;
      // this.handlePropertiesManagement = application.How_is_Property_Management_Handled__c;
      // this.thirdPartyPropertiesManagement = application.Property_Management_Companies__c;
      // this.creYearsOfExperience = application.Years_Experience__c;
      // this.creNumberOfPropertiesSelfManaged = application.Number_of_Properties_Self_Managed__c;
      this.otherTypeOfProperties = application.Other_Type_of_Properties__c;
    }

    public Application__c getRecord() {
      // this.representedByAttorney = this.representedByAttorney != null
      //   ? this.representedByAttorney
      //   : false;

      // this.willUseThirdPartyTitle = this.willUseThirdPartyTitle != null
      //   ? this.willUseThirdPartyTitle
      //   : false;

      // this.acknowledgementFinalLoanProceeds = this.acknowledgementFinalLoanProceeds !=
      //   null
      //   ? this.acknowledgementFinalLoanProceeds
      //   : false;

      this.formCompleted = this.formCompleted != null
        ? this.formCompleted
        : false;
      // this.felony = this.felony != null ? this.felony : false;
      // this.onFinancialSanctionsList = this.onFinancialSanctionsList != null
      //   ? this.onFinancialSanctionsList
      //   : false;
      // this.delinquentOrDefaultOnAnyDebt = this.delinquentOrDefaultOnAnyDebt !=
      //   null
      //   ? this.delinquentOrDefaultOnAnyDebt
      //   : false;
      // this.pendingLitigations = this.pendingLitigations != null
      //   ? this.pendingLitigations
      //   : false;
      // this.propertyViolationsInvestigations5yr = this.propertyViolationsInvestigations5yr !=
      //   null
      //   ? this.propertyViolationsInvestigations5yr
      //   : false;
      // this.outstandingJudgements = this.outstandingJudgements != null
      //   ? this.outstandingJudgements
      //   : false;
      // this.isLawsuitDefendant = this.isLawsuitDefendant != null
      //   ? this.isLawsuitDefendant
      //   : false;
      // this.portfolioProperiesLitigations = this.portfolioProperiesLitigations !=
      //   null
      //   ? this.portfolioProperiesLitigations
      //   : false;
      // this.isUsCitizen = this.isUsCitizen != null ? this.isUsCitizen : false;
      // this.isPermanentResidentAlien = this.isPermanentResidentAlien != null
      //   ? this.isPermanentResidentAlien
      //   : false;

      // this.interestRateCheckbox = this.interestRateCheckbox != null
      //   ? this.interestRateCheckbox
      //   : false;

      // this.hasLostMoney = this.hasLostMoney != null ? this.hasLostMoney : false;

      // this.reviewTitle = this.reviewTitle != null ? this.reviewTitle : false;
      // this.lostMoneyOrFixAndFlip = this.lostMoneyOrFixAndFlip != null
      //   ? this.lostMoneyOrFixAndFlip
      //   : false;

      // this.optForCorevestInsuranceAgent = this.optForCorevestInsuranceAgent !=
      //   null
      //   ? this.optForCorevestInsuranceAgent
      //   : false;

      Application__c application = new Application__c();

      if (this.willUseThirdPartyTitle != null) {
        application.Will_Use_Third_Party_Title__c = this.willUseThirdPartyTitle;
      }
      application.Third_Party_Title_Company_Name__c = this.thirdPartyTitleCompanyName;
      application.Third_Party_Title_Contact_Name__c = this.thirdPartyTitleContactName;
      application.Third_Party_Title_Address__c = this.thirdPartyTitleAddress;
      application.Third_Party_Title_Mobile_Phone__c = this.thirdPartyTitleMobilePhone;
      application.Third_Party_Title_Work_Phone__c = this.thirdPartyTitleWorkPhone;
      application.Third_Party_Title_Email__c = this.thirdPartyTitleEmail;
      application.Third_Party_Title_City__c = this.thirdPartyTitleCity;
      application.Third_Party_Title_State__c = this.thirdPartyTitleState;
      application.Third_party_Title_Zip__c = this.thirdPartyTitleZip;

      application.Lender__c = this.lender;
      application.Felony_File_Id__c = this.felonyFileUploadedId;
      application.Financial_Sanctions_File_Id__c = this.onFinancialSanctionsListFileUploadedId;

      application.Pending_Litigations_File_Id__c = this.pendingLitigationsFileUploadedId;
      application.Delinquent_Debt_File_Id__c = this.delinquentOrDefaultOnAnyDebtFileUploadedId;

      application.Outstanding_Judgement_File_Id__c = this.outstandingJudgementsFileUploadedId;
      application.Property_Violations_File_Id__c = this.propertyViolationsInvestigations5yrFileUploadedId;
      application.Lawsuit_Defendent_File_Id__c = this.isLawsuitDefendantFileUploadedId;
      application.Portfolio_Properties_File_Id__c = this.portfolioProperiesLitigationsFileUploadedId;
      application.Permanent_Resident_File_Id__c = this.isPermanentResidentAlienFileUploadedId;
      application.Foreign_National_File_Id__c = this.isForeignNationalFileUploadedId;
      application.US_Citizen_File_Id__c = this.isUsCitizenFileUploadedId;
      application.Property_Strategy__c = this.propertyStrategy;

      if (this.acknowledgementFinalLoanProceeds != null) {
        application.Acknowledgement_of_final_loan_proceeds__c = this.acknowledgementFinalLoanProceeds;
      }

      if (this.representedByAttorney != null) {
        application.Represented_by_an_Attorney__c = this.representedByAttorney;
      }

      if (this.optForCorevestInsuranceAgent != null) {
        application.Opt_For_Corevest_Insurance_Agent__c = this.optForCorevestInsuranceAgent;
      }
      application.Felony_Comments__c = this.felonyComments;
      application.Deliquent_Or_Default_On_Any_Debt_Comment__c = this.delinquentOrDefaultOnAnyDebtComments;
      application.On_Financial_Sanction_List_Comments__c = this.onFinancialSanctionsListComments;
      application.Pending_Litigations_Comments__c = this.pendingLitigationsComments;
      application.Violations_Investigations_Comments__c = this.propertyViolationsInvestigations5yrComments;
      application.Is_Lawsuit_Defendant_Comments__c = this.isLawsuitDefendantComments;
      application.Outstanding_Judgements_Comments__c = this.outstandingJudgementsComments;
      application.Portfolio_Properties_Litigations_Comment__c = this.portfolioProperiesLitigationsComments;
      application.Is_US_Citizen_Comments__c = this.isUsCitizenComments;
      application.Is_Permanent_Resident_Alien_Comments__c = this.isPermanentResidentAlienComments;
      application.Is_Foreign_National_Comments__c = this.isForeignNationalComments;
      application.Business_Contact_Work_Phone__c = this.businessContactWorkPhone;
      application.Status__c = this.status;
      application.Id = this.id;
      application.Deal__c = this.dealId;
      application.Loan_Type__c = this.loanType;
      application.Loan_Id__c = this.loanId;
      application.Alchemy_User_Id__c = this.user_id;
      application.Broker_Alchemy_User_Id__c = this.broker_id;
      application.Form_Completed__c = this.formCompleted;
      application.First_Name__c = this.firstName;
      application.Middle_Name__c = this.middleName;
      application.Marital_Status__c = this.martialStatus;
      application.Last_Name__c = this.lastName;
      application.Home_Address__c = this.homeAddress;
      application.Email__c = this.email;
      application.Mobile_Phone__c = this.mobilePhone;
      application.DOB__c = this.dob;
      application.Marital_Status__c = this.martialStatus;
      application.Business_Contact_Company_Name__c = this.businessContactCompanyName;
      application.Business_Contact_Company_Address__c = this.businessContactCompanyAddress;
      application.Business_Entity_Place_of_Formation__c = this.businessEntityName;
      // application.Business_Entity_Name__c = this.businessEntityName;
      application.Business_Entity_Date_Of_Formation__c = this.businessEntityDateOfFormation;
      application.Business_Entity_Type_Of_Company__c = this.businessEntityTypeOfCompany;
      application.Business_Contact_City__c = this.businessContactCity;
      application.Business_Contact_State__c = this.businessContactState;
      application.Business_Contact_Zip__c = this.businessContactZip;
      application.Business_Contact_Email__c = this.businessContactEmail;

      application.Principal_Info_City__c = this.pinfoCity;
      application.Principal_Info_State__c = this.pinfoState;
      application.Principal_Info_Zip__c = this.pinfoZip;

      if (this.principalInfos != null) {
        application.PrincipalInfos_JSON__c = JSON.serialize(
          this.principalInfos
        );
      }
      application.Attorney_Contact_Name__c = this.attorneyContactName;
      application.Attorney_Contact_Company_Name__c = this.attorneyContactCompanyName;
      application.Attorney_Contact_Address__c = this.attorneyContactAddress;
      application.Attorney_Contact_Email_Address__c = this.attorneyContactEmailAddress;
      application.Attorney_Contact_Work_Phone__c = this.attorneyContactWorkPhone;
      application.Attorney_Contact_Mobile_Phone__c = this.attorneyContactMobilePhone;
      application.Attorney_Contact_City__c = this.attorneyContactCity;
      application.Attorney_Contact_State__c = this.attorneyContactState;
      application.Attorney_Contact_Zip__c = this.attorneyContactZip;

      application.Insurance_Agent_Name__c = this.insuranceAgentName;
      application.Insurance_Agent_Company_Name__c = this.insuranceAgentCompanyName;
      application.Insurance_Agent_Address__c = this.insuranceAgentAddress;
      application.Insurance_Agent_Email_Address__c = this.insuranceAgentEmailAddress;
      application.Insurance_Agent_Work_Phone__c = this.insuranceAgentWorkPhone;
      application.Insurance_Agent_Mobile_Phone__c = this.insuranceAgentMobilePhone;
      application.Insurance_Agent_City__c = this.insuranceAgentCity;
      application.Insurance_Agent_State__c = this.insuranceAgentState;
      application.Insurance_Agent_Zip__c = this.insuranceAgentZip;
      system.debug('--felony--');
      system.debug(felony);

      if (this.felony != null) {
        application.Felony__c = this.felony;
      }
      // application.Felony__c = this.felony;
      if (this.onFinancialSanctionsList != null) {
        application.On_Financial_Sanction_List__c = this.onFinancialSanctionsList;
      }
      if (this.delinquentOrDefaultOnAnyDebt != null) {
        application.Deliquent_Or_Default_On_Any_Debt__c = this.delinquentOrDefaultOnAnyDebt;
      }
      if (this.pendingLitigations != null) {
        application.Pending_Litigations__c = this.pendingLitigations;
      }
      if (this.propertyViolationsInvestigations5yr != null) {
        application.Property_Violations_Investigations_5yr__c = this.propertyViolationsInvestigations5yr;
      }
      if (this.outstandingJudgements != null) {
        application.Outstanding_Judgements__c = this.outstandingJudgements;
      }
      if (this.isLawsuitDefendant != null) {
        application.Is_Lawsuit_Defendant__c = this.isLawsuitDefendant;
      }
      if (this.portfolioProperiesLitigations != null) {
        application.Portfolio_Properties_Litigations__c = this.portfolioProperiesLitigations;
      }

      if (this.isUsCitizen != null) {
        application.Is_US_Citizen__c = this.isUsCitizen;
      }
      if (this.isPermanentResidentAlien != null) {
        application.Is_Permanent_Resident_Alien__c = this.isPermanentResidentAlien;
      }
      if (this.isForeignNational != null) {
        application.Is_Foreign_National__c = this.isForeignNational;
      }

      application.Country__c = this.country;
      application.Summary__c = this.summary;
      application.Estimated_Total_Asset_Value__c = this.estimatedTotalAssetValue;
      application.Estimated_Total_Liability_Value__c = this.estimatedTotalLiabilityValue;
      application.Estimated_Net_Worth_Value__c = this.estimatedNetWorthValue;
      application.Estimated_Total_Liquid_Asset_Value__c = this.estimatedTotalLiquidAssetValue;
      application.Date_of_Estimation__c = this.dateOfEstimation;
      application.Loan_Desired_Amount__c = this.loanDesiredAmount;

      if (this.loanPurpose != null) {
        application.Loan_Purpose__c = String.join(this.loanPurpose, ';');
      }

      application.Lender_Payoff_Property_Number__c = this.lenderPayoffPropertyNumber;
      application.Estimated_Payoff_Amount__c = this.estimatedPayoffAmount;
      application.Payoff_Amount_As_Of__c = this.payoffAmountAsOf;
      application.Estimated_Prepayment_Penalties__c = this.estimatedPrepaymentPenalties;
      if (this.interestRateCheckbox != null) {
        application.Interest_Rate_Checkbox__c = this.interestRateCheckbox;
      }
      application.Occupation_Statement__c = this.occupationStatement;
      application.Signature__c = this.signature;
      application.Title__c = this.title;
      application.Name__c = this.name;
      application.Signature_Date__c = this.signatureDate;
      application.Credit_Pull_Signature__c = this.creditPullSignature;
      application.Credit_Pull_Sign_Name__c = this.creditPullSignName;
      application.Credit_Pull_Sign_Date__c = this.creditPullSignDate;

      if (this.ethnicity != null) {
        application.Ethnicity__c = String.join(this.ethnicity, ';');
      }

      // if (this.sex != null) {
      //   application.Sex__c = String.join(this.sex, ';');
      // }

      application.Sex__c = this.sex;

      if (this.race != null) {
        application.Race__c = String.join(this.race, ';');
      }
      application.Number_of_Rental_Properties_Owned__c = this.numberOfRentalPropertiesOwned;
      application.How_Long_Investing_in_Rental_Properties__c = this.howLongInvestingInRentalProperties;
      application.Estimated_Value_of_Entire_Portfolio__c = this.estimatedValueOfPortfolio;
      application.Average_Rental_Property_Purchase_Price__c = this.propertiesAvgPurchasePrice; //this.//this.averagePurchasePrice;
      application.Average_Hold_Time_of_Rental_Properties__c = this.propertiesAvgHoldTime; //this.averagePropertyHoldTime;
      application.Average_Cost_of_Rental_Property_Reno__c = this.avgRenovateCost;
      if (this.typeOfPropertiesOwned != null) {
        application.Type_of_Rental_Properties_Owned__c = String.join(
          this.typeOfPropertiesOwned,
          ';'
        );
      }
      if (this.sourceOfRentalProperties != null) {
        application.Source_of_the_Rental_Properties__c = String.join(
          this.sourceOfRentalProperties,
          ';'
        );
      }
      // if (this.howLongToHoldPortfolio != null) {
      //   application.How_Long_to_Hold_Portfolio__c = String.join(
      //     this.howLongToHoldPortfolio,
      //     ';'
      //   );
      // }

      application.How_Long_to_Hold_Portfolio__c = this.howLongToHoldPortfolio;
      // if (this.propertyManagement != null) {
      //   application.How_is_Property_Management_Handled__c = String.join(
      //     this.propertyManagement,
      //     ';'
      //   );
      // }
      application.How_is_Property_Management_Handled__c = this.propertyManagement;

      // if (this.propertyManagementCompanies != null) {
      //   application.Property_Management_Companies__c = String.join(
      //     this.propertyManagementCompanies,
      //     ';'
      //   );
      // }

      application.Property_Management_Companies__c = this.propertyManagementCompanies;
      application.Software_Used__c = this.softwareUsed;
      application.Years_Experience__c = this.yearsExperience;
      application.Number_of_Properties_Self_Managed__c = this.numberOfPropertiesSelfManaged;
      if (this.hasLostMoney != null) {
        application.Has_Lost_Money_on_Property__c = this.hasLostMoney;
      }
      application.Reason_for_Lost_Money__c = this.reasonMoneyLost;
      application.Properties_To_Purchase__c = this.propertiesToPurchase;
      application.Acknowledgement_of_final_loan_proceeds__c = acknowledgementFinalLoanProceeds;
      if (this.typeOfProperties != null) {
        application.Type_Of_Properties__c = String.join(
          this.typeOfProperties,
          ';'
        );
      }

      if (this.sourceOfAcquisitions != null) {
        application.Sources_of_Acquisition__c = String.join(
          this.sourceOfAcquisitions,
          ';'
        );
      }

      if (this.costForAcquiredProperties != null) {
        application.Cost_for_Acquired_Properties__c = String.join(
          this.costForAcquiredProperties,
          ';'
        );
      }

      if (this.operationalStates != null) {
        application.States_of_Operation__c = String.join(
          this.operationalStates,
          ';'
        );
      }
      application.Target_Cities__c = this.targetCities;
      if (this.reviewTitle != null) {
        application.Review_Title__c = this.reviewTitle;
      }
      application.Obtain_Title_Insurance__c = this.obtainTitleInsurance;
      application.Title_Company__c = this.titleCompany;
      //application.Range_of_Properties__c = this.rangeOfProperties;
      if (this.priceRangPurProperty != null) {
        application.Range_of_Properties__c = String.join(
          this.priceRangPurProperty,
          ';'
        );
      }
      application.Underwrited_Acquisitions__c = this.underwritedAcquisitions;
      application.Fair_Market_Value__c = this.fairMarketValue;
      application.Estimated_Renovation_Costs__c = this.estimatedRenovationCosts;
      application.Renovation_Work_Performer__c = this.renovationWorkPerformer;
      application.Exit_Strategy__c = this.exitStrategy;
      application.Plan_To_Fix_and_Flip__c = this.planToFixAndFlip;
      application.Financing_For_Each_Project__c = this.financingForEachProject;
      application.Plan_To_Purchase_Refinacing_Properties__c = this.planToPurchaseRefinancingProperties;
      if (this.lostMoneyOrFixAndFlip != null) {
        application.Lost_Money_Or_Fix_and_Flip__c = this.lostMoneyOrFixAndFlip;
      }
      application.Reason_For_Losses__c = this.reasonForLosses;

      application.Transaction_Type__c = this.spbTransactionType;
      application.Purchase_Price__c = this.spbPurchasePrice;
      application.Estimated_Closing_Date__c = this.spbEstimatedClosingDate;
      application.Estimated_As_Is_Value__c = this.spbEstimatedAsIsValue;
      application.Property_Street_Address__c = this.spbStreetAddress;
      application.Property_City__c = this.spbCity;
      application.Property_State__c = this.spbState;
      application.Property_Zip_Code__c = this.spbZipCode;
      application.Property_Type__c = this.spbPropertyType;
      application.Number_of_Units__c = this.spbNoUnits;
      application.Plan_Rehab_on_Property__c = this.spbPlanRehabProperty;
      application.Summary_of_Rehab_Work__c = this.spbSummaryRehabWork;
      application.Perform_Rehab_Work__c = this.spbPerformRehabWork;
      // application.Estimated_Renovation_Costs__c = this.spbEstimatedRehabCost;
      application.Estimated_As_Repaired_Value__c = this.spbEstimatedAsRepairedValue;
      application.Applying_Purpose_Investment_Loan__c = this.spbApplyingPurposeInvestmentLoan;
      // application.Loan_Desired_Amount__c = this.spbTotalLoanAmountRequested;
      application.Long_Loan_Needed__c = this.spbLongLoanNeeded;
      application.Current_Payoff_Amount__c = this.spbCurrentPayoffAmount;
      application.Intend_To_Pay_Loan__c = this.spbIntendToPayLoan;
      application.Investment_Properties_Sold__c = this.spbInvestmentPropertiesSold;
      application.Rental_Properties_Owned__c = this.spbRentalPropertiesOwned;
      application.Properties_Owned_Operated_as_Principal__c = this.propertiesOwnedAndOperatedAsPrincipal;
      application.Properties_Owned_as_Principal__c = this.propertiesOwnedAsPrincipal;
      application.Construction_Projects_Completed__c = this.constructionProjectsCompleted;
      application.Renovation_Principal_Rental__c = this.renovationPrincipalRental;
      application.Renovation_Principal_Sale__c = this.renovationPrincipalSale;
      application.Other_Loan_Purpose__c = this.creOtherLoanPurpose;
      if (this.creLoanType != null) {
        application.CRE_Loan_Type__c = String.join(this.creLoanType, ';');
      }
      application.Other_Loan_Type__c = this.creOtherLoanType;
      application.Project_Type__c = this.projectType;
      application.Other_Project_Type__c = this.otherProjectType;
      // application.Exit_Strategy__c = this.creExitStrategy;
      application.Other_Exit_Strategy__c = this.otherCreExitStrategy;
      if (this.refinanceStrategy != null) {
        application.Refinance_Strategy__c = String.join(
          this.refinanceStrategy,
          ';'
        );
      }
      application.Other_Refinance_Strategy__c = this.otherRefinanceStrategy;
      application.Long_Properties_Hold__c = this.longPropertiesHold;
      // application.How_is_Property_Management_Handled__c = this.handlePropertiesManagement;
      // application.Property_Management_Companies__c = this.thirdPartyPropertiesManagement;
      // application.Years_Experience__c = this.creYearsOfExperience;
      // application.Number_of_Properties_Self_Managed__c = this.creNumberOfPropertiesSelfManaged;
      application.Other_Type_of_Properties__c = this.otherTypeOfProperties;

      if (this.status == null) {
        this.status = 'Pending';
      }

      return application;
    }
  }

  // public class TermApplication extends Application {

  // }

  // public class RentalApplication extends Application {
  //   public Integer numberOfRentalPropertiesOwned; // integer,
  //   public String howLongInvestingInRentalProperties; // string,
  //   public Integer estimatedValueOfPortfolio; // integer,
  //   public Integer propertiesAvgPurchasePrice; // integer,
  //   public String propertiesAvgHoldTime; // string,
  //   public Integer avgRenovateCost; // integer,
  //   public List<String> typeOfPropertiesOwned; // [string],
  //   public List<String> sourceOfRentalProperties; // [string],
  //   public List<String> howLongToHoldPortfolio; // [string],
  //   public List<String> propertyManagement; // [string],
  //   public List<String> propertyManagementCompanies; // [string],
  //   public String softwareUsed; // string(more than 255 characters),
  //   public Integer yearsExperience; // integer,
  //   public Integer numberOfPropertiesSelfManaged; // integer,
  //   public Boolean hasLostMoney; // boolean,
  //   public String reasonMoneyLost; // string(more than 255 characters),

  // }

  // public class BridgeApplication extends Application {

  // }

  class PrincipalInfo {
    String principalInfoName;
    String principalInfoAddress;
    String principalWorkPhone;
    String principalInfoEmail;
    String principalInfoMobile;
    String principalInfoCity;
    String principalInfoState;
    String principalInfoZip;
  }
}