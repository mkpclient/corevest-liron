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
    helper.queryFundings(component);
  }
});