({
  checkPermission: function (component) {
    // const action = component.get("c.userHasPermission");

    // action.setParams({ permissionSetName: "" });

    // action.setCallback(this, (response) => {
    //   const state = response.getState();
    //   if (state === "SUCCESS") {
    //     console.log(response.getReturnValue());
    //     component.set("v.hasDeletePermission", response.getReturnValue());
    //   } else if (state === "ERROR") {
    //     console.log("permission error");
    //     console.log(response.getError());
    //   }
    // });

    // $A.enqueueAction(action);
    let fields = ["Name"];

    component
      .find("util")
      .getPermissions("Appraisal__c", fields, (response) => {
        console.log("--apraisal perm map--");
        console.log(response);

        component.set("v.appraisalPermissionsMap", response);
      });

      component
      .find("util")
      .getPermissions("Property__c", fields, (response) => {
        console.log("--apraisal perm map--");
        console.log(response);

        component.set("v.propertyPermissionsMap", response);
      });
  }
  

  // checkProfile: function (component) {
  //   const action = component.get("c.getUser");

  //   action.setCallba`c`k(this, (response) => {
  //     const state = response.getState();
  //     if (state === "SUCCESS") {
  //       console.log(response.getReturnValue());
  //       component.set("v.profileName", response.getReturnValue().Profile.Name);
  //     } else if (state === "ERROR") {
  //       console.log("permission error");
  //       console.log(response.getError());
  //     }
  //   });

  //   $A.enqueueAction(action);
  // }
});