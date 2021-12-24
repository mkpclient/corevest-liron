({
    onInit: function(component, event, helper) {
        let cp = component.get("v.compProperty");
        let columns = [ {label: '', fieldName: 'rowLabel', type: 'text'},
                       {label: 'Comp 1', fieldName: 'col1', type: 'text'},
                       {label: 'Comp 2', fieldName: 'col2', type: 'text'},
                       {label: 'Comp 3', fieldName: 'col3', type: 'text'},
                      ];
                       
                       let data = [  {rowLabel: 'Address', col1: cp.Property_AVMs__r[0].AVM_C1_Address__c, col2: cp.Property_AVMs__r[0].AVM_C2_Address__c, col3: cp.Property_AVMs__r[0].AVM_C3_Address__c},
                       
                       {rowLabel: 'City', col1: cp.Property_AVMs__r[0].AVM_C1_City__c, col2: cp.Property_AVMs__r[0].AVM_C2_City__c, col3: cp.Property_AVMs__r[0].AVM_C3_City__c},
                       
                       {rowLabel: 'State', col1: cp.Property_AVMs__r[0].AVM_C1_State__c, col2: cp.Property_AVMs__r[0].AVM_C2_State__c, col3: cp.Property_AVMs__r[0].AVM_C3_State__c},
                       
                       {rowLabel: 'Zip', col1: cp.Property_AVMs__r[0].AVM_C1_Zip__c, col2: cp.Property_AVMs__r[0].AVM_C2_Zip__c, col3: cp.Property_AVMs__r[0].AVM_C3_Zip__c},
                       
                       {rowLabel: 'Units', col1: helper.toString(cp.Property_AVMs__r[0].AVM_C1_Units__c), col2: helper.toString(cp.Property_AVMs__r[0].AVM_C2_Units__c), col3: helper.toString(cp.Property_AVMs__r[0].AVM_C3_Units__c)},
                       
                       {rowLabel: 'Beds', col1: helper.toString(cp.Property_AVMs__r[0].AVM_C1_Beds__c), col2: helper.toString(cp.Property_AVMs__r[0].AVM_C2_Beds__c), col3: helper.toString(cp.Property_AVMs__r[0].AVM_C3_Beds__c)},
                       
                       {rowLabel: 'Baths', col1: helper.toString(cp.Property_AVMs__r[0].AVM_C1_Baths__c), col2: helper.toString(cp.Property_AVMs__r[0].AVM_C2_Baths__c), col3: helper.toString(cp.Property_AVMs__r[0].AVM_C3_Baths__c)},
                       
                       {rowLabel: 'Garage', col1: helper.toString(cp.Property_AVMs__r[0].AVM_C1_Garages__c), col2: helper.toString(cp.Property_AVMs__r[0].AVM_C2_Garages__c), col3: helper.toString(cp.Property_AVMs__r[0].AVM_C3_Garages__c)},
                       
						{rowLabel: 'Lot Size', col1: cp.Property_AVMs__r[0].AVM_C1_Lot_Size__c, col2: cp.Property_AVMs__r[0].AVM_C2_Lot_Size__c, col3: cp.Property_AVMs__r[0].AVM_C3_Lot_Size__c},

						{rowLabel: 'Square Feet', col1: helper.toString(cp.Property_AVMs__r[0].AVM_C1_Square_Feet__c), col2: helper.toString(cp.Property_AVMs__r[0].AVM_C2_Square_Feet__c), col3: helper.toString(cp.Property_AVMs__r[0].AVM_C3_Square_Feet__c)},

						{rowLabel: 'Year Built', col1: helper.toString(cp.Property_AVMs__r[0].AVM_C1_Year_Built__c), col2: helper.toString(cp.Property_AVMs__r[0].AVM_C2_Year_Built__c), col3: helper.toString(cp.Property_AVMs__r[0].AVM_C3_Year_Built__c)},

						{rowLabel: 'Last Sale Date', col1: cp.Property_AVMs__r[0].AVM_C1_Last_Sale_Date__c, col2: cp.Property_AVMs__r[0].AVM_C2_Last_Sale_Date__c, col3: cp.Property_AVMs__r[0].AVM_C3_Last_Sale_Date__c},

						{rowLabel: 'Last Sale Price', col1: helper.toCurrency(cp.Property_AVMs__r[0].AVM_C1_Last_Sale_Price__c, true), col2: helper.toCurrency(cp.Property_AVMs__r[0].AVM_C2_Last_Sale_Price__c, true), col3: helper.toCurrency(cp.Property_AVMs__r[0].AVM_C3_Last_Sale_Price__c, true)},

						{rowLabel: 'List Date', col1: cp.Property_AVMs__r[0].AVM_C1_List_Date__c, col2: cp.Property_AVMs__r[0].AVM_C2_List_Date__c, col3: cp.Property_AVMs__r[0].AVM_C3_List_Date__c},

						{rowLabel: 'List Price', col1: helper.toCurrency(cp.Property_AVMs__r[0].AVM_C1_List_Price__c, true), col2: helper.toCurrency(cp.Property_AVMs__r[0].AVM_C2_List_Price__c, true), col3: helper.toCurrency(cp.Property_AVMs__r[0].AVM_C3_List_Price__c, true)},

						{rowLabel: 'Square Foot Price', col1: helper.toCurrency(cp.Property_AVMs__r[0].AVM_C1_Square_Foot_Price__c, false), col2: helper.toCurrency(cp.Property_AVMs__r[0].AVM_C2_Square_Foot_Price__c, false), col3: helper.toCurrency(cp.Property_AVMs__r[0].AVM_C3_Square_Foot_Price__c, false)},

						{rowLabel: 'Percent of Valuation', col1: helper.toString(cp.Property_AVMs__r[0].AVM_C1_Percent_Of_Valuation__c), col2: helper.toString(cp.Property_AVMs__r[0].AVM_C2_Percent_Of_Valuation__c), col3: helper.toString(cp.Property_AVMs__r[0].AVM_C3_Percent_Of_Valuation__c)},

						{rowLabel: 'Included in Calculation', col1: cp.Property_AVMs__r[0].AVM_C1_Included_In_Calculation__c ? 'True' : 'False', col2: cp.Property_AVMs__r[0].AVM_C2_Included_In_Calculation__c ? 'True' : 'False', col3: cp.Property_AVMs__r[0].AVM_C3_Included_In_Calculation__c ? 'True' : 'False'},

						{rowLabel: 'REO', col1: cp.Property_AVMs__r[0].AVM_C1_REO__c, col2: cp.Property_AVMs__r[0].AVM_C2_REO__c, col3: cp.Property_AVMs__r[0].AVM_C3_REO__c},

						{rowLabel: 'Comp Type', col1: cp.Property_AVMs__r[0].AVM_C1_Comp_Type__c, col2: cp.Property_AVMs__r[0].AVM_C2_Comp_Type__c, col3: cp.Property_AVMs__r[0].AVM_C3_Comp_Type__c},

						{rowLabel: 'Act Dom', col1: helper.toString(cp.Property_AVMs__r[0].AVM_C1_Act_Dom__c), col2: helper.toString(cp.Property_AVMs__r[0].AVM_C2_Act_Dom__c), col3: helper.toString(cp.Property_AVMs__r[0].AVM_C3_Act_Dom__c)},

						{rowLabel: 'Tot Dom', col1: helper.toString(cp.Property_AVMs__r[0].AVM_C1_Tot_Dom__c), col2: helper.toString(cp.Property_AVMs__r[0].AVM_C2_Tot_Dom__c), col3: helper.toString(cp.Property_AVMs__r[0].AVM_C3_Tot_Dom__c)},

						{rowLabel: 'Target Distance', col1: helper.toString(cp.Property_AVMs__r[0].AVM_C1_Target_Distance__c), col2: helper.toString(cp.Property_AVMs__r[0].AVM_C2_Target_Distance__c), col3: helper.toString(cp.Property_AVMs__r[0].AVM_C3_Target_Distance__c)},
						];
        
        component.set("v.columns", columns);
        component.set("v.data", data);
    },
    
    close: function(component, event, helper) {
        component.set("v.compProperty", null);
    },
    
})