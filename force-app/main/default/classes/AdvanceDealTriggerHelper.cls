public without sharing class AdvanceDealTriggerHelper {
  static final string VALIDADVSTATUS = 'Completed';
  static final string VALIDCALCULATIONTYPE = 'Fixed at First Advance';
  static final string FIRSTCONTACTTYPE = 'Individual';
  static final string ENTITYTYPE = 'Guarantor';
  static final string SECONDCONTACTTYPE = 'Vendor';
  static final string VENDORTYPE = 'Lender Legal Counsel';
  static final List<String> TEAMROLES = new List<String>{
    'Closer',
    'Originator',
    'Sales Analyst'
  };
  static final List<String> USERROLES = new List<String>{
    'Post Closing',
    'Post Closing Manager'
  };
  static final String EMAILDEVNAME = 'Maturity_Date_Set_on_Advance_Completion_1629747645098';
  static final string SENDEREMAIL = 'integrations@cvest.com';

  private static Map<Id, Opportunity> getOpportunityForEmail(
    List<Opportunity> opps
  ) {
    return new Map<Id, Opportunity>(
      [
        SELECT
          Id,
          Contact__c,
          (
            SELECT
              Id,
              Contact__r.Email,
              Contact__c,
              Deal_Contact_Type__c,
              Entity_Type__c,
              Vendor_Type__c
            FROM Deal_Contacts__r
            WHERE
              (Deal_Contact_Type__c = :FIRSTCONTACTTYPE
              AND Entity_Type__c = :ENTITYTYPE
              AND Contact__c != NULL)
              OR (Deal_Contact_Type__c = :SECONDCONTACTTYPE
              AND Vendor_Type__c = :VENDORTYPE
              AND Contact__c != NULL)
          ),
          (
            SELECT
              Id,
              TeamMemberRole,
              UserId,
              User.ContactId,
              User.Email,
              User.FirstName,
              User.LastName
            FROM OpportunityTeamMembers
            WHERE TeamMemberRole IN :TEAMROLES
          )
        FROM Opportunity
        WHERE Id IN :opps
      ]
    );
  }

  public static void sendEmailForDealTrigger(
    List<Opportunity> deals,
    Id templateId
  ) {
    Map<Id, Opportunity> opps = getOpportunityForEmail(deals);

    List<OrgWideEmailAddress> owea = [
      SELECT Id
      FROM OrgWideEmailAddress
      WHERE Address = :SENDEREMAIL
    ];

    List<Id> contactIds = new List<Id>();
    List<Id> userIds = new List<Id>();
    List<Id> toIds = new List<Id>();
    List<String> ccEmails = new List<String>();
    List<String> bccEmails = new List<String>();
    // List<Id> allIds = new List<Id>();
    List<Messaging.SingleEmailMessage> allEmails = new List<Messaging.SingleEmailMessage>();

    for (Opportunity opp : opps.values()) {
      Messaging.SingleEmailMessage dealEmail = new Messaging.SingleEmailMessage();

      dealEmail.setTemplateId(templateId);
      dealEmail.setWhatId(opp.Id);
      dealEmail.setSaveAsActivity(false);
      dealEmail.setTargetObjectId(opp.Contact__c);
      dealEmail.setTreatTargetObjectAsRecipient(false);
      bccEmails.add('bryon.harland@cvest.com');

      if (opp.Deal_Contacts__r.size() > 0) {
        for (integer i = 0; i < opp.Deal_Contacts__r.size(); i++) {
          Deal_Contact__c dealContact = opp.Deal_Contacts__r[i];
          // allIds.add(dealContact.Contact__c);
          if (
            dealContact.Deal_Contact_Type__c == FIRSTCONTACTTYPE &&
            dealContact.Entity_Type__c == ENTITYTYPE
          ) {
            if (i == 0) {
              dealEmail.setTargetObjectId(dealContact.Contact__c);
            } else {
              toIds.add(dealContact.Contact__c);
            }
          } else {
            // contactIds.add(dealContact.Contact__c);
            ccEmails.add(dealContact.Contact__r.Email);
          }
        }
      }

      if (opp.OpportunityTeamMembers.size() > 0) {
        for (OpportunityTeamMember teamMember : opp.OpportunityTeamMembers) {
          // userIds.add(teamMember.UserId);
          // allIds.add(teamMember.UserId);
          ccEmails.add(teamMember.User.Email);
        }
      }

      dealEmail.setToAddresses(toIds);
      dealEmail.setCcAddresses(ccEmails);
      dealEmail.setBccAddresses(bccEmails);
      dealEmail.setUseSignature(false);

      if (owea.size() > 0) {
        dealEmail.setOrgWideEmailAddressId(owea.get(0).Id);
      }

      allEmails.add(dealEmail);
    }

    // for (User user : [
    //   SELECT
    //     Id,
    //     FirstName,
    //     LastName,
    //     Email,
    //     isActive,
    //     Profile.Name,
    //     UserRole.Name,
    //     UserType
    //   FROM User
    //   WHERE UserRole.Name IN :USERROLES AND isActive = TRUE AND Email != NULL
    // ]) {
    //   // userIds.add(user.Id);
    //   // allIds.add(user.Id);
    //   ccEmails.add(user.Email);
    // }

    // Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

    // for (Id id : allIds) {
    //   Messaging.SingleEmailMessage newEmail = Messaging.renderStoredEmailTemplate(
    //     templateId,
    //     id,
    //     opp.Id
    //   );
    //   // String emailSubject = newEmail.getSubject();
    //   // String emailTextBody = newEmail.getPlainTextBody();

    //   newEmail.setTargetObjectId(id);
    //   // newEmail.setSubject(emailSubject);
    //   // newEmail.setPlainTextBody(emailTextBody);
    //   newEmail.saveAsActivity = false;

    //   allEmails.add(newEmail);
    // }

    List<Messaging.SendEmailResult> results = Messaging.sendEmail(allEmails);

    // List<Messaging.SendEmailResult> results = Messaging.sendEmail(allEmails);

    if (results[0].success) {
      System.debug('The email was sent successfully : ' + results);
    } else {
      System.debug(
        'The email failed to send:  ' + results[0].errors[0].message
      );
    }
  }

  public static void advanceDealTriggerHelperMethod(
    Map<Id, Advance__c> newMap,
    Map<Id, Advance__c> oldMap
  ) {
    Map<Id, Advance__c> completedAdvances = new Map<Id, Advance__c>();
    Set<Id> completedAdvDeals = new Set<Id>();
    for (Advance__c adv : newMap.values()) {
      if (oldMap.containsKey(adv.Id)) {
        Advance__c oldAdv = oldMap.get(adv.Id);
        if (
          oldAdv.Status__c != adv.Status__c &&
          VALIDADVSTATUS == adv.Status__c
        ) {
          completedAdvances.put(adv.Id, adv);
          completedAdvDeals.add(adv.Deal__c);
        }
      } else if (adv.Status__c == VALIDADVSTATUS) {
        completedAdvances.put(adv.Id, adv);
        completedAdvDeals.add(adv.Deal__c);
      }
    }

    if (completedAdvances.size() > 0) {
      List<Opportunity> deals = [
        SELECT
          Id,
          Maturity_Date_Calculation_Type__c,
          Stated_Maturity_Date__c,
          Advance_Period__c,
          LOC_Term__c,
          CloseDate
        FROM Opportunity
        WHERE
          Id IN :completedAdvDeals
          AND Maturity_Date_Calculation_Type__c = :VALIDCALCULATIONTYPE
          AND Stated_Maturity_Date__c = NULL
        FOR UPDATE
      ];

      System.debug('advance trigger for deal has started');

      if (deals.size() > 0) {
        System.debug('advance trigger for deal has returned the query');
        for (Opportunity updatedDeal : deals) {
          if (updatedDeal.Advance_Period__c != null) {
            updatedDeal.Modified_Expiration_Date__c = updatedDeal.CloseDate
              .addDays(Integer.valueOf(updatedDeal.Advance_Period__c));
          }

          if (!string.isBlank(updatedDeal.LOC_Term__c)) {
            List<String> locTerm = updatedDeal.LOC_Term__c.split(' ');
            Integer locTermNumber = Integer.valueOf(locTerm[0]);
            updatedDeal.Stated_Maturity_Date__c = updatedDeal.CloseDate
              .addDays(locTermNumber);
            updatedDeal.Updated_Loan_Maturity_Date__c = updatedDeal.CloseDate
              .addDays(locTermNumber);
          }
        }

        EmailTemplate tpl = [
          SELECT Id
          FROM EmailTemplate
          WHERE DeveloperName = :EMAILDEVNAME
          LIMIT 1
        ];

        try {
          update deals;
          sendEmailForDealTrigger(deals, tpl.Id);
        } catch (DmlException err) {
          System.debug('deal update on trigger error: ' + err);
        }
      }
    }
  }
}