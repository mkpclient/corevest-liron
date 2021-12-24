({
  init: function (component, event, helper) {
    helper.initHelper(component, event, helper, false);
  },

  refresh: function (component, event, helper) {
    helper.initHelper(component, event, helper, true);
  }
});