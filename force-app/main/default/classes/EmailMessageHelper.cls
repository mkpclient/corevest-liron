public class EmailMessageHelper {
    public static void afterInsert(List<EmailMessage> emMessage){

//list<id> oppId = new list<id>();
//list<opportunity> oppToUpdate = new list<opportunity>();
//list<opportunity> finalOppsToUpdate = new list<opportunity>();

list<id> propId = new list<id>();
list<Property__c> propToUpdate = new list<Property__c>();
list<Property__c> finalPropToUpdate = new list<Property__c>();

        
list<id> advanceId = new list<id>();
list<Advance__c> advanceToUpdate = new list<Advance__c>();
list<Advance__c> finalAdvanceToUpdate = new list<Advance__c>();
        
//String opp_prefix = Schema.SObjectType.Opportunity.getKeyPrefix();
String prop_prefix = Schema.SObjectType.Property__c.getKeyPrefix();
String advance_prefix = Schema.SObjectType.Advance__c.getKeyPrefix();


    
    for(EmailMessage em : emMessage){
        if(em.Subject !=null && em.RelatedToId!=null){
        /*if(em.Subject !=null &&((String)em.RelatedToId).startsWith(opp_prefix)){
        String changeCase = em.Subject.toLowerCase().replace('-',' ');

        if (em.RelatedToId!=null && em.Subject !=null  && changeCase.Contains('kick off')){
            oppId.add(em.RelatedToId);
            System.debug(oppId.size());
        }
        }*/

         if(em.Subject !=null &&((String)em.RelatedToId).startsWith(prop_prefix) && em.HtmlBody.Contains('Title Company:') && em.HtmlBody.Contains('Title Contact Name:') && em.HtmlBody.Contains('Appraisal Order Date:') ){
            propId.add(em.RelatedToId);

            }
            
         else if (em.Subject !=null &&((String)em.RelatedToId).startsWith(advance_prefix) && em.Subject.Contains('Funding Conditions -')) {
            advanceId.add(em.RelatedToId);

        }
        }
    }
    
    
   /* oppToUpdate = [SELECT id, Kickoff_Date__c FROM opportunity WHERE Kickoff_Date__c =null AND id IN:oppId ];
                System.debug(oppToUpdate.size());*/

    /*for(Opportunity opp:oppToUpdate){
        opp.Kickoff_Date__c = date.today();
	finalOppsToUpdate.add(opp);
    }
        if(finalOppsToUpdate.size()>0){
            update finalOppsToUpdate;
        }*/

propToUpdate = [SELECT id, Title_Review_Order_Date__c FROM Property__c WHERE Title_Review_Order_Date__c =null AND id IN:propId ];
        System.debug(propToUpdate.size());

for(Property__c prop :propToUpdate){
    prop.Title_Review_Order_Date__c = date.today();
    finalPropToUpdate.add(prop);
}
if(finalPropToUpdate.size()>0){
    update finalPropToUpdate;
}

        
advanceToUpdate = [SELECT id, Funding_Conditions_Email_Date__c  FROM Advance__c WHERE Funding_Conditions_Email_Date__c =null AND id IN:advanceId ];
        System.debug(advanceToUpdate.size());
        
for(Advance__c adv :advanceToUpdate){
    adv.Funding_Conditions_Email_Date__c = date.today();
    finalAdvanceToUpdate.add(adv);
}
if(finalAdvanceToUpdate.size()>0){
    update finalAdvanceToUpdate;
}
}
}