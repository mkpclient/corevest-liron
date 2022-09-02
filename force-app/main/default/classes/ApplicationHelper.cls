public with sharing class ApplicationHelper {
  public static void beforeInsert(List<Application__c> newList) {
    // Map<String, Id> recordTypeMap = new Map<String, Id>();

    // for (RecordType rt : [
    //   SELECT Id, DeveloperName
    //   FROM RecordType
    //   WHERE Sobjecttype = 'Application__c'
    // ]) {
    //   recordTypeMap.put(rt.DeveloperName, rt.Id);
    // }

    // for (Application__c app : newList) {
    //   if (app.Loan_Type__c == 'rental') {
    //     app.RecordTypeId = recordTypeMap.get('Rental');
    //   } else if (app.Loan_Type__c == 'term') {
    //     app.RecordTypeId = recordTypeMap.get('Term');
    //   } else if (app.Loan_Type__c == 'bridge') {
    //     app.RecordTypeId = recordTypeMap.get('Bridge');
    //   }
    //}
  }

  @AuraEnabled
  public static Map<String, String> convertApplication(
    Map<String, String> params,
    List<String> recordTypes
  ) {
    try {
      system.debug(params);
      system.debug(recordTypes);
      String recordId = params.get('recordId');
      Application__c app = [
        SELECT Id, Contact__c, Lead__c, Lead__r.ConvertedContactId
        FROM Application__c
        WHERE Id = :recordId
      ];

      if (app.Contact__c == null && app.Lead__r.ConvertedContactId != null) {
        app.Contact__c = app.Lead__r.ConvertedContactId;
        update app;
      }

      Map<String, String> response = new Map<String, String>();
      Application__c application = [
        SELECT
          Id,
          Loan_Type__c,
          Status__c,
          Contact__c,
          Lead__c,
          Lead__r.ConvertedContactId,
          Contact__r.AccountId,
          Loan_Purpose__c,
          Loan_Desired_Amount__c
        FROM Application__c
        WHERE Id = :recordId
      ];

      String name = params.get('Name');
      Opportunity opp = new Opportunity();
      opp.Name = name;
      opp.AccountId = application.Contact__r.AccountId;
      opp.Contact__c = application.Contact__c;
      opp.Loan_Purpose__c = application.Loan_Purpose__c;
      opp.Loan_Size__c = application.Loan_Desired_Amount__c;
      opp.Application__c = application.Id;
      opp.StageName = 'Initial Review';
      // opp.CloseDate
      Map<String, Id> recordTypeMap = new Map<String, Id>();
      for (RecordType rt : [
        SELECT Id, DeveloperName
        FROM RecordType
        WHERE sobjecttype = 'Opportunity'
      ]) {
        recordTypeMap.put(rt.DeveloperName, rt.Id);
      }

      List<Opportunity> opps = new List<Opportunity>();
      if (
        application.loan_Type__c == 'Build for Rent' ||
        application.Loan_Type__c == 'Credit Line' ||
        application.Loan_Type__c == 'Single Asset Bridge Loan' ||
        application.Loan_Type__c == 'Multifamily'
      ) {
        opp.RecordTypeId = recordTypeMap.get('LOC_Loan');
        opp.CloseDate = system.today().addDays(75);
      } else if (application.loan_Type__c == 'Rental Portfolio') {
        opp.RecordTypeId = recordTypeMap.get('Term_Loan');
        opp.CloseDate = system.today().addDays(65);
      } else if (application.loan_Type__c == 'Bridge and Rental') {
        if (recordTypes[0] == 'term') {
          opp.RecordTypeId = recordTypeMap.get('Term_Loan');
          opp.CloseDate = system.today().addDays(65);
        } else {
          opp.RecordTypeId = recordTypeMap.get('LOC_Loan');
          opp.CloseDate = system.today().addDays(75);
        }

        if (recordTypes.size() > 1) {
          Opportunity opp1 = opp.clone(false, false, false, false);
          if (recordTypes[1] == 'term') {
            opp1.RecordTypeId = recordTypeMap.get('Term_Loan');
            opp1.CloseDate = system.today().addDays(65);
          } else {
            opp1.RecordTypeId = recordTypeMap.get('LOC_Loan');
            opp1.CloseDate = system.today().addDays(75);
          }

          opps.add(opp1);
        }

        //system.debug(recordTypes);
      }
      opps.add(opp);
      insert opps;
      //insert opp;
      response.put('oppId', opp.Id);
      application.Deal__c = opp.Id;

      if (opps.size() > 1) {
        application.Deal_2__c = opps[0].Id;
      }

      update application;

      List<Deal_Contact__c> dcs = new List<Deal_Contact__c>();

      // dcs.add(
      //   new Deal_Contact__c(
      //     Contact__c = application.Contact__c,
      //     Deal__c = opp.Id,
      //     Deal_Contact_Type__c = 'Individual',
      //     Entity_Type__c = 'Applicant'
      //   )
      // );

      dcs.add(
        new Deal_Contact__c(
          Contact__c = application.Contact__c,
          Deal__c = opp.Id,
          Deal_Contact_Type__c = 'Individual',
          Entity_Type__c = 'Sponsor'
        )
      );

      if (opps.size() > 0) {
        dcs.add(
          new Deal_Contact__c(
            Contact__c = application.Contact__c,
            Deal__c = opps[0].Id,
            Deal_Contact_Type__c = 'Individual',
            Entity_Type__c = 'Sponsor'
          )
        );
      }

      insert dcs;

      List<Property__c> properties = new List<Property__c>();
      for (Application_Property__c property : [
        SELECT
          Acquisition_Date__c,
          Acquisition_Price__c,
          Address__c,
          Air_Conditioning__c,
          Application__c,
          Bathrooms__c,
          Bedrooms__c,
          Borrower_Opinion_of_Current_Value__c,
          CapEx_Reserves__c,
          City__c,
          Comments__c,
          Country__c,
          CreatedById,
          CreatedDate,
          Credit_Loss__c,
          Currently_Leased__c,
          HOA__c,
          Id,
          Insurance__c,
          IsDeleted,
          Landscaping_Expense__c,
          Lease_End_Date__c,
          Lease_Ready__c,
          Lease_Start_Date__c,
          Lease_Term__c,
          Lease_UpMarketing__c,
          MaintenanceRepairs__c,
          Monthly_Rent__c,
          NOI__c,
          Name,
          Number_of_Units__c,
          Other_Expenses__c,
          Other_Reserves__c,
          Owner_Paid_Utilities__c,
          Pool__c,
          Property_Management__c,
          Property_Type__c,
          Rehab_Completion_Date__c,
          Rehab_Costs__c,
          Section_8__c,
          Security_Deposit__c,
          Special_Assessments__c,
          Square_Footage__c,
          State__c,
          SystemModstamp,
          Taxes__c,
          Total_Basis__c,
          Total_Expenses__c,
          Transaction_Costs__c,
          Vacancy_RepairsMaintenance__c,
          Year_Built__c,
          Zipcode__c
        FROM Application_Property__c
        WHERE Application__c = :recordId
      ]) {
        Property__c prop = new Property__c();
        prop.Deal__c = opp.Id;
        prop.Acquisition_Date__c = property.Acquisition_Date__c;
        prop.Acquisition_Price__c = property.Acquisition_Price__c;
        prop.Property_Name__c = property.Address__c;
        prop.Air_Conditioning__c = property.Air_Conditioning__c;
        prop.Number_of_Bath__c = property.Bathrooms__c;
        prop.Number_of_Beds__c = property.Bedrooms__c;
        prop.Borrower_Opinion_of_Current_Value__c = property.Borrower_Opinion_of_Current_Value__c;
        prop.Cap_Ex_Reserves__c = property.CapEx_Reserves__c;
        prop.City__c = property.City__c;
        prop.Comments__c = property.Comments__c;
        prop.Credit_Loss__c = property.Credit_Loss__c;
        prop.Currently_Leased__c = property.Currently_Leased__c;
        prop.Annual_HOA_Fee__c = property.HOA__c;
        prop.Annual_Landscaping_Expense__c = property.Landscaping_Expense__c;
        prop.Lease_End_Date__c = property.Lease_End_Date__c;
        prop.Lease_Ready__c = property.Lease_Ready__c;
        prop.Lease_Start_Date__c = property.Lease_Start_Date__c;
        prop.Lease_Term__c = property.Lease_Term__c;
        prop.Lease_Up_Marketing__c = property.Lease_UpMarketing__c;
        prop.Maintenance_Repairs__c = property.MaintenanceRepairs__c;
        prop.Monthly_Rent__c = property.Monthly_Rent__c;
        prop.Name = property.Name;
        prop.Number_of_Units__c = property.Number_of_Units__c;
        prop.Other_Expenses__c = property.Other_Expenses__c;
        prop.Other_Reserves__c = property.Other_Reserves__c;
        prop.Owner_Paid_Utilities__c = property.Owner_Paid_Utilities__c;
        prop.Pool__c = property.Pool__c;

        if (property.Property_Type__c == 'townhom') {
          property.Property_Type__c = 'townhome';
        }

        if (property.Property_Type__c == '1-4 Unit') {
          property.Property_Type__c = '2-4 Unit';
        }

        prop.Property_Type__c = property.Property_Type__c;
        prop.Rehab_Completion_Date__c = property.Rehab_Completion_Date__c;
        prop.Rehab_Costs__c = property.Rehab_Costs__c;
        prop.Section_8__c = property.Section_8__c;
        prop.Security_Deposit__c = property.Security_Deposit__c;
        prop.Special_Assesments_CFD_Mello_Roos_etc__c = property.Special_Assessments__c;
        prop.State__c = property.State__c;
        prop.Annual_Taxes__c = property.Taxes__c;
        prop.Name = property.Address__c;
        prop.Transaction_Costs__c = property.Transaction_Costs__c;
        prop.Vacancy_Repairs__c = property.Vacancy_RepairsMaintenance__c;
        prop.Year_Built__c = property.Year_Built__c;
        prop.Zipcode__c = property.Zipcode__c;

        if (opps.size() > 1) {
          Property__c prop1 = prop.clone(false, false, false, false);
          prop1.Deal__c = opps[0].Id;
          properties.add(prop1);
        }

        properties.add(prop);
      }

      insert properties;

      return response;
    } catch (Exception e) {
      system.debug(e.getLineNumber());
      throw new AuraHandledException(e.getMessage());
    }
  }
}