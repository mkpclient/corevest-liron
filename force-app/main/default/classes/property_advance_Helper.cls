public class property_advance_Helper {
  /*
   * Property Fields
   * Current_Outstanding_Loan_Amount__c
   * Approved_Advance_Max__c
   * Approved_Advance_Amount
   * Property_Advance_Number__c
   * Reno_Advance_Amount_Remaining__c
   * Initial_Disbursement_Remaining__c
   * Renovation_Advance_Amount_Used__c
   * Initial_Disbursement_Used__c
   * Approved_Advance_Amount_Used__c
   * Advacne_Status_text__c
   * Property__c
   */
  public static Map<String, Schema.SObjectField> FIELD_MAP = Schema.SObjectType.Property_Advance__c.fields.getMap();

  /**
   * @name beforeInsert
   * @description
   * @param
   **/
  public static void beforeInsert(List<Property_Advance__c> newList) {
    Set<Id> propertyIds = new Set<Id>();
    Set<Id> advanceIds = new Set<Id>();

    for (Property_Advance__c adv : newList) {
      propertyIds.add(adv.Property__c);
      advanceIds.add(adv.Advance__c);
    }

    Map<Id, Advance__c> constAdvMap = new Map<Id, Advance__c>(
      [
        SELECT Id
        FROM Advance__c
        WHERE RecordType_Name__c = 'Construction Advance' AND Id IN :advanceIds
      ]
    );

    Map<Id, Property__c> propertyMap = new Map<Id, Property__c>(
      [
        SELECT
          Id,
          Number_of_Advances__c,
          Acquisition_Price__c,
          Appraised_Value_Amount__c,
          Deal__r.Holdback_To_Rehab_Ratio__c,
          Deal__r.LTC__c,
          Deal__r.LTV__c,
          Approved_Advance_Amount__c,
          Advance_Fee__c,
          BPO_Appraisal_Fee__c,
          Doc_Prep_Fee__c,
          Max_LTC_Dollar__c,
          Max_LTV_Dollar__c,
          Escrow_Agent__c,
          Title_Company__c,
          Title_Company_Contact__c,
          // Max_LTC_Dollar_nooverride__c,
          Reno_Advance_Amount__c,
          Initial_Disbursement_remaining__c,
          Status__c,
          // Max_LTV_Dollar_nooverride__c,
          BlackSquare_Fee__c,
          Initial_Disbursement__c,
          Approved_Renovation_Holdback__c,
          RecordType_Name__c,
          Advance_Fee_formula__c,
          Total_Cost_Basis__c,
          After_Repair_Value__c,
          Origination_Fee_Amnt__c,
          Broker_Adv_Fee_Amnt__c,
          Perc_of_Rehab_Budget__c,
          Daily_Interest_Rate__c,
          Approved_Advance_Amount_Max__c,
          Rehab_Budget__c,
          Appraisal_Due_Date__c,
          Assignment_Fee__c,
          Report_Fee_BR__c,
          Report_Fee_GEO__c,
          Report_Fee_PCR__c,
          Report_Fee_PH1__c,
          Report_Fee_PH2__c,
          Report_Fee_PC__c,
          Report_Fee_SEI__c,
          Report_Fee_SUY__c,
          Report_Fee_ZN__c,
          (
            SELECT Id, Name, Property_Advance_Number__c
            FROM Property_Advances__r
            WHERE Property_Advance_Number__c != NULL
            ORDER BY Property_Advance_Number__c DESC
          )
        FROM Property__c
        WHERE Id IN :propertyIds
      ]
    );

    for (Property_Advance__c adv : newList) {
      Property__c property = propertyMap.get(adv.Property__c);
      adv.Purchase_Price__c = property.Acquisition_Price__c;
      adv.Approved_Assignment_Fee__c = property.Assignment_Fee__c;
      adv.BPO_APpraisal_Value__c = property.Appraised_Value_Amount__c; //property.Status__c == 'In Process' ? 0 : property.BPO_Appraisal_Value__c;
      adv.Max_LTC__c = property.Deal__r.LTC__c;
      adv.Max_LTC_Dollar__c = property.Max_LTC_Dollar__c;
      // adv.Max_LTC_Dollar_nooverride__c = property.Max_LTC_Dollar_nooverride__c;
      adv.Max_LTV__c = property.Deal__r.LTV__c;
      adv.Max_LTV_Dollar__c = property.Max_LTV_Dollar__c;
      // adv.Max_LTV_Dollar_nooverride__c = property.Max_LTV_Dollar_nooverride__c;
      // adv.Approved_Advance_Amount__c = property.Approved_Advance_Amount__c;
      adv.Escrow_Agent__c = property.Escrow_Agent__c;
      adv.Title_Company__c = property.Title_Company__c;
      adv.Title_Company_Contact__c = property.Title_Company_Contact__c;
      //adv.Initial_Disbursement__c = property.Initial_Disbursement__c;
      // adv.Initial_Disbursement__c = property.Initial_Disbursement_remaining__c;
      adv.Total_Cost_Basis__c = property.Total_Cost_Basis__c;
      adv.After_Repair_Value__c = property.After_Repair_Value__c;
      if (
        property.Number_of_Advances__c >= 1 ||
        constAdvMap.containsKey(adv.Advance__c)
      ) {
        adv.Holdback_To_Rehab_Ratio__c = property.Deal__r.Holdback_To_Rehab_Ratio__c;
        adv.Renovation_Reserve__c =
          (adv.Approved_Amount__c != null ? adv.Approved_Amount__c : 0) *
          (property.Deal__r.Holdback_To_Rehab_Ratio__c / 100);
      } else {
        adv.Renovation_Reserve__c = property.Reno_Advance_Amount__c;
      }
      adv.Approved_Advance_Amount_Max__c = property.Approved_Advance_Amount_Max__c;
      adv.Approved_Renovation_Holdback__c = property.Approved_Renovation_Holdback__c;
      adv.Renovation_Budget__c = property.Rehab_Budget__c;
      adv.Appraisal_Due_Date__c = property.Appraisal_Due_Date__c;
      //if(property.RecordType_Name__c == 'Renovation Advance'){
      //adv.Renovation_Advance__c = property.Reno_Advance_Amount__c;
      //}

      //if(property.RecordType_Name__c == 'Renovation Reserve'){
      //adv.Renovation_Reserve__c = property.Reno_Advance_Amount__c;
      //}

      adv.Perc_of_Rehab_Budget__c = property.Perc_of_Rehab_Budget__c;
      // adv.Origination_Fee__c = property.Origination_Fee_Amnt__c;
      //adv.Daily_Interest_Rate__c = property.Daily_Interest_Rate__c;

      //if(adv.Advance_Fee__c == null){
      //    adv.Advance_Fee__c = property.Advance_Fee_formula__c;
      //}

      if (property.Number_of_Advances__c == 0) {
        adv.Initial_Disbursement__c = property.Initial_Disbursement__c;
        adv.Broker_Advance_Fee__c = property.Broker_Adv_Fee_Amnt__c;
        adv.Advance_Fee__c = property.Advance_Fee_formula__c;
        adv.Origination_Fee__c = property.Origination_Fee_Amnt__c;
        adv.BPO_Appraisal_Fee__c = property.BPO_Appraisal_Fee__c;
        adv.Budget_Review_Report_Fee__c = property.Report_Fee_BR__c;
        adv.Geotechnical_Report_Fee__c = property.Report_Fee_GEO__c;
        adv.PCR_Report_Fee__c = property.Report_Fee_PCR__c;
        adv.Phase_1_Report_Fee__c = property.Report_Fee_PH1__c;
        adv.Phase_2_Report_Fee__c = property.Report_Fee_PH2__c;
        adv.Property_Condition_Report_Fee__c = property.Report_Fee_PC__c;
        adv.Seismic_Report_Fee__c = property.Report_Fee_SEI__c;
        adv.Survey_Report_Fee__c = property.Report_Fee_SUY__c;
        adv.Zoning_Report_Fee__c = property.Report_Fee_ZN__c;
        if (
          adv.Purchase_Price__c == null ||
          adv.Purchase_Price__c == 0 ||
          adv.Initial_Disbursement__c == null ||
          adv.Initial_Disbursement__c == 0
        ) {
          //|| adv.BPO_Appraisal_Value__c == null || adv.BPO_Appraisal_Value__c == 0){
          adv.Initial_LTC_percent__c = 0;
        } else {
          //adv.Initial_LTC_percent__c = adv.Approved_Advance_Amount__c/Math.max(adv.Purchase_Price__c, adv.BPO_Appraisal_Value__c);
          adv.Initial_LTC_percent__c =
            adv.Initial_Disbursement__c / adv.Purchase_Price__c;
        }

        if (
          adv.BPO_Appraisal_Value__c == null ||
          adv.BPO_Appraisal_Value__c == 0 ||
          adv.Initial_Disbursement__c == null ||
          adv.Initial_Disbursement__c == 0
        ) {
          adv.As_Is_LTV_percent__c = 0;
        } else {
          adv.As_Is_LTV_percent__c =
            adv.Initial_Disbursement__c / adv.BPO_Appraisal_Value__c;
          //adv.As_Is_LTV_percent__c = adv.Approved_Advance_Amount__c/adv.BPO_Appraisal_Value__c;
        }
      }

      // adv.BPO_Appraisal_Fee__c = property.Status__c == 'In Process'
      //   ? 0
      //   : property.BPO_Appraisal_Fee__c;
      adv.Doc_Prep_Fee__c = property.Doc_Prep_Fee__c;
      adv.BlackSquare_Fee__c = property.BlackSquare_Fee__c;

      if (adv.Total_Cost_Basis__c == null || adv.Total_Cost_Basis__c == 0) {
        adv.Total_LTC_percent__c = 0;
      } else {
        adv.Total_LTC_percent__c =
          adv.Approved_Advance_Amount_Calc__c / adv.Total_Cost_Basis__c;
        //adv.Total_LTC_percent__c = adv.Approved_Advance_Amount__c/adv.Purchase_Price__c;
      }

      if (adv.After_Repair_Value__c == null || adv.After_Repair_Value__c == 0) {
        adv.After_Repair_Value__c = 0;
      } else {
        adv.ARV_LTV_percent__c =
          adv.Approved_Advance_Amount_Calc__c / adv.After_Repair_Value__c;
      }

      if (String.isBlank(adv.Name)) {
        if (propertyMap.get(adv.Property__c).Property_Advances__r.size() > 0) {
          adv.Name = String.valueOf(
            propertyMap.get(adv.Property__c)
              .Property_Advances__r[0]
              .Property_Advance_Number__c + 1
          );
        } else {
          adv.Name = '1';
        }
      }

      adv.Advance_Status_text__c = adv.Advance_Status__c;
    }

    Map<Id, Map<Id, List<Property_Advance__c>>> wireMap = new Map<Id, Map<Id, List<Property_Advance__c>>>();

    for (Property_Advance__c adv : newList) {
      if (adv.Escrow_Agent__c != null) {
        if (!wireMap.containsKey(adv.Advance__c)) {
          wireMap.put(adv.Advance__c, new Map<Id, List<Property_Advance__c>>());
        }

        if (!wireMap.get(adv.Advance__c).containsKey(adv.Escrow_Agent__c)) {
          wireMap.get(adv.Advance__c)
            .put(adv.Escrow_Agent__c, new List<Property_Advance__c>());
        }

        wireMap.get(adv.Advance__c).get(adv.Escrow_Agent__c).add(adv);
      }

      if (adv.Title_Company__c != null) {
        if (!wireMap.containsKey(adv.Advance__c)) {
          wireMap.put(adv.Advance__c, new Map<Id, List<Property_Advance__c>>());
        }

        if (!wireMap.get(adv.Advance__c).containsKey(adv.Title_Company__c)) {
          wireMap.get(adv.Advance__c)
            .put(adv.Title_Company__c, new List<Property_Advance__c>());
        }

        wireMap.get(adv.Advance__c).get(adv.Title_Company__c).add(adv);
      }
    }

    //after insert

    List<Wire__c> wireUpsert = new List<Wire__c>();

    for (Wire__c wire : [
      SELECT
        Id,
        Advance__c,
        Advance_Fee__c,
        Approved_Advance_Amount__c,
        BPO_Appraisal_Fee__c,
        Doc_Prep_Fee__c,
        BlackSquare_Fee__c,
        Escrow_Agent__c,
        Origination_Fee__c,
        Daily_Interest_Rate__c
      FROM Wire__c
      WHERE Escrow_Agent__c != NULL AND Advance__c IN :wireMap.keySet()
    ]) {
      if (wireMap.get(wire.Advance__c).containsKey(wire.Escrow_Agent__c)) {
        for (
          Property_Advance__c adv : wireMap.get(wire.Advance__c)
            .get(wire.Escrow_Agent__c)
        ) {
          wire.Advance_Fee__c =
            util.fixNull(wire.Advance_Fee__c) +
            util.fixNull(adv.Advance_Fee__c);
          wire.Approved_Advance_Amount__c =
            util.fixNull(wire.Approved_Advance_Amount__c) +
            util.fixNull(adv.Approved_Advance_Amount_Calc__c);
          wire.BPO_Appraisal_Fee__c =
            util.fixNull(wire.BPO_Appraisal_Fee__c) +
            util.fixNull(adv.BPO_Appraisal_Fee__c);
          wire.Doc_Prep_Fee__c =
            util.fixNull(wire.Doc_Prep_Fee__c) +
            util.fixNull(adv.Doc_Prep_Fee__c);
          wire.BlackSquare_Fee__c = util.fixNull(
            wire.BlackSquare_Fee__c + util.fixNull(adv.Blacksquare_Fee__c)
          );
          wire.Origination_Fee__c = util.fixNull(
            wire.Origination_Fee__c + util.fixNull(adv.Origination_Fee__c)
          );
          //wire.Daily_Interest_Rate__c = util.fixNull(wire.Daily_Interest_Rate__c+  util.fixNull(adv.Daily_Interest_Rate__c));
        }

        wireUpsert.add(wire);
        wireMap.get(wire.Advance__c).remove(wire.Escrow_Agent__c);
      }
    }

    for (Id advId : wireMap.keySet()) {
      for (Id escrowId : wireMap.get(advId).keySet()) {
        Wire__c wire = new Wire__c();
        wire.Advance__c = advId;
        wire.Escrow_Agent__c = escrowId;
        wire.Advance_Fee__c = 0;
        wire.Approved_Advance_Amount__c = 0;
        wire.BPO_Appraisal_Fee__c = 0;
        wire.Doc_Prep_Fee__c = 0;
        wire.BlackSquare_Fee__c = 0;
        wire.Origination_Fee__c = 0;
        //wire.Daily_Interest_Rate__c = 0;

        for (Property_Advance__c adv : wireMap.get(advId).get(escrowId)) {
          wire.Advance_Fee__c += util.fixNull(adv.Advance_Fee__c);
          wire.Approved_Advance_Amount__c += util.fixNull(
            adv.Approved_Advance_Amount_Calc__c
          );
          wire.BPO_Appraisal_Fee__c += util.fixNull(adv.BPO_Appraisal_Fee__c);
          wire.Doc_Prep_Fee__c += util.fixNull(adv.Doc_Prep_Fee__c);
          wire.BlackSquare_Fee__c += util.fixNull(adv.BlackSquare_Fee__c);
          wire.Origination_Fee__c += util.fixNull(adv.Origination_Fee__c);
          //wire.Daily_Interest_Rate__c += util.fixNull(adv.Daily_Interest_Rate__c);
        }

        wireUpsert.add(wire);
      }
    }

    if (wireMap.size() > 0) {
      upsert wireUpsert;
    }

    List<Property_Advance__c> advUpdate = new List<Property_Advance__c>();
    for (Property_Advance__c adv : newList) {
      for (Wire__c w : wireUpsert) {
        if (
          w.Advance__c == adv.Advance__c &&
          adv.Escrow_Agent__c == w.Escrow_Agent__c
        ) {
          adv.Wire__c = w.Id;
          continue;
        }
      }
    }
  }

  /**
   * @name afterInsert
   * @description
   * @param
   **/
  public static void afterInsert(List<Property_Advance__c> newList) {
    Set<Id> advIds = new Set<Id>();
    for (Property_Advance__c pAdv : newList) {
      advIds.add(pAdv.Advance__c);
    }

    if (advIds.size() > 0) {
      // rollupAdvances(advIds);
      setAdvRecordTypes(advIds);
    }
  }

  /**
   * @name beforeUpdate
   * @description
   * @param
   **/
  public static void beforeUpdate(
    List<Property_Advance__c> newList,
    List<Property_Advance__c> oldList
  ) {
    Map<Id, Advance__c> constAdvMap = new Map<Id, Advance__c>(
      [
        SELECT Id
        FROM Advance__c
        WHERE
          Id IN (
            SELECT Advance__c
            FROM Property_Advance__c
            WHERE Id IN :newList
          )
          AND RecordType_Name__c LIKE 'Construction%'
      ]
    );

    for (Integer i = 0; i < newList.size(); i++) {
      if (
        constAdvMap.containsKey(newList[i].Advance__c) &&
        (newList[i].Approved_Amount__c != oldList[i].Approved_Amount__c ||
        newList[i].Holdback_To_Rehab_Ratio__c !=
        oldList[i].Holdback_To_Rehab_Ratio__c) &&
        newList[i].Holdback_To_Rehab_Ratio__c != null &&
        newList[i].Approved_Amount__c != null
      ) {
        newList[i].Renovation_Reserve__c =
          newList[i].Approved_Amount__c *
          (newList[i].Holdback_To_Rehab_Ratio__c / 100);
      }
      //if(newList[i].Advance_Status__c != oldList[i].Advance_Status__c){
      newList[i].Advance_Status_text__c = newList[i].Advance_Status__c;
      //}
    }
    Set<Id> propertyIds = new Set<Id>();

    for (Property_Advance__c adv : newList) {
      if (adv.Advance_Status__c != 'Completed') {
        propertyIds.add(adv.Property__c);
      }
    }
    Map<Id, Property__c> propertyMap = new Map<Id, Property__c>();
    if (propertyIds.size() > 0) {
      propertyMap = new Map<Id, Property__c>(
        [
          SELECT
            Id,
            Number_of_Advances__c,
            Acquisition_Price__c,
            Appraised_Value_Amount__c,
            Deal__r.LTC__c,
            Deal__r.LTV__c,
            Approved_Advance_Amount__c,
            Advance_Fee__c,
            BPO_Appraisal_Fee__c,
            Doc_Prep_Fee__c,
            Max_LTC_Dollar__c,
            Max_LTV_Dollar__c,
            Escrow_Agent__c,
            // Max_LTC_Dollar_nooverride__c,
            // Max_LTV_Dollar_nooverride__c,
            Initial_Disbursement__c,
            Initial_Disbursement_Remaining__c,
            Advance_Fee_formula__c,
            Total_Cost_Basis__c,
            After_Repair_Value__c,
            Approved_Renovation_Holdback__c,
            Reno_Advance_Amount__c,
            Status__c,
            BlackSquare_Fee__c,
            Daily_Interest_Rate__c,
            Origination_Fee_Amnt__c,
            Approved_Advance_Amount_Max__c,
            Broker_Adv_Fee_Amnt__c,
            Rehab_Budget__c,
            Appraisal_Due_Date__c,
            Title_Company__c,
            Title_Company_Contact__c,
            Assignment_Fee__c,
            Report_Fee_BR__c,
            Report_Fee_GEO__c,
            Report_Fee_PCR__c,
            Report_Fee_PH1__c,
            Report_Fee_PH2__c,
            Report_Fee_PC__c,
            Report_Fee_SEI__c,
            Report_Fee_SUY__c,
            Report_Fee_ZN__c
          FROM Property__c
          WHERE Id IN :propertyIds
        ]
      );
    }

    for (Property_Advance__c adv : newList) {
      if (
        adv.Advance_Status__c != 'Completed' &&
        propertyMap.containsKey(adv.Property__c)
      ) {
        Property__c property = propertyMap.get(adv.Property__c);
        adv.Purchase_Price__c = property.Acquisition_Price__c;
        adv.Approved_Assignment_Fee__c = property.Assignment_Fee__c;
        adv.BPO_APpraisal_Value__c = property.Appraised_Value_Amount__c;
        adv.Max_LTC__c = property.Deal__r.LTC__c;
        adv.Max_LTC_Dollar__c = property.Max_LTC_Dollar__c;
        // adv.Max_LTC_Dollar_nooverride__c = property.Max_LTV_Dollar_nooverride__c;
        adv.Max_LTV__c = property.Deal__r.LTV__c;
        adv.Max_LTV_Dollar__c = property.Max_LTV_Dollar__c;
        // adv.Max_LTV_Dollar_nooverride__c = property.Max_LTV_Dollar_nooverride__c;
        // adv.Approved_Advance_Amount__c = property.Approved_Advance_Amount__c;
        adv.Escrow_Agent__c = property.Escrow_Agent__c;
        // adv.Initial_Disbursement__c = property.Initial_Disbursement_remaining__c;
        adv.Total_Cost_Basis__c = property.Total_Cost_Basis__c;
        adv.After_Repair_Value__c = property.After_Repair_Value__c;
        //adv.Renovation_Reserve__c = property.Approved_Renovation_Holdback__c;
        if (!constAdvMap.containsKey(adv.Advance__c)) {
          adv.Renovation_Reserve__c = property.Reno_Advance_Amount__c;
        }
        adv.Approved_Advance_Amount_Max__c = property.Approved_Advance_Amount_Max__c;
        adv.Approved_Renovation_Holdback__c = property.Approved_Renovation_Holdback__c;
        adv.Renovation_Budget__c = property.Rehab_Budget__c;
        adv.Appraisal_Due_Date__c = property.Appraisal_Due_Date__c;
        adv.Title_Company__c = property.Title_Company__c;
        adv.Title_Company_Contact__c = property.Title_Company_Contact__c;

        if (property.Number_of_Advances__c == 0) {
          adv.Initial_Disbursement__c = property.Initial_Disbursement__c;
          adv.Broker_Advance_Fee__c = property.Broker_Adv_Fee_Amnt__c;
          adv.Advance_Fee__c = property.Advance_Fee_formula__c;
          adv.Origination_Fee__c = property.Origination_Fee_Amnt__c;
          adv.BPO_Appraisal_Fee__c = property.BPO_Appraisal_Fee__c;
          adv.Budget_Review_Report_Fee__c = property.Report_Fee_BR__c;
          adv.Geotechnical_Report_Fee__c = property.Report_Fee_GEO__c;
          adv.PCR_Report_Fee__c = property.Report_Fee_PCR__c;
          adv.Phase_1_Report_Fee__c = property.Report_Fee_PH1__c;
          adv.Phase_2_Report_Fee__c = property.Report_Fee_PH2__c;
          adv.Property_Condition_Report_Fee__c = property.Report_Fee_PC__c;
          adv.Seismic_Report_Fee__c = property.Report_Fee_SEI__c;
          adv.Survey_Report_Fee__c = property.Report_Fee_SUY__c;
          adv.Zoning_Report_Fee__c = property.Report_Fee_ZN__c;
        }

        // adv.BPO_Appraisal_Fee__c = property.Status__c == 'In Process'
        //   ? 0
        //   : property.BPO_Appraisal_Fee__c;
        adv.Doc_Prep_Fee__c = property.Doc_Prep_Fee__c;
        adv.BlackSquare_Fee__c = property.BlackSquare_Fee__c;
        //adv.Daily_Interest_Rate__c = property.Daily_Interest_Rate__c;

        if (
          adv.Purchase_Price__c == null ||
          adv.Purchase_Price__c == 0 ||
          adv.Initial_Disbursement__c == null ||
          adv.Initial_Disbursement__c == 0
        ) {
          //|| adv.BPO_Appraisal_Value__c == null || adv.BPO_Appraisal_Value__c == 0){
          adv.Initial_LTC_percent__c = 0;
        } else {
          //adv.Initial_LTC_percent__c = adv.Approved_Advance_Amount__c/Math.max(adv.Purchase_Price__c, adv.BPO_Appraisal_Value__c);
          adv.Initial_LTC_percent__c =
            adv.Initial_Disbursement__c / adv.Purchase_Price__c;
        }

        if (adv.Total_Cost_Basis__c == null || adv.Total_Cost_Basis__c == 0) {
          adv.Total_LTC_percent__c = 0;
        } else {
          adv.Total_LTC_percent__c =
            adv.Approved_Advance_Amount_Calc__c / adv.Total_Cost_Basis__c;
          //adv.Total_LTC_percent__c = adv.Approved_Advance_Amount__c/adv.Purchase_Price__c;
        }

        if (
          adv.After_Repair_Value__c == null ||
          adv.After_Repair_Value__c == 0
        ) {
          adv.After_Repair_Value__c = 0;
        } else {
          adv.ARV_LTV_percent__c =
            adv.Approved_Advance_Amount_Calc__c / adv.After_Repair_Value__c;
        }

        if (
          adv.BPO_Appraisal_Value__c == null ||
          adv.BPO_Appraisal_Value__c == 0 ||
          adv.Initial_Disbursement__c == null ||
          adv.Initial_Disbursement__c == 0
        ) {
          adv.As_Is_LTV_percent__c = 0;
        } else {
          adv.As_Is_LTV_percent__c =
            adv.Initial_Disbursement__c / adv.BPO_Appraisal_Value__c;
          //adv.As_Is_LTV_percent__c = adv.Approved_Advance_Amount__c/adv.BPO_Appraisal_Value__c;
        }
      }
    }

    Map<Id, Map<Id, List<Property_Advance__c>>> wireMap = new Map<Id, Map<Id, List<Property_Advance__c>>>();

    for (Property_Advance__c adv : newList) {
      if (adv.Escrow_Agent__c != null && adv.Advance_Status__c != 'Completed') {
        if (!wireMap.containsKey(adv.Advance__c)) {
          wireMap.put(adv.Advance__c, new Map<Id, List<Property_Advance__c>>());
        }

        if (!wireMap.get(adv.Advance__c).containsKey(adv.Escrow_Agent__c)) {
          wireMap.get(adv.Advance__c)
            .put(adv.Escrow_Agent__c, new List<Property_Advance__c>());
        }

        wireMap.get(adv.Advance__c).get(adv.Escrow_Agent__c).add(adv);
      }
    }

    //after insert

    List<Wire__c> wireUpsert = new List<Wire__c>();

    if (wireMap.size() > 0) {
      for (Wire__c wire : [
        SELECT
          Id,
          Advance__c,
          Advance_Fee__c,
          Approved_Advance_Amount__c,
          BPO_Appraisal_Fee__c,
          Doc_Prep_Fee__c,
          BlackSquare_Fee__c,
          Origination_Fee__c,
          Escrow_Agent__c,
          Daily_Interest_Rate__c
        FROM Wire__c
        WHERE Escrow_Agent__c != NULL AND Advance__c IN :wireMap.keySet()
      ]) {
        if (wireMap.get(wire.Advance__c).containsKey(wire.Escrow_Agent__c)) {
          for (
            Property_Advance__c adv : wireMap.get(wire.Advance__c)
              .get(wire.Escrow_Agent__c)
          ) {
            wire.Advance_Fee__c += util.fixNull(adv.Advance_Fee__c);
            wire.Approved_Advance_Amount__c += util.fixNull(
              adv.Approved_Advance_Amount_Calc__c
            );
            wire.BPO_Appraisal_Fee__c += util.fixNull(adv.BPO_Appraisal_Fee__c);
            wire.Doc_Prep_Fee__c += util.fixNull(adv.Doc_Prep_Fee__c);
            wire.Origination_Fee__c += util.fixNull(adv.Origination_Fee__c);
            wire.BlackSquare_Fee__c += util.fixNull(adv.BlackSquare_Fee__c);
            //wire.Daily_Interest_Rate__c += util.fixNull(adv.Daily_Interest_Rate__c);
          }

          wireUpsert.add(wire);
          wireMap.get(wire.Advance__c).remove(wire.Escrow_Agent__c);
        }
      }
    }

    for (Id advId : wireMap.keySet()) {
      for (Id escrowId : wireMap.get(advId).keySet()) {
        Wire__c wire = new Wire__c();
        wire.Advance__c = advId;
        wire.Escrow_Agent__c = escrowId;
        wire.Advance_Fee__c = 0;
        wire.Approved_Advance_Amount__c = 0;
        wire.BPO_Appraisal_Fee__c = 0;
        wire.Doc_Prep_Fee__c = 0;
        wire.BlackSquare_Fee__c = 0;
        wire.Origination_Fee__c = 0;
        //wire.Daily_Interest_Rate__c = 0;

        for (Property_Advance__c adv : wireMap.get(advId).get(escrowId)) {
          wire.Advance_Fee__c += util.fixNull(adv.Advance_Fee__c);
          wire.Approved_Advance_Amount__c += util.fixNull(
            adv.Approved_Advance_Amount_Calc__c
          );
          wire.BPO_Appraisal_Fee__c += util.fixNull(adv.BPO_Appraisal_Fee__c);
          wire.Doc_Prep_Fee__c += util.fixNull(adv.Doc_Prep_Fee__c);
          wire.Origination_Fee__c += util.fixNull(adv.Origination_Fee__c);
          wire.BlackSquare_Fee__c += util.fixNull(adv.BlackSquare_Fee__c);
          //wire.Daily_Interest_Rate__c += util.fixNull(adv.Daily_Interest_Rate__c);
        }
        wireUpsert.add(wire);
      }
    }

    if (wireMap.size() > 0) {
      upsert wireUpsert;
    }

    List<Property_Advance__c> advUpdate = new List<Property_Advance__c>();
    for (Property_Advance__c adv : newList) {
      for (Wire__c w : wireUpsert) {
        if (
          w.Advance__c == adv.Advance__c &&
          adv.Escrow_Agent__c == w.Escrow_Agent__c
        ) {
          adv.Wire__c = w.Id;
          continue;
        }
      }
    }
  }

  /**
   * @name afterUpdate
   * @description
   * @param
   **/
  public static void afterUpdate(
    List<Property_Advance__c> newList,
    List<Property_Advance__c> oldList
  ) {
    Set<Id> wireIds = new Set<Id>();
    Set<Id> advIds = new Set<Id>();
    for (Integer i = 0; i < newList.size(); i++) {
      if (newList[i].Wire__c != null) {
        wireIds.add(newList[i].Wire__c);
      }

      if (oldList[i].Wire__c != null) {
        wireIds.add(oldList[i].Wire__c);
      }

      //if(oldList[i].Daily_Interest_Rate_Total__c != newList[i].Daily_Interest_Rate_Total__c){
      advIds.add(newList[i].Advance__c);
      //}
    }

    if (wireIds.size() > 0) {
      rollupWires(wireIds);
    }

    if (advIds.size() > 0) {
      rollupAdvances(advIds);
    }
  }

  /**
   * @name beforeDelete
   * @description
   * @param
   **/
  public static void beforeDelete(List<Property_Advance__c> newList) {
    for (Integer i = 0; i < newList.size(); i++) {
    }
  }

  /**
   * @name afterDelete
   * @description
   * @param
   **/
  public static void afterDelete(
    List<Property_Advance__c> newList,
    List<Property_Advance__c> oldList
  ) {
    //Map<Id, List<Property_Advance__c>> wireIds = new Map<Id, List<Property_Advance__c>>();
    Set<Id> wireIds = new Set<Id>();
    Set<Id> advIds = new Set<Id>();

    for (Integer i = 0; i < oldList.size(); i++) {
      if (oldList[i].Wire__c != null) {
        wireIds.add(oldList[i].Wire__c);
      }
      if (oldList[i].Advance__c != null) {
        advIds.add(oldList[i].Advance__c);
      }
    }

    if (wireIds.size() > 0) {
      rollupWires(wireIds);
    }

    if (advIds.size() > 0) {
      setAdvRecordTypes(advIds);
    }
  }

  /**
   * @name afterUndelete
   * @description
   * @param
   **/
  public static void afterUndelete(List<Property_Advance__c> oldList) {
    for (Integer i = 0; i < oldList.size(); i++) {
    }
  }

  public static Map<String, Id> getAdvanceRecordTypes() {
    Map<String, Id> advRecordTypeMap = new Map<String, Id>();
    for (RecordType rt : [
      SELECT Id, DeveloperName
      FROM RecordType
      WHERE SobjectType = 'Advance__c'
    ]) {
      advRecordTypeMap.put(rt.DeveloperName, rt.Id);
    }
    return advRecordTypeMap;
  }

  public static void setAdvRecordTypes(Set<Id> advIds) {
    List<Advance__c> advances = new List<Advance__c>();
    Map<String, Id> recTypes = getAdvanceRecordTypes();
    Map<id, id> propertyAdvMap = new Map<id, id>(); //CIP-2149 - Raj Sirivolu. 1/20/2022.
    for (
      Advance__c adv : [
        SELECT
          Id,
          RecordType.DeveloperName,
          Deal__r.Reno_Funding_Type__c,
          Target_Advance_Date__c, //CIP-2149 - Raj Sirivolu. 1/20/2022.
          Underwriter__c, //CIP-2149 - Raj Sirivolu. 1/20/2022.
          Closer__c,
          Title_Review_Company__c,
          Funding_Shield_Cert_Status__c,
          HUD_Settlement_Statement_Status__c,
          (
            SELECT
              Id,
              property__c, //CIP-2149 - Raj Sirivolu. 1/20/2022.
              Property__r.RecordType__c,
              Property__r.Number_of_Advances__c,
              Property__r.Requested_Funding_Date__c, //CIP-2149 - Raj Sirivolu. 1/20/2022.
              Property__r.Underwriter__c, //CIP-2149 - Raj Sirivolu. 1/20/2022.
              Property__r.Closer__c,
              Property__r.Title_Review_Company__c,
              Property__r.Funding_Shield_Cert_Status__c,
              Property__r.HUD_Settlement_Statement_Status__c
            FROM Property_Advances__r
            ORDER BY createdDate ASC, property__c ASC
          )
        FROM Advance__c
        WHERE Id IN :advIds
      ]
    ) {
      Boolean hasReno = false;
      Boolean hasChanged = false;
      Boolean isConstruction = false;
      //CIP-2149 - Raj Sirivolu. 1/20/2022. Begin.
      Date requestedFundDt = null;
      String underwriter = '';
      String closer = '';
      String titleReview = '';
      String hudStatus = '';
      String fundingShieldStatus = '';
      //CIP-2149 - Raj Sirivolu. 1/20/2022. End.
      for (Property_Advance__c pAdv : adv.Property_Advances__r) {
        if (Integer.valueOf(pAdv.Property__r.Number_of_Advances__c) >= 1) {
          isConstruction = true;
          hasReno = false;
        } else if (pAdv.Property__r.RecordType__c == 'Renovation') {
          hasReno = true;
          isConstruction = false;
        }
        //CIP-2149 - Raj Sirivolu. 1/20/2022. Begin.
        if (Trigger.isAfter && Trigger.isInsert) {
          // system.debug('pAdv.Property__r.Requested_Funding_Date__c :' +pAdv.Property__r.Requested_Funding_Date__c);
          // system.debug('pAdv.Property__r.Underwriter__c :' +pAdv.Property__r.Underwriter__c);
          if (
            adv.RecordType.DeveloperName == 'Non_Renovation_Initial' ||
            adv.RecordType.DeveloperName == 'Renovation_Initial'
          ) {
            propertyAdvMap.put(pAdv.Property__c, adv.id);
            if (pAdv.Property__r.Requested_Funding_Date__c != null) {
              requestedFundDt = pAdv.Property__r.Requested_Funding_Date__c;
            }
            if (pAdv.Property__r.Underwriter__c != null) {
              underwriter = pAdv.Property__r.Underwriter__c;
            }
            if (pAdv.Property__r.Closer__c != null) {
              closer = pAdv.Property__r.Closer__c;
            }
            if (pAdv.Property__r.Title_Review_Company__c != null) {
              titleReview = pAdv.Property__r.Title_Review_Company__c;
            }
            if (pAdv.Property__r.Funding_Shield_Cert_Status__c != null) {
              fundingShieldStatus = pAdv.Property__r.Funding_Shield_Cert_Status__c;
            }
            if (pAdv.Property__r.HUD_Settlement_Statement_Status__c != null) {
              hudStatus = pAdv.Property__r.HUD_Settlement_Statement_Status__c;
            }
            // system.debug('requestedFundDt :' +requestedFundDt);
            // system.debug('underwriter :' +underwriter);
          }
        }
        //CIP-2149 - Raj Sirivolu. 1/20/2022. End.
      }

      if (
        isConstruction &&
        adv.RecordType.DeveloperName != 'Construction_Advance' &&
        adv.Deal__r.Reno_Funding_Type__c == 'Advances'
      ) {
        hasChanged = true;
        adv.RecordTypeId = recTypes.get('Construction_Advance');
      } else if (
        isConstruction &&
        adv.RecordType.DeveloperName != 'Construction_Draw' &&
        adv.Deal__r.Reno_Funding_Type__c == 'Reserves'
      ) {
        hasChanged = true;
        adv.RecordTypeId = recTypes.get('Construction_Draw');
      } else if (
        hasReno && adv.RecordType.DeveloperName != 'Renovation_Initial'
      ) {
        hasChanged = true;
        adv.RecordTypeId = recTypes.get('Renovation_Initial');
      } else if (
        !hasReno && adv.RecordType.DeveloperName != 'Non_Renovation_Initial'
      ) {
        hasChanged = true;
        adv.RecordTypeId = recTypes.get('Non_Renovation_Initial');
      }

      //CIP-2149 - Raj Sirivolu. 1/20/2022. Begin.
      if (Trigger.isAfter && Trigger.isInsert) {
        if (
          adv.RecordType.DeveloperName == 'Non_Renovation_Initial' ||
          adv.RecordType.DeveloperName == 'Renovation_Initial'
        ) {
          if (requestedFundDt != null) {
            hasChanged = true;
            adv.Target_Advance_Date__c = requestedFundDt;
          }
          if (!String.isblank(underwriter)) {
            hasChanged = true;
            adv.Underwriter__c = underwriter;
          }
          if (!String.isblank(closer)) {
            hasChanged = true;
            adv.Closer__c = closer;
          }
          if (!String.isblank(titleReview)) {
            hasChanged = true;
            adv.Title_Review_Company__c = titleReview;
          }
          if (!String.isblank(fundingShieldStatus)) {
            hasChanged = true;
            adv.Funding_Shield_Cert_Status__c = fundingShieldStatus;
          }
          if (!String.isblank(hudStatus)) {
            hasChanged = true;
            adv.HUD_Settlement_Statement_Status__c = hudStatus;
          }
          system.debug(
            'adv.Target_Advance_Date__c :' + adv.Target_Advance_Date__c
          );
          system.debug('adv.Underwriter__c :' + adv.Underwriter__c);
        }
      }

      //CIP-2149 - Raj Sirivolu. 1/20/2022. End.
      if (hasChanged) {
        advances.add(adv);
      }
    } //Advance__c SOQL

    //CIP-2149 - Raj Sirivolu. 1/20/2022. Begin.
    if (Trigger.isAfter && Trigger.isInsert) {
      if (propertyAdvMap.size() > 0) {
        List<Property__c> propertyList = new List<Property__c>();
        for (Property__c property : [
          SELECT id, Initial_Advance__c
          FROM property__c
          WHERE id = :propertyAdvMap.keySet() AND Initial_Advance__c = NULL
        ]) {
          property.Initial_Advance__c = propertyAdvMap.get(property.id);
          propertyList.add(property);
        }
        //system.debug('propertyList :' +propertyList);
        try {
          update propertyList;
        } catch (DmlException err) {
          System.debug('Property intial advance id update error: ' + err);
        }
      }
    }
    //CIP-2149 - Raj Sirivolu. 1/20/2022. End.
    try {
      update advances;
    } catch (DmlException err) {
      System.debug('Advance record type change error : ' + err);
    }
  }

  public static void rollupAdvances(Set<Id> advIds) {
    Map<Id, Advance__c> advMap = new Map<Id, Advance__c>();

    for (Id i : advIds) {
      Advance__c advance = new Advance__c(Id = i);
      advance.Daily_Interest_Rate_Subtotal__c = 0;
      advance.Distinct_Counties__c = '';
      advMap.put(i, advance);
    }

    for (AggregateResult ar : [
      SELECT Advance__c parent, SUM(Daily_Interest_Rate_Total__c) intRateTotal
      FROM Property_Advance__c
      WHERE Advance__c IN :advMap.keySet()
      GROUP BY Advance__c
    ]) {
      Id advId = (Id) ar.get('parent');
      Advance__c adv = advMap.get(advId);
      adv.Daily_Interest_Rate_Subtotal__c = util.fixNull(
        (Decimal) ar.get('intRateTotal')
      );
    }

    for (AggregateResult ar : [
      SELECT Advance__c parent, Property__r.County__c county
      FROM Property_Advance__c
      WHERE Advance__c IN :advMap.keySet() AND Property__r.County__c != NULL
      GROUP BY Advance__c, Property__r.County__c
      ORDER BY property__r.county__c ASC
    ]) {
      Id advId = (Id) ar.get('parent');
      String county = (String) ar.get('county');
      Advance__c adv = advMap.get(advId);
      adv.Distinct_Counties__c += county + ';';
    }

    update advMap.values();
  }

  @future(callout=true) // pre-empting a call out from the wire trigger
  public static void rollupWires(Set<Id> wireIds) {
    Map<Id, Wire__c> wireMap = new Map<Id, Wire__c>();

    system.debug(wireIds);

    for (Id i : wireIds) {
      wireMap.put(i, new Wire__c(Id = i));

      Wire__c wire = new Wire__c();
      wire.Advance_Fee__c = 0;
      wire.Origination_Fee__c = 0;
      wire.Approved_Advance_Amount__c = 0;
      wire.BPO_Appraisal_Fee__c = 0;
      wire.Doc_Prep_Fee__c = 0;
      //wire.Daily_Interest_Rate__c = 0;
      wire.BlackSquare_Fee__c = 0;
    }

    List<Wire__c> wireUpdates = new List<Wire__c>();
    List<Wire__c> wireDeletes = new List<Wire__c>();

    for (AggregateResult ar : [
      SELECT
        Wire__c parent,
        SUM(Advance_Fee__c) ar,
        SUM(Approved_Advance_Amount_Calc__c) ar2,
        SUM(BPO_Appraisal_Fee__c) ar3,
        SUM(Doc_Prep_Fee__c) ar4,
        SUM(Origination_Fee__c) ar5,
        SUM(Daily_Interest_Rate_Total__c) ar6,
        SUM(BlackSquare_Fee__c) ar7
      FROM Property_Advance__c
      WHERE Wire__c IN :wireIds
      GROUP BY Wire__c
    ]) {
      system.debug('inside aggregeresult');

      Id wireId = (Id) ar.get('parent');
      system.debug(wireId);
      if (!wireMap.containsKey(wireId)) {
        wireMap.put(wireId, new Wire__c(Id = wireId));
      }

      Wire__c wire = wireMap.get(wireId);
      wire.Advance_Fee__c = util.fixNull((Decimal) ar.get('ar'));
      wire.Approved_Advance_Amount__c = util.fixNull((Decimal) ar.get('ar2'));
      wire.BPO_Appraisal_Fee__c = util.fixNull((Decimal) ar.get('ar3'));
      wire.Doc_Prep_Fee__c = util.fixNull((Decimal) ar.get('ar4'));
      wire.Origination_Fee__c = util.fixNull((Decimal) ar.get('ar5'));
      //wire.Daily_Interest_Rate__c = util.fixNull((Decimal)ar.get('ar6'));
      wire.BlackSquare_Fee__c = util.fixNull((Decimal) ar.get('ar7'));
      wireMap.put(wireId, wire);

      wireUpdates.add(wire);
      wireMap.remove(wireId);
    }

    system.debug(wireMap);
    system.debug(wireUpdates);

    if (wireMap.keySet().size() > 0) {
      delete wireMap.values();
    }

    if (wireUpdates.size() > 0) {
      update wireUpdates;
    }
  }
}