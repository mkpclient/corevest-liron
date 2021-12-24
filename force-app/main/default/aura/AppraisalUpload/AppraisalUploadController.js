({
  init: function (component, event, helper) {
    console.log("test");
    //component.set("v.randomId", "_" + Math.random().toString(36).substr(2, 9));
    var action = component.get("c.getSession");
    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state == "SUCCESS") {
        //var sessionId = response.getReturnValue();
        var res = JSON.parse(response.getReturnValue());
        //var url = window.location.href;
        //var splitUrl = url.split("/s")
        //var sfInstanceUrl = splitUrl[0];
        //console.log(sfInstanceUrl);

        component.set("v.sessionId", res.sessionId);
        component.set("v.sfInstanceUrl", res.endpoint);
        console.log("--res--");
        console.log(res);
      } else if (state === "ERROR") {
        //resolve();
        console.log("error");
        console.log(response.getError());
      }
    });

    $A.enqueueAction(action);
  },
  fileChanged: function (component, event, helper) {
    console.log("file changed");

    let files = event.getSource().get("v.files");

    // console.log(files);

    if (files && files.length > 0) {
      let fr = new FileReader();

      fr.onload = $A.getCallback((res) => {
        // console.log(res);
        let data = res.target.result;
        // console.log(data);
        console.log(fr.file);
        let uploadFiles = helper.splitXML(data);
        //console.log(uploadFiles);
        const fileName = fr.file.name.split(".xml")[0];

        helper.forceTkUpload(component, helper, uploadFiles, fileName);
      });

      fr.file = files[0];
      //   console.log(files[0]);
      fr.readAsText(files[0]);
    }
  }
});