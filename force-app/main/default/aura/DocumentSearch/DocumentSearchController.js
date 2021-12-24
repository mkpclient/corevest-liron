({
  init: function (component, event, helper) {
    console.log("document search init");

    // helper.initDataTable(component);

    if (component.get("v.isCommunity")) {
      // var url = location.hash;
      // if (!$A.util.isEmpty(url)) {
      //   var recordId = location.hash.split("#!")[1].split("?")[0];
      //   console.log(recordId);
      //   component.set("v.recordId", recordId);
      // }

      var queryString = location.search;

      if (!$A.util.isEmpty(queryString)) {
        var query = {};
        var pairs = (queryString[0] === "?"
          ? queryString.substr(1)
          : queryString
        ).split("&");
        for (var i = 0; i < pairs.length; i++) {
          var pair = pairs[i].split("=");
          query[decodeURIComponent(pair[0])] = decodeURIComponent(
            pair[1] || ""
          );
        }

        console.log(query);

        component.set("v.recordId", query.id);
      }

      var action = component.get("c.getRecordTypeName");
      action.setParams({
        i: component.get("v.recordId")
      });

      action.setCallback(this, function (response) {
        var state = response.getState();

        if (state === "SUCCESS") {
          component.set("v.recordTypeName", response.getReturnValue());
          console.log(response.getReturnValue());
          console.log(component.get("v.recordTypeName"));

          // var fields = [];
          // var columns = component.find('dataTable').get('v.columns');
          // for(var i = 0; i < columns.length; i++){
          //     fields.push(columns[i].get('v.name'));
          // }

          //fields.push('Vendor_Type_Access__c');

          //component.set('v.fieldList', fields);
          //console.log(component.get('v.fieldList'));
          //helper.queryRecordsList(component);
        } else if (state === "ERROR") {
          console.log("error");
        }
      });

      var action1 = component.get("c.getUser");
      action1.setStorable();
      action1.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          //console.log(JSON.parse( response.getReturnValue() ));
          component.set("v.user", JSON.parse(response.getReturnValue()));
          var user = JSON.parse(response.getReturnValue());
          //var user = component.get('v.user');

          if (user.userType == "borrower") {
            //helper.queryBorrowerDeals(component);
            component.set("v.whereClause", "Borrower_Access__c = true");
          } else {
            //helper.queryVendorDeals(component);
            component.set("v.whereClause", "Vendor_Access__c = true");
          }

          helper.queryPicklists(component);

          //$A.enqueueAction(action);
        } else {
          console.log("error");
          console.log(response);
        }
      });
      $A.enqueueAction(action1);
    } else {
      helper.queryPicklists(component);
    }
    helper.compilePermissions(component);
  },
  updateFolder: function (component, event, helper) {
    console.log("documents:", component.get("v.documents"));
    var documents = component.get("v.documents");
    let selectedIds = [];
    documents.forEach((deal) => {
      if (deal.selected) {
        selectedIds.push(deal.Id);
      }
    });

    if (selectedIds.length > 0) {
      component.set("v.modalOpen", true);
      component.set("v.selectedIds", selectedIds);
    }
  },
  search: function (component, event, helper) {
    helper.searchDocuments(component, helper);
  },
  selectAll: function (component, event, helper) {
    //console.log('select all');
    var selected = component.find("checked").get("v.checked");
    //console.log(selected);
    var documents = component.get("v.documents");

    documents.forEach(function (deal) {
      deal.selected = selected;
    });

    component.set("v.documents", documents);
  },
  viewDocument: function (component, event, helper) {
    $A.get("e.lightning:openFiles").fire({
      recordIds: [event.getSource().get("v.title")]
    });
  },
  inputKeyPress: function (component, event, helper) {
    if (event.which == 13) {
      helper.searchDocuments(component, helper);
    }
  },
  deleteDocuments: function (component, event, helper) {
    var documents = component.get("v.documents");

    var selectedDocs = [];

    documents.forEach(function (doc) {
      //console.log(doc);
      if (doc.selected) {
        selectedDocs.push(doc);
      }
    });

    console.log(selectedDocs);

    component.find("util").delete(selectedDocs, function (response) {
      helper.searchDocuments(component, helper);
    });
  }
});