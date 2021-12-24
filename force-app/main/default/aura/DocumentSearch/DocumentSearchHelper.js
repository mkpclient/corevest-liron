({
  queryPicklists: function (component) {
    var queryString = "select Section__c from deal_document__c";
    queryString +=
      " where document_Loaded__c = true and deal__c = '" +
      component.get("v.recordId") +
      "'";

    if (component.get("v.isCommunity")) {
      queryString += " AND " + component.get("v.whereClause");
    }

    queryString += " group by section__c";

    component.find("util").query(queryString, function (data) {
      var picklists = [""];

      data.forEach(function (d) {
        picklists.push(d.Section__c);
      });

      component.set("v.picklistOptions", picklists);
    });
  },

  initDataTable: function (component) {
    var columns = [
      { label: "Document Id", fieldName: "Name", type: "text" },
      { label: "Name", fieldName: "File_Name__c", type: "text" },
      { label: "Type", fieldName: "Section__c", type: "text" }
    ];

    var table = component.find("documents");
    table.set("v.columns", columns);
  },

  searchDocuments: function (component, helper) {
    var option = component.find("option").get("v.value");

    var searchText = component.find("search").get("v.value");

    if (component.get("v.isCommunity")) {
      console.log(option);
      console.log(searchText);
      helper.searchDocsCommunity(component, helper, searchText, option);
    } else {
      var queryString =
        "SELECT Id, Name, File_Name__c, Section__c, Property__c, Property__r.Name, Attachment_Id__c, Type__c, Added_By__r.Name, Added_On__c, Document_Type__c FROM Deal_Document__c WHERE Deal__c = '" +
        component.get("v.recordId") +
        "'";
      queryString += " AND Document_Loaded__c = true";
      if (!$A.util.isEmpty(option)) {
        queryString += " AND Section__c = '" + option + "'";
      }

      if (!$A.util.isEmpty(searchText)) {
        queryString += " AND (File_Name__c LIKE '%" + searchText + "%'";
        queryString += " OR Property__r.Name LIKE '%" + searchText + "%') ";
      }

      queryString += " ORDER BY Added_On__c ASC";

      component.find("util").query(queryString, function (data) {
        console.log(data);

        // component.find('documents').set('v.data', data);
        component.set("v.documents", data);
      });
    }

    // }else{
    // component.set('v.documents', []);
    // }
  },

  /*compilePermissions: function (component) {
    let fields = ["Name", "Reviewed_By__c", "Document_Type__c", "Section__c"];

    component
      .find("util")
      .getPermissions("Deal_Document__c", fields, (response) => {
        console.log(response);

        component.set("v.permissionsMap", response);
      });
  	},*/

  searchDocsCommunity: function (component, helper, searchText, option) {
    var whereClause = component.get("v.whereClause");
    console.log(whereClause);
    //whereClause += ' AND Document_Loaded__c = true';
    if (!$A.util.isEmpty(option)) {
      whereClause += " AND Section__c = '" + option + "'";
    }

    if (!$A.util.isEmpty(searchText)) {
      whereClause += " AND (File_Name__c LIKE '%" + searchText + "%'";
      whereClause += " OR Property__r.Name LIKE '%" + searchText + "%')";
    }

    // $A.util.removeClass(component.find('spinner'), 'slds-hide');
    // this.callAction(
    //     component,
    //     'c.getDocumentList',
    //     {
    //         'parentId' : component.get('v.recordId'),
    //         'parentFieldName' : 'Deal__c',
    //         'sobjectType' : 'Deal_Document__c',
    //         'fields' : ['Id', 'Name', 'File_Name__c', 'Added_On__c', 'Added_By__r.Name'],

    //         'whereClause' : component.get('v.whereClause'),

    //         'accountId': component.get('v.user').accountId,
    //         'vendorType': component.get('v.user').accountType,
    //         'userType': component.get('v.user').userType,
    //     },
    //     function( data ) {

    //         //var records = JSON.parse(data);
    //         var records = JSON.parse(data);
    //         component.set('v.records', records);
    //         //console.log(records);
    //         var tableCmp = component.find( 'dataTable' );

    //         var pageSize = component.get('v.pageSize');
    //         var currentPage = component.get('v.currentPage');

    //         component.set('v.maxPage', Math.ceil(records.length/pageSize));

    //         var recordsToDisplay = records.slice((currentPage-1)*pageSize, currentPage*pageSize);

    //         tableCmp.set('v.rows', recordsToDisplay);

    //         $A.util.addClass(component.find('spinner'), 'slds-hide');

    //     }
    // )

    var action = component.get("c.getDocumentList");

    action.setParams({
      parentId: component.get("v.recordId"),
      parentFieldName: "Deal__c",
      sobjectType: "Deal_Document__c",
      fields: [
        "Id",
        "Name",
        "File_Name__c",
        "Section__c",
        "Attachment_Id__c",
        "Type__c",
        "Added_By__r.Name",
        "Added_On__c",
        "Document_Type__c",
        "Property__c",
        "Property__r.Name"
      ],

      whereClause: whereClause,

      accountId: component.get("v.user").accountId,
      vendorType: component.get("v.user").accountType,
      userType: component.get("v.user").userType
    });

    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        console.log(JSON.parse(response.getReturnValue()));
        component.set("v.documents", JSON.parse(response.getReturnValue()));
      } else if (state === "ERROR") {
        console.log(response.getError());
      }
    });

    $A.enqueueAction(action);
  },

  compilePermissions: function (component, helper, records) {
    let fields = ["Reviewed_By__c", "Document_Type__c", "Section__c"];

    component
      .find("util")
      .getPermissions("Deal_Document__c", fields, (response) => {
        component.set("v.permissionsMap", response);
      });
  }
});