import { LightningElement, api, wire } from "lwc";
import {
  subscribe,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext,
  publish
} from "lightning/messageService";

import calcMessage from "@salesforce/messageChannel/ScheduleLoanAgreementMessage__c";
import Do_you_sell_Loans_to_this_Company__c from "@salesforce/schema/Account.Do_you_sell_Loans_to_this_Company__c";

export default class LoanAgreementNew extends LightningElement {
  @api deal;

  subscription = null;
  calculatedFields = null;
  //@api loanVersion = {};

  @wire(MessageContext)
  messageContext;

  constructor() {
    super();
  }
  connectedCallback() {
    //console.log("init of deal");
    //console.log("loanAgreement");
    this.subscribeMessageChannel();
    publish(this.messageContext, calcMessage, { type: "init" });
  }

  subscribeMessageChannel() {
    if (this.subscription) {
      return;
    }
    this.subscription = subscribe(
      this.messageContext,
      calcMessage,
      (message) => {
        this.handleMessage(message);
      },
      { scope: APPLICATION_SCOPE }
    );
  }

  unsubscribeToMessageChannel() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  disconnectedCallback() {
    this.unsubscribeToMessageChannel();
  }
  @api
  refresh() {
    publish(this.messageContext, calcMessage, { type: "init" });
  }

  handleMessage(message) {
    console.log("--receiving message--");
    console.log(message);
    //this.calculatedFields();

    if (message.type === "update") {
      this.calculatedFields = message.calculatedFields;
    }
  }

  get loanTypeOptions() {
    const options = [
      { label: "", value: "" },
      { label: "Recourse", value: "Recourse" },
      { label: "Non-Recourse", value: "Non-Recourse" },
      {
        label: "Non-Recourse (No Cash Management)",
        value: "Non-Recourse (No Cash Management)"
      },
      {
        label: "Non-Recourse (Springing Cash Management)",
        value: "Non-Recourse (Springing Cash Management)"
      }
    ];

    return options;
  }

  get cashManagementOptions() {
    const options = [
      { label: "", value: "" },
      { label: "Springing", value: "Springing" },
      { label: "Soft", value: "Soft" },
      { label: "Hard", value: "Hard" },
      { label: "None", value: "None" }
    ];

    return options;
  }

  calculateClosingDateTaxReserveDeposit() {
    return this.totalReserveTaxCalc();
    // return (
    //   this.deal.Origination_Fee__c && (this.deal.Origination_Fee__c * 12) / 2
    // );
  }

  get closingDateTaxReserveDeposit() {
    // return this.totalReserveTaxCalc();
    return this.calculateClosingDateTaxReserveDeposit();
  }

  calculateInitialMonthlyTaxReserveDeposit() {
    return this.monthlyTaxCalc();
    // let val = this.calculateClosingDateTaxReserveDeposit();
    // return val && val / 2;
  }

  get initialMonthlyTaxReserveDeposit() {
    // return this.calculateInitialMonthlyTaxReserveDeposit();
    return this.monthlyTaxCalc();
  }

  // calculateClosingDateTaxReserveDeposit(){
  //   return ""
  // }

  // get closingDateTaxReserveDeposit(){
  //   return ""
  // }

  calculateInitialMonthlyInsuranceReserveDeposit() {
    return this.monthlyInsuranceCalc();
    // return (
    //   this.deal.Deposit_Insurance_Review__c &&
    //   this.deal.Deposit_Insurance_Review__c / 2
    // );
  }

  get initialMonthlyInsuranceReserveDeposit() {
    return this.calculateInitialMonthlyInsuranceReserveDeposit();
  }

  calculateMaturityDate() {
    let months =
      this.deal.Term_Loan_Type_Months__c &&
      parseInt(this.deal.Term_Loan_Type_Months__c.replace("months", "").trim());

    let val = "";
    console.log(this.deal.First_Payment_Date1__c, months);
    if (this.deal.First_Payment_Date1__c && months) {
      let d = new Date(this.deal.First_Payment_Date1__c);
      val = new Date(d.setUTCMonth(d.getMonth() + months - 1));
      console.log(val);
      val = val.toISOString().split("T")[0];
      console.log("ISO val = " + val);
    }

    console.log(val);

    return val;
  }

