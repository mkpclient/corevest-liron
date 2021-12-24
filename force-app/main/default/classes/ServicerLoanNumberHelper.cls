public without sharing class ServicerLoanNumberHelper {
  // @future
  // public static void assignLoanNumbers(Set<Id> opportunityIds){
  //     Integer numberOfIds = opportunityIds.size();

  //     List<Id> oppIds = new List<Id>(opportunityIds);

  //     List<Servicer_Loan_Number__c> loanNumbers = [SELECT Id, Loan_Number__c, Deal__c FROM Servicer_Loan_Nunmber__c WHERE Deal__c = null LIMIT: oppIds.size()];

  //     for(Integer i = 0; i < oppIds.size(); i++){
  //         loanNumbers[i].Deal__c = oppIds[i];
  //     }

  //     if(loanNumbers.size () > 0){
  //         update loanNumbers;
  //     }

  // }

  public static void assignLoanNumbers(List<Opportunity> opps) {
    List<Servicer_Loan_Number__c> loanNumbers = [
      SELECT Id, Servicer_Name__c, Loan_Number__c, Deal__c
      FROM Servicer_Loan_Number__c
      WHERE Deal__c = NULL
      ORDER BY Loan_Number__c ASC
      LIMIT :opps.size()
    ];

    List<Servicer_Loan_Number__c> numbersToUpdate = new List<Servicer_Loan_Number__c>();

    for (Integer i = 0; i < opps.size(); i++) {
      if (i < loanNumbers.size()) {
        loanNumbers[i].Deal__c = opps[i].Id;
        opps[i].Servicer_Commitment_Id__c = loanNumbers[i].Loan_Number__c;
        opps[i].Servicer_Name__c = loanNumbers[i].Servicer_Name__c;
        // numbersToUpdate.add()
      }
    }

    if (loanNumbers.size() > 0) {
      update loanNumbers;
      if (
        [
          SELECT Id, Servicer_Name__c, Loan_Number__c, Deal__c
          FROM Servicer_Loan_Number__c
          WHERE Deal__c = NULL
        ]
        .size() == 0
      ) {
        sendNotificationEmail();
      }
    } else {
      sendNotificationEmail();
    }
  }

  @future
  public static void sendNotificationEmail() {
    //to Lorielle.Bendixen@berkadia.com;Peter.Fiss@berkadia.com
    //cc sokun.soun@cvest.com;cj.suzuki@cvest.com;suzanne.nguyen@cvest.com;micaela.lumpkin@cvest.com;aileen.fallis@cvest.com;support@cvest.com

    Settings__mdt setting = [
      SELECT Id, berkadia_to_emails__c, berkadia_cc_emails__c
      FROM settings__mdt
      WHERE developername = 'Universal_Settings'
      LIMIT 1
    ];

    Id templateId = [
      SELECT Id
      FROM EmailTemplate
      WHERE Name = 'Berkadia Servicer Loan Number Template'
      LIMIT 1
    ]
    .Id;
    Id orgEmailId = [
      SELECT Id, Address
      FROM OrgWideEmailAddress
      WHERE Address = 'integrations@cvest.com'
      LIMIT 1
    ]
    .Id;
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

    // List<String> toAddress = new List<String>();
    // List<String> fromAddress = new List<String>();
    if (String.isNotBlank(setting.Berkadia_To_Emails__c)) {
      List<String> toAddress = setting.Berkadia_To_Emails__c.split(';');
      email.setToAddresses(toAddress);
    }

    if (String.isNotBlank(setting.Berkadia_CC_Emails__c)) {
      List<String> ccAddress = setting.Berkadia_CC_Emails__c.split(';');
      email.setCcAddresses(ccAddress);
    }

    email.setTemplateId(templateId);
    email.setOrgWideEmailAddressId(orgEmailId);
    email.setTargetObjectId(UserInfo.getUserId());
    email.setSaveAsActivity(false);
    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
  }
}