@RestResource(urlMapping='/portal/deal/*')
global with sharing class PortalAPIDeal {
  @HttpGet
  global static void doGet() {
    RestRequest req = RestContext.request;
    RestResponse res = Restcontext.response;

    List<String> params = Restcontext.request.requestURI.split('/');

    if (params[3] == 'userId') {
      String userId = params[4];
      Id contactId = AlchemyAPI.getContactIdByAlchemyId(userId);
      Set<Id> dealIds = AlchemyAPI.getDealIdsContactId(contactId);

      Set<String> fields = util.getAllFieldNamesForObject('Opportunity');

      String queryString = 'SELECT ';
      queryString += String.join(new List<String>(fields), ',');
      queryString += ', Application__r.Term_Sheet_Sent__c ,Contact__r.Name,Account.Name,Contact__r.OwnerId,Contact__r.Owner.Name,Contact__r.Owner.Phone,Contact__r.Owner.Email,Contact__r.Owner.smallPhotoURl, Contact__r.Owner.Portal_Profile_Pic__c, ';
      queryString += ' (SELECT Id,UserId,TeamMemberRole, User.Email, User.smallPhotoURl, User.Name,User.Phone, User.Portal_Profile_Pic__c FROM OpportunityTeamMembers) ';
      queryString += ' FROM Opportunity ';
      queryString += ' WHERE Id IN: dealIds';
      //   system.debug(queryString);

      List<LoanSmall> loans = new List<LoanSmall>();

      for (Opportunity deal : (List<Opportunity>) Database.query(queryString)) {
        loans.add(new LoanSmall(deal));
      }

      // Opportunity deal = (Opportunity) Database.query(queryString);

      // Loan loan = new Loan(deal);

      res.responseBody = Blob.valueOf(JSON.serialize(loans));
      res.addHeader('Content-Type', 'application/json');

      //Contact contact = [SELECT Id, ]

      // Set<Id> termLoans = new Set<Id>();
      // Set<Id> locLoans = new Set<Id>();
      // Set<Id> sabLoans = new Set<Id>();
      // Set<Id> salLoans = new Set<Id>();
      // for (Opportunity opp : [
      //   SELECT Id, Contact__r.Alchemy_Portal_Id__c, RecordType.DeveloperName
      //   FROM Opportunity
      //   WHERE Id IN :dealIds
      // ]) {
      //   String recordTypeName = opp.RecordType.DeveloperName;

      //   switch on recordTypeName {
      //     when 'Term_Loan' {
      //       termLoans.add(opp.Id);
      //     }
      //     when 'LOC_Loan' {
      //       locLoans.add(opp.Id);
      //     }
      //     when 'Single_Asset_Bridge_Loan' {
      //       sabLoans.add(opp.Id);
      //     }
      //     when 'Single_Asset_Loan' {
      //       salLoans.add(opp.Id);
      //     }
      //   }

      //   if (
      //     termLoans.size() > 0 ||
      //     locLoans.size() > 0 ||
      //     sabLoans.size() > 0 ||
      //     salLoans.size() > 0
      //   ) {
      //     List<Opportunity> deals = new List<Opportunity>();

      //     if (termLoans.size() > 0) {
      //       // Set<String> fields = TERM_FIELDS;
      //       Set<String> fields = util.getAllFieldNamesForObject('Opportunity');

      //       String queryString = 'SELECT ';
      //       queryString += String.join(new List<String>(fields), ',');
      //       queryString += ' FROM Opportunity ';
      //       queryString += ' WHERE Id IN : termLoans';
      //       //   system.debug(queryString);

      //       deals.addAll((List<Opportunity>) Database.query(queryString));
      //     }

      //     if (locLoans.size() > 0) {
      //       // Set<String> fields = LOC_FIELDS;
      //       Set<String> fields = util.getAllFieldNamesForObject('Opportunity');

      //       String queryString = 'SELECT ';
      //       queryString += String.join(new List<String>(fields), ',');
      //       queryString += ' FROM Opportunity ';
      //       queryString += ' WHERE Id IN : locLoans';
      //       //   system.debug(queryString);

      //       deals.addAll((List<Opportunity>) Database.query(queryString));
      //     }

      //     if (sabLoans.size() > 0) {
      //       //Set<String> fields = SAB_FIELDS;
      //       Set<String> fields = util.getAllFieldNamesForObject('Opportunity');
      //       String queryString = 'SELECT ';
      //       queryString += String.join(new List<String>(fields), ',');
      //       queryString += ' FROM Opportunity ';
      //       queryString += ' WHERE Id IN : sabLoans';
      //       //   system.debug(queryString);

      //       deals.addAll((List<Opportunity>) Database.query(queryString));
      //     }

      //     if (salLoans.size() > 0) {
      //       // Set<String> fields = SAL_FIELDS;
      //       Set<String> fields = util.getAllFieldNamesForObject('Opportunity');
      //       String queryString = 'SELECT ';
      //       queryString += String.join(new List<String>(fields), ',');
      //       queryString += ' FROM Opportunity ';
      //       queryString += ' WHERE Id IN : salLoans';
      //       //   system.debug(queryString);

      //       deals.addAll((List<Opportunity>) Database.query(queryString));
      //     }

      //     res.responseBody = Blob.valueOf(JSON.serialize(deals, true));
      //     res.addHeader('Content-Type', 'application/json');
      //   } else {
      //     Map<String, String> bodyResp = new Map<String, String>();
      //     bodyResp.put('status', 'error');
      //     bodyResp.put('message', 'Deals not found with User Id ' + userId);
      //     res.responseBody = Blob.valueOf(JSON.serialize(bodyResp));
      //     res.addHeader('Content-Type', 'application/json');
      //   }
      // }
    } else {
      Id dealId = params[3];
      system.debug(dealId);
      List<Opportunity> opp = [
        SELECT
          Id,
          RecordType.DeveloperName,
          Contact__r.OwnerId,
          Contact__r.Owner.Name,
          Contact__r.Owner.Phone,
          Contact__r.Owner.Email,
          Contact__r.Owner.smallPhotoURl,
          Contact__r.Owner.Portal_Profile_Pic__c
        FROM Opportunity
        WHERE Id = :dealId
      ];

      if (opp.size() > 0) {
        String recordTypeName = opp[0].RecordType.DeveloperName;
        // Set<String> fields = new Set<String>();

        // switch on recordTypeName {
        //   when 'Term_Loan' {
        //     fields = TERM_FIELDS;
        //   }
        //   when 'LOC_Loan' {
        //     fields = LOC_FIELDS;
        //   }
        //   when 'Single_Asset_Bridge_Loan' {
        //     fields = SAB_FIELDS;
        //   }
        //   when 'Single_Asset_Loan' {
        //     fields = SAL_FIELDS;
        //   }
        // }

        // Set<String> fields = new Set<String>{
        //   'Name',
        //   'Deal_Loan_Number__c',
        //   'Account.Name',
        //   'LOC_Term__c',
        //   'Loan_Size__c',
        //   'Over_LOC_Commitment__c',
        //   'Expired__c',
        //   'Advance_Period_Days_In_Months__c',
        //   'Asset_Maturity__c',
        //   'Days_Remaining__c',
        //   'StageName',
        //   'CloseDate',
        //   'LOC_Loan_Type__c',
        //   'Product_Sub_Type__c',
        //   'Interest_Rate_Type__c',
        //   'LTC__c',
        //   'LTV__c',
        //   'Origination_Fee__c',
        //   'Fee__c',
        //   'Rate__c',
        //   'Project_Strategy__c',
        //   'Type',
        //   'Final_Loan_Amount__c',
        //   'Current_Loan_Amount__c',
        //   'LOC_Commitment__c'
        //   // (SELECT Id,UserId,TeamMemberRole, User.Email, User.smallPhotoURl, User.Name,User.Phone FROM OpportunityTeamMembers)
        // };
        Set<String> fields = util.getAllFieldNamesForObject('Opportunity');

        String queryString = 'SELECT ';
        queryString += String.join(new List<String>(fields), ',');
        queryString += ' ,Contact__r.Name, Application__r.Term_Sheet_Sent__c ';
        queryString += ' ,Account.Name,Contact__r.OwnerId,Contact__r.Owner.Name,Contact__r.Owner.Phone,Contact__r.Owner.Email,Contact__r.Owner.smallPhotoURl, Contact__r.Owner.Portal_Profile_Pic__c, ';
        queryString += ' (SELECT Id,UserId,TeamMemberRole, User.Email, User.smallPhotoURl, User.Name,User.Phone, User.Portal_Profile_Pic__c FROM OpportunityTeamMembers) ';

        Set<String> applicationFieldNames = util.getAllFieldNamesForObject(
          'Application__c'
        );

        String applicationQueryString = 'SELECT ';
        applicationQueryString += String.join(
          new List<String>(applicationFieldNames),
          ','
        );
        applicationQueryString += ' FROM Applications__r';

        queryString += ', (' + applicationQueryString + ')';

        // queryString += ', (SELECT Id FROM Application__r)';
        queryString += ' FROM Opportunity ';
        queryString += ' WHERE Id =\'' + dealId + '\'';
        queryString += ' LIMIT 1';
        //   system.debug(queryString);

        Opportunity deal = (Opportunity) Database.query(queryString);

        // deal.OpportunityTeamMembers.add(
        //   new OpportunityTeamMember(
        //     TeamMemberRole = 'Relationship Manager',
        //     User = opp[0].Contact__r.Owner,
        //     UserId = opp[0].Contact__r.Id
        //   )
        // );

        Loan loan = new Loan(deal);

        res.responseBody = Blob.valueOf(JSON.serialize(loan));
        res.addHeader('Content-Type', 'application/json');
      } else {
        Map<String, String> bodyResp = new Map<String, String>();
        bodyResp.put('status', 'error');
        bodyResp.put('message', 'Deal not found with Id ' + dealId);
        res.responseBody = Blob.valueOf(JSON.serialize(bodyResp));
        res.addHeader('Content-Type', 'application/json');
      }
    }
  }

  public class LoanSmall {
    Id id;
    String loanType;
    DateTime createdDate;
    String loanName;
    String primaryContact;

    LoanSmall(Opportunity deal) {
      Loan loan = new Loan(deal);

      this.id = deal.id;
      this.loanType = loan.loanType;
      this.createdDate = deal.CreatedDate;
      this.loanName = loan.loanName;
      this.primaryContact = deal.Contact__r.Name;
    }
  }

  public class Loan {
    String loanName;
    String loanNumber;
    String accountName;
    String term;
    Decimal loanSize;
    String overLocCommitment;
    String expired;
    String advancePeriodInMonths;
    String assetMaturityDays;
    Decimal daysRemaining;
    String stage;
    Date closeDate;
    String productType;
    String productSubType;
    String interestRateType;
    Decimal interestRate;
    Decimal maxLTC;
    Decimal maxLTV;
    Decimal originationFee;
    Decimal advanceFee;
    String loanType;

    Decimal originalLoanBalance;
    Decimal outstandingLoanBalance;
    Decimal remainingCommitmentAmount;
    // String interestRateType
    String index;
    Decimal indexMargin;
    String indexFloor;
    String primaryContact;

    Id id;
    List<DealTeamMember> teamMembers;

    List<PortalAPIApplication.ApplicationSmall> applications;
    Id termsheetApplicationId;

    Loan(Opportunity o) {
      teamMembers = new List<DealTeamMember>();
      loanName = o.Name;
      loanNumber = o.Deal_Loan_Number__c;
      accountName = o.Account.Name;
      term = o.LOC_Term__c;
      loanSize = o.Loan_Size__c;
      overLocCommitment = o.Over_LOC_Commitment__c;
      expired = o.Expired__c;
      advancePeriodInMonths = o.Advance_Period_Days_In_Months__c;
      assetMaturityDays = o.Asset_Maturity__c;
      daysRemaining = o.Days_Remaining__c;
      primaryContact = o.Contact__r.Name;
      //stage = o.StageName;

      List<PortalAPIApplication.ApplicationSmall> applications = new List<PortalAPIApplication.ApplicationSmall>();

      if (o.Application__r != null) {
        for (Application__c application : o.Applications__r) {
          applications.add(
            new PortalAPIApplication.ApplicationSmall(application)
          );
        }
      }

      if (o.Application__r.Term_Sheet_Sent__c) {
        this.termsheetApplicationId = o.Application__c;
      }

      this.applications = applications;

      if (o.LOC_Loan_Type__c == 'Term Loan') {
        this.loanType = 'Rental Portfolio';
      }
      if (
        o.LOC_Loan_Type__c == 'Credit Line' &&
        o.Project_Strategy__c != 'Fix and Flip'
      ) {
        this.loanType = 'Credit Line';
      }
      if (
        o.LOC_Loan_Type__c == 'Credit Line' &&
        o.Project_Strategy__c == 'Fix and Flip'
      ) {
        this.loanType = 'Credit Line';
      }

      if (
        o.LOC_Loan_Type__c == 'Credit Line' &&
        o.Product_Sub_Type__c == 'Build to Rent'
      ) {
        this.loanType = 'Build For Rent';
      }

      if (o.LOC_Loan_Type__c == 'Build to Rent') {
        this.loanType = 'Build For Rent';
      }

      if (
        o.LOC_Loan_Type__c == 'Single Asset (1-4 Unit)' ||
        o.LOC_Loan_Type__c == 'Single Asset (5-10 Unit)'
      ) {
        this.loanType = 'Bridge Loan';
      }
      if (o.Loc_Loan_Type__c == 'Multifamily/CRE') {
        this.loanType = 'Multifamily';
      }

      if (o.LOC_Loan_Type__c == 'Model Home Release') {
        this.loanType = 'Model Home Release';
      }

      if (o.LOC_Loan_Type__c == 'Single Asset Rental') {
        this.loanType = 'Single Rental';
      }

      if (o.LOC_Loan_Type__c == 'Single Rental Loan') {
        this.loanType = 'Single Rental';
      }

      if (o.Type == 'Term Loan' || o.Type == 'Single Rental Loan') {
        if (
          o.Final_Loan_Amount__c == null &&
          o.Current_Loan_Amount__c == null
        ) {
          loanSize = o.Loan_Size__c;
        } else if (
          o.Final_Loan_Amount__c == null &&
          o.Current_Loan_Amount__c != null
        ) {
          loanSize = o.Current_Loan_Amount__c;
        } else if (o.Final_Loan_Amount__c != null) {
          loanSize = o.Final_Loan_Amount__c;
        }
      } else if (o.Type == 'Bridge Loan' || o.Type == 'SAB Loan') {
        if (o.LOC_Commitment__c == null) {
          loanSize = o.Loan_Size__c;
        } else {
          loanSize = o.LOC_Commitment__c;
        }
      }
      stage = PortalAPIDashboard.dealStageMap.get(o.StageName);

      // stage = 'New';
      // if (o.StageName == 'Rejected' || o.StageName == 'Withdrawn') {
      //   stage = 'Inactive';
      // }

      // if (
      //   o.StageName == 'Expired' ||
      //   o.StageName == 'Matured' ||
      //   o.StageName == 'Paid Off'
      // ) {
      //   stage = 'Past';
      // }

      // if (
      //   o.StageName == 'Closed Won' &&
      //   system.today().addDays(7) > o.CloseDate
      // ) {
      //   stage = 'Active';
      // }

      closeDate = o.CloseDate;
      //productType = o.LOC_Loan_Type__c;

      if (o.LOC_Loan_Type__c == 'Term Loan') {
        this.productType = 'Rental Portfolio';
      }
      if (
        o.LOC_Loan_Type__c == 'Credit Line' &&
        o.Project_Strategy__c != 'Fix and Flip'
      ) {
        this.productType = 'Credit Line';
      }
      if (
        o.LOC_Loan_Type__c == 'Credit Line' &&
        o.Project_Strategy__c == 'Fix and Flip'
      ) {
        this.productType = 'Fix and Flip';
      }

      if (
        o.LOC_Loan_Type__c == 'Credit Line' &&
        o.Product_Sub_Type__c == 'Build to Rent'
      ) {
        this.productType = 'Build For Rent';
      }

      if (o.LOC_Loan_Type__c == 'Build to Rent') {
        this.productType = 'Build For Rent';
      }

      if (
        o.LOC_Loan_Type__c == 'Single Asset (1-4 Unit)' ||
        o.LOC_Loan_Type__c == 'Single Asset (5-10 Unit)'
      ) {
        this.productType = 'Bridge Loan';
      }
      if (o.Loc_Loan_Type__c == 'Multifamily/CRE') {
        this.productType = 'Multifamily';
      }

      if (o.LOC_Loan_Type__c == 'Model Home Release') {
        this.productType = 'Model Home Release';
      }

      if (o.LOC_Loan_Type__c == 'Single Rental Loan') {
        this.productType = 'Single Rental';
      }

      if (o.LOC_Loan_Type__c == 'Single Asset Rental') {
        this.productType = 'Single Rental';
      }

      originalLoanBalance = o.Original_UPB_Svc__c;
      outstandingLoanBalance = o.Current_UPB__c;
      remainingCommitmentAmount = o.Outstanding_Facility_Amount__c;

      productSubType = o.Product_Sub_Type__c;
      interestRateType = o.Interest_Rate_Type__c;
      if (interestRateType == null) {
        interestRateType = o.Requested_Interest_Type__c;
      }

      if (String.isBlank(o.Interest_Rate_Type__c)) {
        interestRateType = o.Requested_Interest_Type__c;
      }

      interestRate = o.Final_Interest_Rate_Calc__c;

      if (interestRate == null || interestRate == 0) {
        interestRate = o.Rate__c;
      }

      index = o.Index__c;

      if (String.isBlank(index)) {
        index = o.Requested_Index__c;
      }

      indexMargin = o.Index_Margin__c;
      if (indexMargin == null) {
        indexMargin = o.Requested_Index_Margin__c;
      }

      indexFloor = o.Index_Floor__c;
      if (String.isBlank(indexFloor)) {
        indexFloor = o.Requested_Index_Floor__c;
      }

      //interestRate = o.Rate__c;
      maxLTC = o.LTC__c;
      maxLTV = o.LTV__c;
      originationFee = o.Origination_Fee__c;
      advanceFee = o.Fee__c;
      id = o.Id;

      teamMembers.add(new DealTeamMember(o.Contact__r));
      for (OpportunityTeamMember member : o.OpportunityTeamMembers) {
        teamMembers.add(new DealTeamMember(member));
      }
    }
  }

  class DealTeamMember {
    String name;
    String role;
    String phoneNumber;
    String email;
    String photoUrl;

    DealTeamMember(OpportunityTeamMember teamMember) {
      this.name = teamMember.User.Name;
      this.role = teamMember.TeamMemberRole;
      this.phoneNumber = teamMember.User.Phone;
      this.email = teamMember.User.email;

      if (String.isBlank(teamMember.User.Portal_Profile_Pic__c)) {
        this.photoURL = 'https://cvest--alchemy.my.salesforce.com/file-asset-public/default?oid=00DZ0000009T6aH';
      } else {
        this.photoURL = teamMember.User.Portal_Profile_Pic__c;
      }

      //this.photoURL = teamMember.User.smallPhotoURl;
    }

    DealTeamMember(Contact c) {
      this.name = c.Owner.Name;
      this.role = 'Relationship Manager';
      this.phoneNumber = c.Owner.Phone;
      this.email = c.Owner.Email;
      this.photoURL = c.Owner.smallPhotoURl;

      if (String.isBlank(c.Owner.Portal_Profile_Pic__c)) {
        this.photoURL = 'https://cvest--alchemy.my.salesforce.com/file-asset-public/default?oid=00DZ0000009T6aH';
      } else {
        this.photoURL = c.Owner.Portal_Profile_Pic__c;
      }
    }
  }

  public static Set<String> TERM_FIELDS = new Set<String>{
    'RecordType.DeveloperName',
    'Contact__r.Alchemy_Portal_Id__c',
    'AccountId',
    'Application__c',
    'Amortization_Term__c',
    'Annual_HOA__c',
    'Anticipated_Closing_Date__c',
    'Borrower_Entity__c',
    'Bridge_Borrower__c',
    'Broker_Fees__c',
    'YSP_perc__c',
    'CloseDate',
    'Cash_Management__c',
    'Country__c',
    'Current_Loan_Amount__c',
    'Current_UPB__c',
    'Deal_Loan_Number__c',
    'Name',
    'Deposit_Amount__c',
    'Deposit_Collected__c',
    'Deposit_Fed_Reference__c',
    'Final_Interest_Rate_Calc__c',
    'Final_Loan_Amount__c',
    'Final_Swap__c',
    'Final_Spread__c',
    'Floor__c',
    'Foreign_National__c',
    'Hold_Reason__c',
    'Indicative_Rate_Calc__c',
    'IO_Term__c',
    'Last_Payment_Date__c',
    'LTC__c',
    'LTV__c',
    'Next_Payment_Date__c',
    'CAF_Upfront_Fee__c',
    'Property_Management__c',
    'Rate_Locked__c',
    'Recourse__c',
    'Spread_BPS__c',
    'StageName',
    'State_Percentages__c',
    'Stated_Maturity_Date__c',
    'Swap_Rate__c',
    'Term_Loan_Type__c',
    'Total_Properties__c',
    'Total_Units__c',
    'Type',
    'Updated_Loan_Maturity_Date__c',
    'UW_LTC__c',
    'UW_LTV__c',
    'YM_Prepayment_Penalty__c',
    'YM_Prepayment_Penalty_Description__c',
    'Id',
    'Original_UPB__c'
  };

  public static Set<String> LOC_FIELDS = new Set<String>{
    'RecordType.DeveloperName',
    'Contact__r.Alchemy_Portal_Id__c',
    'AccountId',
    'Active_States__c',
    'Application__c',
    'Fee__c',
    'Advance_Period__c',
    'Asset_Maturity__c',
    'Borrower_Entity__c',
    'Broker_Fees__c',
    'CloseDate',
    'Country__c',
    'Current_UPB__c',
    'Deal_Loan_Number__c',
    'Name',
    'Deposit_Amount__c',
    'Deposit_Collected__c',
    'Deposit_Fed_Reference__c',
    'Exit_Fee__c',
    'Extension_Fee__c',
    'Hold_Reason__c',
    'Index__c',
    'Index_Floor__c',
    'Index_Margin__c',
    'Rate__c',
    'Last_Payment_Date__c',
    'Loan_Effective_Date__c',
    'LOC_Commitment__c',
    'Margin__c',
    'LTC__c',
    'LTV__c',
    'Next_Payment_Date__c',
    'CAF_Upfront_Fee__c',
    'LOC_Loan_Type__c',
    'Product_Sub_Type__c',
    'Project_Strategy__c',
    'Recourse__c',
    'Renovation_Limit__c',
    'Revolving1__c',
    'StageName',
    'State_Percentages__c',
    'Stated_Maturity_Date__c',
    'LOC_Term__c',
    'Total_Properties__c',
    'Type',
    'Updated_Loan_Maturity_Date__c',
    'Utilization__c',
    'Id'
  };

  public static Set<String> SAB_FIELDS = new Set<String>{
    'AccountId',
    'Fee__c',
    'Application__c',
    'Advance_Period__c',
    'Asset_Maturity__c',
    'Borrower_Entity__c',
    'Broker_Fees__c',
    'CloseDate',
    'Country__c',
    'Current_UPB__c',
    'Deal_Loan_Number__c',
    'Name',
    'Deposit_Amount__c',
    'Deposit_Collected__c',
    'Deposit_Fed_Reference__c',
    'Exit_Fee__c',
    'Extension_Fee__c',
    'Hold_Reason__c',
    'Index__c',
    'Index_Floor__c',
    'Index_Margin__c',
    'Rate__c',
    'Last_Payment_Date__c',
    'Loan_Effective_Date__c',
    'LOC_Commitment__c',
    'Margin__c',
    'LTC__c',
    'LTV__c',
    'Next_Payment_Date__c',
    'CAF_Upfront_Fee__c',
    'LOC_Loan_Type__c',
    'Product_Sub_Type__c',
    'Project_Strategy__c',
    'Recourse__c',
    'Renovation_Limit__c',
    'Revolving1__c',
    'StageName',
    'State_Percentages__c',
    'Stated_Maturity_Date__c',
    'LOC_Term__c',
    'Total_Properties__c',
    'Type',
    'Updated_Loan_Maturity_Date__c',
    'Id'
  };

  public static Set<String> SAL_FIELDS = new Set<String>{
    'AccountId',
    'Borrower_Entity__c',
    'Application__c',
    'Broker_Fees__c',
    'CloseDate',
    'Country__c',
    'Deal_Loan_Number__c',
    'Name',
    'Hold_Reason__c',
    'Indicative_Rate_Calc__c',
    'Last_Payment_Date__c',
    'LTC__c',
    'LTV__c',
    'Next_Payment_Date__c',
    'CAF_Upfront_Fee__c',
    'Recourse__c',
    'Spread_BPS__c',
    'StageName',
    'State_Percentages__c',
    'Stated_Maturity_Date__c',
    'Swap_Rate__c',
    'Term_Loan_Type__c',
    'Total_Properties__c',
    'Type',
    'Updated_Loan_Maturity_Date__c',
    'Id'
  };
}