  get maturityDate() {
    return this.calculateMaturityDate();
  }

  calculateDebtReserve() {
    let debtreserve = null;

    if (this.calculatedFields) {
      //if (this.calculatedFields.Holdback_Reserve_Override__c) {
      //   debtreserve = this.calculatedFields.Holdback_Reserve_Override__c;
      // else if (this.calculatedFields.Holdback_Reserve__c) {
      debtreserve = this.calculatedFields.Holdback_Reserve__c;
      //}
    }

    return debtreserve;

    // return this.calculatedFields
    //   ? this.calculatedFields.Holdback_Reserve__c
    //   : null;
  }

  get debtreserve() {
    return this.calculateDebtReserve();
  }

  calculateRequiredDSCR() {
    let val = "Non Applicable";

    if (
      this.deal.Recourse__c &&
      this.deal.Recourse__c.includes("Non-Recourse")
    ) {
      val = this.deal.Min_DSCR__c;
    }

    return val;
  }

  get requiredDSCR() {
    return this.calculateRequiredDSCR();
  }

  calculateInterestOnly() {
    let val = "No";

    if (
      this.deal.IO_Term__c &&
      this.deal.IO_Term__c !== "0 months" &&
      this.deal.IO_Term__c !== "None"
    ) {
      val = "Yes";
    }

    return val;
  }

  get interestOnly() {
    return this.calculateInterestOnly();
  }

  calculateUnderwrittenVacancy() {
    return (
      this.deal.Static_Vacancy__c &&
      this.deal.Credit_Loss_Adjustment__c &&
      this.deal.Static_Vacancy__c + this.deal.Credit_Loss_Adjustment__c
    );
  }

  get underwrittenVacancy() {
    return this.calculateUnderwrittenVacancy();
  }

  // get debtservice() {
  //   return 0;
  // }

  calculateRequiredRentDebtServiceRatio() {
    let val = "Non Applicable";

    if (
      this.deal.Recourse__c == "Recourse" ||
      this.deal.Recourse__c ===
        "Non-Recourse (Non-Recourse (No Cash Management)"
    ) {
      val = "1.80x";
    }

    return val;
  }

  get requiredRentDebtServiceRatio() {
    return this.calculateRequiredRentDebtServiceRatio();
  }

  updateValue(event) {
    const deal = JSON.parse(JSON.stringify(this.deal));
    deal[event.target.getAttribute("data-name")] = event.target.value;
    this.deal = deal;
  }

  get holdback() {
    return this.holdbackReserveCalc();
  }

  holdbackReserveCalc() {
    let val = 0;

    if (!this.calculatedFields) {
      var PV = this.deal.Current_Loan_Amount__c;
      var Indicative_Rate = this.finalInterestRateCalc();
      if (this.deal.Interest_Rate_Type__c == "Fixed") {
        if (PV && Indicative_Rate) {
          //PMT= (PV*Rate*(1+Rate)^nper)/[(1+Rate)^nper - 1]
          var rate = parseFloat((Indicative_Rate * 365) / (12 * 360 * 100));
          var pmt = parseFloat(
            (PV * rate * Math.pow(1 + rate, 360)) /
              (Math.pow(1 + rate, 360) - 1)
          ).toFixed(2);
          //component.find("DebtService").set("v.value", pmt);
          val = pmt;
        }
      } else if (this.deal.Interest_Rate_Type__c == "Interest Only") {
        if (PV && Indicative_Rate && this.deal.IO_Term__c) {
          //IPMT = pmt + (1+rate)^(nper-1)*(pv *rate - pmt)
          var rate = parseFloat((Indicative_Rate * 365) / (12 * 360 * 100));
          var IO_Term = this.deal.IO_Term__c;
          var nper = parseInt(IO_Term.split(" months")[0]);

          var pmt = parseFloat(
            (PV * rate * Math.pow(1 + rate, 360)) /
              (Math.pow(1 + rate, 360) - 1)
          );
          var ipmt = parseFloat(
            pmt + (1 + Math.pow(rate, nper - 1)) * PV * rate - pmt
          ).toFixed(2);
          //component.find("DebtService").set("v.value", ipmt);
          val = ipmt;
        }
      }

      //console.log("holdback");
      //console.log(val);
    } else {
      val = this.calculatedFields.Required_Holdback_Reserve__c;
    }

    return val;
  }

