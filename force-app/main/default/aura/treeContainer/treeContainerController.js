({
	init : function(component, event, helper) {
		//console.log('tree container init');
		// console.log(component.get('v.folderStructure'));

		//var folders = [];
		var folderStructure = component.get('v.folderStructure');

		var folders = [];
		if(!$A.util.isEmpty(folderStructure)){
			Object.keys(folderStructure).forEach( key => {
				folders.push(folderStructure[key]);
			});
		}

		//console.log(folders);
		component.set('v.folders', folders);
	},

	checked : function(component, event, helper){
		var items = component.find('items');
		var value = component.get('v.checked');
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

		component.set('v.folderStructure', component.get('v.folderStructure'));

		//var tree = component.get('v.tree');
		//tree.checked = component.get('v.checked');
		//component.set('v.tree', tree);
	}
})