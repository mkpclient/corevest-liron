({
  init: function (component, event, helper) {
    //console.log('init');

    console.log("term init");
    console.log(component.get("v.recordId"));

    //console.log(component.get('v.stageName'));

    helper.callAction(
      component,
      "c.getRecord",
      {
        i: component.get("v.recordId")
      },
      function (data) {
        var record = JSON.parse(data);
        //console.log(data);
        var stageName = record["StageName"];

        component.set("v.stageName", stageName);
        //console.log(component.get('v.stageName'));
        if (stageName == "Closed Won") {
          component.set("v.readOnly", true);
        }

        if (
          stageName == "Initial Review" ||
          stageName == "Data Tape Received" ||
          stageName == "Term Sheet Issued" ||
          stageName == "Term Sheet Signed/Deposit Collected"
        ) {
          component.set("v.allowDelete", true);
        }

        console.log("read only - " + component.get("v.readOnly"));
        console.log("allow delete - " + component.get("v.allowDelete"));

        helper.callAction(
          component,
          "c.getRelatedList",
          {
            parentId: component.get("v.recordId"),
            parentFieldName: component.get("v.parentFieldName"),
            sobjectType: component.get("v.sobjectType"),
            whereClause: "Is_Parent__c = false AND Status__c = 'Active'",
            orderClause: "Property_Name__c ASC, Name ASC"
          },
          function (data) {
            console.log(data);
            console.log("--data tape--");
            // console

            let newList = {};
            data.forEach((d) => {
              newList[d.Id] = component.get("v.recordId");
            });

            if (!$A.util.isEmpty(data)) {
              helper.compileDupeCheck(component, helper, newList);
            }
            var dateCols = [];
            var columns = component.find("hot-table").get("v.columns");
            columns.forEach(function (col) {
              if (col.get("v.type") === "date") {
                dateCols.push(col.get("v.data"));
              }
            });

            component.set("v.dateCols", dateCols);

            data.forEach(function (row) {
              dateCols.forEach(function (field) {
                if (!$A.util.isEmpty(row[field])) {
                  row[field] = $A.localizationService.formatDate(
                    row[field],
                    "MM/DD/YYYY"
                  );
                }
              });
            });

            if ($A.util.isEmpty(data)) {
              data.push({});
            }

            component.find("hot-table").createTable(data);
          }
        );
      }
    );
  },

  debug: function (component, event, helper) {
    console.log("--debug--");
    helper.sendDupeEmail(component);
  },

  saveRows: function (component, event, helper) {
    //var table = component.find('hot-table')

    $A.util.toggleClass(component.find("spinner"), "slds-hide");

    var requiredFields = new Set();
    let requiredFieldsMap = {};
    let fields = [];
    let hasNVProperty = false;
    component
      .find("hot-table")
      .get("v.columns")
      .forEach(function (col) {
        if (!col.get("v.allowEmpty")) {
          requiredFields.add(col.get("v.data"));
          requiredFieldsMap[col.get("v.data")] = {
            notRequiredChild: col.get("v.notRequiredForChildren"),
            label: col.get("v.title")
          };
        }

        if (col.get("v.data") != "_") {
          fields.push(col.get("v.data"));
        }
      });

    var missingRequiredFields = false;
    let emptyRows = {};
    let needsRent = [];
    let statesDoNotLendIn = [];

    component.find("hot-table").getData(function (data) {
      console.log(data);
      data.forEach(function (el, index) {
        if (el.hasOwnProperty("_")) {
          delete el["_"];
        }
        el["Annual_NOI__c"] = "";
        el["Annual_Total_Expenses__c"] = "";
        el["Total_Basis__c"] = "";

        //for (var x in el) {
        fields.forEach((x) => {
          if (!$A.util.isEmpty(el[x]) && x.includes("Date")) {
            if (el[x] == "1/0/00" || $A.util.isEmpty(el[x].replace(/ /g, ""))) {
              el[x] = null;
            } else {
              el[x] = $A.localizationService.formatDate(el[x], "YYYY-MM-DD");
            }
          }

          if (requiredFields.has(x) && $A.util.isEmpty(el[x])) {
            if (
              requiredFieldsMap[x].notRequiredChild == true &&
              (el["Property_Type__c"] == "2-4 Unit" ||
                el["Property_Type__c"] == "Multifamily" ||
                el["Property_Type__c"] == "Mixed Use")
            ) {
            } else {
              missingRequiredFields = true;

              if (!emptyRows[requiredFieldsMap[x].label]) {
                emptyRows[requiredFieldsMap[x].label] = [];
              }

              emptyRows[requiredFieldsMap[x].label].push(index + 1);
            }
          }

          if ($A.util.isEmpty(el[x])) {
            el[x] = null;
          }
          if (el[x] == "$0.00") {
            delete el[x];
          }
        });

        if (el["Monthly_Rent__c"] == 0) {
          missingRequiredFields = true;
          needsRent.push(index + 1);
        }

        if (
          el["State__c"] == "MN" ||
          el["State__c"] == "ND" ||
          el["State__c"] == "SD"
        ) {
          missingRequiredFields = true;
          statesDoNotLendIn.push(index + 1);
        }

        if (el["State__c"] == "NV") {
          hasNVProperty = true;
        }

        if (!$A.util.isEmpty(el.ZipCode__c) && el.ZipCode__c.length < 5) {
          let iter = 5 - el.ZipCode__c.length;
          for (let paddings = 0; paddings < iter; paddings++) {
            el.ZipCode__c = "0" + el.ZipCode__c;
          }
        }

        // if (el["Active__c"]) {
        //   el["Status__c"] = "Active";
        // } else {
        //   el["Status__c"] = "Inactive";
        // }

        el["Deal__c"] = component.get("v.recordId");
      });

      let duplicateRows = new Set();
      for (let i = 0; i < data.length; i++) {
        for (let j = 0; j < data.length; j++) {
          if (i === j) {
            continue;
          }

          if (
            !$A.util.isEmpty(data[i].Name) &&
            !$A.util.isEmpty(data[j].Name) &&
            data[i].Name.toLowerCase() === data[j].Name.toLowerCase()
          ) {
            duplicateRows.add(i + 1);
            duplicateRows.add(j + 1);

            missingRequiredFields = true;
          }
        }
      }

      if (!missingRequiredFields) {
        if (hasNVProperty) {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Portfolio has Nevada Property",
            message:
              "This Portfolio includes Properties in Nevada.  This will need to go through our Broker licensed in Nevada.",
            mode: "dismissible",
            type: "warning",
            duration: 10000
          });
          toastEvent.fire();
        }

        component.set("v.errorMessages", []);
        helper.callAction(
          component,
          "c.saveDataTape",
          {
            data: JSON.stringify(data),
            dealId: component.get("v.recordId")
          },
          function (resp) {
            $A.util.toggleClass(component.find("spinner"), "slds-hide");
            var data = JSON.parse(resp);
            let newList = {};
            data.forEach(function (row) {
              newList[row.Id] = component.get("v.recordId");
              component.get("v.dateCols").forEach(function (field) {
                if (!$A.util.isEmpty(row[field])) {
                  row[field] = $A.localizationService.formatDate(
                    row[field],
                    "MM/DD/YYYY"
                  );
                }
              });
            });

            console.log(newList);
            if (!$A.util.isEmpty(data)) {
              helper.compileDupeCheck(component, helper, newList, true);
            }

            component.find("hot-table").loadData(data, null);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              title: "Success",
              message: "Saved",
              mode: "dismissible",
              type: "success"
            });
            toastEvent.fire();

            // if (
            //   component.get("v.dupeList").length > 0 &&
            //   !component.get("v.sentDupeEmail")
            // ) {
            //   component.set("v.sentDupeEmail", true);
            //   helper.sendDupeEmail(component);
            // }
          },
          function (resp) {
            var errorMsg = "";

            if (resp) {
              for (var index in resp) {
                console.error("Error: " + resp[index].message);
                errorMsg += resp[index].message + " ";
              }
            } else {
              console.error("Unknown error");
            }

            $A.util.toggleClass(component.find("spinner"), "slds-hide");
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              title: "Error",
              message: errorMsg,
              mode: "dismissible",
              type: "error"
            });
            toastEvent.fire();
          }
        );
      } else {
        $A.util.toggleClass(component.find("spinner"), "slds-hide");

        let errorMessages = [];
        for (let obj in emptyRows) {
          let errorMessage = `Missing required field: ${obj}: rows ${emptyRows[
            obj
          ].join(", ")}`;
          errorMessages.push(errorMessage);
        }

        if (needsRent.length > 0) {
          let errorMessage = `Monthly Rent must be greater than $0.00: rows ${needsRent.join(
            ", "
          )}`;
          errorMessages.push(errorMessage);
        }

        if (statesDoNotLendIn.length > 0) {
          let errorMessage = `CoreVest does not loan on Properties in MN, ND, or SD: rows ${statesDoNotLendIn.join(
            ", "
          )}`;
          errorMessages.push(errorMessage);
        }

        if (duplicateRows.size > 0) {
          let errorMessage = `Address is not unique, please update or add unit/apt #. rows ${Array.from(
            duplicateRows
          ).join(", ")}`;
          errorMessages.push(errorMessage);
        }

        console.log(errorMessages);
        component.set("v.errorTitle", "Review the issues below");
        component.set("v.errorMessages", errorMessages);
      }
    });
  },

  navigateToRecord: function (component, event, helper) {
    if (!$A.util.isEmpty(component.get("v.dupeList"))) {
      component.find("dupeModal").openModal(component.get("v.dupeList"));
    } else {
      var navigationEvent = $A.get("e.force:navigateToSObject");
      navigationEvent.setParams({
        recordId: component.get("v.recordId"),
        slideDevName: "detail"
      });

      navigationEvent.fire();
    }
  },

  showModal: function (component, event, helper) {
    component.find("importer").open();
  },

  handleImport: function (component, event, helper) {
    var propertyArray = event.getParam("propertyArray");
    var headerList = event.getParam("headerList");
    var columns = component.find("hot-table").get("v.columns");

    console.log("propertyArray=", propertyArray);
    console.log("headerlist=", headerList);
    var properties = [];

    component.find("hot-table").getData(function (data) {
      if (!$A.util.isEmpty(data) && !$A.util.isEmpty(data[0])) {
        properties = data;
      }
    });

    var propertyMap = {};
    properties.forEach((property, index) => {
      propertyMap[property.Asset_ID__c] = index;
    });

    let columnList = [];
    for (let i = 0; i < columns.length; i++) {
      let label = columns[i].get("v.title");

      if (
        !$A.util.isEmpty(label) &&
        !$A.util.isEmpty(label.trim()) &&
        label != " " &&
        label != "_"
      ) {
        for (let j = 0; j < headerList.length; j++) {
          let header = headerList[j];

          if (
            !$A.util.isEmpty(header) &&
            header.toLowerCase().trim() == label.toLowerCase().trim()
          ) {
            columnList.push({
              index: j,
              column: columns[i],
              header: header,
              label: label,
              fieldName: columns[i].get("v.data"),
              type: columns[i].get("v.type")
            });
          }
        }
      }
    }

    console.log(columnList);
    //console.log(propertyMap);

    let dateMap = {};

    for (var i = 0; i < propertyArray.length; i++) {
      var property = {};

      //console.log(propertyArray[i]);

      if (propertyArray[i][0] == i + 1) {
        propertyArray[i].unshift("");
      }

      for (var j = 0; j < columnList.length; j++) {
        //if( j != )

        // var fieldName = columnList[j].get("v.data");
        let fieldName = columnList[j].fieldName;
        let index = columnList[j].index;
        let fieldType = columnList[j].type;
        let label = columnList[j].label;

        if (!$A.util.isEmpty(fieldName) && fieldName != "_") {
          //&& columns[j].get('v.data') != 'Asset_ID__c'){
          var value = propertyArray[i][index];
          //console.log(value);
          if (fieldType == "numeric" && !$A.util.isEmpty(value)) {
            value = value.replace("$", "");
            value = value.split(",").join("");
            value = parseFloat(value);
          }

          if (fieldType == "date" && !$A.util.isEmpty(value)) {
            if (
              $A.localizationService.formatDate(value, "YYYY-MM-DD") ===
              "Invalid Date"
            ) {
              if (!dateMap[label]) {
                dateMap[label] = [];
              }

              dateMap[label].push(i + 1);

              value = null;
            }
          }

          property[fieldName] = value;
        }
      }

      property["Status__c"] = "Active";

      if (!$A.util.isEmpty(property.Asset_ID__c)) {
        var index = propertyMap[property.Asset_ID__c];

        if (!$A.util.isEmpty(index)) {
          var id = properties[index].Id;
          property.Id = properties[index].Id;

          properties[index] = property;
        }
      } else {
        properties.push(property);
      }

      //properties.push(property);
    }
    console.log("--imported-- properties");
    console.log(properties);
    console.log("--date map--");
    console.log(dateMap);

    let errorMessages = [];
    for (let obj in dateMap) {
      let errorMessage = `${obj}: rows ${dateMap[obj].join(", ")}`;
      //dateMap[obj].forEach(index => {
      //errorMessage += `${dateMap[obj][index]}, `;
      //});
      errorMessages.push(errorMessage);
    }

    // component.set('v.errorMessage')
    console.log(errorMessages);
    component.set("v.errorTitle", "Invalid Date Data");
    component.set("v.errorMessages", errorMessages);

    //component.find('hot-table').getData(function(data){

    // if($A.util.isEmpty(data) || $A.util.isEmpty(data[0])){
    // 	component.find('hot-table').loadData(properties, null);
    // }else{
    // 	component.find('hot-table').loadData(data.concat(properties), null);
    // }

    // 	component.find('importer').close();
    // })

    component.find("hot-table").loadData(properties, null);
    component.find("importer").close();
  },

  export: function (component, event, helper) {
    console.log("export");
    var exportCmp = component.find("export");

    var value;
    exportCmp.getValue(function (val) {
      value = val;
    });

    var properties = [];

    var action = component.get("c.getRelatedList");
    if (value == "exportAll") {
      action.setParams({
        parentId: component.get("v.recordId"),
        parentFieldName: component.get("v.parentFieldName"),
        sobjectType: component.get("v.sobjectType"),
        whereClause: "Status__c = 'Active'",
        orderClause: "Property_Name__c ASC, Parent_Property__c ASC, Name ASC"
      });
    } else if (value == "excludeParent") {
      action.setParams({
        parentId: component.get("v.recordId"),
        parentFieldName: component.get("v.parentFieldName"),
        sobjectType: component.get("v.sobjectType"),
        whereClause: "Is_Parent__c = false AND Status__c = 'Active'",
        orderClause: "Property_Name__c ASC, Name ASC"
      });
    } else if (value == "excludeSubUnit") {
      action.setParams({
        parentId: component.get("v.recordId"),
        parentFieldName: component.get("v.parentFieldName"),
        sobjectType: component.get("v.sobjectType"),
        whereClause: "Is_Sub_Unit__c = false AND Status__c = 'Active'",
        orderClause: "Name ASC"
      });
    }

    helper
      .serverSideCall(action, component)
      .then(
        $A.getCallback(function (response) {
          properties = response;
          var action1 = component.get("c.getTemplate");
          action1.setParams({
            fileName: "Term DataTapeTemplate"
          });
          return helper.serverSideCall(action1, component);
        })
      )
      .then(
        $A.getCallback(function (response) {
          console.log("data loaded");

          XlsxPopulate.fromDataAsync(
            helper.base64ToArrayBuffer(JSON.parse(response))
          )
            .then((workbook) => {
              var columns = component.find("hot-table").get("v.columns");

              for (var i = 0; i < properties.length; i++) {
                for (var j = 0; j < columns.length; j++) {
                  var prop = columns[j].get("v.data");

                  if (
                    columns[j].get("v.type") == "date" &&
                    !$A.util.isEmpty(properties[i][prop])
                  ) {
                    properties[i][prop] = $A.localizationService.formatDate(
                      properties[i][prop],
                      "MM/DD/YYYY"
                    );
                  }

                  if (
                    !$A.util.isEmpty(prop) &&
                    prop != "_" &&
                    prop != "Annual_NOI__c" &&
                    prop != "Annual_Total_Expenses__c" &&
                    prop != "Total_Basis__c"
                  ) {
                    workbook
                      .sheet(1)
                      .row(10 + i)
                      .cell(j + 2)
                      .value(properties[i][prop]);
                  }
                }
              }
              return workbook.outputAsync("base64");
            })
            .then((data) => {
              var link = document.createElement("a");
              link.href = "data:" + XlsxPopulate.MIME_TYPE + ";base64," + data;
              link.download = "CoreVestDataTapeTemplate.xlsx";
              link.click();
              exportCmp.close();
            });
        })
      )
      .catch(function (error) {
        console.log(error);
      });

    //console.log(properties);

    //exportCmp.close();

    // var action = component.get('c.test');
    // action.setCallback(this, function(response){
    // 	console.log('data loaded');
    // 	//console.log(JSON.parse(response.getReturnValue()));
    // 	//console.log(helper.base64ToArrayBuffer(JSON.parse(response.getReturnValue() ) ));
    // 	XlsxPopulate.fromDataAsync(helper.base64ToArrayBuffer(JSON.parse(response.getReturnValue() ) ) )
    // 		.then(workbook => {
    // 			//const value = workbook.sheet(0).cell("C7").value();
    // 			//console.log(value);
    // 			//workbook.sheet(0).cell("A1").value("foo");

    // 			//component.get('v.')
    // 			var properties;
    // 			component.find('hot-table').getData(function(data){
    // 				properties = data;
    // 			});

    // 			//console.log(data1);
    // 			var columns = component.find('hot-table').get('v.columns');
    // 			// console.log('--columns--');
    // 			// console.log(columns);
    // 			// columns.forEach(el => {
    // 			// 	console.log(el.get('v.data'));
    // 			// });

    // 			for(var i = 0; i < properties.length; i++){
    // 				for(var j =0; j < columns.length; j++){

    // 		// 			el['Annual_NOI__c'] = '';
    // 		// el['Annual_Total_Expenses__c'] = '';
    // 		// el['Total_Basis__c'] = '';

    // 					var prop = columns[j].get('v.data');
    // 					if(!$A.util.isEmpty(prop) && prop != '_' && prop != 'Annual_NOI__c' && prop != 'Annual_Total_Expenses__c' && prop != 'Total_Basis__c'){
    // 						workbook.sheet(1).row(10+i).cell(j+3).value(properties[i][prop]);
    // 					}

    // 				}
    // 				//workbook.sheet(1).row(10+i).cell(3).value(properties[i].Name);
    // 			}
    // 			return workbook.outputAsync('base64');

    // 			//console.log(workbook.sheet(0).cell("D8").value());
    // 		}).then(data => {
    // 			location.href = "data:" + XlsxPopulate.MIME_TYPE + ";base64," + data;
    // 		});
    // });

    // $A.enqueueAction(action);
  },

  openExportModal: function (component, event, helper) {
    component.find("export").open();
  },

  openDupeModal: function (component, event, helper) {
    //
    console.log("open dupe modal");
    component.find("dupeModal").openModal(component.get("v.dupeList"));
  },

  closeDupeModal: function (component, event, helper) {
    //
    // console.log("open dupe modal");
    component.find("dupeModal").closeModal();
  }
});