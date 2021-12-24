public without sharing class CommunityController {
  @AuraEnabled
  public static string getRelationshipManager() {
    community_Controller.UserResource user = (community_Controller.UserResource) JSON.deserialize(
      community_Controller.getUser(),
      community_Controller.UserResource.class
    );
    if (user.userType == 'borrower') {
      Map<String, String> relationshipManager = new Map<String, String>();
      Contact c = [
        SELECT Id, Owner.Name, Owner.Email, Owner.MediumPhotoURL, Owner.Phone
        FROM Contact
        WHERE Id = :user.contactId
        LIMIT 1
      ];
      relationshipManager.put('name', c.Owner.Name);
      relationshipManager.put('email', c.Owner.Email);
      relationshipManager.put('phone', c.Owner.Phone);
      relationshipManager.put('photoURL', c.Owner.MediumPhotoURL);

      return JSON.serialize(relationshipManager);
    } else {
      return null;
    }

    //return null;
  }

  @AuraEnabled
  public static string getUnderwriter(String recordType) {
    community_Controller.UserResource user = (community_Controller.UserResource) JSON.deserialize(
      community_Controller.getUser(),
      community_Controller.UserResource.class
    );
    if (user.userType == 'borrower') {
      Map<String, String> underwriter = new Map<String, String>();

      // List<Opportunity> deals = [SELECT Id, Underwriter__c, Underwriter__r.Name, Underwriter__r.Email, Underwriter__r.MediumPhotoURL, Underwriter__r.Phone
      //                             FROM Opportunity
      //                             WHERE RecordType__c =: recordType AND StageName IN ('Underwriting', 'Closed Won', 'Matured', 'Expired')
      //                             Order By StageName Asc, CreatedDate Desc];

      Set<Id> oppIds = new Set<Id>();
      for (Deal_Contact__c c : [
        SELECT Id, Deal__c
        FROM Deal_Contact__c
        WHERE Contact__c = :user.contactId AND Entity_Type__c = 'Portal Access'
      ]) {
        oppIds.add(c.Deal__c);
      }

      Boolean foundUw = false;

      for (Opportunity deal : [
        SELECT
          Id,
          Underwriter__c,
          Underwriter__r.Name,
          Underwriter__r.Email,
          Underwriter__r.MediumPhotoURL,
          Underwriter__r.Phone
        FROM Opportunity
        WHERE
          RecordType__c = :recordType
          AND StageName IN ('Underwriting', 'Closed Won', 'Matured', 'Expired')
          AND (Id IN :oppIds
          OR Contact__c = :user.contactId)
        ORDER BY StageName ASC, CreatedDate DESC
      ]) {
        if (String.isNotBlank(deal.Underwriter__c)) {
          underwriter.put('name', deal.Underwriter__r.Name);
          underwriter.put('email', deal.Underwriter__r.Email);
          underwriter.put('phone', deal.Underwriter__r.Phone);
          underwriter.put('photoURL', deal.Underwriter__r.MediumPhotoURL);

          foundUw = true;
          break;
        }
      }

      if (foundUw) {
        return JSON.serialize(underwriter);
      } else {
        return null;
      }
    } else {
      return null;
    }

    //return null;
  }

  @AuraEnabled
  public static string getPortalUser() {
    User u = [
      SELECT Id, Contact.FirstName, Contact.LastName
      FROM User
      WHERE ID = :UserInfo.getUserId()
    ];

    Map<String, String> userMap = new Map<String, String>();

    userMap.put('firstname', u.Contact.FirstName);
    userMap.put('lastname', u.Contact.LastName);

    return JSON.serialize(userMap);
    //return null;
  }

  @AuraEnabled
  public static String submitRequest(Contact updatedContact, Task t) {
    try {
      update updatedContact;
      insert t;
    } catch (DmlException e) {
      throw new AuraHandledException(e.getMessage());
    }

    return 'SUCCESS';
  }

  @AuraEnabled
  public static Contact getContactDetails() {
    Contact userContact = null;
    community_Controller.UserResource user = (community_Controller.UserResource) JSON.deserialize(
      community_Controller.getUser(),
      community_Controller.UserResource.class
    );

    if (user.contactId != null) {
      userContact = [
        SELECT
          FirstName,
          LastName,
          Phone,
          Email,
          Company_Name__c,
          MailingStreet,
          MailingCity,
          MailingState,
          MailingPostalCode,
          OwnerId
        FROM Contact
        WHERE ID = :user.contactId
        LIMIT 1
      ];
    }

    return userContact;
  }

  @AuraEnabled
  public static Opportunity getDealInfo(String recordId) {
    Opportunity o = null;
    if (checkAccess(recordId)) {
      o = [
        SELECT
          Id,
          RecordType.DeveloperName,
          Name,
          LOC_Loan_Type__c,
          Loan_Size__c,
          Product_Sub_Type__c
        FROM Opportunity
        WHERE Id = :recordId
        LIMIT 1
      ];
    }

    return o;
  }

  @AuraEnabled
  public static string getRecordType(String recordId) {
    String recordType = '';
    if (checkAccess(recordId)) {
      if (String.isNotBlank(recordId) && recordId instanceof Id) {
        String queryString =
          'SELECT Id, RecordType.DeveloperName FROM ' +
          String.valueOf(Id.ValueOf(recordId).getSObjectType()) +
          ' WHERE Id =\'' +
          recordId +
          '\' AND RecordTypeId != null LIMIT 1';
        List<sObject> sobjList = database.query(queryString);
        if (sobjList.size() > 0) {
          recordType = (String) sobjList[0]
            .getsObject('RecordType')
            .get('DeveloperName');
        }
      }
    } else {
      recordType = null;
    }

    return recordType;
  }

  @AuraEnabled
  public static String getDealMembers(String recordId) {
    List<Map<String, Object>> dealMembers = new List<Map<String, Object>>();

    if (checkAccess(recordId)) {
      for (OpportunityTeamMember member : [
        SELECT
          Id,
          UserId,
          TeamMemberRole,
          User.Email,
          User.MediumPhotoURL,
          User.Name
        FROM OpportunityTeamMember
        WHERE OpportunityId = :recordId
      ]) {
        Map<String, String> dealMember = new Map<String, String>();
        dealMember.put('name', member.User.Name);
        dealMember.put('teamMemberRole', member.TeamMemberRole);
        dealMember.put('email', member.User.Email);
        dealMember.put('photoURL', member.User.MediumPhotoURL);

        dealMembers.add(dealMember);
      }
    }
    return JSON.serialize(dealMembers);
  }

  public static boolean checkAccess(Id recordId) {
    if (
      [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()]
      .ContactId == null
    ) {
      return true;
    }

    Boolean hasAccess = false;
    String sobjectType = recordId.getSObjectType().getDescribe().getName();
    community_Controller.UserResource user = (community_Controller.UserResource) JSON.deserialize(
      community_Controller.getUser(),
      community_Controller.UserResource.class
    );

    if (user.userType == 'vendor') {
      hasAccess = checkVendorAccess(recordId, sobjectType, user);
    } else if (user.userType == 'borrower') {
      hasAccess = checkBorrowerAccess(recordId, sobjectType, user);
    } else if (user.userType == 'standard') {
      hasAccess = true;
    }
    return hasAccess;
  }

  // public static Boolean checkAccess(Id recordId,)

  public static Boolean checkVendorAccess(
    Id recordId,
    String sobjectType,
    community_Controller.UserResource user
  ) {
    Boolean hasAccess = false;
    if (sobjectType == 'Opportunity') {
      Id vendorId = user.accountId;
      hasAccess = ([
        SELECT Id
        FROM Deal_Contact__c
        WHERE Deal__c = :recordId AND Account__c = :vendorId
      ]
      .size() > 0);
    } else if (sobjectType == 'Property__c') {
      Id dealId = [
        SELECT Id, Deal__c
        FROM Property__c
        WHERE Id = :recordId
        LIMIT 1
      ]
      .Deal__c;
      return checkVendorAccess(dealId, 'Opportunity', user);
    }

    return hasAccess;
  }

  public static Boolean checkBorrowerAccess(
    Id recordId,
    String sobjectType,
    community_Controller.UserResource user
  ) {
    //return false;
    Boolean hasAccess = false;
    if (sobjectType == 'Opportunity') {
      hasAccess =
        [SELECT Id FROM Opportunity WHERE Contact__c = :user.ContactId].size() >
        0 ||
        [
          SELECT Id
          FROM Deal_Contact__C
          WHERE
            Deal__c = :recordId
            AND Contact__c = :user.ContactId
            AND Entity_Type__c = 'Portal Access'
        ]
        .size() > 0;
    } else if (sobjectType == 'Property__c') {
      Id dealId = [
        SELECT Id, Deal__c
        FROM Property__c
        WHERE Id = :recordId
        LIMIT 1
      ]
      .Deal__c;
      return checkBorrowerAccess(dealId, 'Opportunity', user);
    }
    return hasAccess;
  }

  @AuraEnabled
  public static String getTermDataTapeProperties(
    String recordId,
    String filter
  ) {
    List<String> termFields = new List<String>{
      'Asset_ID__c',
      'Property_Name__c',
      'APN__c',
      'Property_Type__c',
      'Name',
      'City__c',
      'State__c',
      'ZipCode__c',
      'County__c',
      'Number_of_Units__c',
      'Number_of_Beds__c',
      'Number_of_Bath__c',
      'Square_Feet__c',
      'Year_Built__c',
      'Air_Conditioning__c',
      'Pool__c',
      'Section_8__c',
      'Condition__c',
      'Zoning_Compliance__c',
      'Acquisition_Date__c',
      'Acquisition_Price__c',
      //'Transaction_Type__c',
      'Transaction_Costs__c',
      'Rehab_Costs__c',
      'Total_Basis__c',
      'Borrower_Opinion_of_Current_Value__c',
      'Calc_AveValue__c',
      'Appraisal_Form__c',
      'BPO_Appraisal_Date__c',
      'Appraised_Value_Amount__c',
      'Currently_Leased__c',
      'Lease_Ready__c',
      'Lease_End_Date__c',
      'Lease_Term__c',
      'Monthly_Rent__c',
      'Security_Deposit__c',
      'Other_Income__c',
      'Annual_HOA_Fee__c',
      'Special_Assesments_CFD_Mello_Roos_etc__c',
      'Annual_Taxes__c',
      'Annual_Insurance__c',
      'Annual_Managment_Fee__c',
      'Maintenance_Repairs__c',
      'Owner_Paid_Utilities__c',
      'Annual_Landscaping_Expense__c',
      'Other_Expenses__c',
      'Lease_Up_Marketing__c',
      'Vacancy_Repairs__c',
      'Credit_Loss__c',
      'Annual_Total_Expenses__c',
      'Cap_Ex_Reserves__c',
      'Other_Reserves__c',
      'Annual_NOI__c',
      'Property_Manager__c',
      'Existing_Debt__c',
      'Current_Interest_Rate__c',
      'Are_Payments_Current__c',
      'Refinance_Acquisition__c',
      'ALA__c'
    };

    String queryString = 'SELECT Id, ';
    for (String field : termFields) {
      queryString += field + ', ';
    }

    queryString = queryString.subStringBeforeLast(',');
    queryString += ' FROM Property__c WHERE Deal__c =\'' + recordId + '\'';

    if (filter == null || filter == 'excludeParent') {
      queryString += ' AND Is_Parent__c = false AND Status__c = \'Active\' ';
      queryString += ' ORDER BY Property_Name__c ASC';
    } else if (filter == 'excludeParent') {
      //
      queryString += ' AND Is_Parent__c = false AND Status__c = \'Active\'';
      queryString += ' ORDER BY Property_Name__c ASC';
    } else if (filter == 'excludeSubUnit') {
      queryString += ' AND Is_Sub_Unit__c = false AND Status__c = \'Active\'';
      queryString += ' ORDER BY Property_Name__c Name ASC';
    }

    if (checkAccess(recordId)) {
      return JSON.serialize(Database.query(queryString));
    } else {
      return null;
    }
  }

  @AuraEnabled
  public static string getTemplate(String templateName) {
    if (templateName == 'TermDataTape') {
      return JSON.serialize(
        [
          SELECT Id, Body
          FROM StaticResource
          WHERE Name = 'CoreVestPortalTermDataTape'
        ]
        .Body
      );
    } else {
      return null;
    }
  }
}