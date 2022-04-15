public without sharing class CommunityFundingController {
  @AuraEnabled
  public static List<Property__c> insertProperties(
    String opportunityId,
    String properties
  ) {
    if (CommunityController.checkAccess(opportunityId)) {
      system.debug(properties);
      List<Property__c> props = (List<Property__c>) JSON.deserialize(
        properties,
        List<Property__c>.class
      );

      try {
        List<Database.SaveResult> resInsert = Database.insert(props, false);

        String errorMessage = '';

        for (Database.SaveResult r : resInsert) {
          if (!r.isSuccess()) {
            for (Database.Error error : r.getErrors()) {
              if (error instanceof Database.DuplicateError) {
                Datacloud.DuplicateResult duplicateResult = ((Database.DuplicateError) error)
                  .getDuplicateResult();

                List<Datacloud.MatchResult> matchResults = duplicateResult.getMatchResults();
                Datacloud.MatchRecord[] matchRecords = matchResults[0]
                  .getMatchRecords();

                errorMessage += error.getMessage() + ' ';
                errorMessage += matchRecords[0].getRecord().get('Name');

                system.debug('--- stuff -- ');
                system.debug(JSON.serialize(matchRecords[0].getRecord()));
              } else {
                errorMessage += error.getMessage();
              }
            }
          }
        }

        if (String.isNotBlank(errorMessage)) {
          throw new AuraHandledException(errorMessage);
        }

        return props;
      } catch (DmlException e) {
        throw new AuraHandledException('testdaf');
        //return null;
      }
    } else {
      return null;
    }
  }

  @AuraEnabled
  public static void updateRecord(sObject record) {
    update record;

    return;
  }

  @AuraEnabled
  public static List<Property__c> getFundingsInProcess(String recordId) {
    List<Property__c> fundings = new List<Property__c>();

    List<String> fundingStati = new List<String>{
      'Pending',
      'In Process',
      'Due Diligence',
      'Closing'
    };

    if (
      String.isNotBlank(recordId) && CommunityController.checkAccess(recordId)
    ) {
      String queryString = 'SELECT Id, Name, City__c, State__c, ZipCode__c, County__c, Property_Type__c,';
      queryString += ' Number_of_Units__c, Number_of_Beds__c, Number_of_Bath__c, Square_Feet__c, Refinance_Acquisition__c,';
      queryString += ' Requested_Funding_Date__c, Acquisition_Price__c, Acquisition_Date__c, Contract_Close_Date__c,';
      queryString += ' Title_Company_text__c, Title_Contact_Name__c, Title_Contact_Phone__c,';

      queryString += ' Status__c, CreatedDate, Deal__r.LOC_Commitment__c, Deal__r.Outstanding_Facility_Amount__c, Deal__r.Days_Remaining__c,';
      queryString += ' Deal__r.Expired__c, Advance_Fee_formula__c, Broker_Adv_Fee_Amnt__c, Doc_Prep_Fee__c, BPO_Appraisal_Fee__c, BPO_Appraisal_Date__c,';
      queryString += ' Appraised_Value_Amount__c, Asset_Maturity_Date__c, Current_Outstanding_Loan_Amount__c, Partial_Paydown__c, Partial_Paydown_Date__c,';
      queryString += ' Payoff_Request_Date__c, Payoff_Request_Sent_Date__c, Payoff_Received_Date__c';

      queryString += ' FROM Property__c WHERE Deal__c =: recordId';

      queryString += ' AND Status__c IN : fundingStati';

      fundings = (List<Property__c>) database.query(queryString);
    } else {
      Set<Id> bridgeIds = getAllBridgeDealIds();

      String queryString = 'SELECT Id, Name, City__c, State__c, ZipCode__c, County__c, Property_Type__c,';
      queryString += ' Number_of_Units__c, Number_of_Beds__c, Number_of_Bath__c, Square_Feet__c, Refinance_Acquisition__c,';
      queryString += ' Requested_Funding_Date__c, Acquisition_Price__c, Acquisition_Date__c, Contract_Close_Date__c,';
      queryString += ' Title_Company_text__c, Title_Contact_Name__c, Title_Contact_Phone__c,';

      queryString += ' Status__c, CreatedDate, Deal__r.LOC_Commitment__c, Deal__r.Outstanding_Facility_Amount__c, Deal__r.Days_Remaining__c,';
      queryString += ' Deal__r.Expired__c, Advance_Fee_formula__c, Broker_Adv_Fee_Amnt__c, Doc_Prep_Fee__c, BPO_Appraisal_Fee__c, BPO_Appraisal_Date__c,';
      queryString += ' Appraised_Value_Amount__c, Asset_Maturity_Date__c, Current_Outstanding_Loan_Amount__c, Partial_Paydown__c, Partial_Paydown_Date__c,';
      queryString += ' Payoff_Request_Date__c, Payoff_Request_Sent_Date__c, Payoff_Received_Date__c';

      queryString += ' FROM Property__c WHERE Deal__c IN : bridgeIds';
      queryString += ' AND Status__c IN : fundingStati';
      fundings = (List<Property__c>) database.query(queryString);
    }

    return fundings;
  }

  @AuraEnabled
  public static Map<String, Object> getLOCChartData(String recordId) {
    Map<String, Object> response = new Map<String, Object>();

    if (
      String.isNotBlank(recordId) && CommunityController.checkAccess(recordId)
    ) {
      Opportunity deal = [
        SELECT Id, Aggregate_Funding__c, Outstanding_Facility_Amount__c
        FROM Opportunity
        WHERE Id = :recordId
      ];
      response.put('Drawn', deal.Aggregate_Funding__c);
      response.put('Undrawn', deal.Outstanding_Facility_Amount__c);
    } else {
      Set<Id> bridgeIds = getAllBridgeDealIds();

      AggregateResult ar = [
        SELECT
          SUM(Aggregate_Funding__c) ar,
          SUM(Outstanding_Facility_Amount__c) ar1
        FROM Opportunity
        WHERE Id IN :bridgeIds
      ];

      response.put('Drawn', (Decimal) ar.get('ar'));
      response.put('Undrawn', (Decimal) ar.get('ar1'));
    }

    return response;
  }

  @AuraEnabled
  public static List<Property__c> getClosedFundings(String recordId) {
    List<Property__c> properties;
    if (
      String.isNotBlank(recordId) && CommunityController.checkAccess(recordId)
    ) {
      properties = [
        SELECT
          Id,
          Name,
          Deal__r.Name,
          Approved_Advance_Amount_Used__c,
          Funding_Date__c,
          Asset_Maturity_Date__c,
          Deal__r.Product_Sub_Type__c
        FROM Property__C
        WHERE Deal__c = :recordId
      ];
    } else {
      Set<Id> bridgeIds = getAllBridgeDealIds();
      properties = [
        SELECT
          Id,
          Name,
          Deal__r.Name,
          Approved_Advance_Amount_Used__c,
          Funding_Date__c,
          Asset_Maturity_Date__c,
          Deal__r.Product_Sub_Type__c
        FROM Property__C
        WHERE Deal__c IN :bridgeIds
      ];
    }

    return properties;
  }

  @AuraEnabled
  public static List<Property__c> getLoanFundings(String recordId) {
    List<Property__c> properties;
    if (
      String.isNotBlank(recordId) && CommunityController.checkAccess(recordId)
    ) {
      properties = [
        SELECT
          Id,
          Name,
          Deal__r.Name,
          Deal__r.LOC_Commitment__c,
          Deal__r.Requested_LTV_Max__c,
          Deal__r.Requested_LTC_Max__c,
          Deal__r.Requested_ARV_LTV__c,
          Deal__r.Requested_Total_Loan_LTC__c,
          Deal__r.CloseDate,
          Deal__r.Current_Line_Maturity_Date__c,
          Deal__r.LOC_Outside_Advance_Days__c,
          Deal__r.Max_Advance_Fee_formula__c
        FROM Property__C
        WHERE Deal__c = :recordId
      ];
    } else {
      Set<Id> bridgeIds = getAllBridgeDealIds();
      properties = [
        SELECT
          Id,
          Name,
          Deal__r.Name,
          Deal__r.LOC_Commitment__c,
          Deal__r.Requested_LTV_Max__c,
          Deal__r.Requested_LTC_Max__c,
          Deal__r.Requested_ARV_LTV__c,
          Deal__r.Requested_Total_Loan_LTC__c,
          Deal__r.CloseDate,
          Deal__r.Current_Line_Maturity_Date__c,
          Deal__r.LOC_Outside_Advance_Days__c,
          Deal__r.Max_Advance_Fee_formula__c
        FROM Property__C
        WHERE Deal__c IN :bridgeIds
      ];
    }

    return properties;
  }

  public static Set<Id> getAllBridgeDealIds() {
    community_Controller.UserResource user = (community_Controller.UserResource) JSON.deserialize(
      community_Controller.getUser(),
      community_Controller.UserResource.class
    );

    return new Map<Id, Opportunity>(
        (List<Opportunity>) JSON.deserialize(
          community_Controller.getBorrowerDeals(
            user.contactId,
            new List<String>{ 'Id' },
            null,
            null,
            null,
            false,
            false,
            true
          ),
          List<Opportunity>.class
        )
      ) 
      .keySet();
  }

  @AuraEnabled
  public static String initMatrixScreen(String recordId) {
    Map<String, Object> response = new Map<String, Object>();
    if (CommunityController.checkAccess(recordId)) {
      // Property__c prop = [SELECT Id, Refinance_Acquisition__c FROM Property__c WHERE Id =: recordId];
      String queryString = compileQueryString();
      queryString += ' WHERE ID =: recordId';
      system.debug(queryString);
      Property__c prop = ((List<Property__c>) database.query(queryString))[0];
      response.put('property', prop);

      Map<String, List<Deal_Document__c>> requiredDocs = new Map<String, List<Deal_Document__c>>();
      if (
        prop.Refinance_Acquisition__c != null &&
        FUNDING_MATRIX.get(prop.Refinance_Acquisition__c.toLowerCase()) != null
      ) {
        for (
          String requiredDoc : FUNDING_MATRIX.get(
            prop.Refinance_Acquisition__c.toLowerCase()
          )
        ) {
          requiredDocs.put(requiredDoc, new List<Deal_Document__c>());
        }

        for (Deal_Document__c doc : [
          SELECT
            Id,
            Document_Type__c,
            File_Name__c,
            Added_On__c,
            Added_By__r.Name,
            Reviewed_On__c,
            Reviewed_By__r.Name
          FROM Deal_Document__c
          WHERE Document_Type__c IN :requiredDocs.keySet()
        ]) {
          system.debug(doc.Document_Type__c);
          system.debug(requiredDocs);
          requiredDocs.get(doc.Document_Type__c).add(doc);
        }

        Integer docTypesCompleted = 0;
        Integer docsTotal = 0;
        Integer reviewedDocs = 0;
        for (List<Deal_Document__c> docs : requiredDocs.values()) {
          if (docs.size() > 0) {
            docTypesCompleted++;
          }

          docsTotal += docs.size();

          for (Deal_Document__c doc : docs) {
            if (doc.Reviewed_By__c != null) {
              reviewedDocs++;
            }
          }
        }

        Decimal docsUploadPercent =
          ((Decimal) docTypesCompleted) / requiredDocs.size();
        Decimal docsReviewedPercent = docsTotal != 0
          ? ((Decimal) reviewedDocs) / docsTotal
          : 0;
        Decimal totalPercent =
          docsUploadPercent * .5 +
          docsReviewedPercent * .5;

        response.put(
          'statusText',
          '' +
          (requiredDocs.size() - docTypesCompleted) +
          ' Remaining Document(s) to be Uploaded'
        );
        response.put(
          'docsReviewedText',
          '' +
          (docsTotal - reviewedDocs) +
          ' Remaining Document(s) to be Approved'
        );

        response.put('statusPercent', docsUploadPercent);
        response.put('docsReviewedPercent', docsReviewedPercent);
        response.put('totalPercent', totalPercent);
        response.put('docTypes', requiredDocs);
        response.put('fieldMap', fieldMap);
        response.put(
          'fields',
          FUNDING_FIELDS.get(prop.Refinance_Acquisition__c.toLowerCase())
        );
      } else {
      }
    }

    return JSON.serialize(response);
  }

  public static String compileQueryString() {
    String qs = 'SELECT Id,';
    for (String field : fieldMap.keySet()) {
      qs += field + ', ';
    }

    qs = qs.substringBeforeLast(',');
    qs += ' FROM Property__c';

    return qs;
  }

  public static Map<String, List<String>> FUNDING_MATRIX = new Map<String, List<String>>{
    'purchase' => new List<String>{ 'Purchase Contract' },
    'refinance' => new List<String>{
      'Executed Purchase Contract or Sales Receipt',
      'Executed closing HUD or Sales Receipt',
      'Recorded Deed'
    },
    'refinance with completed rehab' => new List<String>{
      'Executed Purchase Contract/Sales Receipt',
      'Executed closing HUD or Sales Receipt',
      'Recorded Deed',
      'Rehab work'
    },
    'purchase with renovation' => new List<String>{
      'Purchase Contract',
      'Scope of Work or Renovation Budget'
    }
  };

  @AuraEnabled
  public static String getDatatapeTemplate() {
    return JSON.serialize(
      [
        SELECT Id, Body
        FROM StaticResource
        WHERE Name = 'FundingRequestDatatape'
      ]
      .Body
    );
  }

  public static Map<String, List<String>> FUNDING_FIELDS = new Map<String, List<String>>{
    'purchase' => new List<String>{
      'Title_Contact_Name__c',
      'Title_Contact_Phone__c',
      'Title_Contact_Email_Address__c'
    },
    'refinance' => new List<String>{
      'Interior_Access_POC__c',
      'Interior_Access_POC_Phone__c',
      'Interior_Access_POC_Email__c'
    },
    'refinance with completed rehab' => new List<String>{
      'Interior_Access_POC__c',
      'Interior_Access_POC_Phone__c',
      'Interior_Access_POC_Email__c'
    },
    'purchase with renovation' => new List<String>{
      'Interior_Access_POC__c',
      'Interior_Access_POC_Phone__c',
      'Interior_Access_POC_Email__c'
    }
  };

  public static Map<String, String[]> fieldMap = new Map<String, String[]>{
    'Title_Contact_Name__c' => new List<String>{
      'Closing Attorney/Title Contact Name',
      'text'
    },
    'Title_Contact_Phone__c' => new List<String>{
      'Closing Attorney/Title Contact Phone Number ',
      'text'
    },
    'Title_Contact_Email_Address__c' => new List<String>{
      'Closing Attorney/Title Contact Email',
      'text'
    },
    'Interior_Access_POC__c' => new List<String>{
      'Point of Contact for Interior Access Name',
      'text'
    },
    'Interior_Access_POC_Phone__c' => new List<String>{
      'Point of Contact for Interior Access Phone',
      'text'
    },
    'Interior_Access_POC_Email__c' => new List<String>{
      'Point of Contact for Interior Access Email Address',
      'text'
    },
    'Refinance_Acquisition__c' => new List<String>{ 'Transaction Type', 'text' }
  };
}