  finalInterestRateCalc() {
    var InterestRateTermSheet = 0;
    if (this.deal.Final_Swap__c && this.deal.Final_Spread__c) {
      var yearSwapRate = parseFloat(this.deal.Final_Swap__c);
      var creditSpread = parseFloat(this.deal.Final_Spread__c);
      InterestRateTermSheet = parseFloat(yearSwapRate + creditSpread).toFixed(
        2
      );
    }

    return InterestRateTermSheet;
  }

  totalSourcesCalc() {
    var TotalSources = null;
    if (this.deal.Current_Loan_Amount__c && this.deal.Deposit_Amount__c) {
      var Final_Loan_Amount = parseFloat(this.deal.Current_Loan_Amount__c);
      var Deposit_Amount = parseFloat(this.deal.Deposit_Amount__c);
      TotalSources = parseFloat(Final_Loan_Amount + Deposit_Amount).toFixed(2);
    }

    return TotalSources;
  }

  fundingDateCalc() {
    let closingDate = new Date(this.deal.CloseDate);

    let fundingDate2 = new Date(
      closingDate.getFullYear(),
      closingDate.getMonth() + 1,
      0
    );
    fundingDate2 = fundingDate2.toISOString();

    return fundingDate2;
  }

  stubInterestDayCountCalc() {
    let stubInterestDayCount = null;

    let fundingDate1 = this.deal.CloseDate;
    let fundingDate2 = this.fundingDateCalc();

    var date1 = new Date(fundingDate1);
    var date2 = new Date(fundingDate2);
    var diffTime = Math.abs(date2 - date1 + 1);
    stubInterestDayCount = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return stubInterestDayCount;
  }

  stubInterestCalc() {
    var stubInterest = 0;
    var InterestRateTermSheet = 0;
    var Final_Loan_Amount = 0;
    var stubInterestDayCount = 0;

    let finalInterestRate = this.finalInterestRateCalc();
    if (finalInterestRate) {
      InterestRateTermSheet = parseFloat(finalInterestRate).toFixed(2);
    }
    if (this.deal.Current_Loan_Amount__c) {
      Final_Loan_Amount = parseFloat(this.deal.Current_Loan_Amount__c).toFixed(
        2
      );
    }

    let stubInterestDay = this.stubInterestDayCountCalc();

    if (stubInterestDay) {
      stubInterestDayCount = parseFloat(stubInterestDay).toFixed(2);
    }
    stubInterest = parseFloat(
      (parseFloat(InterestRateTermSheet) *
        parseFloat(Final_Loan_Amount) *
        parseFloat(stubInterestDayCount)) /
        36000
    ).toFixed(2);

    return stubInterest;
  }

  totalLenderCalc() {
    var totalLender = 0;
    var Origination_Fee = 0;
    var stubInterest = 0;
    var Lender_Diligence_Out_of_Pocket = 0;
    var cfcorevestpurchaser = 0;

    if (this.deal.Calculated_Origination_Fee__c) {
      Origination_Fee = parseFloat(
        this.deal.Calculated_Origination_Fee__c
      ).toFixed(2);
    }

    let stubInterestTemp = this.stubInterestCalc();

    if (stubInterestTemp) {
      stubInterest = parseFloat(stubInterestTemp).toFixed(2);
    }
    if (this.deal.Deposit_Lender_Out_of_Pocket__c) {
      Lender_Diligence_Out_of_Pocket = parseFloat(
        this.deal.Deposit_Lender_Out_of_Pocket__c
      ).toFixed(2);
    }
    if (this.deal.Bridge_Payoff__c) {
      cfcorevestpurchaser = parseFloat(this.deal.Bridge_Payoff__c).toFixed(2);
    }
    totalLender = parseFloat(
      parseFloat(
        parseFloat(Origination_Fee) +
          parseFloat(stubInterest) +
          parseFloat(Lender_Diligence_Out_of_Pocket) +
          parseFloat(cfcorevestpurchaser)
      )
    ).toFixed(2);

    return totalLender;
  }

