({
  splitXML: function (xmlFile) {
    // let result = xmlFile
    //   .match(/<DOCUMENT>(.*?)<\/DOCUMENT>/g)
    //   .map(function (val) {
    //     return val.replace(/<\/?b>/g, '');
    //   });

    //let result = xmlFile.match(/<DOCUMENT>(.*?)<\/DOCUMENT>/g);

    //console.log(result);

    //let startIndex = xmlFile.lastIndexOf('<DOCUMENT>') + 10;
    //l/et endInd

    let pdfFile = xmlFile.substring(
      xmlFile.lastIndexOf("<DOCUMENT>") + 10,
      xmlFile.lastIndexOf("</DOCUMENT>")
    );

    xmlFile = xmlFile.replace(pdfFile, "");

    return [xmlFile, pdfFile];
    //console.log(xmlFile);
    //console.log(pdfFile);
  },

  forceTkUpload: function (component, helper, files, fileName) {
    var sessionId = component.get("v.sessionId");
    var sfInstanceUrl = component.get("v.sfInstanceUrl");
    //sfInstanceUrl = "https://cs93.salesforce.com";
    if (
      sfInstanceUrl == "https://cvest--qa.salesforce.com/" ||
      "https://cvest--full.salesforce.com/"
    ) {
      sfInstanceUrl = "https://cs201.salesforce.com";
    }

    console.log(files);
    console.log(sessionId);
    console.log(sfInstanceUrl);

    var client = new forcetk.Client();
    client.setSessionToken(sessionId, "v36.0", sfInstanceUrl);
    client.proxyUrl = null;

    var recordId = component.get("v.recordId");

    console.log(recordId);

    client.createBlob(
      "ContentVersion",
      { Origin: "C", PathOnClient: fileName + ".xml" },
      fileName + ".xml",
      "VersionData",
      new Blob([files[0]], {
        type: "text/xml"
      }),
      $A.getCallback(function (response) {
        console.log("stuff");
        console.log(response);

        let action = component.get("c.attachFileToParent");
        action.setParams({
          contentVersionId: response.id,
          parentId: component.get("v.recordId")
        });

        action.setCallback(this, (resp) => {
          let state = resp.getState();

          if (state === "SUCCESS") {
            // console.log("success xml");
            var toast = $A.get("e.force:showToast");
            toast.setParams({
              type: "success",
              message: "Appraisal XML successfully uploaded"
            });

            toast.fire();
          } else if (state === "ERROR") {
            console.log("error xml");
            console.log(resp.getError());
          }
        });

        $A.enqueueAction(action);
      }),
      $A.getCallback(function (request, status, response) {
        console.log(status);
      })
    );

    client.createBlob(
      "ContentVersion",
      { Origin: "C", PathOnClient: fileName + ".pdf" },
      fileName + ".pdf",
      "VersionData",
      helper.b64ToBlob(files[1], "application/pdf"),
      $A.getCallback(function (response) {
        console.log("stuff");
        console.log(response);

        let action = component.get("c.attachFileToParent");
        action.setParams({
          contentVersionId: response.id,
          parentId: component.get("v.recordId")
        });

        action.setCallback(this, (resp) => {
          let state = resp.getState();

          if (state === "SUCCESS") {
            console.log("success pdf");
          } else if (state === "ERROR") {
            console.log("error pdf");
            console.log(resp.getError());
          }
        });

        $A.enqueueAction(action);
      }),
      $A.getCallback(function (request, status, response) {
        console.log(status);
      })
    );
  },

  b64ToBlob: function (b64Data, contentType) {
    const sliceSize = 512;
    const byteCharacters = atob(b64Data);
    const byteArrays = [];

    for (let offset = 0; offset < byteCharacters.length; offset += sliceSize) {
      const slice = byteCharacters.slice(offset, offset + sliceSize);

      const byteNumbers = new Array(slice.length);
      for (let i = 0; i < slice.length; i++) {
        byteNumbers[i] = slice.charCodeAt(i);
      }

      const byteArray = new Uint8Array(byteNumbers);
      byteArrays.push(byteArray);
    }

    const blob = new Blob(byteArrays, { type: contentType });
    return blob;
  }
});