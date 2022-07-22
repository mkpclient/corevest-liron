public class CommissionDetail_Helper {
  public static void afterInsert(List<Commission_Detail__c> newList) {
    list<id> myList = new List<id>();
    list<Commission__c> commsToUpdate = new List<Commission__c>();

    List<Commission_Detail__c> commDetailsBridge = new List<Commission_Detail__c>();
    Map<Id, Id> dealDetailMap = new Map<Id, Id>();

      //ties bridge commission details to existing commission records if advance was approved before deal is closed won, or if commission detail doesn't exist
    for (Integer i = 0; i < newList.size(); i++) {
      if (newList[i].Loan_Type__c == 'Bridge Loan') {
        commDetailsBridge.add(newList[i]);
        dealDetailmap.put(newList[i].Deal__c, newList[i].Id);
      }
      //   myList.add(newList[i].id);
    }

    // list<Commission_Detail__c> myCommDetailsBridge = [
    //   SELECT Id, Deal__c
    //   FROM Commission_Detail__c
    //   WHERE Loan_Type__C = 'Bridge Loan' AND Id IN :myList
    // ];
    if (commDetailsBridge.size() > 0) {
      for (Commission__c bridgeCommission : [
        SELECT Id, Deal__c
        FROM Commission__c
        WHERE Commission_Detail__c = NULL AND Deal__c IN :dealDetailMap.keySet()
      ]) {
        bridgeCommission.Commission_Detail__c = dealDetailMap.get(
          bridgeCommission.Deal__c
        );
        commsToUpdate.add(bridgeCommission);
      }

      update commsToUpdate;

      //   Map<Id, Id> myMap = new Map<Id, Id>();
      //   for (Commission_Detail__c CommDetail : myCommDetailsBridge) {
      //     myMap.put(CommDetail.Deal__c, CommDetail.Id);
      //   }
      // Map<Id, Id> dealDetailMap = new Map<Id, Id>();

      //   if (mycommDetailsBridge.size() > 0) {
      //   list<Commission__c> myBridgeCommissions = [
      //     SELECT id, Deal__c
      //     FROM Commission__c
      //     WHERE Commission_detail__c = NULL AND Deal__c = :myMap.keySet()
      //   ];

      //   if (myBridgeCommissions.size() > 0) {
      //     system.debug(myBridgeCommissions.size());
      //     for (Commission__c bComm : myBridgeCommissions) {
      //       bComm.Commission_detail__c = myMap.get(bComm.Deal__c);
      //       commsToUpdate.add(bComm);
      //     }

      //     // }
      //   }
    }
    // if (commsToUpdate.size() > 0) {
    //   update commsToUpdate;
    // }
  }

  public static void afterUpdate(
    List<Commission_Detail__c> newList,
    List<Commission_Detail__c> oldList
  ) {
    list<id> myListApproved = new List<id>();
    list<id> myList = new List<id>();
    list<Commission_Detail__c> bridgeCommId = new List<Commission_Detail__c>();

    for (Integer i = 0; i < newList.size(); i++) {
      myList.add(newList[i].id);

      if (
        newList[i].Approval_Status__c == 'Approved' &&
        newList[i].Approval_Status__c != oldList[i].Approval_Status__c
      ) {
        myListApproved.add(newList[i].id);
        System.debug(newList[i].id);
      }
    }

    list<Commission__c> myCommsToAdd = new List<Commission__c>();
    list<Commission__c> commsToUpdate = new List<Commission__c>();
//term records no 30 year DSCR
    list<Commission_Detail__c> myCommDetailsTerm = [
      SELECT
        Account_Intro_Source__c,
        Id,
        CAF_YSP__c,
        Commission_Type__c,
        Deal__c,
        Final_Loan_Amount__c,
        Deal__r.id,
        Deal__r.Calculated_Origination_Fee__c,
        Deal__r.CAF_Upfront_Fee__c,
        Deal__r.Account.Borrowed_on_Term_Loans__c,
        Deal__r.Account.Borrowed_on_Bridge_Loans__c,
        Deal__r.Account.Total_Borrowed_on_Bridge__c,
        Loan_Type__c,
        Originator_Paid_in_Full__c,
        Internal_Referral__c,
        Internal_Referral_Fee_Bypass__c,
        Internal_Referral_Fee__c,
        Internal_Referral__r.id,
        Internal_Referral__r.isActive,
        OwnerId,
        Name
      FROM Commission_Detail__c
      WHERE Loan_Type__C = 'Term Loan' AND Id IN :myListApproved AND Deal__r.Term_Loan_Type__c != '30 Year'
    ];
    System.debug(myCommDetailsTerm.size());
      
// bridge section commission detail to attach to commission
    list<Commission_Detail__c> myCommDetailsBridge = [
      SELECT Id, Deal__r.id
      FROM Commission_Detail__c
      WHERE Loan_Type__C = 'Bridge Loan' AND Id IN :myList
    ];

    System.debug('bridge list' + myCommDetailsBridge.size());

      //term section
   if (myCommDetailsTerm.size() > 0) {
      for (Commission_Detail__c termComm : myCommDetailsTerm) {
        system.debug('enter forloop');

        decimal originationPlusCaf;
        decimal above10Mill;
        decimal above10MillComm;
        decimal finComm;
        decimal finalCommAmount;
        decimal originationFeeTotal;
        decimal orgFee = termComm.Deal__r.CAF_Upfront_Fee__c / 100;
        decimal rateBasedOnBorrowed;

        if (
          termComm.Final_Loan_Amount__c <= 10000000 &&
          //termComm.Final_Loan_Amount__c <= 10000000 &&
          termComm.Commission_Type__c == 'Direct' &&
          termComm.Originator_Paid_in_Full__c != true
        ) {
          system.debug('under 10 mil and direct');
          rateBasedOnBorrowed = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c -
            termComm.Final_Loan_Amount__c >= 10000000
            ? 0.25
            : 0.50;

          system.debug(
            'o fee' + termComm.Deal__r.Calculated_Origination_Fee__c
          );
          if (
            termComm.Internal_Referral__c != null && termComm.Internal_Referral_Fee_Bypass__c !=true &&
            termComm.Internal_Referral_Fee__c != null &&
            termComm.Internal_Referral_Fee__c != 'N/A' &&
            termComm.Internal_Referral__r.isActive == true

          ) {
            //decimal internalFee = termComm.Internal_Referral_Fee__c == '20%'
              //? .20
              //: .50;
                                   decimal internalFee;
                        
                        if(termComm.Internal_Referral_Fee__c == '10%'){
                            internalFee = .10;
                        }else if(termComm.Internal_Referral_Fee__c == '20%'){
                            internalFee = .20;
                            
                        }else if(termComm.Internal_Referral_Fee__c == '30%'){
                            internalFee = .30;
                            
                        }else if(termComm.Internal_Referral_Fee__c == '50%'){
                            internalFee = .50;
                            
                        }

            if (
              termComm.CAF_YSP__c == '0 BPS in Spread' ||
              termComm.CAF_YSP__c == null
            ) {
              decimal commRefAmount =
                (termComm.Final_Loan_Amount__c * orgFee) * rateBasedOnBorrowed;
              system.debug(commRefAmount);
              decimal finalCommFee = commRefAmount * internalFee;
              system.debug(finalCommFee);

              Commission__c myCommission = new Commission__c();
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;
              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Commission_Amount1__c = finalCommFee;
              myCommission.Origination_Fee__c = orgFee * 100;
              myCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * orgFee;
              myCommission.Owner__c = termComm.Internal_Referral__r.id;
              myCommission.OwnerId = termComm.Internal_Referral__r.id;
              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c = commRefAmount;

              myCommsToAdd.add(myCommission);

              Commission__c refCommission = new Commission__c();
              refCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              refCommission.Commission_Detail__c = termComm.Id;
              refCommission.Commission_Type__c = termComm.Commission_Type__c;
              refCommission.Deal__c = termComm.Deal__c;
              refCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;
              refCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              refCommission.Loan_Type__c = termComm.Loan_Type__c;
              refCommission.OwnerId = termComm.OwnerId;
              refCommission.Commission_Amount1__c =
                commRefAmount - finalCommFee;
              refCommission.Origination_Fee__c = orgFee * 100;
              refCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * orgFee;
              refCommission.Owner__c = termComm.OwnerId;
              refCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              refCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              refCommission.Commissionable_Amount__c = commRefAmount;

              myCommsToAdd.add(refCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '+5 BPS in Spread / +25 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '+10 BPS in Spread / +25 BPS in Commissionable Fee'
            ) {
              originationPlusCaf = orgFee + 0.0025;

              decimal commRefAmount =
                (termComm.Final_Loan_Amount__c * originationPlusCaf) *
                rateBasedOnBorrowed;
              decimal finalCommFee = commRefAmount * internalFee;

              Commission__c myCommission = new Commission__c();
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;
              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Commission_Amount1__c = finalCommFee;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;
              myCommission.Owner__c = termComm.Internal_Referral__r.id;
              myCommission.OwnerId = termComm.Internal_Referral__r.id;
              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c = commRefAmount;

              myCommsToAdd.add(myCommission);

              Commission__c refCommission = new Commission__c();
              refCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              refCommission.Commission_Detail__c = termComm.Id;
              refCommission.Commission_Type__c = termComm.Commission_Type__c;
              refCommission.Deal__c = termComm.Deal__c;
              refCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;
              refCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              refCommission.Loan_Type__c = termComm.Loan_Type__c;
              refCommission.Commission_Amount1__c =
                commRefAmount - finalCommFee;
              refCommission.Origination_Fee__c = originationPlusCaf * 100;
              refCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;
              refCommission.Owner__c = termComm.OwnerId;
              refCommission.OwnerId = termComm.OwnerId;
              refCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              refCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              refCommission.Commissionable_Amount__c = commRefAmount;

              myCommsToAdd.add(refCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '-5 BPS in Spread / -25 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '-10 BPS in Spread / -25 BPS in Commissionable Fee'
            ) {
              originationPlusCaf = orgFee - 0.0025;

              decimal commRefAmount =
                (termComm.Final_Loan_Amount__c * originationPlusCaf) *
                rateBasedOnBorrowed;
              decimal finalCommFee = commRefAmount * internalFee;

              Commission__c myCommission = new Commission__c();
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;
              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Commission_Amount1__c = finalCommFee;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;
              myCommission.Owner__c = termComm.Internal_Referral__r.id;
              myCommission.OwnerId = termComm.Internal_Referral__r.id;
              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c = commRefAmount;

              myCommsToAdd.add(myCommission);

              Commission__c refCommission = new Commission__c();
              refCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              refCommission.Commission_Detail__c = termComm.Id;
              refCommission.Commission_Type__c = termComm.Commission_Type__c;
              refCommission.Deal__c = termComm.Deal__c;
              refCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;
              refCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              refCommission.Loan_Type__c = termComm.Loan_Type__c;
              refCommission.Commission_Amount1__c =
                commRefAmount - finalCommFee;
              refCommission.Origination_Fee__c = originationPlusCaf * 100;
              refCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;
              refCommission.Owner__c = termComm.OwnerId;
              refCommission.OwnerId = termComm.OwnerId;
              refCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              refCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              refCommission.Commissionable_Amount__c = commRefAmount;

              myCommsToAdd.add(refCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '+10 BPS in spread / +50 BPS in Commissionable Fee' ||
              termCOmm.CAF_YSP__c ==
              '+15 BPS in Spread / +50 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '+20 BPS in Spread / +50 BPS in Commissionable Fee'
            ) {
              originationPlusCaf = orgFee + 0.005;
              system.debug(originationPlusCaf);
              decimal commRefAmount =
                (termComm.Final_Loan_Amount__c * originationPlusCaf) *
                rateBasedOnBorrowed;
              system.debug(commRefAmount);
              decimal finalCommFee = commRefAmount * internalFee;
              system.debug(finalCommFee);

              Commission__c myCommission = new Commission__c();
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Commission_Amount1__c = finalCommFee;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;
              myCommission.Owner__c = termComm.Internal_Referral__r.id;
              myCommission.OwnerId = termComm.Internal_Referral__r.id;
              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c = commRefAmount;

              myCommsToAdd.add(myCommission);

              Commission__c refCommission = new Commission__c();
              refCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              refCommission.Commission_Detail__c = termComm.Id;
              refCommission.Commission_Type__c = termComm.Commission_Type__c;
              refCommission.Deal__c = termComm.Deal__c;
              refCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;
              refCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              refCommission.Loan_Type__c = termComm.Loan_Type__c;
              refCommission.Commission_Amount1__c =
                commRefAmount - finalCommFee;
              refCommission.Origination_Fee__c = originationPlusCaf * 100;
              refCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;
              refCommission.Owner__c = termComm.OwnerId;
              refCommission.OwnerId = termComm.OwnerId;
              refCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              refCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              refCommission.Commissionable_Amount__c = commRefAmount;

              myCommsToAdd.add(refCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '-10 BPS in spread / -50 BPS in Commissionable Fee' ||
              termCOmm.CAF_YSP__c ==
              '-15 BPS in Spread / -50 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '-20 BPS in Spread / -50 BPS in Commissionable Fee'
            ) {
              originationPlusCaf = orgFee - 0.005;

              decimal commRefAmount =
                (termComm.Final_Loan_Amount__c * originationPlusCaf) *
                rateBasedOnBorrowed;
              decimal finalCommFee = commRefAmount * internalFee;

              Commission__c myCommission = new Commission__c();
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;
              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Commission_Amount1__c = finalCommFee;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;
              myCommission.Owner__c = termComm.Internal_Referral__r.id;
              myCommission.OwnerId = termComm.Internal_Referral__r.id;

              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c = commRefAmount;

              myCommsToAdd.add(myCommission);

              Commission__c refCommission = new Commission__c();
              refCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              refCommission.Commission_Detail__c = termComm.Id;
              refCommission.Commission_Type__c = termComm.Commission_Type__c;
              refCommission.Deal__c = termComm.Deal__c;
              refCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;
              refCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              refCommission.Loan_Type__c = termComm.Loan_Type__c;
              refCommission.Commission_Amount1__c =
                commRefAmount - finalCommFee;
              refCommission.Origination_Fee__c = originationPlusCaf * 100;
              refCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;
              refCommission.Owner__c = termComm.OwnerId;
              myCommission.Owner__c = termComm.OwnerId;

              refCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              refCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              refCommission.Commissionable_Amount__c = commRefAmount;

              myCommsToAdd.add(refCommission);
            }
          } else {
            if (
              termComm.CAF_YSP__c == null ||
              termComm.CAF_YSP__c == '0 BPS in Spread'
            ) {
              Commission__c myCommission = new Commission__c();
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;
              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Owner__c = termComm.OwnerId;
              myCommission.OwnerId = termComm.OwnerId;

              myCommission.Commission_Amount1__c =
                (termComm.Final_Loan_Amount__c * orgFee) * rateBasedOnBorrowed;
              myCommission.Origination_Fee__c = orgFee * 100;
              myCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * orgFee;
              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                termComm.Final_Loan_Amount__c * orgFee;

              myCommsToAdd.add(myCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '+5 BPS in Spread / +25 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '+10 BPS in Spread / +25 BPS in Commissionable Fee'
            ) {
              originationPlusCaf = orgFee + 0.0025;

              Commission__c myCommission = new Commission__c();
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;
              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Owner__c = termComm.OwnerId;
              myCommission.OwnerId = termComm.OwnerId;

              myCommission.Commission_Amount1__c =
                (termComm.Final_Loan_Amount__c * originationPlusCaf) *
                rateBasedOnBorrowed;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;
              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;

              myCommsToAdd.add(myCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '-5 BPS in Spread / -25 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '-10 BPS in Spread / -25 BPS in Commissionable Fee'
            ) {
              originationPlusCaf = orgFee - 0.0025;

              Commission__c myCommission = new Commission__c();
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Owner__c = termComm.OwnerId;
              myCommission.OwnerId = termComm.OwnerId;

              myCommission.Commission_Amount1__c =
                (termComm.Final_Loan_Amount__c * originationPlusCaf) *
                rateBasedOnBorrowed;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;
              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;

              myCommsToAdd.add(myCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '+10 BPS in spread / +50 BPS in Commissionable Fee' ||
              termCOmm.CAF_YSP__c ==
              '+15 BPS in Spread / +50 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '+20 BPS in Spread / +50 BPS in Commissionable Fee'
            ) {
              originationPlusCaf = orgFee + 0.005;

              Commission__c myCommission = new Commission__c();
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Owner__c = termComm.OwnerId;
              myCommission.OwnerId = termComm.OwnerId;

              myCommission.Commission_Amount1__c =
                (termComm.Final_Loan_Amount__c * originationPlusCaf) *
                rateBasedOnBorrowed;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;
              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;

              myCommsToAdd.add(myCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '-10 BPS in spread / -50 BPS in Commissionable Fee' ||
              termCOmm.CAF_YSP__c ==
              '-15 BPS in Spread / -50 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '-20 BPS in Spread / -50 BPS in Commissionable Fee'
            ) {
              originationPlusCaf = orgFee - 0.005;

              Commission__c myCommission = new Commission__c();
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Owner__c = termComm.OwnerId;
              myCommission.OwnerId = termComm.OwnerId;

              myCommission.Commission_Amount1__c =
                (termComm.Final_Loan_Amount__c * originationPlusCaf) *
                rateBasedOnBorrowed;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;
              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;

              myCommsToAdd.add(myCommission);
            }
          }
        } else if (
		  termComm.Final_Loan_Amount__c <= 10000000 &&
          //termComm.Final_Loan_Amount__c <= 10000000 &&
          termComm.Commission_Type__c == 'Internal' &&
          termComm.Originator_Paid_in_Full__c != true
        ) {
          system.debug('under 10 mil and internal');
          rateBasedOnBorrowed = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c -
            termComm.Final_Loan_Amount__c >= 10000000
            ? 0.15
            : 0.35;
          if (
            termComm.Internal_Referral__c != null && termComm.Internal_Referral_Fee_Bypass__c !=true &&
            termComm.Internal_Referral_Fee__c != null &&
            termComm.Internal_Referral_Fee__c != 'N/A' &&
                          termComm.Internal_Referral__r.isActive == true

          ) {
            //decimal internalFee = termComm.Internal_Referral_Fee__c == '20%'
            //  ? .20
             // : .50;
                        decimal internalFee;
                        
                        if(termComm.Internal_Referral_Fee__c == '10%'){
                            internalFee = .10;
                        }else if(termComm.Internal_Referral_Fee__c == '20%'){
                            internalFee = .20;
                            
                        }else if(termComm.Internal_Referral_Fee__c == '30%'){
                            internalFee = .30;
                            
                        }else if(termComm.Internal_Referral_Fee__c == '50%'){
                            internalFee = .50;
                            
                        }
            if (
              termComm.CAF_YSP__c == '0 BPS in Spread' ||
              termComm.CAF_YSP__c == null
            ) {
              decimal commRefAmount =
                (termComm.Final_Loan_Amount__c * orgFee) * rateBasedOnBorrowed;
              system.debug(commRefAmount);
              decimal finalCommFee = commRefAmount * internalFee;
              system.debug(finalCommFee);

              Commission__c myCommission = new Commission__c();
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Commission_Amount1__c = finalCommFee;
              myCommission.Origination_Fee__c = orgFee * 100;
              myCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * orgFee;
              myCommission.Owner__c = termComm.Internal_Referral__r.id;
              myCommission.OwnerId = termComm.Internal_Referral__r.id;

              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c = commRefAmount;

              myCommsToAdd.add(myCommission);

              Commission__c refCommission = new Commission__c();
              refCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              refCommission.Commission_Detail__c = termComm.Id;
              refCommission.Commission_Type__c = termComm.Commission_Type__c;
              refCommission.Deal__c = termComm.Deal__c;
              refCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              refCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              refCommission.Loan_Type__c = termComm.Loan_Type__c;
              refCommission.Commission_Amount1__c =
                commRefAmount - finalCommFee;
              refCommission.Origination_Fee__c = orgFee * 100;
              refCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * orgFee;
              refCommission.Owner__c = termComm.OwnerId;
              refCommission.OwnerId = termComm.OwnerId;

              refCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              refCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              refCommission.Commissionable_Amount__c = commRefAmount;

              myCommsToAdd.add(refCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '+5 BPS in Spread / +25 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '+10 BPS in Spread / +25 BPS in Commissionable Fee'
            ) {
              originationPlusCaf = orgFee + 0.0025;

              decimal commRefAmount =
                (termComm.Final_Loan_Amount__c * originationPlusCaf) *
                rateBasedOnBorrowed;
              decimal finalCommFee = commRefAmount * internalFee;

              Commission__c myCommission = new Commission__c();
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Commission_Amount1__c = finalCommFee;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;
              myCommission.Owner__c = termComm.Internal_Referral__r.id;
              myCommission.OwnerId  = termComm.Internal_Referral__r.id;

              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c = commRefAmount;

              myCommsToAdd.add(myCommission);

              Commission__c refCommission = new Commission__c();
              refCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              refCommission.Commission_Detail__c = termComm.Id;
              refCommission.Commission_Type__c = termComm.Commission_Type__c;
              refCommission.Deal__c = termComm.Deal__c;
              refCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              refCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              refCommission.Loan_Type__c = termComm.Loan_Type__c;
              refCommission.Commission_Amount1__c =
                commRefAmount - finalCommFee;
              refCommission.Origination_Fee__c = originationPlusCaf * 100;
              refCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;
              refCommission.Owner__c = termComm.OwnerId;
              refCommission.OwnerId = termComm.OwnerId;

              refCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              refCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              refCommission.Commissionable_Amount__c = commRefAmount;

              myCommsToAdd.add(refCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '-5 BPS in Spread / -25 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '-10 BPS in Spread / -25 BPS in Commissionable Fee'
            ) {
              originationPlusCaf = orgFee - 0.0025;

              decimal commRefAmount =
                (termComm.Final_Loan_Amount__c * originationPlusCaf) *
                rateBasedOnBorrowed;
              decimal finalCommFee = commRefAmount * internalFee;

              Commission__c myCommission = new Commission__c();
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Commission_Amount1__c = finalCommFee;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;
              myCommission.Owner__c = termComm.Internal_Referral__r.id;
              myCommission.OwnerId = termComm.Internal_Referral__r.id;

              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c = commRefAmount;

              myCommsToAdd.add(myCommission);

              Commission__c refCommission = new Commission__c();
              refCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              refCommission.Commission_Detail__c = termComm.Id;
              refCommission.Commission_Type__c = termComm.Commission_Type__c;
              refCommission.Deal__c = termComm.Deal__c;
              refCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              refCommission.Loan_Type__c = termComm.Loan_Type__c;
              refCommission.Commission_Amount1__c =
                commRefAmount - finalCommFee;
              refCommission.Origination_Fee__c = originationPlusCaf * 100;
              refCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;
              refCommission.Owner__c = termComm.OwnerId;
              refCommission.OwnerId = termComm.OwnerId;

              refCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              refCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              refCommission.Commissionable_Amount__c = commRefAmount;

              myCommsToAdd.add(refCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '+10 BPS in spread / +50 BPS in Commissionable Fee' ||
              termCOmm.CAF_YSP__c ==
              '+15 BPS in Spread / +50 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '+20 BPS in Spread / +50 BPS in Commissionable Fee'
            ) {
              originationPlusCaf = orgFee + 0.005;
              system.debug(originationPlusCaf);
              decimal commRefAmount =
                (termComm.Final_Loan_Amount__c * originationPlusCaf) *
                rateBasedOnBorrowed;
              system.debug(commRefAmount);
              decimal finalCommFee = commRefAmount * internalFee;
              system.debug(finalCommFee);

              Commission__c myCommission = new Commission__c();
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Commission_Amount1__c = finalCommFee;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;
              myCommission.Owner__c = termComm.Internal_Referral__r.id;
              myCommission.OwnerId = termComm.Internal_Referral__r.id;

              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c = commRefAmount;

              myCommsToAdd.add(myCommission);

              Commission__c refCommission = new Commission__c();
              refCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              refCommission.Commission_Detail__c = termComm.Id;
              refCommission.Commission_Type__c = termComm.Commission_Type__c;
              refCommission.Deal__c = termComm.Deal__c;
              refCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              refCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              refCommission.Loan_Type__c = termComm.Loan_Type__c;
              refCommission.Commission_Amount1__c =
                commRefAmount - finalCommFee;
              refCommission.Origination_Fee__c = originationPlusCaf * 100;
              refCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;
              refCommission.Owner__c = termComm.OwnerId;
              refCommission.OwnerId = termComm.OwnerId;

              refCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              refCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              refCommission.Commissionable_Amount__c = commRefAmount;

              myCommsToAdd.add(refCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '-10 BPS in spread / -50 BPS in Commissionable Fee' ||
              termCOmm.CAF_YSP__c ==
              '-15 BPS in Spread / -50 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '-20 BPS in Spread / -50 BPS in Commissionable Fee'
            ) {
              originationPlusCaf = orgFee - 0.005;

              decimal commRefAmount =
                (termComm.Final_Loan_Amount__c * originationPlusCaf) *
                rateBasedOnBorrowed;
              decimal finalCommFee = commRefAmount * internalFee;

              Commission__c myCommission = new Commission__c();
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Commission_Amount1__c = finalCommFee;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;
              myCommission.Owner__c = termComm.Internal_Referral__r.id;
              myCommission.OwnerId = termComm.Internal_Referral__r.id;

              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c = commRefAmount;

              myCommsToAdd.add(myCommission);

              Commission__c refCommission = new Commission__c();
              refCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              refCommission.Commission_Detail__c = termComm.Id;
              refCommission.Commission_Type__c = termComm.Commission_Type__c;
              refCommission.Deal__c = termComm.Deal__c;
              refCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              refCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              refCommission.Loan_Type__c = termComm.Loan_Type__c;
              refCommission.Commission_Amount1__c =
                commRefAmount - finalCommFee;
              refCommission.Origination_Fee__c = originationPlusCaf * 100;
              refCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;
              refCommission.Owner__c = termComm.OwnerId;
              refCommission.OwnerId = termComm.OwnerId;

              refCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              refCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              refCommission.Commissionable_Amount__c = commRefAmount;

              myCommsToAdd.add(refCommission);
            }
          } else {
            if (
              termComm.CAF_YSP__c == null ||
              termComm.CAF_YSP__c == '0 BPS in Spread'
            ) {
              Commission__c myCommission = new Commission__c();
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Owner__c = termComm.OwnerId;
              myCommission.OwnerId = termComm.OwnerId;

              myCommission.Commission_Amount1__c =
                (termComm.Final_Loan_Amount__c * orgFee) * rateBasedOnBorrowed;
              myCommission.Origination_Fee__c = orgFee * 100;
              myCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * orgFee;
              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;
              myCommission.Commissionable_Amount__c =
                termComm.Final_Loan_Amount__c * orgFee;

              myCommsToAdd.add(myCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '+5 BPS in Spread / +25 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '+10 BPS in Spread / +25 BPS in Commissionable Fee'
            ) {
              originationPlusCaf = orgFee + 0.0025;

              Commission__c myCommission = new Commission__c();
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Owner__c = termComm.OwnerId;
              myCommission.OwnerId = termComm.OwnerId;


              myCommission.Commission_Amount1__c =
                (termComm.Final_Loan_Amount__c * originationPlusCaf) *
                rateBasedOnBorrowed;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;
              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;

              myCommsToAdd.add(myCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '-5 BPS in Spread / -25 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '-10 BPS in Spread / -25 BPS in Commissionable Fee'
            ) {
              originationPlusCaf = orgFee - 0.0025;

              Commission__c myCommission = new Commission__c();
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Owner__c = termComm.OwnerId;
              myCommission.OwnerId = termComm.OwnerId;


              myCommission.Commission_Amount1__c =
                (termComm.Final_Loan_Amount__c * originationPlusCaf) *
                rateBasedOnBorrowed;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;
              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;

              myCommsToAdd.add(myCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '+10 BPS in spread / +50 BPS in Commissionable Fee' ||
              termCOmm.CAF_YSP__c ==
              '+15 BPS in Spread / +50 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '+20 BPS in Spread / +50 BPS in Commissionable Fee'
            ) {
              originationPlusCaf = orgFee + 0.005;

              Commission__c myCommission = new Commission__c();
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Owner__c = termComm.OwnerId;
              myCommission.OwnerId = termComm.OwnerId;

              myCommission.Commission_Amount1__c =
                (termComm.Final_Loan_Amount__c * originationPlusCaf) *
                rateBasedOnBorrowed;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;
              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;

              myCommsToAdd.add(myCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '-10 BPS in spread / -50 BPS in Commissionable Fee' ||
              termCOmm.CAF_YSP__c ==
              '-15 BPS in Spread / -50 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '-20 BPS in Spread / -50 BPS in Commissionable Fee'
            ) {
              originationPlusCaf = orgFee - 0.005;

              Commission__c myCommission = new Commission__c();
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Owner__c = termComm.OwnerId;
              myCommission.OwnerId = termComm.OwnerId;

              myCommission.Commission_Amount1__c =
                (termComm.Final_Loan_Amount__c * originationPlusCaf) *
                rateBasedOnBorrowed;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;
              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                termComm.Final_Loan_Amount__c * originationPlusCaf;

              myCommsToAdd.add(myCommission);
            }
          }
        } 
          else if (
          termComm.Final_Loan_Amount__c > 10000000 &&
          termComm.Commission_Type__c == 'Direct' &&
          termComm.Originator_Paid_in_Full__c != true
        ) {
          system.debug('over 10 mil and direct');

          rateBasedOnBorrowed = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c -
            termComm.Final_Loan_Amount__c >= 10000000
            ? 0.25
            : 0.50;

          if (
            termComm.Internal_Referral__c != null && termComm.Internal_Referral_Fee_Bypass__c !=true &&
            termComm.Internal_Referral_Fee__c != null &&
            termComm.Internal_Referral_Fee__c != 'N/A' &&
            termComm.Internal_Referral__r.isActive == true

          ) {
            system.debug('internal condition 4');

            //decimal internalFee = termComm.Internal_Referral_Fee__c == '20%'
             // ? .20
             // : .50;

                                      decimal internalFee;
                        
                        if(termComm.Internal_Referral_Fee__c == '10%'){
                            internalFee = .10;
                        }else if(termComm.Internal_Referral_Fee__c == '20%'){
                            internalFee = .20;
                            
                        }else if(termComm.Internal_Referral_Fee__c == '30%'){
                            internalFee = .30;
                            
                        }else if(termComm.Internal_Referral_Fee__c == '50%'){
                            internalFee = .50;
                            
                        }
            if (
              termComm.CAF_YSP__c == '0 BPS in Spread' ||
              termComm.CAF_YSP__c == null
            ) {
              system.debug('0 BPS in Spread');

              system.debug(orgFee);
              above10Mill = (termComm.Final_Loan_Amount__c - 10000000);
              system.debug(above10Mill);
              above10MillComm = (above10Mill * orgFee) * 0.25;
              system.debug(above10MillComm);
              finComm = (10000000 * orgFee) * rateBasedOnBorrowed;
              system.debug(finComm);
              finalCommAmount = (above10MillComm + finComm);
              system.debug(finalCommAmount);

              Commission__c myCommission = new Commission__c();
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Commission_Amount1__c =
                finalCommAmount * internalFee;
              myCommission.Origination_Fee__c = orgFee * 100;
              myCommission.Origination_Fee_Amt__c =
                (10000000 * orgFee) + (above10Mill * orgFee);
              myCommission.Owner__c = termComm.Internal_Referral__r.id;
              myCommission.OwnerId = termComm.Internal_Referral__r.id;

              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                (10000000 * orgFee) + (above10Mill * orgFee);

              myCommsToAdd.add(myCommission);

              Commission__c refCommission = new Commission__c();
              refCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              refCommission.Commission_Type__c = termComm.Commission_Type__c;
              refCommission.Deal__c = termComm.Deal__c;
              refCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              refCommission.Commission_Detail__c = termComm.Id;
              refCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              refCommission.Loan_Type__c = termComm.Loan_Type__c;
              refCommission.Commission_Amount1__c =
                finalCommAmount - (finalCommAmount * internalFee);
              refCommission.Origination_Fee__c = orgFee * 100;
              refCommission.Origination_Fee_Amt__c =
                (10000000 * orgFee) + (above10Mill * orgFee);
              refCommission.Owner__c = termComm.OwnerId;
              refCommission.OwnerId = termComm.OwnerId;

              refCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              refCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              refCommission.Commissionable_Amount__c =
                (10000000 * orgFee) + (above10Mill * orgFee);

              myCommsToAdd.add(refCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '+5 BPS in Spread / +25 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '+10 BPS in Spread / +25 BPS in Commissionable Fee'
            ) {
              system.debug('25');

              originationPlusCaf = orgFee + 0.025;

              above10Mill = (termComm.Final_Loan_Amount__c - 10000000);
              above10MillComm = (above10Mill * originationPlusCaf) * 0.25;
              system.debug(above10MillComm);
              finComm = (10000000 * originationPlusCaf) * rateBasedOnBorrowed;
              system.debug(finComm);
              finalCommAmount = (above10MillComm + finComm);
              system.debug(finalCommAmount);

              Commission__c myCommission = new Commission__c();
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Commission_Amount1__c =
                finalCommAmount * internalFee;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);
              myCommission.Owner__c = termComm.Internal_Referral__r.id;
              myCommission.OwnerId = termComm.Internal_Referral__r.id;

              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);

              myCommsToAdd.add(myCommission);

              Commission__c refCommission = new Commission__c();
              refCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              refCommission.Commission_Type__c = termComm.Commission_Type__c;
              refCommission.Deal__c = termComm.Deal__c;
              refCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              refCommission.Commission_Detail__c = termComm.Id;
              refCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              refCommission.Loan_Type__c = termComm.Loan_Type__c;
              refCommission.Commission_Amount1__c =
                finalCommAmount - (finalCommAmount * internalFee);
              refCommission.Origination_Fee__c = originationPlusCaf * 100;
              refCommission.Origination_Fee_Amt__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);
              refCommission.Owner__c = termComm.OwnerId;
              refCommission.OwnerId = termComm.OwnerId;

              refCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              refCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              refCommission.Commissionable_Amount__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);

              myCommsToAdd.add(refCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '-5 BPS in Spread / -25 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '-10 BPS in Spread / -25 BPS in Commissionable Fee'
            ) {
              system.debug('-25');

              originationPlusCaf = orgFee - 0.025;

              system.debug(originationPlusCaf);
              above10Mill = (termComm.Final_Loan_Amount__c - 10000000);
              above10MillComm = (above10Mill * originationPlusCaf) * 0.25;
              finComm = (10000000 * originationPlusCaf) * rateBasedOnBorrowed;

              finalCommAmount = (above10MillComm + finComm);
              system.debug(finalCommAmount);

              Commission__c myCommission = new Commission__c();
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Commission_Amount1__c =
                finalCommAmount * internalFee;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);
              myCommission.Owner__c = termComm.Internal_Referral__r.id;
              myCommission.OwnerId = termComm.Internal_Referral__r.id;

              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);

              myCommsToAdd.add(myCommission);

              Commission__c refCommission = new Commission__c();
              refCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              refCommission.Commission_Type__c = termComm.Commission_Type__c;
              refCommission.Deal__c = termComm.Deal__c;
              refCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              refCommission.Commission_Detail__c = termComm.Id;
              refCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              refCommission.Loan_Type__c = termComm.Loan_Type__c;
              refCommission.Commission_Amount1__c =
                finalCommAmount - (finalCommAmount * internalFee);
              refCommission.Origination_Fee__c = originationPlusCaf * 100;
              refCommission.Origination_Fee_Amt__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);
              refCommission.Owner__c = termComm.OwnerId;
              refCommission.OwnerId = termComm.OwnerId;

              refCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              refCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              refCommission.Commissionable_Amount__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);

              myCommsToAdd.add(refCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '+10 BPS in spread / +50 BPS in Commissionable Fee' ||
              termCOmm.CAF_YSP__c ==
              '+15 BPS in Spread / +50 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '+20 BPS in Spread / +50 BPS in Commissionable Fee'
            ) {
              system.debug('50');

              originationPlusCaf = orgFee + 0.005;

              system.debug(originationPlusCaf);
              above10Mill = (termComm.Final_Loan_Amount__c - 10000000);
              above10MillComm = (above10Mill * originationPlusCaf) * 0.25;
              finComm = (10000000 * originationPlusCaf) * rateBasedOnBorrowed;

              finalCommAmount = (above10MillComm + finComm);
              system.debug(finalCommAmount);

              Commission__c myCommission = new Commission__c();
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Commission_Amount1__c =
                finalCommAmount * internalFee;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);
              myCommission.Owner__c = termComm.Internal_Referral__r.id;
              myCommission.OwnerId = termComm.Internal_Referral__r.id;

              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);

              myCommsToAdd.add(myCommission);

              Commission__c refCommission = new Commission__c();
              refCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              refCommission.Commission_Type__c = termComm.Commission_Type__c;
              refCommission.Deal__c = termComm.Deal__c;
              refCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              refCommission.Commission_Detail__c = termComm.Id;
              refCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              refCommission.Loan_Type__c = termComm.Loan_Type__c;
              refCommission.Commission_Amount1__c =
                finalCommAmount - (finalCommAmount * internalFee);
              refCommission.Origination_Fee__c = originationPlusCaf * 100;
              refCommission.Origination_Fee_Amt__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);
              refCommission.Owner__c = termComm.OwnerId;
              refCommission.OwnerId = termComm.OwnerId;

              refCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              refCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              refCommission.Commissionable_Amount__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);

              myCommsToAdd.add(refCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '-10 BPS in spread / -50 BPS in Commissionable Fee' ||
              termCOmm.CAF_YSP__c ==
              '-15 BPS in Spread / -50 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '-20 BPS in Spread / -50 BPS in Commissionable Fee'
            ) {
              system.debug('-50');

              originationPlusCaf = orgFee - 0.005;

              system.debug(originationPlusCaf);
              above10Mill = (termComm.Final_Loan_Amount__c - 10000000);
              above10MillComm = (above10Mill * originationPlusCaf) * 0.25;
              finComm = (10000000 * originationPlusCaf) * rateBasedOnBorrowed;

              finalCommAmount = (above10MillComm + finComm);
              system.debug(finalCommAmount);

              Commission__c myCommission = new Commission__c();
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Commission_Amount1__c =
                finalCommAmount * internalFee;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);
              myCommission.Owner__c = termComm.Internal_Referral__r.id;
              myCommission.OwnerId = termComm.Internal_Referral__r.id;

              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);

              myCommsToAdd.add(myCommission);

              Commission__c refCommission = new Commission__c();
              refCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              refCommission.Commission_Type__c = termComm.Commission_Type__c;
              refCommission.Deal__c = termComm.Deal__c;
              refCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              refCommission.Commission_Detail__c = termComm.Id;
              refCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              refCommission.Loan_Type__c = termComm.Loan_Type__c;
              refCommission.Commission_Amount1__c =
                finalCommAmount - (finalCommAmount * internalFee);
              refCommission.Origination_Fee__c = originationPlusCaf * 100;
              refCommission.Origination_Fee_Amt__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);
              refCommission.Owner__c = termComm.OwnerId;
              refCommission.OwnerId = termComm.OwnerId;

              refCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              refCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              refCommission.Commissionable_Amount__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);

              myCommsToAdd.add(refCommission);
            }
          } else {
            if (
              termComm.CAF_YSP__c == '0 BPS in Spread' ||
              termComm.CAF_YSP__c == null
            ) {
              system.debug(orgFee);
              system.debug(rateBasedOnBorrowed);
              above10Mill = (termComm.Final_Loan_Amount__c - 10000000);
              above10MillComm = (above10Mill * orgFee) * 0.25;
              finComm = (10000000 * orgFee) * rateBasedOnBorrowed;
              finalCommAmount = (above10MillComm + finComm);

              Commission__c myCommission = new Commission__c();

              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;

              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Owner__c = termComm.OwnerId;
              myCommission.OwnerId = termComm.OwnerId;

              myCommission.Commission_Amount1__c = finalCommAmount;
              myCommission.Origination_Fee__c = orgFee * 100;
              myCommission.Origination_Fee_Amt__c =
                (10000000 * orgFee) + (above10Mill * orgFee);
              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                (10000000 * orgFee) + (above10Mill * orgFee);

              myCommsToAdd.add(myCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '+5 BPS in Spread / +25 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '+10 BPS in Spread / +25 BPS in Commissionable Fee'
            ) {
              originationPlusCaf = orgFee + 0.0025;
              system.debug(originationPlusCaf);
              above10Mill = (termComm.Final_Loan_Amount__c - 10000000);
              above10MillComm = (above10Mill * originationPlusCaf) * 0.25;
              finComm = (10000000 * originationPlusCaf) * rateBasedOnBorrowed;

              finalCommAmount = (above10MillComm + finComm);
              system.debug(finalCommAmount);

              Commission__c myCommission = new Commission__c();

              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;

              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Owner__c = termComm.OwnerId;
              myCommission.OwnerId = termComm.OwnerId;

              myCommission.Commission_Amount1__c = finalCommAmount;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);
              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);

              myCommsToAdd.add(myCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '-5 BPS in Spread / -25 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '-10 BPS in Spread / -25 BPS in Commissionable Fee'
            ) {
              originationPlusCaf = orgFee - 0.0025;

              system.debug(originationPlusCaf);
              above10Mill = (termComm.Final_Loan_Amount__c - 10000000);
              above10MillComm = (above10Mill * originationPlusCaf) * 0.25;
              finComm = (10000000 * originationPlusCaf) * rateBasedOnBorrowed;

              finalCommAmount = (above10MillComm + finComm);
              system.debug(finalCommAmount);

              Commission__c myCommission = new Commission__c();

              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;

              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Owner__c = termComm.OwnerId;
              myCommission.OwnerId = termComm.OwnerId;

              myCommission.Commission_Amount1__c = finalCommAmount;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);
              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);

              myCommsToAdd.add(myCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '+10 BPS in spread / +50 BPS in Commissionable Fee' ||
              termCOmm.CAF_YSP__c ==
              '+15 BPS in Spread / +50 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '+20 BPS in Spread / +50 BPS in Commissionable Fee'
            ) {
              originationPlusCaf = orgFee + 0.005;
              system.debug(originationPlusCaf);

              system.debug(originationPlusCaf);
              above10Mill = (termComm.Final_Loan_Amount__c - 10000000);
              above10MillComm = (above10Mill * originationPlusCaf) * 0.25;
              finComm = (10000000 * originationPlusCaf) * rateBasedOnBorrowed;

              finalCommAmount = (above10MillComm + finComm);
              system.debug(finalCommAmount);

              Commission__c myCommission = new Commission__c();

              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;

              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Owner__c = termComm.OwnerId;
              myCommission.OwnerId = termComm.OwnerId;

              myCommission.Commission_Amount1__c = finalCommAmount;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);
              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);

              myCommsToAdd.add(myCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '-10 BPS in spread / -50 BPS in Commissionable Fee' ||
              termCOmm.CAF_YSP__c ==
              '-15 BPS in Spread / -50 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '-20 BPS in Spread / -50 BPS in Commissionable Fee'
            ) {
              originationPlusCaf = orgFee - 0.005;

              system.debug(originationPlusCaf);
              above10Mill = (termComm.Final_Loan_Amount__c - 10000000);
              above10MillComm = (above10Mill * originationPlusCaf) * 0.25;
              finComm = (10000000 * originationPlusCaf) * rateBasedOnBorrowed;

              finalCommAmount = (above10MillComm + finComm);
              system.debug(finalCommAmount);

              Commission__c myCommission = new Commission__c();

              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;

              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Owner__c = termComm.OwnerId;
              myCommission.OwnerId = termComm.OwnerId;

              myCommission.Commission_Amount1__c = finalCommAmount;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);
              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);

              myCommsToAdd.add(myCommission);
            }
          }
            
        } else if (
          termComm.Final_Loan_Amount__c > 10000000 &&
          termComm.Commission_Type__c == 'Internal' &&
          termComm.Originator_Paid_in_Full__c != true
        ) {
          system.debug('over 10 mil and internal');
          rateBasedOnBorrowed = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c -
            termComm.Final_Loan_Amount__c >= 10000000
            ? 0.15
            : 0.35;

          if (
            termComm.Internal_Referral__c != null && termComm.Internal_Referral_Fee_Bypass__c !=true &&
            termComm.Internal_Referral_Fee__c != null &&
            termComm.Internal_Referral_Fee__c != 'N/A' &&
            termComm.Internal_Referral__r.isActive == true

          ) {
            system.debug('internal condition 4');

           // decimal internalFee = termComm.Internal_Referral_Fee__c == '20%'
            //  ? .20
            //  : .50;
            
                                      decimal internalFee;
                        
                        if(termComm.Internal_Referral_Fee__c == '10%'){
                            internalFee = .10;
                        }else if(termComm.Internal_Referral_Fee__c == '20%'){
                            internalFee = .20;
                            
                        }else if(termComm.Internal_Referral_Fee__c == '30%'){
                            internalFee = .30;
                            
                        }else if(termComm.Internal_Referral_Fee__c == '50%'){
                            internalFee = .50;
                            
                        }

            if (
              termComm.CAF_YSP__c == '0 BPS in Spread' ||
              termComm.CAF_YSP__c == null
            ) {
              system.debug('0 BPS in Spread');

              system.debug(orgFee);
              above10Mill = (termComm.Final_Loan_Amount__c - 10000000);
              system.debug(above10Mill);
              above10MillComm = (above10Mill * orgFee) * 0.15;
              system.debug(above10MillComm);
              finComm = (10000000 * orgFee) * rateBasedOnBorrowed;
              system.debug(finComm);
              finalCommAmount = (above10MillComm + finComm);
              system.debug(finalCommAmount);

              Commission__c myCommission = new Commission__c();
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Commission_Amount1__c =
                finalCommAmount * internalFee;
              myCommission.Origination_Fee__c = orgFee * 100;
              myCommission.Origination_Fee_Amt__c =
                (10000000 * orgFee) + (above10Mill * orgFee);
              myCommission.Owner__c = termComm.Internal_Referral__r.id;
              myCommission.OwnerId = termComm.Internal_Referral__r.id;

              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                (10000000 * orgFee) + (above10Mill * orgFee);

              myCommsToAdd.add(myCommission);

              Commission__c refCommission = new Commission__c();
              refCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              refCommission.Commission_Type__c = termComm.Commission_Type__c;
              refCommission.Deal__c = termComm.Deal__c;
              refCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              refCommission.Commission_Detail__c = termComm.Id;
              refCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              refCommission.Loan_Type__c = termComm.Loan_Type__c;
              refCommission.Commission_Amount1__c =
                finalCommAmount - (finalCommAmount * internalFee);
              refCommission.Origination_Fee__c = orgFee * 100;
              refCommission.Origination_Fee_Amt__c =
                (10000000 * orgFee) + (above10Mill * orgFee);
              refCommission.Owner__c = termComm.OwnerId;
              refCommission.OwnerId = termComm.OwnerId;

              refCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              refCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              refCommission.Commissionable_Amount__c =
                (10000000 * orgFee) + (above10Mill * orgFee);

              myCommsToAdd.add(refCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '+5 BPS in Spread / +25 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '+10 BPS in Spread / +25 BPS in Commissionable Fee'
            ) {
              system.debug('25');

              originationPlusCaf = orgFee + 0.025;

              above10Mill = (termComm.Final_Loan_Amount__c - 10000000);
              above10MillComm = (above10Mill * originationPlusCaf) * 0.15;
              system.debug(above10MillComm);
              finComm = (10000000 * originationPlusCaf) * rateBasedOnBorrowed;
              system.debug(finComm);
              finalCommAmount = (above10MillComm + finComm);
              system.debug(finalCommAmount);

              Commission__c myCommission = new Commission__c();
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Commission_Amount1__c =
                finalCommAmount * internalFee;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);
              myCommission.Owner__c = termComm.Internal_Referral__r.id;
              myCommission.OwnerId = termComm.Internal_Referral__r.id;

              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);

              myCommsToAdd.add(myCommission);

              Commission__c refCommission = new Commission__c();
              refCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              refCommission.Commission_Type__c = termComm.Commission_Type__c;
              refCommission.Deal__c = termComm.Deal__c;
              refCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              refCommission.Commission_Detail__c = termComm.Id;
              refCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              refCommission.Loan_Type__c = termComm.Loan_Type__c;
              refCommission.Commission_Amount1__c =
                finalCommAmount - (finalCommAmount * internalFee);
              refCommission.Origination_Fee__c = originationPlusCaf * 100;
              refCommission.Origination_Fee_Amt__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);
              refCommission.Owner__c = termComm.OwnerId;
              refCommission.OwnerId = termComm.OwnerId;

              refCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              refCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              refCommission.Commissionable_Amount__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);

              myCommsToAdd.add(refCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '-5 BPS in Spread / -25 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '-10 BPS in Spread / -25 BPS in Commissionable Fee'
            ) {
              system.debug('-25');

              originationPlusCaf = orgFee - 0.025;

              above10Mill = (termComm.Final_Loan_Amount__c - 10000000);
              above10MillComm = (above10Mill * originationPlusCaf) * 0.15;
              system.debug(above10MillComm);
              finComm = (10000000 * originationPlusCaf) * rateBasedOnBorrowed;
              system.debug(finComm);
              finalCommAmount = (above10MillComm + finComm);
              system.debug(finalCommAmount);

              Commission__c myCommission = new Commission__c();
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Commission_Amount1__c =
                finalCommAmount * internalFee;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);
              myCommission.Owner__c = termComm.Internal_Referral__r.id;
              myCommission.OwnerId = termComm.Internal_Referral__r.id;

              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);

              myCommsToAdd.add(myCommission);

              Commission__c refCommission = new Commission__c();
              refCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              refCommission.Commission_Type__c = termComm.Commission_Type__c;
              refCommission.Deal__c = termComm.Deal__c;
              refCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              refCommission.Commission_Detail__c = termComm.Id;
              refCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              refCommission.Loan_Type__c = termComm.Loan_Type__c;
              refCommission.Commission_Amount1__c =
                finalCommAmount - (finalCommAmount * internalFee);
              refCommission.Origination_Fee__c = originationPlusCaf * 100;
              refCommission.Origination_Fee_Amt__c = above10MillComm + finComm;
              refCommission.Owner__c = termComm.OwnerId;
              refCommission.OwnerId = termComm.OwnerId;

              refCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              refCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              refCommission.Commissionable_Amount__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);

              myCommsToAdd.add(refCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '+10 BPS in spread / +50 BPS in Commissionable Fee' ||
              termCOmm.CAF_YSP__c ==
              '+15 BPS in Spread / +50 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '+20 BPS in Spread / +50 BPS in Commissionable Fee'
            ) {
              system.debug('50');

              originationPlusCaf = orgFee + 0.005;

              above10Mill = (termComm.Final_Loan_Amount__c - 10000000);
              above10MillComm = (above10Mill * originationPlusCaf) * 0.15;
              system.debug(above10MillComm);
              finComm = (10000000 * originationPlusCaf) * rateBasedOnBorrowed;
              system.debug(finComm);
              finalCommAmount = (above10MillComm + finComm);
              system.debug(finalCommAmount);

              Commission__c myCommission = new Commission__c();
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Commission_Amount1__c =
                finalCommAmount * internalFee;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);
              myCommission.Owner__c = termComm.Internal_Referral__r.id;
              myCommission.OwnerId = termComm.Internal_Referral__r.id;

              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);

              myCommsToAdd.add(myCommission);

              Commission__c refCommission = new Commission__c();
              refCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              refCommission.Commission_Type__c = termComm.Commission_Type__c;
              refCommission.Deal__c = termComm.Deal__c;
              refCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              refCommission.Commission_Detail__c = termComm.Id;
              refCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              refCommission.Loan_Type__c = termComm.Loan_Type__c;
              refCommission.Commission_Amount1__c =
                finalCommAmount - (finalCommAmount * internalFee);
              refCommission.Origination_Fee__c = originationPlusCaf * 100;
              refCommission.Origination_Fee_Amt__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);
              refCommission.Owner__c = termComm.OwnerId;
              refCommission.OwnerId = termComm.OwnerId;

              refCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              refCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              refCommission.Commissionable_Amount__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);

              myCommsToAdd.add(refCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '-10 BPS in spread / -50 BPS in Commissionable Fee' ||
              termCOmm.CAF_YSP__c ==
              '-15 BPS in Spread / -50 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '-20 BPS in Spread / -50 BPS in Commissionable Fee'
            ) {
              system.debug('-50');

              originationPlusCaf = orgFee - 0.005;

              above10Mill = (termComm.Final_Loan_Amount__c - 10000000);
              above10MillComm = (above10Mill * originationPlusCaf) * 0.15;
              system.debug(above10MillComm);
              finComm = (10000000 * originationPlusCaf) * rateBasedOnBorrowed;
              system.debug(finComm);
              finalCommAmount = (above10MillComm + finComm);
              system.debug(finalCommAmount);

              Commission__c myCommission = new Commission__c();
              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Commission_Amount1__c =
                finalCommAmount * internalFee;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);
              myCommission.Owner__c = termComm.Internal_Referral__r.id;
              myCommission.OwnerId = termComm.Internal_Referral__r.id;

              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);

              myCommsToAdd.add(myCommission);

              Commission__c refCommission = new Commission__c();
              refCommission.CAF_YSP__c = termComm.CAF_YSP__c;
              refCommission.Commission_Type__c = termComm.Commission_Type__c;
              refCommission.Deal__c = termComm.Deal__c;
              refCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              refCommission.Commission_Detail__c = termComm.Id;
              refCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              refCommission.Loan_Type__c = termComm.Loan_Type__c;
              refCommission.Commission_Amount1__c =
                finalCommAmount - (finalCommAmount * internalFee);
              refCommission.Origination_Fee__c = originationPlusCaf * 100;
              refCommission.Origination_Fee_Amt__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);
              refCommission.Owner__c = termComm.OwnerId;
             refCommission.OwnerId = termComm.OwnerId;

              refCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              refCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              refCommission.Commissionable_Amount__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);

              myCommsToAdd.add(refCommission);
            }
          } else {
            if (
              termComm.CAF_YSP__c == '0 BPS in Spread' ||
              termComm.CAF_YSP__c == null
            ) {
              above10Mill = (termComm.Final_Loan_Amount__c - 10000000);
              above10MillComm = (above10Mill * orgFee) * 0.15;
              finComm = (10000000 * orgFee) * rateBasedOnBorrowed;
              finalCommAmount = (above10MillComm + finComm);

              Commission__c myCommission = new Commission__c();

              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;

              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Owner__c = termComm.OwnerId;
              myCommission.OwnerId = termComm.OwnerId;

              myCommission.Commission_Amount1__c = finalCommAmount;
              myCommission.Origination_Fee__c = orgFee * 100;
              myCommission.Origination_Fee_Amt__c =
                (10000000 * orgFee) + (above10Mill * orgFee);
              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                (10000000 * orgFee) + (above10Mill * orgFee);

              myCommsToAdd.add(myCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '+5 BPS in Spread / +25 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '+10 BPS in Spread / +25 BPS in Commissionable Fee'
            ) {
              originationPlusCaf = orgFee + 0.0025;
              above10Mill = (termComm.Final_Loan_Amount__c - 10000000);
              above10MillComm = (above10Mill * originationPlusCaf) * 0.15;
              system.debug(above10MillComm);
              finComm = (10000000 * originationPlusCaf) * rateBasedOnBorrowed;
              system.debug(finComm);
              finalCommAmount = (above10MillComm + finComm);
              system.debug(finalCommAmount);

              Commission__c myCommission = new Commission__c();

              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;

              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Owner__c = termComm.OwnerId;
              myCommission.Owner__c = termComm.OwnerId;

              myCommission.Commission_Amount1__c = finalCommAmount;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);
              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);

              myCommsToAdd.add(myCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '-5 BPS in Spread / -25 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '-10 BPS in Spread / -25 BPS in Commissionable Fee'
            ) {
              originationPlusCaf = orgFee - 0.0025;

              above10Mill = (termComm.Final_Loan_Amount__c - 10000000);
              above10MillComm = (above10Mill * originationPlusCaf) * 0.15;
              system.debug(above10MillComm);
              finComm = (10000000 * originationPlusCaf) * rateBasedOnBorrowed;
              system.debug(finComm);
              finalCommAmount = (above10MillComm + finComm);
              system.debug(finalCommAmount);

              Commission__c myCommission = new Commission__c();

              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;

              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Owner__c = termComm.OwnerId;
              myCommission.Owner__c = termComm.OwnerId;

              myCommission.Commission_Amount1__c = finalCommAmount;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);
              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);

              myCommsToAdd.add(myCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '+10 BPS in spread / +50 BPS in Commissionable Fee' ||
              termCOmm.CAF_YSP__c ==
              '+15 BPS in Spread / +50 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '+20 BPS in Spread / +50 BPS in Commissionable Fee'
            ) {
              originationPlusCaf = orgFee + 0.005;
              above10Mill = (termComm.Final_Loan_Amount__c - 10000000);
              above10MillComm = (above10Mill * originationPlusCaf) * 0.15;
              system.debug(above10MillComm);
              finComm = (10000000 * originationPlusCaf) * rateBasedOnBorrowed;
              system.debug(finComm);
              finalCommAmount = (above10MillComm + finComm);
              system.debug(finalCommAmount);

              Commission__c myCommission = new Commission__c();

              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;

              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Owner__c = termComm.OwnerId;
              myCommission.Owner__c = termComm.OwnerId;

              myCommission.Commission_Amount1__c = finalCommAmount;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);
              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);

              myCommsToAdd.add(myCommission);
            } else if (
              termComm.CAF_YSP__c ==
              '-10 BPS in spread / -50 BPS in Commissionable Fee' ||
              termCOmm.CAF_YSP__c ==
              '-15 BPS in Spread / -50 BPS in Commissionable Fee' ||
              termComm.CAF_YSP__c ==
              '-20 BPS in Spread / -50 BPS in Commissionable Fee'
            ) {
              originationPlusCaf = orgFee - 0.005;

              above10Mill = (termComm.Final_Loan_Amount__c - 10000000);
              above10MillComm = (above10Mill * originationPlusCaf) * 0.15;
              system.debug(above10MillComm);
              finComm = (10000000 * originationPlusCaf) * rateBasedOnBorrowed;
              system.debug(finComm);
              finalCommAmount = (above10MillComm + finComm);
              system.debug(finalCommAmount);

              Commission__c myCommission = new Commission__c();

              myCommission.CAF_YSP__c = termComm.CAF_YSP__c;

              myCommission.Commission_Type__c = termComm.Commission_Type__c;
              myCommission.Deal__c = termComm.Deal__c;
              myCommission.Final_Loan_Amount_Trigger__c = termComm.Final_Loan_Amount__c;

              myCommission.Commission_Detail__c = termComm.Id;
              myCommission.Account_Intro_Source__c = termComm.Account_Intro_Source__c;
              myCommission.Loan_Type__c = termComm.Loan_Type__c;
              myCommission.Owner__c = termComm.OwnerId;
              myCommission.Owner__c = termComm.OwnerId;

              myCommission.Commission_Amount1__c = finalCommAmount;
              myCommission.Origination_Fee__c = originationPlusCaf * 100;
              myCommission.Origination_Fee_Amt__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);
              myCommission.Total_Borrowed_on_Term__c = termComm.Deal__r.Account.Borrowed_on_Term_Loans__c;
              myCommission.Total_Borrowed_on_Bridge__c = termComm.Deal__r.Account.Total_Borrowed_on_Bridge__c;
              myCommission.Commissionable_Amount__c =
                (10000000 * originationPlusCaf) +
                (above10Mill * originationPlusCaf);

              myCommsToAdd.add(myCommission);
            }
          }
        }
      }
    }


    if (myCommDetailsBridge.size() > 0) {
     List<Commission_Detail__c> commDetailsBridge = new List<Commission_Detail__c>();
    Map<Id, Id> dealDetailMap = new Map<Id, Id>();

    for (Integer i = 0; i < newList.size(); i++) {
      if (newList[i].Loan_Type__c == 'Bridge Loan') {
        commDetailsBridge.add(newList[i]);
        dealDetailmap.put(newList[i].Deal__c, newList[i].Id);
      }
    }
        //ties comm detail to commission generated from advance
    if (commDetailsBridge.size() > 0) {
      for (Commission__c bridgeCommission : [
        SELECT Id, Deal__c
        FROM Commission__c
        WHERE Commission_Detail__c = NULL AND Deal__c IN :dealDetailMap.keySet()
      ]) {
        bridgeCommission.Commission_Detail__c = dealDetailMap.get(
          bridgeCommission.Deal__c
        );
        commsToUpdate.add(bridgeCommission);
      }

      update commsToUpdate;

    }

    }

    if (myCommsToAdd.size() > 0) {
      insert myCommsToAdd;
    }
  }
}