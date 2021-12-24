({
  selectAttachment: function(component, event, helper) {
    console.log("click select Attachment");
    var selectedAttachments = component.get("v.selectedAttachments");
    var state = event.target.getAttribute("data-state");
    var recordId = event.target.getAttribute("data-recordid");
    var recordName = event.target.getAttribute("data-record");
    var recordType = event.target.getAttribute("data-type") || "Attachment";
    var description = event.target.getAttribute("data-description") || "";
    console.log(event.target.getAttribute("data-state"));

    if (state === "unselected") {
      // console.log('inside not originally selected ')
      selectedAttachments.push({
        Id: recordId,
        Name: recordName,
        Type: recordType,
        Description: description
      });
      event.target.setAttribute("data-state", "selected");
    } else if (state === "selected") {
      for (let i = 0; i < selectedAttachments.length; i++) {
        if (selectedAttachments[i].Id === recordId) {
          selectedAttachments.splice(i, 1);
          break;
        }
      }
      component.set("v.selectedAttachments", selectedAttachments);
      event.target.setAttribute("data-state", "unselected");
    }
    console.log(event.target.getAttribute("data-state"));
    console.log(selectedAttachments);
  }
});