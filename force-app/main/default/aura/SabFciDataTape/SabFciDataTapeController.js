({
    init: function (component, event, helper) {
      console.log("FCI DATATAPE INIT")
      helper.setPermission(component);
      helper.setDealStatus(component);
      helper.getUserProfile(component);
      const queryFields = ["Id"].concat(component
        .find("hot-table")
        .get("v.columns")
        .map(col => col.get("v.data"))
        .filter(f => f[0] != "_")
        );
      component.set("v.fieldList", queryFields);
      helper.callAction(
        component,
        "c.getRecordList",
        {
          parentId: component.get("v.recordId"),
          parentFieldName: component.get("v.parentFieldName"),
          sobjectType: component.get("v.sobjectType"),
          fields: queryFields,
          sortCol: "",
          sortDir: "",
          whereClause: "Property_Type__c != 'Parent'",
          orderBy: "Asset_ID__c asc"
        },
        function (data) {
          if ($A.util.isEmpty(data)) {
            data.push({});
          } else {
            data.forEach(function (d) {
              d["_defaultYes"] = "Yes";
              d["_defaultNo"] = "No";
              d["_defaultZero"] = 0;
              d["_defaultBlank"] = "";
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
  
          if (col.get("v.data") != "_" && col.get("v.data")[0] != "_") {
            fields.push(col.get("v.data"));
          }
        });
  
      var missingRequiredFields = false;
      let emptyRows = {};
  
      component.find("hot-table").getData(function (data) {
        data.forEach(function (d) {
          d["_defaultYes"] = "Yes";
          d["_defaultNo"] = "No";
          d["_defaultZero"] = 0;
          d["_defaultBlank"] = "";
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
                d["_defaultYes"] = "Yes";
                d["_defaultNo"] = "No";
                d["_defaultZero"] = 0;
                d["_defaultBlank"] = "";
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
  
      let readOnlyColumns = [];
  
      for (let i = 0; i < columns.length; i++) {
        let label = columns[i].get("v.title");
  
        if (columns[i].get("v.readOnly")) {
          readOnlyColumns.push(columns[i].get("v.data"));
        }
  
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
          // var id = properties[index].Id;
          property.Id = properties[index].Id;
  
          readOnlyColumns.forEach((fieldName) => {
            property[fieldName] = properties[index][fieldName];
          });
  
          properties[index] = property;
        } else {
          readOnlyColumns.forEach((x) => {
            delete property[x];
          });
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
      const queryFields = component.get("v.fieldList");
  
      var action = component.get("c.getRecordList");
      action.setParams({
        parentId: component.get("v.recordId"),
        parentFieldName: component.get("v.parentFieldName"),
        sobjectType: component.get("v.sobjectType"),
        fields: queryFields,
        sortCol: "",
        sortDir: "",
        whereClause: "Property_Type__c != 'Parent'",
        orderBy: "Asset_ID__c asc"
    });
      
      //console.log(value);
  
      helper
        .serverSideCall(action, component)
        .then(
          $A.getCallback(function (response) {
            console.log("abc");
            properties = response;
            properties.forEach(function (d) {
              d["_defaultYes"] = "Yes";
              d["_defaultNo"] = "No";
              d["_defaultZero"] = 0;
              d["_defaultBlank"] = "";
            });
            var action1 = component.get("c.getTemplate");
            action1.setParams({
              fileName: "SAB FCIDataTapeTemplate"
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
                    const pctFields = ["Rate__c", "Default_Rate__c", "Late_Charge__c"];
                    if (
                      !$A.util.isEmpty(prop)
                    ) {
                      let val;
                      const fieldArray = prop.split(".");
                      console.log(fieldArray);
                      fieldArray.forEach(f => {
                        if(!val) {
                          val = properties[i][f];
                        } else {
                          val = val[f];
                        }
                        if(pctFields.includes(f) && !isNaN(val)) {
                          val = val / 100;
                        }
                      });
                      workbook
                        .sheet(0)
                        .row(10 + i)
                        .cell(j + 3)
                        .value(val);
                    }
                  }
                }
                return workbook.outputAsync("base64");
              })
              .then((data) => {
                console.log(456);
                var link = document.createElement("a");
                link.href = "data:" + XlsxPopulate.MIME_TYPE + ";base64," + data;
                link.download = "CoreVestSABFCIDataTape.xlsx";
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