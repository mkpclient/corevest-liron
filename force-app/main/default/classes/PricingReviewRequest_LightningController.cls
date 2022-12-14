public without sharing class PricingReviewRequest_LightningController {
  public static Id userId = UserInfo.getUserId();
  public static final List<String> REPRICE_CC_NAMES = new List<String>{
    'Libby Burgeson',
    'Behnam Hoss'
  };

  public static Set<Id> repriceCcUsers {
    get {
      if (REPRICE_CC_NAMES.size() == 0) {
        return new Set<Id>();
      }
      Map<Id, User> users = new Map<Id, User>(
        [SELECT Id FROM User WHERE Name IN :REPRICE_CC_NAMES]
      );

      return users.keySet();
    }
    private set;
  }

  public static Map<String, String> bridgeFields = new Map<String, String>{
    // 'Name' => 'Name',
    // 'Referral_Source__c' => 'Referral Source',
    // 'Advance_Period_Days_In_Months__c' => 'Advance Period Days',
    // 'LTC__c' => 'Max LTC %',
    // 'LTV__c' => 'Max LTV %',
    // 'Origination_Fee__c' => 'Origination Fee',
    // 'Fee__c' => 'Fee %',
    // 'Exit_Fee__c' => 'Exit Fee',
    // 'Rate__c' => 'Interest Rate',
    // 'Revolving__c' => 'Revolving',
    // 'Max_Advance_Fee__c' => 'Max Advance Fee',
    // 'Additional_Adjustments__c' => 'Additional Adjustments',
    // 'Min_DSCR__c' => 'Min DSCR',
    'Loan_Size__c' => 'Requested Loan Size',
    'Sponsor_Details__c' => 'Sponsor Details',
    'Sponsor_Strategy__c' => 'Sponsor Strategy',
    'Deal_Intro_Source__c' => 'Deal Intro Source',
    'Active_States__c' => 'Active States',
    'Requested_Exit_Fee__c' => 'Requested Exit Fee',
    'Requested_Origination_Fee__c' => 'Requested Origination Fee',
    'Requested_Draw_Fee__c' => 'Requested Advance Fee',
    'Broker_Fees__c' => 'Broker Fee %',
    'Foreign_National_picklist__c' => 'Foreign National'
  };
  // standard => , custom =>
  // workflow rules to populate it once ir a bridge

  public static Map<String, String> sabFields = new Map<String, String>{
    'LOC_Program_Type__c' => 'Bridge Program Type',
    // 'Sponsor_Details__c' => 'Sponsor Details',
    // 'Sponsor_Strategy__c' => 'Sponsor Strategy',
    'Loan_Size__c' => 'Requested Loan Size',
    'Renovation_Funding__c' => 'Renovation Funding',
    // 'Requested_Exit_Fee__c' => 'Requested Exit Fee',
    'Requested_Origination_Fee__c' => 'Requested Origination Fee',
    'Broker_Fees__c' => 'Broker Fee %',
    'LOC_Program_Type__c' => 'Bridge Program Type',
    'LOC_Loan_Type__c' => 'Product Type',
    'Recourse__c' => 'Recourse',
    'Foreign_National_picklist__c' => 'Foreign National'
  };

  public static Map<String, String> termFields = new Map<String, String>{
    'Name' => 'Name',
    'Loan_Purpose__c' => 'Loan Purpose',
    'Acquisition_Cost__c' => 'Acquisition Cost',
    'Renovation_Cost__c' => 'Renovation Cost',
    'Annual_HOA_Sum__c' => 'Total Annual HOA',
    'Section_8_Count__c' => 'Section 8 Count',
    'CloseDate' => 'Close Date',
    'Total_NOI__c' => 'NOI',
    //'Referral_Source__c' => 'Referral Source',
    'Floor__c' => 'Floor %',
    'LTC__c' => 'Max LTC %',
    'Term_Loan_Type__c' => 'Term Loan Type',
    'Amortization_Term__c' => 'Amortization Term',
    'YM_Prepayment_Penalty__c' => 'YM Par Prepayment Period',
    'Stepdown_Prepayment_Period__c' => 'Stepdown Prepayment Period',
    'Recourse__c' => 'Recourse',
    'Average_Lease_Term__c' => 'Average Lease Term',
    'Static_Vacancy__c' => 'Static Vacancy',
    'Average_Maintenance_Per_Asset__c' => 'Average Maintenance Per Asset',
    'Average_Cap_Ex_Per_Asset__c' => 'Average Cap-Ex Per Asset',
    'Min_DSCR__c' => 'Min DSCR',
    'Deal_Intro_Source__c' => 'Deal Intro Source',
    'CAF_YSP__c' => 'CAF YSP',
    'YSP_perc__c' => 'Broker YSP %',
    'Foreign_National_picklist__c' => 'Foreign National'
  };

  public static Set<String> bridgeRequiredDocuments = new Set<String>{};

  public static Set<String> sabRequiredDocuments = new Set<String>{
    // 'Bridge Project Sizing Model'
  };

  public static Set<String> termRequiredDocuments = new Set<String>{
    'Draft Model',
    'Greenlight Deck'
  };

  @AuraEnabled //trivikram
  public static String validateRecord(Id recordId) {
    Settings__mdt universalSetting = lightning_Controller.queryUniversalSettings();

    String qs = 'SELECT GLC_Required__c,GLC_Approved__c,RecordType.DeveloperName,OwnerId,Name,Fee__c,Exit_Fee__c,Max_Advance_Fee__c,StageName,LOC_Loan_Type__c,LOC_Program_Type__c,Type,Broker_Fees__c, YSP_perc__c, Deal_Intro_Sub_Source__c,Account.Number_of_Contacts__c,Current_Approval_Process__c,Swap_Rate__c,Spread_BPS__c,CAF_YSP__c,';

    for (String field : termFields.keySet()) {
      if (!qs.contains(field + ',')) {
        qs += field + ',';
      }
    }

    for (String field : bridgeFields.keySet()) {
      if (!qs.contains(field + ',')) {
        qs += field + ',';
      }
    }

    for (String field : sabFields.keySet()) {
      if (!qs.contains(field + ',')) {
        qs += field + ',';
      }
    }

    qS += ' (SELECT Id, Document_Type__c, Other_Document_Type__c, Type__c, Document_Loaded__c FROM Deal_Documents__r ';
    qS += '    WHERE Document_Loaded__c = true AND (Document_Type__c IN : bridgeRequiredDocuments OR Document_Type__c IN : termRequiredDocuments OR Document_Type__c IN : sabRequiredDocuments)),';

    // qs = qs.substringBeforeLast(',');
    qs += ' (SELECT Id, Status__c, Property_Type__c, Red_Bell_Sync__c FROM Properties__r) FROM Opportunity WHERE Id = :recordId LIMIT 1';
    // System.debug('validating from controller');
    //system.debug(recordId);
    System.debug(qs);

    Opportunity o = (Opportunity) Database.query(qs);
    //System.debug(o);

    returnItem ri = new returnItem();
    ri.otherMessage = new List<String>();
    if(o.LOC_Program_Type__c == 'Standard') {
      ri.allowBypass = true;
    } 

    //TriVikram added below check to resubmit for GLC
    List<Approval_History__c> ahList = [
      SELECT
        Actor__c,
        Name,
        Approver__c,
        Comments__c,
        Deal__c,
        Parent_Status__c,
        Process_Id__c,
        Process_Instance_Id__c,
        Status__c,
        Date_Acted__c,
        Time_in_Approval__c,
        Step_Item_Id__c,
        Status_Text__c,
        Verified__c,
        Approval_Type__c,
        Deal__r.Approved_by_Capital_Markets__c,
        Deal__r.Approved_by_Underwriter__c,
        Deal__r.OwnerId,
        Deal__r.Owner.Name,
        Deal__r.Approval_Status__c,
        Deal__r.Apex_Context__c,
        CreatedDate,
        Resolution__c,
        Deal_Stage_At_Time_of_Submission__c
      FROM Approval_History__c
      WHERE Deal__c = :recordId
      ORDER BY LastModifiedDate DESC
    ];
    // ri.isDisplayGLC = false;
    for (Approval_History__c ah : ahList) {
      if (
        ah.Status_Text__c ==
        'Rejected- Pending GLC approval' /*&& ah.Approval_Type__c=='Approved By GLC' */
      ) {
        ri.isDisplayGLC = true;
        break;
      }
      if(
        String.isNotEmpty(ah.Comments__c) && ah.Comments__c.containsIgnoreCase('bypassed') && ri.allowBypass == true
      ) {
        ri.otherMessage.add(
        'Pricing approval for this deal has already been bypassed.'
      );
      break;
      }
    }

    /*if(ri.isDisplayGLC){
       if(!o.GLC_Approved__c){
           ri.otherMessage.add('GLC Approved checkbox should be marked.'); 
       }
		
   }else{
       termRequiredDocuments.remove('Diligence Documents');
   }*/
    system.debug('--ri--');
    system.debug(ri);
    // if (!ri.isDisplayGLC && o.GLC_Required__c && !o.GLC_Approved__c) {
    //   ri.isDisplayGLC = true;
    // }

    if (!ri.isDisplayGLC) {
      termRequiredDocuments.remove('Greenlight Deck');
    }

    if (o.Current_Approval_Process__c != null) {
      ri.otherMessage.add(
        'Deal is already in an Approval Process.  See Approvals Tab for details'
      );
    }

    List<String> nullFields = new List<String>();

    Set<String> requiredDocuments;
    if (o.RecordType.DeveloperName == 'Term_Loan') {
      requiredDocuments = termRequiredDocuments;
    } else if (o.RecordType.DeveloperName == 'LOC_Loan') {
      requiredDocuments = bridgeRequiredDocuments;
    } else {
      requiredDocuments = sabRequiredDocuments;
    }

    Set<String> loadedDocuments = new Set<String>();
    for (Deal_Document__c doc : o.Deal_Documents__r) {
      loadedDocuments.add(doc.Document_Type__c);
      loadedDocuments.add(doc.Type__c);
      loadedDocuments.add(doc.Other_Document_Type__c);
    }
    requiredDocuments.removeAll(loadedDocuments);

    if (requiredDocuments.size() > 0) {
      String errorString = 'The following document(s) are required: ';
      for (String doc : requiredDocuments) {
        errorString +=
          (doc == 'Greenlight Deck'
            ? 'Diligence Documents - Greenlight Deck'
            : doc) + ',';
      }
      errorString = errorString.substringBeforeLast(',') + '.';
      ri.otherMessage.add(errorString);
    }
    // Validation for submitting a Single Asset Bridge Loan for Pricing Approval
    if (o.RecordType.DeveloperName == 'Single_Asset_Bridge_Loan') {
      if (o.Account.Number_of_Contacts__c == 0) {
        ri.otherMessage.add(
          'Account does not have any related Contact. Please add Contact before submitting.'
        );
      }

      if (o.Properties__r.size() == 0) {
        ri.otherMessage.add('Property is required before submitting.');
      }
      for (String field : sabFields.keySet()) {
        if (null == o.get(field)) {
          nullFields.add(sabFields.get(field));
        }
      } // Validation for submitting a Term Loan for Pricing Approval
    } else if (o.RecordType.DeveloperName == 'Term_Loan') {
      if (o.Account.Number_of_Contacts__c == 0) {
        ri.otherMessage.add(
          'Account does not have any related Contact. Please add Contact before submitting.'
        );
      }

      if (o.Properties__r.size() == 0) {
        ri.otherMessage.add('Data tape is required before submitting.');
      }
      for (String field : termFields.keySet()) {
        if (null == o.get(field)) {
          nullFields.add(termFields.get(field));
        }
      }

      if (
        universalSetting.Require_X_Author_Validation_on_Pricing__c &&
        !lightning_Controller.isXAuthorSaved(recordId)
      ) {
        ri.otherMessage.add('X-Author is required before submitting');
      }

      if (universalSetting.Require_Address_Valid_on_Pricing__c) {
        Decimal percentageValidated =
          100 * lightning_Controller.calculateSmartyStreetsVerified(recordId);

        system.debug('--percentages validated--=');
        system.debug(percentageValidated);
        system.debug(recordId);

        if (
          universalSetting.Validated_Address_Threshold__c != null &&
          universalSetting.Validated_Address_THreshold__c > percentageValidated
        ) {
          ri.OtherMessage.add(
            // universalSetting.Validated_Address_Threshold__c +
            // '% of properties must be validated with SmartyStreets. Go to the Validated Addresses Tab under the Properties Tab'
            'Properties must be validated with SmartyStreets. Go to the Validated Addresses Tab under the Properties Tab'
          );
        }
      }

      if (
        universalSetting.Require_AVM_Sync_on_Pricing__c &&
        !UnderwritingApproval_LightningController.propertiesHaveBeenRedBellSynced(
          o.Properties__r
        )
      ) {
        ri.OtherMessage.add(
          'Properties must be synced with HouseCanary. Go to the HouseCanary Data Tab under the Properties Tab'
        );
      } // Validation for submitting a Bridge Loan for Pricing Approval
    } else if (o.RecordType.DeveloperName == 'LOC_Loan') {
      if (o.Account.Number_of_Contacts__c == 0) {
        ri.otherMessage.add(
          'Account does not have any related Contact. Please add Contact before submitting.'
        );
      }

      if (
        o.Properties__r.size() == 0 &&
        o.LOC_Loan_Type__c == 'Multifamily/CRE'
      ) {
        ri.otherMessage.add('Property is required before submitting.');
      }
      for (String field : bridgeFields.keySet()) {
        if (null == o.get(field)) {
          nullFields.add(bridgeFields.get(field));
        }
      }
    }

    ri.wrongUser = false;
    ri.oppName = o.Name;
    ri.recordType = o.RecordType.DeveloperName;

    if (nullFields.size() > 0) {
      ri.nullFields = nullFields;
    }

    if (
      o.StageName == 'Expired' ||
      o.StageName == 'Matured' ||
      o.StageName == 'Paid Off'
    ) {
      ri.wrongStage = true;
    }

    //CIP-2191-RS.4/4/22.Begin.
   /* if (
      universalSetting.Request_Beekin_Rental_Data_Validation__c &&
      beekingRentalInfoCheck(recordId)
    ) {
      ri.otherMessage.add(
        'Please retrieve rental estimates from Beekin on all the properties before moving the deal to Pricing Review.'
      );
    }*/
    ////CIP-2191-RS.4/4/22.End.

 //CIP-2288-RS.8/18/22.Begin.      
      if (o.LOC_Loan_Type__c == 'Term Loan' || o.LOC_Loan_Type__c == 'Multifamily/CRE' || o.LOC_Loan_Type__c  == 'Build to Rent' || o.LOC_Loan_Type__c == 'Single Asset (5-10 Unit)'
          || o.LOC_Loan_Type__c == 'Single Asset (1-4 Unit)' )
      {
           DealPropertyVlidation(recordId, o.LOC_Loan_Type__c,ri,Null);
      }
 //CIP-2288-RS.8/18/22.End.      
    System.debug(ri);
    return JSON.serialize(ri, true);
  }

 //CIP-2288-RS.8/18/22.Begin.
  @AuraEnabled
  public static Void DealPropertyVlidation(Id recId, String Product_Type, returnItem ri, List<String> listMessages) {
      
    System.debug('RS999 recId :' +recId);
    System.debug('RS999 Product_Type :' +Product_Type);
    System.debug('RS999 ri :' +ri);
    System.debug('RS999 listMessages :' +listMessages);      
    List<property__c> properties = [
      SELECT id,
		City__c,
		State__c,
		ZipCode__c,
		Acquisition_Price__c,
		Borrower_Opinion_of_Current_Value__c,
		Override_Initial_Disbursement__c
      FROM Property__c
      WHERE Deal__c = :recId
        AND Status__c NOT IN ('Inactive', 'Cancelled')
 		AND Is_Sub_Unit__c = false
    ];

    Map<integer,String> mapReturnMessage = new Map<integer,String>();
    String returnMessage ='';
    For (property__c propertie : properties)
    {        
    if (Product_Type == 'Term Loan')
    {
			if (String.isBlank(propertie.City__c))
            {
               if(!mapReturnMessage.containsKey(1)) mapReturnMessage.Put(1,GetMessage(1)) ;
            }
            if (String.isBlank(propertie.ZipCode__c))
            {
               if(!mapReturnMessage.containsKey(2)) mapReturnMessage.Put(2,GetMessage(2)) ;
            }         
            if (String.isBlank(propertie.State__c))
            {
               if(!mapReturnMessage.containsKey(3)) mapReturnMessage.Put(3,GetMessage(3)) ;
            }
            if (propertie.Acquisition_Price__c == Null)
            {
               if(!mapReturnMessage.containsKey(4)) mapReturnMessage.Put(4,GetMessage(4)) ;
            }      
            if (propertie.Borrower_Opinion_of_Current_Value__c == Null)
            {
               if(!mapReturnMessage.containsKey(5)) mapReturnMessage.Put(5,GetMessage(5)) ;
            }          
    }
      
    if (Product_Type == 'Multifamily/CRE' || Product_Type == 'Build to Rent' )
    {
			if (String.isBlank(propertie.City__c))
            {
               if(!mapReturnMessage.containsKey(1)) mapReturnMessage.Put(1,GetMessage(1)) ;
            }
            if (String.isBlank(propertie.ZipCode__c))
            {
               if(!mapReturnMessage.containsKey(2)) mapReturnMessage.Put(2,GetMessage(2)) ;
            }         
            if (String.isBlank(propertie.State__c))
            {
               if(!mapReturnMessage.containsKey(3)) mapReturnMessage.Put(3,GetMessage(3)) ;
            }
            if (propertie.Override_Initial_Disbursement__c == Null)
            {
               if(!mapReturnMessage.containsKey(6)) mapReturnMessage.Put(6,GetMessage(6)) ;
            }              
    }
      
    if (Product_Type == 'Single Asset (1-4 Unit)' || Product_Type == 'Single Asset (5-10 Unit)')
    {
			if (String.isBlank(propertie.City__c))
            {
               if(!mapReturnMessage.containsKey(1)) mapReturnMessage.Put(1,GetMessage(1)) ;
            }
            if (String.isBlank(propertie.ZipCode__c))
            {
               if(!mapReturnMessage.containsKey(2)) mapReturnMessage.Put(2,GetMessage(2)) ;
            }         
            if (String.isBlank(propertie.State__c))
            {
               if(!mapReturnMessage.containsKey(3)) mapReturnMessage.Put(3,GetMessage(3)) ;
            }
    }
    }
      if (mapReturnMessage.size() > 0)
      {
          If (ri != Null)
          {
          For(String curMessage : mapReturnMessage.values())
          {
              ri.otherMessage.add(curMessage);
              System.Debug('RS999 listMessages :' +listMessages);              
          }
          }
          Else
          {
           For(String curMessage : mapReturnMessage.values())
          {
              listMessages.add(curMessage);
              System.Debug('RS999 listMessages :' +listMessages);
          }  
          }
      }
  }
    
  @AuraEnabled
  public static String GetMessage(Integer messageNumber) {    
      
    Messages__mdt  message = [SELECT Detailed_Description__c, Messages__c, MessagetNumber__c , Message_Type__c from Messages__mdt where MessagetNumber__c = :messageNumber];
	      
    //String ErrorString = message.Messages__c + ' (' + String.valueOf(messageNumber)  + ')';
    String ErrorString = message.Messages__c;
      
    Return ErrorString;
      
  }
 //CIP-2288-RS.8/18/22.End.    
    
  @AuraEnabled
  public static Integer queryPricingCount(Id recId) {
    try {
      return [
        SELECT COUNT()
        FROM Approval_History__c
        WHERE
          Parent_Status__c = 'Approved'
          AND Status__c LIKE '%Submitted'
          AND Deal__c = :recId
          AND Approval_Type__c LIKE '%Pricing%'
      ];
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  // public wrapper name, userId

  public class returnItem {
    public String recordType;
    public String oppName;
    public Boolean wrongUser;
    public List<String> nullFields;
    public Boolean wrongStage;
    public Boolean noUploads;
    public List<String> otherMessage;
    public Boolean isDisplayGLC = false;
    public Boolean allowBypass = false;
  }

  @AuraEnabled
  public static void bypassApproval(
    String recordId,
    String recordName
  ) {

    Opportunity newOpp = new Opportunity(
      Id = recordId,
      Approval_Status__c = 'Standard Pricing - Approval Not Needed'
    );
    update newOpp;

    String qs = 'SELECT GLC_Approved__c,RecordType.DeveloperName,OwnerId,Name,Fee__c,CAF_Upfront_Fee__c,Loan_Size__c,Spread_BPS__c,Swap_Rate__c,Exit_Fee__c,Max_Advance_Fee__c,StageName,LOC_Program_Type__c,LOC_Loan_Type__c,Product_Sub_Type__c,Type,Broker_Fees__c, YSP_perc__c, Deal_Intro_Sub_Source__c,Exception__c,';

    for (String field : termFields.keySet()) {
      if (!qs.contains(field + ',')) {
        qs += field + ',';
      }
    }

    for (String field : bridgeFields.keySet()) {
      if (!qs.contains(field + ',')) {
        qs += field + ',';
      }
    }

    for (String field : sabFields.keySet()) {
      if (!qs.contains(field + ',')) {
        qs += field + ',';
      }
    }

    qs += ' (SELECT Id FROM Properties__r) FROM Opportunity WHERE Id = :recordId LIMIT 1';
    Opportunity opp = (Opportunity) Database.query(qs);

    Approval_History__c ahc = new Approval_History__c(
        Parent_Status__c = 'Approved',
        Deal__c = recordId,
        Name = 'Pricing Review Request: ' + recordName.left(50),
        ProcessName__c = 'Standard SAB Pricing Review',
        Approver__c = UserInfo.getName(),
        Actor__c = UserInfo.getUserId(),
        Role__c = 'Submitter',
        Date_Acted__c = System.now(),
        Status__c = 'Approved',
        Status_Text__c = 'Approved',
        Comments__c = 'Bypassed by submitter.',
        Approval_Type__c = 'Pricing Review',
        Requested_Loan_Size__c = opp.Loan_Size__c,
        Requested_Exit_Fee__c = opp.Exit_Fee__c,
        Origination_Fee__c = opp.CAF_Upfront_Fee__c,
        Deal_Stage_At_Time_of_Submission__c = opp.StageName,
        Advance_Fee_Percent__c = opp.Fee__c,
        Swap_Rate__c = opp.Swap_Rate__c,
        Spread__c = opp.Spread_BPS__c,
        Foreign_National_picklist__c = opp.Foreign_National_picklist__c
      );
      insert ahc;
  }

  @AuraEnabled
  public static String startApproval(
    String recordId,
    String recordName,
    String comments,
    String resolution,
    String recordType
  ) {
    update new Opportunity(
      Id = recordId,
      Approved_By_Underwriter__c = null,
      Approved_By_Capital_Markets__c = null
    );

    System.debug('starting approval through server code');

    String qs = 'SELECT GLC_Approved__c,RecordType.DeveloperName,OwnerId,Name,Fee__c,CAF_Upfront_Fee__c,Loan_Size__c,Spread_BPS__c,Swap_Rate__c,Exit_Fee__c,Max_Advance_Fee__c,StageName,LOC_Program_Type__c,LOC_Loan_Type__c,Product_Sub_Type__c,Type,Broker_Fees__c, YSP_perc__c, Deal_Intro_Sub_Source__c,Exception__c,';

    for (String field : termFields.keySet()) {
      if (!qs.contains(field + ',')) {
        qs += field + ',';
      }
    }

    for (String field : bridgeFields.keySet()) {
      if (!qs.contains(field + ',')) {
        qs += field + ',';
      }
    }

    for (String field : sabFields.keySet()) {
      if (!qs.contains(field + ',')) {
        qs += field + ',';
      }
    }

    // qs = qs.substringBeforeLast(',');
    qs += ' (SELECT Id FROM Properties__r) FROM Opportunity WHERE Id = :recordId LIMIT 1';
    Opportunity opp = (Opportunity) Database.query(qs);

    Boolean isReprice = queryPricingCount(recordId) > 0;

    Boolean oppUpdated = false;

    if (String.isNotBlank(resolution)) {
      opp.GLC_Approved__c = true;
      oppUpdated = true;
    }

    if (opp.StageName == 'Approved by Committee' && isReprice) {
      opp.StageName = 'Underwriting';
      opp.Apex_Context__c = true;
      oppUpdated = true;
    }

    if (oppUpdated) {
      update opp;
    }

    String processName = '';

    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
    req.setComments(comments);
    req.setObjectId(recordId);
    req.setSubmitterId(userId);
    req.setSkipEntryCriteria(true);

    if (
      (opp.LOC_Loan_Type__c == 'Single Asset (1-4 Unit)' ||
      opp.LOC_Loan_Type__c == 'Single Asset (5-10 Unit)') &&
      opp.LOC_Program_Type__c == 'Standard'
    ) {
      if (opp.Loan_Size__c < 1500000 && !opp.Exception__c) {
        processName = 'Standard_SAB_Pricing_Review_Below_1_5M';
        req.setProcessDefinitionNameOrId('Standard_SAB_Pricing_Review_Below_1_5M');
      } else {
        processName = 'Custom_SAB_Pricing_Review';
        req.setProcessDefinitionNameOrId('Custom_SAB_Pricing_Review');
      }
    } else if (
      (opp.LOC_Loan_Type__c == 'Single Asset (1-4 Unit)' ||
      opp.LOC_Loan_Type__c == 'Single Asset (5-10 Unit)') &&
      opp.LOC_Program_Type__c == 'Custom'
    ) {
      processName = 'Custom_SAB_Pricing_Review';
      req.setProcessDefinitionNameOrId('Custom_SAB_Pricing_Review');
    } else if (opp.LOC_Loan_Type__c == 'Credit Line') {
      if (opp.Loan_Size__c < 5000000) {
        System.debug('inside here, looking for a LOC process');
        processName = 'Bridge_LOC_Pricing_Review_Capital_Market';
        req.setProcessDefinitionNameOrId(
          'Bridge_LOC_Pricing_Review_Capital_Market'
        );
      } else {
        System.debug('inside here, looking for a LOC process');
        processName = 'Bridge_LOC_Pricing_Review';
        req.setProcessDefinitionNameOrId('Bridge_LOC_Pricing_Review');
        // req.setProcessDefinitionNameOrId('Test_Willie_Dinorah_Bridge');
        // req.setProcessDefinitionNameOrId('Test_Marc_Winnie_LOC');
      }
    } else if (opp.LOC_Loan_Type__c == 'Multifamily/CRE' || opp.LOC_Loan_Type__c == 'Build to Rent') {
      System.debug('inside here, looking for a LOC process');
      processName = 'Bridge_LOC_Pricing_Review';
      req.setProcessDefinitionNameOrId('Bridge_LOC_Pricing_Review');
    } else if (opp.LOC_Loan_Type__c == 'Term Loan') {
      if (
        opp.Loan_Size__c < 5000000 &&
        opp.Product_Sub_Type__c != 'Short Term Rental'
      ) {
        System.debug('inside here, looking for term loan approval process');
        processName = 'Term_Pricing_Review_Capital_Markets';
        req.setProcessDefinitionNameOrId(
          isReprice
            ? 'Term_Repricing_Review_Capital_Markets'
            : 'Term_Pricing_Review_Capital_Markets'
        );
      } else {
        System.debug('inside here, looking for term loan approval process');
        processName = 'Term_Pricing_Review';
        req.setProcessDefinitionNameOrId(
          isReprice ? 'Term_Repricing_Review' : 'Term_Pricing_Review'
        );
        // req.setProcessDefinitionNameOrId('Test_Willie_Dinorah_Term');
        // req.setProcessDefinitionNameOrId('Test_Marc_Winnie_Term');
      }
    }

    try {
      Approval.ProcessResult result = Approval.process(req);
      Id processInstanceId = result.getInstanceId();
      Id oppId = result.getEntityId();
      String status = result.getInstanceStatus();
      List<Id> workItemIds = result.getNewWorkitemIds();

      System.debug('this is workItemIds');
      System.debug(workItemIds);

      Map<String, Boolean> unlockApprovalMap = util.compileApprovalUnlockMap();
      if (unlockApprovalMap.get(processName)) {
        Approval.UnlockResult lr = Approval.unlock(oppId);
      }

      List<Approval_History__c> history = [
        SELECT Id
        FROM Approval_History__c
        WHERE Deal__c = :oppId
      ];
      String customStatus = 'Submitted';
      if (history.size() > 0) {
        if (opp.GLC_Approved__c) {
          customStatus = 'Re-submitted ??? Post GLC';
        } else {
          customStatus = 'Re-submitted';
        }
      }

      List<Approval_History__c> ahList = new List<Approval_History__c>();
      Approval_History__c ahc = new Approval_History__c(
        Process_Instance_Id__c = processInstanceId,
        Parent_Status__c = status,
        Deal__c = oppId,
        Name = 'Pricing Review Request: ' + recordName.left(50),
        ProcessName__c = processName.replace('_', ' '),
        Approver__c = UserInfo.getName(),
        Actor__c = UserInfo.getUserId(),
        Role__c = 'Submitter',
        Date_Acted__c = System.now(),
        Status__c = customStatus,
        Status_Text__c = customStatus,
        Comments__c = comments,
        Approval_Type__c = 'Pricing Review',
        Resolution__c = resolution,
        Requested_Loan_Size__c = opp.Loan_Size__c,
        Requested_Exit_Fee__c = opp.Exit_Fee__c,
        Origination_Fee__c = opp.CAF_Upfront_Fee__c,
        Deal_Stage_At_Time_of_Submission__c = opp.StageName,
        Advance_Fee_Percent__c = opp.Fee__c,
        Swap_Rate__c = opp.Swap_Rate__c,
        Spread__c = opp.Spread_BPS__c,
        Foreign_National_picklist__c = opp.Foreign_National_picklist__c
      );
      insert ahc;
      for (Integer i = 0; i < workItemIds.size(); i++) {
        Approval_History__c a = new Approval_History__c(
          Process_Instance_Id__c = processInstanceId,
          Process_Id__c = workItemIds[i],
          ProcessName__c = processName.replace('_', ' '),
          Parent_Status__c = status,
          Deal__c = oppId,
          Name = 'Pricing Review Approval: ' + recordName.left(50),
          Approver__c = 'Approver',
          Status__c = 'Pending',
          Status_Text__c = 'Pending',
          Approval_Type__c = 'Pricing Review',
          Resolution__c = resolution,
          Origination_Fee__c = opp.CAF_Upfront_Fee__c,
          Deal_Stage_At_Time_of_Submission__c = opp.StageName,
          Advance_Fee_Percent__c = opp.Fee__c,
          Swap_Rate__c = opp.Swap_Rate__c,
          Spread__c = opp.Spread_BPS__c,
          Foreign_National_picklist__c = opp.Foreign_National_picklist__c
        );

        if (workItemIds.size() == 1) {
          if (
            processName != 'Term_Pricing_Review_Capital_Markets' &&
            processName != 'Bridge_LOC_Pricing_Review_Capital_Market' && 
            processName != 'Standard_SAB_Pricing_Review_Below_1_5M'
          ) {
            a.Status_Text__c = 'Pending: Underwriting Review';
          } else {
            a.Status_Text__c = 'Pending: Capital Markets Review';
          }
        }

        //if (i == 0){
        //a.Approver__c = 'Underwriter';
        //a.Name = 'Underwriter Approval: ' + recordName;
        //a.Role__c = 'Underwriter';
        //} else if (i == 1){
        //a.Approver__c = 'Capital Market';
        //a.Name = 'Capital Market Approval: ' + recordName;
        //a.Role__c = 'Capital Market';
        //}
        ahList.add(a);
      }
      insert ahList;
      //System.debug('this is ahList');
      //System.debug(ahList);
      if (result.isSuccess()) {
        Task t = new Task(
          WhatId = recordId,
          Description = 'Sent pricing request for ' + recordName.left(50),
          Status = 'Completed',
          Subject = 'Sent Pricing Request',
          ActivityDate = system.today()
        );
        insert t;
        System.debug(t);

        List<Opportunity> oList = [
          SELECT Id, Name, RecordType.DeveloperName, OwnerId, CAF_Analyst__c
          FROM Opportunity
          WHERE Id = :oppId
          LIMIT 1
        ];

        if (oList.size() > 0) {
          Opportunity o = oList[0];
          String s =
            ' ' +
            UserInfo.getFirstName() +
            ' ' +
            UserInfo.getLastName() +
            ' has submitted a Pricing Review Request for ' +
            o.Name +
            '.';
          ApprovalAttachments_lightningController.createNotification(
            o,
            UserInfo.getUserId(),
            'all',
            s,
            workItemIds
          );
          System.debug('successful notification');
        }
      }
      if (isReprice) {
        sendRepricingEmail(oppId);
      }
      return 'The record has been submitted for review.';
    } catch (Exception e) {
      System.debug(e.getMessage() + ' ???? ?????????? ?????????? ' + e.getLineNumber());
      return e.getMessage();
    }
  }

  @future
  public static void sendRepricingEmail(String oppId) {
    EmailTemplate template = [
      SELECT Id, DeveloperName
      FROM EmailTemplate
      WHERE DeveloperName = 'Pricing_Review_Request_Courtesy'
    ];

    if (template == null) {
      return;
    }
    Opportunity opp = [
      SELECT Id, Closer__c, Contact__c, Underwriter__c
      FROM Opportunity
      WHERE Id = :oppId
    ];
    Set<Id> recipientIds = new Set<Id>();
    recipientIds.addAll(repriceCcUsers);
    if (opp.Closer__c != null) {
      recipientIds.add(opp.Closer__c);
    }
    if (opp.Underwriter__c != null) {
      recipientIds.add(opp.Underwriter__c);
    }

    List<Id> recipIdsAsList = new List<Id>();
    recipIdsAsList.addAll(recipientIds);
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    email.setToAddresses(recipIdsAsList);
    email.setTemplateId(template.Id);
    email.setTargetObjectId(opp.Contact__c);
    email.setTreatTargetObjectAsRecipient(false);
    email.setWhatId(opp.Id);
    List<OrgWideEmailAddress> owea = [
      SELECT Id
      FROM OrgWideEmailAddress
      WHERE Address = 'caf-apps@cvest.com'
    ];
    if (owea.size() > 0) {
      email.setOrgWideEmailAddressId(owea[0].Id);
    }
    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
  }
}