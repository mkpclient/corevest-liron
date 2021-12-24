({
  serverSideCall: function(action, component) {
    return new Promise(function(resolve, reject) {
      action.setCallback(this, function(response) {
        var state = response.getState();
        if (component.isValid() && state === "SUCCESS") {
          resolve(response.getReturnValue());
        } else if (component.isValid() && state === "ERROR") {
          reject(new Error(response.getError()));
        }
      });
      $A.enqueueAction(action);
    });
  },

  base64ToArrayBuffer: function(base64) {
    var binary_string = window.atob(base64);
    var len = binary_string.length;
    var bytes = new Uint8Array(len);
    // console.log(binary_string);
    console.log(len);
    for (var i = 0; i < len; i++) {
      bytes[i] = binary_string.charCodeAt(i);
    }
    return bytes.buffer;
  }
});