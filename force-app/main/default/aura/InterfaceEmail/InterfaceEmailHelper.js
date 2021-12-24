({
  toggleHide: function(component, name) {
    $A.util.toggleClass(component.find(name), "slds-hide");
    console.log("--togle hide--", name);
  }
});