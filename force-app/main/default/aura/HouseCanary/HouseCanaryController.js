({
  onInit: function (component, event, helper) {
    helper.getProperties(component);
    component.set("v.columns", helper.getColumns());
  },

  recordUpdate: function (component, event, helper) {
    let profile = component.get("v.CurrentUser")["Profile"].Name;
    if (
      profile == "Term Operations" ||
      profile == "Bridge Closing" ||
      profile == "Bridge Operations" ||
	  profile == "System Administrator" 
    ) {
      component.set("v.ShowValueReport", "Yes");
    }
  },

  recordUpdateDeal: function (component, event, helper) {
    let dealStage = component.get("{!v.CurrentDeal.Current_Stage__c}");
    let profile = component.get("v.CurrentUser")["Profile"].Name;
    component.set("v.stage", dealStage);
    if (
      dealStage == "Term Sheet Signed/Deposit Collected" ||
      dealStage == "Underwriting"
    ) {
      component.set("v.ShowValue", "Yes");
    } else {
      if (
        profile == "Origination Manager" ||
        profile == "Sales Analyst" ||
        profile == "Relationship Manager" ||
        profile == "Sales Analyst Bridge Operations Hybrid" ||
        profile == "Sales Analyst Term Operations Hybrid"
      ) {
        component.set("v.ShowValue", "No");
        component.set("v.ShowValueReport", "No");
      } else {
        component.set("v.ShowValue", "Yes");
      }
    }
  },

  refresh: function (component, event, helper) {
    helper.getProperties(component);
  },

  nextPage: function (component, event, helper) {
    let currentPage = component.get("v.currentPage");
    component.set("v.currentPage", currentPage + 1);
    component.set("v.tableData", helper.getTableData(component));
    component.set("v.selectedRowsCount", 0);
  },

  prevPage: function (component, event, helper) {
    let currentPage = component.get("v.currentPage");
    component.set("v.currentPage", currentPage - 1);
    component.set("v.tableData", helper.getTableData(component));
    component.set("v.selectedRowsCount", 0);
  },

  lastPage: function (component, event, helper) {
    let maxPage = component.get("v.maxPage");
    component.set("v.currentPage", maxPage);
    component.set("v.tableData", helper.getTableData(component));
    component.set("v.selectedRowsCount", 0);
  },

  firstPage: function (component, event, helper) {
    component.set("v.currentPage", 1);
    component.set("v.tableData", helper.getTableData(component));
    component.set("v.selectedRowsCount", 0);
  },

  openReportml: function (component, event, helper) {
    let recordId = component.get("v.recordId");
    let reportUrl =
      "/lightning/r/Report/00O76000000JU4YEAW/view?fv0=" + recordId;
    window.open(reportUrl);
  },

  openReportsh: function (component, event, helper) {
    let recordId = component.get("v.recordId");
    let reportUrl =
      "/lightning/r/Report/00O76000000JU4TEAW/view?fv0=" + recordId;
    window.open(reportUrl);
  },
  toggleSelectAll: function (component, event, helper) {
    let selectedRowsCount = component.get("v.selectedRowsCount");
    if (selectedRowsCount == 0) {
      console.log("select all");
      helper.selectAll(component);
    } else {
      console.log("deselect all");
      helper.deselectAll(component);
    }
  },

  updateSelectedRowsCount: function (component, event, helper) {
    let tableData = component.get("v.tableData");
    let selectedRowsCount = 0;
    for (let td of tableData) {
      if (td.Selected == true) {
        selectedRowsCount++;
      }
    }
    component.set("v.selectedRowsCount", selectedRowsCount);
  },

  getHouseCanaryData: function (component, event, helper) {
    component.set("v.valueReport", "False");
    let selectedProps = helper.mapRowsToProperties(component);
    if (selectedProps.length == 0) {
      alert("No properties were selected");
      return;
    }
    helper.oneAtATimeHouseCanaryRead(component, selectedProps);
  },

  valueReportMsg: function (component, event, helper) {
    component.set("v.valueReportPreMessage", "True");
  },

  valueReportMsgClose: function (component, event, helper) {
    component.set("v.valueReportPreMessage", false);
  },

  getHouseCanaryData1: function (component, event, helper) {
    var newCheckBoxValue = component
      .find("OKtocallValueReport")
      .get("v.checked");
    if (newCheckBoxValue) {
      component.set("v.valueReportPreMessage", false);
      component.set("v.valueReport", "True");
      let selectedProps = helper.mapRowsToProperties(component);
      if (selectedProps.length == 0) {
        alert("No properties were selected");
        return;
      }
      helper.oneAtATimeHouseCanaryRead(component, selectedProps);
    }
  },

  openModal: function (component, event, helper) {
    let rowIndex = parseInt(event.currentTarget.dataset.rowIndex);
    console.log(rowIndex);
    let properties = component.get("v.properties");
    let currentPage = component.get("v.currentPage");
    let pageSize = component.get("v.pageSize");
    console.log(
      currentPage,
      pageSize,
      rowIndex,
      (currentPage - 1) * pageSize + rowIndex
    );
    let compProperty = properties[(currentPage - 1) * pageSize + rowIndex];
    console.log(compProperty);
    component.set("v.compProperty", compProperty);
  }
});