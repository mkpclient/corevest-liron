({
  init: function (component, event, helper) {},

  createTable: function (component, event, helper) {
    console.log("createTable");

    var data = component.get("v.data");
    var params = event.getParam("arguments");

    var data = params.data;

    var table = component.find("table");
    container = table.elements[0];

    var colHeaders = [];
    var columns = [];

    component.get("v.columns").forEach(function (col) {
      var headerName = col.get("v.title");
      if (!col.get("v.allowEmpty")) {
        headerName = "<span style='color:red'>" + headerName + "</span>";
      }
      colHeaders.push(headerName);
      //console.log(col.get('v.source'));
      //console.log(col.get('v.type'));
      //console.log(col.get('v.title'));
      //console.log(col.get('v.allowEmpty'));
      columns.push({
        data: col.get("v.data"),
        type: col.get("v.type"),
        format: col.get("v.format"),
        //allowEmpty: col.get("v.allowEmpty"),
        dateFormat: col.get("v.dateFormat"),
        source: col.get("v.source"),
        correctFormat: col.get("v.correctFormat"),
        readOnly: col.get("v.readOnly")
      });
    });

    //if(component.ge)
    console.log("v.allowDelete");
    console.log(component.get("v.allowDelete"));
    var contextMenu = {
      callback: function (key, options) {
        if (key === "active") {
          console.log(options);
          console.log("--selected--");

          var hot = component.get("v.hot");

          for (var i = options.start.row; i < options.end.row + 1; i++) {
            data[i].Active__c = !data[i].Active__c;
          }
          hot.loadData(data);
        } else if (key === "delete") {
          //console.log(options);
          //console.log('--selected--');

          var hot = component.get("v.hot");

          for (var i = options.start.row; i < options.end.row + 1; i++) {
            data[i].IsDeleted = !data[i].IsDeleted;
          }
          hot.loadData(data);
        }
      },

      items: {
        active: {
          name: "Toggle Active",
          disabled: !component.get("v.allowActiveToggle")
        },
        delete: {
          name: "Toggle Delete",
          disabled: !component.get("v.allowDelete")
        },
        row_above: { disabled: !component.get("v.allowInsert") },
        row_below: { disabled: !component.get("v.allowInsert") },
        undo: {},
        redo: {}
      }
    };

    function isEmptyRow(instance, row) {
      var rowData = instance.getData()[row];

      for (var i = 0, ilen = rowData.length; i < ilen; i++) {
        if (rowData[i] !== null) {
          return false;
        }
      }

      return true;
    }

    function backgroundColor(
      instance,
      td,
      row,
      col,
      prop,
      value,
      cellProperties
    ) {
      var data = instance.getSourceData()[row];

      if (!$A.util.isEmpty(data["Active__c"]) && !data["Active__c"]) {
        td.style.textDecoration = "line-through";
      }
      if (!$A.util.isEmpty(data["IsDeleted"]) && data["IsDeleted"]) {
        td.style.color = "red";
        td.style.textDecoration = "line-through";
      }

      //console.log(prop);
      //console.log(value);
      //console.log(component.get('v.columns')[col].get('v.allowEmpty'));

      let propType = data["Property_Type__c"];

      if (
        !component.get("v.columns")[col].get("v.allowEmpty") &&
        $A.util.isEmpty(value)
      ) {
        console.log("empty cell");
        if (
          (propType == "2-4 Unit" ||
            propType == "Multifamily" ||
            propType == "Mixed Use") &&
          component.get("v.columns")[col].get("v.notRequiredForChildren")
        ) {
          td.style.backgroundColor = "white";
        } else {
          td.style.backgroundColor = "red";
        }
      }

      if (
        component.get("v.columns")[col].get("v.data") === "State__c" &&
        value == "NV"
      ) {
        td.style.backgroundColor = "yellow";
      }

      if (
        component.get("v.columns")[col].get("v.data") === "State__c" &&
        (value == "ND" || value == "SD" || value == "MN")
      ) {
        td.style.backgroundColor = "red";
      }

      if (
        component.get("v.columns")[col].get("v.data") === "Monthly_Rent__c" &&
        value == 0
      ) {
        td.style.backgroundColor = "red";
      }

      if (cellProperties.type == "numeric") {
        Handsontable.renderers.NumericRenderer.apply(this, arguments);
      } else if (cellProperties.type == "dropdown") {
        //if (value == "Y" || value == "y") {
        //  value = "Yes";
        //} else if (value == "N" || value == "n") {
        //  value = "No";
        //}
        Handsontable.renderers.AutocompleteRenderer.apply(this, arguments);
      } else {
        Handsontable.renderers.TextRenderer.apply(this, arguments);
      }
    }

    var hot = new Handsontable(container, {
      data: data,
      rowHeaders: true,
      colHeaders: true,
      columns: columns,
      colHeaders: colHeaders,
      contextMenu: true,
      fixedColumnsLeft: component.get("v.fixedColumnsLeft"),
      fixedRowsTop: 0,
      stretchH: "all",
      contextMenu: contextMenu,
      fillHandle: {
        direction: "vertical",
        autoInsertRow: false
      },
      cells: function (row, col, prop) {
        var cellProperties = {};
        //console.log(prop);
        cellProperties.renderer = backgroundColor;

        return cellProperties;
      }
    });

    if (component.get("v.readOnly")) {
      hot.updateSettings({
        readOnly: true, // make table cells read-only
        contextMenu: false, // disable context menu to change things
        disableVisualSelection: true, // prevent user from visually selecting
        manualColumnResize: false, // prevent dragging to resize columns
        manualRowResize: false, // prevent dragging to resize rows
        comments: false // prevent editing of comments
      });
    }

    component.set("v.hot", hot);
  },

  getData: function (component, event, helper) {
    var hot = component.get("v.hot");

    var params = event.getParam("arguments");

    params.callback(hot.getSourceData());
  },

  loadData: function (component, event, helper) {
    var hot = component.get("v.hot");
    var params = event.getParam("arguments");

    var data = params.data;

    hot.loadData(data);
    component.set("v.hot", hot);
  },

  debug: function (component, event, helper) {
    var columns = component.get("v.columns");

    console.log(columns[1].get("v.title"));
  }
});