({
    toggleHide: function(component, name) {

		let cmps = component.find(name);

		if(!$A.util.isArray(cmps)){
			cmps = [cmps];
		}

		cmps.forEach(cmp => {
			$A.util.toggleClass(cmp, 'slds-hide');
		})

		
	}
})