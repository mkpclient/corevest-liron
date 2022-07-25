public without sharing class TitleOrder_LightningHelper {
  public static final String DOCUMENT_TYPE = 'Title Order';
  public static final List<String> DEAL_DOC_FIELDS = new List<String>{
    'Id',
    'Deal__c',
    'Title_Order__c',
    'Service_Link_Id__c',
    'Type__c',
    'Document_Type__c',
    'File_Name__c',
    'Attachment_Id__c',
    'ContentVersion_Id__c'
  };
  public static final List<String> DEAL_FIELDS = new List<String>{
    'Deal_Loan_Number__c',
    'Id',
    'Current_Loan_Amount__c',
    'Name'
  };

  public static final Map<String,String> DATATAPE_FIELD_MAP = new Map<String,String>{
    'Asset_ID__c' => 'Asset ID',
    'Property_Name__c' => 'Property Name (Parent Property)',
    'APN__c' => 'APN',
    'Property_Type__c' => 'Property Type',
    'Name' => 'Address',
    'City__c' => 'City',
    'State__c' => 'State',
    'ZipCode__c' => 'ZIP',
    'County__c' => 'County',
    'Number_of_Units__c' => '# of Units',
    'Number_of_Beds__c' => 'BD',
    'Number_of_Bath__c' => 'BA',
    'Square_Feet__c' => 'SF',
    'No_of_Stories__c' => '# of Stories',
    'Year_Built__c' => 'Year Built',
    'Air_Conditioning__c' => 'A/C',
    'Pool__c' => 'Pool',
    'Section_8__c' => 'Section 8',
    'Condition__c' => 'Condition',
    'Zoning_Compliance__c' => 'Legally Conforming',
    'Acquisition_Date__c' => 'Acquisition Date',
    'Acquisition_Price__c' => 'Acquisition Price',
    'Acquisition_Type__c' => 'Acquisition Type',
    'Transaction_Costs__c' => 'Transaction Costs',
    'Rehab_Costs__c' => 'Rehab Costs',
    'Rehab_Completion_Date__c' => 'Rehab Completion Date',
    'Total_Basis__c' => 'Total Basis',
    'Borrower_Opinion_of_Current_Value__c' => 'Borrower Opinion of Current Market Value',
    'Calc_AveValue__c' => 'Red Bell Calc AveValue',
    'Appraisal_Form__c' => 'Appraisal Form',
    'BPO_Appraisal_Date__c' => 'Effective Date',
    'Appraised_Value_Amount__c' => 'Appraisal Value',
    'Currently_Leased__c' => 'Currently Leased? (Y/N)',
    'Lease_Ready__c' => 'Lease Ready',
    'Lease_Start_Date__c' => 'Lease Start Date',
    'Lease_End_Date__c' => 'Lease End Date',
    'Lease_Term__c' => 'Lease Term',
    'Monthly_Rent__c' => 'Monthly Rent',
    'Estimated_Rent__c' => 'Monthly Estimated Rent',
    'Security_Deposit__c' => 'Security Deposit',
    'Other_Income__c' => 'Other Income',
    'Annual_HOA_Fee__c' => 'HOA',
    'Special_Assesments_CFD_Mello_Roos_etc__c' => 'Special Assessments',
    'Annual_Taxes__c' => 'Taxes',
    'Annual_Insurance__c' => 'Insurance',
    'Annual_Managment_Fee__c' => 'Property Management',
    'Maintenance_Repairs__c' => 'Maintenance/ Repairs',
    'Owner_Paid_Utilities__c' => 'Owner Paid Utilities',
    'Annual_Landscaping_Expense__c' => 'Landscaping Expense',
    'Other_Expenses__c' => 'Other Expenses',
    'Lease_Up_Marketing__c' => 'Lease Up/Marketing',
    'Vacancy_Repairs__c' => 'Vacancy Repairs/Maintenance',
    'Credit_Loss__c' => 'Credit Loss',
    'Annual_Total_Expenses__c' => 'Total Expenses',
    'Cap_Ex_Reserves__c' => 'CapEx Reserves',
    'Other_Reserves__c' => 'Other Reserves',
    'Annual_NOI__c' => 'NOI',
    'Property_Manager__c' => 'Assigned PM Company (By property)',
    'Interior_Access_POC__c' => 'Interior Access POC',
    'Interior_Access_POC_Phone__c' => 'Interior Access POC Phone',
    'Interior_Access_POC_Email__c' => 'Interior Access POC Email',
    'Existing_Debt__c' => 'Existing Debt',
    'Asset_Maturity_Date_Override__c' => 'Date of Maturity',
    'Current_Interest_Rate__c' => 'Interest Rate',
    'Are_Payments_Current__c' => 'Are payments current',
    'Refinance_Acquisition__c' => 'Refinance / Acquisition',
    'ALA__c' => 'ALA',
    'Appraisal_Replacement_Cost_Value__c' => 'Appraisal Replacement Cost Value'
  };

  @AuraEnabled
  public static String retrieveData(Id dealId) {
    try {
      List<ReturnObject> returnObj = new List<ReturnObject>();
      List<Property__c> props = [
        SELECT
          Id,
          Name,
          City__c,
          Property_Type__c,
          Number_of_Units__c,
          Status__c,
          (
            SELECT
              Id,
              Status__c,
              Status_Formula__c,
              Order_Opened_Date__c,
              Title_Complete_Date__c,
              Original_Title_Cleared_Date__c,
              All_Cleared_To_Close_Date__c,
              Comments__c,
              Title_Vendor__c,
              Order_Number__c
            FROM Title_Orders__r
            ORDER BY CreatedDate DESC
          )
        FROM Property__c
        WHERE Deal__c = :dealId AND Is_Sub_Unit__c = FALSE
      ];

      for (Property__c p : props) {
        ReturnObject retVal = new ReturnObject();
        retVal.parseData(p, p.Title_Orders__r);
        returnObj.add(retVal);
      }

      return JSON.serialize(returnObj);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static List<Deal_Document__c> retrieveDocuments(
    Id dealId,
    List<Id> titleOrderIds
  ) {
    try {
      String queryString =
        'SELECT ' +
        String.join(DEAL_DOC_FIELDS, ',') +
        ' FROM Deal_Document__c';
      queryString += ' WHERE Document_Type__c = :DOCUMENT_TYPE AND Deal__c= :dealId';
      if (titleOrderIds.size() > 0) {
        queryString += ' AND Title_Order__c IN :titleOrderIds';
      }
      List<Deal_Document__c> dealDocs = Database.query(queryString);

      return dealDocs;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static String returnDataTapeJson(List<Id> propertyIds) {
    String query = 'SELECT ' + String.join(new List<String>(DATATAPE_FIELD_MAP.keySet()), ', ') + ' FROM Property__c WHERE Id IN :propertyIds';

    List<Property__c> props = Database.query(query);
    List<Map<String,Object>> returnList = new List<Map<String,Object>>();

    for(Property__c p : props) {
      Map<String,Object> objMap = new Map<String,Object>();
      for(String key : DATATAPE_FIELD_MAP.keySet()) {
        objMap.put(DATATAPE_FIELD_MAP.get(key), p.get(key));
      }
      returnList.add(objMap);
    }

    return JSON.serialize(returnList);
  }

  @AuraEnabled
  public static void quoteRequest(List<Id> propertyIds, Id dealId, Id cvId) {
    Integer numOfTitleOrders = [
      SELECT COUNT()
      FROM Title_Order__c
      WHERE Deal__c = :dealId
    ];

    ContentVersion cv = [
      SELECT ContentSize, VersionData
      FROM ContentVersion
      WHERE Id = :cvId
    ];
    Deal_Document__c dealDoc = [
      SELECT File_Name__c
      FROM Deal_Document__c
      WHERE ContentVersion_Id__c = :cvId
    ];
    String queryString =
      'SELECT ' +
      String.join(DEAL_FIELDS, ',') +
      ' FROM Opportunity WHERE Id = :dealId';
    Opportunity deal = Database.query(queryString);

    ServiceLinkAPI.ServiceLinkRequest qRequest = new ServiceLinkAPI.ServiceLinkRequest();
    qRequest.generateRequest(deal, dealDoc, cv, numOfTitleOrders + 1);
    ServiceLinkAPI.ServiceLinkRequest qResponse = ServiceLinkAPI.performRequest(
      'QuoteRequest',
      qRequest
    );
    List<Title_Order__c> titleOrders = new List<Title_Order__c>();

    for (Id propId : propertyIds) {
      titleOrders.add(
        new Title_Order__c(
          Property__c = propId,
          Source_Party_ID__c = qRequest.SourcePartyID,
          Destination_Party_ID__c = qRequest.DestinationPartyID,
          Quote_ID__c = qRequest.QuoteID,
          Loan_Number__c = qRequest.LoanNumber,
          Loan_Portfolio_Name__c = qRequest.LoanPortfolioName,
          Loan_Amount__c = qRequest.LoanAmount,
          Comments__c = qRequest.Comments,
          Document_Name__c = qRequest.Document.DocumentName,
          Document_Type__c = qRequest.Document.DocumentType,
          Bulk_Project_Order_Num__c = qResponse.BulkProjectOrderNum,
          Deal__c = dealId
        )
      );
    }

    performDmlFuture(JSON.serialize(titleOrders));
  }

  @future
  public static void performDmlFuture(String sobjectJson) {
    List<Title_Order__c> titleOrders = (List<Title_Order__c>) JSON.deserialize(
      sobjectJson,
      List<Title_Order__c>.class
    );
    upsert titleOrders;
  }

  public class TitleOrderObject {
    public String titleOrderId { get; set; }
    public String titleVendor { get; set; }
    public DateTime orderDate { get; set; }
    public Date titleCompleted { get; set; }
    public Date originalTitleCleared { get; set; }
    public DateTime allClearedToClose { get; set; }
    public String titleOrderStatus { get; set; }
    public String comments { get; set; }
    public Boolean showCheckbox { get; set; }
    public Boolean showURL { get; set; }
    public String linkUrl { get; set; }
  }

  public class ReturnObject {
    public String propertyId { get; set; }
    public String address { get; set; }
    public String city { get; set; }
    public String propertyType { get; set; }
    public Decimal noOfUnits { get; set; }
    public String propertyStatus { get; set; }
    public String linkUrl { get; set; }
    public List<TitleOrderObject> titleOrders { get; set; }

    public void parseData(
      Property__c property,
      List<Title_Order__c> titleOrders
    ) {
      if (property != null) {
        this.propertyId = property.Id;
        this.address = property.Name;
        this.city = property.City__c;
        this.propertyType = property.Property_Type__c;
        this.noOfUnits = property.Number_of_Units__c;
        this.propertyStatus = property.Status__c;
        this.linkUrl =
          System.URL.getSalesforceBaseUrl().toExternalForm() +
          '/' +
          property.Id;
      }
      List<TitleOrderObject> titleOrdersLocal = new List<TitleOrderObject>();
      if (titleOrders != null && titleOrders.size() > 0) {
        for (Title_Order__c titleOrder : titleOrders) {
          TitleOrderObject titleOrderval = new TitleOrderObject();
          titleOrderval.titleOrderId = titleOrder.Id;
          titleOrderval.titleOrderStatus = titleOrder.Status_Formula__c;
          titleOrderval.titleVendor = String.isNotEmpty(
              titleOrder.Title_Vendor__c
            )
            ? titleOrder.Title_Vendor__c
            : null;
          titleOrderval.orderDate = titleOrder.Order_Opened_Date__c != null
            ? titleOrder.Order_Opened_Date__c
            : null;
          titleOrderval.titleCompleted = titleOrder.Title_Complete_Date__c !=
            null
            ? titleOrder.Title_Complete_Date__c
            : null;
          titleOrderval.originalTitleCleared = titleOrder.Original_Title_Cleared_Date__c !=
            null
            ? titleOrder.Original_Title_Cleared_Date__c
            : null;
          titleOrderval.allClearedToClose = titleOrder.All_Cleared_To_Close_Date__c !=
            null
            ? titleOrder.All_Cleared_To_Close_Date__c
            : null;
          titleOrderval.comments = String.isNotEmpty(titleOrder.Comments__c)
            ? titleOrder.Comments__c
            : null;
          titleOrderval.showCheckbox = true;
          titleOrderval.showURL = true;
          titleOrderval.linkUrl =
            System.URL.getSalesforceBaseUrl().toExternalForm() +
            '/' +
            titleOrder.Id;
          titleOrdersLocal.add(titleOrderval);
        }
      } else {
        TitleOrderObject titleOrder = new TitleOrderObject();
        titleOrder.titleOrderStatus = 'Unordered';
        titleOrder.showCheckbox = false;
        titleOrder.showURL = false;
        titleOrder.titleOrderId = property.Id;
        titleOrdersLocal.add(titleOrder);
      }
      this.titleOrders = titleOrdersLocal;
    }
  }
}
