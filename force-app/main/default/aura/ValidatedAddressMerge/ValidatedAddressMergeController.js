({
  init: function (component, event, helper) {
    console.log("init");

    let action = component.get("c.initMergeScreen");

    action.setParams({
      recordId: component.get("v.recordId")
    });

    action.setCallback(this, (response) => {
      let state = response.getState();

      if (state === "SUCCESS") {
        let merges = response.getReturnValue();
        //console.log("--merges--");
        //console.log(merges);

        let wrappers = [];

        for (let merge of merges) {
          merge[0].checked = true;
          wrappers.push({
            merges: merge,
            checked: false
          });
        }

        //console.log(wrappers);

        console.log("---wrappers--");
        console.log(wrappers);

        component.set("v.wrappers", wrappers);

        //$A.util.toggleClass(component.find("spinner"), "slds-hide");
        $A.util.addClass(component.find("spinner"), "slds-hide");
      } else if (state === "ERROR") {
        console.log("--error--");

        console.log(response.getError());
      }
    });

    $A.enqueueAction(action);
  },

  revalidate: function (component, event, helper) {
    $A.util.toggleClass(component.find("spinner"), "slds-hide");
    component.find("merge").set("v.disabled", true);
    component.find("revalidate").set("v.disabled", true);

    let propertyIds = [];
    let wrappers = component
      .get("v.wrappers")
      .filter((merge) => merge.rerunChecked);

    wrappers.forEach((wrapper) => {
      if (
        propertyIds.length == 0 ||
        propertyIds[propertyIds.length - 1].length == 50
      ) {
        propertyIds.push([]);
      }

      propertyIds[propertyIds.length - 1].push(wrapper.merges[0].propertyId);
    });

    console.log(propertyIds);

    if (propertyIds.length > 0) {
      propertyIds.reduce((promise, prop, index) => {
        return promise.then(
          $A.getCallback(() => {
            return helper.singleSmartyStreetsCall(component, prop).then(
              $A.getCallback((res) => {
                //console.log('done in promise');
                //component.set("v.properties", res.properties);
                //component.set("v.tableData", this.getTableData(component));
                if (index == propertyIds.length - 1) {
                  //this.hideSpinner(component);
                  //this.showToast('success', 'Properties successfully updated!');
                  $A.enqueueAction(component.get("c.init"));
                  $A.util.toggleClass(component.find("spinner"), "slds-hide");

                  component.find("merge").set("v.disabled", false);
                  component.find("revalidate").set("v.disabled", false);
                } else if (index == propertyIds.length - 1) {
                  //  this.hideSpinner(component);
                  //  let errorMsg = 'An error occured on one or more properties.';
                  //  for (let msg of errorMsgs) {
                  //    errorMsg += '\n' + msg;
                  //  }
                  //  this.showToast('error', errorMsg);
                  $A.enqueueAction(component.get("c.init"));
                  $A.util.toggleClass(component.find("spinner"), "slds-hide");

                  component.find("merge").set("v.disabled", false);
                  component.find("revalidate").set("v.disabled", false);
                }
              }),
              $A.getCallback((error) => {
                //console.log('error in promise');
                //isError = true;
                //errorMsgs.push(prop.Name + ': ' + error.message);
                if (index == propertyIds.length - 1) {
                  $A.enqueueAction(component.get("c.init"));
                  $A.util.toggleClass(component.find("spinner"), "slds-hide");

                  component.find("merge").set("v.disabled", false);
                  component.find("revalidate").set("v.disabled", false);
                }
              })
            );
          })
        );
      }, Promise.resolve());
    } else {
      // $A.enqueueAction(component.get("c.init"));
      $A.util.toggleClass(component.find("spinner"), "slds-hide");
      component.find("merge").set("v.disabled", false);
      component.find("revalidate").set("v.disabled", false);
    }
  },

  merge: function (component, event, helper) {
    $A.util.toggleClass(component.find("spinner"), "slds-hide");
    component.find("merge").set("v.disabled", true);
    component.find("revalidate").set("v.disabled", true);
    let properties = [];
    let wrappers = component.get("v.wrappers").filter((merge) => merge.checked);

    //console.log(wrappers);

    wrappers.forEach((wrapper) => {
      let propertyId = wrapper.merges[0].propertyId;
      // console.log(propertyId);

      // console.log(component.find(propertyId));

      wrapper.merges.forEach((merge) => {
        //console.log(merge.checked);

        if (merge.checked) {
          let property = { sobjectType: "Property__c", Id: merge.propertyId };
          merge.fields.forEach((field) => {
            if ($A.util.isUndefinedOrNull(field.validatedAddressValue)) {
              property[field.propertyAPIFieldName] = null;
            } else if (
              field.propertyFieldType != field.validatedAddressFieldType
            ) {
              if (field.validatedAddressFieldType == "BOOLEAN") {
                property[
                  field.propertyAPIFieldName
                ] = field.validatedAddressValue ? "Yes" : "No";

                property[field.propertyAPIFieldName];
              } else if (
                field.validatedAddressFieldType == "DOUBLE" &&
                field.propertyFieldType == "STRING"
              ) {
                property[field.propertyAPIFieldName] =
                  field.validatedAddressValue + "";
              } else {
                property[field.propertyAPIFieldName] =
                  field.validatedAddressValue;
              }
            } else {
              property[field.propertyAPIFieldName] =
                field.validatedAddressValue;

              // if (field.propertyAPIFieldName == "Appraised_Value_Amount__c") {
              //   property["BPO_validatedAddress_Value__c"] = field.validatedAddressValue;
              // }
            }
          });
          // property.validatedAddress_Uploaded__c = true;

          // if (property.validatedAddress_Form__c == "FNM1004D") {
          //   var mergeProperty = {
          //     sobjectType: "Property__c",
          //     Id: property.Id,
          //     validatedAddress_Uploaded__c: true,
          //     BPO_validatedAddress_Date__c: property.BPO_validatedAddress_Date__c,
          //     Appraised_Value_Amount__c: property.Appraised_Value_Amount__c
          //   };

          //   property = mergeProperty;
          // }

          properties.push(property);
        }
      });
    });

    console.log(properties);

    if (properties.length > 0) {
      component.find("util").upsert(
        properties,
        $A.getCallback((result) => {
          $A.enqueueAction(component.get("c.init"));
          component.find("merge").set("v.disabled", false);
          component.find("revalidate").set("v.disabled", false);
        }),
        $A.getCallback((error) => {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Error",
            message: error[0].message,
            duration: " 5000",
            type: "error",
            mode: "sticky"
          });
          toastEvent.fire();
          component.find("merge").set("v.disabled", false);
          component.find("revalidate").set("v.disabled", false);
          $A.util.toggleClass(component.find("spinner"), "slds-hide");
        })
      );
    } else {
      $A.util.toggleClass(component.find("spinner"), "slds-hide");
      component.find("merge").set("v.disabled", false);
    }

    // let action = component.get('c.mergevalidatedAddresss');

    // action.setParams({
    // 	merges: merges
    // })

    // action.setCallback(this, function(response){
    // 	let state = response.getState();

    // 	if(state === 'SUCCESS'){
    // 		console.log(JSON.parse(response.getReturnValue()));
    // 	}else if(state === 'ERROR'){
    // 		console.log(response.getError());
    // 	}
    // });

    // if(merges.length > 0){
    // 	$A.enqueueAction(action);
    // }
  },

  radioChanged: function (component, event, helper) {
    console.log(event.getSource());
    let radio = event.getSource();
    let propertyId = radio.get("v.name");
    let validatedAddressId = radio.get("v.title");

    console.log(propertyId);
    console.log(validatedAddressId);

    let wrappers = component.get("v.wrappers");
    wrappers.forEach((wrapper) => {
      if (wrapper.merges[0].propertyId == propertyId) {
        wrapper.merges.forEach((merge) => {
          if (merge.validatedAddressId == validatedAddressId) {
            merge.checked = true;
          } else {
            merge.checked = false;
          }
        });
      }
    });

    component.set("v.wrappers", wrappers);
  },

  checkAll: function (component, event, helper) {
    console.log("checked");
    let checkbox = event.getSource();
    let checked = checkbox.get("v.checked");

    let wrappers = component.get("v.wrappers");
    wrappers.forEach((wrapper) => {
      if (!wrapper.merges[0].isEmpty) {
        wrapper.checked = checked;
      } else if (wrapper.merges[0].isEmpty) {
        wrapper.rerunChecked = checked;
      }
    });

    component.set("v.wrappers", wrappers);
  },
  export: function (component, event, helper) {
    let recordId = component.get("v.recordId");
    //let reportUrl =

    let wrappers = component.get("v.wrappers");
    console.log(wrappers);

    let validatedAddresss = [];
    wrappers.forEach((wrapper) => {
      let forms = new Set();
      wrapper.merges.forEach((merge) => {
        let formId = merge.formId ? merge.formId : "";
        let validatedAddress = {
          Id: merge.validatedAddressId,
          sobjectType: "validatedAddress__c",
          Include_In_Report__c: false
        };
        if (!forms.has(formId)) {
          validatedAddress.Include_In_Report__c = true;
          forms.add(formId);
        }

        validatedAddresss.push(validatedAddress);
      });
    });

    console.log(validatedAddresss);

    if (!$A.util.isEmpty(validatedAddresss)) {
      component.find("util").upsert(validatedAddresss, (response) => {
        let reportUrl =
          "/lightning/r/Report/00O0a000005KMpYEAW/view?fv0=" + recordId;
        window.open(reportUrl);
      });
    }
  }
});