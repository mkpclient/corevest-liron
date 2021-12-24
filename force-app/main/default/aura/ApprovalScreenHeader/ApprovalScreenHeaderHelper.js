({
	toggleHide : function(component, name) {
		$A.util.toggleClass(component.find(name), 'slds-hide');
	}
})