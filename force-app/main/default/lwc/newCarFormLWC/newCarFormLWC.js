import { LightningElement, wire } from "lwc";
import LightningAlert from "lightning/alert";
import createCar from "@salesforce/apex/PracticeLWCController.createCar";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import CAR_OBJECT from "@salesforce/schema/Car__c";
import BODYTYPE_FIELD from "@salesforce/schema/Car__c.BodyType__c";
import FUEL_FIELD from "@salesforce/schema/Car__c.Fuel__c";
import TRANSMISSION_FIELD from "@salesforce/schema/Car__c.Transmission__c";
import MODELYEAR_FIELD from "@salesforce/schema/Car__c.Model_Year__c";

export default class NewCarFormLWC extends LightningElement {
  carName;
  carFuel;
  carPrice;
  carTransmission;
  carModelYear;
  carBodyType = "Sedan";

  @wire(getObjectInfo, { objectApiName: CAR_OBJECT })
  objectInfo;

  @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: BODYTYPE_FIELD
  })
  bodyTypePicklist;

  @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: FUEL_FIELD
  })
  fuelPicklist;

  @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: TRANSMISSION_FIELD
  })
  transmissionPicklist;

  @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: MODELYEAR_FIELD
  })
  modelYearPicklist;

  get bodyTypeOptions() {
    return this.bodyTypePicklist?.data?.values || [];
  }

  get fuelOptions() {
    return this.fuelPicklist?.data?.values || [];
  }

  get transmissionOptions() {
    return this.transmissionPicklist?.data?.values || [];
  }

  get modelYearOptions() {
    return this.modelYearPicklist?.data?.values || [];
  }

  // Form Input Field OnChange Handler
  handleChange(event) {
    this[event.target.name] = event.target.value;
  }

  // Reset Form Inputs
  resetForm() {
    this.carName = "";
    this.carFuel = "";
    this.carBodyType = "";
    this.carTransmission = "";
    this.carModelYear = "";
    this.carPrice = "";

    this.template
      .querySelectorAll("lightning-input")
      .forEach((input) => (input.value = ""));

    this.carBodyType = "Sedan";
  }

  // Submit Form Handler to Create New Car Records
  async handleSubmit() {
    // Field validation
    if (!this.carName || this.carPrice == null || !this.carBodyType) {
      await LightningAlert.open({
        message: `All required fields must be filled`,
        theme: "error", // Options: 'success', 'error', 'warning', 'info'
        label: "System Alert" // Header text
      });

      return;
    }

    try {
      const carId = await createCar({
        carName: this.carName,
        carPrice: this.carPrice,
        carBodyType: this.carBodyType,
        carFuel: this.carFuel,
        carTransmission: this.carTransmission,
        carModelYear: this.carModelYear
      });

      await LightningAlert.open({
        message: `Car created successfully! Id: ${carId}`,
        theme: "success", // Options: 'success', 'error', 'warning', 'info'
        label: "System Alert" // Header text
      });
    } catch (error) {
      const message =
        error?.body?.message || error?.message || "Unknown error occurred";

      await LightningAlert.open({
        message: message,
        theme: "error", // Options: 'success', 'error', 'warning', 'info'
        label: "System Alert" // Header text
      });
    }
  }
}
