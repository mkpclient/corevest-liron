({
  init: function(component, event, helper) {
    // let recordId = component.get('v.recordId');
    // console.log('this is the recordId');
    // console.log(recordId);
    // let action = component.get('c.returnAttachments');
    // action.setParams({recordId: recordId});
    // action.setCallback(this, function(response){
    // 	let state = response.getState();
    // 	if (state === 'SUCCESS'){

    // 		console.log('--approval process attachments--');
    // 		console.log(JSON.parse(response.getReturnValue()));

    // 		let returnVal = JSON.parse(response.getReturnValue());
    // 		let attachments = returnVal.Attachments;
    // 		let contentVersions = returnVal.ContentVersions;
    // 		component.set('v.properties', returnVal.Properties);
    // 		console.log(returnVal);
    // 		if (!attachments) attachments = [];
    // 		if (contentVersions){
    // 			contentVersions.forEach(function(el){
    // 				attachments.push({
    // 					Id: el.Id,
    // 					Name: el.PathOnClient
    // 				});
    // 			});
    // 		}
    // 		component.set('v.attachments', attachments);
    // 		console.log('attachment comp done');
    // 	} else {
    // 		console.log(response.getError());
    // 	}
    // });
    // $A.enqueueAction(action);

    var processId = component.get("v.recordId");

    var queryString =
      "SELECT ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.RecordType.DeveloperName  FROM ProcessInstanceWorkItem WHERE Id = '" +
      processId +
      "' LIMIT 1";

    component.find("util").query(queryString, function(piwi) {
      console.log(piwi);

      if (!$A.util.isEmpty(piwi)) {
        var oppId = piwi[0].ProcessInstance.TargetObjectId;
        var recordType =
          piwi[0].ProcessInstance.TargetObject.RecordType.DeveloperName;
        console.log(recordType);

        console.log(oppId);

        var docQueryString =
          "SELECT Id, File_Name__c,ContentVersion_Id__c, Document_Type__c, Attachment_Id__c, Added_On__c, Added_By__r.Name From Deal_Document__c WHERE Deal__c = '" +
          oppId +
          "'";

        var whereClause = "";

        if (recordType == "Term_Loan") {
          whereClause = component.get("v.termWhereClause");
        } else if (recordType == "LOC_Loan" || recordType.includes("Bridge")) {
          whereClause = component.get("v.bridgeWhereClause");
        }

        if (!$A.util.isEmpty(whereClause)) {
          docQueryString += " AND (" + whereClause + ")";
        }

        component.find("util").query(docQueryString, function(docs) {
          console.log(docs);
          component.set("v.files", docs);
        });
      }
    });
  },

  openDoc: function(component, event, helper) {
    var docId = event.target.getAttribute("data-title");
    console.log(docId);
    $A.get("e.lightning:openFiles").fire({
      recordIds: [docId]
    });
  }
});