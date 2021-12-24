({
  init: function (component, event, helper) {
    helper.setPermission(component);
    helper.setDealStatus(component);
    helper.getUserProfile(component);
    helper.callAction(
      component,
      "c.getRelatedList",
      {
        parentId: component.get("v.recordId"),
        parentFieldName: component.get("v.parentFieldName"),
        sobjectType: component.get("v.sobjectType"),
        whereClause: "Property_Type__c != 'Parent'",
        orderClause: "Asset_ID__c asc"
      },
      function (data) {
        if ($A.util.isEmpty(data)) {
          data.push({});
        } else {
          data.forEach(function (d) {
            if (d.RecordTypeId == "0120a0000019jiAAAQ") {
              d.RT = "Renovation";
            } else if (d.RecordTypeId === "0120a0000015H6TAAU") {
              d.RT = "No Renovation";
            } else {
              d.RT = "Ground Up Construction";
            }
            if (d.Closer__c == "0055b00000P92byAAB") {
              d.Closer = "David Carrillo";
            } else if (d.Closer__c == "0050a00000MCPyLAAX") {
              d.Closer = "Kathy Perez";
            } else if (d.Closer__c == "0050a00000MBNARAA5") {
              d.Closer = "Jaime Chavez";
            } else if (d.Closer__c == "0055b00000OGpKXAA1") {
              d.Closer = "Jenna Taylor";
            } else if (d.Closer__c == "0050a00000MCQ1jAAH") {
              d.Closer = "Jessica Lievanos";
            } else if (d.Closer__c == "005j000000FXxrDAAT") {
              d.Closer = "Gina Lambis";
            } else if (d.Closer__c == "0050a00000L853XAAR") {
              d.Closer = "Nate Valline";
            } else if (d.Closer__c == "0055b00000Omc6lAAB") {
              d.Closer = "Ellie Young";
            } else {
              d.Closer = null;
            }
          });
        }

        var columns = component.find("hot-table").get("v.columns");
        var dateCols = [];
        columns.forEach(function (col) {
          if (col.get("v.type") === "date") {
            dateCols.push(col.get("v.data"));
          }
        });

        // component.set("v.dateCols", dateCols);

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

        if (component.get("v.tableInit")) {
          component.find("hot-table").loadData(data, null);
        } else {
          component.find("hot-table").createTable(data);
          component.set("v.tableInit", true);
        }
      }
    );
  },

  debug: function (component, event, helper) {
    console.log("test");
    component.find("hot-table").getData();
  },

  saveRows: function (component, event, helper) {
    //var table = component.find('hot-table')

    $A.util.toggleClass(component.find("spinner"), "slds-hide");

    var requiredFields = new Set();
    let requiredFieldsMap = {};
    let fields = [];

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

    component.find("hot-table").getData(function (data) {
      data.forEach(function (el, index) {
        if (el.hasOwnProperty("_")) {
          delete el["_"];
        }

        if (el.RT == "Renovation") {
          el.RecordTypeId = "0120a0000019jiAAAQ";
        } else if (el.RT == "No Renovation") {
          el.RecordTypeId = "0120a0000015H6TAAU";
        } else {
          el.RecordTypeId = "0120a0000019kcQAAQ";
        }

        if (el.Closer == "David Carrillo") {
          el.Closer__c = "0055b00000P92byAAB";
        } else if (el.Closer == "Kathy Perez") {
          el.Closer__c = "0050a00000MCPyLAAX";
        } else if (el.Closer == "Jaime Chavez") {
          el.Closer__c = "0050a00000MBNARAA5";
        } else if (el.Closer == "Jenna Taylor") {
          el.Closer__c = "0055b00000OGpKXAA1";
        } else if (el.Closer == "Jessica Lievanos") {
          el.Closer__c = "0050a00000MCQ1jAAH";
        } else if (el.Closer == "Gina Lambis") {
          el.Closer__c = "005j000000FXxrDAAT";
        } else if (el.Closer == "Nate Valline") {
          el.Closer__c = "0050a00000L853XAAR";
        } else if (el.Closer == "Ellie Young") {
          el.Closer__c = "0055b00000Omc6lAAB";
        } else {
          el.Closer__c = null;
        }

        // delete el["RT"];

        el["sobjectType"] = "Property__c";

        //for (var x in el) {
        fields.forEach((x) => {
          if (!$A.util.isEmpty(el[x]) && x.includes("Date")) {
            if (el[x] == "1/0/00" || $A.util.isEmpty(el[x].replace(/ /g, ""))) {
              el[x] = null;
            } else {
              if (
                $A.localizationService.formatDate(el[x], "YYYY-MM-DD") ===
                "Invalid Date"
              ) {
                el[x] = null;
              } else {
                el[x] = $A.localizationService.formatDate(el[x], "YYYY-MM-DD");
              }
            }
          }

          // if(!$A.util.isEmpty(el[x]]) && el[x].includes('%')){

          // }

          if (requiredFields.has(x) && $A.util.isEmpty(el[x])) {
            missingRequiredFields = true;
            if (!emptyRows[requiredFieldsMap[x].label]) {
              emptyRows[requiredFieldsMap[x].label] = [];
            }
            emptyRows[requiredFieldsMap[x].label].push(index + 1);
          }

          if ($A.util.isEmpty(el[x])) {
            //delete el[x];
            el[x] = null;
            if (x == "Id" || x == "RecordTypeId") {
              delete el[x];
            }
          }
          if (el[x] == "$0.00") {
            delete el[x];
          }

          if (x == "State__c" && !$A.util.isEmpty(el[x]) && el[x].length == 2) {
            el[x] = el[x].toUpperCase();
          }

          if (
            x == "ZipCode__c" &&
            !$A.util.isEmpty(el[x]) &&
            el[x].length < 5
          ) {
            let iter = 5 - el[x].length;
            for (let paddings = 0; paddings < iter; paddings++) {
              el[x] = "0" + el[x];
            }
          }
        });
        el["Deal__c"] = component.get("v.recordId");
        el["Active__c"] = true;

        if ($A.util.isEmpty(el["Status__c"])) {
          el["Status__c"] = "Due Diligence";
        }
      });

      console.log(data);

      if (!missingRequiredFields) {
        if (component.get("v.dealStatus") === "Expired") {
          var toastEvent1 = $A.get("e.force:showToast");
          toastEvent1.setParams({
            title: "This Loan has Expired",
            message:
              "A Loan Modification will be needed before this Property can be funded",
            mode: "dismissible",
            type: "warning"
          });
          toastEvent1.fire();
        }

        helper.callAction(
          component,
          "c.upsertRecords",
          {
            records: data
          },
          function (resp) {
            $A.util.toggleClass(component.find("spinner"), "slds-hide");

            resp.forEach(function (d) {
              if (d.RecordTypeId == "0120a0000019jiAAAQ") {
                d.RT = "Renovation";
              } else if (d.RecordTypeId === "0120a0000015H6TAAU") {
                d.RT = "No Renovation";
              } else {
                d.RT = "Ground Up Construction";
              }

              if (d.Closer__c == "0055b00000P92byAAB") {
                d.Closer = "David Carrillo";
              } else if (d.Closer__c == "0050a00000MCPyLAAX") {
                d.Closer = "Kathy Perez";
              } else if (d.Closer__c == "0050a00000MBNARAA5") {
                d.Closer = "Jaime Chavez";
              } else if (d.Closer__c == "0055b00000OGpKXAA1") {
                d.Closer = "Jenna Taylor";
              } else if (d.Closer__c == "0050a00000MCQ1jAAH") {
                d.Closer = "Jessica Lievanos";
              } else if (d.Closer__c == "005j000000FXxrDAAT") {
                d.Closer = "Gina Lambis";
              } else if (d.Closer__c == "0050a00000L853XAAR") {
                d.Closer = "Nate Valline";
              } else if (d.Closer__c == "0055b00000Omc6lAAB") {
                d.Closer = "Ellie Young";
              } else {
                d.Closer = null;
              }
            });
            // var data = JSON.parse(resp);

            //console.log(resp);

            //component.find("hot-table").loadData(resp, null);
            $A.enqueueAction(component.get("c.init"));
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              title: "Success",
              message: "Saved",
              mode: "dismissible",
              type: "success"
            });
            toastEvent.fire();
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
          let errorMessage = `${obj}: rows ${emptyRows[obj].join(", ")}`;
          errorMessages.push(errorMessage);
        }

        // console.log(errorMessages);
        component.set("v.errorTitle", "Missing required fields");
        component.set("v.errorMessages", errorMessages);
      }
    });
  },

  navigateToRecord: function (component, event, helper) {
    var navigationEvent = $A.get("e.force:navigateToSObject");
    navigationEvent.setParams({
      recordId: component.get("v.recordId")
    });

    navigationEvent.fire();
  },

  showModal: function (component, event, helper) {
    component.find("importer").open();
  },

  handleImport: function (component, event, helper) {
    var propertyArray = event.getParam("propertyArray");
    var headerList = event.getParam("headerList");

    var columns = component.find("hot-table").get("v.columns");

    var properties = [];
    component.find("hot-table").getData(function (data) {
      if (!$A.util.isEmpty(data) && !$A.util.isEmpty(data[0])) {
        properties = data;
      }
    });

    //console.log(properties);
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

    //console.log(propertyMap);
    let dateMap = {};

    for (var i = 0; i < propertyArray.length; i++) {
      var property = {};
      for (var j = 0; j < columnList.length; j++) {
        let fieldName = columnList[j].fieldName;
        let indexRow = columnList[j].index;
        let fieldType = columnList[j].type;
        let label = columnList[j].label;

        if (fieldName == "Status__c" && $A.util.isEmpty(value)) {
          value = "Due Diligence";
        }

        if (!$A.util.isEmpty(fieldName) && fieldName != "_") {
          var value = propertyArray[i][indexRow];
          if (fieldType == "numeric" && !$A.util.isEmpty(value)) {
            value = value.replace("$", "");

            //value = value.replace("%", "");
            value = value.split(",").join("");
            value = parseFloat(value);
          }

          if (fieldType == "date" && !$A.util.isEmpty(value)) {
            // var splitValue = "-";
            // if (value.includes("/")) {
            //   //value = value.replace(/\//g, '-')
            //   splitValue = "/";
            // }

            // var values = value.split(splitValue);
            // if (values[0].length != 4) {
            //   value = "20" + values[2] + "-";
            //   //+ values[0] + '-' + values[1];

            //   if (values[0].length == 1) {
            //     value += "0";
            //   }
            //   value += values[0] + "-"; //+ '-' + values[1];
            //   if (values[1].length == 1) {
            //     value += "0";
            //   }
            //   value += values[1];
            // }

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

      if (!$A.util.isEmpty(property.Asset_ID__c)) {
        var index = propertyMap[property.Asset_ID__c];
        console.log(index);
        var id = properties[index].Id;
        property.Id = properties[index].Id;

        properties[index] = property;
      } else {
        properties.push(property);
      }
    }

    // component.find('hot-table').getData(function(data){

    // 	if($A.util.isEmpty(data) || $A.util.isEmpty(data[0])){
    // 		component.find('hot-table').loadData(properties, null);
    // 	}else{
    // 		component.find('hot-table').loadData(data.concat(properties), null);
    // 	}

    // 	component.find('importer').close();
    // })

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

    component.find("hot-table").loadData(properties, null);
    component.find("importer").close();
  },
  export: function (component, event, helper) {
    console.log("export");

    var properties = [];

    var action = component.get("c.getRelatedList");
    action.setParams({
      parentId: component.get("v.recordId"),
      parentFieldName: component.get("v.parentFieldName"),
      sobjectType: component.get("v.sobjectType"),
      whereClause: "Is_Parent__c = false",
      orderClause: "Asset_ID__c asc"
    });

    //console.log(value);

    helper
      .serverSideCall(action, component)
      .then(
        $A.getCallback(function (response) {
          console.log("abc");
          properties = response;
          properties.forEach(function (property) {
            if (property.RecordTypeId == "0120a0000019jiAAAQ") {
              property.RT = "Renovation";
            } else if (property.RecordTypeId === "0120a0000015H6TAAU") {
              property.RT = "No Renovation";
            } else {
              property.RT = "Ground Up Construction";
            }

            if (property.Closer__c == "0050a00000MCPyLAAX") {
              property.Closer = "Kathy Perez";
            } else if (property.Closer__c == "0050a00000MBNARAA5") {
              property.Closer = "Jaime Chavez";
            } else if (property.Closer__c == "0055b00000OGpKXAA1") {
              property.Closer = "Jenna Taylor";
            } else if (property.Closer__c == "0050a00000MCQ1jAAH") {
              property.Closer = "Jessica Lievanos";
            } else if (property.Closer__c == "005j000000FXxrDAAT") {
              property.Closer = "Gina Lambis";
            } else if (property.Closer__c == "0050a00000L853XAAR") {
              property.Closer = "Nate Valline";
            } else if (property.Closer__c == "0055b00000Omc6lAAB") {
              property.Closer = "Ellie Young";
            } else {
              property.Closer = null;
            }
          });
          var action1 = component.get("c.getTemplate");
          action1.setParams({
            fileName: "Bridge DataTapeTemplate"
          });
          console.log("def");

          return helper.serverSideCall(action1, component);
        })
      )
      .then(
        $A.getCallback(function (response) {
          console.log("data loaded");
          //console.log(JSON.parse(response.getReturnValue()));
          //console.log(helper.base64ToArrayBuffer(JSON.parse(response.getReturnValue() ) ));
          //console.log(response);
          XlsxPopulate.fromDataAsync(
            helper.base64ToArrayBuffer(JSON.parse(response))
          )
            .then((workbook) => {
              console.log(123);
              var columns = component.find("hot-table").get("v.columns");
              for (var i = 0; i < properties.length; i++) {
                for (var j = 0; j < columns.length; j++) {
                  var prop = columns[j].get("v.data");
                  if (
                    !$A.util.isEmpty(prop) &&
                    prop != "_" &&
                    prop != "Annual_NOI__c" &&
                    prop != "Annual_Total_Expenses__c" &&
                    prop != "Total_Basis__c"
                  ) {
                    workbook
                      .sheet(0)
                      .row(10 + i)
                      .cell(j + 3)
                      .value(properties[i][prop]);
                  }
                }
              }
              return workbook.outputAsync("base64");
            })
            .then((data) => {
              console.log(456);
              var link = document.createElement("a");
              link.href = "data:" + XlsxPopulate.MIME_TYPE + ";base64," + data;
              link.download = "CoreVestBridgeDataTape.xlsx";
              link.click();
              //exportCmp.close();
            });
        })
      )
      .catch(function (error) {
        console.log(JSON.stringify(error));
      });
  }
});