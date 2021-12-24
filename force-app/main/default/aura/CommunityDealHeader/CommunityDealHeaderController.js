({
  init: function (component, event, helper) {
    // var url = location.hash;
    // if (!$A.util.isEmpty(url)) {
    //   var recordId = location.hash.split("#!")[1].split("?")[0];

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
        query[decodeURIComponent(pair[0])] = decodeURIComponent(pair[1] || "");
      }

      console.log(query);
	
      component.set("v.recordId", query.id);
    }

    let action = component.get("c.getDealInfo");
	var recordId = component.get("v.recordId");
    action.setParams({ recordId: recordId });
		
      
      
    action.setCallback(this, function (response) {
      let state = response.getState();
      if (state === "SUCCESS") {
        //component.set("v.recordType", response.getReturnValue());
         console.log(response.getReturnValue());
        component.set("v.deal", response.getReturnValue());
      } else if (state === "ERROR") {
        console.log("--error--");
        console.log(response.getError());
      }
    });

    $A.enqueueAction(action);
  },

  drawRequest: function (component, event, helper) {
    let url = "/portal/s/new-construction-draw";
    location.href = url;
    // window.open(url, "_blank");
  },

  newFunding: function (component, event, helper) {
    let recordId = component.get("v.recordId");
    let url = "/portal/s/new-funding-request?id=" + recordId;

    location.href = url;
  },

  navigateToDataTape: function (component, event, helper) {
    let recordId = component.get("v.recordId");
    let recordType = component.get("v.deal").RecordType.DeveloperName;

    let path = "";
    if (recordType == "LOC_Loan") {
      path = "bridge-data-tape";
    } else {
      path = "term-data-tape";
    }

    let url = `/portal/s/${path}?id=${recordId}`;

    location.href = url;
  }
});