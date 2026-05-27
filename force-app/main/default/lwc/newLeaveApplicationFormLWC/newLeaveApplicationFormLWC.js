import { LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getEmployees from "@salesforce/apex/MyLeavesListController.getEmployees";
import createLeave from "@salesforce/apex/MyLeavesListController.createLeave";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import LEAVE_OBJECT from "@salesforce/schema/LeaveMngSys_Leave__c";
import LEAVE_TYPE from "@salesforce/schema/LeaveMngSys_Leave__c.Leave_Type__c";
import LEAVE_STATUS from "@salesforce/schema/LeaveMngSys_Leave__c.Leave_Status__c";

export default class NewLeaveApplicationFormLWC extends LightningElement {
  leaveName;
  leaveEmployee;
  leaveFromDate;
  leaveToDate;
  leaveType;
  leaveStatus;
  leaveReason;
  employeesList;
  userDetails;

  @wire(getObjectInfo, { objectApiName: LEAVE_OBJECT })
  objectInfo;

  @wire(getEmployees)
  wiredUsers({ data, error }) {
    if (data) {
      this.employeesList = data.map((u) => ({
        label: u.Name,
        value: u.Id
      }));
    } else if (error) {
      // handle the error
      console.error("Error fetching employees:", error);
      this.employeesList = [];
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: LEAVE_TYPE
  })
  typePicklist;

  get typePicklistOptions() {
    return this.typePicklist?.data?.values || [];
  }

  @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: LEAVE_STATUS
  })
  statusPicklist;

  get statusPicklistOptions() {
    return this.statusPicklist?.data?.values || [];
  }

  // Form Input Field OnChange Handler
  handleChange(event) {
    const field = event.target.name;
    this[field] = event.target.value;
  }

  // Sumbit Handler
  handleSubmit() {
    createLeave({
      leaveName: this.leaveName,
      leaveEmployee: this.leaveEmployee,
      leaveFromDate: new Date(this.leaveFromDate),
      leaveToDate: new Date(this.leaveToDate),
      leaveType: this.leaveType,
      leaveStatus: this.leaveStatus,
      leaveReason: this.leaveReason
    })
      .then(() => {
        this.showToastHanlder(
          "Success",
          "Leave created successfully",
          "success"
        );
        this.resetFormHandler();
      })
      .catch((error) => {
        this.showToastHanlder("Error", error.body.message, "error");
      });
  }

  // Reset Form Inputs
  resetFormHandler() {
    this.leaveName = "";
    this.leaveEmployee = "";
    this.leaveFromDate = "";
    this.leaveToDate = "";
    this.leaveType = "";
    this.leaveStatus = "";
    this.leaveReason = "";

    this.template
      .querySelectorAll(
        "lightning-input, lightning-combobox, lightning-textarea"
      )
      .forEach((input) => (input.value = ""));
  }

  // Show Toast Message Handler
  showToastHanlder(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }
}
