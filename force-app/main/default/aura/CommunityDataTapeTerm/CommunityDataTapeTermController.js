({
  init: function(component, event, helper) {
      console.log('init');
    var queryString = location.search;
	
    if (!$A.util.isEmpty(queryString)) {
      var query = {};
      var pairs = (queryString[0] === "?"
        ? queryString.substr(1)
        : queryString
      ).split("&");
      for (var i = 0; i < pairs.length; i++) {
        var pair = pairs[i].split("=");
        query[decodeURIComponent(pair[0])] = decodeURIComponent(pair[1] || "");
      }

      console.log(query);
	
      component.set("v.recordId", query.id);
    }
      
      

    let action = component.get("c.getTermDataTapeProperties");

    action.setParams({ recordId: component.get("v.recordId") });

    action.setCallback(this, function(response) {
      let state = response.getState();
		console.log(state);
      if (state === "SUCCESS") {
        console.log(JSON.parse(response.getReturnValue()));
        let data = JSON.parse(response.getReturnValue());
        
        component.find("hot-table").createTable(data);
      } else if (state === "ERROR") {
        //
          console.log(response.getError());
      }
    });
	console.log('i');
    $A.enqueueAction(action);
  },

  navigateToRecord: function(component, event, helper) {
    let recordId = component.get("v.recordId");

    location.href = `/portal/s/deal?id=${recordId}`;
  },

  export: function(component, event, helper) {
    console.log("export");
    var exportCmp = component.find("export");

    var value;
    exportCmp.getValue(function(val) {
      value = val;
    });

    var properties = [];

    // var action = component.get("c.getRelatedList");
    // if (value == "exportAll") {
    //   action.setParams({
    //     parentId: component.get("v.recordId"),
    //     parentFieldName: component.get("v.parentFieldName"),
    //     sobjectType: component.get("v.sobjectType"),
    //     whereClause: "Active__c = true",
    //     orderClause: "Property_Name__c ASC, Parent_Property__c ASC, Name ASC"
    //   });
    // } else if (value == "excludeParent") {
    //   action.setParams({
    //     parentId: component.get("v.recordId"),
    //     parentFieldName: component.get("v.parentFieldName"),
    //     sobjectType: component.get("v.sobjectType"),
    //     whereClause: "Is_Parent__c = false AND Active__c = true",
    //     orderClause: "Property_Name__c asc"
    //   });
    // } else if (value == "excludeSubUnit") {
    //   action.setParams({
    //     parentId: component.get("v.recordId"),
    //     parentFieldName: component.get("v.parentFieldName"),
    //     sobjectType: component.get("v.sobjectType"),
    //     whereClause: "Is_Sub_Unit__c = false AND Active__c = true",
    //     orderClause: "Name asc"
    //   });
    // }

    let action = component.get("c.getTermDataTapeProperties");

    action.setParams({ recordId: component.get("v.recordId"), filter: value });

    helper
      .serverSideCall(action, component)
      .then(
        $A.getCallback(function(response) {
          properties = JSON.parse(response);
          console.log(properties);
          var action1 = component.get("c.getTemplate");
          action1.setParams({
            templateName: "TermDataTape"
          });
          return helper.serverSideCall(action1, component);
        })
      )
      .then(
        $A.getCallback(function(response) {
          console.log("data loaded");

          // console.log(JSON.parse(response));

          XlsxPopulate.fromDataAsync(
            helper.base64ToArrayBuffer(JSON.parse(response))
          )
            .then(workbook => {
              var columns = component.find("hot-table").get("v.columns");

              for (var i = 0; i < properties.length; i++) {
                for (var j = 0; j < columns.length; j++) {
                  var prop = columns[j].get("v.data");

                  if (
                    columns[j].get("v.type") == "date" &&
                    !$A.util.isEmpty(properties[i][prop])
                  ) {
                    properties[i][prop] = $A.localizationService.formatDate(
                      properties[i][prop],
                      "MM/DD/YYYY"
                    );
                  }

                  if (
                    !$A.util.isEmpty(prop) &&
                    prop != "_" &&
                    prop != "Annual_NOI__c" &&
                    prop != "Annual_Total_Expenses__c" &&
                    prop != "Total_Basis__c"
                  ) {
                    workbook
                      .sheet(1)
                      .row(10 + i)
                      .cell(j + 2)
                      .value(properties[i][prop]);
                  }
                }
              }
              return workbook.outputAsync("base64");
            })
            .then(data => {
              console.log("getting here?");
              var link = document.createElement("a");
              link.href = "data:" + XlsxPopulate.MIME_TYPE + ";base64," + data;
              link.download = "TermDataTape.xlsx";
              link.click();
              exportCmp.close();
            });
        })
      )
      .catch(function(error) {
        console.log(error);
      });
  },

  openExportModal: function(component, event, helper) {
    component.find("export").open();
  }
});