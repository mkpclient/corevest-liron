({
  loadDocuments: function(component, helper, data, zip) {
    return data.reduce(function(promise, doc, index) {
      return promise.then(
        $A.getCallback(function() {
          component.set("v.currentIndex", index + 1);
          return helper.loadDocument(component, helper, doc, index, zip).then(
            $A.getCallback(function(res) {
              if (!$A.util.isEmpty(res)) {
              }
            })
          );
        })
      );
    }, Promise.resolve());
  },

  loadDocument: function(component, helper, doc, index, zip) {
    //resolve();

    return new Promise((resolve, reject) => {
      //console.log(index);
      //console.log(doc);

      var action = component.get("c.getDocumentData");
      action.setParams({ contentVersionId: doc.ContentVersion_Id__c });
      //console.log(action);
      action.setCallback(this, function(response) {
        var state = response.getState();

        if (state === "SUCCESS") {
          //console.log(doc);
          var data = response.getReturnValue();
          if (data.error !== "error" && data.error !== "deleted") {
            var path =
              component.get("v.dealLabel") +
              "/" +
              doc.Folder_String__c.replace(";", "/") +
              "/";

            if (!$A.util.isEmpty(doc.Property__c)) {
              path += doc.Property__r.Name + "/";
            }

            path += data.title;

            zip.file(path, data.data, { base64: true });
          } else if (data.error == "deleted") {
            //

            console.log("--deleted--");
            console.log(doc);

            let filesDeleted = component.get("v.filesDeleted");
            filesDeleted.push({
              // title: data.title,
              contentDocumentId: doc.ContentVersion_Id__c,
              // size: data.size,
              docType: doc.Document_Type__c,
              folder: doc.Folder_String__c.replace(";", "-")
            });

            component.set("v.filesDeleted", filesDeleted);
          } else {
            //let errorMsg = ''
            let filesTooBig = component.get("v.filesTooBig");
            filesTooBig.push({
              title: data.title,
              contentDocumentId: doc.ContentVersion_Id__c,
              size: data.size,
              docType: doc.Document_Type__c,
              folder: doc.Folder_String__c.replace(";", "-")
            });

            component.set("v.filesTooBig", filesTooBig);
          }

          resolve();
          //var data = JSON.parse(response.getReturnValue());
        } else if (state === "ERROR") {
          reject();
        }
      });

      $A.enqueueAction(action);

      //resolve();
    });
  },

  travelFolders: function(obj, set) {
    if (obj.checked && !$A.util.isEmpty(obj.folderString)) {
      set.add(obj.folderString);
    }

    if (!$A.util.isEmpty(obj.subFolders)) {
      Object.keys(obj.subFolders).forEach(key => {
        this.travelFolders(obj.subFolders[key], set);
      });
    }
  },

  returnFolderObj: function(obj) {
    var arr = [];
    //console.log(obj);
    if (!$A.util.isEmpty(obj.fileTypes) && obj.fileTypes.size > 0) {
      //console.log(!$A.util.isEmpty(obj.fileTypes));
      //console.log(obj);
      arr.push(obj);
    }

    if (!$A.util.isEmpty(obj.subFolders)) {
      Object.keys(obj.subFolders).forEach(key => {
        arr = arr.concat(this.returnFolderObj(obj.subFolders[key]));
      });
    }
    //console.log(arr);
    return arr;
  },

  compileFileTypes: function(component) {
    var fileTypes = component.get("v.fileTypes");
    var arr = [];

    fileTypes.forEach(el => {
      if (el.checked) {
        arr = arr.concat(el.fileTypesArr);
      }
    });

    component.set("v.fileTypesArr", Array.from(new Set(arr)));
  }
});