({
    doInit: function(component, event, helper) {
        var action = component.get("c.getDealIdFromProperty");
        action.setParams({
            propertyId: component.get("v.recordId")
        });
        action.setCallback(this,function(data){
            var state = data.getState();
            var responseMap = data.getReturnValue();
            if(state == "SUCCESS"){
                console.log('responseMap=>'+JSON.stringify(responseMap));
                component.set("v.dealId", responseMap.dealId);
            }else if(state = "ERROR"){
                //alert('Unknow error');
            }
            
        });
        $A.enqueueAction(action);
    },
    test: function(component, event, helper) {
        console.log("test");
        
        let vendors = component.find("vendors");
        
        console.log(vendors);
        vendors.clickMe();
    },

  openEmailModal: function(component, event, helper) {
    console.log("open email");
    console.log(JSON.parse(JSON.stringify(event.getParams())));

    let ToAddress = event.getParam("toAddressEmail");
    let template = event.getParam("template");
    //let

    var actionAPI = component.find("quickActionAPI");

    // actionAPI.getAvailableActionFields({ actionName: 'Opportunity.Send_Email' })
    //     .then(args => {
    //         console.log(JSON.parse(JSON.stringify(args)));
    //         actionAPI.invokeAction(args);
    //     }).catch(error => {
    //         console.log(error);
    //     })

    let targetFields = {
      HtmlBody: { value: template.HtmlValue },
      Subject: { value: template.Subject },
      ToAddress: { value: ToAddress }
    };

    actionAPI
      .setActionFieldValues({
        actionName: "Property__c.Send_Email",
        targetFields: targetFields
      })
      .then(results => {
        console.log(JSON.parse(JSON.stringify(results)));
      })
      .catch(error => {
        alert(JSON.stringify(error));
          console.log(error);
      });

    console.log("fire");
  },

  closeModal: function(component, event, helper) {
    $A.util.toggleClass(component.find("modal"), "slds-fade-in-open");
    $A.util.toggleClass(component.find("backdrop"), "slds-backdrop_open");
  },

  templateChanged: function(component, event, helper) {
    console.log("tempalte changed");

    console.log(JSON.parse(JSON.stringify(event.getParams())));
    let templateId = event.getParam("value");
    // component.set('v.templateId')
    let whoId = component.get("v.whoId");
    let whatId = component.get("v.recordId");

    component
      .find("vendors")
      .compileEmail({
        whoId: component.get("v.whoId"),
        templateId: templateId,
        whatId: component.get("v.recordId")
      })
      .then(results => {
        console.log(results);
        results = results.replace(/\t/g, "&nbsp;&nbsp;&nbsp;&nbsp;");
        results = results.replace(/(?:\r\n|\r|\n)/g, "<br/>");
        let message = JSON.parse(results);
        // console.log('<html>' + message.htmlBody + '</html>');
        let htmlBody = message.htmlBody;

        console.log("here?");
        component.find("richtextinput").set("v.value", htmlBody);
        // component.set('v.subject', message.subject);
      })
      .catch(error => {
        console.log(error);
      });

    // component.find('vendors').queryTemplate(templateId)
    //     .then(results => {
    //         let template = results[0];
    //         let body = template.HtmlValue;
    //         console.log('results');
    //         console.log(results);
    //         component.find('richtextinput').set('v.value', body);

    //     }).catch(error => {

    //         console.log('error');
    //         console.log(error);
    //     })
  }
});