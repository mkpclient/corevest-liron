({	
	getTemplateId : function(component){
		
		if($A.util.isEmpty(component.get('v.templateId'))){
			var queryString = 'SELECT Id, LatestPublishedVersionId FROM ContentDocument WHERE Title = \'Correspondent Import Tape\'';

			component.find('util').query(queryString, function(resp){



				component.set('v.templateId', resp[0].LatestPublishedVersionId);
			});
		}

		

	},

	queryAccount : function(component, accountId) {
		var queryString = 'SELECT Id, Name, Interest_Calculation_Method__c, Price_Percentage__c, Coupon_Floor__c, Correspondent_Interest_Strip__c';
		queryString += ' FROM Account WHERE Id = \'' + accountId + '\'';


		component.find('util').query(queryString, function(response){
			var account = response[0];

			component.set('v.correspondent', account);
			component.set('v.couponFloor', account.Coupon_Floor__c);
			component.set('v.correspondentInterestStrip', account.Correspondent_Interest_Strip__c);
			component.set('v.pricePercentage', account.Price_Percentage__c);
			component.set('v.interestCalculation', account.Interest_Calculation_Method__c);

			component.find('hot-table').createTable([{}]);
		});
	},

	queryTradeAndDeals : function(component, tradeId){
		var columns = component.find('hot-table').get('v.columns');
		var queryString = 'SELECT Id, ';
		columns.forEach(function(column){
			if(column.get('v.data') != '_' && column.get('v.data') != 'Id'){
				queryString += column.get('v.data') + ', ';
			}
			
		});
		queryString = queryString.substring(0, queryString.lastIndexOf(','));
		queryString += ' FROM Trade_Deal__c WHERE Trade__c =\'' + tradeId + '\''; 

		component.find('util').query(queryString, function(data){

			var dateCols = [];
			var columns = component.find('hot-table').get('v.columns');
			columns.forEach(function(col){
				if(col.get('v.type') === 'date'){
					dateCols.push(col.get('v.data'));

				}
			});

			component.set('v.dateCols', dateCols);

			data.forEach(function(row){
				dateCols.forEach(function(field){
					if(!$A.util.isEmpty(row[field])){
						row[field] = $A.localizationService.formatDate(row[field], 'MM/DD/YYYY');
					}
				});
			});

			if($A.util.isEmpty(data)){
				data.push({});
			}

			component.find('hot-table').createTable(data);
		});

		queryString = 'SELECT Id, Name, Total_Purchase_Price__c, Cutoff_Date__c, Trade_Date__c, Settlement_Date__c, Correspondent__c,';
		queryString += ' Price_Percentage__c, Coupon_Floor__c, Correspondent_Interest_Strip__c, Interest_Calculation__c'
		queryString += ' FROM Trade__c';
		queryString += ' WHERE Id = \'' + component.get('v.recordId') + '\'';

		component.find('util').query(queryString, function(trade){


			component.set('v.trade', trade[0]);
			component.set('v.tradeDate', trade[0].Trade_Date__c);
			component.set('v.settlementDate', trade[0].Settlement_Date__c);

			component.set('v.couponFloor', trade[0].Coupon_Floor__c);
			component.set('v.correspondentInterestStrip', trade[0].Correspondent_Interest_Strip__c);
			component.set('v.pricePercentage', trade[0].Price_Percentage__c);
			component.set('v.interestCalculation', trade[0].Interest_Calculation__c);
			
			var qString = 'SELECT Id, Name, Interest_Calculation_Method__c, Price_Percentage__c, Coupon_Floor__c, Correspondent_Interest_Strip__c';
			qString += ' FROM Account WHERE Id = \'' + trade[0].Correspondent__c + '\'';

			component.find('util').query(qString, function(accounts){
				component.set('v.correspondent', accounts[0]);

				// component.set('v.couponFloor', accounts[0].Coupon_Floor__c);
				// component.set('v.correspondentInterestStrip', accounts[0].Correspondent_Interest_Strip__c);
				// component.set('v.pricePercentage', accounts[0].Price_Percentage__c);
				// component.set('v.interestCalculation', accounts[0].Interest_Calculation_Method__c);

			});

		});

	},

	toggleModal : function(component){
		$A.util.toggleClass(component.find('importModal'), 'slds-fade-in-open');
		$A.util.toggleClass(component.find('importBackdrop'), 'slds-backdrop_open');
	},

	compileTrade : function(component){
		var accountId = component.get('v.correspondent').Id;

		var trade = {
			sobjectType: 'Trade__c',
			Correspondent__c: accountId,
			Trade_Date__c: component.get('v.tradeDate'),
			Settlement_Date__c: component.get('v.settlementDate'), 
			Price_Percentage__c: component.get('v.pricePercentage'),
			Coupon_Floor__c: component.get('v.couponFloor'),
			Correspondent_Interest_Strip__c: component.get('v.correspondentInterestStrip'),
			Interest_Calculation__c: component.get('v.interestCalculation'),
		};

		if(component.get('v.sobjectType') == 'Trade__c'){
			trade.Id = component.get('v.recordId');
		}

		return trade;

	},

	compileTradeDeals : function(component, tradeId){
		component.find('hot-table').getData(function(data){

			var columns = component.find('hot-table').get('v.columns');

			data.forEach(function(el){

				if(el.hasOwnProperty('_')){
					delete el['_'];
				}
				el['sobjectType'] = 'Trade_Deal__c';

				for(var x in el){

					if(!$A.util.isEmpty(el[x]) && (x.includes('Date') || x == 'First_Payment__c') && x != 'Closed_Date_Acquired_Date__c' ){
						if(el[x] == 'N/A'){
							el[x] = null;
						}else{
							el[x] = $A.localizationService.formatDate(el[x], 'YYYY-MM-DD');
						}
					}

					if($A.util.isEmpty(el[x])){
						el[x] = null;
					}

					if(el[x] == '$0.00'){
						delete el[x];
					}

					if(x == 'State__c' && !$A.util.isEmpty(el[x]) && el[x].length == 2){
						el[x] = el[x].toUpperCase();
					}
				}

				 el['Trade__c'] = tradeId;
			});

			//console.log(data);

			return data;

		});

		
	},

	readFile : function(file, component, helper){
		var reader = new FileReader();
		//console.log(reader);
		//console.log(this);
		reader.onload = $A.getCallback(function(event){
			var data = event.target.result;



	
			var arr = helper.fixdata(data);
			component.set('v.dataTapeNeedToUpload', btoa(arr));
			// var workbook;

			var workbook = XLSX.read(btoa(arr), {type:'base64'});

			var sheetName = 'Data Tape';
			// console.log(workbook);
			var csv = XLSX.utils.sheet_to_csv(workbook.Sheets[sheetName]);
			var rows = csv.split('\n');
			// console.log(rows);
			var startNumber = 11;

			var importList = [];

			var row1 = helper.CSVToArray(rows[1])[0];
			var row2 = helper.CSVToArray(rows[2])[0];

			console.log(row1);

			var tradeDate = row1[6];
			//console.log(helper.CSVToArray(rows[1])[0][6]);
			if(!$A.util.isEmpty(tradeDate)){
				if(tradeDate == 'N/A'){
					tradeDate = null;
				}else{
					tradeDate = $A.localizationService.formatDate(tradeDate, 'YYYY-MM-DD');
				}
			}

			component.set('v.tradeDate', tradeDate);

			var settlementDate = row2[6];
			console.log(settlementDate);
			if(!$A.util.isEmpty(settlementDate)){
				if(settlementDate == 'N/A'){
					settlementDate = null;
				}else{
					settlementDate = $A.localizationService.formatDate(settlementDate, 'YYYY-MM-DD');
				}
			}
			component.set('v.settlementDate', settlementDate);

			for(var i = startNumber; i < rows.length; i++){
				var row = helper.CSVToArray(rows[i])[0];
				//console.log(row);
				if($A.util.isEmpty(row[1]) && $A.util.isEmpty(row[2])){
					break;
				}
				importList.push(row.slice(1));
			}

			//console.log(importList);
			helper.handleImport(component, importList);

		});

		console.log('import helper');
		reader.readAsArrayBuffer(file);


	},

	handleImport : function(component, dealsArray){
		var columns = component.find('hot-table').get('v.columns');

		var deals = [];

		component.find('hot-table').getData(function(data){
			if(!$A.util.isEmpty(data) && !$A.util.isEmpty(data[0]) ){
				deals = data;
			}
		});

		var dealMap = {};
		deals.forEach( (deal, index) => {
			dealMap[deal.Id] = index;
		});

		// console.log(dealMap);

		for(var i = 0; i < dealsArray.length; i++){
			var deal = {};
			for(var j = 0; j < columns.length; j++){
				var fieldName = columns[j].get('v.data');
				if(!$A.util.isEmpty(columns[j].get('v.data')) && columns[j].get('v.data') != '_' ){//&& columns[j].get('v.data') != 'Asset_ID__c'){
					var value = dealsArray[i][j];
					if(columns[j].get('v.type') == 'numeric' && !$A.util.isEmpty(value)){
						// console.log(columns[j].get('v.data'));
						//console.log('value = ', value);

						value = value.replace("$", "");
						value = value.replace("_", "");
						value = value.replace("-", "");
						value = value.replace(/ /g,'');
						value = value.split(",").join("");

						//console.log('cleaned value = ', value );

						//console.log(!$A.util.isEmpty(value));
						if(!$A.util.isEmpty(value)){
							value = parseFloat(value);
						}else{
							value = null;
						}

						//console.log('float = ', value );
						//console.log('---');
					}

					deal[columns[j].get('v.data')] = value;
				}
			}
			// deal['Active__c'] = true;

			if(!$A.util.isEmpty(deal.Id)){
				var index = dealMap[deal.Id];

				if(!$A.util.isEmpty(index)){
					var id = deals[index].Id;
					deal.Id = deals[index].Id;

					deals[index] = deal;
				}
				

			}else{
				deals.push(deal);
			}

		}

		$A.util.toggleClass(component.find('spinner'), 'slds-hide');
		// helper.toggleModal(component);
		$A.util.toggleClass(component.find('importModal'), 'slds-fade-in-open');
		$A.util.toggleClass(component.find('importBackdrop'), 'slds-backdrop_open');

		component.find('hot-table').loadData(deals, null);


	},


	sheet_from_array_of_arrays : function(data, opts) {
		var ws = {};
		var range = {s: {c:10000000, r:10000000}, e: {c:0, r:0 }};
		for(var R = 0; R != data.length; ++R) {
			for(var C = 0; C != data[R].length; ++C) {
				if(range.s.r > R) range.s.r = R;
				if(range.s.c > C) range.s.c = C;
				if(range.e.r < R) range.e.r = R;
				if(range.e.c < C) range.e.c = C;
				var cell = {v: data[R][C] };
				if(cell.v == null) continue;
				var cell_ref = XLSX.utils.encode_cell({c:C,r:R});

				if(typeof cell.v === 'number') cell.t = 'n';
				else if(typeof cell.v === 'boolean') cell.t = 'b';
				else if(cell.v instanceof Date) {
					cell.t = 'n'; cell.z = XLSX.SSF._table[14];
					cell.v = this.datenum(cell.v);
				}
				else cell.t = 's';

				ws[cell_ref] = cell;
			}
		}
		if(range.s.c < 10000000) ws['!ref'] = XLSX.utils.encode_range(range);
		return ws;
	},

	s2ab : function(s){
		var buf = new ArrayBuffer(s.length);
		var view = new Uint8Array(buf);
		for (var i=0; i!=s.length; ++i) view[i] = s.charCodeAt(i) & 0xFF;
		return buf;
	},

	datenum : function(v, date1904) {
		if(date1904) v+=1462;
		var epoch = Date.parse(v);
		return (epoch - new Date(Date.UTC(1899, 11, 30))) / (24 * 60 * 60 * 1000);
	},

	fixdata : function(data) {
		var o = "", l = 0, w = 10240;
		for(; l<data.byteLength/w; ++l) o+=String.fromCharCode.apply(null,new Uint8Array(data.slice(l*w,l*w+w)));
		o+=String.fromCharCode.apply(null, new Uint8Array(data.slice(l*w)));
		return o;
	},

	process_wb : function(workbook){
		var result = [];

		workbook.SheetNames.forEach(function(sheetName) {
			var csv = XLSX.utils.sheet_to_csv(workbook.Sheets[sheetName]);
			if(csv.length > 0){
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

	CSVToArray : function( strData, strDelimiter ){
        // Check to see if the delimiter is defined. If not,
        // then default to comma.
        strDelimiter = (strDelimiter || ",");

        // Create a regular expression to parse the CSV values.
        var objPattern = new RegExp(
            (
                // Delimiters.
                "(\\" + strDelimiter + "|\\r?\\n|\\r|^)" +

                // Quoted fields.
                "(?:\"([^\"]*(?:\"\"[^\"]*)*)\"|" +

                // Standard fields.
                "([^\"\\" + strDelimiter + "\\r\\n]*))"
            ),
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
        while (arrMatches = objPattern.exec( strData )){

            // Get the delimiter that was found.
            var strMatchedDelimiter = arrMatches[ 1 ];

            // Check to see if the given delimiter has a length
            // (is not the start of string) and if it matches
            // field delimiter. If id does not, then we know
            // that this delimiter is a row delimiter.
            if (
                strMatchedDelimiter.length &&
                strMatchedDelimiter !== strDelimiter
                ){

                // Since we have reached a new row of data,
                // add an empty row to our data array.
                arrData.push( [] );

            }

            var strMatchedValue;

            // Now that we have our delimiter out of the way,
            // let's check to see which kind of value we
            // captured (quoted or unquoted).
            if (arrMatches[ 2 ]){

                // We found a quoted value. When we capture
                // this value, unescape any double quotes.
                strMatchedValue = arrMatches[ 2 ].replace(
                    new RegExp( "\"\"", "g" ),
                    "\""
                    );

            } else {

                // We found a non-quoted value.
                strMatchedValue = arrMatches[ 3 ];

            }


            // Now that we have our value string, let's add
            // it to the data array.
            arrData[ arrData.length - 1 ].push( strMatchedValue );
        }

        // Return the parsed data.
        return( arrData );
    },
    base64ToArrayBuffer : function(base64){
        var binary_string =  window.atob(base64);
        var len = binary_string.length;
        var bytes = new Uint8Array( len );
        // console.log(binary_string);
        console.log(len);
        for (var i = 0; i < len; i++)        {
            bytes[i] = binary_string.charCodeAt(i);
        }
        return bytes.buffer;

    }



})