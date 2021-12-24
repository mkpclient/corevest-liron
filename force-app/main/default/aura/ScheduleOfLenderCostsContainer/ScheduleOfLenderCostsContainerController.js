({
  init: function (component, event, helper) {},

  generatePDF: function (component, event, helper) {
    console.log("generate pdf");

    let action = component.get("c.getPDFContent");

    let loanVersion = event.getParams();

    let versionId = loanVersion.Id;
    console.log(versionId);

    action.setParams({ loanVersionId: versionId });

    action.setCallback(this, (response) => {
      let state = response.getState();

      if (state === "SUCCESS") {
        const linkSource = `data:application/pdf;base64,${response.getReturnValue()}`;
        const downloadLink = document.createElement("a");
        document.body.appendChild(downloadLink);

        downloadLink.href = linkSource;
        downloadLink.target = "_self";
        downloadLink.download = loanVersion.Full_Name__c + ".pdf";
        downloadLink.click();
      } else {
        console.log(response.getError());
      }
    });

    $A.enqueueAction(action);
  },

  initEmail: function (component, event, helper) {
    console.log("init email");
    let defaults = event.getParams();
    // console.log(defaults);

    component.find("emailComposer").openModal(defaults);
  }
});