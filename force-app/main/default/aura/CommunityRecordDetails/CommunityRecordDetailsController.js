({
  init: function (component, event, helper) {
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

    // if (!$A.util.isEmpty(url)) {
    //   var recordId = location.hash.split("#!")[1].split("?")[0];
    //   console.log(recordId);
    //   component.set("v.recordId", recordId);
    // }

    var action = component.get("c.getCommunityDetails");

    action.setStorable();
    action.setParams({ recordId: component.get("v.recordId") });

    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        console.log(response.getReturnValue());

        if (!$A.util.isEmpty(response.getReturnValue())) {
          let layout = response.getReturnValue();

          layout.sections.forEach((section) => {
            let maxRows = Math.max(
              section.columns[0].fields.length,
              section.columns[1].fields.length
            );
            let rows = [];
            for (let i = 0; i < maxRows; i++) {
              let row = [];
              if (!$A.util.isEmpty(section.columns[0].fields[i])) {
                row.push(section.columns[0].fields[i]);
              } else {
                row.push({});
              }

              if (!$A.util.isEmpty(section.columns[1].fields[i])) {
                row.push(section.columns[1].fields[i]);
              } else {
                row.push({});
              }

              rows.push(row);
            }

            section.rows = rows;
          });

          console.log(layout);

          component.set("v.layout", layout);
        }
      } else if (state === "ERROR") {
        console.log(response.getError());
      }
    });

    $A.enqueueAction(action);
  }
});