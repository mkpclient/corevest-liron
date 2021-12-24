({
  validateInput: function(component, event, helper) {
    let valid = true;
    component.find("input").forEach(input => {
      //console.log('input');
      input.showHelpMessageIfInvalid();
      if (!input.get("v.validity").valid) {
        valid = false;
      }
    });
    
    component.set("v.valid", valid);
    return valid;
  }
});