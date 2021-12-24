({	
	getRecordTypeName : function(component, helper){
		var action = component.get('c.getRecordTypeName');
		action.setParams({
			i : component.get('v.recordId')
		});

		action.setCallback(this, function(response){
			var state = response.getState();

			if(state === 'SUCCESS'){
				component.set('v.recordTypeName', response.getReturnValue());
				//console.log(response.getReturnValue());
				//console.log(component.get('v.recordTypeName'));

				helper.getLayout(component, helper);


			}else if(state === 'ERROR'){
				console.log('error');
			}
		});

		$A.enqueueAction(action);
	},

	getLayout : function(component, helper) {
		var action = component.get('c.queryLayout');
		console.log('getLayout');
		action.setParams({
			//recordId: component.get('v.dealId'),
			//recordTypeId: '012j0000000WA15AAG'
			sobjectName : component.get('v.sobjectType'),
			recordTypeName : component.get('v.recordTypeName'),
			userType : component.get('v.user').userType
		});
		//console.log(component.get('v.sobjectType'));
		//console.log(component.get('v.recordTypeName'));
		action.setCallback(this, function(response){
			var state = response.getState();
			console.log(state);
			if(state === 'SUCCESS'){

				var fieldTypeMap = component.get('v.fieldTypeMap');

				var layout = JSON.parse(response.getReturnValue()).layouts[0].detailLayoutSections;
				//console.log(layout);
				var sections = [];
				var fieldList = [];
				layout.forEach(function(sect){
					//console.log(sect);
					var section = {
						header : sect['heading'],
						fields : []
					}

					sect['layoutRows'].forEach(function(row){
						
						row['layoutItems'].forEach(function(item){
							var field = {
								'label': '',
								'fieldName': '',
								'value': '',
								'type': ''
							};
							field['label'] = item['label'];

							//console.log(item['layoutComponents']);
							if(!$A.util.isEmpty(item['layoutComponents'])){
								field['fieldName'] = item['layoutComponents'][0]['value'];
								

								field['type'] = fieldTypeMap[field['fieldName']];

								if(field['type'] == 'REFERENCE'){
									//console.log('is reference');
									var fieldName = field['fieldName'];

									var end = fieldName.slice(-2);

									if(end == 'Id'){
										fieldName = fieldName.substring(0, fieldName.length-2) + '.Name';
									}else if(end == '_c'){
										fieldName = fieldName.substring(0, fieldName.length-1) + 'r.Name';
									}

									field['fieldName'] = fieldName; 
									//console.log(fieldName);


								}
								fieldList.push(field['fieldName']);
								//console.log(field['type']);
							}
							

							section['fields'].push(field);

							
						});
					});

					if(section.header != 'System Information'){
						sections.push(section);
					}
					


				});

				//console.log(sections);
				//component.set('v.pageBlockSections', sections);
				//console.log('--fieldList--');
				//console.log(fieldList);
				helper.getRecord(component, helper, fieldList, sections);

			}else{
				console.log(state);
				console.log(response.getError());
			}
		});
		// console.log(action);
		action.setStorable();
		$A.enqueueAction(action);
	},

	getFieldTypeMap : function(component, helper){
		var action = component.get('c.getFieldTypeMap');
		action.setParams({
			'sobjectName': component.get('v.sobjectType')
		});

		action.setCallback(this, function(response){
			var state = response.getState();
			if(state === 'SUCCESS'){
				var fieldTypeMap = JSON.parse(response.getReturnValue());
				component.set('v.fieldTypeMap', fieldTypeMap);
				//console.log(component.get('v.fieldTypeMap'));

				//helper.getLayout(component, helper);
				helper.getRecordTypeName(component, helper);
			}else if(state === 'ERROR'){
				var errors = response.getError();
				console.log(errors);
			}
		});

		action.setStorable();
		$A.enqueueAction(action);
	},

	getRecord : function(component, helper, fieldList, pageBlockSections){
		var action = component.get('c.queryRecord');
		//console.log(fieldList);
		action.setParams({
			i : component.get('v.recordId'),
			fieldList: fieldList
		});

		action.setCallback(this, function(response){
			var state = response.getState();
			if(state === 'SUCCESS'){
				//console.log(response.getReturnValue());
				var record = JSON.parse(response.getReturnValue())[0];
				//console.log(record);
				pageBlockSections.forEach(function(section){
					section['fields'].forEach(function(field){
						//console.log(field);
						//field['value'] = record[field['fieldName']];
						field['value'] = helper.parseFieldValue(record, field['fieldName']);
						//console.log(field['value']);
					})
				});

				component.set('v.pageBlockSections', pageBlockSections);
				//console.log(record);

				//console.log(pageBlockSections);

			}else if(state === 'ERROR'){
				var errors = response.getError();
				console.log(errors);
				console.log('error');
			}
		});

		$A.enqueueAction(action);
	},

	parseFieldValue : function(obj, fieldPath ) {

        var fields = fieldPath.split( '.' );

        var value = null;

        if ( obj.hasOwnProperty( fields[0] ) ) {

            value = obj[fields[0]];

            if ( fields.length > 1 ) {

                for ( var i = 1; i < fields.length; i++ ) {
                    if ( value != null && value.hasOwnProperty( fields[i] ) ) {
                        value = value[fields[i]];
                    } else {
                        value = null;
                        break;
                    }
                }

            }
        }

        return value;
	}
})