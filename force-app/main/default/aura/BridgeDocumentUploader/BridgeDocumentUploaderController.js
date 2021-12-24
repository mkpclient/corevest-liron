({
	init : function(component, event, helper) {
		helper.queryPicklists(component);
		//helper.queryAttachments(component);
		//helper.checkBoxFolderId(component);
		console.log(component.get('v.recordId'));
	},

	picklistChange : function(component, event, helper){
		var target = event.getSource();
		var rowString = target.get('v.class');
		var row = rowString.split('-')[1];

		var files = component.get('v.files');
		console.log(files[row]);
		files[row].documentType = '';
		files[row].typeOptions = component.get('v.picklistMap')[files[row].section];
		component.set('v.files', files);
		//console.log(component.get('v.files'));
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

	}
})