({
	init : function(component, event, helper) {
		console.log('init');

		var action = component.get('c.getSession');
        action.setCallback(this, function(response){
            var state = response.getState();

            if(state == 'SUCCESS'){
                var res = JSON.parse(response.getReturnValue());
                console.log('--res--', res);
                component.set('v.sessionId', res.sessionId);
                component.set('v.sfInstanceUrl', res.endpoint);
                component.set('v.userId', res.userId);
                component.set('v.communityId', res.community);

                console.log(component.get('v.sessionId'));
                console.log(component.get('v.sfInstanceUrl'));
                console.log(component.get('v.userId'));
                console.log(component.get('v.communityId'));

            }else if(state === 'ERROR'){
                console.log('error');
                console.log(response.getError());
            }

        });

        $A.enqueueAction(action);


        helper.queryFiles(component);
		
		helper.compilePicklists(component);

	},

	handleFiles : function(component, event, helper){
		$A.util.toggleClass(component.find('spinner'), 'slds-hide');

		var files = component.find('uploader').get('v.files')
		
		// if(!$A.util.isArray(files)){
		// 	files = [files];
		// }

		var fileList = [];
		console.log(files.length);
		for(var i = 0; i < files.length; i++){
			fileList.push(files[i]);
		}

		console.log(fileList);

		helper.readFiles(component, helper, fileList, component.get('v.recordId')).then(function(){
			console.log('all done');
			$A.util.toggleClass(component.find('spinner'), 'slds-hide');
			// component.find('inputFile').getElement().value = '';
			helper.queryFiles(component);

			component.find('uploader').set('v.value', '');
		});

		



	},

	onDragOver : function(component, event, helper){
		console.log('drag');
		event.preventDefault();
	},

	onDrop : function(component, event, helper){
		console.log('drop');
		event.stopPropagation();
		event.preventDefault();
		$A.util.removeClass(component.find('spinner'), 'slds-hide');
		event.dataTransfer.dropEffect = 'copy';
		var files = event.dataTransfer.files;
		var fileList = [];
		for(var i = 0; i < files.length; i++){
			fileList.push(files[i]);
		}
		helper.readFiles(component, helper, fileList, component.get('v.parentId')).then(function(){
			console.log('all done');
			$A.util.addClass(component.find('spinner'), 'slds-hide');
		});

	},

	picklistChange : function(component, event, helper){
		var target = event.getSource();
		

		var rowString = target.get('v.class');
		console.log(rowString);
		if(rowString == 'bulk'){

			var typeOptions = component.get('v.picklistMap')[component.get('v.folder')];

			console.log(typeOptions);

			component.set('v.documentTypes', typeOptions);

			var files = component.get('v.files');


			files.forEach( function ( file ) {
				file.Folder__c = component.get('v.Folder__c');

				file.Type__c = '';
				file.typeOptions = typeOptions;
			 } );

			component.set('v.files', files);

		}else{
			var row = rowString.split('-')[1];

			var files = component.get('v.files');

			files[row].typeOptions = component.get('v.picklistMap')[files[row].Folder__c];

			//console.log(files[row].typeOptions.indexOf(files[row].documentType));

			//if(files[row].typeOptions.indexOf(files[row].documentType) == -1){
			files[row].Type__c = '';
			//}

			component.set('v.files', files);
		}
	},

	saveFiles : function(component, event, helper){
		console.log(component.get('v.files'));

		var files = component.get('v.files');
		var updateFiles = [];
		files.forEach(function(file){
			if(!$A.util.isEmpty(file.Folder__c) && !$A.util.isEmpty(file.Type__c)){
				file['Parent_Object__c'] = component.get('v.sobjectType');
				file['sobjectType'] = 'ContentVersion';

				updateFiles.push(file);
			}

		});

		console.log(updateFiles);

		if(!$A.util.isEmpty(updateFiles)){
			component.find('util').upsert(updateFiles, function(resp){
				helper.queryFiles(component);
			})
		}


	} 
})