@RestResource(urlMapping='/portal/application/*')
global without sharing class PortalAPIApplication {
  public static String portalId;
  public static Id applicationId;
  public static Id contactId;
  public static Id leadId;

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

    // portalId = (String) applicationBody.get('user_id');
    contactId = AlchemyAPI.getContactIdByAlchemyId(portalId);
    leadId = AlchemyAPI.getLeadIdByAlchemyId(portalId);

    if (leadId != null || contactId != null) {
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
        system.debug(fieldName);
        system.debug(fieldsTOValue.get(fieldName));
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

      system.debug(application);

      application.Lead__c = leadId;
      application.Contact__c = contactId;

      insert application;

      //Application appToSend = new Application(application);

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

      //Applications__c apps = new List<Application__c>();

      List<Application> applications = new List<Application>();
      for (Application__c application : queryApplications(portalId)) {
        applications.add(new Application(application));
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
    queryString += ' FROM Application__c';
    queryString += ' WHERE Alchemy_User_Id__c =: portalId ';
    queryString += ' ORDER BY CreatedDate desc';
    List<Application__c> applications = (List<Application__c>) database.query(
      queryString
    );

    return applications;
  }

  public virtual class Application {
    public Id id; //id
    public String status;
    public String loanType; // Loan_Type__cloanType
    public Decimal loanId; //Loan_Id__c
    public String user_id; //Alchemy_User_Id__c

    public Boolean formCompleted;
    public String firstName; //First_Name__c
    public String lastName; //Last_Name__c
    public String homeAddress; //Home_Address__c
    public String email;
    public String mobilePhone; //Mobile_Phone__c
    public Date dob; //DOB
    public String maritalStatus; //Marital_Status__c

    public String businessContactCompanyName; //Business_Contact_Company_Name__c;
    public String businessContactCompanyAddress; //Business_Contact_Company_Address__c;
    public String businessContactEmail; //Business_Contact_Email__c;

    public String businessEntityName; //Business_Entity_Name__c;
    public Date businessEntityDateOfFormation; //Business_Entity_Date_Of_Formation__c
    public String businessEntityTypeOfCompany; //Business_Entity_Type_Of_Company__c

    public List<PrincipalInfo> principalInfos; //PrincipalInfos_JSON__c

    public String attorneyContactName; //Attorney_Contact_Name__c
    public String attorneyContactCompanyName; //Attorney_Contact_Company_Name__c
    public String attorneyContactAddress; //Attorney_Contact_Address__c
    public String attorneyContactEmailAddress; //Attorney_Contact_Mobile_Phone__c
    public String attorneyContactWorkPhone; //Attorney_Contact_Work_Phone__c
    public String attorneyContactMobilePhone; //Attorney_Contact_Mobile_Phone__c

    public String insuranceAgentName; //Insurance_Agent_Name__c
    public String insuranceAgentCompanyName; //Insurance_Agent_Company_Name__c
    public String insuranceAgentAddress; //Insurance_Agent_Address__c
    public String insuranceAgentEmailAddress; //Insurance_Agent_Email_Address__c
    public String insuranceAgentWorkPhone; //Insurance_Agent_Work_Phone__c
    public String insuranceAgentMobilePhone; //Insurance_Agent_Mobile_Phone__c

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
    public Decimal averagePurchasePrice; //Average_Rental_Property_Purchase_Price__c integer,
    public String averagePropertyHoldTime; //Average_Hold_Time_of_Rental_Properties__c string,
    public Decimal averageRenovateCost; // Average_Cost_of_Rental_Property_Reno__cinteger,
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
    public String statesOfOperations; //States_of_Operation__c // string(more than 255 characters),
    public String targetCities; //Target_Cities__c string(more than 255 characters),
    public List<String> sourceOfAcquisitions; //Sources_of_Acquisition__c [string],
    public Boolean reviewTitle; //Review_Title__c// boolean,
    public Boolean obtainTitleInsurance; //Obtain_Title_Insurance__c boolean,
    public String titleCompany; // Title_Company__cstring,
    public String rangeOfProperties; //Range_of_Properties__c string,
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

    Application(Application__c application) {
      this.status = application.Status__c;
      this.id = application.Id;
      this.loanType = application.Loan_Type__c;
      this.loanId = application.Loan_Id__c;
      this.user_id = application.Alchemy_User_Id__c;
      this.formCompleted = application.Form_Completed__c;
      this.firstName = application.First_Name__c;
      this.lastName = application.Last_Name__c;
      this.homeAddress = application.Home_Address__c;
      this.email = application.Email__c;
      this.mobilePhone = application.Mobile_Phone__c;
      this.dob = application.DOB__c;
      this.maritalStatus = application.Marital_Status__c;
      this.businessContactCompanyName = application.Business_Contact_Company_Name__c;
      this.businessContactCompanyAddress = application.Business_Contact_Company_Address__c;
      this.businessEntityName = application.Business_Entity_Name__c;
      this.businessEntityDateOfFormation = application.Business_Entity_Date_Of_Formation__c;
      this.businessEntityTypeOfCompany = application.Business_Entity_Type_Of_Company__c;
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
      this.insuranceAgentName = application.Insurance_Agent_Name__c;
      this.insuranceAgentCompanyName = application.Insurance_Agent_Company_Name__c;
      this.insuranceAgentAddress = application.Insurance_Agent_Address__c;
      this.insuranceAgentEmailAddress = application.Insurance_Agent_Email_Address__c;
      this.insuranceAgentWorkPhone = application.Insurance_Agent_Work_Phone__c;
      this.insuranceAgentMobilePhone = application.Insurance_Agent_Mobile_Phone__c;
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
      this.averagePurchasePrice = application.Average_Rental_Property_Purchase_Price__c;
      this.averagePropertyHoldTime = application.Average_Hold_Time_of_Rental_Properties__c;
      this.averageRenovateCost = application.Average_Cost_of_Rental_Property_Reno__c;

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

      this.statesOfOperations = application.States_of_Operation__c;
      this.targetCities = application.Target_Cities__c;

      if (String.isNotBlank(application.Sources_of_Acquisition__c)) {
        this.sourceOfAcquisitions = application.Sources_of_Acquisition__c.split(
          ';'
        );
      }

      this.reviewTitle = application.Review_Title__c;
      this.obtainTitleInsurance = application.Obtain_Title_Insurance__c;
      this.titleCompany = application.Title_Company__c;
      this.rangeOfProperties = application.Range_of_Properties__c;
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
    }

    public Application__c getRecord() {
      this.formCompleted = this.formCompleted != null
        ? this.formCompleted
        : false;
      this.felony = this.formCompleted != null ? this.formCompleted : false;
      this.onFinancialSanctionsList = this.formCompleted != null
        ? this.formCompleted
        : false;
      this.delinquentOrDefaultOnAnyDebt = this.formCompleted != null
        ? this.formCompleted
        : false;
      this.pendingLitigations = this.formCompleted != null
        ? this.formCompleted
        : false;
      this.propertyViolationsInvestigations5yr = this.formCompleted != null
        ? this.formCompleted
        : false;
      this.outstandingJudgements = this.formCompleted != null
        ? this.formCompleted
        : false;
      this.isLawsuitDefendant = this.formCompleted != null
        ? this.formCompleted
        : false;
      this.portfolioProperiesLitigations = this.formCompleted != null
        ? this.formCompleted
        : false;
      this.isUsCitizen = this.formCompleted != null
        ? this.formCompleted
        : false;
      this.isPermanentResidentAlien = this.formCompleted != null
        ? this.formCompleted
        : false;
      this.isForeignNational = this.formCompleted != null
        ? this.formCompleted
        : false;
      this.interestRateCheckbox = this.formCompleted != null
        ? this.formCompleted
        : false;
      this.hasLostMoney = this.formCompleted != null
        ? this.formCompleted
        : false;
      this.reviewTitle = this.formCompleted != null
        ? this.formCompleted
        : false;
      this.lostMoneyOrFixAndFlip = this.formCompleted != null
        ? this.formCompleted
        : false;

      Application__c application = new Application__c();
      application.Status__c = this.status;
      application.Id = this.id;
      application.Loan_Type__c = this.loanType;
      application.Loan_Id__c = this.loanId;
      application.Alchemy_User_Id__c = this.user_id;
      application.Form_Completed__c = this.formCompleted;
      application.First_Name__c = this.firstName;
      application.Last_Name__c = this.lastName;
      application.Home_Address__c = this.homeAddress;
      application.Email__c = this.email;
      application.Mobile_Phone__c = this.mobilePhone;
      application.DOB__c = this.dob;
      application.Marital_Status__c = this.maritalStatus;
      application.Business_Contact_Company_Name__c = this.businessContactCompanyName;
      application.Business_Contact_Company_Address__c = this.businessContactCompanyAddress;
      application.Business_Entity_Name__c = this.businessEntityName;
      application.Business_Entity_Date_Of_Formation__c = this.businessEntityDateOfFormation;
      application.Business_Entity_Type_Of_Company__c = this.businessEntityTypeOfCompany;
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
      application.Insurance_Agent_Name__c = this.insuranceAgentName;
      application.Insurance_Agent_Company_Name__c = this.insuranceAgentCompanyName;
      application.Insurance_Agent_Address__c = this.insuranceAgentAddress;
      application.Insurance_Agent_Email_Address__c = this.insuranceAgentEmailAddress;
      application.Insurance_Agent_Work_Phone__c = this.insuranceAgentWorkPhone;
      application.Insurance_Agent_Mobile_Phone__c = this.insuranceAgentMobilePhone;
      application.Felony__c = this.felony;
      application.On_Financial_Sanction_List__c = this.onFinancialSanctionsList;
      application.Deliquent_Or_Default_On_Any_Debt__c = this.delinquentOrDefaultOnAnyDebt;
      application.Pending_Litigations__c = this.pendingLitigations;
      application.Property_Violations_Investigations_5yr__c = this.propertyViolationsInvestigations5yr;
      application.Outstanding_Judgements__c = this.outstandingJudgements;
      application.Is_Lawsuit_Defendant__c = this.isLawsuitDefendant;
      application.Portfolio_Properties_Litigations__c = this.portfolioProperiesLitigations;
      application.Is_US_Citizen__c = this.isUsCitizen;
      application.Is_Permanent_Resident_Alien__c = this.isPermanentResidentAlien;
      application.Is_Foreign_National__c = this.isForeignNational;
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
      application.Interest_Rate_Checkbox__c = this.interestRateCheckbox;
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
      application.Average_Rental_Property_Purchase_Price__c = this.averagePurchasePrice;
      application.Average_Hold_Time_of_Rental_Properties__c = this.averagePropertyHoldTime;

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
      application.Has_Lost_Money_on_Property__c = this.hasLostMoney;
      application.Reason_for_Lost_Money__c = this.reasonMoneyLost;
      application.Properties_To_Purchase__c = this.propertiesToPurchase;

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

      application.States_of_Operation__c = this.statesOfOperations;
      application.Target_Cities__c = this.targetCities;
      application.Review_Title__c = this.reviewTitle;
      application.Obtain_Title_Insurance__c = this.obtainTitleInsurance;
      application.Title_Company__c = this.titleCompany;
      application.Range_of_Properties__c = this.rangeOfProperties;
      application.Underwrited_Acquisitions__c = this.underwritedAcquisitions;
      application.Fair_Market_Value__c = this.fairMarketValue;
      application.Estimated_Renovation_Costs__c = this.estimatedRenovationCosts;
      application.Renovation_Work_Performer__c = this.renovationWorkPerformer;
      application.Exit_Strategy__c = this.exitStrategy;
      application.Plan_To_Fix_and_Flip__c = this.planToFixAndFlip;
      application.Financing_For_Each_Project__c = this.financingForEachProject;
      application.Plan_To_Purchase_Refinacing_Properties__c = this.planToPurchaseRefinancingProperties;
      application.Lost_Money_Or_Fix_and_Flip__c = this.lostMoneyOrFixAndFlip;
      application.Reason_For_Losses__c = this.reasonForLosses;

      return application;
    }
  }

  // public class TermApplication extends Application {

  // }

  // public class RentalApplication extends Application {
  //   public Integer numberOfRentalPropertiesOwned; // integer,
  //   public String howLongInvestingInRentalProperties; // string,
  //   public Integer estimatedValueOfPortfolio; // integer,
  //   public Integer averagePurchasePrice; // integer,
  //   public String averagePropertyHoldTime; // string,
  //   public Integer averageRenovateCost; // integer,
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
  }
}