  corevestProceedsCalc() {
    var CorevestProceeds = 0;
    var TotalSources = 0;
    var totalLender = 0;

    let totalSources = this.totalSourcesCalc();

    if (totalSources) {
      TotalSources = parseFloat(totalSources).toFixed(2);
    }
    let totalLenderCalc = this.totalLenderCalc();
    if (totalLenderCalc) {
      totalLender = parseFloat(totalLenderCalc).toFixed(2);
    }
    CorevestProceeds = parseFloat(
      parseFloat(TotalSources) - parseFloat(totalLender)
    ).toFixed(2);

    return CorevestProceeds;
  }

  monthlyTaxCalc() {
    var tax = 0;
    var taxentry = 0;

    if (!this.calculatedFields) {
      if (this.deal.Total_Annual_Tax__c) {
        taxentry = parseFloat(this.deal.Total_Annual_Tax__c);
        tax = parseFloat(taxentry / 12).toFixed(2);
      }
    } else {
      tax = parseFloat(this.calculatedFields.Monthly_Tax__c).toFixed(2);
    }

    return tax;
  }

  // get totalReserveTax() {
  //   return this.totalReserveTax();
  // }

  totalReserveTaxCalc() {
    var totalreservetax = 0;
    var tax = 0;
    var reservetax = 0;

    if (!this.calculatedFields) {
      let monthlyTaxCalc = this.monthlyTaxCalc();

      if (monthlyTaxCalc) {
        tax = parseFloat(monthlyTaxCalc);
      }
      if (this.deal.Reserve_Tax__c) {
        reservetax = parseFloat(this.deal.Reserve_Tax__c);
      }
      totalreservetax =
        reservetax != 0 ? parseFloat(tax * reservetax).toFixed(2) : 0;
    } else {
      totalreservetax = parseFloat(
        this.calculatedFields.Total_Reserve_Tax__c
      ).toFixed(2);
    }

    return totalreservetax;
  }

  monthlyInsuranceCalc() {
    var insurance = 0;
    var insuranceentry = 0;

    if (!this.calculatedFields) {
      if (this.deal.Total_Annual_Insurance__c) {
        insuranceentry = parseFloat(this.deal.Total_Annual_Insurance__c);
        insurance = parseFloat(insuranceentry / 12).toFixed(2);
      }
    } else {
      insurance = parseFloat(
        this.calculatedFields.Monthly_Insurance__c
      ).toFixed(2);
    }

    return insurance;
  }

  get closingInsuranceReserve() {
    return this.totalReserveInsuranceCalc();
  }

  totalReserveInsuranceCalc() {
    var totalreserveinsurance = 0;
    var insurence = 0;
    var reserveinsurance = 0;

    if (!this.calculatedFields) {
      let monthlyInsuranceCalc = this.monthlyInsuranceCalc();

      if (monthlyInsuranceCalc) {
        insurence = parseFloat(monthlyInsuranceCalc);
      }
      if (this.deal.Reserve_Insurance__c) {
        reserveinsurance = parseFloat(this.deal.Reserve_Insurance__c);
      }
      totalreserveinsurance =
        reserveinsurance != 0
          ? parseFloat(insurence * reserveinsurance).toFixed(2)
          : 0;
    } else {
      totalreserveinsurance = parseFloat(
        this.calculatedFields.Total_Reserve_Insurance__c
      ).toFixed(2);
    }

    return totalreserveinsurance;
  }

  monthlyCapExCalc() {
    var capex = 0;
    var capexentry = 0;
    if (this.deal.Total_Annual_Cap_Ex__c) {
      capexentry = parseFloat(this.deal.Total_Annual_Cap_Ex__c);
      capex = parseFloat(capexentry / 12).toFixed(2);
    }
    return capex;
  }

