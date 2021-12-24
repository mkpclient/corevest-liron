({
  callAction: function (
    component,
    actionName,
    params,
    successCallback,
    failureCallback
  ) {
    console.log(actionName);

    var action = component.get(actionName);

    if (params) {
      action.setParams(params);
    }

    action.setCallback(this, function (response) {
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

  callActionPromise: function (component, actionName, params) {
    var action = component.get(actionName);
    action.setParams(params);

    return new Promise(function (resolve, reject) {
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (component.isValid() && state === "SUCCESS") {
          resolve(response.getReturnValue());
        } else if (component.isValid() && state === "ERROR") {
          reject(new Error(response.getError()));
        }
      });
      $A.enqueueAction(action);
    });
  }
});