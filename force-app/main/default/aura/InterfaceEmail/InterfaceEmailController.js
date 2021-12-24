({
  init: function(component, event, helper) {
    console.log("changed 2!!!!!!!!!!");
    let recordId = component.get("v.recordId");
    console.log("this is our record id");
    console.log(recordId);
    component.set("v.submitting", true);
    let action = component.get("c.returnDeal");
    action.setParams({ recordId: recordId });
    action.setCallback(this, function(response) {
      var state = response.getState();
      component.set("v.submitting", false);
      if (state === "SUCCESS") {
        var returnVal = JSON.parse(response.getReturnValue());
        console.log(returnVal);
        if (returnVal.Error && returnVal.Error.length > 0) {
          console.log("no emailing here!");
          helper.toggleHide(component, "notAllowed");
        } else if (
          returnVal.TermSheetError &&
          returnVal.TermSheetError.length > 0
        ) {
          helper.toggleHide(component, "noTermSheet");

          // } else if (returnVal.OwnerError && returnVal.OwnerError.length > 0){
          // 	helper.toggleHide(component, 'originator');
        } else if (
          returnVal.ValidationError &&
          returnVal.ValidationError.length > 0
        ) {
          helper.toggleHide(component, "validationError");
        } else {
          // let attachments = returnVal.Attachments.slice();
          let contentVersions = returnVal.ContentVersions;
          var newArr = contentVersions.map(function(el) {
            return {
              Id: el.Id,
              Name: el.PathOnClient,
              Type: "ContentVersion",
              Description: el.Description
            };
          });
          console.log("this is newArr");
          console.log(newArr);
          component.set("v.possibleAttachments", newArr);

          let recipients = returnVal.Recipients;
          // let cc = returnVal.CC[0];
          let user = returnVal.CurrentUser[0];
          let emailBody = returnVal.EmailContents[0];
          // emailBody += '<img src="https://www.blog.google/static/blog/images/google-200x200.7714256da16f.png" />';
          let subject = returnVal.Subject[0];
          let cc = returnVal.CC.join("; ");
          console.log(returnVal);
          console.log(cc);

          if (user) {
            component.set("v.user", user);
          }

          // contentVersions.forEach((el, idx) => {
          // 	attachments.push({
          // 		Id: el.Id,
          // 		Name: el.PathOnClient,
          // 		Type: 'ContentVersion'
          // 	});
          // 	if (idx === contentVersions.length - 1){
          // 		component.set('v.possibleAttachments', attachments);
          // 	}
          // });
          component.set("v.recipients", recipients);
          component.set("v.ccText", cc);
          component.set("v.emailSubject", subject);
          component.set("v.emailMessage", emailBody);
          helper.toggleHide(component, "allowed");
          // helper.toggleHide(component, "submitButton");
          console.log("????");
        }
      } else {
        console.log(response.getError());
      }
    });
    $A.enqueueAction(action);
  },

  submitEmail: function(component, event, helper) {
    //component.find("submitButton").set("v.disabled", true);
    component.set("v.submitting", true);
    $A.util.addClass(component.find("termsheetError"), "slds-hide");
    console.log("ok");
    var currentUser = component.get("v.user.Email");
    // var selectedRecipients = component.get('v.selectedRecipients');
    var recordId = component.get("v.recordId");
    var selectedAttachments = component.get("v.selectedAttachments");
    var emailSubject = component.get("v.emailSubject");
    var emailMessage = component.get("v.emailMessage");
    var recipients = component.get("v.recipients").join(";");
    console.log("these are the recipients");
    console.log(recipients);
    var emailObj = {
      currentUser: currentUser,
      recordId: recordId,
      emailSubject: emailSubject,
      emailMessage: emailMessage,
      recipients: recipients,
      ccUsers: component.get("v.ccText")
    };

    var ccText = component.get("v.ccText");
    console.log("this is the searchTerm");
    console.log(ccText);

    if (ccText) {
      emailObj.selectedCC = ccText;
    }

    var attachIds = [];
    var cvIds = [];

    let hasTermSheet = false;

    for (let i = 0; i < selectedAttachments.length; i++) {
      if (selectedAttachments[i].Description == "Termsheet") {
        hasTermSheet = true;
      }

      if (selectedAttachments[i].Type === "ContentVersion") {
        cvIds.push(selectedAttachments[i].Id);
      } else if (selectedAttachments[i].Type === "Attachment") {
        attachIds.push(selectedAttachments[i].Id);
      }
    }

    console.log("attachIds " + attachIds);
    console.log("cvIds " + cvIds);

    let action = component.get("c.sendEmail");
    action.setParams({
      s: JSON.stringify(emailObj),
      attachIds: JSON.stringify(attachIds),
      cvIds: JSON.stringify(cvIds)
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.submitted", "SUCCESS");
        console.log("success");
      } else {
        console.log(response.getError());
        component.set("v.submitted", "ERROR");
        console.log("error");
      }
      component.set("v.submitting", false);
    });

    if (hasTermSheet) {
      $A.enqueueAction(action);
    } else {
      // var toastEvent = $A.get("e.force:showToast");
      // toastEvent.setParams({
      //   title: "Missing Termsheet",
      //   message: "Please attach a Termsheet to the deal",
      //   mode: "sticky",
      //   type: "error"
      // });
      // toastEvent.fire();
      $A.util.removeClass(component.find("termsheetError"), "slds-hide");
      //component.find("submitButton").set("v.disabled", false);
      component.set("v.submitting", false);
    }

    //
  },

  closeWindow: function(component, event, helper) {
    $A.get("e.force:closeQuickAction").fire();
  }
});