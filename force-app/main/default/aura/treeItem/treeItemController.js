({
	init : function(component, event, helper) {
		var tree = component.get('v.tree');
		var nodes = tree.subFolders;

		var items = [];
		if(!$A.util.isEmpty(nodes)){
			Object.keys(nodes).forEach( key => {
				items.push(nodes[key]);
			});
		}

		component.set('v.items', items);
	},

	toggle : function(component, event, helper){
		var toggleButton = component.find('toggle');
		var itemsList = component.find('itemsList');
		if(toggleButton.get('v.iconName') == 'utility:chevronright'){
			$A.util.removeClass(itemsList, 'slds-is-collapsed');
			$A.util.addClass(itemsList, 'slds-is-expanded');
			toggleButton.set('v.iconName', 'utility:chevrondown');
		}else{
			$A.util.addClass(itemsList, 'slds-is-collapsed');
			$A.util.removeClass(itemsList, 'slds-is-expanded');
			toggleButton.set('v.iconName', 'utility:chevronright');
		}
	},

	checked : function(component, event, helper){
		var items = component.find('items');
		console.log('checked');
		if(!$A.util.isEmpty(items)){
			if(items.constructor !== Array){
				//console.log(item.ge);
				items = [items];
			}
			items.forEach(el => {
				el.set('v.checked', component.get('v.checked'));
			});
		}

		var tree = component.get('v.tree');
		tree.checked = component.get('v.checked');
		component.set('v.tree', tree);

		//component.getEvent('treeEvent').fire();
	},

	toggleCheckbox : function(component, event, helper){
		
		var value = event.getParam('arguments').value;


		var items = component.find('items');
		if(!$A.util.isEmpty(items)){
			if(items.constructor !== Array){
				//console.log(item.ge);
				items = [items];
			}
			items.forEach(el => {
				//el.set('v.checked', component.get('v.checked'));
				el.toggleCheckbox(value);
			});
		}

		component.set('v.checked', value);

		var tree = component.get('v.tree');
		tree.checked = value;
		component.set('v.tree', tree);
	},

	clicked : function(component, event, helper){
		var value = component.get('v.checked');

		var items = component.find('items');
		if(!$A.util.isEmpty(items)){
			if(items.constructor !== Array){
				//console.log(item.ge);
				items = [items];
			}
			items.forEach(el => {
				//el.set('v.checked', component.get('v.checked'));
				el.toggleCheckbox(value);
			});
		}

		var tree = component.get('v.tree');
		tree.checked = component.get('v.checked');
		component.set('v.tree', tree);

		component.set('v.folderStructure', component.get('v.folderStructure'));
	}
})