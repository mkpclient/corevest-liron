({
    init: function(component, event, helper) {
        let action = component.get("c.returnHistoryOpp");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log("this is the response");
                console.log(response.getReturnValue());
                let responseVal = JSON.parse(response.getReturnValue());
                component.set("v.processId", responseVal.processId);
                if (true == responseVal.isSubmitter) {
                    component.set("v.showRecall", true);
                }
                
                component.set("v.roleName", responseVal.userRole);
                
                console.log(responseVal);
                let returnArr = responseVal.ahList;
                component.set("v.total", returnArr.length.toString());
                
                helper.sortByDate(
                    returnArr,
                    "Date_Acted__c",
                    "CreatedDate",
                    "Status__c",
                    "Submitted",
                    "Re-submitted",
                    function(arr) {
                        console.log("this is the arr");
                        console.log(arr);
                        let steps = arr.slice(0, 6);
                        component.set("v.steps", steps);
                        component.set("v.extraSteps", arr.slice(6));
                    }
                );
                
                component.set("v.chatterComments", responseVal.ChatterCommentsList);
            } else {
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
    },
  toggleHide : function(component, name) {
		$A.util.toggleClass(component.find(name), 'slds-hide');
	},
    toggleMessage: function(str){
        if (str == 'Show All'){
            return 'Hide Additional Items';
        }
        return 'Show All';
    },

	sortByDate : function(arr,field1,field2,exceptionField,exceptionValue,exceptionValue2,cb){
		arr.sort(function(a,b){
			var sortByFieldA = a[field1] ? field1 : field2;
			var sortByFieldB = b[field1] ? field1 : field2;

			if ( a[exceptionField] == exceptionValue || a[exceptionField] == exceptionValue2)
				sortByFieldA = field2;

			if ( b[exceptionField] == exceptionValue || b[exceptionField] == exceptionValue2)
				sortByFieldB = field2;

			return Date.parse(b[sortByFieldB]) - Date.parse(a[sortByFieldA]);
		})
		console.log(arr);
		cb(arr);

	}
})