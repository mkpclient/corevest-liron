({
	CHUNK_SIZE: 950 000,
    MAX_FILE_SIZE: 4 275 000,
    MAX_FILE_SIZE_API: 20 000 000, 

    compilePicklists : function(component){
    	

    	component.find('util').getDependentPickists('ContentVersion', 'Parent_Object__c', 'Folder__c', function(resp){
    		component.set('v.folders', [''].concat(resp[component.get('v.sobjectType')]));
    	})

    	component.find('util').getDependentPickists('ContentVersion', 'Folder__c', 'Type__c', function(resp){
    		component.set('v.picklistMap', resp);
    	});
    },

    queryFiles : function(component){
    	var queryString = 'SELECT Id, ContentDocumentId, ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink ';
    	queryString += ' WHERE LinkedEntityId = \'' + component.get('v.recordId') + '\'';
    	component.find('util').query(queryString, function(data){
    		
    		if(!$A.util.isEmpty(data)){
    			var idSet = '(';
    			data.forEach(function(doc){
    				idSet += '\'' + doc.ContentDocument.LatestPublishedVersionId + '\', ';
    			});

    			idSet = idSet.substring(0, idSet.lastIndexOf(','));

    			idSet += ')';
    			component.find('util').query('SELECT Id, Type__c, Folder__c, Title, ContentSize FROM ContentVersion WHERE Type__c = null AND Id IN ' + idSet, function(versionData){
    				//console.log(versionData);
    				console.log(versionData);
    				component.set('v.files', versionData);
    			})
    		}

    	})
    },

    readFiles : function(component, helper, arr, parentId){
        return arr.reduce(function(promise, file, index) {
    
            return promise.then($A.getCallback(function() {
                return helper.readFile(component, helper, file, parentId, index).then($A.getCallback(function(res){
                    console.log('done in promise');
                    if(!$A.util.isEmpty(res)){
                        var files = component.get('v.files');
                        files.push(res);
                        component.set('v.files', files);
                    }
                }));
            }));
        }, Promise.resolve());
    },

    readFile : function(component, helper, file, parentId) {
        return new Promise(
            function(resolve, reject){
                // var fr = new FileReader();
                // fr.onload = $A.getCallback(function(event){
                //     var data = event.target.result;
                //     var fileContents = data.match(/,(.*)$/)[1];
                //     var fromPos = 0;
                //     var toPos = Math.min(fileContents.length, fromPos + helper.CHUNK_SIZE);

                //     helper.forceTkUpload(component, helper, file,fileContents, parentId, resolve, reject);
                    
                // })
                
                // if(file.size >= helper.MAX_FILE_SIZE){
                    // if(file.size < helper.MAX_FILE_SIZE_API && component.get('v.uploaderType') != 'portal'){
                        helper.forceTkUpload(component, helper, file, null, parentId, resolve, reject);
                    // }else{
                        // var obj = {
                //             name : file.name,
                //             size : file.size,
                //             message : 'file to big'
                //         }
                //         resolve(obj);
                //     }
                // }else{
                //     fr.readAsDataURL(file);
                // }
            }

        );

    },
    forceTkUpload : function(component, helper, file, fileContents, parentId, resolve, reject) {
        console.log('inside forceTk upload');
        var sessionId = component.get("v.sessionId");
        var sfInstanceUrl = component.get("v.sfInstanceUrl");
        var userId = component.get('v.userId');
        var communityId = component.get('v.communityId');
        var client = new forcetk.Client();
        client.setSessionToken(sessionId ,'v36.0',sfInstanceUrl);
        client.proxyUrl = null;
        this.visualforce = false;

        console.log(component.get('v.parentId'));
        console.log(file);
        try{

            var param = {
            'Origin': 'H',
            'PathOnClient': file.name,
            'FirstPublishLocationId' : component.get('v.recordId'),
            }

            console.log(param);

            if(location.href.includes('dealrequest')){
                console.log('in community');
                param.NetworkId = communityId
            }

            client.createBlob('ContentVersion', param, 

                   file.name, 'VersionData', file , $A.getCallback(function(response)
                   {
                       if(response.id !== null)
                       {
                            console.log(response);
                            console.log(component.get('v.parentId'));
                                // var action = component.get('c.linkFileToRecord');

                                // var ContentDocumentId = response.id
                                //    action.setParams({
                                //         fileIds : [response.id],
                                //         parentId : component.get('v.parentId')

                                //    });

                                //    action.setCallback(this, function(response){
                                //         var state = response.getState();
                                //         console.log(state);
                                //         if(state === 'SUCCESS'){
                                //             var contentId = JSON.parse(response.getReturnValue())[0].ContentDocumentId;
                                //             var today = new Date();

                                //             var fileObj = {
                                //                 ContentDocumentId : contentId,
                                //                 title : file.name,
                                //                 size : file.size,
                                //                 linkedToRecord : true
                                //             };

                                //             resolve(fileObj);
                                //         }else if(state === 'ERROR'){
                                //             console.log('error');
                                //             console.log(response.getError());
                                //             resolve();
                                //         }


                                //    });
                                //     $A.enqueueAction(action);
                                resolve();
                           
                       }
                       else
                       {    
                            console.log(response.errors[0].message);
                            console.log('error');
                         
                       }
                   }), 
                   function(request, status, response)
                   {
                     
                       resolve();

            });
        }catch(e){
            var obj = {
                name : file.name,
                size : file.size,
                message : 'file to big'
            }
            resolve(obj);
        }
    }
})