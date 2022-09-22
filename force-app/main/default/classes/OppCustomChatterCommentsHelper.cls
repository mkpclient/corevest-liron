public class OppCustomChatterCommentsHelper {
    
  public static boolean afterupdateran = false;
  public static boolean afterInsertran = false;
  public static boolean afterdeleteran = false;

  public static void AfterInsert(
    List<FeedComment> newList,
    List<FeedComment> oldList
  ) {
    List<FeedComment> newFeedComment = new List<FeedComment>();
    List<deal_chatter_deal_approval_chatter_link__c> newChtrLinkList = new List<deal_chatter_deal_approval_chatter_link__c>();
    id processingId;

    if (!afterInsertran) {
      afterInsertran = true;
      for (FeedComment fI : newList) {
        List<deal_chatter_deal_approval_chatter_link__c> oldChtrLinkList = [
          SELECT DealChatterId__c
          FROM deal_chatter_deal_approval_chatter_link__c
          WHERE Deal_Approval_Chatter_Id__c = :fI.FeedItemId
          LIMIT 1
        ];
        if (oldChtrLinkList.size() > 0) {
          processingid = oldChtrLinkList[0].DealChatterId__c;
        } else {
          oldChtrLinkList = [
            SELECT Deal_Approval_Chatter_Id__c
            FROM deal_chatter_deal_approval_chatter_link__c
            WHERE DealChatterId__c = :fI.FeedItemId
            LIMIT 1
          ];
          if (oldChtrLinkList.size() > 0) {
            processingId = oldChtrLinkList[0].Deal_Approval_Chatter_Id__c;
          }
        }

        if (oldChtrLinkList.size() > 0) {
          FeedComment newFI = new FeedComment();
          deal_chatter_deal_approval_chatter_link__c newChtrLink = new deal_chatter_deal_approval_chatter_link__c();
          newFI.CommentType = fI.CommentType;
          newFI.FeedItemId = processingId;
          newFI.CommentBody = fI.CommentBody;
          newFI.IsRichText = fI.IsRichText;
          newFI.Status = fI.Status;
          newFeedComment.add(newFI);
          newChtrLink.Deal_Approval_Chatter_Id__c = fI.id;
          newChtrLinkList.add(newChtrLink);
        }
      } //for

      if (newFeedComment.size() > 0) {
        Database.insert(newFeedComment, false);
        for (Integer i = 0; i < newFeedComment.size(); i++) {
          newChtrLinkList[i].DealChatterId__c = newFeedComment[i].id;
          newChtrLinkList[i].is_chatter_related__c = false;
        }
      }

      if (newChtrLinkList.size() > 0) {
        Database.insert(newChtrLinkList, false);
      }
    } //did the Insert ran before
  } //afterInsert method

  /////////////////////////////////////////////////////////////////////
  public static void AfterUpdate(
    List<FeedComment> newList,
    List<FeedComment> oldList
  ) {
    List<FeedComment> newFeedComment = new List<FeedComment>();
    id processingId;

    if (!afterupdateran) {
      afterupdateran = true;
      for (FeedComment fI : newList) {
        List<deal_chatter_deal_approval_chatter_link__c> newChtrLinkList = [
          SELECT DealChatterId__c, Deal_Approval_Chatter_Id__c
          FROM deal_chatter_deal_approval_chatter_link__c
          WHERE is_chatter_related__c = FALSE AND DealChatterId__c = :fI.id
          LIMIT 1
        ];
        if (newChtrLinkList.size() > 0) {
          processingId = newChtrLinkList[0].Deal_Approval_Chatter_Id__c;
        }

        if (!(newChtrLinkList.size() > 0)) {
          newChtrLinkList = [
            SELECT DealChatterId__c, Deal_Approval_Chatter_Id__c
            FROM deal_chatter_deal_approval_chatter_link__c
            WHERE Deal_Approval_Chatter_Id__c = :fI.id
            LIMIT 1
          ];

          if (newChtrLinkList.size() > 0) {
            processingId = newChtrLinkList[0].DealChatterId__c;
          }
        }

        if (newChtrLinkList.size() > 0) {
          for (FeedComment fIInside : [
            SELECT CommentBody, CommentType, IsRichText, Status
            FROM FeedComment
            WHERE Id = :processingId
          ]) {
            fIInside.CommentBody = fI.CommentBody;
            fIInside.IsRichText = fI.IsRichText;
            fIInside.Status = fI.Status;
            newFeedComment.add(fIInside);
          }
        }
      } //first for
      if (newFeedComment.size() > 0) {
        Database.Update(newFeedComment, false);
      }
    }
  }
  /////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////
  public static void BeforeDelete(List<FeedComment> oldList) {
    List<FeedComment> newFeedComment = new List<FeedComment>();
    List<deal_chatter_deal_approval_chatter_link__c> newChtrLinkDelList = new List<deal_chatter_deal_approval_chatter_link__c>();
    id processingId, DeleteId;
    if (!afterdeleteran) {
      afterdeleteran = true;
      for (FeedComment fI : oldList) {
        List<deal_chatter_deal_approval_chatter_link__c> newChtrLinkList = [
          SELECT id, DealChatterId__c, Deal_Approval_Chatter_Id__c
          FROM deal_chatter_deal_approval_chatter_link__c
          WHERE is_chatter_related__c = FALSE AND DealChatterId__c = :fI.id
          LIMIT 1
        ];
        if (newChtrLinkList.size() > 0) {
          DeleteId = newChtrLinkList[0].id;
          processingId = newChtrLinkList[0].Deal_Approval_Chatter_Id__c;
        }

        if (!(newChtrLinkList.size() > 0)) {
          newChtrLinkList = [
            SELECT id, DealChatterId__c, Deal_Approval_Chatter_Id__c
            FROM deal_chatter_deal_approval_chatter_link__c
            WHERE Deal_Approval_Chatter_Id__c = :fI.id
            LIMIT 1
          ];

          if (newChtrLinkList.size() > 0) {
            DeleteId = newChtrLinkList[0].id;
            processingId = newChtrLinkList[0].DealChatterId__c;
          }
        }

        if (newChtrLinkList.size() > 0) {
          for (FeedComment fIInside : [
            SELECT Id
            FROM FeedComment
            WHERE Id = :processingId
          ]) {
            deal_chatter_deal_approval_chatter_link__c newChtrLink = new deal_chatter_deal_approval_chatter_link__c();
            newFeedComment.add(fIInside);
            newChtrLink.id = DeleteId;
            newChtrLinkDelList.add(newChtrLink);
          }
        }
      } //first for

      if (newFeedComment.size() > 0) {
        Database.delete(newFeedComment, false);
      }

      if (newChtrLinkDelList.size() > 0) {
        Database.delete(newChtrLinkDelList, false);
      }
    }
  }
}