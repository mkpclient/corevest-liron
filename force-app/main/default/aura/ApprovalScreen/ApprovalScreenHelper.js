({
	toggleDirection : function(title,properties,parent,component,cb) {
		let field = title.split('-')[0];
		let direction = title.split('-')[1];
		let numberBool = title.split('-')[2]

		if (direction == 'down'){
			if (numberBool){
				console.log('this is a number');
				properties.sort(function(a,b){
					var fieldA = a[field] ? a[field] : 0;
					var fieldB = b[field] ? b[field] : 0;
					return fieldA - fieldB;
				});
				parent.setAttribute('title',field + '-' + 'up-number');
			} else {
				properties.sort(function(a,b){
					var nameA = a[field] ? a[field].toUpperCase() : ' ';
					var nameB = b[field] ? b[field].toUpperCase() : ' ';
					if (nameA < nameB) {
					  return 1;
					}
					if (nameA > nameB) {
					  return -1;
					}
					return 0;
				});
				parent.setAttribute('title',field + '-' + 'up');
			}
			component.set('v.'+field, 'up');
		} else if (direction == 'up'){
			if (numberBool){
				console.log('this is a number');
				properties.sort(function(a,b){
					var fieldA = a[field] ? a[field] : 0;
					var fieldB = b[field] ? b[field] : 0;
					return fieldB - fieldA;
				});
				parent.setAttribute('title',field + '-' + 'down-number');
			} else {
				properties.sort(function(a,b){
					var nameA = a[field] ? a[field].toUpperCase() : ' ';
					var nameB = b[field] ? b[field].toUpperCase() : ' ';
					if (nameA < nameB) {
					  return -1;
					}
					if (nameA > nameB) {
					  return 1;
					}
					return 0;
				});
				parent.setAttribute('title',field + '-' + 'down');
			}
			component.set('v.'+field, 'down');
		}
		cb(properties);
	}
})