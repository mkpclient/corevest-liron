({
  searchDocuments: function(component, helper) {
    var option = component.find("option").get("v.value");
    var searchText = component.find("search").get("v.value");

    var whereClause = "";

    var recordId = "";

    component.set("v.sobjectType", option);

    if (!$A.util.isEmpty(searchText)) {
      whereClause += " Name LIKE '%" + searchText + "%' OR Deal_Loan_Number__c LIKE '%" + searchText + "%' OR Servicer_Commitment_Id__c LIKE '%" + searchText + "%'";
    }

    var user = component.get("v.user");

    var action;
    var fieldList = [];
    if (option == "Deal") {
      fieldList = [
        "Id",
        "Name",
        "Deal_Loan_Number__c",
        "Servicer_Commitment_Id__c",
        "StageName",
        "Loan_Size__c",
        "Anticipated_Closing_Date__c",
        "RecordType.Name"
      ];

      // if(user.userType == 'borrower'){
      //     action = component.get('c.getBorrowerDeals');

      // }else{
      //     action = component.get('c.getVendorDeals');
      // }

      action = component.get("c.getDeals");
    } else if (option == "Property") {
      fieldList = [
        "Id",
        "Name",
        "Deal_Loan_Number__c",
        "Parent_Property__c",
        "Parent_Property__r.Name",
        "City__c",
        "State__c"
      ];

      if (user.userType == "borrower") {
        recordId = component.get("v.user").contactId;
      } else {
        recordId = component.get("v.user").accountId;
      }

      if (!$A.util.isEmpty(searchText)) {
        whereClause += " OR Deal__r.Name LIKE '%" + searchText + "%' OR Deal__r.Deal_Loan_Number__c LIKE '%" + searchText + "%' OR Deal__r.Servicer_Commitment_Id__c LIKE '%" + searchText + "%'";
      }

      //console.log(whereClause);

      action = component.get("c.getProperties");
    }

    action.setParams({
      accountId: component.get("v.user").accountId,
      contactId: component.get("v.user").contactId,
      fields: fieldList,
      whereClause: whereClause,
      userType: component.get("v.user").userType
    });

    action.setCallback(this, function(response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        console.log("success");
        component.set("v.data", JSON.parse(response.getReturnValue()));
        console.log(component.get("v.data"));
      } else {
        console.log(response.getError());
      }
    });

    $A.enqueueAction(action);
  }
});