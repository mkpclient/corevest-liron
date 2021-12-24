({
    handleImport : function(component, event, helper){
        //$A.util.toggleClass(component.find('spinner'), 'slds-hide');
        console.log('onchange?');
		var file = component.find('fileUpload').get('v.files')[0];

		helper.readFile(file, component, helper);
    }
})