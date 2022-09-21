({
  sheet_from_array_of_arrays: function(data, opts) {
    var ws = {};
    var range = { s: { c: 10000000, r: 10000000 }, e: { c: 0, r: 0 } };
    for (var R = 0; R != data.length; ++R) {
      for (var C = 0; C != data[R].length; ++C) {
        if (range.s.r > R) range.s.r = R;
        if (range.s.c > C) range.s.c = C;
        if (range.e.r < R) range.e.r = R;
        if (range.e.c < C) range.e.c = C;
        var cell = { v: data[R][C] };
        if (cell.v == null) continue;
        var cell_ref = XLSX.utils.encode_cell({ c: C, r: R });

        if (typeof cell.v === "number") cell.t = "n";
        else if (typeof cell.v === "boolean") cell.t = "b";
        else if (cell.v instanceof Date) {
          cell.t = "n";
          cell.z = XLSX.SSF._table[14];
          cell.v = this.datenum(cell.v);
        } else cell.t = "s";

        ws[cell_ref] = cell;
      }
    }
    if (range.s.c < 10000000) ws["!ref"] = XLSX.utils.encode_range(range);
    return ws;
  },

  s2ab: function(s) {
    var buf = new ArrayBuffer(s.length);
    var view = new Uint8Array(buf);
    for (var i = 0; i != s.length; ++i) view[i] = s.charCodeAt(i) & 0xff;
    return buf;
  },

  datenum: function(v, date1904) {
    if (date1904) v += 1462;
    var epoch = Date.parse(v);
    return (epoch - new Date(Date.UTC(1899, 11, 30))) / (24 * 60 * 60 * 1000);
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

  readFile: function(file, component, helper) {
    var reader = new FileReader();
    //console.log(reader);
    //console.log(this);
    reader.onload = $A.getCallback(function(event) {
      var data = event.target.result;

      // var o = "", l = 0, w = 10240;
      // for(; l<data.byteLength/w; ++l) o+=String.fromCharCode.apply(null,new Uint8Array(data.slice(l*w,l*w+w)));
      // o+=String.fromCharCode.apply(null, new Uint8Array(data.slice(l*w)));
      //return o;
      var arr = helper.fixdata(data);

      var workbook;

      var workbook = XLSX.read(btoa(arr), { type: "base64" });

      var sheetName = "Data Tape";
      var csv = XLSX.utils.sheet_to_csv(workbook.Sheets[sheetName]);
      var rows = csv.split("\n");

      // var rowStart = 0;
      // var columnStart = 0;
      // for(var i = 0; i < rows.length; i++){
      // 	var row = helper.CSVToArray(rows[i])[0];
      // 	console.log(row);
      // 	console.log(row[0]);
      // 	break;
      // 	if(row[i][0] == 'Address'){
      // 		rowStart = i+1;
      // 		columnStart = 0;
      // 		break;
      // 	}else if(row[1] == 'Address'){
      // 		rowStart = i+1;
      // 		columnStart = 1;
      // 		break;
      // 	}
      // }
      // console.log(rowStart);
      // console.log(columnStart);

      //console.log(rows[8]);
      var startNumber = 8;
      var ifTerm = false;
      console.log("we made it here");
      if(component.get("v.isSabFci")) {
        startNumber = 1;
      } else if (component.get("v.recordType") == "LOC_Loan") {
        startNumber = 9;
      } else if (
        rows[8] ==
        ',Address,Property Name (Parent Property),City,State,Zip,County,"Property Type (SFR, Condo, Duplex, Triplex, etc.) ",# of Units,BD,BA,SF,Year Built,Pool,APN,Section 8 (Y/N),,Acquisition Date,Acquisition Price,Transaction Costs,Rehab Costs,Rehab Completion Date,Total Basis,Borrower Opinion of Current Market Value,Refinance / Acquisition,,Currently Leased? (Y/N),Lease Ready,Lease Start Date,Lease End Date,Lease Term,,Monthly Rent,Security Deposit,,HOA,Special Assesments (CFD / Mello Roos etc.),Taxes,Insurance,Property Management,Maintenance/ Repairs,Owner Paid Utilities,Landscaping Expense,Other Expenses,,Lease Up/ Marketing,Vacancy Repairs/ Maintenance,Credit Loss,,Total Expenses,,CapEx Reserves,Other Reserves,,NOI,,,,,,,,,,,'
      ) {
        startNumber = 9;
      } else {
        ifTerm = true;
      }

      var headerRow = helper.CSVToArray(rows[startNumber - 1])[0];
      console.log(headerRow);

      var importList = [];
      for (var i = startNumber; i < rows.length; i++) {
        //console.log(rows[i][0]);
        var row = helper.CSVToArray(rows[i])[0];
        //console.log(row);
        //var columns = rows[i].split(',');
        //console.log(row[1]);
        // console.log(row[1]);
        // console.log(row[2]);
        // console.log(row);
        if ($A.util.isEmpty(row[1]) && $A.util.isEmpty(row[2])) {
          break;
        }
        //console.log(columns.slice(1));

        if (ifTerm) {
          importList.push(row.slice(0));
        } else {
          importList.push(row.slice(1));
        }

        //console.log(rows[i]);
      }

      //console.log(importList);

      var importEvent = component.getEvent("importer");
      importEvent.setParams({
        propertyArray: importList,
        headerList: headerRow
      });

      console.log(importList);

      importEvent.fire();
      //console.log('fired');
    });

    //reader.readAsDataURL(file);
    reader.readAsArrayBuffer(file);
  },

  process_wb: function(workbook) {
    var result = [];

    workbook.SheetNames.forEach(function(sheetName) {
      var csv = XLSX.utils.sheet_to_csv(workbook.Sheets[sheetName]);
      if (csv.length > 0) {
        result.push("SHEET: " + sheetName);
        result.push("");
        result.push(csv);
      }
    });

    console.log(result.join("\n"));
    //return result.join("\n");
  },

  // CSVtoArray : function(text){
  // 	var re_valid = /^\s*(?:'[^'\\]*(?:\\[\S\s][^'\\]*)*'|"[^"\\]*(?:\\[\S\s][^"\\]*)*"|[^,'"\s\\]*(?:\s+[^,'"\s\\]+)*)\s*(?:,\s*(?:'[^'\\]*(?:\\[\S\s][^'\\]*)*'|"[^"\\]*(?:\\[\S\s][^"\\]*)*"|[^,'"\s\\]*(?:\s+[^,'"\s\\]+)*)\s*)*$/;
  //     var re_value = /(?!\s*$)\s*(?:'([^'\\]*(?:\\[\S\s][^'\\]*)*)'|"([^"\\]*(?:\\[\S\s][^"\\]*)*)"|([^,'"\s\\]*(?:\s+[^,'"\s\\]+)*))\s*(?:,|$)/g;
  //     // Return NULL if input string is not well formed CSV string.
  //     if (!re_valid.test(text)) return null;
  //     var a = [];                     // Initialize array to receive values.
  //     text.replace(re_value, // "Walk" the string using replace with callback.
  //         function(m0, m1, m2, m3) {
  //             // Remove backslash from \' in single quoted values.
  //             if      (m1 !== undefined) a.push(m1.replace(/\\'/g, "'"));
  //              //Remove backslash from \" in double quoted values.
  //             else if (m2 !== undefined) a.push(m2.replace(/\\"/g, '"'));
  //             else if (m3 !== undefined) a.push(m3);
  //             return ''; // Return empty string.
  //         });
  //     // Handle special case of empty last value.
  //     if (/,\s*$/.test(text)) a.push('');
  //     return a;
  // }

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
  }
});