  totalReserveCapExCalc() {
    var totalreservecapex = 0;
    var capex = 0;
    var reservecapex = 0;

    let monthlyCapExCalc = this.monthlyCapExCalc();
    if (monthlyCapExCalc) {
      capex = parseFloat(monthlyCapExCalc);
    }
    if (this.deal.Reserve_Cap_Ex__c) {
      reservecapex = parseFloat(this.deal.Reserve_Cap_Ex__c);
    }
    totalreservecapex =
      reservecapex != 0 ? parseFloat(capex * reservecapex).toFixed(2) : 0;
    return totalreservecapex;
  }

  get monthlyPayment() {
    return this.monthlyPaymentCalc();
  }

  monthlyPaymentCalc() {
    var capex = 0;
    var insurence = 0;
    var tax = 0;
    var DebtService = 0;
    var debtreserve = 0;

    if (!this.calculatedFields) {
      let monthlyCapExCalc = this.monthlyCapExCalc();

      let monthlyInsuranceCalc = this.monthlyInsuranceCalc();

      let monthlyTaxCalc = this.monthlyTaxCalc();

      let holdbackReserveCalc = this.holdbackReserveCalc();

      if (monthlyCapExCalc) {
        capex = parseFloat(monthlyCapExCalc);
      }
      if (monthlyInsuranceCalc) {
        insurence = parseFloat(monthlyInsuranceCalc);
      }
      if (monthlyTaxCalc) {
        tax = parseFloat(monthlyTaxCalc);
      }
      if (holdbackReserveCalc) {
        DebtService = parseFloat(holdbackReserveCalc);
      }

      debtreserve = parseFloat(capex + insurence + tax + DebtService).toFixed(
        2
      );
    } else {
      debtreserve = this.calculatedFields.Monthly_Payment__c;
    }

    return debtreserve;
  }

  // get totalReserveClosing() {
  //   return this.totalReserveClosingCalc();
  // }
  totalReserveClosingCalc() {
    var totalreserves = 0;

    let holdbackReserveCalc = this.holdbackReserveCalc();

    if (
      holdbackReserveCalc &&
      this.deal.Recourse__c == "Non-Recourse" &&
      this.deal.Cash_Management__c === "None"
    ) {
      totalreserves += parseFloat(this.holdbackReserveCalc());
    }
    let totalReserveTaxCalc = this.totalReserveTaxCalc();
    if (totalReserveTaxCalc) {
      totalreserves += parseFloat(totalReserveTaxCalc);
    }

    let totalReserveCapExCalc = this.totalReserveCapExCalc();
    if (totalReserveCapExCalc) {
      totalreserves += parseFloat(totalReserveCapExCalc);
    }

    let totalReserveInsuranceCalc = this.totalReserveInsuranceCalc();
    if (totalReserveInsuranceCalc) {
      totalreserves += parseFloat(totalReserveInsuranceCalc);
    }
    return totalreserves;
  }

  // get totalThirdParty() {
  //   return this.totalThirdPartyCalc();
  // }

  totalThirdPartyCalc() {
    let totalThirdParty = 0;
    let loanFees = this.loanFees;

    if (loanFees) {
      loanFees.forEach((loanFee) => {
        let amt = 0;
        if (loanFee.Fee_Amount__c) {
          amt = loanFee.Fee_Amount__c;
        }

        totalThirdParty += amt;
      });
    }

    return totalThirdParty;
  }

  // get netProceedsBorrower() {
  //   return this.netProceedsBorrowerCalc();
  // }

  netProceedsBorrowerCalc() {
    var netproceedstoborrower = 0;

    let totalSourcesCalc = this.totalSourcesCalc();
    if (totalSourcesCalc) {
      netproceedstoborrower += parseFloat(totalSourcesCalc).toFixed(2);
    }

    let totalLenderCalc = this.totalLenderCalc();
    if (totalLenderCalc) {
      netproceedstoborrower -= parseFloat(totalLenderCalc).toFixed(2);
    }

    let totalReserveClosingCalc = this.totalReserveClosingCalc();
    if (totalReserveClosingCalc) {
      netproceedstoborrower -= parseFloat(totalReserveClosingCalc).toFixed(2);
    }

    let totalThirdPartyCalc = this.totalThirdPartyCalc();
    if (totalThirdPartyCalc) {
      netproceedstoborrower -= parseFloat(totalThirdPartyCalc).toFixed(2);
    }
    return netproceedstoborrower;
  }

