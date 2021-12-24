({
  init: function (component, event, helper) {
    console.log("email init");
    let params = event.getParam("arguments");

    //console.log(params);
    console.log(JSON.parse(JSON.stringify(params.defaults)));

    // component.set("v.body", params.defaults.htmlBody);
    component.set("v.subject", params.defaults.subject);
    component.set("v.emailOpen", true);

    component.find("composer").set("v.body", params.defaults.htmlBody);

    $A.util.addClass(component.find("modal"), "slds-fade-in-open");
    $A.util.addClass(component.find("backdrop"), "slds-backdrop_open");
  },

  closeModal: function (component, event, helper) {
    $A.util.removeClass(component.find("modal"), "slds-fade-in-open");
    $A.util.removeClass(component.find("backdrop"), "slds-backdrop_open");
  },

  send: function (component, event, helper) {
    console.log("send email");

    component.find("composer").send((response) => {
      $A.util.removeClass(component.find("modal"), "slds-fade-in-open");
      $A.util.removeClass(component.find("backdrop"), "slds-backdrop_open");
    });
  }
});