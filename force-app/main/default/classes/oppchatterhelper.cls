public class oppchatterhelper {
    public static void AfterInsert(List<FeedItem> newList, List<FeedItem> oldList) 
    {
        List<FeedItem>  newfeeditem = new List<FeedItem>();
        for (FeedItem FI :newList )
        {
        	System.debug('FI.Parent_Id__c :' +FI.ParentId);
       		List<Custom_Chatter_Mapping__c> CustChatList = [SELECT Deal__c FROM Custom_Chatter_Mapping__c where id = :FI.ParentId Limit 1 ];

       		if (CustChatList.size() > 0)
       		{
              	FeedItem NewFI = new FeedItem();
                NewFI.Type	=	FI.Type;
                NewFI.Title = FI.Title;
                NewFI.LinkUrl = FI.LinkUrl;
                NewFI.RelatedRecordId = FI.RelatedRecordId;
                NewFI.NetworkScope = FI.NetworkScope;
                NewFI.Visibility = FI.Visibility;
                NewFI.Body = FI.Body;
                NewFI.IsRichText = FI.IsRichText;
                NewFI.ParentId = CustChatList[0].Deal__c;
                newfeeditem.add(NewFI);
            }   
            If (newfeeditem.size() > 0)
            {
            	Database.insert(newfeeditem,false);
            }
        }
    }

    public static void AfterUpdate( List<FeedItem> newList, List<FeedItem> oldList) 
    {
        List<FeedItem>  newfeeditem = new List<FeedItem>();
        for (FeedItem FI :newList )
        {
        	System.debug('FI.Parent_Id__c :' +FI.ParentId);
            System.debug('FI.Body :' +FI.Body);
       		List<Custom_Chatter_Mapping__c> CustChatList = [SELECT Deal__c FROM Custom_Chatter_Mapping__c where id = :FI.ParentId Limit 1 ];
			System.debug('CustChatList[0].Deal__c :' +CustChatList[0].Deal__c);
       		if (CustChatList.size() > 0)
       		{
                
			for(FeedItem FIInside :[SELECT Id,Body,Type,Title,LinkUrl,RelatedRecordId,NetworkScope,Visibility,IsRichText 
                                     FROM FeedItem where ParentId = :CustChatList[0].Deal__c] )
            {
                System.debug('FIInside.Body :' +FIInside.Body);
              if (FIInside.Body == FI.Body)
              {
                FIInside.Type				=	FI.Type;
                FIInside.Title 				= FI.Title;
                FIInside.LinkUrl 			= FI.LinkUrl;
                FIInside.RelatedRecordId 	= FI.RelatedRecordId;
                FIInside.NetworkScope 		= FI.NetworkScope;
                FIInside.Visibility 		= FI.Visibility;
                FIInside.Body 				= FI.Body;
                FIInside.IsRichText 		= FI.IsRichText;
                newfeeditem.add(FIInside);
              }
            }
			 If (newfeeditem.size() > 0)
            {
            	Database.Update(newfeeditem,false);
            }            
			}
        }
    }

    public static void BeforeDelete(List<FeedItem> oldList) 
    {
        List<FeedItem>  newfeeditem = new List<FeedItem>();
        for (FeedItem FI :oldList )
        {
        	System.debug('FI.Parent_Id__c :' +FI.ParentId);
            System.debug('FI.Body :' +FI.Body);
       		List<Custom_Chatter_Mapping__c> CustChatList = [SELECT Deal__c FROM Custom_Chatter_Mapping__c where id = :FI.ParentId Limit 1 ];
			System.debug('CustChatList[0].Deal__c :' +CustChatList[0].Deal__c);
       		if (CustChatList.size() > 0)
       		{
			for(FeedItem FIInside :[SELECT Id,Body,Type,Title,LinkUrl,RelatedRecordId,NetworkScope,Visibility,IsRichText 
                                     FROM FeedItem where ParentId = :CustChatList[0].Deal__c] )
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
        }
    }    

}