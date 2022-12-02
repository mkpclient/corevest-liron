public without sharing class ChecklistPDFController {
  public List<Checklist_Item__c> dealItems { get; set; }
  public List<Checklist_Item__c> contactItems { get; set; }

  public ChecklistPDFController(
    ApexPages.standardController standardController
  ) {
    system.debug('init');
    String id = ApexPages.currentPage().getParameters().get('id');

    Checklist_Section__c section = [
      SELECT Id, PDF_Generation_Ids__c
      FROM Checklist_Section__c
      WHERE Id = :id
    ];

    Map<String, List<Checklist_Item__c>> itemMap = new Map<String, List<Checklist_Item__c>>();
    itemMap.put('deal', new List<Checklist_Item__c>());
    itemMap.put('contact', new List<Checklist_Item__c>());

    if (String.isNotBlank(section.PDF_Generation_Ids__c)) {
      List<String> ids = (List<String>) JSON.deserialize(
        section.PDF_Generation_Ids__c,
        List<String>.class
      );

      for (Checklist_Item__c item : [
        SELECT
          Id,
          Property__c,
          Deal__c,
          Doc_Structure_Id__c,
          Document_Type__c,
          Folder_String__c,
          Status__c,
          Name,
          Checklist_Section__c,
          (
            SELECT
              Id,
              Added_On__c,
              Added_By__r.Name,
              Document_Type__c,
              Reviewed_By__r.Name,
              Reviewed_On__c,
              File_Name__c,
              ContentVersion_Id__c,
              Status__c,
              Comments__c,
              Reviewed__c
            FROM Deal_Documents__r
          ),
          (
            SELECT
              Id,
              Deal__c,
              Lead__r.Name,
              Contact__r.Name,
              Lead__c,
              Contact__c,
              Application__c,
              Body__c,
              Alchemy_Portal_Id__c,
              Submitted_From_Portal__c,
              Deal_Document__c,
              Property__c,
              CreatedDate,
              Owner.Name,
              Owner.Id,
              Subject__c,
              Comment__c,
              Owner_Image__c,
              Application__r.Name,
              Property__r.Name,
              Deal__r.Name,
              Deal_Document__r.Name,
              Unread__c,
              Checklist_Item__c
            FROM Comments__r
            ORDER BY CreatedDate ASC
          )
        FROM Checklist_Item__c
        WHERE Id IN :ids
      ]) {
        String itemType = 'deal';
        if (item.Checklist_Section__c == id) {
          itemType = 'contact';
        }

        if (item.Status__c == 'Pending') {
          item.Status__c = 'Not Started';
        }

        itemMap.get(itemType).add(item);
      }
    }

    this.dealItems = itemMap.get('deal');
    this.contactItems = itemMap.get('contact');

    system.debug(dealItems);
    system.debug(contactItems);
  }
}