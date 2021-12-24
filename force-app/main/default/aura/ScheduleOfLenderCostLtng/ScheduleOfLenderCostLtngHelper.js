({
    init: function(component, event, helper) {
        var action = component.get("c.getData");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            if(component.isValid() && response.getState() === "SUCCESS") {
                var responseObj = response.getReturnValue(); 
                component.set("v.Deal", responseObj);
                var tableCmp = component.find( 'dataTable' );
                tableCmp.set( 'v.rows', responseObj.Loan_Fees__r );
                helper.refreshAllFormulaMethods(component, event, helper);
            }else if(response.getState() === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }else {
                    console.log("Unknown error");                                                         
                }
                
            }
        });
        
        $A.enqueueAction(action);
    },
    refreshAllFormulaMethods: function(component, event, helper) {
        component.set("v.unsavedObj", {
            dealId: component.get("v.Deal.Id"),
            fundingDate2: null,
            originationfeepercentage: 0,
            yearSwapRate: 0,
            installmentcomment: null,
            creditSpread: 0,
            InterestRateTermSheet: 0,
            // finalInterestRate : 0,
            InterestRateRateLock: 0,
            stubInterestDayCount: null,
            debtreserve: null,
            DebtService: null,
            stubInterest: null,
            CorevestProceeds: null,
            cfcorevestpurchaser: null,
           // taxentry: null,
            TotalSources: null,
            totalLender: null,
           // capexentry: null,
          //  insuranceentry: null,
            tax: null,
            capex: null,
            totalthirdparty: null,
            insurence: null,
            totalreserves: null,
            netproceedstoborrower: null,
            totaluses: null,
         //   reservetax: null,
            totalreservetax: null,
            totalreserveinsurance: null,
            totalreservecapex: null,
            rateType: null,
            totalmonthlypayment : null
        });
        
        var date1 = new Date(component.get("v.Deal.CloseDate"));
        var fundingDate2 = new Date(date1.getFullYear(), date1.getMonth() + 1, 0);
        component
        .find("fundingDate2")
        .set(
            "v.value",
            $A.localizationService.formatDate(fundingDate2, "YYYY-MM-DD")
        );
                
        //call all methods here
        this.updatestubInterestDayCount(component, event, helper);
        this.updateInterestRateTermSheet(component, event, helper);
        // this.updatefinalInterestRate(component, event, helper);
        this.updateTotalSources(component, event, helper);
        //this.updatetotalLender(component, event, helper);
        this.updatetotalreservetax(component, event, helper);
        this.updatetotalreservecapex(component, event, helper);
        this.updatetotalreserveinsurance(component, event, helper);
        this.updatetotalmonthlypayment(component, event, helper);
        this.updatestubInterest(component, event, helper);
        this.updatetotalLender(component, event, helper);///
        this.updateCorevestProceeds(component, event, helper);
        this.updatetotalthirdparty(component, event, helper);
        this.updatenetproceedstoborrower(component, event, helper);
        this.updatetotalreserves(component, event, helper);
        this.updatefieldswithtotallender(component, event, helper);
        this.updatetotaluses(component, event, helper);
        // this.updateDebtService(component, event, helper);
        this.attachPrintListener(component);
        this.initializeIframe(component, event);
        this.updatefieldswithtotalreserve(component, event, helper);
        
        this.updateDebtService(component, event, helper);
        
        //update other fields
        helper.updatetax(component, event, helper);
        helper.updateinsurence(component, event, helper);
        helper.updatecapex(component, event, helper);
        
    },
    updatestubInterestDayCount: function(component, event, helper) {
        var stubInterestDayCount;
        if (
            !$A.util.isEmpty(component.find("fundingDate1").get("v.value")) &&
            !$A.util.isUndefined(component.find("fundingDate2").get("v.value"))
        ) {
            var date1 = new Date(component.find("fundingDate1").get("v.value"));
            var date2 = new Date(component.find("fundingDate2").get("v.value"));
            var diffTime = Math.abs(date2 - date1 + 1);
            stubInterestDayCount = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        }
        component.find("stubInterestDayCount").set("v.value", stubInterestDayCount);
    },
    updateInterestRateTermSheet: function(component, event, helper) {
        var InterestRateTermSheet = 0;
        if (
            !$A.util.isEmpty(component.find("yearSwapRate").get("v.value")) &&
            !$A.util.isUndefined(component.find("yearSwapRate").get("v.value"))
        ) {
            var yearSwapRate = parseFloat(
                component.find("yearSwapRate").get("v.value")
            );
        }
        if (
            !$A.util.isEmpty(component.find("creditSpread").get("v.value")) &&
            !$A.util.isUndefined(component.find("creditSpread").get("v.value"))
        ) {
            var creditSpread = parseFloat(
                component.find("creditSpread").get("v.value")
            );
            InterestRateTermSheet = parseFloat(yearSwapRate + creditSpread).toFixed(2);
        }
        component
        .find("InterestRateTermSheet")
        .set("v.value", InterestRateTermSheet);
    },
      
    updateTotalSources: function(component, event, helper) {
        var TotalSources;
        if (
            !$A.util.isEmpty(component.find("Final_Loan_Amount").get("v.value")) &&
            !$A.util.isUndefined(component.find("Deposit_Amount").get("v.value"))
        ) {
            var Final_Loan_Amount = parseFloat(
                component.find("Final_Loan_Amount").get("v.value")
            );
            var Deposit_Amount = parseFloat(
                component.find("Deposit_Amount").get("v.value")
            );
            TotalSources = parseFloat(Final_Loan_Amount + Deposit_Amount).toFixed(2);
        }
        component.find("TotalSources").set("v.value", TotalSources);
        helper.updatefieldswithtotallender(component, event, helper);
    },
    updatestubInterest: function(component, event, helper) {
        var stubInterest = 0;
        var InterestRateTermSheet = 0;
        var Final_Loan_Amount = 0;
        var stubInterestDayCount = 0;
        if (
            !$A.util.isEmpty(component.find("InterestRateTermSheet").get("v.value")) &&
            !$A.util.isUndefined(component.find("InterestRateTermSheet").get("v.value"))
        ) {
            InterestRateTermSheet = parseFloat(
                component.find("InterestRateTermSheet").get("v.value")
            ).toFixed(2);
        }
        if (
            !$A.util.isEmpty(component.find("Final_Loan_Amount").get("v.value")) &&
            !$A.util.isUndefined(component.find("Final_Loan_Amount").get("v.value"))
        ) {
            Final_Loan_Amount = parseFloat(
                component.find("Final_Loan_Amount").get("v.value")
            ).toFixed(2);
        }
        if (
            !$A.util.isEmpty(component.find("stubInterestDayCount").get("v.value")) &&
            !$A.util.isUndefined(
                component.find("stubInterestDayCount").get("v.value")
            )
        ) {
            stubInterestDayCount = parseFloat(
                component.find("stubInterestDayCount").get("v.value")
            ).toFixed(2);
        }
        stubInterest = parseFloat(
            (parseFloat(InterestRateTermSheet) *
             parseFloat(Final_Loan_Amount) *
             parseFloat(stubInterestDayCount)) /
            36000
        ).toFixed(2);
        
        component.find("stubInterest").set("v.value", stubInterest);
    },
    updatetotalLender: function(component, event, helper) {
        var totalLender = 0;
        var Origination_Fee = 0;
        var stubInterest = 0;
        var Lender_Diligence_Out_of_Pocket = 0;
        var cfcorevestpurchaser = 0;
        if (
            !$A.util.isEmpty(component.find("Origination_Fee").get("v.value")) &&
            !$A.util.isUndefined(component.find("Origination_Fee").get("v.value"))
        ) {
            Origination_Fee = parseFloat(
                component.find("Origination_Fee").get("v.value")
            ).toFixed(2);
        }
        if (
            !$A.util.isEmpty(component.find("stubInterest").get("v.value")) &&
            !$A.util.isUndefined(component.find("stubInterest").get("v.value"))
        ) {
            stubInterest = parseFloat(
                component.find("stubInterest").get("v.value")
            ).toFixed(2);
        }
        if (
            !$A.util.isEmpty(
                component.find("Lender_Diligence_Out_of_Pocket").get("v.value")
            ) &&
            !$A.util.isUndefined(
                component.find("Lender_Diligence_Out_of_Pocket").get("v.value")
            )
        ) {
            Lender_Diligence_Out_of_Pocket = parseFloat(
                component.find("Lender_Diligence_Out_of_Pocket").get("v.value")
            ).toFixed(2);
        }
        if (
            !$A.util.isEmpty(component.find("cfcorevestpurchaser").get("v.value")) &&
            !$A.util.isUndefined(component.find("cfcorevestpurchaser").get("v.value"))
        ) {
            cfcorevestpurchaser = parseFloat(
                component.find("cfcorevestpurchaser").get("v.value")
            ).toFixed(2);
        }
        totalLender = parseFloat(
            parseFloat(
                parseFloat(Origination_Fee) +
                parseFloat(stubInterest) +
                parseFloat(Lender_Diligence_Out_of_Pocket) +
                parseFloat(cfcorevestpurchaser)
            )
        ).toFixed(2);
        component.find("totalLender").set("v.value", totalLender);
        helper.updatefieldswithtotallender(component, event, helper);
    },
    updateCorevestProceeds: function(component, event, helper) {
        var CorevestProceeds = 0;
        var TotalSources = 0;
        var totalLender = 0;
        if (
            !$A.util.isEmpty(component.find("TotalSources").get("v.value")) &&
            !$A.util.isUndefined(component.find("TotalSources").get("v.value"))
        ) {
            TotalSources = parseFloat(
                component.find("TotalSources").get("v.value")
            ).toFixed(2);
        }
        if (
            !$A.util.isEmpty(component.find("totalLender").get("v.value")) &&
            !$A.util.isUndefined(component.find("totalLender").get("v.value"))
        ) {
            totalLender = parseFloat(
                component.find("totalLender").get("v.value")
            ).toFixed(2);
        }
        CorevestProceeds = parseFloat(
            parseFloat(TotalSources) - parseFloat(totalLender)
        ).toFixed(2);
        component.find("CorevestProceeds").set("v.value", CorevestProceeds);
    },
    /* Added - Deal Loan Fees */
    callAction: function(
        component,
        actionName,
        params,
        successCallback,
        failureCallback
    ) {
        //this.showSpinner( component );
        
        var action = component.get(actionName);
        
        if (params) {
            action.setParams(params);
        }
        
        action.setCallback(this, function(response) {
            //this.hideSpinner( component );
            
            if (component.isValid() && response.getState() === "SUCCESS") {
                if (successCallback) {
                    successCallback(response.getReturnValue());
                }
            } else {
                console.error(
                    'Error calling action "' +
                    actionName +
                    '" with state: ' +
                    response.getState()
                );
                
                if (failureCallback) {
                    failureCallback(response.getError(), response.getState());
                } else {
                    //this.logActionErrors( component, response.getError() );
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    saveRecords: function(component, helper) {
        var table = component.find("dataTable");
        
        var rows = table.get("v.rows");
        table.toggleSpinner();
        helper.callAction(
            component,
            "c.upsertRecords",
            {
                records: rows
            },
            
            function(data) {
                component.set("v.editMode", !component.get("v.editMode"));
                table.set("v.rows", data);
                table.toggleSpinner();
                helper.queryRecords(component);
            }
        );
    },
    deleteRecords: function(component, helper, records) {
        var tableCmp = component.find("dataTable");
        
        tableCmp.toggleSpinner();
        helper.callAction(
            component,
            "c.deleteRecords",
            {
                records: records
            },
            function(data) {
                tableCmp.toggleSpinner();
                helper.queryRecords(component);
            }
        );
    },
    queryRecords: function(component) {
        var tableCmp = component.find("dataTable");
        
        tableCmp.toggleSpinner();
        this.callAction(
            component,
            "c.getDealLoanFees",
            {
                recordId: component.get("v.recordId")
            },
            function(data) {
                var tableCmp = component.find("dataTable");
                tableCmp.set("v.rows", data);
                tableCmp.toggleSpinner();
                
                var totalthirdparty = 0;
                for (var i in data)
                    totalthirdparty = totalthirdparty + data[i].Fee_Amount__c;
                console.log(totalthirdparty);
                component.find("totalthirdparty").set("v.value", totalthirdparty);
            }
        );
    },
    updatetotalthirdparty: function(component, event, helper) {
        var totalthirdparty = 0;
        var deal = component.get("v.Deal");
        var fees = deal.Loan_Fees__r;
        for (var i in fees)
            totalthirdparty = totalthirdparty + fees[i].Fee_Amount__c;
        console.log(totalthirdparty);
        component.find("totalthirdparty").set("v.value", totalthirdparty);
        helper.updatefieldswithtotallender(component, event, helper);
    },
    updatetax: function(component, event, helper) {
        var tax = 0;
        var taxentry = 0;
        if (
            !$A.util.isEmpty(component.get("v.Deal.Total_Annual_Tax__c")) &&
            !$A.util.isUndefined(component.get("v.Deal.Total_Annual_Tax__c"))
        ) {
            taxentry = parseFloat(component.get("v.Deal.Total_Annual_Tax__c"));
            tax = parseFloat(taxentry / 12).toFixed(2);
        }
        component.find("tax").set("v.value", tax);
        helper.updatefieldswithtotalreserve(component, event, helper);
    },
    updateinsurence: function(component, event, helper) {
        var insurence = 0;
        var insuranceentry = 0;
        if (
            !$A.util.isEmpty(component.get("v.Deal.Total_Annual_Insurance__c")) &&
            !$A.util.isUndefined(component.get("v.Deal.Total_Annual_Insurance__c"))
        ) {
            insuranceentry = parseFloat(component.get("v.Deal.Total_Annual_Insurance__c"));
            insurence = parseFloat(insuranceentry / 12).toFixed(2);
        }
        component.find("insurence").set("v.value", insurence);
        helper.updatefieldswithtotalreserve(component, event, helper);
    },
    updatecapex: function(component, event, helper) {
        var capex = 0;
        var capexentry = 0;
        if (
            !$A.util.isEmpty(component.get("v.Deal.Total_Annual_Cap_Ex__c")) &&
            !$A.util.isUndefined(component.get("v.Deal.Total_Annual_Cap_Ex__c"))
        ) {
            capexentry = parseFloat(component.get("v.Deal.Total_Annual_Cap_Ex__c"));
            capex = parseFloat(capexentry / 12).toFixed(2);
        }
        component.find("capex").set("v.value", capex);
        helper.updatefieldswithtotalreserve(component, event, helper);
    },
    updatetotalreservetax: function(component, event, helper) {
        var totalreservetax = 0;
        var tax = 0;
        var reservetax = 0;
        if (
            !$A.util.isEmpty(component.find("tax").get("v.value")) &&
            !$A.util.isUndefined(component.find("tax").get("v.value"))
        ) {
            tax = parseFloat(
                component.find("tax").get("v.value")
            );
        }
        if (
            !$A.util.isEmpty(component.find("reservetax").get("v.value")) &&
            !$A.util.isUndefined(component.find("reservetax").get("v.value"))
        ) {
            reservetax = parseFloat(
                component.find("reservetax").get("v.value")
            );
        }
        totalreservetax =
            reservetax != 0
        ? parseFloat(tax * reservetax).toFixed(2)
        : 0;
        component
        .find("totalreservetax")
        .set("v.value", totalreservetax);
    },
    
    updatetotalreserveinsurance: function(component, event, helper) {
        var totalreserveinsurance = 0;
        var insurence = 0;
        var reserveinsurance = 0;
        if (
            !$A.util.isEmpty(component.find("insurence").get("v.value")) &&
            !$A.util.isUndefined(component.find("insurence").get("v.value"))
        ) {
            insurence = parseFloat(
                component.find("insurence").get("v.value")
            );
        }
        if (
            !$A.util.isEmpty(component.find("reserveinsurance").get("v.value")) &&
            !$A.util.isUndefined(component.find("reserveinsurance").get("v.value"))
        ) {
            reserveinsurance = parseFloat(
                component.find("reserveinsurance").get("v.value")
            );
        }
        totalreserveinsurance =
            reserveinsurance != 0
        ? parseFloat(insurence * reserveinsurance).toFixed(2)
        : 0;
        component
        .find("totalreserveinsurance")
        .set("v.value", totalreserveinsurance);
    },
    updatetotalreservecapex: function(component, event, helper) {
        var totalreservecapex = 0;
        var capex = 0;
        var reservecapex = 0;
        if (
            !$A.util.isEmpty(component.find("capex").get("v.value")) &&
            !$A.util.isUndefined(component.find("capex").get("v.value"))
        ) {
            capex = parseFloat(component.find("capex").get("v.value"));
        }
        if (
            !$A.util.isEmpty(component.find("reservecapex").get("v.value")) &&
            !$A.util.isUndefined(component.find("reservecapex").get("v.value"))
        ) {
            reservecapex = parseFloat(component.find("reservecapex").get("v.value"));
        }
        totalreservecapex =
            reservecapex != 0 ? parseFloat(capex * reservecapex).toFixed(2) : 0;
        component.find("totalreservecapex").set("v.value", totalreservecapex);
    },
    updatetotalmonthlypayment: function(component, event, helper) {
        var capex = 0;
        var insurence = 0;
        var tax = 0;
        var DebtService = 0;
        var debtreserve = 0;
        if (
            !$A.util.isEmpty(component.find("capex").get("v.value")) &&
            !$A.util.isUndefined(component.find("capex").get("v.value"))
        ) {
            capex = parseFloat(component.find("capex").get("v.value"));
        }
        if (
            !$A.util.isEmpty(component.find("insurence").get("v.value")) &&
            !$A.util.isUndefined(component.find("insurence").get("v.value"))
        ) {
            insurence = parseFloat(component.find("insurence").get("v.value"));
        }
        if (
            !$A.util.isEmpty(component.find("tax").get("v.value")) &&
            !$A.util.isUndefined(component.find("tax").get("v.value"))
        ) {
            tax = parseFloat(component.find("tax").get("v.value"));
        }
        if (
            !$A.util.isEmpty(component.find("DebtService").get("v.value")) &&
            !$A.util.isUndefined(component.find("DebtService").get("v.value"))
        ) {
            DebtService = parseFloat(component.find("DebtService").get("v.value"));
        }
        
        debtreserve = parseFloat(capex+insurence+tax+DebtService).toFixed(2);
        component.find("debtreserve").set("v.value", debtreserve);
    },
    updatetotalreserves: function(component, event, helper) {
        var totalreserves = 0;
        if (
            component.find("DebtService") &&
            !$A.util.isEmpty(component.find("DebtService").get("v.value")) &&
            !$A.util.isUndefined(component.find("DebtService").get("v.value"))
            && component.get("v.Deal.Recourse__c")=='Non-Recourse' && component.get("v.Deal.Cash_Management__c")=='None'
        ) {
            totalreserves += parseFloat(component.find("DebtService").get("v.value"));
        }
        if (
            !$A.util.isEmpty(component.find("totalreservetax").get("v.value")) &&
            !$A.util.isUndefined(component.find("totalreservetax").get("v.value"))
        ) {
            totalreserves += parseFloat(
                component.find("totalreservetax").get("v.value")
            );
        }
        if (
            !$A.util.isEmpty(component.find("totalreservecapex").get("v.value")) &&
            !$A.util.isUndefined(component.find("totalreservecapex").get("v.value"))
        ) {
            totalreserves += parseFloat(
                component.find("totalreservecapex").get("v.value")
            );
        }
        if (
            !$A.util.isEmpty(
                component.find("totalreserveinsurance").get("v.value")
            ) &&
            !$A.util.isUndefined(
                component.find("totalreserveinsurance").get("v.value")
            )
        ) {
            totalreserves += parseFloat(
                component.find("totalreserveinsurance").get("v.value")
            );
        }
        //component.find("totalreserves").set("v.value", totalreserves);
        component.set("v.unsavedObj.totalreserves", totalreserves);
        helper.updatefieldswithtotallender(component, event, helper);
    },
    
    updatefieldswithtotalreserve: function(component, event, helper) {
        helper.updatetotalreserveinsurance(component, event, helper);
        helper.updatetotalreservecapex(component, event, helper);
        helper.updatetotalreservetax(component, event, helper);
        helper.updatetotalmonthlypayment(component, event, helper);  
        this.updatetotalreserves(component, event, helper);
    },
    updatefieldswithtotallender: function(component, event, helper) {
        helper.updateCorevestProceeds(component, event, helper);
        helper.updatenetproceedstoborrower(component, event, helper);
        helper.updatetotaluses(component, event, helper);
    },
    
    updatenetproceedstoborrower: function(component, event, helper) {
        var netproceedstoborrower = 0;
        if (
            !$A.util.isEmpty(component.find("TotalSources").get("v.value")) &&
            !$A.util.isUndefined(component.find("TotalSources").get("v.value"))
        ) {
            netproceedstoborrower += parseFloat(
                component.find("TotalSources").get("v.value")
            ).toFixed(2);
        }
        if (
            !$A.util.isEmpty(component.find("totalLender").get("v.value")) &&
            // !$A.util.isEmpty(component.find("totalLender").get("v.value")) &&
            !$A.util.isUndefined(component.find("totalLender").get("v.value"))
        ) {
            netproceedstoborrower -= parseFloat(
                component.find("totalLender").get("v.value")
            ).toFixed(2);
        }
        if (
            !$A.util.isEmpty(component.find("totalreserves").get("v.value")) &&
            //  !$A.util.isEmpty(component.find("totalreserves").get("v.value")) &&
            !$A.util.isUndefined(component.find("totalreserves").get("v.value"))
        ) {
            netproceedstoborrower -= parseFloat(
                component.find("totalreserves").get("v.value")
            ).toFixed(2);
        }
        if (
            !$A.util.isEmpty(component.find("totalthirdparty").get("v.value")) &&
            //  !$A.util.isEmpty(component.find("totalthirdparty").get("v.value")) &&
            !$A.util.isUndefined(component.find("totalthirdparty").get("v.value"))
        ) {
            netproceedstoborrower -= parseFloat(
                component.find("totalthirdparty").get("v.value")
            ).toFixed(2);
        }
        component
        .find("netproceedstoborrower")
        .set("v.value", netproceedstoborrower);
        //helper.updatefieldswithtotallender(component, event, helper, false);
    },
    updatetotaluses: function(component, event, helper) {
        var totaluses = 0;
        //alert('0');
        if (
            !$A.util.isEmpty(
                component.find("netproceedstoborrower").get("v.value")
            ) &&
            !$A.util.isUndefined(
                component.find("netproceedstoborrower").get("v.value")
            )
        ) {
            totaluses += parseFloat(
                component.find("netproceedstoborrower").get("v.value")
            );
        }
        if (
            !$A.util.isEmpty(component.find("totalLender").get("v.value")) &&
            !$A.util.isUndefined(component.find("totalLender").get("v.value"))
        ) {
            totaluses += parseFloat(component.find("totalLender").get("v.value"));
        }
        if (
            !$A.util.isEmpty(component.find("totalreserves").get("v.value")) &&
            !$A.util.isUndefined(component.find("totalreserves").get("v.value"))
        ) {
            totaluses += parseFloat(component.find("totalreserves").get("v.value"));
        }
        if (
            !$A.util.isEmpty(component.find("totalthirdparty").get("v.value")) &&
            !$A.util.isUndefined(component.find("totalthirdparty").get("v.value"))
        ) {
            totaluses += parseFloat(component.find("totalthirdparty").get("v.value"));
        }
        component.find("totaluses").set("v.value", totaluses);
    },
    
    saveAndPrint: function(component, event, isPrint) {
        component.find("saveBtn").set("v.disabled", true);
        component.find("printBtn").set("v.disabled", true);
        
        var action = component.get("c.saveDealData");
        action.setParams({
            deal: component.get("v.Deal")
        });
        action.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === "SUCCESS" && response.getReturnValue().Success=='true') {
                if(isPrint){
                    this.printData(component, event);
                }else{
                    alert('Record saved successfully.');
                }
                
                $A.get("e.force:refreshView").fire();
            }else if(response.getReturnValue().Success=='false') {
                alert(response.getReturnValue().ErrorMessage);
            } else if (response.getState() === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert.log(errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            } else {
                alert("Error occurred while updating Deal data.");
            }
            component.find("printBtn").set("v.disabled", false);
            component.find("saveBtn").set("v.disabled", false);
        });
        
        $A.enqueueAction(action);
    },
    printData: function(cmp, event) {
        var vfWindow = cmp.find("vfFrame").getElement().contentWindow;
        console.log("unsavedObj----> " + JSON.stringify(cmp.get("v.unsavedObj")));
        vfWindow.postMessage(JSON.stringify(cmp.get("v.unsavedObj")), "*");
    },
    initializeIframe: function(cmp, event) {
        var action = cmp.get("c.getUrlAndInstance");
        action.setCallback(
            this,
            $A.getCallback(function(response) {
                if (response.getState() === "SUCCESS") {
                    cmp.set("v.iframeBaseURL", response.getReturnValue());
                    var checkForIframe = setInterval(
                        $A.getCallback(function() {
                            if (
                                typeof cmp.find("vfFrame") != "undefined" &&
                                cmp.find("vfFrame").getElement() != null
                            ) {
                                cmp.find("vfFrame").getElement().src = cmp.get(
                                    "v.iframeBaseURL"
                                );
                                clearInterval(checkForIframe);
                            }
                        }),
                        10
                    );
                } else {
                    alert(
                        "An error occured while fetching Salesforce URL. Please reload this page."
                    );
                }
            })
        );
        $A.enqueueAction(action);
    },
    attachPrintListener: function(cmp, event) {
        var self = this;
        window.addEventListener(
            "message",
            $A.getCallback(function(event) {
                if (event.data == "finished printing") {
                    console.log("Printing done.");
                }
            })
        );
    },
    updateDebtService: function(component, event, helper) {
        var PV=component.get("v.Deal.Final_Loan_Amount__c");
        var Indicative_Rate=component.get("v.unsavedObj.InterestRateTermSheet");
        if(component.get("v.Deal.Interest_Rate_Type__c")=='Fixed'){
            if(!$A.util.isUndefined(PV) && !$A.util.isUndefined(Indicative_Rate)){
                //PMT= (PV*Rate*(1+Rate)^nper)/[(1+Rate)^nper - 1]
                var rate=parseFloat((Indicative_Rate*365)/(12*360*100));
                var pmt=parseFloat(PV*rate*(Math.pow((1+rate), 360))/(Math.pow((1+rate),360) - 1)).toFixed(2);
                component.find("DebtService").set("v.value", pmt);
            }else{
                component.find("DebtService").set("v.value",0);
            }
        }else if(component.get("v.Deal.Interest_Rate_Type__c")=='Interest Only'){
            if(!$A.util.isUndefined(PV) && !$A.util.isUndefined(Indicative_Rate) && !$A.util.isUndefined(component.get("v.Deal.IO_Term__c"))){
                //IPMT = pmt + (1+rate)^(nper-1)*(pv *rate - pmt)
                var rate=parseFloat((Indicative_Rate*365)/(12*360*100));
                var IO_Term=component.get("v.Deal.IO_Term__c");
                var nper=parseInt(IO_Term.split(' months')[0]);
                
                var pmt=parseFloat(PV*rate*(Math.pow((1+rate), 360))/(Math.pow((1+rate),360) - 1));
                var ipmt= parseFloat(pmt+((1+Math.pow(rate,(nper-1)))*PV*rate)- pmt).toFixed(2);
                component.find("DebtService").set("v.value", ipmt);
            }else{
                
                component.find("DebtService").set("v.value",0);
            }
        }
    },
});