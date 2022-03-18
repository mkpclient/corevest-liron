public class OppCustomChatterCommentsHelper 
{
    
    public static boolean afterupdateran = false;
    
    public static void AfterInsert(List<FeedComment> newList, List<FeedComment> oldList) 
    {
        List<FeedComment>  newFeedComment= new List<FeedComment>();
        List<deal_chatter_deal_approval_chatter_link__c> newChtrLinkList = new List<deal_chatter_deal_approval_chatter_link__c>();
        
        for (FeedComment fI :newList )
        {
        	System.debug('FI.Parent_Id Thanks  :' +fI.ParentId);
            System.debug('FI.FeedItemId :' +fI.FeedItemId);
            List<deal_chatter_deal_approval_chatter_link__c> oldChtrLinkList = [SELECT DealChatterId__c from deal_chatter_deal_approval_chatter_link__c 
                                                                                where Deal_Approval_Chatter_Id__c =:fI.FeedItemId Limit 1 ];
            
       		List<Custom_Chatter_Mapping__c> custChatList = [SELECT Deal__c FROM Custom_Chatter_Mapping__c where id = :fI.ParentId Limit 1 ];

       		if (CustChatList.size() > 0)
       		{
              	FeedComment newFI = new FeedComment();
                deal_chatter_deal_approval_chatter_link__c newChtrLink = new deal_chatter_deal_approval_chatter_link__c();
                newFI.CommentType		=	fI.CommentType;
 				newFI.FeedItemId		=	oldChtrLinkList[0].DealChatterId__c;	
                //newFI.ParentId			=	custChatList[0].Deal__c;
                newFI.CommentBody		=	fI.CommentBody;
                newFI.IsRichText		=	fI.IsRichText;
                newFI.Status			=	fI.Status;
                newFI.Revision			=	fI.Revision;
                newFeedComment.add(newFI);
                newChtrLink.Deal_Approval_Chatter_Id__c = fI.id;
                System.debug('newChtrLink.Deal_Approval_Chatter_Id__c :' +newChtrLink.Deal_Approval_Chatter_Id__c);
                newChtrLinkList.add(newChtrLink);
            }   
        }
        
        If (newFeedComment.size() > 0)
        {
            Database.insert(newFeedComment,false);
            
		    for (Integer i = 0; i < newFeedComment.size();i++)
            {
            newChtrLinkList[i].DealChatterId__c = newFeedComment[i].id;
            newChtrLinkList[i].is_chatter_related__c = false;
			System.debug('RS999 newChtrLink[i].DealChatterId__c :' +newChtrLinkList[i].DealChatterId__c);
            }            
        }        

        if (newChtrLinkList.size() > 0)
        {
        Database.insert(newChtrLinkList,false);
        }
    }

    public static void AfterUpdate( List<FeedComment> newList, List<FeedComment> oldList) 
    {
        List<FeedComment>  newFeedComment= new List<FeedComment>();
        id processingId;
        
        if (!afterupdateran)
        {
        for (FeedComment fI :newList )
        {
        	System.debug('fI.id :' +fI.id);
            System.debug('fI.CommentBody :' +fI.CommentBody);
            afterupdateran = true;
            List<deal_chatter_deal_approval_chatter_link__c> newChtrLinkList = [SELECT DealChatterId__c, Deal_Approval_Chatter_Id__c 
                                                                                FROM deal_chatter_deal_approval_chatter_link__c WHERE is_chatter_related__c = false
                                                                                and DealChatterId__c = :fI.id Limit 1];
            if (newChtrLinkList.size() > 0)
            {
                system.debug('This is a Deal id and approval id is' +newChtrLinkList[0].Deal_Approval_Chatter_Id__c);
               processingId = newChtrLinkList[0].Deal_Approval_Chatter_Id__c; 
            }
            
       		if (!(newChtrLinkList.size() > 0))
            {
            	newChtrLinkList = [SELECT DealChatterId__c, Deal_Approval_Chatter_Id__c FROM deal_chatter_deal_approval_chatter_link__c 
                                   WHERE Deal_Approval_Chatter_Id__c = :fI.id Limit 1];   

                if (newChtrLinkList.size() > 0)
                {
                    system.debug('This is a approval id and the deal id is' +newChtrLinkList[0].id);
                    processingId = newChtrLinkList[0].DealChatterId__c;
                }
            }

       		if (newChtrLinkList.size() > 0)
       		{
                
			for(FeedComment fIInside :[SELECT   CommentBody, CommentType, IsRichText, Status,  Revision 
                                     FROM FeedComment where Id = :processingId] )
            {
                fIInside.CommentBody	=	fI.CommentBody;
                fIInside.IsRichText		=	fI.IsRichText;
                fIInside.Status			=	fI.Status;
                newFeedComment.add(fIInside);
            }
			}
        }
        If (newFeedComment.size() > 0)
        {
            Database.Update(newFeedComment,false);
        }          
    }
    }

    public static void BeforeDelete(List<FeedComment> oldList) 
    {
        List<FeedComment>  newFeedComment = new List<FeedComment>();
        List<deal_chatter_deal_approval_chatter_link__c> newChtrLinkDelList = new List<deal_chatter_deal_approval_chatter_link__c>();
        id processingId,DeleteId;
        
        for (FeedComment fI :oldList )
        {
        	System.debug('fI.id :' +fI.id);
            List<deal_chatter_deal_approval_chatter_link__c> newChtrLinkList = [SELECT id,DealChatterId__c, Deal_Approval_Chatter_Id__c 
                                                                                FROM deal_chatter_deal_approval_chatter_link__c WHERE is_chatter_related__c = false 
                                                                                and DealChatterId__c = :fI.id Limit 1];
            if (newChtrLinkList.size() > 0)
            {
               system.debug('This is a Deal id and approval id is' +newChtrLinkList[0].id);
               DeleteId = newChtrLinkList[0].id;
               processingId = newChtrLinkList[0].Deal_Approval_Chatter_Id__c; 
            }
            
       		if (!(newChtrLinkList.size() > 0))
            {
            	newChtrLinkList = [SELECT id,DealChatterId__c, Deal_Approval_Chatter_Id__c FROM deal_chatter_deal_approval_chatter_link__c 
                                   WHERE Deal_Approval_Chatter_Id__c = :fI.id Limit 1];   

                if (newChtrLinkList.size() > 0)
                {
                    system.debug('This is a approval id and the deal id is' +newChtrLinkList[0].DealChatterId__c);
                    DeleteId = newChtrLinkList[0].id;
                    processingId = newChtrLinkList[0].DealChatterId__c;
                }
            }

       		if (newChtrLinkList.size() > 0)
       		{
			for(FeedComment fIInside :[SELECT Id FROM FeedComment where Id = :processingId] )
            {
                deal_chatter_deal_approval_chatter_link__c newChtrLink = new deal_chatter_deal_approval_chatter_link__c();
                newFeedComment.add(fIInside);
                newChtrLink.id = DeleteId;
                newChtrLinkDelList.add(newChtrLink);
            }
			}
        }
        If (newFeedComment.size() > 0)
        {
            Database.delete(newFeedComment,false);
        }    
        If (newChtrLinkDelList.size() > 0)
        {
            Database.delete(newChtrLinkDelList,false);
        }        
    }
}