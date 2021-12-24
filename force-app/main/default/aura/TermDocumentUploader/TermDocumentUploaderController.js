({
	init : function(component, event, helper) {
		helper.queryPicklists(component);
		console.log(component.get('v.recordId'));
		// console.log('--test--');
	},

	picklistChange : function(component, event, helper){
		var target = event.getSource();
		

		var rowString = target.get('v.class');
		console.log(rowString);
		if(rowString == 'bulk'){

			var typeOptions = component.get('v.picklistMap')[component.get('v.section')];

			console.log(typeOptions);

			component.set('v.documentTypes', typeOptions);

			var files = component.get('v.files');


			files.forEach( function ( file ) {
				file.section = component.get('v.section');

				file.documentType = '';
				file.typeOptions = typeOptions;
			 } );

			component.set('v.files', files);

		}else{
			var row = rowString.split('-')[1];

			var files = component.get('v.files');
			//console.log(files[row]);

			files[row].typeOptions = component.get('v.picklistMap')[files[row].section];

			//console.log(files[row].typeOptions.indexOf(files[row].documentType));

			//if(files[row].typeOptions.indexOf(files[row].documentType) == -1){
				files[row].documentType = '';
			//}

			component.set('v.files', files);
		}
	},

	saveFiles : function(component, event, helper){

		var promises = [];

		var files = component.get('v.files');

		helper.saveFilesPromise(component, helper, files).then(function(){
			console.log('all done');
		});
	},

	deleteAttachment : function(component, event, helper){
		console.log('delete');
		console.log(event.getSource().get('v.value'));

		var rowIndex = event.getSource().get('v.value');

		var files = component.get('v.files');

		var toDelete = files.splice(rowIndex, 1);
		var attachments = [];
		for(var i = 0; i < toDelete.length; i++){
			var attachment = {
				'Id': toDelete[i].attachmentId,
				'sobjectType': 'Attachment'
			}

			attachments.push(attachment);
		}
		console.log(component);

		var action = component.get('c.deleteRecords');

		action.setParams({ records : attachments});

		action.setCallback(this, function(response){
			var state = response.getState();

			if(state === 'SUCCESS'){
				console.log('delete success');
				component.set('v.files', files);
			}else if(state === 'ERROR'){
				console.log('delete errors');
			}
		});

		$A.enqueueAction(action);

	},

	documentTypeChange : function(component, event, helper){
		var documentType = component.get('v.documentType');
		var docTypes = component.get('v.documentTypes');
		var section = component.get('v.section');

		var files = component.get('v.files');

		files.forEach ( function ( file ) {
			
			if(file.section != section){
				file.section = section;
				file.typeOptions = docTypes; 
			}

			file.documentType = documentType;
		});

		component.set('v.files', files);

	},

	filesChanged : function(component, event, helper){
		console.log('files changed');
	}
})