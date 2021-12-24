({
  init: function (component, event, helper) {
    // var url = location.hash;
    // if(!$A.util.isEmpty(url)){
    //     var recordId = location.hash.split('#!')[1].split('?')[0];
    //     console.log(recordId);
    //     component.set('v.recordId', recordId);
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

    var action = component.get("c.getRecordTypeName");
    action.setParams({
      i: component.get("v.recordId")
    });

    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        component.set("v.recordTypeName", response.getReturnValue());
        //console.log(response.getReturnValue());
        //console.log(component.get('v.recordTypeName'));

        //console.log(component.get('v.user'));

        component.set("v.ready", true);
      } else if (state === "ERROR") {
        console.log("error");
      }
    });

    var action1 = component.get("c.getUser");
    action1.setStorable();
    action1.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.user", JSON.parse(response.getReturnValue()));
        $A.enqueueAction(action);
      } else {
        console.log("error");
        console.log(response);
      }
    });
    $A.enqueueAction(action1);
  }
});