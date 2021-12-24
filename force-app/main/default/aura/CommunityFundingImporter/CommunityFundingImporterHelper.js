({
  fields: [
    { fieldName: "RecordTypeId", type: "text" },
    { fieldName: "Name", type: "text" },
    { fieldName: "City__c", type: "text" },
    { fieldName: "State__c", type: "text" },
    { fieldName: "ZipCode__c", type: "text" },
    { fieldName: "Property_Type__c", type: "text" },
    { fieldName: "Number_of_Units__c", type: "numeric" },
    { fieldName: "Number_of_Beds__c", type: "numeric" },
    { fieldName: "Number_of_Bath__c", type: "text" },
    { fieldName: "Square_Feet__c", type: "text" },
    { fieldName: "Refinance_Acquisition__c", type: "text" },
    { fieldName: "Requested_Funding_Date__c", type: "date" },
    { fieldName: "Acquisition_Price__c", type: "numeric" },
    { fieldName: "Acquisition_Date__c", type: "date" },
    { fieldName: "Contract_Close_Date__c", type: "date" },
    { fieldName: "Title_Company_text__c", type: "text" },
    { fieldName: "Title_Contact_Name__c", type: "text" },
    { fieldName: "Title_Contact_Phone__c", type: "text" },
    { fieldName: "Title_Contact_Email_Address__c", type: "text" },
    { fieldName: "Interior_Access_POC__c", type: "text" },
    { fieldName: "Interior_Access_POC_Phone__c", type: "text" },
    { fieldName: "Interior_Access_POC_Email__c", type: "text" }
  ],

  readFile: function(file, component, helper) {
    var reader = new FileReader();
    reader.onload = $A.getCallback(function(event) {
      var data = event.target.result;

      // console.log(file);
      var validated = false;
      var records = [];
      if (
        file.type ==
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      ) {
        var resp = helper.handleXlsx(component, data, helper);
        //records = resp.records;

        component.set("v.properties", resp.records);
      }

      //$A.util.toggleClass(component.find('spinner'), 'slds-hide');
    });

    reader.readAsArrayBuffer(file);
  },

  handleXlsx: function(component, data, helper) {
    var arr = helper.fixdata(data);
    var workbook = XLSX.read(btoa(arr), { type: "base64" });
    var sheetName = workbook.SheetNames[0];
    // console.log(workbook);
    // console.log(workbook);
    var csv = XLSX.utils.sheet_to_csv(workbook.Sheets[sheetName]);
    var rows = csv.split("\n");
    var startNumber = 9;

    var importList = [];
    for (var i = startNumber; i < rows.length; i++) {
      if (!$A.util.isEmpty(rows[i])) {
        var row = helper.CSVToArray(rows[i])[0];
        //console.log(row);
        if ($A.util.isEmpty(row[1]) && $A.util.isEmpty(row[2])) {
          break;
        }
        importList.push(row);
      }
    }

    var columns = helper.fields;

    var properties = [];

    for (var i = 0; i < importList.length; i++) {
      var property = {};
      for (var j = 1; j < columns.length + 1; j++) {
        let column = columns[j - 1];
        var fieldName = column.fieldName;
        if (
          (!$A.util.isEmpty(fieldName) && fieldName != "_") ||
          fieldName == "Id"
        ) {
          var value = importList[i][j];
          let fieldType = column.type;
          if (fieldType == "numeric" && !$A.util.isEmpty(value)) {
            value = value.replace("$", "");
            value = value.replace("_", "");
            value = value.replace("-", "");
            value = value.replace(/ /g, "");
            value = value.split(",").join("");

            if (!$A.util.isEmpty(value)) {
              value = parseFloat(value);
            } else {
              value = null;
            }
          } else if (fieldType == "date" && !$A.util.isEmpty(value)) {
            value = $A.localizationService.formatDate(value, "YYYY-MM-DD");
          }

          property[fieldName] = value;
        }
      }

      property["sobjectType"] = "Property__c";
      let wrapper = { record: property, valid: true };
      properties.push(wrapper);
    }
    var resp = {
      records: properties
    };

    return resp;
  },

  fixdata: function(data) {
    var o = "",
      l = 0,
      w = 10240;
    for (; l < data.byteLength / w; ++l)
      o += String.fromCharCode.apply(
        null,
        new Uint8Array(data.slice(l * w, l * w + w))
      );
    o += String.fromCharCode.apply(null, new Uint8Array(data.slice(l * w)));
    return o;
  },

  CSVToArray: function(strData, strDelimiter) {
    // Check to see if the delimiter is defined. If not,
    // then default to comma.
    strDelimiter = strDelimiter || ",";

    // Create a regular expression to parse the CSV values.
    var objPattern = new RegExp(
      // Delimiters.
      "(\\" +
        strDelimiter +
        "|\\r?\\n|\\r|^)" +
        // Quoted fields.
        '(?:"([^"]*(?:""[^"]*)*)"|' +
        // Standard fields.
        '([^"\\' +
        strDelimiter +
        "\\r\\n]*))",
      "gi"
    );

    // Create an array to hold our data. Give the array
    // a default empty first row.
    var arrData = [[]];

    // Create an array to hold our individual pattern
    // matching groups.
    var arrMatches = null;

    // Keep looping over the regular expression matches
    // until we can no longer find a match.
    while ((arrMatches = objPattern.exec(strData))) {
      // Get the delimiter that was found.
      var strMatchedDelimiter = arrMatches[1];

      // Check to see if the given delimiter has a length
      // (is not the start of string) and if it matches
      // field delimiter. If id does not, then we know
      // that this delimiter is a row delimiter.
      if (strMatchedDelimiter.length && strMatchedDelimiter !== strDelimiter) {
        // Since we have reached a new row of data,
        // add an empty row to our data array.
        arrData.push([]);
      }

      var strMatchedValue;

      // Now that we have our delimiter out of the way,
      // let's check to see which kind of value we
      // captured (quoted or unquoted).
      if (arrMatches[2]) {
        // We found a quoted value. When we capture
        // this value, unescape any double quotes.
        strMatchedValue = arrMatches[2].replace(new RegExp('""', "g"), '"');
      } else {
        // We found a non-quoted value.
        strMatchedValue = arrMatches[3];
      }

      // Now that we have our value string, let's add
      // it to the data array.
      arrData[arrData.length - 1].push(strMatchedValue);
    }

    // Return the parsed data.
    return arrData;
  },
  base64ToArrayBuffer: function(base64) {
    var binary_string = window.atob(base64);
    var len = binary_string.length;
    var bytes = new Uint8Array(len);
    // console.log(binary_string);
    for (var i = 0; i < len; i++) {
      bytes[i] = binary_string.charCodeAt(i);
    }
    return bytes.buffer;
  }
});