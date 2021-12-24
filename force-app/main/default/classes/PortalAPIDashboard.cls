@RestResource(urlMapping='/portal/dashboard/*')
global without sharing class PortalAPIDashboard {
  //   public static Integer pageSize;
  //   public static Integer page;
  public static String portalUserId;
  public static Id contactid;

  public static Set<Id> dealIds;

  public static Integer paginationStart;
  public static Integer paginationEnd;
  public static Boolean usePagination;

  @HttpGet
  global static void doGet() {
    RestRequest req = RestContext.request;
    RestResponse res = Restcontext.response;

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
      //   paginationStart = pageSize * (page - 1) - 1; // 2
      //   paginationEnd = page * pageSize - 1; // 2
      paginationStart = (page - 1) * pageSize; //2 4
      paginationEnd = page * pageSize; //35
      usePagination = true;
    }

    List<String> params = Restcontext.request.requestURI.split('/');
    if (params[3] == 'loans') {
      portalUserId = params[4];
      contactId = AlchemyAPI.getContactIdByAlchemyId(portalUserId);
      dealIds = AlchemyAPI.getDealIdsContactId(contactId);

      if (String.isNotBlank(contactId)) {
        Contact contact = [
          SELECT Id, Alchemy_Portal_Id__c
          FROM Contact
          WHERE Id = :contactId
          LIMIT 1
        ];

        if (params.size() > 5) {
          String status = params[5];

          List<Deal> loans = getDealList(status);
          res.addHeader('Content-Type', 'application/json');
          res.responseBody = Blob.valueOf(JSON.serialize(loans));
        } else {
          Map<String, Object> loans = createMyDealsDashboard(contact);

          res.addHeader('Content-Type', 'application/json');
          res.responseBody = Blob.valueOf(JSON.serialize(loans));
        }

        //List<Deal> loans = createMyDealsDashboard(contact);
      } else {
        Map<String, String> respBody = new Map<String, String>();
        res.addHeader('Content-Type', 'application/json');
        respBody.put('status', 'error');
        respBody.put('message', 'User Id Not Found');
        res.responseBody = Blob.valueOf(JSON.serialize(respBody, true));
      }
    } else if (params[3] == 'properties') {
      portalUserId = params[4];
      contactId = AlchemyAPI.getContactIdByAlchemyId(portalUserId);
      dealIds = AlchemyAPI.getDealIdsContactId(contactId);

      if (String.isNotBlank(contactId)) {
        Contact contact = [
          SELECT Id, Alchemy_Portal_Id__c
          FROM Contact
          WHERE Id = :contactId
          LIMIT 1
        ];

        if (params.size() > 5) {
          String status = params[5];
          List<Property> properties = getPropertyList(status);

          res.addHeader('Content-Type', 'application/json');
          res.responseBody = Blob.valueOf(JSON.serialize(properties));
        } else {
          PropertyDashboard dashboard = createPropertyDashboard(contact);

          res.addHeader('Content-Type', 'application/json');
          res.responseBody = Blob.valueOf(JSON.serialize(dashboard));
        }
      } else {
        Map<String, String> respBody = new Map<String, String>();
        res.addHeader('Content-Type', 'application/json');
        respBody.put('status', 'error');
        respBody.put('message', 'User Id Not Found');
        res.responseBody = Blob.valueOf(JSON.serialize(respBody, true));
      }
    } else {
      portalUserId = params[3];
      contactId = AlchemyAPI.getContactIdByAlchemyId(portalUserId);
      dealIds = AlchemyAPI.getDealIdsContactId(contactId);

      if (String.isNotBlank(contactId)) {
        Contact contact = [
          SELECT
            Id,
            Alchemy_Portal_Id__c,
            OwnerId,
            Owner.Name,
            Owner.Phone,
            Owner.Email,
            Owner.smallPhotoURl,
            Owner.Portal_Profile_Pic__c
          FROM Contact
          WHERE Id = :contactId
          LIMIT 1
        ];

        if (params.size() > 4) {
          String status = params[4];
          List<Loan> loans = getLoansList(status);
          res.addHeader('Content-Type', 'application/json');
          res.responseBody = Blob.valueOf(JSON.serialize(loans));
        } else {
          Dashboard dashboard = createDashboard(contact);

          res.addHeader('Content-Type', 'application/json');
          res.responseBody = Blob.valueOf(JSON.serialize(dashboard));
        }
      } else {
        Map<String, String> respBody = new Map<String, String>();
        res.addHeader('Content-Type', 'application/json');
        respBody.put('status', 'error');
        respBody.put('message', 'User Id Not Found');
        res.responseBody = Blob.valueOf(JSON.serialize(respBody, true));
      }
    }
  }

  public static List<Loan> getLoansList(String status) {
    List<Loan> loans = new List<Loan>();

    List<Opportunity> opps = new List<Opportunity>();
    if (status == 'new') {
      opps = getNewOpportunities();
    } else if (status == 'active') {
      opps = getActiveOpportunities();
    } else if (status == 'inactive') {
      opps = getInactiveOpportunities();
    }

    Integer size = opps.size();

    if (!usePagination) {
      paginationStart = 0;
      paginationEnd = size;
    }

    for (Integer i = paginationStart; i < paginationEnd; i++) {
      if (i < size) {
        Loan loan = new Loan(opps[i]);
        loans.add(loan);
      }
    }

    return loans;
  }

  public static List<Deal> getDealList(String status) {
    List<Deal> loans = new List<Deal>();

    List<Opportunity> opps = new List<Opportunity>();
    if (status == 'new') {
      opps = getNewOpportunities();
    } else if (status == 'active') {
      opps = getActiveOpportunities();
    } else if (status == 'inactive') {
      opps = getInactiveOpportunities();
    }

    Integer size = opps.size();

    if (!usePagination) {
      paginationStart = 0;
      paginationEnd = size;
    }

    for (Integer i = paginationStart; i < paginationEnd; i++) {
      if (i < size) {
        Deal loan = new Deal(opps[i]);
        loans.add(loan);
      }
    }

    return loans;
  }

  public static List<Property> getPropertyList(String status) {
    List<Property> properties = new List<Property>();

    List<Property__c> props = new List<Property__c>();
    if (status == 'new') {
      props = getNewProperties();
    } else if (status == 'active') {
      props = getActiveProperties();
    } else if (status == 'inactive') {
      props = getInactiveProperties();
    }

    Integer size = props.size();

    if (!usePagination) {
      paginationStart = 0;
      paginationEnd = size;
    }

    for (Integer i = paginationStart; i < paginationEnd; i++) {
      if (i < size) {
        Property prop = new Property(props[i]);
        properties.add(prop);
      }
    }

    return properties;
  }

  public static Dashboard createDashboard(Contact contact) {
    Dashboard dashboard = new Dashboard(contact);
    //Set<Id> dealIds = new Set<Id>();

    Integer activeLoans = 0;
    Integer inactiveLoans = 0;
    Integer newLoans = 0;

    // Integer paginationStart = null;
    // Integer paginationEnd = null;

    //pageSize = 1;
    //page=3
    // Boolean usePagination = false;
    // if (pageSize != null && page != null) {
    //   paginationStart = pageSize * (page - 1) - 1; // 1
    //   paginationEnd = page * pageSize - 1; // 2
    //   usePagination = true;
    // }

    List<Opportunity> opps = getNewOpportunities();
    newLoans = opps.size();

    if (!usePagination) {
      paginationStart = 0;
      paginationEnd = newLoans;
    }

    for (Integer i = paginationStart; i < paginationEnd; i++) {
      if (i < newLoans) {
        Loan loan = new Loan(opps[i]);
        dashboard.newLoans.add(loan);
      }
    }

    opps = getActiveOpportunities();
    activeLoans = opps.size();

    if (!usePagination) {
      paginationStart = 0;
      paginationEnd = activeLoans;
    }

    for (Integer i = paginationStart; i < paginationEnd; i++) {
      if (i < activeLoans) {
        Loan loan = new Loan(opps[i]);
        dashboard.activeLoans.add(loan);
      }
    }

    opps = getInactiveOpportunities();
    inactiveLoans = opps.size();

    if (!usePagination) {
      paginationStart = 0;
      paginationEnd = inactiveLoans;
    }

    for (Integer i = paginationStart; i < paginationEnd; i++) {
      if (i < inactiveLoans) {
        Loan loan = new Loan(opps[i]);
        dashboard.inactiveLoans.add(loan);
      }
    }

    dashboard.numberOfActiveLoans = activeLoans;
    dashboard.numberOfInactiveLoans = inactiveLoans;
    dashboard.numberOfNewLoans = newLoans;

    dashboard.applications = new List<Map<String, String>>();
    for (Application__c applications : [
      SELECT Id, Loan_Type__c, Status__c
      FROM Application__c
      WHERE Alchemy_User_Id__c = :portalUserId
    ]) {
      Map<String, String> application = new Map<String, String>();
      application.put('id', applications.Id);
      application.put('loanType', applications.Loan_Type__c);
      application.put('status', applications.Status__c);

      dashboard.applications.add(application);
    }
    return dashboard;
  }

  public static Map<String, Object> createMyDealsDashboard(Contact contact) {
    // Dashboard dashboard = new Dashboard(contact);
    List<Deal> deals = new List<Deal>();
    Set<Id> dealIds = AlchemyAPI.getDealIdsContactId(contact.Id);
    Map<String, Object> dashboard = new Map<String, Object>();
    dashboard.put('activeLoans', new List<Deal>());
    dashboard.put('newLoans', new List<Deal>());
    dashboard.put('inactiveLoans', new List<Deal>());

    Integer activeLoans = 0;
    Integer inactiveLoans = 0;
    Integer newLoans = 0;

    // Integer paginationStart = null;
    // Integer paginationEnd = null;

    // Boolean usePagination = false;
    // if (pageSize != null && page != null) {
    //   paginationStart = pageSize * (page - 1) - 1; // 1
    //   paginationEnd = page * pageSize - 1; // 2
    //   usePagination = true;
    // }

    List<Opportunity> opps = getNewOpportunities();
    newLoans = opps.size();
    if (!usePagination) {
      paginationStart = 0;
      paginationEnd = newLoans;
    }
    for (Integer i = paginationStart; i < paginationEnd; i++) {
      if (i < newLoans) {
        deal loan = new deal(opps[i]);
        ((List<Deal>) dashboard.get('newLoans')).add(loan);
      }
    }

    opps = getActiveOpportunities();
    activeLoans = opps.size();

    if (!usePagination) {
      paginationStart = 0;
      paginationEnd = activeLoans;
    }

    for (Integer i = paginationStart; i < paginationEnd; i++) {
      if (i < activeLoans) {
        deal loan = new deal(opps[i]);
        ((List<Deal>) dashboard.get('activeLoans')).add(loan);
      }
    }

    opps = getInactiveOpportunities();
    inactiveLoans = opps.size();
    if (!usePagination) {
      paginationStart = 0;
      paginationEnd = inactiveLoans;
    }
    for (Integer i = paginationStart; i < paginationEnd; i++) {
      if (i < inactiveLoans) {
        deal loan = new deal(opps[i]);
        ((List<Deal>) dashboard.get('inactiveLoans')).add(loan);
      }
    }

    dashboard.put('numberOfNewLoans', newLoans);
    dashboard.put('numberOfActiveLoans', activeLoans);
    dashboard.put('numberOfInactiveLoans', inactiveLoans);

    return dashboard;
  }

  public static PropertyDashboard createPropertyDashboard(Contact contact) {
    PropertyDashboard dashboard = new PropertyDashboard();

    Integer activeProperties = 0;
    Integer inactiveProperties = 0;
    Integer newProperties = 0;

    // Integer paginationStart = null;
    // Integer paginationEnd = null;

    //pageSize = 1;
    //page=3
    // Boolean usePagination = false;
    // if (pageSize != null && page != null) {
    //   //   paginationStart = pageSize * (page - 1) - 1; // 2
    //   //   paginationEnd = page * pageSize - 1; // 2
    //   paginationStart = (page - 1) * page; //2
    //   paginationEnd = page * pageSize; //3
    //   usePagination = true;
    // }

    List<Property__c> props = getNewProperties();
    newProperties = props.size();

    system.debug(newProperties);

    if (!usePagination) {
      paginationStart = 0;
      paginationEnd = newProperties;
    }

    system.debug(paginationStart);
    system.debug(paginationEnd);

    for (Integer i = paginationStart; i < paginationEnd; i++) {
      if (i < newProperties) {
        Property property = new property(props[i]);
        dashboard.newProperties.add(property);
      }
    }

    props = getActiveProperties();
    activeProperties = props.size();

    if (!usePagination) {
      paginationStart = 0;
      paginationEnd = activeProperties;
    }

    for (Integer i = paginationStart; i < paginationEnd; i++) {
      if (i < activeProperties) {
        Property property = new property(props[i]);
        dashboard.activeProperties.add(property);
      }
    }

    props = getinActiveProperties();
    inactiveProperties = props.size();

    if (!usePagination) {
      paginationStart = 0;
      paginationEnd = inactiveProperties;
    }

    for (Integer i = paginationStart; i < paginationEnd; i++) {
      if (i < inactiveProperties) {
        Property property = new property(props[i]);
        dashboard.inactiveProperties.add(property);
      }
    }

    dashboard.numberOfActiveProperties = activeProperties;
    dashboard.numberOfInactiveProperties = inactiveProperties;
    dashboard.numberOfNewProperties = newProperties;

    //dashboard.calculateTotals();
    return dashboard;
  }

  public static List<Opportunity> getNewOpportunities() {
    Date today7 = system.today().addDays(7);

    return [
      SELECT
        Id,
        Name,
        Deal_Loan_Number__c,
        StageName,
        Type,
        Final_Loan_Amount__c,
        Current_Loan_AMount__c,
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
        LOC_Loan_Type__c,
        LOC_Commitment__c,
        Term_Loan_Type_Months__c,
        (
          SELECT Id, Name, State__c, City__c, ZipCode__c
          FROM Properties__r
          WHERE Status__c != 'Cancelled' AND Status__c != 'Inactive'
          LIMIT 1
        ),
        (
          SELECT
            Id,
            UserId,
            TeamMemberRole,
            User.Email,
            User.smallPhotoURl,
            User.Name,
            User.Phone,
            User.Portal_Profile_Pic__c
          FROM OpportunityTeamMembers
        )
      FROM Opportunity
      WHERE
        (Contact__c = :contactId
        OR Id IN :dealIds)
        AND StageName NOT IN ('Matured', 'Expired', 'Withdrawn', 'Rejected', 'Paid Off')
        AND (StageName != 'Closed Won'
        OR (StageName = 'Closed Won'
        AND CloseDate >= :today7))
      ORDER BY CloseDate DESC, Name ASC
    ];
  }

  public static List<Opportunity> getActiveOpportunities() {
    Date today7 = system.today().addDays(7);

    return [
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
        (
          SELECT Id, Name, State__c, City__c, ZipCode__c
          FROM Properties__r
          WHERE Status__c != 'Cancelled' AND Status__c != 'Inactive'
          LIMIT 1
        ),
        (
          SELECT
            Id,
            UserId,
            TeamMemberRole,
            User.Email,
            User.smallPhotoURl,
            User.Name,
            User.Phone,
            User.Portal_Profile_Pic__c
          FROM OpportunityTeamMembers
        )
      FROM Opportunity
      WHERE
        (Contact__c = :contactId
        OR Id IN :dealIds)
        AND StageName NOT IN ('Matured', 'Expired', 'Withdrawn', 'Rejected', 'Paid Off')
        AND StageName = 'Closed Won'
        AND CloseDate < :today7
      ORDER BY CloseDate DESC, Name ASC
    ];
  }

  public static List<Opportunity> getInactiveOpportunities() {
    return [
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
        (
          SELECT Id, Name, State__c, City__c, ZipCode__c
          FROM Properties__r
          WHERE Status__c != 'Cancelled' AND Status__c != 'Inactive'
          LIMIT 1
        ),
        (
          SELECT
            Id,
            UserId,
            TeamMemberRole,
            User.Email,
            User.smallPhotoURl,
            User.Name,
            User.Phone,
            User.Portal_Profile_Pic__c
          FROM OpportunityTeamMembers
        )
      FROM Opportunity
      WHERE
        (Contact__c = :contactId
        OR Id IN :dealIds)
        AND StageName IN ('Paid Off', 'Withdrawn', 'Rejected')
      ORDER BY CloseDate DESC, Name ASC
    ];
  }

  public static List<Property__c> getActiveProperties() {
    Date today7 = system.today().addDays(7);

    return [
      SELECT
        Id,
        Deal__c,
        Deal__r.StageName,
        Deal__r.CloseDate,
        Deal__r.Name,
        Name,
        State__c,
        City__c,
        Deal__r.LOC_Loan_Type__c
      FROM Property__c
      WHERE
        (Deal__r.Contact__c = :contactId
        OR Deal__c IN :dealIds)
        AND Deal__r.StageName NOT IN (
          'Matured',
          'Expired',
          'Withdrawn',
          'Rejected',
          'Paid Off'
        )
        AND Deal__r.StageName = 'Closed Won'
        AND Deal__r.CloseDate <= :today7
      ORDER BY Deal__r.CloseDate DESC, Name ASC
    ];
  }

  public static List<Property__c> getNewProperties() {
    Date today7 = system.today().addDays(7);

    return [
      SELECT
        Id,
        Deal__c,
        Deal__r.StageName,
        Deal__r.CloseDate,
        Deal__r.Name,
        Name,
        State__c,
        City__c,
        Deal__r.LOC_Loan_Type__c
      FROM Property__c
      WHERE
        (Deal__r.Contact__c = :contactId
        OR Deal__c IN :dealIds)
        AND Deal__r.StageName NOT IN (
          'Matured',
          'Expired',
          'Withdrawn',
          'Rejected',
          'Paid Off'
        )
        AND (Deal__r.StageName != 'Closed Won'
        OR (Deal__r.StageName = 'Closed Won'
        AND Deal__r.CloseDate > :today7))
      ORDER BY Deal__r.CloseDate DESC, Name ASC
    ];
  }

  public static List<Property__c> getInactiveProperties() {
    Date today7 = system.today().addDays(7);

    return [
      SELECT
        Id,
        Deal__c,
        Deal__r.StageName,
        Deal__r.CloseDate,
        Deal__r.Name,
        Name,
        State__c,
        City__c,
        Deal__r.LOC_Loan_Type__c
      FROM Property__c
      WHERE
        (Deal__r.Contact__c = :contactId
        OR Deal__c IN :dealIds)
        AND Deal__r.StageName IN (
          'Matured',
          'Expired',
          'Withdrawn',
          'Rejected',
          'Paid Off'
        )
      ORDER BY Deal__r.CloseDate DESC, Name ASC
    ];
  }

  public static Map<String, String> dealStageMap = new Map<String, String>{
    'Initial Review' => 'Initial Review',
    'Data Tape Received' => 'Initial Review',
    'Issue Term Sheet/Order Appraisal' => 'Initial Review',
    'Term Sheet Issued' => 'Term Sheet Signed Deposit Collected',
    'Submitted to Underwriting' => 'Term Sheet Issued',
    'Loan Processing' => 'Underwriting',
    'Underwriting' => 'Underwriting',
    'UW Hold' => 'UW Hold',
    'Approved by Committee' => 'Approved',
    'Closed Won' => 'Closed',
    'Expired' => 'Expired',
    'Matured' => 'Matured',
    'Paid Off' => 'Paid Off',
    'Rejected' => 'Rejected',
    'Withdrawn' => 'Withdrawn'
  };

  public static Map<String, String> loanTypeMap = new Map<String, String>{
    'Term Loan' => 'Rental Portfolio',
    'Credit Line' => 'Credit Line',
    'Single Asset (14 Units)' => 'Single Asset',
    'Multifamily/CRE' => 'Multifamily',
    'Build to Rent' => 'Build For Rent',
    'Single Rental Loan' => 'Single Rental',
    'Model Home Lease' => 'Model Home Lease'
  };

  class PropertyDashboard {
    public List<Property> activeProperties;
    public List<Property> newProperties;
    public List<Property> inactiveProperties;

    public Integer numberOfActiveProperties;
    public Integer numberOfInactiveProperties;
    public Integer numberOfNewProperties;

    PropertyDashboard() {
      activeProperties = new List<Property>();
      newProperties = new List<Property>();
      inactiveProperties = new List<Property>();
      numberOfNewProperties = 0;
      numberOfActiveProperties = 0;
      numberOfInactiveProperties = 0;
    }

    public void calculateTotals() {
      this.numberOfActiveProperties = this.activeProperties.size();
      this.numberOfInactiveProperties = this.inactiveProperties.size();
      this.numberOfNewProperties = this.newProperties.size();
    }
  }

  class Property {
    Id id;
    Id loanId;
    String loanName;
    String address;
    String city;
    String state;
    String loanType;

    Property(Property__c property) {
      this.id = property.Id;
      this.loanName = property.Deal__r.Name;
      this.address = property.Name;
      this.city = property.City__c;
      this.state = property.State__c;
      this.loanId = property.Deal__r.Id;
      this.loanType = loanTypeMap.get(property.Deal__r.LOC_Loan_Type__c);
    }
  }

  class Dashboard {
    public List<Loan> activeLoans;
    public List<Loan> newLoans;
    public List<Loan> inactiveLoans;
    public Integer numberOfNewLoans;
    public Integer numberOfActiveLoans;
    public Integer numberOfInactiveLoans;

    public List<Map<String, String>> applications;

    DealTeamMember relationshipManager;

    Dashboard(Contact c) {
      activeLoans = new List<Loan>();
      newLoans = new List<Loan>();
      inactiveLoans = new List<Loan>();
      numberOfNewLoans = 0;
      numberOfActiveLoans = 0;
      numberOfInactiveLoans = 0;
      relationshipManager = new DealTeamMember(c);
    }

    public void calculateTotals() {
      this.numberOfActiveLoans = this.activeLoans.size();
      this.numberOfInactiveLoans = this.inactiveLoans.size();
      this.numberOfNewLoans = this.newLoans.size();
    }
  }

  class Loan {
    // Map<String, Object> data;
    Id id;
    String accountName;
    String loanStage;
    Decimal requestedLoanSize;
    Date estimatedClosing;
    String loanType;
    List<DealTeamMember> dealTeam;
    List<String> currentStatus;
    Decimal totalFunding;
    Decimal fundingUsed;
    String loanName;
    // String status;
    String loanStatus;
    // Decimal amountUsed;

    Integer totalMonths;
    Integer months;

    Loan(Opportunity deal) {
      currentStatus = new List<String>();
      dealTeam = new List<DealTeamMember>();
      this.id = deal.Id;
      //this.loanType = loanTypeMap.get(deal.LOC_Loan_Type__c); //deal.RecordType.Name;

      if (deal.LOC_Loan_Type__c == 'Term Loan') {
        this.loanType = 'Rental Portfolio';
      }
      if (
        deal.LOC_Loan_Type__c == 'Credit Line' &&
        deal.Project_Strategy__c != 'Fix and Flip'
      ) {
        this.loanType = 'Credit Line';
      }
      if (
        deal.LOC_Loan_Type__c == 'Credit Line' &&
        deal.Project_Strategy__c == 'Fix and Fliup'
      ) {
        this.loanType = 'Credit Line';
      }

      if (
        deal.LOC_Loan_Type__c == 'Credit Line' &&
        deal.Product_Sub_Type__c == 'Build to Rent'
      ) {
        this.loanType = 'Build For Rent';
      }

      if (deal.LOC_Loan_Type__c == 'Build to Rent') {
        this.loanType = 'Build For Rent';
      }

      if (
        deal.LOC_Loan_Type__c == 'Single Asset (1-4 Unit)' ||
        deal.LOC_Loan_Type__c == 'Single Asset (5-10 Unit)'
      ) {
        this.loanType = 'Bridge Loan';
      }
      if (deal.Loc_Loan_Type__c == 'Multifamily/CRE') {
        this.loanType = 'Multifamily';
      }

      if (deal.LOC_Loan_Type__c == 'Model Home Release') {
        this.loanType = 'Model Home Release';
      }

      if (deal.LOC_Loan_Type__c == 'Single Asset Rental') {
        this.loanType = 'Single Rental';
      }

      if (deal.LOC_Loan_Type__c == 'Single Rental Loan') {
        this.loanType = 'Single Rental';
      }

      this.accountName = deal.Account.Name;
      this.loanStage = dealStageMap.get(deal.StageName);
      //this.requestedLoanSize = deal.Loan_Size__c;
      if (deal.Type == 'Term Loan' || deal.Type == 'Single Rental Loan') {
        if (
          deal.Final_Loan_Amount__c == null &&
          deal.Current_Loan_Amount__c == null
        ) {
          this.requestedLoanSize = deal.Loan_Size__c;
        } else if (
          deal.Final_Loan_Amount__c == null &&
          deal.Current_Loan_Amount__c != null
        ) {
          this.requestedLoanSize = deal.Current_Loan_Amount__c;
        } else if (deal.Final_Loan_Amount__c != null) {
          this.requestedLoanSize = deal.Final_Loan_Amount__c;
        }
      } else if (deal.Type == 'Bridge Loan' || deal.Type == 'SAB Loan') {
        if (deal.LOC_Commitment__c == null) {
          this.requestedLoanSize = deal.Loan_Size__c;
        } else {
          this.requestedLoanSize = deal.LOC_Commitment__c;
        }
      }

      this.estimatedClosing = deal.CloseDate;
      this.loanName = deal.Name;
      // system.debug(deal.OpportunityTeamMembers);
      for (OpportunityTeamMember teamMember : deal.OpportunityTeamMembers) {
        dealTeam.add(new DealTeamMember(teamMember));
      }

      this.totalFunding = deal.LOC_Commitment__c;
      this.fundingUsed = deal.Aggregate_Funding__c;
      if (String.isNotBlank(deal.Term_Loan_Type_Months__c)) {
        String months = deal.Term_Loan_Type_Months__c.replaceALl('months', '')
          .trim();
        months = months.replaceALL('Months', '');

        this.totalMonths = Integer.valueOf(months.trim());
        this.months = 0;
      }

      if (String.isNotBlank(deal.LOC_Term__c)) {
        String months = deal.LOC_Term__c.replaceALl('months', '').trim();
        months = months.replaceALL('Months', '');
        this.totalMonths = Integer.valueOf(months.trim());
        // this.totalMonths = Integer.valueOf(
        //   deal.LOC_Term__c.replaceALl('months', '').trim()
        // );
        this.months = 0;
      }

      Date today = system.today();
      Date closeDate = deal.CloseDate;

      this.months = closeDate.monthsBetween(today);

      this.loanStatus = 'New Loan';
      if (deal.StageName == 'Rejected' || deal.StageName == 'Withdrawn') {
        this.loanStatus = 'Inactive Loan';
      }

      if (
        deal.StageName == 'Expired' ||
        deal.StageName == 'Matured' ||
        deal.StageName == 'Paid Off'
      ) {
        this.loanStatus = 'Past Loan';
      }

      if (
        deal.StageName == 'Closed Won' &&
        system.today().addDays(7) > deal.CloseDate
      ) {
        this.loanStatus = 'Active Loan';
      }

      // this.totalMonths = deal.Term_Loan_Type_Months__c.replace();
      // this.months = 0;
      // data.put('loanType')
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
      //this.photoURL = 'https://cvest--alchemy.my.salesforce.com/file-asset-public/Mjpg?oid=00DZ0000009T6aH';//teamMember.User.smallPhotoURl;
    }

    DealTeamMember(Contact c) {
      this.name = c.Owner.Name;
      this.role = 'Relationship Manager';
      this.phoneNumber = c.Owner.Phone;
      this.email = c.Owner.Email;
      if (String.isBlank(c.Owner.Portal_Profile_Pic__c)) {
        this.photoURL = 'https://cvest--alchemy.my.salesforce.com/file-asset-public/default?oid=00DZ0000009T6aH';
      } else {
        this.photoURL = c.Owner.Portal_Profile_Pic__c;
      }
      //this.photoURL = c.Owner.smallPhotoURl;
    }
  }

  class Deal {
    String loanName;
    String loanNumber;
    String loanStatus;
    String loanStage;
    Decimal loanAmount;
    String productType;
    String productSubType;
    String projectStrategy;
    String portalProductType;
    String type;
    Date closeDate;
    Date loanMaturityDate;
    Decimal remainingCommitment;
    Decimal totalProperties;
    String termInMonths;
    String propertyAddress;
    String termInYears;
    Decimal totalFunded;
    String id;
    Deal(Opportunity opp) {
      this.id = opp.Id;
      this.loanName = opp.Name;
      this.loanNumber = opp.Deal_Loan_Number__c;
      this.loanStage = dealStageMap.get(opp.StageName);
      this.type = opp.Type;
      // if (
      //   opp.Final_Loan_Amount__c == null &&
      //   opp.Current_Loan_Amount__c == null &&
      //   opp.LOC_Commitment__c == null
      // ) {
      //   this.loanAmount = opp.Loan_Size__c;
      // } else if (
      //   opp.Final_Loan_Amount__c == null &&
      //   opp.Current_Loan_Amount__c != null
      // ) {
      //   this.loanAmount = opp.CUrrent_Loan_Amount__c;
      // } else if (opp.Final_Loan_Amount__c != null) {
      //   this.loanAmount = opp.Final_Loan_Amount__c;
      // } else {
      //   this.loanAMount = opp.LOC_Commitment__c;
      // }

      if (opp.Type == 'Term Loan' || opp.Type == 'Single Rental Loan') {
        if (
          opp.Final_Loan_Amount__c == null &&
          opp.Current_Loan_Amount__c == null
        ) {
          this.loanAmount = opp.Loan_Size__c;
        } else if (
          opp.Final_Loan_Amount__c == null &&
          opp.Current_Loan_Amount__c != null
        ) {
          this.loanAmount = opp.Current_Loan_Amount__c;
        } else if (opp.Final_Loan_Amount__c != null) {
          this.loanAmount = opp.Final_Loan_Amount__c;
        }
      } else if (opp.Type == 'Bridge Loan' || opp.Type == 'SAB Loan') {
        if (opp.LOC_Commitment__c == null) {
          this.loanAmount = opp.Loan_Size__c;
        } else {
          this.loanAmount = opp.LOC_Commitment__c;
        }
      }

      this.productType = opp.LOC_Loan_Type__c;
      this.productSubType = opp.Product_Sub_Type__c;
      this.projectStrategy = opp.Project_Strategy__c;
      if (opp.LOC_Loan_Type__c == 'Term Loan') {
        this.portalProductType = 'Rental Portfolio';
      }
      if (
        opp.LOC_Loan_Type__c == 'Credit Line' &&
        opp.Project_Strategy__c != 'Fix and Flip'
      ) {
        this.portalProductType = 'Credit Line';
      }
      if (
        opp.LOC_Loan_Type__c == 'Credit Line' &&
        opp.Project_Strategy__c == 'Fix and Flip'
      ) {
        this.portalProductType = 'Fix and Flip';
      }

      if (
        opp.LOC_Loan_Type__c == 'Credit Line' &&
        opp.Product_Sub_Type__c == 'Build to Rent'
      ) {
        this.portalProductType = 'Build For Rent';
      }

      if (opp.LOC_Loan_Type__c == 'Build to Rent') {
        this.portalProductType = 'Build For Rent';
      }

      if (
        opp.LOC_Loan_Type__c == 'Single Asset (1-4 Unit)' ||
        opp.LOC_Loan_Type__c == 'Single Asset (5-10 Unit)'
      ) {
        this.portalProductType = 'Bridge Loan';
      }
      if (opp.Loc_Loan_Type__c == 'Multifamily/CRE') {
        this.portalProductType = 'Multifamily';
      }

      if (opp.LOC_Loan_Type__c == 'Model Home Release') {
        this.portalProductType = 'Model Home Release';
      }

      if (opp.LOC_Loan_Type__c == 'Single Rental Loan') {
        this.portalProductType = 'Single Rental';
      }

      if (opp.LOC_Loan_Type__c == 'Single Asset Rental') {
        this.portalProductType = 'Single Rental';
      }

      this.closeDate = opp.CloseDate;

      this.loanMaturityDate = opp.Updated_Loan_Maturity_Date__c;
      this.totalFunded = opp.Aggregate_Funding__c;
      this.termInYears = opp.Term_Loan_Type__c;
      this.termInMonths = opp.LOC_Term__c;
      this.remainingCommitment = opp.Outstanding_Facility_Amount__c;
      this.totalProperties = opp.Total_Properties__c;

      Set<String> singleAssetLoanTypes = new Set<String>{
        'Single Asset (1-4 Unit)',
        'Single Asset (5-10 Unit)',
        'Multifamily/CRE',
        'Single Rental Loan'
      };
      if (
        singleAssetLoanTypes.contains(opp.LOC_Loan_Type__c) &&
        opp.Properties__r.size() > 0
      ) {
        Property__c property = opp.Properties__r[0];
        this.propertyAddress =
          property.Name +
          ' ' +
          property.City__c +
          ' ' +
          property.State__c +
          ' ' +
          property.ZipCode__c;
      }

      this.loanStatus = 'New Loan';
      if (opp.StageName == 'Rejected' || opp.StageName == 'Withdrawn') {
        this.loanStatus = 'Inactive Loan';
      }

      if (
        opp.StageName == 'Expired' ||
        opp.StageName == 'Matured' ||
        opp.StageName == 'Paid Off'
      ) {
        this.loanStatus = 'Past Loan';
      }

      if (
        opp.StageName == 'Closed Won' &&
        system.today().addDays(7) > opp.CloseDate
      ) {
        this.loanStatus = 'Active Loan';
      }

      // if(opp.LOC_Loan_Type__c == 'Credit Line' && opp.Product_Sub_Type__c = 'Build to Rent'){

      // }
    }
  }
}