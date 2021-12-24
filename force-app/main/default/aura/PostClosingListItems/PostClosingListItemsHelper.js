({
  queryItemPicklists: function (component, sectionId) {
    let queryString = `SELECT Id, Post_Close_Setting__c, Post_Closing_Criteria__c, Post_Closing_Item_Per_County__c, Post_Closing_Required__c, `;
    queryString += `Post_Closing_sObjectType__c, Post_Closing_Sort__c, Post_Closing_Trigger__c, Document_Type__c `;
    queryString += `FROM Document_Structure__mdt WHERE Post_Close_Setting__c = '${sectionId}'`;

    component.find("util").query(queryString, (results) => {
      console.log(results);
      //
      const documentStructureMap = {};
      const documentStructureOptions = [];

      results.forEach((docStructure) => {
        documentStructureMap[docStructure.Id] = docStructure;
        documentStructureOptions.push({
          label: docStructure.Document_Type__c,
          value: docStructure.Id
        });
      });

      component.set("v.docStructureMap", documentStructureMap);
      component.set(
        "v.docStructureOptions",
        [{ label: "", value: "" }].concat(documentStructureOptions)
      );
    });
  },

  handleActive: function (component, event, helper) {
    let tab = event.getSource();
    component.set("v.selectedTabId", tab.get("v.Id"));
  }
});