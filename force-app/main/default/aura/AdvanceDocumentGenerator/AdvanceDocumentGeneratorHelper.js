({
    loadFile : function(url, callback){
        JSZipUtils.getBinaryContent(url, callback);
    },
    
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
    
    uploadHelper: function(component, event, file) {
        var self = this;
        if (file.size > self.MAX_FILE_SIZE) {
            alert('File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }
        
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadProcess(component, file, fileContents);
        });
        
        objFileReader.readAsDataURL(file);
    },
    
    uploadProcess: function(component, file, fileContents, index) {
        var startPosition = 0;
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '', index, false);
    },
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId, index, allChunksComplete) {
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var emailBody=component.get("v.emailBody");
         emailBody=emailBody.split('<p><br></p>').join('<br>')
        emailBody=emailBody.split('<p>').join('');
        emailBody=emailBody.split('</p>').join('<br>')
        console.log('emailBody--->'+emailBody);
        var action = component.get("c.saveChunk");
        action.setParams({
			parentId : component.get("v.recordId"),
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fileId: attachId,
            allChunksComplete: allChunksComplete,
            emailAddress : component.get("v.emailAddress"),
            ccAddress : component.get("v.ccAddress"),
            bccAddress : component.get("v.bccAddress"),
            subject : component.get("v.subject"),
            emailBody : emailBody,
            attachedFileIds : this.filterFileIds(component)
        });
        
        // set call back 
        action.setCallback(this, function(response) {
            if(component.isValid() && response.getState() == "SUCCESS"){
                attachId = response.getReturnValue();
                
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);

                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId, index,false);
                }else if(!allChunksComplete){
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId, index, true);
                }else{	
                    //alert('Attachment sent successfully.');
                    this.showToast(component,"success", "Success!", "Email sent successfully.");
                     var cmpEvent = component.getEvent("cmpEvent");
                     cmpEvent.fire();
                }
            } else if (response.getState() === "ERROR") {
                component.set("v.showLoadingSpinner", false);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        alert("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
        });
        $A.enqueueAction(action);
    },
    filterFileIds : function(component){
        var fileIds=component.get("v.fileIds");
        var filteredFileIds=[];
        fileIds.forEach(function(item) {
            filteredFileIds.push(item.documentId);
        });
        return filteredFileIds;   
	},
    showToast : function(component, type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent){
            toastEvent.setParams({
                "mode": "dismissible",
                "type": type,
                "title": title,
                "message": message
            });
            toastEvent.fire();
        }
        
    },
})