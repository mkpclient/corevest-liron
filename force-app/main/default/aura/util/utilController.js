({
  queryDatabase: function (component, event, helper) {
    var params = event.getParam("arguments");
    console.log(params.queryString);
    if (params) {
      helper.callAction(
        component,
        "c.query",
        params,
        params.callback,
        params.failureCallback
      );
    }
  },

  queryDatabasePromise: function (component, event, helper) {
    var params = event.getParam("arguments");

    if (params) {
      return helper.callActionPromise(component, "c.query", params);
    }
  },

  queryDatabaseJSON: function (component, event, helper) {
    var params = event.getParam("arguments");

    if (params) {
      helper.callAction(
        component,
        "c.queryJSON",
        params,
        params.callback,
        params.failureCallback
      );
    }
  },

  upsertRecs: function (component, event, helper) {
    var params = event.getParam("arguments");

    if (params) {
      if (!$A.util.isArray(params.records)) {
        params.records = [params.records];
      }

      helper.callAction(
        component,
        "c.upsertRecords",
        params,
        params.callback,
        params.failureCallback
      );
    }
  },

  deleteRecs: function (component, event, helper) {
    var params = event.getParam("arguments");

    if (!$A.util.isArray(params.records)) {
      params.records = [params.records];
    }

    if (params) {
      helper.callAction(
        component,
        "c.deleteRecords",
        params,
        params.callback,
        params.failureCallback
      );
    }
  },

  queryRecs: function (component, event, helper) {
    var params = event.getParam("arguments");

    if (params) {
      helper.callAction(
        component,
        "c.queryRecords",
        params,
        params.callback,
        params.failureCallback
      );
    }
  },

  queryUserId: function (component, event, helper) {
    var params = event.getParam("arguments");

    if (params) {
      helper.callAction(
        component,
        "c.getUserId",
        params,
        params.callback,
        params.failureCallback
      );
    }
  },

  queryUserRecord: function (component, event, helper) {
    var params = event.getParam("arguments");

    if (params) {
      helper.callAction(
        component,
        "c.getUser",
        params,
        params.callback,
        params.failureCallback
      );
    }
  },

  getDependentPickists: function (component, event, helper) {
    var params = event.getParam("arguments");

    if (params) {
      helper.callAction(
        component,
        "c.GetDependentOptions",
        params,
        params.callback,
        params.failureCallback
      );
    }
  },

  insertFiles: function (component, event, helper) {
    var params = event.getParam("arguments");
    console.log(params);
    if (params) {
      helper.callAction(
        component,
        "c.insertFileAndLink",
        params,
        params.callback,
        params.failureCallback
      );
    }
  },
  queryPicklist: function (component, event, helper) {
    var params = event.getParam("arguments");

    if (params) {
      helper.callAction(
        component,
        "c.getPicklistValues",
        params,
        params.callback,
        params.failureCallback
      );
    }
  },

  getFileStaticResource: function (component, event, helper) {
    var params = event.getParam("arguments");
    if (params) {
      return helper.callActionPromise(
        component,
        "c.getFileFromStaticResource",
        params
      );
    }
  },

  queryPermissions: function (component, event, helper) {
    var params = event.getParam("arguments");

    if (params) {
      helper.callAction(
        component,
        "c.compileFieldPermissions",
        params,
        params.callback,
        params.failureCallback
      );
    }
  }
});