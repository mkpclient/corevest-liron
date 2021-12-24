({
  compileFields: function(component) {
    var fields = [];
    var columns = component.find("dataTable").get("v.columns");
    for (var i = 0; i < columns.length; i++) {
      fields.push(columns[i].get("v.name"));
    }
    component.set("v.fieldList", fields);
  },

  showSpinner: function(component) {
    $A.util.removeClass(component.find("spinner"), "slds-hide");
  },
  hideSpinner: function(component) {
    $A.util.addClass(component.find("spinner"), "slds-hide");
  },
  navigateToRecord: function(recordId) {},
  /**
   * actionName = the apex controller method to call (e.g. 'c.myMethod' )
   * params = JSON object specifying action parameters (e.g. { 'x' : 42 } )
   * successCallback = function to call when action completes (e.g. function( response ) { ... } )
   * failureCallback = function to call when action fails (e.g. function( response ) { ... } )
   **/
  callAction: function(
    component,
    actionName,
    params,
    successCallback,
    failureCallback
  ) {
    this.showSpinner(component);
    var action = component.get(actionName);
    if (params) {
      action.setParams(params);
    }
    action.setCallback(this, function(response) {
      this.hideSpinner(component);
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
          this.logActionErrors(component, response.getError());
        }
      }
    });
    $A.enqueueAction(action);
  },
  logActionErrors: function(component, errors) {
    if (errors) {
      for (var index in errors) {
        console.error("Error: " + errors[index].message);
      }
    } else {
      console.error("Unknown error");
    }
  },

  queryProperties: function(component) {
    var tableCmp = component.find("dataTable");
    // $A.util.removeClass(component.find('spin'))
    //console.log(component.get('v.fieldList'));

    var fieldList = [
      "Id",
      "Name",
      "Parent_Property__c",
      "Parent_Property__r.Name",
      "City__c",
      "State__c",
      "Deal__r.Name",
      "RecordType.Name",
      "Active__c"
    ];

    this.callAction(
      component,
      "c.getProperties",
      {
        accountId: component.get("v.user").accountId,
        contactId: component.get("v.user").contactId,
        fields: fieldList,
        whereClause: "",
        showOnlyOpen: component.get("v.showOnlyOpen"),
        showOnlyTerm: component.get("v.showOnlyTerm"),
        showOnlyBridge: component.get("v.showOnlyBridge")
      },
      function(data) {
        //console.log(data);
        var records = JSON.parse(data);
        component.set("v.records", records);

        var tableCmp = component.find("dataTable");
        var pageSize = component.get("v.pageSize");
        var currentPage = component.get("v.currentPage");
        component.set("v.maxPage", Math.ceil(records.length / pageSize));

        var recordsToDisplay = records.slice(
          (currentPage - 1) * pageSize,
          currentPage * pageSize
        );

        tableCmp.set("v.rows", recordsToDisplay);
      },
      function(errors, state) {
        console.log(errors);
      }
    );
  }

  // queryVendorDeals : function(component){
  //     //console.log('query vendor deals');
  //     var tableCmp = component.find('dataTable');
  //     // $A.util.removeClass(component.find('spin'))
  //     //console.log(component.get('v.fieldList'));
  //     this.callAction(
  //         component,
  //         'c.getVendorDeals',
  //         {
  //             accountId: component.get('v.user').accountId,
  //             fields: component.get('v.fieldList'),
  //             'sortCol' : tableCmp.get( 'v.sortColumnName' ),
  //             'sortDir' : tableCmp.get( 'v.sortDirection' ),
  //             'whereClause' : '',
  //             'showOnlyOpen': component.get('v.showOnlyOpen'),
  //             'showOnlyTerm': component.get('v.showOnlyTerm'),
  //             'showOnlyBridge': component.get('v.showOnlyBridge')

  //         },
  //         function(data){
  //             //console.log(data);
  //             var records = JSON.parse(data);
  //             component.set('v.records', records);

  //             var tableCmp = component.find('dataTable');
  //             var pageSize = component.get('v.pageSize');
  //             var currentPage = component.get('v.currentPage');
  //             component.set('v.maxPage', Math.ceil(records.length/pageSize));

  //             var recordsToDisplay = records.slice((currentPage-1)*pageSize, currentPage*pageSize);

  //             tableCmp.set('v.rows', recordsToDisplay);

  //         },
  //         function(errors, state){
  //             console.log(errors);

  //         }
  //     );
  // },

  // queryBorrowerDeals : function(component){
  //     var tableCmp = component.find('dataTable');
  //     // $A.util.removeClass(component.find('spin'))
  //     //console.log(component.get('v.fieldList'));
  //     this.callAction(
  //         component,
  //         'c.getBorrowerDeals',
  //         {
  //             contactId: component.get('v.user').contactId,
  //             fields: component.get('v.fieldList'),
  //             'sortCol' : tableCmp.get( 'v.sortColumnName' ),
  //             'sortDir' : tableCmp.get( 'v.sortDirection' ),
  //             'whereClause' : '',
  //             'showOnlyOpen': component.get('v.showOnlyOpen'),
  //             'showOnlyTerm': component.get('v.showOnlyTerm'),
  //             'showOnlyBridge': component.get('v.showOnlyBridge')

  //         },
  //         function(data){
  //             //console.log(data);
  //             var records = JSON.parse(data);
  //             component.set('v.records', records);

  //             var tableCmp = component.find('dataTable');
  //             var pageSize = component.get('v.pageSize');
  //             var currentPage = component.get('v.currentPage');
  //             component.set('v.maxPage', Math.ceil(records.length/pageSize));

  //             var recordsToDisplay = records.slice((currentPage-1)*pageSize, currentPage*pageSize);

  //             tableCmp.set('v.rows', recordsToDisplay);

  //         },
  //         function(errors, state){
  //             console.log(errors);

  //         }
  //     );
  // }
});