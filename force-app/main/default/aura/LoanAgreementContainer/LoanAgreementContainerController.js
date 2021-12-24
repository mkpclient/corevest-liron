({
  init: function (component, event, helper) {
    console.log("doc generator init");
  },

  initEmail: function (component, event, helper) {
    console.log("init email");
    let defaults = event.getParams();
    // console.log(defaults);

    component.find("emailComposer").openModal(defaults);
  },

  generateLoanAgreement: function (component, event, helper) {
    console.log("generate document");

    let loanAgreement = event.getParams();
    console.log(loanAgreement);

    component
      .find("util")
      .getFileFromStaticResource(
        component.get("v.StaticResourceName"),
        "LoanAgreement.docx"
      )
      .then(
        $A.getCallback((response) => {
          console.log(response);

          //console.log(params);
          helper.loadFile(response, function (error, content) {
            if (error) {
              throw error;
            }
            var zip = new JSZip(content);
            var expressions = require("angular-expressions");

            // expressions.Parser.filter = {};
            //expressions.filters = {};
            console.log(expressions);

            // expressions.filters.formatCurrency = function(input){
            // 	if(!input) return input;
            // 	return '$'+input;
            // }

            // expressions.filters.today = function(input){
            // 	return 'September 24, 2018'
            // }

            // expressions.Parser.$filter = expressions.filter;
            // expressions.filter.today(input){

            // }

            var angularParser = function (tag) {
              //console.log(tag);

              return {
                get:
                  tag === "."
                    ? function (s) {
                        return s;
                      }
                    : function (s) {
                        return expressions.compile(
                          tag.replace(/(’|“|”)/g, "'")
                        )(s);
                      }
              };
            };

            var doc = new Docxtemplater()
              .loadZip(zip)
              .setOptions({ parser: angularParser });
            console.log(loanAgreement);
            if (!loanAgreement.YM_Prepayment_Penalty_Description__c) {
              loanAgreement.YM_Prepayment_Penalty_Description__c = "";
            }
            doc.setData(loanAgreement);

            try {
              // render the document (replace all occurences of {first_name} by John, {last_name} by Doe, ...)
              doc.render();
            } catch (error) {
              var e = {
                message: error.message,
                name: error.name,
                stack: error.stack,
                properties: error.properties
              };
              console.log(JSON.stringify({ error: e }));
              // The error thrown here contains additional information when logged with JSON.stringify (it contains a property object).
              throw error;
            }
            var out = doc.getZip().generate({
              type: "blob",
              mimeType:
                "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
            }); //Output the document using Data-URI

            let fileName = loanAgreement.Full_Name__c;
            //fileName = fileName.replace(/\//g, "");
            //fileName = fileName.replace(/\s/g, "_");

            if (!component.get("v.isSendEmail")) {
              saveAs(out, fileName + ".docx");
            } else {
              console.log("File Generated-->" + out);
              helper.uploadHelper(component, event, out);
            }
          });
        })
      );
  }
});