({
  init: function (component, event, helper) {
    // var url = location.hash;
    // if(!$A.util.isEmpty(url)){
    // 	var recordId = location.hash.split('#!')[1].split('?')[0];
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

    let action = component.get("c.getDealMembers");

    action.setParams({ recordId: component.get("v.recordId") });

    action.setCallback(this, function (response) {
      let state = response.getState();
      if (state === "SUCCESS") {
        console.log(JSON.parse(response.getReturnValue()));
        component.set("v.dealMembers", JSON.parse(response.getReturnValue()));
      } else if (state === "ERROR") {
        console.log(response.getError());
      }
    });

    $A.enqueueAction(action);
  }
});