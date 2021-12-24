({
  init: function (component, event, helper) {
    // var fields = [];
    // var columns = component.find('dataTable').get('v.columns');
    // for(var i = 0; i < columns.length; i++){
    //     fields.push(columns[i].get('v.name'));
    // }
    // component.set('v.fieldList', fields);
    // console.log(component.get('v.fieldList'));
    helper.compilePermissions(component);
  },

  handlePageChangeEvent: function (component, event, helper) {
    var tableCmp = component.find("dataTable");

    event.stopPropagation();

    if ($A.util.isEmpty(component.get("v.fieldList"))) {
      helper.compileFields(component);
    }

    helper.callAction(
      component,
      "c.getRecords",
      {
        parentId: component.get("v.recordId"),
        parentFieldName: component.get("v.parentFieldName"),
        sobjectType: component.get("v.sobjectType"),
        fields: component.get("v.fieldList"),
        page: event.getParam("pageNumber"),
        pageSize: event.getParam("pageSize"),
        sortCol: tableCmp.get("v.sortColumnName"),
        sortDir: tableCmp.get("v.sortDirection"),
        whereClause: component.get("v.whereClause")
      },
      function (data) {
        var tableCmp = component.find("dataTable");

        var rows = tableCmp.get("v.rows");
        //console.log(JSON.parse(data));

        tableCmp.set("v.rows", rows.concat(data));
      }
    );
  },

  handleSortChangeEvent: function (component, event, helper) {
    var tableCmp = component.find("dataTable");

    tableCmp.set("v.pageNumber", 1);

    console.log("handling sort event in app container");
    console.log("columnName=" + event.getParam("columnName"));
    console.log("sortDirection=" + event.getParam("sortDirection"));
    console.log("pageNumber=" + tableCmp.get("v.pageNumber"));
    console.log("pageSize=" + tableCmp.get("v.pageSize"));

    // console.log(component.find('dataTable').get('v.rows'), rows);

    if ($A.util.isEmpty(component.get("v.fieldList"))) {
      helper.compileFields(component);
    }

    helper.callAction(
      component,
      "c.getRecords",
      {
        parentId: component.get("v.recordId"),
        parentFieldName: component.get("v.parentFieldName"),
        sobjectType: component.get("v.sobjectType"),
        fields: component.get("v.fieldList"),
        page: tableCmp.get("v.pageNumber"),
        pageSize: tableCmp.get("v.pageSize"),
        sortCol: event.getParam("columnName"),
        sortDir: event.getParam("sortDirection"),
        whereClause: component.get("v.whereClause")
      },
      function (data) {
        var tableCmp = component.find("dataTable");

        tableCmp.set("v.rows", data);
        //tableCmp.set('v.rows', []);
      }
    );
  },

  saveRows: function (component, event, helper) {
    helper.saveRecords(component, helper);
  },

  toggleEdit: function (component, event, helper) {
    component.set("v.editMode", !component.get("v.editMode"));
  },
  refresh: function (component, event, helper) {
    helper.queryRecords(component);
  },

  delete: function (component, event, helper) {
    var table = component.find("dataTable");
    var rowsChecked = [];
    table.getChecked(function (resp) {
      rowsChecked = resp;
    });

    var rows = table.get("v.rows");
    var rowsToDelete = [];

    rowsChecked.forEach(function (el) {
      rowsToDelete.push(rows[el]);
    });
    helper.deleteRecords(component, helper, rowsToDelete);
  }
});