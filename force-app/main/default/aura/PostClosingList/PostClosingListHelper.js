({
  postCloseFields: [
    "Id",
    "Name",
    "Num_of_Items__c",
    "Num_of_Items_Completed__c",
    "Num_of_Item_Requiring_Follow_Up__c",
    "Num_of_Items_Requiring_Revision__c",
    "Percent_of_Items_Completed__c",
    "Perc_of_Items_Requiring_Follow_Up__c",
    "Perc_of_Items_Requiring_Revision__c",
    "Deal__c"
  ],

  postClosingSectionFields: [
    "Id",
    "Name",
    "Num_of_Items__c",
    "Num_of_Items_Completed__c",
    "Num_of_Item_Requiring_Follow_Up__c",
    "Num_of_Items_Requiring_Revision__c",
    "Percent_of_Items_Completed__c",
    "Perc_of_Items_Requiring_Follow_Up__c",
    "Perc_of_Items_Requiring_Revision__c",
    "Advance__c",
    "Post_Closing__c",
    "mdt_Id__c",
    "(Select Id, ActivityDate, Owner.Name, OwnerId, Subject, Status FROM Tasks)"
  ],

  postClosingItemFields: [
    "Id",
    "Comment__c",
    "Name",
    "Recorded__c",
    "Recorded_Document__c",
    "Required__c",
    "Uploaded__c",
    "Status__c",
    "Deal_Document__c",
    "Sort__c",
    "mdt_Id__c",
    "Contact__c",
    "Contact__r.Name",
    "Advance__c",
    "Business_Entity__c",
    "Business_Entity__r.Name",
    "Advance__r.Name",
    "Post_Closing_Section__r.Id",
    "Post_Closing_Section__r.Advance__r.Name",
    "County__c"
  ],

  dealDocFields: [
    "Id",
    "Reviewed__c",
    "Reviewed_On__c",
    "Post_Closing_Item__c",
    "Post_Closing_Item__r.Post_Closing_Section__c",
    "Attachment_Id__c"
  ],

  taskFields: [
    "Id",
    "ActivityDate",
    "Owner.Name",
    "OwnerId",
    "Subject",
    "Status",
    "RecordTypeId",
    "WhatId"
  ],

  compileDealIdQuery: function (advanceId) {
    let queryString = `SELECT Id, Deal__c `;
    queryString += ` FROM Advance__c WHERE Id = '${advanceId}'`;
    return queryString;
  },

  compileQueryString: function (dealId) {
    let queryString = `SELECT ${this.postCloseFields.join(", ")} `;
    queryString += ` FROM Post_Closing__c WHERE Deal__c = '${dealId}'`;
    return queryString;
  },

  compileSectionsQueryString: function (recordId, sobjectType) {
    let queryString = `SELECT ${this.postClosingSectionFields.join(", ")} `;

    queryString += `, (SELECT ${this.postClosingItemFields.join(", ")} `;
    queryString += ` FROM Post_Closing_Items__r ORDER BY Sort__c Desc, County__c ASC, Contact__c ASC, Business_Entity__c ASC)`;

    queryString += ` FROM Post_Closing_Section__c `;

    if (sobjectType == "Opportunity") {
      queryString += ` WHERE Post_Closing__r.Deal__c = '${recordId}'`;
    } else if (sobjectType === "Advance__c") {
      queryString += ` WHERE Advance__c = '${recordId}'`;
    }

    return queryString;
  },

  compileDealDocQueryString: function (recordId, sobjectType) {
    let queryString = `SELECT ${this.dealDocFields.join(", ")} `;

    //queryString += `, (SELECT ${this.postClosingItemFields.join(", ")} `;
    //queryString += ` FROM Post_Closing_Items__r ORDER BY Sort__c Desc)`;

    queryString += ` FROM Deal_Document__c WHERE Post_Closing_Item__c != null `;

    if (sobjectType === "Opportunity") {
      queryString += ` AND Deal__c = '${recordId}'`;
    } else if (sobjectType === "Advance__c") {
      queryString += ` AND Advance__c = '${recordId}'`;
    }

    // Deal__c = '${dealId}'`;

    return queryString;
  },

  compileTaskQueryString: function (itemIds) {
    // if(itemIds.length == 0)
    let limString = "";
    if (itemIds.length === 0) {
      return "SELECT Id FROM Task LIMIT 0";
    }
    let queryString = `SELECT ${this.taskFields.join(", ")} `;

    queryString += ` FROM Task WHERE WhatId IN (${itemIds.join(",")})`;
    queryString += limString;
    return queryString;
  },

  initHelper: function (component, event, helper, refreshTabs) {
    let dealQueryString = helper.compileDealIdQuery(
      component.get("v.recordId")
    );

    component.find("util").query(dealQueryString, (results) => {
      let dealId = component.get("v.recordId");

      if (component.get("v.sObjectName") === "Advance__c") {
        dealId = results[0].Deal__c;
      }

      console.log("advance deal id");
      console.log(dealId);

      let queryStringPC = helper.compileQueryString(dealId);

      component.find("util").query(queryStringPC, (results) => {
        //console.log("--results--");
        //console.log(results);
        let postClosing = results[0];
        component.set("v.postClosing", postClosing);
      });
    });

    let queryStringItems = helper.compileSectionsQueryString(
      component.get("v.recordId"),
      component.get("v.sObjectName")
    );

    let docQueryString = helper.compileDealDocQueryString(
      component.get("v.recordId"),
      component.get("v.sObjectName")
    );

    component.find("util").getUserId((results) => {
      component.set("v.userId", results);
    });

    component.find("util").query(queryStringItems, (results) => {
      let wrappers = results;
      //console.log("--wrappers--");
      //console.log(wrappers);
      const itemIds = [];
      wrappers.forEach((section) => {
        section.Post_Closing_Items__r &&
          section.Post_Closing_Items__r.forEach((item) => {
            itemIds.push(`'${item.Id}'`);
          });
      });

      component.find("util").query(docQueryString, (docs) => {
        docs.forEach((doc) => {
          let sectionId = doc.Post_Closing_Item__r.Post_Closing_Section__c;
          let itemId = doc.Post_Closing_Item__c;

          wrappers.forEach((section) => {
            if (section.Id === sectionId) {
              section.Post_Closing_Items__r.forEach((item) => {
                // itemIds.push(`'${item.Id}'`);
                if (item.Id === itemId) {
                  if (!item.hasOwnProperty("Deal_Documents__r")) {
                    item.Deal_Documents__r = [];
                  }
                  item.Deal_Documents__r.push(doc);
                }
              });
            }
          });
        });

        let taskQueryString = helper.compileTaskQueryString(itemIds);
        //console.log(taskQueryString);
        component.find("util").query(taskQueryString, (tasks) => {
          //console.log("--tasks--");
          //console.log(tasks);
          tasks.forEach((task) => {
            let itemId = task.WhatId;
            wrappers.forEach((section) => {
              //if (section.Id === sectionId) {
              section.Post_Closing_Items__r &&
                section.Post_Closing_Items__r.forEach((item) => {
                  if (item.Id === itemId) {
                    if (!item.hasOwnProperty("Tasks")) {
                      item.Tasks = [];
                    }
                    item.Tasks.push(task);
                  }
                });
              //}
            });
          });

          // component.set("v.itemWrappers", wrappers);

          // let itemTabs = component.find("itemTabs");

          // if (!$A.util.isArray(itemTabs)) {
          //   itemTabs = [itemTabs];
          // }

          // itemTabs.forEach((tab) => {
          //   tab.refreshChecklists();
          // });

          let dealWrappers = [];
          let advanceWrappers = [];

          console.log(wrappers);
          wrappers.forEach((wrapper) => {
            if (
              !$A.util.isEmpty(wrapper.Advance__c) &&
              wrapper.Name !== "Principal Loan Docs" &&
              wrapper.Name !== "Trailing Loan Docs"
            ) {
              advanceWrappers.push(wrapper);
            } else {
              dealWrappers.push(wrapper);
            }
          });

          //console.log(advanceWrappers);
          //console.log(dealWrappers);

          component.set("v.itemWrappers", dealWrappers);
          component.set("v.advanceWrappers", advanceWrappers);

          // if (refreshTabs) {
          //   let itemTabs = component.find("itemTabs");
          //   console.log(itemTabs);
          //   if (!$A.util.isArray(itemTabs)) {
          //     itemTabs = [itemTabs];
          //   }

          //   itemTabs.forEach((tab) => {
          //     if (tab.refreshChecklists) {
          //       tab.refreshChecklists();
          //     }
          //   });
          // }
        });

        //console.log("--task query string--");
        //console.log(taskQueryString);
        //console.log("wrappers= ", wrappers);

        //console.log(docs);
      });

      //postClosing.Post_Closing_Items__r.forEach((section) => {
      // let wrapperLength = wrappers.length;
      // if (
      //   wrapperLength === 0 ||
      //   wrappers[wrapperLength - 1].Id !== section.Id
      // ) {
      //   wrappers.push({
      //     Id.
      //     sectionName: section.Section__c,
      //     items: []
      //   });
      //   wrapperLength++;
      // }
      // wrappers[wrapperLength - 1].items.push(item);
      //});
    });
  }
});