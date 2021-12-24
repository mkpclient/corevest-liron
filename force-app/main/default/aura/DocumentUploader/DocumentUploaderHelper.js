({
  queryAttachments: function (component) {
    var action = component.get("c.getAttachments");
    action.setParams({
      recordId: component.get("v.recordId"),
      dealDocumentId: component.get("v.documentId")
    });

    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        //component.set('v.files', JSON.parse(response.getReturnValue()));
        var files = JSON.parse(response.getReturnValue());

        //console.log(component.get('v.files'));
        component.get("v.sobjectType");
        if (component.get("v.sobjectType") == "Property__c") {
          var picklistMap = component.get("v.picklistMap");
          files.forEach(function (el) {
            el.typeOptions = picklistMap[Object.keys(picklistMap)[0]];
            el.section = Object.keys(picklistMap)[0];
          });
        }

        component.set("v.files", files);

        console.log(component.get("v.files"));
      } else if (state === "ERROR") {
      }
    });

    $A.enqueueAction(action);
  },

  queryPicklists: function (component) {
    var action = component.get("c.getPicklists");
    action.setParams({
      sobjectType: component.get("v.sobjectType"),
      recordType: component.get("v.recordType"),
      userType: component.get("v.userType"),
      accountId: component.get("v.accountId"),
      accountType: component.get("v.accountType")
    });

    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        var picklistMap = JSON.parse(response.getReturnValue());
        var sections = [];
        // if(component.get('v.sobjectType') != 'Property__c'){
        sections.push("");
        // }
        console.log("---picklist map---");
        console.log(picklistMap);
        for (var x in picklistMap) {
          picklistMap[x].push("");
          picklistMap[x].reverse();
          sections.push(x);
        }

        component.set("v.picklistMap", picklistMap);
        component.set("v.sections", sections);

        console.log(sections);
        this.queryAttachments(component);
      } else if (state === "ERROR") {
        console.log("--eror--");
      }
    });

    $A.enqueueAction(action);
  },

  queryValidations: function (component) {
    var action = component.get("c.getDocumentValidations");
    action.setParams({
      sobjectType: component.get("v.sobjectType"),
      recordType: component.get("v.recordType"),
      userType: component.get("v.userType"),
      accountId: component.get("v.accountId"),
      accountType: component.get("v.accountType")
    });

    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        // var picklistMap = JSON.parse(response.getReturnValue());
        // var sections = [];
        // // if(component.get('v.sobjectType') != 'Property__c'){
        // sections.push("");
        // // }
        // console.log("---picklist map---");
        // console.log(picklistMap);
        // for (var x in picklistMap) {
        //   sections.push(x);
        // }

        // component.set("v.picklistMap", picklistMap);
        // component.set("v.sections", sections);

        // console.log(sections);
        // this.queryAttachments(component);

        const validationMap = JSON.parse(response.getReturnValue());
        console.log(validationMap);
        component.set("v.validationMap", validationMap);
      } else if (state === "ERROR") {
        console.log("--eror--");
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

  saveFiles: function (component, files) {
    var action = component.get("c.saveFile");
    action.setParams({
      file: JSON.stringify(file)
    });

    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        console.log("success");
      } else if (state === "ERROR") {
        console.log("error");
      }
    });

    $A.enqueueAction(action);
  },

  saveFile: function (component, file, index) {
    return new Promise(function (resolve, reject) {
      var action = component.get("c.saveFile");
      console.log("sobjectType: ", component.get("v.sobjectType"));

      var recordId = component.get("v.recordId");
      if (!$A.util.isEmpty(file.parentId)) {
        recordId = file.parentId;
      }

      if (
        component.get("v.uploadType") == "bulk" &&
        component.get("v.sobjectType") == "Property__c"
      ) {
        file.section = component.get("v.section");
        file.documentType = component.get("v.documentType");
      }

      action.setParams({
        fileJSON: JSON.stringify(file),
        recordId: recordId,
        sobjectType: component.get("v.sobjectType")
      });

      action.setCallback(this, function (response) {
        var state = response.getState();

        if (state === "SUCCESS") {
          //var retVal=response.getReturnValue();
          var uploadedFile = JSON.parse(response.getReturnValue());
          uploadedFile.status = "uploaded";
          resolve(JSON.parse(response.getReturnValue()), index);
          //resolve(file);
        } else if (state === "ERROR") {
          var errors = response.getError();
          //file.uploaded = 'failure';
          if (errors) {
            if (errors[0] && errors[0].message) {
              console.log(errors[0].message);
              //reject(Error("Error message: " + ));
              file.status = "failed";
              reject(file);
            }
          } else {
            //reject(Error("Unknown error"));
            file.status = "failed";
            reject(file, index);
          }
        }
      });

      //console.log(file);

      if (
        !file.uploaded &&
        !$A.util.isEmpty(file.section) &&
        !$A.util.isEmpty(file.documentType)
      ) {
        file.missingType = false;
        if (
          component.get("v.uploadType") != "bulk" ||
          component.get("v.sobjectType") != "Property__c"
        ) {
          $A.enqueueAction(action);
          //console.log("1");
        } else if (!$A.util.isEmpty(file.parentId)) {
          $A.enqueueAction(action);
          //console.log("2");
        } else {
          //console.log("3");
          file.status = "";
          resolve(file, index);
        }
      } else {
        console.log("4");
        file.missingType = true;
        file.status = "";
        resolve(file, index);
      }
    });
  },

  saveFilesPromise: function (component, helper, arr) {
    return arr.reduce(function (promise, file, index) {
      if (file.uploaded || file.requireValidations) {
        return promise;
      } else {
        file.status = "uploading";
        var files = component.get("v.files");
        files[index] = file;
        component.set("v.files", files);
        return promise.then(
          $A.getCallback(function () {
            return helper.saveFile(component, file, index).then(
              $A.getCallback(function (res) {
                var files = component.get("v.files");
                files[index] = res;
                component.set("v.files", files);
              })
            );
          })
        );
      }
    }, Promise.resolve());
  }
});