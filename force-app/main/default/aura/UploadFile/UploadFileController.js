/* fileUploadController2.js is identical */
({

    init : function(component, event, helper){
        console.log('init');

        var processId = component.get('v.recordId');

        var queryString = 'SELECT ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.RecordType.Name FROM ProcessInstanceWorkItem WHERE Id = \'' + processId + '\' LIMIT 1';

        component.find('util').query(queryString, function(piwi){
            console.log('piwi = ', piwi);

            if(!$A.util.isEmpty(piwi)){
                var oppId = piwi[0].ProcessInstance.TargetObjectId;


                component.set('v.dealId', oppId);

                console.log('dealId = ', oppId);
                // console.log(oppId);

                // var docQueryString = 'SELECT Id, File_Name__c,ContentVersion_Id__c, Document_Type__c, Attachment_Id__c, Added_By__r.Name From Deal_Document__c WHERE Deal__c = \'' + oppId + '\'';

                // var whereClause = component.get('v.whereClause');
                // if(!$A.util.isEmpty(whereClause)){
                //     docQueryString += ' AND (' + whereClause + ')';
                // }

                // component.find('util').query(docQueryString, function(docs){
                //     console.log(docs);
                //     component.set('v.files', docs);
                // });


            }

        })

    },

    save : function(component, event, helper) {
        helper.save(component);
    },

    waiting: function(component, event, helper) {
		// helper.toggleHide(component);

    	$A.util.addClass(component.find("uploading").getElement(), "uploading");
    	$A.util.removeClass(component.find("uploading").getElement(), "notUploading");
    },

    doneWaiting: function(component, event, helper) {
		// helper.toggleHide(component);

    	$A.util.removeClass(component.find("uploading").getElement(), "uploading");
    	$A.util.addClass(component.find("uploading").getElement(), "notUploading");

    },

	closeModal : function(component, event, helper){
		document.querySelector('.slds-fade-in-open').classList.remove('slds-fade-in-open');
		document.querySelector('.slds-backdrop_open').classList.remove('slds-backdrop_open');
		document.querySelector('input.file').value = '';
	},

    handleUploadFinish : function(component, event){
        console.log( 'upload finished');

        var uploadedFiles = event.getParam('files');

        console.log(uploadedFiles);
        //alert("Files uploaded: ")

        var ids = [];
        uploadedFiles.forEach(function(data){
            ids.push(data.documentId);
        });

        var action = component.get('c.createDealDocuments');

        action.setParams({
            ids: ids,
            dealId: component.get('v.dealId')
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
                console.log('upload success');
                $A.get('e.force:refreshView').fire();
            }else if(state === 'ERROR'){
                console.log('stuff');
                console.log(response.getError());
            }

        });

        $A.enqueueAction(action);


    }
})