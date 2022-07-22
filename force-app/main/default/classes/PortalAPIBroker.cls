@RestResource(urlMapping='/portal/broker/*')
global without sharing class PortalAPIBroker {
  @HttpPost
  global static void doPost() {
    RestRequest req = RestContext.request;
    RestResponse res = Restcontext.response;

    List<String> params = Restcontext.request.requestURI.split('/');

    Map<String, Object> body = (Map<String, Object>) System.JSON.deserializeUntyped(
      req.requestBody.toString()
    );

    if (params[3] == 'invite') {
      String brokerId = (String) body.get('brokerId');
      String borrowerEmail = (String) body.get('borrowerEmail');
      String borrowerFirstName = (String) body.get('borrowerFirstName');
      String borrowerLastName = (String) body.get('borrowerLastName');
      String companyName;
      if (body.containsKey('borrowerCompany')) {
        companyName = (String) body.get('borrowerCompany');
      }
      String borrowerId = (String) body.get('borrowerId');
      String dealId = (String) body.get('dealId');

      Id applicationId;
      if (body.containsKey('applicationId')) {
        applicationId = (Id) body.get('applicationId');
      }

      if (applicationId != null) {
        Application__c application = [
          SELECT Id, Deal__c
          FROM Application__c
          WHERE Id = :applicationId
          LIMIT 1
        ];

        if (dealId == null) {
          dealId = application.Deal__c;
        }
      }

      List<Contact> existingContacts = [
        SELECT Id
        FROM Contact
        WHERE Alchemy_Portal_Id__c = :borrowerId
      ];
      List<Lead> existingLeads = [
        SELECT Id
        FROM Lead
        WHERE Alchemy_Portal_Id__c = :borrowerId
      ];

      Id leadId;
      Id contactId;

      Contact broker = [
        SELECT Id
        FROM Contact
        WHERE Alchemy_Portal_Id__c = :brokerId
        LIMIT 1
      ];

      if (existingContacts.size() > 0) {
        contactId = existingContacts[0].Id;
      } else if (existingLeads.size() > 0) {
        leadId = existingLeads[0].Id;
      }

      if (leadId == null && contactId == null) {
        Lead newLead = new Lead();
        newLead.FirstName = borrowerFirstName;
        newLead.LastName = borrowerLastName;
        newLead.Company = companyName;

        insert newLead;

        leadId = newLead.Id;
      }

      system.debug(dealId);

      List<Opportunity> opps = [
        SELECT
          Id,
          LOC_Loan_Type__c,
          Project_Strategy__c,
          Product_Sub_Type__c,
          Type
        FROM Opportunity
        WHERE Id = :dealId
      ];
      String dealType = '';
      String loanType = '';
      if (opps.size() > 0) {
        Opportunity opp = opps[0];
        if (opp.LOC_Loan_Type__c == 'Term Loan') {
          dealType = 'Rental Portfolio';
        }
        if (
          opp.LOC_Loan_Type__c == 'Credit Line' &&
          opp.Project_Strategy__c != 'Fix and Flip'
        ) {
          dealType = 'Credit Line';
        }
        if (
          opp.LOC_Loan_Type__c == 'Credit Line' &&
          opp.Project_Strategy__c == 'Fix and Flip'
        ) {
          dealType = 'Credit Line';
        }

        if (
          opp.LOC_Loan_Type__c == 'Credit Line' &&
          opp.Product_Sub_Type__c == 'Build to Rent'
        ) {
          dealType = 'Build for Rent';
        }

        if (opp.LOC_Loan_Type__c == 'Build to Rent') {
          dealType = 'Build for Rent';
        }

        if (
          opp.LOC_Loan_Type__c == 'Single Asset (1-4 Unit)' ||
          opp.LOC_Loan_Type__c == 'Single Asset (5-10 Unit)'
        ) {
          dealType = 'Single Asset Bridge Loan';
        }
        if (opp.Loc_Loan_Type__c == 'Multifamily/CRE') {
          dealType = 'Multifamily';
        }

        if (opp.LOC_Loan_Type__c == 'Model Home Release') {
          dealType = 'Model Home Release';
        }

        if (opp.LOC_Loan_Type__c == 'Single Asset Rental') {
          dealType = 'Single Rental';
        }

        if (opp.LOC_Loan_Type__c == 'Single Rental Loan') {
          dealType = 'Single Rental';
        }

        if (dealType == 'Rental Portfolio') {
          loanType = 'Rental Portfolio';
        } else if (dealType == 'Build for Rent') {
          loanType = 'Build for Rent';
        } else if (dealType == 'Credit Line') {
          loanType = 'Credit Line';
        } else if (dealType == 'Bridge Loan') {
          loanType = 'Single Asset Bridge Loan';
        } else if (dealType == 'Multifamily') {
          loanType = 'Multifamily';
        } else if (dealType == 'Model Home Lease') {
          // loanType = 'Model Home Lease';
        } else if (dealType == 'Single Rental') {
          // loanType = 'Rental';
        }
      }

      Application__c app = new Application__c();
      app.Alchemy_User_Id__c = borrowerId;
      app.Borrower_Name__c = borrowerFirstName + ' ' + borrowerLastName;
      app.Lead__c = leadId;
      app.Contact__c = contactId;
      app.Broker__c = broker.Id;
      app.Broker_Alchemy_User_Id__c = brokerId;
      app.Deal__c = dealId;
      app.Id = applicationId;
      app.Loan_Type__c = loanType;
      //   stuff goes here..//

      //   app.Deal__c = dealId

      upsert app;

      PortalAPIApplication.ApplicationSmall applicationSmall = new PortalAPIApplication.ApplicationSmall(
        PortalAPIApplication.queryApplication(app.Id)
      );

      res.addHeader('Content-Type', 'application/json');
      res.responseBody = Blob.valueOf(JSON.serialize(applicationSmall, true));
    }
  }
}