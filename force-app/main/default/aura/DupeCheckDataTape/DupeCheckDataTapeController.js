({
    init: function(component, event, helper) {
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
            function(data) {
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
                
                console.log(component.get("v.readOnly"));
                console.log(component.get("v.allowDelete"));
                
                helper.callAction(
                    component,
                    "c.getRelatedListPropertyForDupeCheck",
                    {
                        parentId: component.get("v.recordId"),
                        parentFieldName: component.get("v.parentFieldName"),
                        sobjectType: component.get("v.sobjectType"),
                        whereClause: "Active__c = true",
                        orderClause: "Property_Name__c asc"
                    },
                    function(data1) {
                        var  data=JSON.parse(data1);
                        
                        var dateCols = [];
                        var columns = component.find("hot-table").get("v.columns");
                        columns.forEach(function(col) {
                            if (col.get("v.type") === "date") {
                                dateCols.push(col.get("v.data"));
                            }
                        });
                        
                        component.set("v.dateCols", dateCols);
                        
                        data.forEach(function(row) {
                            dateCols.forEach(function(field) {
                                if (!$A.util.isEmpty(row.property[field])) {
                                    row.property[field] = $A.localizationService.formatDate(
                                        row.property[field],
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
    
    debug: function(component, event, helper) {
        console.log("test");
        component.find("hot-table").getData();
    },
    
    navigateToRecord: function(component, event, helper) {
        var navigationEvent = $A.get("e.force:navigateToSObject");
        navigationEvent.setParams({
            recordId: component.get("v.recordId"),
            slideDevName: "detail"
        });
        
        navigationEvent.fire();
    },
    
    export: function(component, event, helper) {
        console.log("export");
        var exportCmp = component.find("export");
        
        var value;
        exportCmp.getValue(function(val) {
            value = val;
        });
        var properties = [];
        
        var action = component.get("c.getRelatedListPropertyForDupeCheck");
            action.setParams({
                parentId: component.get("v.recordId"),
                parentFieldName: component.get("v.parentFieldName"),
                sobjectType: component.get("v.sobjectType"),
                whereClause: "Active__c = true",
                orderClause: "Property_Name__c ASC, Parent_Property__c ASC, Name ASC"
            });
        helper
        .serverSideCall(action, component)
        .then(
            $A.getCallback(function(response) {
                //var  data=JSON.parse(data1);
                console.log("export code data here - "+response);
                var responseData=[];
                responseData = JSON.parse(response);
                //filter all data based on selection here
                for(var index in responseData){
                    if (value.indexOf(responseData[index].Status)!=-1) {
                       properties.push(responseData[index]); 
                    } 
                }
                
                var action1 = component.get("c.getTemplate");
                action1.setParams({
                    fileName: "BridgeDuplicateDataTape"
                });
                return helper.serverSideCall(action1, component);
            })
        )
        .then(
            $A.getCallback(function(response) {
                console.log("data loaded");
                
                XlsxPopulate.fromDataAsync(
                    helper.base64ToArrayBuffer(JSON.parse(response))
                )
                .then(workbook => {
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
                    .sheet(0)
                    .row(10 + i)
                    .cell(j + 2)
                    .value(properties[i][prop]);
                }
            }
                           }
                           return workbook.outputAsync("base64");
            })
        .then(data => {
            var link = document.createElement("a");
            link.href = "data:" + XlsxPopulate.MIME_TYPE + ";base64," + data;
            link.download = "BridgeDuplicateDataTape.xlsx";
            link.click();
            exportCmp.close();
        });
    })
    )
    .catch(function(error) {
    console.log(error);
});

},
    
    openExportModal: function(component, event, helper) {
        component.find("export").open();
    }
});