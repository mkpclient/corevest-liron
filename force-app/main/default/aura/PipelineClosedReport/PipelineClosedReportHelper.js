({
    STAGES : [
        'UW Hold',
        'Underwriting',
        'Approved By Committee',
        
    ],
        //'Closed Won' 
        // after underwriter for new columns
        // sorting by anticipated closing date
        // pending kickoff then hold at bottom
        //
        PIPELINE_FIELDS : [
        'Anticipated_Closing_Date__c',
        'Name',
        'Loan_Purpose__c',
        'Deal_Loan_Number__c',
        'Introductions_Source__c',
        'Recourse__c',
        'Cash_Management__c',
        'Term_Loan_Type__c',
        'LTV__c',
        'Amortization_Term__c',
        'Spread_BPS__c',
        'Floor__c',
        'State_Percentages__c',
        'Rate_Lock_Picklist__c',
        'StageName__c',
        'Current_Loan_Amount__c',
        'OwnerId__c',
        'Underwriter__c',
        'Loan_Coordinator__c',
        'Closer__c',
        'LegalCounsel__c',
        'Title__c',
        'Title_and_Escrow__c',
        'Third_Party_Title_Name__c',
        'Third_Party_Title__c',
        'Are_Assets_Coming_Off_Bridge_Line__c',
        'Are_Assets_Being_RFNC_From_Existing_Term__c',
        'Warehouse_Line__c',
        '',
        'Anticipated_IC_Approval__c',
        'Kickoff_Date__c',
        'Days_In_Underwriting__c'
    ],
    PIPELINE_FIELDSSEL : [
        'Anticipated_Closing_Date__c',
        'Name',
        'Loan_Purpose__c',
        'Deal_Loan_Number__c',
        'Account.Introductions_Source__c',
        'Recourse__c',
        'Cash_Management__c',
        'Term_Loan_Type__c',
        'LTV__c',
        'Amortization_Term__c',
        'Spread_BPS__c',
        'Floor__c',
        'State_Percentages__c',
        'Rate_Lock_Picklist__c',
        'StageName',
        'Current_Loan_Amount__c',
        'Owner.LastName',
        'Underwriter__r.Initials__c',
        'Loan_Coordinator__r.Initials__c',
        'Closer__r.Initials__c',
        'Title__r.Name',
        'Third_Party_Title__r.Name',
        'Are_Assets_Coming_Off_Bridge_Line__c',
        'Are_Assets_Being_RFNC_From_Existing_Term__c',
        'Warehouse_Line__c',
        'Anticipated_IC_Approval__c',
        'Kickoff_Date__c',
        'Days_In_Underwriting__c'
    ],
    
    CLOSED_FIELDS : [
        'Anticipated_Closing_Date__c',
        'CloseDate',
        'Name',
        'Loan_Purpose__c',
        'Deal_Loan_Number__c',
        'Account.Introductions_Source__c',
        'Recourse__c',
        'Cash_Management__c',
        'Term_Loan_Type__c',
        'LTV__c',
        'Amortization_Term__c',
        'Final_Spread__c',
        'Floor__c',
        'State_Percentages__c',
        'Rate_Lock_Picklist__c',
        'StageName',
        'Loan_Size__c',
        'Final_Loan_Amount__c',
        //'Owner.Name',
        //'Underwriter__r.Name',
        'Owner.LastName',
        'Underwriter__r.Initials__c',
        'Loan_Coordinator__r.Initials__c',
        // 'Closer__r.Name',
        'Closer__r.Initials__c',
        'Title__r.Name',
        'Third_Party_Title__r.Name',
        'Are_Assets_Coming_Off_Bridge_Line__c',
        'Are_Assets_Being_RFNC_From_Existing_Term__c',
        'Warehouse_Line__c',
        '',
        'Anticipated_IC_Approval__c',
        'Kickoff_Date__c',
        'Days_In_Underwriting__c'
    ],
    
    pushRecord : function(obj, year, monthsArr, monthNum, el){
        
        if (!obj[year]){
            obj[year] = {};
        }
        
        if (!obj[year][monthsArr[monthNum]]){
            obj[year][monthsArr[monthNum]] = [];
        }
        
        var re = /^(\d{4})-(\d{2})-(\d{2})$/;
        
        var datesArr = ['CloseDate',
                        'Anticipated_Closing_Date__c',
                        'Anticipated_IC_Approval__c',
                        'Kickoff_Date__c'];
        
        datesArr.forEach(function(dateField){
            if (el.hasOwnProperty(dateField)){
                el[dateField] = el[dateField].replace(re, '$2/$3/$1');
            }
        })
        
        obj[year][monthsArr[monthNum]].push(el);
    },
    
    base64ToArrayBuffer : function(base64){
        var binary_string =  window.atob(base64);
        var len = binary_string.length;
        var bytes = new Uint8Array( len );
        // console.log(binary_string);
        //console.log(len);
        for (var i = 0; i < len; i++)        {
            bytes[i] = binary_string.charCodeAt(i);
        }
        return bytes.buffer;
    },
    
    archiveDb : function(sheet, obj, currentYear, fieldSortedBy){
        for (var year in sheet){
            if (year != currentYear){
                // push each one in an array
                if (!obj[year]){
                    obj[year] = [];
                }
                for (var month in sheet[year]){
                    sheet[year][month].forEach(function(el){
                        obj[year].push(el);
                    })
                }
            }
        }
        
        for (year in obj){
            obj[year].sort(function(a, b){
                return new Date(b[fieldSortedBy]).getTime() - new Date(a[fieldSortedBy]).getTime();
            })
        }
        
        return obj;
    },
    
    sortByDate : function (yearsObj, year, fieldToSort, cb){
        yearsObj[year].sort(function(a, b){
            return new Date(b[fieldToSort]).getTime() - new Date(a[fieldToSort]).getTime();
        })
        
        // console.log('this is the field we are sorting by: ' + fieldToSort);
        cb(yearsObj[year]);
    },
    
    populateReportPreviousYears : function(yearsObj, columnNames, workbook, sheetNum, cellStart, offsetRows, offsetColumns, fieldToSort, rowStartLetter, breakpt1, breakpt2, rowEndLetter){
        
        
        var years = [];
        for(year in yearsObj){
            years.push(year);
        }
        
        if(fieldToSort == 'CloseDate'){
            years = years.reverse();
        }
        
        // for (var year in years){
        years.forEach( year=> {
            var yearSum = 0;
            // console.log(year);
            //console.log(yearsObj);
            
            for (var i = 0; i <= yearsObj[year].length; i++){
            if (i === yearsObj[year].length){
            //console.log('this is inside last row');
            //console.log(yearSum);
            //console.log('this is columnNames.length');
           // console.log(offsetColumns + columnNames.length);
            workbook.sheet(sheetNum).row(offsetRows + i).cell(offsetColumns).style('leftBorder', {style: 'thick', color: '000'});
        workbook.sheet(sheetNum).row(offsetRows + i).cell(offsetColumns + (columnNames.length - 1)).style('rightBorder', {style: 'thick', color: '000'});
        
        // workbook.sheet(sheetNum).row(offsetRows+i).cell(offsetColumns, columnNames.length).style('topBorder', {style: 'thick', color: '000'});
        workbook.sheet(sheetNum).range(rowStartLetter + (offsetRows+i) + ':' + breakpt1 + (offsetRows+i)).style('topBorder', {style: 'thick', color: '000'});
        workbook.sheet(sheetNum).range(breakpt2 + (offsetRows+i) + ':' + rowEndLetter + (offsetRows+i)).style('topBorder', {style: 'thick', color: '000'});
        workbook.sheet(sheetNum).row(offsetRows+i).cell(breakpt1).style('rightBorder', {style: 'thick', color: '000'});
        workbook.sheet(sheetNum).row(offsetRows+i).cell(breakpt2).style('leftBorder', {style: 'thick', color: '000'});
        
        if (fieldToSort == 'CloseDate'){
            workbook.sheet(sheetNum).row(offsetRows+i).cell(cellStart).value(year + ' Totals: ').style("bold", true);
        } else {
            if(year == 'Closed'){
                workbook.sheet(sheetNum).row(offsetRows+i).cell(cellStart).value(year + ' Actual: ').style("bold", true);
            }
            else{
                workbook.sheet(sheetNum).row(offsetRows+i).cell(cellStart).value(year + ' Estimate: ').style("bold", true);
            }
        }
        // workbook.sheet(sheetNum).row(offsetRows+i).cell(cellStart + 1).value('$' + parseFloat(yearSum).toLocaleString()).style("bold", true);
        workbook.sheet(sheetNum).row(offsetRows+i).cell(cellStart + 1).value(yearSum).style({"bold": true, "numberFormat": "$0,000.00", "horizontalAlignment": 'left'});
        workbook.sheet(sheetNum).row(offsetRows+(i+1)).cell(cellStart).value('Loan Count: ').style("bold", true);
        workbook.sheet(sheetNum).row(offsetRows+(i+1)).cell(cellStart + 1).value(i).style({"bold": true, "numberFormat": "0", "horizontalAlignment": 'left'});
        
        workbook.sheet(sheetNum).row(offsetRows + (i + 1)).cell(offsetColumns).style('leftBorder', {style: 'thick', color: '000'});
        workbook.sheet(sheetNum).row(offsetRows + (i + 1)).cell(offsetColumns + (columnNames.length - 1)).style('rightBorder', {style: 'thick', color: '000', "horizontalAlignment": 'left'});
        
        workbook.sheet(sheetNum).range(rowStartLetter + (offsetRows+(i+1)) + ':' + breakpt1 + (offsetRows+(i+1))).style('bottomBorder', {style: 'thick', color: '000', "horizontalAlignment": 'left'});
        workbook.sheet(sheetNum).range(breakpt2 + (offsetRows+(i+1)) + ':' + rowEndLetter + (offsetRows+(i+1))).style('bottomBorder', {style: 'thick', color: '000', "horizontalAlignment": 'left'});
        workbook.sheet(sheetNum).row(offsetRows+(i+1)).cell(breakpt1).style('rightBorder', {style: 'thick', color: '000'});
        workbook.sheet(sheetNum).row(offsetRows+(i+1)).cell(breakpt2).style('leftBorder', {style: 'thick', color: '000'});
        
        offsetRows += (i + 2);
    } else {
    if(fieldToSort == 'CloseDate'){
    if (yearsObj[year][i].Final_Loan_Amount__c){
    yearSum += yearsObj[year][i].Final_Loan_Amount__c;
}
 }else if(fieldToSort == 'Anticipated_Closing_Date__c'){
    //if(year == 'Closed'){
    //	yearSum += yearsObj[year][i].Final_Loan_Amount__c
    //}else if (yearsObj[year][i].Current_Loan_Amount__c){
    if(yearsObj[year][i].Current_Loan_Amount__c){
        yearSum += yearsObj[year][i].Current_Loan_Amount__c;
    }
    //}
}

workbook.sheet(sheetNum).row(offsetRows + i).cell(rowStartLetter).style('leftBorder', {style: 'thick', color: '000'});
workbook.sheet(sheetNum).row(offsetRows + i).cell(breakpt2).style('leftBorder', {style: 'thick', color: '000'});

workbook.sheet(sheetNum).row(offsetRows + i).cell(breakpt1).style('rightBorder', {style: 'thick', color: '000'});
workbook.sheet(sheetNum).row(offsetRows + i).cell(rowEndLetter).style('rightBorder', {style: 'thick', color: '000'});

for (var j = 0; j < columnNames.length; j++){
    
    var style = {
        "fill": {
            "rgb": "ffffff"
        },
        
        'horizontalAlignment': 'left'
    };
    
    if((offsetRows + i)%2 != 0 ){
        //backgroundColor = "eff8ff";
        style.fill.rgb = "eff8ff"
    }
    
    if(columnNames[j] == 'Loan_Size__c' || columnNames[j] == 'Final_Loan_Amount__c' || columnNames[j] == 'Current_Loan_Amount__c'){
        style.numberFormat = "$0,000.00"
    }
    
    if(columnNames[j] == 'Floor__c' || columnNames[j] == 'Spread_BPS__c' || columnNames[j] == 'Final_Spread__c'){
        style.numberFormat="0.00%";
        
        if(!$A.util.isEmpty(yearsObj[year][i][columnNames[j]])){
            yearsObj[year][i][columnNames[j]] = parseFloat(yearsObj[year][i][columnNames[j]])/100;
        }
    }
    
    if(columnNames[j] == 'LTV__c'){
        style.numberFormat="0%";
        
        if(!$A.util.isEmpty(yearsObj[year][i][columnNames[j]])){
            yearsObj[year][i][columnNames[j]] = parseFloat(yearsObj[year][i][columnNames[j]])/100;
        }
    }
    
    if (columnNames[j] == 'Amortization_Term__c'){
        style.numberFormat = '0';
    }
    
    if (columnNames[j] == 'Days_In_Underwriting__c'){
        if (parseInt(yearsObj[year][i].Days_In_Underwriting__c) >= 60){
            style.fill.rgb = 'C40800';
        } else if (parseInt(yearsObj[year][i].Days_In_Underwriting__c) >= 45 && parseInt(yearsObj[year][i].Days_In_Underwriting__c) <= 59){
            style.fill.rgb = 'FCF200';
        }else if(parseInt(yearsObj[year][i].Days_In_Underwriting__c) < 45){
            style.fill.rgb = '008306'
        }
    }
   
                     
    if(columnNames[j].split('.').length == 2){
        var f = columnNames[j].split('.');
        var v = yearsObj[year][i][f[0]];
        if(!$A.util.isUndefinedOrNull(v)){
            v = v[f[1]];
        }
        
        workbook.sheet(sheetNum).row(offsetRows + i).cell(offsetColumns + j).value(v).style(style);
    } else {
        
        workbook.sheet(sheetNum).row(offsetRows + i).cell(offsetColumns + j).value(yearsObj[year][i][columnNames[j]]).style(style);
    }
    
    // if (j === 0){
    // 	workbook.sheet(sheetNum).row(offsetRows + i).cell(offsetColumns + j).style('leftBorder', {style: 'thick', color: '000'});
    // }
    // if ((j+1) === columnNames.length){
    // 	workbook.sheet(sheetNum).row(offsetRows + i).cell(offsetColumns + j).style('rightBorder', {style: 'thick', color: '000'});
    // }
} // closes for loop for each  column
} // closes else
} // closes loop through all the records in each year

}); // goes through all the previous years
// if (cb != undefined){
// 	cb(workbook);
// }
return offsetRows;
}, // closes populateReportPreviousYears
    
    download : function(component, helper){
        
        var sheet0 = component.get('v.sheetPipeline');
        var sheet1 = component.get('v.sheetClosed');
        
     
        
         console.log('this is the component pipeline sheet');
         console.log(sheet0);
        //
        // console.log('this is the component closed sheet')
        // console.log(sheet1);
        
        // closed is likely not completely in order b/c of existing Anticipated Closing Date values, those are in order
        
        var dbPipelinePrevious = {};
        var dbClosedPrevious = {};
        var currentYear = new Date().getFullYear();
        
        dbPipelinePrevious = helper.archiveDb(sheet0, dbPipelinePrevious, currentYear, 'Anticipated_Closing_Date__c');
        dbClosedPrevious = helper.archiveDb(sheet1, dbClosedPrevious, currentYear, 'CloseDate');
        
        // console.log('these are the previous databases');
        // console.log('this is the pipeline old');
        // console.log(dbPipelinePrevious);
        //
        // console.log('this is the closed old');
        // console.log(dbClosedPrevious);
        
        var docPromise = new Promise(function(resolve, reject){
            var action = component.get('c.getTemplate');
            action.setParams({
                fileName: 'PipelineClosedTemplate'
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === 'SUCCESS'){
                    resolve(response.getReturnValue());
                } else if (state === 'ERROR'){
                    console.log(response.getError());
                    reject(new Error(response.getError()));
                }
            });
            $A.enqueueAction(action);
        });
        
        docPromise.then(function(response){
            XlsxPopulate.fromDataAsync(helper.base64ToArrayBuffer(JSON.parse(response)))
            .then(workbook => {
                
                var offsetColumns = 2;
                var offsetRows = 3, offsetPipeline = 3, offsetClosed = 3;
                
                if (sheet0[currentYear]){

                console.log(helper.PIPELINE_FIELDS);
                offsetPipeline = helper.populateReportPreviousYears(sheet0[currentYear], helper.PIPELINE_FIELDS, workbook, 0, 12, offsetRows, offsetColumns, 'Anticipated_Closing_Date__c', 'B', 'AC', 'AE', 'AG');
            }
                  
                  if (sheet1[currentYear]){

                console.log(helper.CLOSED_FIELDS);                
                offsetClosed = helper.populateReportPreviousYears(sheet1[currentYear], helper.CLOSED_FIELDS, workbook, 1, 14, offsetRows, offsetColumns, 'CloseDate', 'C', 'AB', 'AD', 'AF');
            }

                console.log(helper.PIPELINE_FIELDS);  

                console.log(helper.CLOSED_FIELDS);            
            var offsetPipeline = helper.populateReportPreviousYears(dbPipelinePrevious, helper.PIPELINE_FIELDS, workbook, 0, 12, offsetPipeline, offsetColumns, 'Anticipated_Closing_Date__c', 'B', 'AC', 'AE', 'AG');
            var offsetClosed = helper.populateReportPreviousYears(dbClosedPrevious, helper.CLOSED_FIELDS, workbook, 1, 14, offsetClosed, offsetColumns, 'CloseDate', 'C', 'AB', 'AD', 'AF');
            
            // if (sheet0[currentYear]){
            // 	helper.populateReportPreviousYears(sheet0[currentYear], helper.PIPELINE_FIELDS, workbook, 0, 13, offsetPipeline, offsetColumns, 'CloseDate', 'B', 'S', 'U', 'W');
            // }
            
            // if (sheet1[currentYear]){
            // 	helper.populateReportPreviousYears(sheet1[currentYear], helper.CLOSED_FIELDS, workbook, 1, 14, offsetClosed, offsetColumns, 'CloseDate', 'B', 'U', 'W', 'Y');
            // }
            workbook.sheet(0).row(0).height(49);
            workbook.sheet(1).row(0).height(49);
            
            return workbook.outputAsync('base64');
        }).then(data => {
            var link = document.createElement("a");
            link.href = "data:" + XlsxPopulate.MIME_TYPE + ";base64," + data;
            link.download= "TermPipelineReport.xlsx";
            link.click();
            
            $A.util.addClass(component.find('spinner'), 'slds-hide');
            component.find('download').set('v.disabled', false);
            
        }).catch(function(err){
            console.log(err);
        })
    });
},
    
    callAction : function(action, component){
        return new Promise(function(resolve, reject){
            action.setCallback(this,
                               function(response){
                                   var state = response.getState();
                                   if(component.isValid() && state === 'SUCCESS'){
                                       resolve(response.getReturnValue());
                                   }else if(component.isValid() && state === 'ERROR'){
                                       reject(new Error(response.getError()));
                                   }
                               });
            $A.enqueueAction(action);
        });
    }
})