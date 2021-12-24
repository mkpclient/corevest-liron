({
    init: function(component, event, helper) {
        helper.init(component, event, helper);
    },
    addRow : function(component, event, helper){
        var table = component.find('dataTable');
        var rows = table.get('v.rows');
        if(rows == undefined)
            rows = [];
        console.log(rows);

        var loanFee = {
            'Vendor_Type__c': 'Vendor', 
            'sobjectType': 'Loan_Fee__c',
            'Deal__c' : component.get('v.recordId')
        };

        rows.push(loanFee);
        table.set('v.rows', rows);
        component.set('v.editMode', true);
	},

	delete : function(component, event, helper){
        var table = component.find('dataTable');
		var rowsChecked;
        table.getChecked(function(resp){
            rowsChecked = resp;
        });

        var rows = table.get('v.rows');
        var rowsToDelete = [];
        
        rowsChecked.forEach( function(el){
            rowsToDelete.push(rows[el]);
        });
        helper.deleteRecords(component, helper, rowsToDelete);


    },  
    toggleEdit : function(component, event, helper){
    	 component.set('v.editMode', !component.get('v.editMode'));
        helper.queryRecords(component);
    },
    saveRows : function(component, event, helper){
        helper.saveRecords(component, helper);
    },
    refresh : function(component, event, helper){
        helper.init(component, event, helper);
    },
    updatestubInterestDayCount: function(component, event, helper) {
        helper.updatestubInterestDayCount(component, event, helper);
    },
   updateInterestRateTermSheet: function(component, event, helper) {
        helper.updateInterestRateTermSheet(component, event, helper);
    }, 
 /*  updatefinalInterestRate: function(component, event, helper) {
        helper.updatefinalInterestRate(component, event, helper);
    }, */
    
    updateTotalSources: function(component, event, helper) {
        helper.updateTotalSources(component, event, helper);
        helper.updateDebtService(component, event, helper);
    },
    updatestubInterest: function(component, event, helper) {
        helper.updatestubInterest(component, event, helper);
    },
    updatetotalLender: function(component, event, helper) {
        helper.updatetotalLender(component, event, helper);
    },
     updateCorevestProceeds: function(component, event, helper) {
        helper.updateCorevestProceeds(component, event, helper);
    },
    updatetax: function(component, event, helper) {
        helper.updatetax(component, event, helper);
    },
    updatetotalreservetax: function(component, event, helper) {
        helper.updatetotalreservetax(component, event, helper);
    },
    updatetotalthirdparty: function(component, event, helper) {
        helper.updatetotalthirdparty(component, event, helper);
    },
    save: function(component, event, helper) {
        helper.saveAndPrint(component, event, false);
    },
    saveAndPrint: function(component, event, helper) {
        helper.saveAndPrint(component, event, true);
    },
    updatecapex: function(component, event, helper) {
        helper.updatecapex(component, event, helper);
    },
    updatetotalreservecapex: function(component, event, helper) {
        helper.updatetotalreservecapex(component, event, helper);
    },
    updateinsurence: function(component, event, helper) {
        helper.updateinsurence(component, event, helper);
    }, 
    updatetotalreserveinsurance: function(component, event, helper) {
        helper.updatetotalreserveinsurance(component, event, helper);
    },  
    updatetotalmonthlypayment: function(component, event, helper) {
        helper.updatetotalmonthlypayment(component, event, helper);
    },
    updatetotalreserves: function(component, event, helper) {
        helper.updatetotalreserves(component, event, helper);
    }, 
      updatetotaluses: function(component, event, helper) {
        helper.updatetotaluses(component, event, helper);
    },
    updatenetproceedstoborrower: function(component, event, helper) {
        helper.updatenetproceedstoborrower(component, event, helper);
    },  
    updatefieldswithtotallender: function(component, event, helper) { 
  		helper.updatefieldswithtotallender(component, event, helper); 
        helper.updatetotaluses(component, event, helper);
    },
  updatefieldswithtotalreserve: function(component, event, helper) { 
  		helper.updatefieldswithtotalreserve(component, event, helper); 
        helper.updatetax(component, event, helper);
       helper.updatecapex(component, event, helper);
       helper.updateinsurence(component, event, helper);
      
  },
  finalInterestRateChange: function(component, event, helper) { 
      helper.updatestubInterest(component, event, helper);
      helper.updateDebtService(component, event, helper);
    //  helper.updatefinalInterestRate(component, event, helper);
   }, 
   updateDebtService: function(component, event, helper) { 
      helper.updateDebtService(component, event, helper);
   },
})