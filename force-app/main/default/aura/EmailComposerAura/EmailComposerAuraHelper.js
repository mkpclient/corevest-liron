({
  fileColumns: [
    { label: "Title", fieldName: "Title" },
    { label: "Type", fieldName: "FileExtension" }
  ],

  selectedFileColumns: [
    { label: "Title", fieldName: "Title" },
    { label: "Type", fieldName: "FileExtension" },
    {
      type: "action",
      typeAttributes: {
        rowActions: [{ label: "Remove", name: "remove" }]
      }
    }
  ],

  setEmailOptions: function (component, event, helper) {
    let action = component.get("c.GetUserEmailAddress");

    action.setCallback(this, (response) => {
      let state = response.getState();

      if (state === "SUCCESS") {
        let val = response.getReturnValue();
        console.log(val);

        component.set("v.emailOptions", [{ label: val, value: val }]);
        component.set("v.from", val);
      } else if (state === "ERROR") {
      }
    });

    $A.enqueueAction(action);
  },

  setFiles: function (component, filter) {
    var action = component.get("c.queryFilesOnDeal");

    component.set("v.fileColumns", this.fileColumns);
    component.set("v.selectedFileColumns", this.selectedFileColumns);
    action.setParams({ recordId: component.get("v.recordId") });

    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        let files = JSON.parse(response.getReturnValue());
        component.set("v.files", files);
        //component.set("v.displayedFiles", files.slice(0, pageSize));
        console.log(component.get("v.files"));
      } else if (state === "ERROR") {
        console.log("error");
        console.log(response.getError());
      }
    });

    $A.enqueueAction(action);
  }
});