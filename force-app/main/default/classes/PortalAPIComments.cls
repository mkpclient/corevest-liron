@RestResource(urlMapping='/portal/comments/*')
global without sharing class PortalAPIComments {
  public static Integer paginationStart;
  public static Integer paginationEnd;
  public static Boolean usePagination;

  public static String portalId;
  public static String contactId;
  public static String leadId;

  public static Set<Id> dealIds;

  public static PortalAPIUser.PortalUser user;

  @HttpPost
  global static void doPost() {
    RestRequest req = RestContext.request;
    RestResponse res = Restcontext.response;

    //system.debug(req.requestBody.toString());

    List<String> params = Restcontext.request.requestURI.split('/');

    system.debug(Restcontext.request.requestURI);
    system.debug(params);
    if (params.size() == 4) {
      String action = params[3];

      Boolean flag = action == 'unread';

      List<Object> commentIds = (List<Object>) System.JSON.deserializeUntyped(
        req.requestBody.toString()
      );

      List<Comment__c> comments = new List<Comment__c>();
      for (Object commentId : commentIds) {
        comments.add(new Comment__c(Id = (Id) commentId, Unread__c = flag));
      }

      update comments;

      Map<String, String> responseBody = new Map<String, String>();
      responseBody.put('status', 'success');
      responseBody.put('message', '');
      res.addHeader('Content-Type', 'application/json');
      res.responseBody = Blob.valueOf(JSON.serialize(responseBody, true));
    } else {
      Map<String, Object> body = (Map<String, Object>) System.JSON.deserializeUntyped(
        req.requestBody.toString()
      );

      String portalUserId = (String) body.get('userId');

      String contactId = AlchemyAPI.getContactIdByAlchemyId(portalUserId);
      String leadId = AlchemyAPI.getLeadIdByAlchemyId(portalUserId);

      if (contactId != null || leadId != null) {
        //   Id propertyId = body.get('propertyId');
        //   Id dealId = body.get('dealId');
        //   Id documentId = body.get('documentId');

        Comment__c comment = new Comment__c();
        comment.Deal__c = (Id) body.get('loanId');
        comment.Property__c = (Id) body.get('propertyId');
        comment.Application__c = (Id) body.get('applicationId');
        comment.Deal_Document__c = (Id) body.get('documentId');
        comment.Contact__c = contactId;
        comment.Lead__c = leadId;
        comment.Body__c = (String) body.get('body');
        comment.Alchemy_Portal_Id__c = portalUserId;
        comment.Checklist_Item__c = (Id) body.get('itemId');
        if (body.containsKey('commentId')) {
          comment.Comment__c = (String) body.get('commentId');
        }
        comment.Subject__c = (String) body.get('subject');

        insert comment;

        Map<String, String> responseBody = new Map<String, String>();
        responseBody.put('status', 'success');
        responseBody.put('message', 'Comment successfully inserted');

        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(responseBody, true));
      } else {
        Map<String, String> responseBody = new Map<String, String>();
        responseBody.put('status', 'error');
        responseBody.put('message', 'User Id not found');

        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(responseBody, true));
      }
    }
  }

  @HttpGet
  global static void doGet() {
    RestRequest req = RestContext.request;
    RestResponse res = Restcontext.response;

    List<String> params = Restcontext.request.requestURI.split('/');

    String commentType = params[3];

    List<Comment__c> comments = new List<Comment__c>();

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

    if (
      commentType == 'loanId' ||
      commentType == 'propertyId' ||
      commentType == 'propertyId' ||
      commentType == 'applicationId' ||
      commentType == 'documentId' ||
      commentType == 'userId' ||
      commentType == 'itemId'
    ) {
      if (commentType == 'loanId') {
        Id dealId = params[4];
        comments = getCommentsByDealId(dealId);
      } else if (commentType == 'propertyId') {
        Id propertyId = params[4];
        comments = getCommentsByPropertyId(propertyId);
      } else if (commentType == 'applicationId') {
        Id applicationId = params[4];
      } else if (commentType == 'documentId') {
        Id documentId = params[4];
        comments = getCommentsByDocumentId(documentId);
      } else if (commentType == 'userId') {
        String userId = params[4];
        comments = getCommentsByUserId(userId);
      } else if (commentType == 'itemId') {
        String itemId = params[4];
        comments = getCommentsByItemId(itemId);
      }

      List<Comment> commentsList = new List<Comment>();

      for (Comment__c comment : comments) {
        commentsList.add(new Comment(comment));
      }

      res.responseBody = Blob.valueOf(JSON.serialize(commentsList, true));
      res.addHeader('Content-Type', 'application/json');
    } else {
      String idField = params[3];

      if (!idField.contains('-')) {
        Id commentId = params[3];

        List<Comment> singleComment = getComment(commentId);
        res.responseBody = Blob.valueOf(JSON.serialize(singleComment));
        res.addHeader('Content-Type', 'application/json');
      } else {
        portalId = params[3];
        //contactId = AlchemyAPI.getContactIdByAlchemyId(portalId);
        //leadId = AlchemyAPI.getLeadIdByAlchemyId(portalId);
        user = new PortalAPIUser.PortalUser(portalId);
        contactId = user.contactId;
        leadId = user.leadId;
        if (contactId != null) {
          dealIds = AlchemyAPI.getDealIds(user);
          //dealIds = AlchemyAPI.getDealIdsContactId(contactId);
        }

        //system.debug(params[4]);

        if (contactId != null || leadId != null) {
          if (params[4] == 'picklists') {
            String picklistType = params[5];
            system.debug(dealIds);
            List<Map<String, String>> picklists = new List<Map<String, String>>();
            if (picklistType == 'loans') {
              picklists = getLoanPicklists();
            } else if (picklistType == 'properties') {
              picklists = getPropertyPicklists();
            } else if (picklistType == 'applications') {
              picklists = getApplicationPicklists();
            }

            Map<String, String> respBody = new Map<String, String>();
            res.addHeader('Content-Type', 'application/json');

            res.responseBody = Blob.valueOf(JSON.serialize(picklists));
          } else if (params[4] == 'all') {
            List<comment> allComments = getAllComments();
            List<Comment> commentsToSend = new List<Comment>();
            if (usePagination) {
              for (Integer i = paginationStart; i < paginationEnd; i++) {
                if (i < allComments.size()) {
                  commentsToSend.add(allComments[i]);
                }
              }
            } else {
              commentsToSend = allComments;
            }

            res.addHeader('Content-Type', 'application/json');

            res.responseBody = Blob.valueOf(JSON.serialize(commentsToSend));
          } else if (params[4] == 'count') {
            List<comment> allComments = getAllComments();

            Map<String, Object> countResponse = new Map<String, Integer>();
            countResponse.put('count', allComments.size());

            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(
              JSON.serialize(countResponse, true)
            );
            res.addHeader('Content-Type', 'application/json');

            res.responseBody = Blob.valueOf(JSON.serialize(countResponse));
          }
        } else {
          Map<String, String> respBody = new Map<String, String>();
          res.addHeader('Content-Type', 'application/json');
          respBody.put('status', 'error');
          respBody.put('message', 'User Id Not Found');
          res.statusCode = 404;
          res.responseBody = Blob.valueOf(JSON.serialize(respBody, true));
        }
      }
    }
  }

  public static List<Comment> getComment(Id commentId) {
    List<Comment> comments = new List<Comment>();
    Comment__c singleComment = [
      SELECT
        Id,
        Deal__c,
        Lead__c,
        Lead__r.Name,
        Contact__r.Name,
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
        (SELECT Id FROM Comments__r ORDER BY CreatedDate ASC),
        Owner_Image__c,
        Application__r.Name,
        Property__r.Name,
        Deal__r.Name,
        Deal_Document__r.Name,
        Checklist_Item__c,
        Unread__c
      FROM Comment__c
      WHERE Id = :commentId
      LIMIT 1
    ];

    comments.add(new Comment(singleComment));

    // if (singleComment.Comments__r.size() > 0) {
    //   comments.addAll(getComment(singleComment.Comments__r[0].Id));
    // }
    for (Comment__c c : singleComment.Comments__r) {
      comments.addAll(getComment(c.Id));
    }

    return comments;
  }

  static List<Comment> getAllComments() {
    Map<Id, Application__c> applications = new Map<Id, Application__c>(
      [SELECT Id, Name FROM Application__c WHERE Alchemy_User_Id__c = :portalId]
    );
    List<Comment__c> allComments = [
      SELECT
        Id,
        Deal__c,
        Lead__c,
        Lead__r.Name,
        Contact__r.Name,
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
        Checklist_Item__c,
        Unread__c
      FROM Comment__c
      WHERE
        Alchemy_Portal_Id__c = :portalId
        AND Comment__c = NULL
        AND (Deal__c IN :dealIds
        OR Property__r.Deal__c IN :dealIds
        OR Deal_Document__c IN :dealIds
        OR Application__c IN :applications.keySet())
      ORDER BY CreatedDate DESC
    ];

    // if (!usePagination) {
    //   paginationStart = 0;
    //   paginationEnd = allComments.size();
    // }

    List<Comment> comments = new List<Comment>();
    // for (Integer i = paginationStart; i < paginationEnd; i++) {
    //   if (i < allComments.size()) {
    //     comments.add(new Comment(allComments[i]));
    //   }
    // }
    for (Integer i = 0; i < allComments.size(); i++) {
      comments.add(new Comment(allComments[i]));
    }

    return comments;
  }

  static List<Map<String, String>> getLoanPicklists() {
    List<Map<String, String>> picklists = new List<Map<String, String>>();
    system.debug(dealIds);
    List<Opportunity> opps = [
      SELECT Id, Deal_Loan_Number__c, Name
      FROM Opportunity
      WHERE Id IN :dealIds
    ];

    if (!usePagination) {
      paginationStart = 0;
      paginationEnd = opps.size();
    }

    for (Integer i = paginationStart; i < paginationEnd; i++) {
      Map<String, String> picklist = new Map<String, String>();
      picklist.put('id', opps[i].Id);
      picklist.put('name', opps[i].Deal_Loan_Number__c + ' - ' + opps[i].Name);

      picklists.add(picklist);
    }

    return picklists;
  }

  static List<Map<String, String>> getPropertyPicklists() {
    List<Map<String, String>> picklists = new List<Map<String, String>>();

    List<Property__c> props = [
      SELECT Id, Asset_ID__c, Name
      FROM Property__c
      WHERE Deal__c IN :dealIds AND Active__c = TRUE
    ];
    if (!usePagination) {
      paginationStart = 0;
      paginationEnd = props.size();
    }

    for (Integer i = paginationStart; i < paginationEnd; i++) {
      Map<String, String> picklist = new Map<String, String>();
      picklist.put('id', props[i].Id);
      picklist.put('name', props[i].Asset_ID__c + ' - ' + props[i].Name);

      picklists.add(picklist);
    }

    return picklists;
  }

  static List<Map<String, String>> getApplicationPicklists() {
    List<Map<String, String>> picklists = new List<Map<String, String>>();

    List<Application__c> apps = [
      SELECT Id, Name
      FROM Application__c
      WHERE Alchemy_User_Id__c = :portalId
    ];

    if (!usePagination) {
      paginationStart = 0;
      paginationEnd = apps.size();
    }

    for (Integer i = paginationStart; i < paginationEnd; i++) {
      Map<String, String> picklist = new Map<String, String>();
      picklist.put('id', apps[i].Id);
      picklist.put('name', apps[i].Name);

      picklists.add(picklist);
    }

    return picklists;
  }

  public static List<Comment__c> getCommentsByDealId(Id dealId) {
    return [
      SELECT
        Id,
        Deal__c,
        Lead__c,
        Lead__r.Name,
        Contact__r.Name,
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
        Checklist_item__c,
        Checklist_Item__r.Name
      FROM Comment__c
      WHERE Deal__c = :dealId
      ORDER BY CreatedDate DESC
    ];
  }

  public static List<Comment__c> getCommentsByItemId(Id itemId) {
    return [
      SELECT
        Id,
        Deal__c,
        Lead__c,
        Lead__r.Name,
        Contact__r.Name,
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
        Checklist_Item__c,
        Checklist_Item__r.Name
      FROM Comment__c
      WHERE Checklist_Item__c = :itemId
      ORDER BY CreatedDate DESC
    ];
  }

  static List<Comment__c> getCommentsByPropertyId(Id propertyId) {
    return [
      SELECT
        Id,
        Deal__c,
        Lead__c,
        Lead__r.Name,
        Contact__r.Name,
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
        Checklist_item__c,
        Checklist_Item__r.Name
      FROM Comment__c
      WHERE Property__c = :propertyId
      ORDER BY CreatedDate DESC
    ];
  }

  static List<Comment__c> getCommentsByApplicationId(Id applicationId) {
    return [
      SELECT
        Id,
        Deal__c,
        Lead__c,
        Lead__r.Name,
        Contact__r.Name,
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
        Checklist_item__c,
        Checklist_Item__r.Name
      FROM Comment__c
      WHERE Application__c = :applicationId
      ORDER BY CreatedDate DESC
    ];
    //   List<String> params = Restcontext.request.requestURI.split('/');
  }

  static List<Comment__c> getCommentsByDocumentId(Id documentId) {
    return [
      SELECT
        Id,
        Deal__c,
        Lead__c,
        Lead__r.Name,
        Contact__r.Name,
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
        Checklist_item__c,
        Checklist_Item__r.Name
      FROM Comment__c
      WHERE Deal_Document__c = :documentId
      ORDER BY CreatedDate DESC
    ];
  }

  static List<Comment__c> getCommentsByUserId(String portalUserId) {
    String contactId = AlchemyAPI.getContactIdByAlchemyId(portalUserId);
    String leadId = AlchemyAPI.getLeadIdByAlchemyId(portalUserId);

    return [
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
        Checklist_item__c,
        Checklist_Item__r.Name
      FROM Comment__c
      WHERE
        (Lead__c = :leadId
        OR Contact__c = :contactId)
        AND Deal__c = NULL
        AND Property__c = NULL
        AND Deal_Document__c = NULL
        AND Application__c = NULL
      ORDER BY CreatedDate DESC
    ];
  }

  public class Comment {
    @AuraEnabled
    public String body;
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String propertyId;
    @AuraEnabled
    public String loanId;
    @AuraEnabled
    public String title;
    @AuraEnabled
    public String commentId;
    // String userId;
    // String contactId;
    @AuraEnabled
    public String documentId;
    @AuraEnabled
    public String submitterId;
    @AuraEnabled
    public String leadId;
    @AuraEnabled
    public String submitterName;
    @AuraEnabled
    public String applicationId;
    @AuraEnabled
    public String subject;
    @AuraEnabled
    public DateTime commentDate;
    @AuraEnabled
    public String profileImg;
    @AuraEnabled
    public String loanName;
    @AuraEnabled
    public String propertyName;
    @AuraEnabled
    public String applicationName;
    @AuraEnabled
    public String documentName;
    @AuraEnabled
    public Boolean isUnread = false;
    @AuraEnabled
    public String itemId;

    public Comment(Comment__c comment) {
      this.body = comment.Body__c;
      this.id = comment.Id;
      this.propertyId = comment.Property__c;
      this.loanId = comment.Deal__c;
      this.applicationId = comment.Application__c;
      this.documentId = comment.Deal_Document__c;
      this.commentDate = comment.CreatedDate;
      this.commentId = comment.Comment__c;
      this.isUnread = comment.Unread__c;
      if (comment.Submitted_From_Portal__c) {
        this.submitterId = comment.Alchemy_Portal_Id__c;

        if (comment.Contact__c != null) {
          this.submitterName = comment.Contact__r.Name;
        } else if (comment.Lead__c != null) {
          this.submitterName = comment.Lead__r.Name;
        }
      } else {
        this.submitterId = comment.OwnerId;
        this.submitterName = comment.Owner.Name;
        if (String.isBlank(comment.Owner_Image__c)) {
          this.profileImg = 'https://cvest--alchemy.my.salesforce.com/file-asset-public/default?oid=00DZ0000009T6aH'; //comment.Owner_Image__c;
        } else {
          this.profileImg = comment.Owner_Image__c;
        }
      }

      if (String.isNotBlank(this.body)) {
        this.body = this.body.replaceAll('&amp;', '&');
      }

      this.commentId = comment.Id;
      this.subject = comment.Subject__c;

      if (String.isNotBlank(this.body)) {
        this.body = this.body.replaceAll('&amp;', '&');
      }

      this.applicationName = comment.Application__r.Name;
      this.loanName = comment.Deal__r.Name;
      this.propertyName = comment.Property__r.Name;
      this.documentName = comment.Deal_Document__r.Name;
      this.itemId = comment.Checklist_Item__c;
    }
  }
}