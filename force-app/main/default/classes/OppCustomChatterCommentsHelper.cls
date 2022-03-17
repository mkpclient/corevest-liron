public class OppCustomChatterCommentsHelper 
{
    
    public static boolean afterupdateran = false;
    
    public static void AfterInsert(List<FeedComment> newList, List<FeedComment> oldList) 
    {
      /*  List<FeedComment>  newfeeditem = new List<FeedComment>();
        List<deal_chatter_deal_approval_chatter_link__c> newChtrLinkList = new List<deal_chatter_deal_approval_chatter_link__c>();
        for (FeedComment fI :newList )
        {
        	System.debug('FI.Parent_Id__c :' +FI.ParentId);
       		List<Custom_Chatter_Mapping__c> custChatList = [SELECT Deal__c FROM Custom_Chatter_Mapping__c where id = :FI.ParentId Limit 1 ];

       		if (CustChatList.size() > 0)
       		{
              	FeedComment newFI = new FeedComment();
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
        }*/
    }

    public static void AfterUpdate( List<FeedComment> newList, List<FeedComment> oldList) 
    {
       /* List<FeedComment>  newfeeditem = new List<FeedComment>();
        id processingId;
        
        if (!afterupdateran)
        {
        for (FeedComment fI :newList )
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
                
			for(FeedComment fIInside :[SELECT Id,Body,Type,Title,LinkUrl,RelatedRecordId,NetworkScope,Visibility,IsRichText 
                                     FROM FeedComment where Id = :processingId] )
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
    }*/
    }

    public static void BeforeDelete(List<FeedComment> oldList) 
    {
      /*  List<FeedComment>  newfeeditem = new List<FeedComment>();
        for (FeedComment FI :oldList )
        {
        	System.debug('FI.Parent_Id__c :' +FI.ParentId);
            System.debug('FI.Body :' +FI.Body);
       		List<Custom_Chatter_Mapping__c> CustChatList = [SELECT Deal__c FROM Custom_Chatter_Mapping__c where id = :FI.ParentId Limit 1 ];
			System.debug('CustChatList[0].Deal__c :' +CustChatList[0].Deal__c);
       		if (CustChatList.size() > 0)
       		{
			for(FeedComment FIInside :[SELECT Id,Body,Type,Title,LinkUrl,RelatedRecordId,NetworkScope,Visibility,IsRichText 
                                     FROM FeedComment where ParentId = :CustChatList[0].Deal__c] )
            {
                System.debug('FIInside.Body :' +FIInside.Body);
              if (FIInside.Body == FI.Body)
              {
                newfeeditem.add(FIInside);
              }
            }
			 If (newfeeditem.size() > 0)
            {
            	Database.delete(newfeeditem,false);
            }            
            }//for
        } */
    }    

}