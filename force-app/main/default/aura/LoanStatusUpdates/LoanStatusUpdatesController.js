({
    init: function(component, event, helper) {
        helper.init(component, event);
    },
    
    addRow : function(component, event, helper){
        helper.addRow(component, event, helper);
    },
    
    handleRowAction : function(component, event, helper){
        var recordId=event.getSource().get("v.name");
        var selectedAction = event.getParam("value");
        if(selectedAction=='editRecord'){
            helper.editRecord(component, event, helper, recordId);
        }else if(selectedAction=='deleteRecord'){
            helper.deleteRecord(component, event, helper, recordId);
        }
    },
    
    refresh : function(component, event, helper){
        helper.refresh(component, event);
    }
    
})