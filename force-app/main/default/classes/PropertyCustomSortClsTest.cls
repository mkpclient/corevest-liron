@isTest
public class PropertyCustomSortClsTest {


  @isTest		
  static void propertyCustomSortRunTest(){
     test_Helper.createDealLoanNumber();
        Account acc = test_Helper.createAccount();
		Contact cont = test_Helper.createContact( acc );
		Opportunity deal = test_Helper.createOpportunity( acc, cont );
		system.debug('@@deal'+deal);

        Advance__c  ad = new advance__c(name='test',deal__c=deal.id);
        insert ad;
        List<Property__c>lp = new list<Property__c>();
        Property__c pop = new Property__c(name='test',deal__c=deal.id,Advance__c=ad.id);
        lp.add(pop);
        Property__c pop2 = new Property__c(name='12 test',deal__c=deal.id,Advance__c=ad.id);
        lp.add(pop2);
        Property__c pop3 = new Property__c(name='12-1 test',deal__c=deal.id,Advance__c=ad.id);
        lp.add(pop3);
        Property__c pop4 = new Property__c(name='a12 test',deal__c=deal.id,Advance__c=ad.id);
        lp.add(pop4);
        insert(lp);
        PropertyCustomSortCls.getProperty(lp);
      
  }
}