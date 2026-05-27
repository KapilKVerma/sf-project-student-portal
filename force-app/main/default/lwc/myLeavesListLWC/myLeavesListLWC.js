import { LightningElement, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getEmployeeLeaves from "@salesforce/apex/MyLeavesListController.getEmployeeLeaves";
import deleteLeave from "@salesforce/apex/MyLeavesListController.deleteLeave";

const actions = [
  { label: "Show details", name: "show_details" },
  { label: "Delete", name: "delete" }
];

const columns = [
  { label: "Name", fieldName: "Name" },
  { label: "Leave type", fieldName: "Leave_Type__c" },
  { label: "Leave Status", fieldName: "Leave_Status__c" },
  {
    label: "From",
    fieldName: "From__c",
    type: "date-local",
    typeAttributes: {
      day: "2-digit",
      month: "2-digit",
      year: "numeric"
    }
  },
  {
    label: "To",
    fieldName: "To__c",
    type: "date-local",
    typeAttributes: {
      day: "2-digit",
      month: "2-digit",
      year: "numeric"
    }
  },
  {
    type: "action",
    typeAttributes: { rowActions: actions }
  }
];

export default class MyLeavesListLWC extends NavigationMixin(LightningElement) {
  myLeaves;
  showList = true;
  columns = columns;
  deleteLeaveStatus = "New";
  wiredResult;

  @wire(getEmployeeLeaves)
  wiredLeaves(result) {
    this.wiredResult = result;
    this.myLeaves = result.data;
  }

  // Handler for datatable record row actions
  handleRowActions(event) {
    const actionName = event.detail.action.name;
    const record = event.detail.row;

    if (actionName === actions[0].name) {
      this.navigateToRecordHandler(record);
    }

    if (actionName === actions[1].name) {
      this.deleteLeaveRecordHanlder(record);
    }
  }

  // Navigate to record page of leave record
  navigateToRecordHandler(record) {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: record.Id,
        objectApiName: "LeaveMngSys_Leave__c",
        actionName: "view"
      }
    });
  }

  // Delete Leave record
  deleteLeaveRecordHanlder(record) {
    if (record.Leave_Status__c === this.deleteLeaveStatus) {
      deleteLeave({ leaveId: record.Id })
        .then((result) => {
          this.showToastHanlder(
            "Success",
            `Leaves with Id ${result} has been deleted.`,
            "success"
          );
          refreshApex(this.wiredResult);
        })
        .catch((error) => {
          this.showToastHanlder("Error", error.body.message, "error");
        });
    } else {
      this.showToastHanlder(
        "Error",
        "Leaves with status 'New' can be deleted.",
        "error"
      );
    }
  }

  // Show Toast Message Handler
  showToastHanlder(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }
}
