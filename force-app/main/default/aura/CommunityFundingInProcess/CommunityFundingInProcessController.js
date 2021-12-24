({
  init: function(component, event, helper) {
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

    let action = component.get("c.getFundingsInProcess");
    action.setParams({ recordId: component.get("v.recordId") });
    action.setCallback(this, function(response) {
      let state = response.getState();
      if (state == "SUCCESS") {
        component.set("v.properties", response.getReturnValue());
      } else if (state === "ERROR") {
        console.log("--error--");
        console.log(response.getError());
      }
    });

    $A.enqueueAction(action);
  },

  openModal: function(component, event, helper) {
    console.log("open modal");
    // console.log(event)
    component.set("v.selectedPropertyId", event.target.getAttribute("title"));
    component.set("v.modalOpen", true);
  }
});