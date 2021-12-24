({
  callAction: function (
    component,
    actionName,
    params,
    successCallback,
    failureCallback
  ) {
    //this.showSpinner( component );

    var action = component.get(actionName);

    if (params) {
      action.setParams(params);
    }

    action.setCallback(this, function (response) {
      //this.hideSpinner( component );

      if (component.isValid() && response.getState() === "SUCCESS") {
        if (successCallback) {
          successCallback(response.getReturnValue());
        }
      } else {
        console.error(
          'Error calling action "' +
            actionName +
            '" with state: ' +
            response.getState()
        );

        if (failureCallback) {
          failureCallback(response.getError(), response.getState());
        } else {
          this.logActionErrors(component, response.getError());
        }
      }
    });

    $A.enqueueAction(action);
  },

  logActionErrors: function (component, errors) {
    if (errors) {
      for (var index in errors) {
        console.error("Error: " + errors[index].message);
      }
    } else {
      console.error("Unknown error");
    }
  },

  base64ToArrayBuffer: function (base64) {
    var binary_string = window.atob(base64);
    var len = binary_string.length;
    var bytes = new Uint8Array(len);
    // console.log(binary_string);
    console.log(len);
    for (var i = 0; i < len; i++) {
      bytes[i] = binary_string.charCodeAt(i);
    }
    return bytes.buffer;
  },

  serverSideCall: function (action, component) {
    return new Promise(function (resolve, reject) {
      action.setCallback(this, function (response) {
        var state = response.getState();
        console.log(state);
        console.log(component.isValid());
        console.log(response.getError());
        if (component.isValid() && state === "SUCCESS") {
          resolve(response.getReturnValue());
        } else if (component.isValid() && state === "ERROR") {
          reject(new Error(response.getError()));
        }
      });
      $A.enqueueAction(action);
    });
  },

  setPermission: function (component) {
    const action = component.get("c.userHasPermission");

    action.setParams({ permissionSetName: "Add_Properties_to_Matured_Deal" });

    action.setCallback(this, (response) => {
      const state = response.getState();

      if (state === "SUCCESS") {
        component.set("v.hasMaturedPermission", response.getReturnValue());
      } else if (state === "ERROR") {
        console.log("-error-");
        console.log(response.getError());
      }
    });

    $A.enqueueAction(action);
  },

  setDealStatus: function (component) {
    const action = component.get("c.getRecord");
    action.setParams({ i: component.get("v.recordId") });

    action.setCallback(this, (response) => {
      const state = response.getState();
      if (state === "SUCCESS") {
        console.log("--");
        console.log(JSON.parse(response.getReturnValue()));
        component.set(
          "v.dealStatus",
          JSON.parse(response.getReturnValue()).StageName
        );
      } else if (state === "ERROR") {
        console.log("--error--");
        console.log(response.getError());
      }
    });

    $A.enqueueAction(action);
  },

  getUserProfile: function (component) {
    const action = component.get("c.getUser");

    action.setCallback(this, (response) => {
      const state = response.getState();
      if (state === "SUCCESS") {
        // component.set("v.profileName", response.getReturnValue().Profile.Name);
      } else if (state === "ERROR") {
        console.log("--error--");
        console.log(response.getError());
      }
    });

    $A.enqueueAction(action);
  }
});