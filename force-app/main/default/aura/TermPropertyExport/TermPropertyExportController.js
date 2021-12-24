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

	export : function(component, event, helper){
		var action = component.get('v.exportAction');
		$A.util.removeClass(component.find('spinner'), 'slds-hide');
		$A.enqueueAction(action);
	},

	getValue : function(component, event){
		var params = event.getParam('arguments');
		if(params){
			var inputs = component.find('options');
			inputs.forEach(function(el){
				//console.log(el.elements[0]);
				if(el.elements[0].checked){
					//console.log(el.get('v.label'));
					//console.log(el.get('v.'))
					//console.log(el.elements[0].value);
					params.callback(el.elements[0].value);
				}
			})
			//params.callback(component.g)
		}
	}
	
})