  // get totalUses() {
  //   return this.totalUsesCalc();
  // }

  totalUsesCalc() {
    var totaluses = 0;

    let netProceedsBorrowerCalc = this.netProceedsBorrowerCalc();
    if (netProceedsBorrowerCalc) {
      totaluses += parseFloat(netProceedsBorrowerCalc);
    }

    let totalLenderCalc = this.totalLenderCalc();
    if (totalLenderCalc) {
      totaluses += parseFloat(totalLenderCalc);
    }

    let totalReserveClosingCalc = this.totalReserveClosingCalc();
    if (totalReserveClosingCalc) {
      totaluses += parseFloat(totalReserveClosingCalc);
    }

    let totalThirdPartyCalc = this.totalThirdPartyCalc();
    if (totalThirdPartyCalc) {
      totaluses += parseFloat(totalThirdPartyCalc);
    }
    //component.find("totaluses").set("v.value", totaluses);
    return totaluses;
  }

  @api returnLoanVersion() {
    console.log(this.deal);
    const loanVersion = {
      sobjectType: "Loan_Version__c",
      Holdback_Reserve__c: this.calculateDebtReserve(),
      Borrower__c: this.deal.Borrower__c,
      Sponsor__c: this.deal.Sponsor__c,
      Underwriter_Vacancy_and_Credit_Loss_Perc__c: this.calculateUnderwrittenVacancy(),
      Recourse__c: this.deal.Recourse__c,
      Required_DSCR_Non_Recourse_Only__c: this.calculateRequiredDSCR(),
      // Required_Rent_to_Debt_Service_Ratio__c: this.calculateRequiredRentDebtServiceRatio(),
      Interest_Only__c: this.calculateInterestOnly(),
      Final_Loan_Amount__c: this.deal.Current_Loan_Amount__c,
      Maturity_Date__c: this.calculateMaturityDate(),
      Monthly_Payment__c: this.monthlyPaymentCalc(),
      Initial_Monthly_Tax_Reserve_Deposit__c: this.calculateInitialMonthlyTaxReserveDeposit(),
      InitialMonthlyInsuranceReserveDeposit__c: this.calculateInitialMonthlyInsuranceReserveDeposit(),
      Required_Holdback_Reserve__c: this.holdbackReserveCalc(),
      Pledgor__c: this.deal.Pledgor__c,
      Origination_Fee__c: this.deal.Calculated_Origination_Fee__c,
      Final_Interest_Rate__c: this.deal.Final_Interest_Rate_Calc__c,
      Closing_Date_Tax_Reserve_Deposit__c: this.totalReserveTaxCalc(),
      Closing_Date_Insurance_Reserve_Deposit__c: this.totalReserveInsuranceCalc(),
      Property_Management_Adjustment__c: this.deal
        .Property_Management_Adjustment__c,
      Cash_Management__c: this.deal.Cash_Management__c,
      YM_Prepayment_Penalty__c: this.deal.YM_Prepayment_Penalty__c,
      YM_Prepayment_Penalty_Description__c: this.deal
        .YM_Prepayment_Penalty_Description__c,
      Interest_Rate_Type__c: this.calculatedFields.Interest_Rate_Type__c
    };

    console.log(loanVersion);

    return loanVersion;
  }

  get showDebtService() {
    let show = false;

    console.log("---show debt service---");
    console.log(this.calculatedFields);
    if (this.calculatedFields) {
      show = this.calculatedFields.Interest_Rate_Type__c !== "Interest Only";
    }

    return show;
  }

  get showYMPrepaymentDescription() {
    let show = true;

    if (this.deal) {
      show = this.deal.YM_Prepayment_Penalty__c === "Other";
    }

    return show;
  }
}