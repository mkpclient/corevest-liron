public without sharing class TitleOrderHelper {
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
              Order_Opened_Date__c,
              Title_Complete_Date__c,
              Original_Title_Cleared_Date__c,
              All_Cleared_To_Close_Date__c,
              Comments__c,
              Title_Vendor__c
            FROM Title_Orders__r
            ORDER BY CreatedDate DESC
          )
        FROM Property__c
        WHERE Deal__c = :dealId AND Is_Sub_Unit__c = FALSE
      ];

      for(Property__c p : props) {
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
  public static List<Deal_Document__c> retrieveDocuments(Id dealId, List<Id> titleOrderIds){
    try {
      String queryString = 'SELECT ' + String.join(DEAL_DOC_FIELDS, ',') + ' FROM Deal_Document__c';
      queryString += ' WHERE Document_Type__c = :DOCUMENT_TYPE AND Deal__c= :dealId';
      if(titleOrderIds.size() > 0) {
        queryString += ' AND Title_Order__c IN :titleOrderIds';
      }
      List<Deal_Document__c> dealDocs = Database.query(queryString);

      return dealDocs;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }



  public class TitleOrderObject {
    public String titleOrderId { get; set; }
    public String titleVendor { get; set; }
    public DateTime orderDate { get; set; }
    public DateTime titleCompleted { get; set; }
    public DateTime originalTitleCleared { get; set; }
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
        this.linkUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + property.Id;

      }
      List<TitleOrderObject> titleOrdersLocal = new List<TitleOrderObject>();
      if (titleOrders != null && titleOrders.size() > 0) {
        for (Title_Order__c titleOrder : titleOrders) {
          TitleOrderObject titleOrderval = new TitleOrderObject();
          titleOrderval.titleOrderId = titleOrder.Id;
          titleOrderval.titleOrderStatus = titleOrder.Status__c;
          titleOrderval.titleVendor = String.isNotEmpty(titleOrder.Title_Vendor__c) ? titleOrder.Title_Vendor__c : null;
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
          titleOrderval.linkUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + titleOrder.Id;
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
