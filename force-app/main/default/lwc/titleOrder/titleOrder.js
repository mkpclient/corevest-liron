import queryTitleOrders from "@salesforce/apex/TitleOrder_LightningHelper.queryTitleOrders";
import { api, LightningElement } from "lwc";

const SHOW_STATUSES = [
  "Quote Requested",
  "Cancel Requested",
  "Quote Accepted",
  "Loan Portfolio Change Requested",
  "Order Change Requested",
  "Loan Portfolio Change Confirmed",
  "Quote Request Received",
  "Quote Response Received",
  "Order Confirmed",
  "Quote Request Rejected"
];

const columns = [
  {
    label: "Alerts",
    type: "button-icon",
    typeAttributes: {
      iconName: {
        fieldName: "iconName"
      },
      title: {
        fieldName: "Error_Message__c"
      }
    }
  },
  {
    label: "Address",
    type: "url",
    fieldName: "propLink",
    typeAttributes: {
      label: {
        fieldName: "Property__r.Name"
      },
      target: "_blank"
    }
  },
  {
    label: "City",
    type: "text",
    fieldName: "Property__r.City__c"
  },
  {
    label: "Property Type",
    type: "text",
    fieldName: "Property__r.Property_Type__c"
  },
  {
    label: "# of Units",
    type: "number",
    fieldName: "Property__r.Number_of_Units__c"
  },
  {
    label: "Property Status",
    type: "text",
    fieldName: "Property__r.Status__c"
  },
  {
    label: "Order Status",
    type: "url",
    fieldName: "toLink",
    typeAttributes: {
      label: {
        fieldName: "Status__c"
      },
      target: "_blank"
    }
  },
  {
    label: "Title Vendor",
    type: "text",
    fieldName: "Title_Vendor__c"
  },
  {
    label: "Order Date",
    type: "date",
    fieldName: "CreatedDate"
  },
  {
    label: "Title Completed",
    type: "date",
    fieldName: "Title_Complete_Date__c"
  },
  {
    label: "Original Title Cleared",
    type: "date",
    fieldName: "Original_Title_Cleared_Date__c"
  },
  {
    label: "All Cleared to Close",
    type: "date",
    fieldName: "All_Cleared_To_Close_Date__c"
  },
  {
    label: "Has Active Order Inquiry",
    type: "boolean",
    fieldName: "Has_Order_Inquiry__c"
  },
  {
    label: "Has Response to Order Inquiry",
    type: "boolean",
    fieldName: "Has_Order_Inquiry_Response__c"
  },
  {
    label: "Comments",
    type: "text",
    fieldName: "Comments__c"
  }
];

export default class TitleOrder extends LightningElement {
  @api recordId;
  titleOrderParams;
  allData = [];
  cols = columns;
  titleOrders = [];

  connectedCallback() {
    this.retrieveData();
  }

  async retrieveData() {
    const res = await queryTitleOrders({ dealId: this.recordId });
    const tempRes = res.filter(to => to.Status__c !== "Cancelled");
    let status = "Unordered";
    let hasError = false;
    let hasOrderInquiry = false;
    let orderInquiryAccepted = false;
    let hasProblemItem = false;
    let hasBulkProjectId = false;
    let hasNoOrderNumber = false || tempRes.length === 0;

    const dataTemp = [];
    this.titleOrders = tempRes;
    for (const to of tempRes) {
      const {
        Status__c,
        Error_Message__c,
        Has_Order_Inquiry__c,
        Has_Order_Inquiry_Response__c,
        Bulk_Project_Order_Num__c,
        Order_Number__c
      } = to;
      hasProblemItem ||= Status__c == "Problem Curative Item";
      hasError ||= !!Error_Message__c;
      hasOrderInquiry ||= Has_Order_Inquiry__c;
      orderInquiryAccepted ||= Has_Order_Inquiry_Response__c;
      hasBulkProjectId ||= !!Bulk_Project_Order_Num__c;
      hasNoOrderNumber ||= !Order_Number__c;
      if (SHOW_STATUSES.includes(Status__c) || Status__c.includes("All")) {
        status = Status__c;
      }

      dataTemp.push({
        ...this.flattenObj(to),
        toLink: "/" + to.Id,
        propLink: "/" + to.Property__c,
        iconName: to.Error_Message__c ? "utility:warning" : "utility:check",
        iconText: to.Error_Message__c
          ? "Item has an error"
          : "Item has no errors"
      });
    }
    this.allData = dataTemp;
    this.titleOrderParams = {
      status,
      hasError,
      hasOrderInquiry,
      orderInquiryAccepted,
      hasProblemItem,
      hasBulkProjectId,
      hasNoOrderNumber
    };
  }

  flattenObj(ob) {
    // The object which contains the
    // final result
    let result = {};

    // loop through the object "ob"
    for (const i in ob) {
      // We check the type of the i using
      // typeof() function and recursively
      // call the function again
      if (typeof ob[i] === "object" && !Array.isArray(ob[i])) {
        const temp = this.flattenObj(ob[i]);
        for (const j in temp) {
          // Store temp in result
          result[i + "." + j] = temp[j];
        }
      }

      // Else store ob[i] in result directly
      else {
        result[i] = ob[i];
      }
    }
    return result;
  }
}