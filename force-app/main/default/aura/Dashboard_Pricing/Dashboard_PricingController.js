({
  init: function (component, event, helper) {
    console.log("init start");
    let action = component.get("c.returnApprovals");
    action.setCallback(this, function (response) {
      let state = response.getState();
      if (state === "SUCCESS") {
        let returnVal = JSON.parse(response.getReturnValue());
        console.log(returnVal);
        let approvals = returnVal.ahWrappers;
        let uId = returnVal.userId;

        approvals.sort(function (a, b) {
          return Date.parse(b.lmd) - Date.parse(a.lmd);
        });
        console.log(approvals);
        component.set("v.allApprovals", approvals);
        component.set("v.approvals", approvals.slice(0, 6));

        // component.set('v.approvals', returnVal.ahWrappers);
        // let userId = returnVal.userId;
        // let pList = returnVal.pList.slice();
        //
        // pList.forEach(function(el){
        // 	if (el.Workitems && el.Workitems.records.length > 0){
        // 		el.Steps.records.forEach(function(step,idx){
        // 			if (el.Workitems.records[idx]
        // 				// && el.Workitems.records[idx].ActorId === userId
        // 			){
        // 				step.screenLink = el.Workitems.records[idx].Id;
        // 			}
        // 		});
        // 	}
        // });
        // component.set('v.approvals', pList);
      } else {
        console.log(response.getError());
      }
    });
    $A.enqueueAction(action);
  },

  showMore: function (component, event, helper) {
    console.log(component.get("v.hideOption"));
    if (component.get("v.hideOption") == "Less") {
      component.set("v.hideOption", "More");
      component.set("v.approvals", component.get("v.allApprovals").slice(0, 6));
    } else if (component.get("v.hideOption") == "More") {
      component.set("v.hideOption", "Less");
      component.set("v.approvals", component.get("v.allApprovals"));
    }

    console.log("click all");
  },

  showApproval: function (component, event, helper) {
    console.log(event.target.tagName);
    var tagName = event.target.tagName;
    var classList = event.target.classList;
    if (tagName == "BUTTON") {
      var element = event.target.nextElementSibling;
      var image = event.target.firstElementChild;
    } else if (tagName == "SPAN") {
      var element = event.target.parentElement.nextElementSibling;
      var image = event.target;
    } else if (tagName == "DIV") {
      console.log(event.target);
      var element = event.target.parentElement.nextElementSibling;
      var image = event.target.parentElement.firstElementChild;
    }

    console.log(element);
    console.log(image);
    // let el = event.target.nextElementSibling;
    // console.log(el);
    if (element.getAttribute("data-state") === "hidden") {
      element.classList.remove("hide");
      element.setAttribute("data-state", "shown");
      image.innerHTML = "-";
    } else if (element.getAttribute("data-state") === "shown") {
      element.classList.add("hide");
      element.setAttribute("data-state", "hidden");
      image.innerHTML = "+";
    }
  }
});