public class oppchatterhelper {
    
    public static boolean afterupdateran = false;
    
    public static void AfterInsert(List<FeedItem> newList, List<FeedItem> oldList) 
    {
        List<FeedItem>  newfeeditem = new List<FeedItem>();
        List<deal_chatter_deal_approval_chatter_link__c> newChtrLinkList = new List<deal_chatter_deal_approval_chatter_link__c>();
        for (FeedItem fI :newList )
        {
        	System.debug('FI.Parent_Id__c :' +fI.ParentId);
       		List<Custom_Chatter_Mapping__c> custChatList = [SELECT Deal__c FROM Custom_Chatter_Mapping__c where id = :fI.ParentId Limit 1 ];

       		if (CustChatList.size() > 0)
       		{
              	FeedItem newFI = new FeedItem();
                deal_chatter_deal_approval_chatter_link__c newChtrLink = new deal_chatter_deal_approval_chatter_link__c();
                newFI.Type	=	fI.Type;
                newFI.Title = fI.Title;
                newFI.LinkUrl = fI.LinkUrl;
                newFI.RelatedRecordId = fI.RelatedRecordId;
                newFI.NetworkScope = fI.NetworkScope;
                newFI.Visibility = fI.Visibility;
                newFI.Body = fI.Body;
                newFI.IsRichText = fI.IsRichText;
                newFI.ParentId = custChatList[0].Deal__c;
                newfeeditem.add(newFI);
                newChtrLink.Deal_Approval_Chatter_Id__c = fI.id;
                System.debug('newChtrLink.Deal_Approval_Chatter_Id__c :' +newChtrLink.Deal_Approval_Chatter_Id__c);
                newChtrLinkList.add(newChtrLink);
            }   
        }
        
        If (newfeeditem.size() > 0)
        {
            Database.insert(newfeeditem,false);
            
		    for (Integer i = 0; i < newfeeditem.size();i++)
            {
            newChtrLinkList[i].DealChatterId__c = newfeeditem[i].id;
            newChtrLinkList[i].is_chatter_related__c = true;
			System.debug('newChtrLink[i].DealChatterId__c :' +newChtrLinkList[i].DealChatterId__c);
            }            
        }        

        if (newChtrLinkList.size() > 0)
        {
        Database.insert(newChtrLinkList,false);
        }
    }

    public static void AfterUpdate( List<FeedItem> newList, List<FeedItem> oldList) 
    {
        List<FeedItem>  newfeeditem = new List<FeedItem>();
        id processingId;
        
        if (!afterupdateran)
        {
        for (FeedItem fI :newList )
        {
        	System.debug('fI.id :' +fI.id);
            System.debug('fI.Body :' +fI.Body);
            afterupdateran = true;
            List<deal_chatter_deal_approval_chatter_link__c> newChtrLinkList = [SELECT DealChatterId__c, Deal_Approval_Chatter_Id__c 
                                                                                FROM deal_chatter_deal_approval_chatter_link__c WHERE is_chatter_related__c = true and DealChatterId__c = :fI.id Limit 1];
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
                    system.debug('This is a approval id and the deal id is' +newChtrLinkList[0].DealChatterId__c);
                    processingId = newChtrLinkList[0].DealChatterId__c;
                }
            }

       		if (newChtrLinkList.size() > 0)
       		{
                
			for(FeedItem fIInside :[SELECT Id,Body,Type,Title,LinkUrl,RelatedRecordId,NetworkScope,Visibility,IsRichText 
                                     FROM FeedItem where Id = :processingId] )
            {
                fIInside.Title 				= fI.Title;
                fIInside.Body 				= fI.Body;
                fIInside.IsRichText 		= fI.IsRichText;
                newfeeditem.add(fIInside);
            }
			}
        }
        If (newfeeditem.size() > 0)
        {
            Database.Update(newfeeditem,false);
        }          
    }
    }

    public static void BeforeDelete(List<FeedItem> oldList) 
    {
        List<FeedItem>  newfeeditem = new List<FeedItem>();
         List<deal_chatter_deal_approval_chatter_link__c> newChtrLinkDelList = new List<deal_chatter_deal_approval_chatter_link__c>();
        id processingId,DeleteId;
        
        for (FeedItem fI :oldList )
        {
        	System.debug('fI.id :' +fI.id);
            List<deal_chatter_deal_approval_chatter_link__c> newChtrLinkList = [SELECT id,DealChatterId__c, Deal_Approval_Chatter_Id__c 
                                                                                FROM deal_chatter_deal_approval_chatter_link__c WHERE is_chatter_related__c = true 
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
			for(FeedItem fIInside :[SELECT Id,Body,Type,Title,LinkUrl,RelatedRecordId,NetworkScope,Visibility,IsRichText 
                                     FROM FeedItem where Id = :processingId] )
            {
                deal_chatter_deal_approval_chatter_link__c newChtrLink = new deal_chatter_deal_approval_chatter_link__c();
                newfeeditem.add(fIInside);
                newChtrLink.id = DeleteId;
                newChtrLinkDelList.add(newChtrLink);
            }
			}
        }
        If (newfeeditem.size() > 0)
        {
            Database.delete(newfeeditem,false);
        }    
        If (newChtrLinkDelList.size() > 0)
        {
            Database.delete(newChtrLinkDelList,false);
        }        
    }
}