({  
    init : function(component, event, helper){
        //console.log(event.getParam('oldValue'));
        //console.log(event.getParam('value'));
        if(!$A.util.isEmpty(component.get('v.value'))){
            helper.setRecord(component, component.get('v.value'));
        } 
    },

	searchRecordsMethod : function(component, event, helper) {
        console.log(component.get("v.record"))
        var searchTerm = component.get('v.searchTerm');
        var whereClause = component.get('v.whereClause');
        const record = component.get("v.record");
        if(whereClause.includes("{")) {
            let whereField = whereClause.substring(whereClause.indexOf("{") + 1, whereClause.lastIndexOf("}"));
            if(!!record && record.hasOwnProperty(whereField) && record[whereField]) {
                 whereClause = whereClause.replace(whereField, record[whereField]).replace("{", "'").replace("}", "'");
                 component.set("v.dependentMessage", null);
            } else {
                whereClause = whereClause.replace(whereField, "").replace("{", "'").replace("}", "'");
                if(whereField === "Escrow_Agent__c") {
                    whereField = "Escrow Company";
                }
                component.set("v.dependentMessage", "Please select " + whereField.replace("__c", "").replaceAll("_", " ") + " first.");
            }
        }
        console.log('where clause', whereClause);
        console.log(component.get('v.sObjectName'));
        console.log(searchTerm);
        if ( searchTerm && searchTerm.length > 1 ){
            var sObjectName = component.get("v.sObjectName");
            // var whereClause = component.get("v.whereClause");
            var lim = component.get("v.limit");
            //var returnFields = component.get('v.returnFields');
            var action = component.get("c.searchRecords");

            action.setParams({
                "searchTerm": searchTerm,
                "sObjectName": sObjectName,
                "whereClause": whereClause,
                "lim": lim,
            });

            action.setCallback(this, function(response) {
                if ( response.getState() === "SUCCESS" ){
                    var res = response.getReturnValue();

                    component.set("v.results", res);
                    console.log(component.get('v.results'));
                }
                else if( response.getState() === "ERROR"){
                    console.log('error in autocomplete');
                    console.error(response.getError());
                }
            });
            $A.enqueueAction(action);
        }
        else{
        	component.set('v.results', null);
        }
    },

    handleNewAccount: function(component, event, helper) {

    },
    select : function(component, event, helper){
    	var lookupId = event.target.getAttribute('data-recordid');
    	var recordName = event.target.getAttribute('data-record');


    	component.set('v.results', null);
        component.set('v.searchTerm', recordName);
        component.set('v.value', lookupId);
        //helper.setRecord(component, lookupId);
        helper.valueChangeEvent(component, helper);

    },

    clearRecord : function(component, event, helper){
        component.set('v.value', null);
        component.set('v.searchTerm', '');
        // component.set('v.record', null);
        helper.valueChangeEvent(component, helper);

    },
})