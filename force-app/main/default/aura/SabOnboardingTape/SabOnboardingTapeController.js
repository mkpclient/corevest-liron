({
  onCompLoad: function (component, event, helper) {
    const headerToFields = [
      {
        header: "B Piece Amount",
        field: "",
        type: "text",
        defaultValue: "N/A"
      },
      {
        header: "FCI Loan No.",
        field: "Property__r.Servicer_Loan_Number__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Investor Asset Number",
        field: "Property__r.Yardi_Id__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Previous Account Number",
        field: "Property__r.Deal__r.Deal_Code__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Lender FCI Account #",
        field: "Property__r.Servicer_Id__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Vendor Account (Asset Manager)",
        field: "",
        type: "text",
        defaultValue: "CoreVest"
      },
      {
        header: "Borrower Company Name",
        field: "Property__r.Deal__r.Account_Name__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Borrower Full Name",
        field: "Property__r.Deal__r.Contact__r.Name",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Borrower First Name",
        field: "Property__r.Deal__r.Contact__r.FirstName",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Middle Initial",
        field: "Property__r.Deal__r.Contact__r.MiddleName",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Borrower Last Name",
        field: "Property__r.Deal__r.Contact__r.LastName",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Authorized Contacts for Borrower",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Mailing Address/Street",
        field: "Property__r.Deal__r.Contact__r.MailingStreet",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Mailing Address/City",
        field: "Property__r.Deal__r.Contact__r.MailingCity",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Mailing Address/State",
        field: "Property__r.Deal__r.Contact__r.MailingState",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Mailing Address/Zip",
        field: "Property__r.Deal__r.Contact__r.MailingPostalCode",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Home Phone",
        field: "Property__r.Deal__r.Contact__r.HomePhone",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Mobile Phone",
        field: "Property__r.Deal__r.Contact__r.MobilePhone",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Fax",
        field: "Property__r.Deal__r.Contact__r.Fax",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Social Security or EIN",
        field: "Property__r.Deal__r.Borrower_Entity__r.Business_Tax_ID_EIN__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Email Address",
        field: "Property__r.Deal__r.Contact__r.Email",
        type: "text",
        defaultValue: ""
      },
      {
        header: "CoBorrower/Name",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "CoBorrower/Social Security No.",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "CoBorrower/Home Phone",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "CoBorrower/Work Phone",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "CoBorrower/Mobile Phone",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Property Address/Street",
        field: "Property__r.Name",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Property Address/City",
        field: "Property__r.City__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Property Address/State",
        field: "Property__r.State__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Property Address/Zip",
        field: "Property__r.ZipCode__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Property Address/County",
        field: "Property__r.County__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Property Type (i.e. SFR)",
        field: "Property__r.Property_Type__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Occupancy Type",
        field: "Property__r.Occupancy_Status__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "APN (Parcel ID)",
        field: "Property__r.APN__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Loan Type",
        field: "",
        type: "text",
        defaultValue: "Business"
      },
      // {
      //   header: "Borrower's Primary Residence: Yes or No",
      //   field: "",
      //   type: "text",
      //   defaultValue: "No"
      // },
      {
        header: "Lien Position / Priority",
        field: "",
        type: "text",
        defaultValue: "1st Position"
      },
      {
        header: "Funding Date",
        field: "Advance__r.Wire_Date__c",
        type: "date",
        defaultValue: ""
      },
      {
        header: "1st Payment Due Date",
        field: "Property__r.First_Payment_Date__c",
        type: "date",
        defaultValue: ""
      },
      // {
      //   header: "Paid to Date",
      //   field: "First_Funding_Date__c",
      //   type: "date",
      //   defaultValue: ""
      // },
      {
        header: "Next Payment Due Date",
        field: "Property__r.Next_Payment_Date__c",
        type: "date",
        defaultValue: ""
      },
      {
        header: "Note Maturity Date",
        field: "Property__r.Asset_Maturity_Date__c",
        type: "date",
        defaultValue: ""
      },
      {
        header: "Original Loan Amount",
        field: "Property__r.Deal__r.LOC_Commitment__c",
        type: "currency",
        defaultValue: ""
      },
      {
        header: "Current Principal Bal (Interest Bearing Balance)",
        field: "Advance__r.Initial_Disbursement_Total__c",
        type: "currency",
        defaultValue: ""
      },
      {
        header: "Minimum Late Fee",
        field: "",
        type: "text",
        defaultValue: ""
      },
      // {
      //   header: "Current P&I Monthly Payment",
      //   field: "Current_P_I_Monthly_Payment__c",
      //   type: "currency",
      //   defaultValue: ""
      // },
      {
        header: "Late Charge: Grace Days",
        field: "",
        type: "number",
        defaultValue: "0"
      },
      {
        header: "Late Charge: % or $",
        field: "Property__r.Late_Charge__c",
        type: "percent",
        defaultValue: ""
      },
      {
        header: "Late Fee Disbursement to Broker",
        field: "",
        type: "percent",
        defaultValue: "50"
      },
      {
        header: "Default Rate",
        field: "Property__r.Default_Rate__c",
        type: "percent",
        defaultValue: ""
      },
      {
        header: "Default Rate Disbursement Broker %",
        field: "",
        type: "percent",
        defaultValue: "50"
      },
      {
        header: "Default Rate Disbursement Lender %",
        field: "",
        type: "percent",
        defaultValue: "50"
      },
      {
        header: "Default Interest Effective Date",
        field: "Property__r.Next_Payment_Date__c",
        type: "date",
        defaultValue: ""
      },
      {
        header: "Default Int Grace Period",
        field: "",
        type: "text",
        defaultValue: "N/A"
      },
      {
        header: "Default Int Enable",
        field: "",
        type: "text",
        defaultValue: "Enable"
      },
      {
        header: "Current Monthly Payment Amount",
        field: "",
        type: "currency",
        defaultValue: ""
      },
      {
        header: "Daily Rate",
        field: "",
        type: "number",
        defaultValue: "360"
      },
      {
        header: "Days between Dates",
        field: "",
        type: "text",
        defaultValue: "Actual"
      },
      {
        header: "Dutch Type (if applicable)",
        field: "Property__r.Deal__r.Reno_Funding_Type__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Current Monthly Escrow Payment",
        field: "",
        type: "text",
        defaultValue: "N/A"
      },
      // {
      //   header: "Enable Default Rate at Boarding (Y/N)",
      //   field: "",
      //   type: "text",
      //   defaultValue: ""
      // },
      // {
      //   header: "Default Rate Replaces Late Charges (Y/N)",
      //   field: "",
      //   type: "text",
      //   defaultValue: ""
      // },
      // {
      //   header: "Current Monthly Tax Impounds",
      //   field: "",
      //   type: "text",
      //   defaultValue: ""
      // },
      // {
      //   header: "Current Monthly Insurance Impounds",
      //   field: "",
      //   type: "text",
      //   defaultValue: ""
      // },
      // {
      //   header: "Total Monthly Pymt Amt",
      //   field: "",
      //   type: "text",
      //   defaultValue: ""
      // },
      // {
      //   header: "Interest Accrual Calculation",
      //   field: "Interest_Accrual_Calculation__c",
      //   type: "currency",
      //   defaultValue: ""
      // },
      {
        header: "Prepayment Penalty Expiration Date",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Prepayment Penalty (Y/N)",
        field: "",
        type: "text",
        defaultValue: "N"
      },
      {
        header: "Amortization Type",
        field: "Property__r.Deal__r.Amortization_Term__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Rate Type",
        field: "Property__r.Deal__r.Interest_Rate_Type__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Index Name",
        field: "Property__r.Deal__r.Index__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Floor",
        field: "Property__r.Deal__r.Floor__c",
        type: "percent",
        defaultValue: ""
      },
      {
        header: "Ceiling",
        field: "",
        type: "text",
        defaultValue: "N/A"
      },
      {
        header: "Margin (spread)",
        field: "Property__r.Deal__r.Index_Margin__c",
        type: "percent",
        defaultValue: ""
      },
      {
        header: "Look Back Days",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Note Interest Rate",
        field: "Property__r.Deal__r.Rate__c",
        type: "percent",
        defaultValue: ""
      },
      {
        header: "Yield Spread",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "FCI Servicing Fee is paid by Broker or Investor",
        field: "",
        type: "text",
        defaultValue: "Investor"
      },
      {
        header: "Suspense Balance",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Restricted Balance (construction reserve)",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Escrow Balance",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Set up fee paid by Broker or Lender",
        field: "",
        type: "text",
        defaultValue: "Lender"
      },
      {
        header: "Set Up Fee Paid",
        field: "",
        type: "text",
        defaultValue: "Invoice"
      },
      {
        header: "Unpaid Loan Charges",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Unpaid Interest",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Unpaid Late Fees",
        field: "",
        type: "text",
        defaultValue: ""
      }
    ];
    component.set("v.sheetDataMap", headerToFields);
    helper.retrieveProperties(component, helper);
    helper.getTemplate(component, helper);

  },
  onScriptLoad: function (component, event, helper) {
    console.log("INIT BRIDGE SCRIPT LOADED");
    component.set("v.scriptLoaded", true);
  },

  createSabOnboardingTape: function (component, event, helper) {
    const headerToFieldMap = component.get("v.sheetDataMap");
    const properties = component.get("v.properties");
    XlsxPopulate.fromDataAsync(
      helper.base64ToArrayBuffer(JSON.parse(component.get("v.templateData")))
    )
      .then((workbook) => {
        // row = 1; cell = 3; that's C1;
        let currRow = 2;
        for (let i = 0; i < properties.length; i++) {
          let currProp = helper.flattenObj(properties[i]);
          for (let j = 0; j < headerToFieldMap.length; j++) {
            let currCell = j + 1;
            let currData = headerToFieldMap[j];

            let currVal = currData.defaultValue;
            if (currData.field != null && currData.field.length > 0) {
              currVal = currProp[currData.field];
            }

            if (
              currData.type == "text" ||
              currVal == null ||
              currVal.length == 0
            ) {
              workbook
                .sheet("Sheet1")
                .row(currRow)
                .cell(currCell)
                .value(
                  currData.header == "Middle Initial" &&
                    currVal != null &&
                    currVal.length > 0
                    ? currVal[0]
                    : currVal
                );
            } else if (currData.type == "percent") {
              workbook
                .sheet("Sheet1")
                .row(currRow)
                .cell(currCell)
                .value(parseFloat(currVal) / 100)
                .style("numberFormat", "0.00%");
            } else if (currData.type == "currency") {
              workbook
                .sheet("Sheet1")
                .row(currRow)
                .cell(currCell)
                .value(parseFloat(currVal))
                .style("numberFormat", "$#,##0.00");
            } else if (currData.type == "ordinalNumber") {
              let valAsString = currVal.toString();
              if (valAsString == null || valAsString.length == 0) {
                workbook
                  .sheet("Sheet1")
                  .row(currRow)
                  .cell(currCell)
                  .value(parseFloat(currVal));
                workbook
                  .sheet("Sheet1")
                  .row(currRow)
                  .cell(currCell)
                  .style("bold", true);
              } else {
                let ordinal = "th";
                if (
                  valAsString.length === 1 ||
                  valAsString[valAsString.length - 2] !== "1"
                ) {
                  ordinal =
                    valAsString[valAsString.length - 1] == "1"
                      ? "st"
                      : valAsString[valAsString.length - 1] == "2"
                      ? "2nd"
                      : valAsString[valAsString.length - 1] == "3"
                      ? "rd"
                      : "th";
                }
                workbook
                  .sheet("Sheet1")
                  .row(currRow)
                  .cell(currCell)
                  .value(parseFloat(valAsString + ordinal));
              }
            } else if (currData.type == "number") {
              workbook
                .sheet("Sheet1")
                .row(currRow)
                .cell(currCell)
                .value(parseFloat(currVal));
            } else if (currData.type == "date") {
              const formattedDate = $A.localizationService.formatDate(
                currVal,
                "MM/dd/yyyy"
              );
              workbook
                .sheet("Sheet1")
                .row(currRow)
                .cell(currCell)
                .value(formattedDate);
            }
          }
          currRow++;
        }
        
        return workbook.outputAsync("base64");
      })
      .then((data) => {
        const todayDate = new Date(new Date().toLocaleDateString("en-US"));
        const fileName =
          "SABOnBoardingTape " +
          $A.localizationService.formatDate(todayDate, "MMddyy") +
          ".xlsx";
        var link = document.createElement("a");
        link.href = "data:" + XlsxPopulate.MIME_TYPE + ";base64," + data;
        link.download = fileName;
        link.click();
        helper.saveDealDocument(component, helper, data, fileName);
      });
  }
});