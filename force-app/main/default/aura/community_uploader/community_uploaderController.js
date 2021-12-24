({
  init: function (component, event, helper) {
    console.log("uploader init");
    // var url = location.hash;
    // if(!$A.util.isEmpty(url)){
    // 	var recordId = location.hash.split('#!')[1].split('?')[0];
    // 	console.log(recordId);
    // 	component.set('v.recordId', recordId);
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
        query[decodeURIComponent(pair[0])] = decodeURIComponent(pair[1] || "");
      }

      console.log(query);

      component.set("v.recordId", query.id);
    }
    helper.getPropertyPicklists(component, helper);
    var action = component.get("c.getUser");
    action.setStorable();
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.user", JSON.parse(response.getReturnValue()));
        console.log(component.get("v.user"));
        helper.getRecordTypeName(component, helper);
      } else {
        console.log("error");
        console.log(response);
      }
    });
    $A.enqueueAction(action);

    component
      .find("util")
      .query("SELECT Id FROM Deal_Document__c LIMIT 1", function (response) {
        console.log(response);
        if (!$A.util.isEmpty(response)) {
          component.set("v.documentId", response[0].Id);
        }

        console.log(component.get("v.documentId"));
      });
  },

  propertyIdChange: function (component, event, helper) {
    console.log(component.get("v.propertyId"));
    if ($A.util.isEmpty(component.get("v.propertyId"))) {
      component.set("v.propertyUploaderFacet", []);
    } else {
      $A.createComponent(
        "c:TermDocumentUploader",
        {
          recordId: component.get("v.propertyId"),
          sobjectType: "Property__c",
          recordType: component.get("v.recordTypeName"),
          userType: component.get("v.user").userType,
          uploadType: "portal",
          accountId: component.get("v.user.accountId"),
          accountType: component.get("v.user.accountType")
        },
        function (uploader, status, errorMessage) {
          if (status === "SUCCESS") {
            var body = [];
            body.push(uploader);
            component.set("v.propertyUploaderFacet", uploader);
          }
        }
      );
    }
  },

  handleSelect: function (component, event, helper) {
    var tab = event.getSource();
    console.log(tab.get("v.id"));

    component.set("v.dealSelected", false);
    component.set("v.propertySelected", false);

    component.set("v." + tab.get("v.id") + "Selected", true);
  },

  handleActive: function (component, event, helper) {
    var tab = event.getSource();

    console.log(tab.get("v.id"));

    if (tab.get("v.id") == "dealSingle") {
      component.set("v.dealBulkSelected", false);
    } else if (tab.get("v.id") == "dealBulk") {
      component.set("v.dealSingleSelected", false);
    } else if (tab.get("v.id") == "propertySingle") {
      component.set("v.propertyBulkSelected", false);
    } else if (tab.get("v.id") == "propertyBulk") {
      component.set("v.propertySingleSelected", false);
    }

    component.set("v." + tab.get("v.id") + "Selected", true);
  }
});