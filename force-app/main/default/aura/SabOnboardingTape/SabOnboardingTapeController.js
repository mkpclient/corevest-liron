({
  onCompLoad: function (component, event, helper) {
    const headerToFields = [
      {
        header: "FCI Loan No.",
        field: "Servicer_Loan_Number__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Yardi ID",
        field: "Yardi_Id__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Loan No.",
        field: "Deal__r.Deal_Loan_Number__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Lender FCI Account #",
        field: "Servicer_Id__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Originator",
        field: "Deal__r.Owner.Name",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Borrower Company Name",
        field: "Deal__r.Account_Name__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Borrower First Name",
        field: "Deal__r.Contact__r.FirstName",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Middle Initial",
        field: "Deal__r.Contact__r.MiddleName",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Last Name",
        field: "Deal__r.Contact__r.LastName",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Mailing Address/Street",
        field: "Deal__r.Contact__r.MailingStreet",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Mailing Address/City",
        field: "Deal__r.Contact__r.MailingCity",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Mailing Address/State",
        field: "Deal__r.Contact__r.MailingState",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Mailing Address/Zip",
        field: "Deal__r.Contact__r.MailingPostalCode",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Home Phone",
        field: "Deal__r.Contact__r.HomePhone",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Mobile Phone",
        field: "Deal__r.Contact__r.MobilePhone",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Fax",
        field: "Deal__r.Contact__r.Fax",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Social Security or EIN",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Email Address",
        field: "Deal__r.Contact__r.Email",
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
        header: "Property Address/Street",
        field: "Name",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Property Address/City",
        field: "City__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Property Address/State",
        field: "State__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Property Address/Zip",
        field: "ZipCode__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Property Address/County",
        field: "County__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Property Type (i.e. SFR)",
        field: "Property_Type__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Occupancy Type",
        field: "Occupancy_Status__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Borrower's Primary Residence: Yes or No",
        field: "",
        type: "text",
        defaultValue: "No"
      },
      {
        header: "Lien Position / Priority",
        field: "Lien_Position__c",
        type: "ordinalNumber",
        defaultValue: ""
      },
      {
        header: "Funding Date",
        field: "First_Funding_Date__c",
        type: "date",
        defaultValue: ""
      },
      {
        header: "1st Payment Due Date",
        field: "First_Payment_Date__c",
        type: "date",
        defaultValue: ""
      },
      {
        header: "Paid to Date",
        field: "First_Funding_Date__c",
        type: "date",
        defaultValue: ""
      },
      {
        header: "Next Payment Due Date",
        field: "Next_Payment_Date__c",
        type: "date",
        defaultValue: ""
      },
      {
        header: "Note Maturity Date",
        field: "Asset_Maturity_Date__c",
        type: "date",
        defaultValue: ""
      },
      {
        header: "Original Loan Amount",
        field: "Deal__r.Amount",
        type: "currency",
        defaultValue: ""
      },
      {
        header: "Current Principal Bal (Interest Bearing Balance)",
        field: "Current_UPB__c",
        type: "currency",
        defaultValue: ""
      },
      {
        header: "Current P&I Monthly Payment",
        field: "Current_P_I_Monthly_Payment__c",
        type: "currency",
        defaultValue: ""
      },
      {
        header: "Late Charge: Grace Days",
        field: "",
        type: "number",
        defaultValue: "0"
      },
      {
        header: "Late Charge: % or $",
        field: "Late_Charge__c",
        type: "percent",
        defaultValue: ""
      },
      {
        header: "Default Rate",
        field: "Default_Rate__c",
        type: "percent",
        defaultValue: ""
      },
      {
        header: "Default Rate: Grace Days",
        field: "",
        type: "number",
        defaultValue: "0"
      },
      {
        header: "Enable Default Rate at Boarding (Y/N)",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Default Rate Replaces Late Charges (Y/N)",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Current Monthly Tax Impounds",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Current Monthly Insurance Impounds",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Total Monthly Pymt Amt",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Interest Accrual Calculation",
        field: "Interest_Accrual_Calculation__c",
        type: "currency",
        defaultValue: ""
      },
      {
        header: "Prepayment Penalty Expiration Date",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Prepayment Terms",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Amortization Type",
        field: "Deal__r.Amortization_Term__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Rate Type",
        field: "Deal__r.Interest_Rate_Type__c",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Note Interest Rate",
        field: "Deal__r.Rate__c",
        type: "percent",
        defaultValue: ""
      },
      {
        header: "Sold Rate (to Investor/Lender)",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Broker Servicing Fee",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "FCI Servicing Fee Deducted from Broker or Investor",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Setup Fee Billed or Taken from 1st Distribution",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Setup Fee Paid by Lender or Broker",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header:
          "Escrow Impounds for Taxes and/or Insurance included in Borrower Payment: Yes or No",
        field: "",
        type: "text",
        defaultValue: "No"
      },
      {
        header: "Trust/Suspense Balance",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Escrow Balance",
        field: "",
        type: "currency",
        defaultValue: "0"
      },
      {
        header: "Rec. Corporate Advance Bal.",
        field: "",
        type: "text",
        defaultValue: ""
      },
      {
        header: "Unpaid Late Charges",
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
          let currProp = properties[i];
          for (let j = 0; j < headerToFieldMap.length; j++) {
            let currCell = j + 1;
            let currData = headerToFieldMap[j];

            let currVal = currData.defaultValue;
            if (currData.field != null && currData.field.length > 0) {
              let fieldArray = currData.field.split(".");
              let parent = currProp;
              fieldArray.forEach((field) => {
                if (parent.hasOwnProperty(field)) {
                  if (field[field.length - 1] == "r") {
                    parent = parent[field];
                  } else {
                    currVal = parent[field];
                  }
                }
              });
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