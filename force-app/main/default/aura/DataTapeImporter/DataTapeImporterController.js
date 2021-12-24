({
	init : function(component, event, helper){
		component.set('v.randId', Math.floor(1000 + Math.random() * 9000));
	},
	close : function(component, event, helper){
		var modal = component.find('modal');
		$A.util.removeClass(modal, 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
		$A.util.addClass(modal, 'slds-modal__close');
		$A.util.removeClass(component.find('spinner'), 'slds-hide');
	},
	open : function(component, event, helper){
		var modal = component.find('modal');
		$A.util.removeClass(modal, 'slds-modal__close')

		$A.util.addClass(modal, 'slds-fade-in-open');
		$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
		$A.util.addClass(component.find('spinner'), 'slds-hide');
	},

	toggle : function(component, event, helper){
		var modal = component.find('modal');
		$A.util.toggleClass(modal, 'slds-modal__close')

		$A.util.toggleClass(modal, 'slds-fade-in-open');
		$A.util.toggleClass(component.find('backdrop'), 'slds-backdrop--open');
		$A.util.toggleClass(component.find('spinner'), 'slds-hide');
		
	},

	handleFiles : function(component, event, helper){
		console.log('files were loaded');
		$A.util.removeClass(component.find('spinner'), 'slds-hide');
		var inputFile = component.find('inputFile');
		var files = component.find('inputFile').getElement().files;
		console.log(files);
		var fileList = [];
		for(var i = 0; i < files.length; i++){
			helper.readFile(files[i], component, helper);
		}

		component.find('inputFile').getElement().value = '';
	},

	onDragOver : function(component, event, helper){
		console.log('drag');
		event.preventDefault();
	},

	onDrop : function(component, event, helper){
		console.log('drop');
		event.stopPropagation();
		event.preventDefault();

		event.dataTransfer.dropEffect = 'copy';
		var files = event.dataTransfer.files;

		for(var i = 0; i < files.length; i++){
			helper.readFile(files[i],component, helper);
		}
	},
	
})