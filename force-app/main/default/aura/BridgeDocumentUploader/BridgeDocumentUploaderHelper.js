({
	queryAttachments : function(component) {
		var action = component.get('c.getAttachments');
		action.setParams({
			recordId : component.get('v.recordId')
		});

		action.setCallback(this, function(response){
			var state = response.getState();

			if(state === 'SUCCESS'){
				//component.set('v.files', JSON.parse(response.getReturnValue()));
				var files = JSON.parse(response.getReturnValue());

				//console.log(component.get('v.files'));
				component.get('v.sobjectType')
				if(component.get('v.sobjectType') == 'Property__c'){
					var picklistMap = component.get('v.picklistMap');
					files.forEach(function(el){
						el.typeOptions = picklistMap[Object.keys(picklistMap)[0]];
						el.section = Object.keys(picklistMap)[0];
					})
				}
				component.set('v.files', files);
			}else if(state === 'ERROR'){

			}
		});

		$A.enqueueAction(action);
	},

	queryPicklists : function(component){
		var action = component.get('c.getPicklists');
		action.setParams({
			sobjectType: component.get('v.sobjectType'),
			recordType : component.get('v.recordType')
		});

		action.setCallback(this, function(response){
			var state = response.getState();

			if(state === 'SUCCESS'){
				var picklistMap = JSON.parse(response.getReturnValue());
				var sections = [];
				// if(component.get('v.sobjectType') != 'Property__c'){
				 	sections.push('');
				// }
				
				console.log(picklistMap);
				for(var x in picklistMap){
					sections.push(x);
				}

				component.set('v.picklistMap', picklistMap);
				component.set('v.sections', sections);

				this.queryAttachments(component);
			}else if(state === 'ERROR'){
				console.log('--eror--');
			}
		});

		$A.enqueueAction(action);
	},

	// checkBoxFolderId : function(component){
	// 	var action = component.get('c.getRecord');
	// 	action.setParams({i : component.get('v.recordId')});

	// 	action.setCallback(this, function(response){
	// 		var state = response.getState();

	// 		if(state == 'SUCCESS'){
	// 			var record = JSON.parse(response.getReturnValue());
	// 			component.set('v.boxFolderId', record['Box_Folder_Id__c']);

	// 			if( $A.util.isEmpty(component.get('v.boxFolderId')) ){
	// 				component.set('v.message', 'Box folder Id is not set for this record');
	// 			}

	// 		}else if(state === 'ERROR'){
	// 			component.set('v.message', 'Error checking Box Folder Id');
	// 		}

	// 	});

	// 	$A.enqueueAction(action);

	// },

	saveFiles : function(component, files){
		var action = component.get('c.saveFile');
		action.setParams({
			file: JSON.stringify(file)
		});

		action.setCallback(this, function(response){
			var state = response.getState();

			if(state === 'SUCCESS'){
				console.log('success');
			}else if(state === 'ERROR'){
				console.log('error');
			}
		});

		$A.enqueueAction(action);
	},

	saveFile : function(component, file, index){
		return new Promise(function(resolve, reject) {

			var action = component.get('c.saveFile');
			console.log('sobjectType: ', component.get('v.sobjectType'));
			action.setParams({
				fileJSON: JSON.stringify(file),
				recordId: component.get('v.recordId'),
				sobjectType: component.get('v.sobjectType'),
				'recordType': component.get('v.recordType')
			});

			action.setCallback(this, function(response){
				var state = response.getState();

				if( state === 'SUCCESS'){
					//var retVal=response.getReturnValue();
					var uploadedFile = JSON.parse(response.getReturnValue());
					uploadedFile.status = 'uploaded';
                	resolve(JSON.parse(response.getReturnValue()), index);
                	//resolve(file);
				}else if (state === 'ERROR'){
					var errors = response.getError();
					//file.uploaded = 'failure';
	                if (errors) {
	                    if (errors[0] && errors[0].message) {
	                    	console.log(errors[0].message)
	                        //reject(Error("Error message: " + ));
	                        file.status = 'failed';
	                       	reject(file);
	                    }
	                }
	                else {
	                    //reject(Error("Unknown error"));
	                    file.status = 'failed';
	                    reject(file, index);
	                }
				}

			});

			if(!file.uploaded && !$A.util.isEmpty(file.section)){
				$A.enqueueAction(action);
			}else{
				file.status = '';
				resolve(file, index);
			}
		});

	},

	saveFilesPromise : function(component, helper, arr) {
	    return arr.reduce(function(promise, file, index) {
	    	file.status = 'uploading';
	    	var files = component.get('v.files');
	    	files[index] = file;
	    	component.set('v.files', files);
	        return promise.then($A.getCallback(function() {
	            return helper.saveFile(component, file, index).then($A.getCallback(function(res) {
	            	var files = component.get('v.files');
	            	files[index] = res;
	            	component.set('v.files', files);
	            }));
	        }));
	    }, Promise.resolve());
	}
})