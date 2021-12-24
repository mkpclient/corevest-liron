({
  init: function (component, event, helper) {
    //alert("In Parent");
    // var url = location.hash;
    // if (!$A.util.isEmpty(url) && $A.util.isEmpty(component.get("v.recordId"))) {
    //   var recordId = location.hash.split("#!")[1].split("?")[0];
    //   component.set("v.recordId", recordId);
    // }

    var queryString = location.search;

    if (!$A.util.isEmpty(queryString) && $A.util.isEmpty(component.get("v.recordId"))) {
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

    //console.log("Url==>"+url);

    // component.set("v.wrappers", []);
    // component.set("v.subtabs", []);
    //component.set("v.userId", resp.userId);

    let action = component.get("c.initScreen");

    action.setParams({ recordId: component.get("v.recordId") });
    action.setCallback(this, (response) => {
      //console.log("Response==>" + response.getReturnValue());
      let state = response.getState();
      if (state === "SUCCESS") {
        console.log("Response==>",JSON.parse(response.getReturnValue()));
        let resp = JSON.parse(response.getReturnValue());
        component.set("v.totalDocuments", resp.totalDocs);
        component.set("v.totalReviewed", resp.totalDocumentsReviewed);
        component.set("v.totalUploaded", resp.totalDocumentsUploaded);

        let wrappers = resp.wrappers;
        wrappers.forEach((wrapper) => {
          wrapper.documentWrappers = wrapper.documentWrappers.sort((a, b) => {
            let v1 = a.sortOrder;
            let v2 = b.sortOrder;
            if (v1 < v2) return -1;
            if (v1 > v2) return 1;
            return 0;
          });
        });

        component.set("v.wrappers", wrappers);
        component.set("v.subtabs", resp.subtabs);
        component.set("v.userId", resp.userId);

        if (wrappers.length > 0 && component.find("LoanDocuments")) {
          component.find("LoanDocuments").refreshChecklists();
        }
        if (resp.subtabs.length > 0 && component.find("Properties")) {
          component.find("Properties").refreshChecklists();
        }
        //console.log(resp);
      } else if (state === "ERROR") {
        console.log("--error--");
        console.log(response.getError());
      }
    });

    $A.enqueueAction(action);
  },
  refresh: function (component, event, helper) {
    component.find("ChecklistTabs").refreshChecklistTabs();
  },
  refreshView: function () {
    $A.get("e.force:refreshView").fire();
  }
});