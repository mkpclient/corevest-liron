({
  fetchDealData: function (component, event) {
    component.set("v.dealEdit", {
      propertAddress: "",
      propertAddressDisplay: true,
      initialAdvance: "",
      initialAdvanceDisplay: true,
      renovationAdvance: "",
      renovationAdvanceDisplay: true,
      FixedInterestTypeDisplay: true,
      FloatingInterestTypeDisplay: true,
      extenionOption: "",
      extenionOptionDisplay: true,
      outsideAdvanceDate: "",
      outsideAdvanceDateDisplay: true,
      renovationProperties: "",
      renovationPropertiesDisplay: true,
      renovationFunding: "",
      renovationFundingDisplay: true,
      equityPledge: "",
      equityPledgeDisplay: true,
      MailingAddress: "",
      MailingAddressDisplay: true,
      principlebusiness: "",
      principlebusinessDisplay: true,
      Guarantor1Name: "",
      Guarantor1Address: "",
      guarantor1MarritalStatus: "",
      Guarantor1Residence: "",
      Guarantor1SpouseResidence: "",
      Guarantor1SpouseName: "",
      Guarantor1Display: true,
      Guarantor2Name: "",
      Guarantor2Address: "",
      guarantor2MarritalStatus: "",
      Guarantor2Residence: "",
      Guarantor2SpouseResidence: "",
      Guarantor2SpouseName: "",
      Guarantor2Display: true,
      Guarantor3Name: "",
      Guarantor3Address: "",
      guarantor3MarritalStatus: "",
      Guarantor3Residence: "",
      Guarantor3SpouseResidence: "",
      Guarantor3SpouseName: "",
      Guarantor3Display: true,
      Guarantor4Name: "",
      Guarantor4Address: "",
      guarantor4MarritalStatus: "",
      Guarantor4Residence: "",
      Guarantor4SpouseResidence: "",
      Guarantor4SpouseName: "",
      Guarantor4Display: true,
      Guarantor5Name: "",
      Guarantor5Address: "",
      guarantor5MarritalStatus: "",
      Guarantor5Residence: "",
      Guarantor5SpouseResidence: "",
      Guarantor5SpouseName: "",
      Guarantor5Display: true,
      PresidentName: "",
      SecretaryName: "",
      CFOName: "",
      VPName: "",
      Directors: "",
      BorrowerIsCorporationDisplay: true,
      MembersName: "",
      ManagersName: "",
      ManagingMemberName: "",
      BorrowerIsLLCDisplay: true,
      GeneralPartnerName: "",
      LimitedPartnerName: "",
      BorrowerIsPartnershipDisplay: true,
      Name1LoanDocuments: "",
      title1LoanDocuments: "",
      Name1LoanDocumentsDisplay: true,
      Name2LoanDocuments: "",
      title2LoanDocuments: "",
      Name2LoanDocumentsDisplay: true,
      Name3LoanDocuments: "",
      title3LoanDocuments: "",
      Name3LoanDocumentsDisplay: true,
      Name4LoanDocuments: "",
      title4LoanDocuments: "",
      Name4LoanDocumentsDisplay: true,
      Name5LoanDocuments: "",
      title5LoanDocuments: "",
      Name5LoanDocumentsDisplay: true,
      Loanterm: "",
      LoantermDisplay: true
    });

    if ($A.util.isUndefinedOrNull(component.get("v.record"))) {
      let queryString = this.compileQuery(component);

      console.log(queryString);

      component
        .find("util")
        .queryPromise(queryString)
        .then(
          $A.getCallback((response) => {
            let fullAddress = "";
            if (component.get("v.sObjectName") == "Opportunity") {
              let preRecord = response[0];
              let hasBorrowers = false;
              // preRecord.Deal_Contacts__r = [...preRecord.Deal_Contacts__r];
              if (
                preRecord.Deal_Contacts__r != null &&
                preRecord.Deal_Contacts__r.length > 0
              ) {
                hasBorrowers = preRecord.Deal_Contacts__r.some(
                  (dc) => dc.Entity_Type__c == "Borrower"
                );
                component.set(
                  "v.borrowerContact",
                  preRecord.Deal_Contacts__r.filter(
                    (dc) => dc.Entity_Type__c == "Borrower"
                  )[0]
                );
                preRecord.Deal_Contacts__r = preRecord.Deal_Contacts__r.filter(
                  (dc) => dc.Entity_Type__c == "Guarantor"
                );
              }

              let record = this.compileOpportuntiyData(component, preRecord);

              console.log(record);
              let dealEdit = component.get("v.dealEdit");
              if(record.Deal__r.LOC_Loan_Type__c.toLowerCase().includes("single asset")) {
                component.set("v.isSab", true);
                const propAdv = record.Property_Advances__r.filter(pa => pa.Property__r.Status__c != "Cancelled")[0];
                if(propAdv != null && propAdv.hasOwnProperty("Property__r")) {
                  const propRecord = propAdv.Property__r;
                  const addressString = `${propRecord.Name} ${propRecord.City__c}, ${propRecord.State__c} ${propRecord.ZipCode__c}`;
                  dealEdit.propertAddress = addressString;
                  dealEdit.initialAdvance = propRecord.Initial_Disbursement__c;
                  dealEdit.renovationAdvance = propRecord.Approved_Renovation_Holdback__c;
                  const recTypeName = propRecord.RecordType_Name__c.toLowerCase();
                  const propTypeMap = {
                    "bridge_no_renovation": "Non-Renovation",
                    "bridge_renovation": "Renovation",
                    "ground_up_construction": "Ground Up Construction"
                  }
                  if(propTypeMap.hasOwnProperty(recTypeName)) {
                    dealEdit.propType = propTypeMap[recTypeName];
                  }
                }
                dealEdit.nonSabFieldDisplay = false;
                dealEdit.renovationAdvanceLabel = "Maximum Aggregate Renovation Advance Amount";
                dealEdit.outsideAdvanceDateLabel = "Outside Completion Date";
                dealEdit.renovationPropertiesDisplay = false;
                dealEdit.renovationFundingDisplay = false;
                dealEdit.equityPledgeDisplay = false;
                dealEdit.sabFieldDisplay = true;
              } else {
                dealEdit.nonSabFieldDisplay = true;
                dealEdit.renovationAdvanceLabel = "Renovation Advance Amount";
                dealEdit.outsideAdvanceDateLabel = "Outside Advance Date";
                dealEdit.sabFieldDisplay = false;
              }
              dealEdit.sendEmail = record.Deal__r.Borrower_Entity__c != null;
              component.set("v.dealEdit", dealEdit);
              component.set("v.record", record);
              if (
                component.get("v.record.Deal__r.Borrower_Entity__c") != null ||
                hasBorrowers
              ) {
                component.set("v.hasBorrowerEntity", true);
              } else {
                component.set("v.hasBorrowerEntity", false);
              }
              //Set default data
              //Autopopulate emails from Underwriter__c, Loan_Coordinator__c, Gina.Lambis@cvest.com; Paul.Basmajian@cvest.com; michael.tran@cvest.com; jessica.lievanos@cvest.com in the cc field when User clicks on the Send Email button.
              let isSandbox = component.get("v.isSandbox");
              let emailsArray = [
                "Gina.Lambis@cvest.com",
                "Paul.Basmajian@cvest.com",
                "michael.tran@cvest.com",
                "jessica.lievanos@cvest.com"
              ];
              if (isSandbox) {
                emailsArray = emailsArray.map((e) => e + ".invalid");
              }
              if (
                component.get("v.record.Deal__r.Underwriter__r.Email") != null
              ) {
                emailsArray.push(
                  component.get("v.record.Deal__r.Underwriter__r.Email")
                );
              }
              if (
                component.get("v.record.Deal__r.Loan_Coordinator__r.Email") !=
                null
              ) {
                emailsArray.push(
                  component.get("v.record.Deal__r.Loan_Coordinator__r.Email")
                );
              }
              let ccEmails = "";
              ccEmails = emailsArray.join(";");
              component.set("v.ccAddress", ccEmails);
              component.set("v.bccAddress", component.get("v.User.Email"));
              component.set(
                "v.emailBody",
                "Hello,<br><br>Please see the attached intake form for " +
                  component.get("v.record.Deal__r.Name") +
                  ". " +
                  component.get("v.record.Deal__r.LOC_Loan_Type__c") +
                  "/" +
                  component.get("v.record.Deal__r.Product_Sub_Type__c") +
                  " loan of $" +
                  component.get("v.record.Deal__r.LOC_Commitment__c") +
                  ". Happy to discuss.<br><br>Thank you" +
                  "<br><br>" +
                  component.get("v.User.Name") +
                  " | " +
                  component.get("v.User.Title") +
                  " - " +
                  component.get("v.User.Department") +
                  "<br>Phone - " +
                  component.get("v.User.Phone") +
                  "<br>" +
                  component.get("v.User.Street") +
                  "<br>" +
                  component.get("v.User.City") +
                  ", " +
                  component.get("v.User.State") +
                  " " +
                  component.get("v.User.PostalCode") +
                  " CoreVest Finance | LinkedIn | Facebook | Twitter |Instagram"
              );
              if (component.get("v.record.Deal__r.Advance_Period__c") != null) {
                component.set(
                  "v.dealEdit.outsideAdvanceDate",
                  component.get("v.record.Deal__r.Advance_Period__c")
                );
              } else {
                component.set("v.dealEdit.outsideAdvanceDate", "0");
              }

              if (component.get("v.record.Deal__r.LOC_Commitment__c") == null) {
                component.set("v.loanAmount", "$0");
                component.set(
                  "v.subject",
                  "Loan Doc Request: " +
                    component.get("v.record.Deal__r.Name") +
                    " - Loan No: " +
                    component.get("v.record.Deal__r.Deal_Loan_Number__c") +
                    " - Loan Amount: $ " +
                    component.get("v.record.Deal__r.LOC_Commitment__c")
                );
              } else {
                let loanAmount = component.get(
                  "v.record.Deal__r.LOC_Commitment__c"
                );
                loanAmount = Number(loanAmount).toLocaleString(undefined, {
                  maximumFractionDigits: 2
                });
                loanAmount =
                  "$" +
                  String(loanAmount).replace(/\B(?=(\d{3})+(?!\d))/g, ",");
                component.set("v.loanAmount", loanAmount);
                component.set(
                  "v.subject",
                  "Loan Doc Request: " +
                    component.get("v.record.Deal__r.Name") +
                    " - Loan No: " +
                    component.get("v.record.Deal__r.Deal_Loan_Number__c") +
                    " - Loan Amount: $ " +
                    component.get("v.record.Deal__r.LOC_Commitment__c")
                );
              }

              if (
                component.get("v.record.Deal__r.Interest_Rate_Type__c") ==
                "Fixed"
              ) {
                component.set(
                  "v.record.Deal__r.Rate__c",
                  component.get("v.record.Deal__r.Rate__c") + "%"
                );
                component.set("v.dealEdit.FixedInterestTypeDisplay", true);
                component.set("v.dealEdit.FloatingInterestTypeDisplay", false);
              } else if (
                component.get("v.record.Deal__r.Interest_Rate_Type__c") ==
                "Floating"
              ) {
                component.set(
                  "v.record.Deal__r.Index_Margin__c",
                  component.get("v.record.Deal__r.Index_Margin__c") + "%"
                );
                component.set("v.dealEdit.FixedInterestTypeDisplay", false);
                component.set("v.dealEdit.FloatingInterestTypeDisplay", true);
              }

              //set Borrower Mailing Address
              if (
                component.get(
                  "v.record.Deal__r.Borrower_Entity__r.Address_1__c"
                ) != null
              ) {
                fullAddress +=
                  component.get(
                    "v.record.Deal__r.Borrower_Entity__r.Address_1__c"
                  ) + ", ";
              }
              if (
                component.get(
                  "v.record.Deal__r.Borrower_Entity__r.Address_2__c"
                ) != null
              ) {
                fullAddress +=
                  component.get(
                    "v.record.Deal__r.Borrower_Entity__r.Address_2__c"
                  ) + " ";
              }
              if (
                component.get("v.record.Deal__r.Borrower_Entity__r.City__c") !=
                null
              ) {
                fullAddress +=
                  component.get("v.record.Deal__r.Borrower_Entity__r.City__c") +
                  ", ";
              }
              if (
                component.get("v.record.Deal__r.Borrower_Entity__r.State__c") !=
                null
              ) {
                fullAddress +=
                  component.get(
                    "v.record.Deal__r.Borrower_Entity__r.State__c"
                  ) + " ";
              }
              if (
                component.get("v.record.Deal__r.Borrower_Entity__r.Zip__c") !=
                null
              ) {
                fullAddress += component.get(
                  "v.record.Deal__r.Borrower_Entity__r.Zip__c"
                );
              }
              component.set("v.dealEdit.MailingAddress", fullAddress.trimEnd());

              //set guarantors' info
              //MailingAddress.street, city, state, postalCode, country Guarantor1Address
              //Contact_Name__c Guarantor1Name Guarantor1Display
              if (component.get("v.record.Deal_Contacts__r").length > 0) {
                const guarantors = component.get("v.record.Deal_Contacts__r");
                const dealEdit = component.get("v.dealEdit");
                for (const [i, v] of guarantors.entries()) {
                  if (i > 4) {
                    break;
                  }
                  const contact = v.Deal_Contacts__r.Contact__r;
                  const addressKey = `Guarantor${i + 1}Address`;
                  const nameKey = `Guarantor${i + 1}Name`;
                  const displayKey = `Guarantor${i + 1}Display`;
                  let fullName = "";
                  if (v.Deal_Contacts__r.Contact__r.FirstName) {
                    fullName += v.Deal_Contacts__r.Contact__r.FirstName;
                  }
                  if (v.Deal_Contacts__r.Contact__r.MiddleName) {
                    fullName +=
                      " " + v.Deal_Contacts__r.Contact__r.MiddleName[0];
                  }
                  if (v.Deal_Contacts__r.Contact__r.LastName) {
                    fullName += " " + v.Deal_Contacts__r.Contact__r.LastName;
                  }
                  if (v.Deal_Contacts__r.Contact__r.Suffix) {
                    fullName += " " + v.Deal_Contacts__r.Contact__r.Suffix;
                  }
                  dealEdit[addressKey] =
                    (contact.MailingAddress.street &&
                      contact.MailingAddress.street + ", ") +
                    (contact.MailingAddress.city &&
                      contact.MailingAddress.city + ", ") +
                    (contact.MailingAddress.state &&
                      contact.MailingAddress.state + " ") +
                    (contact.MailingAddress.postalCode &&
                      contact.MailingAddress.postalCode + " ") +
                    (contact.MailingAddress.country &&
                      contact.MailingAddress.country);
                  dealEdit[nameKey] = fullName;
                  dealEdit[displayKey] = true;
                }
                component.set("v.dealEdit", dealEdit);
              }
            } else {
              component.set("v.record", response[0]);
              if (
                component.get("v.record.Deal__r.Borrower_Entity__c") != null
              ) {
                component.set("v.hasBorrowerEntity", true);
              } else {
                component.set("v.hasBorrowerEntity", false);
              }
              //Set default data
              component.set(
                "v.emailBody",
                "Hello,<br>Please see the attached intake form for " +
                  component.get("v.record.Deal__r.Name") +
                  ". " +
                  component.get("v.record.Deal__r.LOC_Loan_Type__c") +
                  "/" +
                  component.get("v.record.Deal__r.Product_Sub_Type__c") +
                  " loan of $" +
                  new Intl.NumberFormat("en-IN", {
                    maximumSignificantDigits: 2
                  }).format(
                    component.get("v.record.Deal__r.LOC_Commitment__c")
                  ) +
                  ". Happy to discuss.<br>Thank you"
              );
              if (component.get("v.record.Deal__r.LOC_Commitment__c") == null) {
                component.set("v.loanAmount", "$0");
                component.set(
                  "v.subject",
                  "Loan Doc Request: " +
                    component.get("v.record.Deal__r.Name") +
                    " - Loan No: " +
                    component.get("v.record.Deal__r.Deal_Loan_Number__c") +
                    " - Loan Amount: $ " +
                    component.get("v.record.Deal__r.LOC_Commitment__c")
                );
              } else {
                loanAmount = Number(loanAmount).toLocaleString(undefined, {
                  maximumFractionDigits: 2
                });
                loanAmount =
                  "$" +
                  String(loanAmount).replace(/\B(?=(\d{3})+(?!\d))/g, ",");
                component.set("v.loanAmount", loanAmount);
                component.set(
                  "v.subject",
                  "Loan Doc Request: " +
                    component.get("v.record.Deal__r.Name") +
                    " - Loan No: " +
                    component.get("v.record.Deal__r.Deal_Loan_Number__c") +
                    " - Loan Amount: $ " +
                    component.get("v.record.Deal__r.LOC_Commitment__c")
                );
              }

              if (component.get("v.record.Deal__r.Advance_Period__c") != null) {
                component.set(
                  "v.dealEdit.outsideAdvanceDate",
                  component.get("v.record.Deal__r.Advance_Period__c")
                );
              } else {
                component.set("v.dealEdit.outsideAdvanceDate", "0");
              }

              if (
                component.get("v.record.Deal__r.Interest_Rate_Type__c") ==
                "Fixed"
              ) {
                component.set(
                  "v.record.Deal__r.Rate__c",
                  component.get("v.record.Deal__r.Rate__c") + "%"
                );
                component.set("v.dealEdit.FixedInterestTypeDisplay", true);
                component.set("v.dealEdit.FloatingInterestTypeDisplay", false);
              } else if (
                component.get("v.record.Deal__r.Interest_Rate_Type__c") ==
                "Floating"
              ) {
                component.set(
                  "v.record.Deal__r.Index_Margin__c",
                  component.get("v.record.Deal__r.Index_Margin__c") + "%"
                );
                component.set("v.dealEdit.FixedInterestTypeDisplay", false);
                component.set("v.dealEdit.FloatingInterestTypeDisplay", true);
              }

              //set Borrower Mailing Address
              if (
                component.get(
                  "v.record.Deal__r.Borrower_Entity__r.Address_1__c"
                ) != null
              ) {
                fullAddress +=
                  component.get(
                    "v.record.Deal__r.Borrower_Entity__r.Address_1__c"
                  ) + ", ";
              }
              if (
                component.get(
                  "v.record.Deal__r.Borrower_Entity__r.Address_2__c"
                ) != null
              ) {
                fullAddress +=
                  component.get(
                    "v.record.Deal__r.Borrower_Entity__r.Address_2__c"
                  ) + " ";
              }
              if (
                component.get("v.record.Deal__r.Borrower_Entity__r.City__c") !=
                null
              ) {
                fullAddress +=
                  component.get("v.record.Deal__r.Borrower_Entity__r.City__c") +
                  ", ";
              }
              if (
                component.get("v.record.Deal__r.Borrower_Entity__r.State__c") !=
                null
              ) {
                fullAddress +=
                  component.get(
                    "v.record.Deal__r.Borrower_Entity__r.State__c"
                  ) + " ";
              }
              if (
                component.get("v.record.Deal__r.Borrower_Entity__r.Zip__c") !=
                null
              ) {
                fullAddress += component.get(
                  "v.record.Deal__r.Borrower_Entity__r.Zip__c"
                );
              }
              component.set("v.dealEdit.MailingAddress", fullAddress.trimEnd());

              //set guarantors' info
              //MailingAddress.street, city, state, postalCode, country Guarantor1Address
              //Contact_Name__c Guarantor1Name Guarantor1Display
              if (component.get("v.record.Deal_Contacts__r").length > 0) {
                const guarantors = component.get("v.record.Deal_Contacts__r");
                const dealEdit = component.get("v.dealEdit");
                for (const [i, v] of guarantors.entries()) {
                  if (i > 4) {
                    break;
                  }
                  const contact = v.Deal_Contacts__r.Contact__r;
                  const addressKey = `Guarantor${i + 1}Address`;
                  const nameKey = `Guarantor${i + 1}Name`;
                  const displayKey = `Guarantor${i + 1}Display`;
                  let fullName = "";
                  if (v.Deal_Contacts__r.Contact__r.FirstName) {
                    fullName += v.Deal_Contacts__r.Contact__r.FirstName;
                  }
                  if (v.Deal_Contacts__r.Contact__r.MiddleName) {
                    fullName +=
                      " " + v.Deal_Contacts__r.Contact__r.MiddleName[0];
                  }
                  if (v.Deal_Contacts__r.Contact__r.LastName) {
                    fullName += " " + v.Deal_Contacts__r.Contact__r.LastName;
                  }
                  if (v.Deal_Contacts__r.Contact__r.Suffix) {
                    fullName += " " + v.Deal_Contacts__r.Contact__r.Suffix;
                  }
                  dealEdit[addressKey] =
                    (contact.MailingAddress.street &&
                      contact.MailingAddress.street + ", ") +
                    (contact.MailingAddress.city &&
                      contact.MailingAddress.city + ", ") +
                    (contact.MailingAddress.state &&
                      contact.MailingAddress.state + " ") +
                    (contact.MailingAddress.postalCode &&
                      contact.MailingAddress.postalCode + " ") +
                    (contact.MailingAddress.country &&
                      contact.MailingAddress.country);
                  dealEdit[nameKey] = fullName;
                  dealEdit[displayKey] = true;
                }
                component.set("v.dealEdit", dealEdit);
              }
            }
          })
        );
    }
  },
  fields: [
    "Id",
    "Name",
    "Title",
    "Approved_Advance_Amount_Total__c",
    "(SELECT Id, Approved_Advance_Amount__c, Initial_Disbursement__c, Renovation_Reserve__c, Property__r.Name, Property__r.APN__c, Property__r.County__c, Property__r.Escrow_Company_text__c, Property__r.Escrow_Agent__r.Name, Property__r.Escrow_Agent__r.BillingStreet, Property__r.Escrow_Agent__r.BillingCity, Property__r.Escrow_Agent__r.BillingState, Property__r.Escrow_Agent__r.BillingPostalCode, Property__r.Escrow_Contact_Name__c, Property__r.Title_Company__r.Name, Property__r.Title_Company__r.BillingStreet, Property__r.Title_Company__r.BillingCity, Property__r.Title_Company__r.BillingState, Property__r.Title_Company__r.BillingPostalCode, Property__r.Title_Company__r.Phone, Property__r.Title_Contact_Name__c, Net_Funding__c, Property__r.Requested_Funding_Date__c, Property__r.Acquisition_Price__c, Property__r.City__c, Property__r.State__c, Property__r.ZipCode__c, Property__r.Asset_Maturity_Date__c, Property__r.Renovation_Type_formula__c FROM Property_Advances__r)",
    "Deal__r.Name",
    "Deal__r.Revolving1__c",
    "Deal__r.Advance_Period_Days_In_Months__c",
    "Deal__r.Asset_Maturity__c",
    "Deal__r.LTV__c",
    "Deal__r.LTC__c",
    "Deal__r.Total_ARV_LTV__c",
    "Deal__r.Renovation_Limit__c",
    "Deal__r.Total_Loan_LTC__c",
    "Deal__r.Recourse__c",
    "Deal__r.Loan_Effective_Date__c",
    "Deal__r.Deal_Loan_Number__c",
    "Deal__r.LOC_Commitment__c",
    "Deal__r.Aggregate_Funding__c",
    "Deal__r.Account.Name",
    "Deal__r.Account.BillingStreet",
    "Deal__r.Account.BillingCity",
    "Deal__r.Account.BillingState",
    "Deal__r.Account.Billing_State_Code__c",
    "Deal__r.Account.BillingPostalCode",
    "Deal__r.Account.Phone",
    "Deal__r.Advance_Period__c",
    "Deal__r.Maturity_Date_Calculation_Type__c"
  ],

  opportunityFields: [
    "Id",
    "Name",
    "Loan_Effective_Date__c",
    "Deal_Loan_Number__c",
    "LOC_Commitment__c",
    "LOC_Loan_Type__c",
    "Product_Sub_Type__c",
    "LOC_Term__c",
    "Exit_Fee__c",
    "LTV__c",
    "LTC__c",
    "Total_ARV_LTV__c",
    "Renovation_Limit__c",
    "Recourse__c",
    "Total_Loan_LTC__c",
    "Revolving1__c",
    "Advance_Period_Days_In_Months__c",
    "Active_States__c",
    "Aggregate_Funding__c",
    "Account.Name",
    "Account.BillingStreet",
    "Account.BillingCity",
    "Account.BillingState",
    "Account.Billing_State_Code__c",
    "Account.BillingPostalCode",
    "Account.Phone",
    "Account.Company_Domicile__c",
    "Account.Entity_Formation_Date__c",
    "Account.Operating_Agreement_Date__c",
    "Advance_Period__c",
    "Authorized_Signor__c",
    "Signor_Capacity__c",
    "CloseDate",
    "Referral_Source__r.Name",
    "Broker_Fees__c",
    "Rate__c",
    "CAF_Upfront_Fee__c",
    "Asset_Maturity__c",
    "Interest_Rate_In_Words__c",
    "Origination_Fee_In_Words__c",
    "Broker_Fees_In_Words__c",
    "Document_Date__c",
    "First_Payment_Date1__c",
    "Requested_Advance_Date__c",
    "Fee__c",
    "Reno_Funding_Type__c",
    "Index_Floor__c",
    "Index__c",
    "Index_Margin__c",
    "Interest_Rate_Type__c",
    "Underwriter__c",
    "Underwriter__r.Email",
    "Loan_Coordinator__r.Email",
    "Loan_Coordinator__c",
    "Maturity_Date_Calculation_Type__c",
    "Borrower_Entity__c",
    "Borrower_Entity__r.Name",
    "Borrower_Entity__r.Company_Jurisdiction__c",
    "Borrower_Entity__r.Date_of_Cert_of_Good_Standing__c",
    "Borrower_Entity__r.Entity_Filing_Date__c",
    "Borrower_Entity__r.Operating_Agreement_Date__c",
    "Borrower_Entity__r.Business_Tax_ID_EIN__c",
    "Borrower_Entity__r.Entity_Type__c",
    "Borrower_Entity__r.Entity_Number__c",
    "Borrower_Entity__r.Address_1__c",
    "Borrower_Entity__r.Address_2__c",
    "Borrower_Entity__r.City__c",
    "Borrower_Entity__r.State__c",
    "Borrower_Entity__r.Zip__c"
  ],

  dealContactFields: [
    "Id",
    "Contact__r.FirstName",
    "Contact__r.MiddleName",
    "Contact__r.LastName",
    "Contact__r.Suffix",
    "Contact__r.MailingState",
    "Entity_Type__c",
    "Contact__r.MailingAddress",
    "CreatedDate",
    "Company_Jurisdiction__c"
  ],

  propertyFields: [
    "Approved_Renovation_Holdback__c",
    "Approved_Advance_Amount__c",
    "Initial_Disbursement_Remaining__c",
    "Reno_Advance_Amount__c",
    "Initial_Disbursement__c",
    //"Net_Funding__c",
    "Id",
    "Name",
    "APN__c",
    "County__c",
    "Escrow_Company_text__c",
    "Escrow_Agent__r.Name",
    "Escrow_Agent__r.BillingStreet",
    "Escrow_Agent__r.BillingCity",
    "Escrow_Agent__r.BillingState",
    "Escrow_Agent__r.BillingPostalCode",
    "Escrow_Contact_Name__c",
    "Title_Company__r.Name",
    "Title_Company__r.BillingStreet",
    "Title_Company__r.BillingCity",
    "Title_Company__r.BillingState",
    "Title_Company__r.BillingPostalCode",
    "Title_Company__r.Phone",
    "Title_Contact_Name__c",
    "Requested_Funding_Date__c",
    //  "Purchase_Price__c",
    "Acquisition_Price__c",
    "City__c",
    "State__c",
    "ZipCode__c",
    "Asset_Maturity_Date__c",
    "Renovation_Type_formula__c",
    "Status__c",
    "RecordType_Name__c"
  ],

  compileQuery: function (component) {
    return component.get("v.sObjectName") == "Advance__c"
      ? this.compileAdvanceQuery(component)
      : this.compileOpportunityQuery(component);
  },

  compileOpportunityQuery: function (component) {
    let recordId = component.get("v.recordId");
    let queryString = "SELECT ";

    for (let field of this.opportunityFields) {
      queryString += `${field},`;
    }

    queryString += " (SELECT ";
    for (let field of this.propertyFields) {
      queryString += `${field},`;
    }

    queryString = queryString.substr(0, queryString.lastIndexOf(","));
    queryString += " FROM Properties__r ";

    let propertyIds = component.get("v.propertyIds");
    if (!$A.util.isEmpty(propertyIds)) {
      //do stuff here
      queryString += "WHERE Id IN " + propertyIds;

      // console.log("--propertyIds--");
      // console.log(propertyIds);
    }

    queryString += " ), ";

    queryString += " (SELECT ";
    for (let field of this.dealContactFields) {
      queryString += `${field},`;
    }
    queryString = queryString.substr(0, queryString.lastIndexOf(","));
    queryString +=
      " FROM Deal_Contacts__r where Entity_Type__c IN ('Guarantor','Borrower') ORDER BY CreatedDate";
    queryString += " ) ";

    queryString += ` FROM Opportunity WHERE Id = '${recordId}'`;

    console.log("compileOpportunityQuery--> " + queryString);

    return queryString;
  },

  compileOpportuntiyData: function (component, deal) {
    //console.log(deal);
    let advance = {
      Deal__r: {},
      dealEdit: {}
    };
    let properties = [];
    let dealContacts = [];

    this.opportunityFields.forEach((field) => {
      //console.log(field);

      if (field.includes(".")) {
        let fields = field.split(".");

        if (deal.hasOwnProperty(fields[0])) {
          if (!advance["Deal__r"].hasOwnProperty(fields[0])) {
            advance["Deal__r"][fields[0]] = {};
          }

          if (deal[fields[0]].hasOwnProperty(fields[1])) {
            advance["Deal__r"][fields[0]][fields[1]] =
              deal[fields[0]][fields[1]];
          }
        }
      } else if (!$A.util.isEmpty(deal[field])) {
        advance["Deal__r"][field] = deal[field];
      }
    });
    /*
    deal.Deal_Contacts__r && deal.Deal_Contacts__r.forEach(sponsor => {
      advance["Deal__r"]["guarantor"] = sponsor;
    });
    */
    deal.Deal_Contacts__r &&
      deal.Deal_Contacts__r.forEach((property) => {
        let propAdvance = {
          Deal_Contacts__r: {}
        };

        this.dealContactFields.forEach((field) => {
          if (field.includes(".")) {
            let fields = field.split(".");

            if (property.hasOwnProperty(fields[0])) {
              if (!propAdvance["Deal_Contacts__r"].hasOwnProperty(fields[0])) {
                propAdvance["Deal_Contacts__r"][fields[0]] = {};
              }

              if (property[fields[0]].hasOwnProperty(fields[1])) {
                propAdvance["Deal_Contacts__r"][fields[0]][fields[1]] =
                  property[fields[0]][fields[1]];
              }
            }
          } else {
            propAdvance["Deal_Contacts__r"][field] = property[field];
          }
        });

        dealContacts.push(propAdvance);
      });

    advance["Deal_Contacts__r"] = dealContacts;
    //

    deal.Properties__r &&
      deal.Properties__r.forEach((property) => {
        let propAdvance = {
          Property__r: {}
        };

        propAdvance["Approved_Advance_Amount__c"] =
          property["Approved_Advance_Amount__c"];
        propAdvance["Initial_Disbursement__c"] =
          property["Initial_Disbursement_Remaining__c"];
        propAdvance["Renovation_Reserve__c"] =
          property["Reno_Advance_Amount__c"];

        this.propertyFields.forEach((field) => {
          if (field.includes(".")) {
            let fields = field.split(".");

            if (property.hasOwnProperty(fields[0])) {
              if (!propAdvance["Property__r"].hasOwnProperty(fields[0])) {
                propAdvance["Property__r"][fields[0]] = {};
              }

              if (property[fields[0]].hasOwnProperty(fields[1])) {
                propAdvance["Property__r"][fields[0]][fields[1]] =
                  property[fields[0]][fields[1]];
              }
            }
          } else {
            propAdvance["Property__r"][field] = property[field];
          }
        });

        properties.push(propAdvance);
      });
    console.log("properties---> " + JSON.stringify(properties));
    advance["Property_Advances__r"] = properties;

    //New changes added by TriVikram for editable fields in Bridge Intake
    var dealEditData = component.get("v.dealEdit"); //this.updateDealRecordData(component);;
    advance["dealEdit"] = dealEditData;

    return advance;
  },

  compileAdvanceQuery: function (component) {
    let queryString = "SELECT ";

    for (let field of this.fields) {
      queryString += `${field},`;
    }

    queryString = queryString.substr(0, queryString.lastIndexOf(","));
    let recordId = component.get("v.recordId");
    queryString += ` FROM Advance__c WHERE Id = '${recordId}'`;

    return queryString;
  },

  generateDocx: function (component, docName) {
    if ($A.util.isUndefinedOrNull(component.get("v.record"))) {
      let queryString = this.compileQuery(component);

      console.log(queryString);

      component
        .find("util")
        .queryPromise(queryString)
        .then(
          $A.getCallback((response) => {
            if (component.get("v.sObjectName") == "Opportunity") {
              let preRecord = response[0];
              if (
                preRecord.Deal_Contacts__r != null &&
                preRecord.Deal_Contacts__r.length > 0
              ) {
                preRecord.Deal_Contacts__r = preRecord.Deal_Contacts__r.filter(
                  (dc) => {
                    dc.Entity_Type__c == "Guarantor";
                  }
                );
              }
              let record = this.compileOpportuntiyData(component, preRecord);

              console.log("Record Data for document---> " + record);

              component.set("v.record", record);
            } else {
              component.set("v.record", response[0]);
            }

            component
              .find("generator")
              .generateDocx(component.get("v.record"), docName);
          })
        );
    } else {
      component
        .find("generator")
        .generateDocx(component.get("v.record"), docName);
    }
  },
  /*
    updateDealRecordData: function(component) {
        var dealEdit = component.get("v.dealEdit")
        dealEdit.propertAddress = ($A.util.isEmpty(dealEdit.propertAddress) || $A.util.isUndefined(dealEdit.propertAddress) ? 'N/A' : dealEdit.propertAddress);
        dealEdit.initialAdvance = ($A.util.isEmpty(dealEdit.initialAdvance) || $A.util.isUndefined(dealEdit.initialAdvance) ? 'N/A' : dealEdit.initialAdvance);
        dealEdit.renovationAdvance = ($A.util.isEmpty(dealEdit.renovationAdvance) || $A.util.isUndefined(dealEdit.renovationAdvance) ? 'N/A' : dealEdit.renovationAdvance);
        dealEdit.intersetRate = ($A.util.isEmpty(dealEdit.intersetRate) || $A.util.isUndefined(dealEdit.intersetRate) ? 'N/A' : dealEdit.intersetRate);
        dealEdit.index = ($A.util.isEmpty(dealEdit.index) || $A.util.isUndefined(dealEdit.index) ? 'N/A' : dealEdit.index);
        dealEdit.indexMargin = ($A.util.isEmpty(dealEdit.indexMargin) || $A.util.isUndefined(dealEdit.indexMargin) ? 'N/A' : dealEdit.indexMargin);
        dealEdit.indexFloor = ($A.util.isEmpty(dealEdit.indexFloor) || $A.util.isUndefined(dealEdit.indexFloor) ? 'N/A' : dealEdit.indexFloor);
        dealEdit.extenionOption = ($A.util.isEmpty(dealEdit.extenionOption) || $A.util.isUndefined(dealEdit.extenionOption) ? 'N/A' : dealEdit.extenionOption);
        dealEdit.outsideAdvanceDate = ($A.util.isEmpty(dealEdit.outsideAdvanceDate) || $A.util.isUndefined(dealEdit.outsideAdvanceDate) ? 'N/A' : dealEdit.outsideAdvanceDate);
        //  dealEdit.underwritingFee=($A.util.isEmpty(dealEdit.underwritingFee) || $A.util.isUndefined(dealEdit.underwritingFee) ? 'N/A' : dealEdit.underwritingFee );
        dealEdit.renovationProperties = ($A.util.isEmpty(dealEdit.renovationProperties) || $A.util.isUndefined(dealEdit.renovationProperties) ? 'N/A' : dealEdit.renovationProperties);
        dealEdit.renovationFunding = ($A.util.isEmpty(dealEdit.renovationFunding) || $A.util.isUndefined(dealEdit.renovationFunding) ? 'N/A' : dealEdit.renovationFunding);
        dealEdit.equityPledge = ($A.util.isEmpty(dealEdit.equityPledge) || $A.util.isUndefined(dealEdit.equityPledge) ? 'N/A' : dealEdit.equityPledge);
        dealEdit.principlebusiness = ($A.util.isEmpty(dealEdit.principlebusiness) || $A.util.isUndefined(dealEdit.principlebusiness) ? 'N/A' : dealEdit.principlebusiness);
        dealEdit.MailingAddress = ($A.util.isEmpty(dealEdit.MailingAddress) || $A.util.isUndefined(dealEdit.MailingAddress) ? 'N/A' : dealEdit.MailingAddress);
        dealEdit.Guarantor1Name = ($A.util.isEmpty(dealEdit.Guarantor1Name) || $A.util.isUndefined(dealEdit.Guarantor1Name) ? 'N/A' : dealEdit.Guarantor1Name);
        dealEdit.Guarantor1Address = ($A.util.isEmpty(dealEdit.Guarantor1Address) || $A.util.isUndefined(dealEdit.Guarantor1Address) ? 'N/A' : dealEdit.Guarantor1Address);
        dealEdit.guarantor1MarritalStatus = ($A.util.isEmpty(dealEdit.guarantor1MarritalStatus) || $A.util.isUndefined(dealEdit.guarantor1MarritalStatus) ? 'N/A' : dealEdit.guarantor1MarritalStatus);
        dealEdit.Guarantor1Residence = ($A.util.isEmpty(dealEdit.Guarantor1Residence) || $A.util.isUndefined(dealEdit.Guarantor1Residence) ? 'N/A' : dealEdit.Guarantor1Residence);
        dealEdit.Guarantor1SpouseResidence = ($A.util.isEmpty(dealEdit.Guarantor1SpouseResidence) || $A.util.isUndefined(dealEdit.Guarantor1SpouseResidence) ? 'N/A' : dealEdit.Guarantor1SpouseResidence);
        dealEdit.Guarantor1SpouseName = ($A.util.isEmpty(dealEdit.Guarantor1SpouseName) || $A.util.isUndefined(dealEdit.Guarantor1SpouseName) ? 'N/A' : dealEdit.Guarantor1SpouseName);
        dealEdit.Guarantor2Name = ($A.util.isEmpty(dealEdit.Guarantor2Name) || $A.util.isUndefined(dealEdit.Guarantor2Name) ? 'N/A' : dealEdit.Guarantor2Name);
        dealEdit.Guarantor2Address = ($A.util.isEmpty(dealEdit.Guarantor2Address) || $A.util.isUndefined(dealEdit.Guarantor2Address) ? 'N/A' : dealEdit.Guarantor2Address);
        dealEdit.guarantor2MarritalStatus = ($A.util.isEmpty(dealEdit.guarantor2MarritalStatus) || $A.util.isUndefined(dealEdit.guarantor2MarritalStatus) ? 'N/A' : dealEdit.guarantor2MarritalStatus);
        dealEdit.Guarantor2Residence = ($A.util.isEmpty(dealEdit.Guarantor2Residence) || $A.util.isUndefined(dealEdit.Guarantor2Residence) ? 'N/A' : dealEdit.Guarantor2Residence);
        dealEdit.Guarantor2SpouseResidence = ($A.util.isEmpty(dealEdit.Guarantor2SpouseResidence) || $A.util.isUndefined(dealEdit.Guarantor2SpouseResidence) ? 'N/A' : dealEdit.Guarantor2SpouseResidence);
        dealEdit.Guarantor2SpouseName = ($A.util.isEmpty(dealEdit.Guarantor2SpouseName) || $A.util.isUndefined(dealEdit.Guarantor2SpouseName) ? 'N/A' : dealEdit.Guarantor2SpouseName);
        dealEdit.Guarantor3Name = ($A.util.isEmpty(dealEdit.Guarantor3Name) || $A.util.isUndefined(dealEdit.Guarantor3Name) ? 'N/A' : dealEdit.Guarantor3Name);
        dealEdit.Guarantor3Address = ($A.util.isEmpty(dealEdit.Guarantor3Address) || $A.util.isUndefined(dealEdit.Guarantor3Address) ? 'N/A' : dealEdit.Guarantor3Address);
        dealEdit.guarantor3MarritalStatus = ($A.util.isEmpty(dealEdit.guarantor3MarritalStatus) || $A.util.isUndefined(dealEdit.guarantor3MarritalStatus) ? 'N/A' : dealEdit.guarantor3MarritalStatus);
        dealEdit.Guarantor3Residence = ($A.util.isEmpty(dealEdit.Guarantor3Residence) || $A.util.isUndefined(dealEdit.Guarantor3Residence) ? 'N/A' : dealEdit.Guarantor3Residence);
        dealEdit.Guarantor3SpouseResidence = ($A.util.isEmpty(dealEdit.Guarantor3SpouseResidence) || $A.util.isUndefined(dealEdit.Guarantor3SpouseResidence) ? 'N/A' : dealEdit.Guarantor3SpouseResidence);
        dealEdit.Guarantor3SpouseName = ($A.util.isEmpty(dealEdit.Guarantor3SpouseName) || $A.util.isUndefined(dealEdit.Guarantor3SpouseName) ? 'N/A' : dealEdit.Guarantor3SpouseName);
        dealEdit.Guarantor4Name = ($A.util.isEmpty(dealEdit.Guarantor4Name) || $A.util.isUndefined(dealEdit.Guarantor4Name) ? 'N/A' : dealEdit.Guarantor4Name);
        dealEdit.Guarantor4Address = ($A.util.isEmpty(dealEdit.Guarantor4Address) || $A.util.isUndefined(dealEdit.Guarantor4Address) ? 'N/A' : dealEdit.Guarantor4Address);
        dealEdit.guarantor4MarritalStatus = ($A.util.isEmpty(dealEdit.guarantor4MarritalStatus) || $A.util.isUndefined(dealEdit.guarantor4MarritalStatus) ? 'N/A' : dealEdit.guarantor4MarritalStatus);
        dealEdit.Guarantor4Residence = ($A.util.isEmpty(dealEdit.Guarantor4Residence) || $A.util.isUndefined(dealEdit.Guarantor4Residence) ? 'N/A' : dealEdit.Guarantor4Residence);
        dealEdit.Guarantor4SpouseResidence = ($A.util.isEmpty(dealEdit.Guarantor4SpouseResidence) || $A.util.isUndefined(dealEdit.Guarantor4SpouseResidence) ? 'N/A' : dealEdit.Guarantor4SpouseResidence);
        dealEdit.Guarantor4SpouseName = ($A.util.isEmpty(dealEdit.Guarantor4SpouseName) || $A.util.isUndefined(dealEdit.Guarantor4SpouseName) ? 'N/A' : dealEdit.Guarantor4SpouseName);
        dealEdit.Guarantor5Name = ($A.util.isEmpty(dealEdit.Guarantor5Name) || $A.util.isUndefined(dealEdit.Guarantor5Name) ? 'N/A' : dealEdit.Guarantor5Name);
        dealEdit.Guarantor5Address = ($A.util.isEmpty(dealEdit.Guarantor5Address) || $A.util.isUndefined(dealEdit.Guarantor5Address) ? 'N/A' : dealEdit.Guarantor5Address);
        dealEdit.guarantor5MarritalStatus = ($A.util.isEmpty(dealEdit.guarantor5MarritalStatus) || $A.util.isUndefined(dealEdit.guarantor5MarritalStatus) ? 'N/A' : dealEdit.guarantor5MarritalStatus);
        dealEdit.Guarantor5Residence = ($A.util.isEmpty(dealEdit.Guarantor5Residence) || $A.util.isUndefined(dealEdit.Guarantor5Residence) ? 'N/A' : dealEdit.Guarantor5Residence);
        dealEdit.Guarantor5SpouseResidence = ($A.util.isEmpty(dealEdit.Guarantor5SpouseResidence) || $A.util.isUndefined(dealEdit.Guarantor5SpouseResidence) ? 'N/A' : dealEdit.Guarantor5SpouseResidence);
        dealEdit.Guarantor5SpouseName = ($A.util.isEmpty(dealEdit.Guarantor5SpouseName) || $A.util.isUndefined(dealEdit.Guarantor5SpouseName) ? 'N/A' : dealEdit.Guarantor5SpouseName);
        dealEdit.BorrowerName = ($A.util.isEmpty(dealEdit.BorrowerName) || $A.util.isUndefined(dealEdit.BorrowerName) ? ' ' : dealEdit.BorrowerName);
        dealEdit.PresidentName = ($A.util.isEmpty(dealEdit.PresidentName) || $A.util.isUndefined(dealEdit.PresidentName) ? 'N/A' : dealEdit.PresidentName);
        dealEdit.SecretaryName = ($A.util.isEmpty(dealEdit.SecretaryName) || $A.util.isUndefined(dealEdit.SecretaryName) ? 'N/A' : dealEdit.SecretaryName);
        dealEdit.CFOName = ($A.util.isEmpty(dealEdit.CFOName) || $A.util.isUndefined(dealEdit.CFOName) ? 'N/A' : dealEdit.CFOName);
        dealEdit.VPName = ($A.util.isEmpty(dealEdit.VPName) || $A.util.isUndefined(dealEdit.VPName) ? 'N/A' : dealEdit.VPName);
        dealEdit.Directors = ($A.util.isEmpty(dealEdit.Directors) || $A.util.isUndefined(dealEdit.Directors) ? 'N/A' : dealEdit.Directors);
        dealEdit.BorrowerLLCName = ($A.util.isEmpty(dealEdit.BorrowerLLCName) || $A.util.isUndefined(dealEdit.BorrowerLLCName) ? ' ' : dealEdit.BorrowerLLCName);
        dealEdit.MembersName = ($A.util.isEmpty(dealEdit.MembersName) || $A.util.isUndefined(dealEdit.MembersName) ? 'N/A' : dealEdit.MembersName);
        dealEdit.ManagersName = ($A.util.isEmpty(dealEdit.ManagersName) || $A.util.isUndefined(dealEdit.ManagersName) ? 'N/A' : dealEdit.ManagersName);
        dealEdit.ManagingMemberName = ($A.util.isEmpty(dealEdit.ManagingMemberName) || $A.util.isUndefined(dealEdit.ManagingMemberName) ? 'N/A' : dealEdit.ManagingMemberName);
        dealEdit.BorrowerPartnershipName = ($A.util.isEmpty(dealEdit.BorrowerPartnershipName) || $A.util.isUndefined(dealEdit.BorrowerPartnershipName) ? ' ' : dealEdit.BorrowerPartnershipName);
        dealEdit.GeneralPartnerName = ($A.util.isEmpty(dealEdit.GeneralPartnerName) || $A.util.isUndefined(dealEdit.GeneralPartnerName) ? 'N/A' : dealEdit.GeneralPartnerName);
        dealEdit.LimitedPartnerName = ($A.util.isEmpty(dealEdit.LimitedPartnerName) || $A.util.isUndefined(dealEdit.LimitedPartnerName) ? 'N/A' : dealEdit.LimitedPartnerName);
        dealEdit.LoanDocuments = ($A.util.isEmpty(dealEdit.LoanDocuments) || $A.util.isUndefined(dealEdit.LoanDocuments) ? ' ' : dealEdit.LoanDocuments);
        dealEdit.Name1LoanDocuments = ($A.util.isEmpty(dealEdit.Name1LoanDocuments) || $A.util.isUndefined(dealEdit.Name1LoanDocuments) ? 'N/A' : dealEdit.Name1LoanDocuments);
        dealEdit.title1LoanDocuments = ($A.util.isEmpty(dealEdit.title1LoanDocuments) || $A.util.isUndefined(dealEdit.title1LoanDocuments) ? 'N/A' : dealEdit.title1LoanDocuments);
        dealEdit.Name2LoanDocuments = ($A.util.isEmpty(dealEdit.Name2LoanDocuments) || $A.util.isUndefined(dealEdit.Name2LoanDocuments) ? 'N/A' : dealEdit.Name2LoanDocuments);
        dealEdit.title2LoanDocuments = ($A.util.isEmpty(dealEdit.title2LoanDocuments) || $A.util.isUndefined(dealEdit.title2LoanDocuments) ? 'N/A' : dealEdit.title2LoanDocuments);
        dealEdit.Name3LoanDocuments = ($A.util.isEmpty(dealEdit.Name3LoanDocuments) || $A.util.isUndefined(dealEdit.Name3LoanDocuments) ? 'N/A' : dealEdit.Name3LoanDocuments);
        dealEdit.title3LoanDocuments = ($A.util.isEmpty(dealEdit.title3LoanDocuments) || $A.util.isUndefined(dealEdit.title3LoanDocuments) ? 'N/A' : dealEdit.title3LoanDocuments);
        dealEdit.Name4LoanDocuments = ($A.util.isEmpty(dealEdit.Name4LoanDocuments) || $A.util.isUndefined(dealEdit.Name4LoanDocuments) ? 'N/A' : dealEdit.Name4LoanDocuments);
        dealEdit.title4LoanDocuments = ($A.util.isEmpty(dealEdit.title4LoanDocuments) || $A.util.isUndefined(dealEdit.title4LoanDocuments) ? 'N/A' : dealEdit.title4LoanDocuments);
        dealEdit.Name5LoanDocuments = ($A.util.isEmpty(dealEdit.Name5LoanDocuments) || $A.util.isUndefined(dealEdit.Name5LoanDocuments) ? 'N/A' : dealEdit.Name5LoanDocuments);
        dealEdit.title5LoanDocuments = ($A.util.isEmpty(dealEdit.title5LoanDocuments) || $A.util.isUndefined(dealEdit.title5LoanDocuments) ? 'N/A' : dealEdit.title5LoanDocuments);


        dealEdit.Loanterm = ($A.util.isEmpty(dealEdit.Loanterm) || $A.util.isUndefined(dealEdit.Loanterm) ? 'N/A' : dealEdit.Loanterm);

        return dealEdit;
    },*/
  removeAttchedFile: function (component, event, helper, index) {
    var fileIds = component.get("v.fileIds");
    var fileIdsDelete = [];
    if ($A.util.isUndefinedOrNull(index)) {
      fileIds.forEach(function (item) {
        fileIdsDelete.push(item.documentId);
      });
    } else {
      var selectedFile = fileIds[index];
      fileIdsDelete.push(selectedFile.documentId);
    }

    var action = component.get("c.deleteFile");
    action.setParams({
      fileIds: fileIdsDelete
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (component.isValid() && state == "SUCCESS") {
        if ($A.util.isUndefinedOrNull(index)) {
          component.set("v.fileIds", []);
          component.set("v.hasBorrowerEntity", false);
        } else {
          fileIds.splice(index, 1);
          component.set("v.fileIds", fileIds);
        }
      } else {
        console.log("Error=", response.getError());
      }
    });
    $A.enqueueAction(action);
  },
  handleDeleteItem: function (cmp, event) {
    switch (event.target.id) {
      case "propertAddress":
        cmp.set("v.dealEdit.propertAddressDisplay", false);
        break;
      case "initialAdvance":
        cmp.set("v.dealEdit.initialAdvanceDisplay", false);
        break;
      case "renovationAdvance":
        cmp.set("v.dealEdit.renovationAdvanceDisplay", false);
        break;
      case "extenionOption":
        cmp.set("v.dealEdit.extenionOptionDisplay", false);
        break;
      case "outsideAdvanceDate":
        cmp.set("v.dealEdit.outsideAdvanceDateDisplay", false);
        break;
      case "renovationProperties":
        cmp.set("v.dealEdit.renovationPropertiesDisplay", false);
        break;
      case "renovationFunding":
        cmp.set("v.dealEdit.renovationFundingDisplay", false);
        break;
      case "equityPledge":
        cmp.set("v.dealEdit.equityPledgeDisplay", false);
        break;
      case "MailingAddress":
        cmp.set("v.dealEdit.MailingAddressDisplay", false);
        break;
      case "principlebusiness":
        cmp.set("v.dealEdit.principlebusinessDisplay", false);
        break;
      case "Guarantor1":
        cmp.set("v.dealEdit.Guarantor1Display", false);
        break;
      case "Guarantor2":
        cmp.set("v.dealEdit.Guarantor2Display", false);
        break;
      case "Guarantor3":
        cmp.set("v.dealEdit.Guarantor3Display", false);
        break;
      case "Guarantor4":
        cmp.set("v.dealEdit.Guarantor4Display", false);
        break;
      case "Guarantor5":
        cmp.set("v.dealEdit.Guarantor5Display", false);
        break;
      case "BorrowerIsCorporation":
        cmp.set("v.dealEdit.BorrowerIsCorporationDisplay", false);
        break;
      case "BorrowerIsLLC":
        cmp.set("v.dealEdit.BorrowerIsLLCDisplay", false);
        break;
      case "BorrowerIsPartnership":
        cmp.set("v.dealEdit.BorrowerIsPartnershipDisplay", false);
        break;
      case "Name1LoanDocuments":
        cmp.set("v.dealEdit.Name1LoanDocumentsDisplay", false);
        break;
      case "Name2LoanDocuments":
        cmp.set("v.dealEdit.Name2LoanDocumentsDisplay", false);
        break;
      case "Name3LoanDocuments":
        cmp.set("v.dealEdit.Name3LoanDocumentsDisplay", false);
        break;
      case "Name4LoanDocuments":
        cmp.set("v.dealEdit.Name4LoanDocumentsDisplay", false);
        break;
      case "Name5LoanDocuments":
        cmp.set("v.dealEdit.Name5LoanDocumentsDisplay", false);
        break;
      case "Loanterm":
        cmp.set("v.dealEdit.LoantermDisplay", false);
        break;
    }
  },
  handleChangeInterestRateType: function (component, event, helper) {
    if (component.get("v.record.Deal__r.Interest_Rate_Type__c") == "Fixed") {
      //component.set("v.record.Deal__r.Rate__c", component.get("v.record.Deal__r.Rate__c") + '%');
      component.set("v.dealEdit.FixedInterestTypeDisplay", true);
      component.set("v.dealEdit.FloatingInterestTypeDisplay", false);
    } else if (
      component.get("v.record.Deal__r.Interest_Rate_Type__c") == "Floating"
    ) {
      //component.set("v.record.Deal__r.Index_Margin__c", component.get("v.record.Deal__r.Index_Margin__c") + '%');
      component.set("v.dealEdit.FixedInterestTypeDisplay", false);
      component.set("v.dealEdit.FloatingInterestTypeDisplay", true);
    }
  }
});
