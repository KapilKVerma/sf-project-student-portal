import { LightningElement, wire } from "lwc";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import LightningAlert from "lightning/alert";
import createCar from "@salesforce/apex/PracticeLWCController.createCar";
import CAR_OBJECT from "@salesforce/schema/Car__c";
import BODYTYPE_FIELD from "@salesforce/schema/Car__c.BodyType__c";
import FUEL_FIELD from "@salesforce/schema/Car__c.Fuel__c";
import TRANSMISSION_FIELD from "@salesforce/schema/Car__c.Transmission__c";
import MODELYEAR_FIELD from "@salesforce/schema/Car__c.Model_Year__c";

export default class RegisterNewCar extends LightningElement {
  carName;
  carFuel;
  carPrice;
  carTransmission;
  carModelYear;
  carBodyType;

  nextButton = true;
  previousButton = false;
  saveExitButton = false;
  cancelButton = false;
  saveButton = false;

  showFormStep1 = true;
  showFormStep2 = false;
  showFormStep3 = false;

  formStep = "1";

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

  handleShowFormStep() {
    if (parseInt(this.formStep) === 1) {
      this.showFormStep1 = true;
      this.showFormStep2 = false;
      this.showFormStep3 = false;
      //   Form Button
      this.nextButton = true;
      this.previousButton = false;
      this.saveExitButton = false;
      this.cancelButton = true;
      this.saveButton = false;
    }
    if (parseInt(this.formStep) === 2) {
      // Form step
      this.showFormStep1 = false;
      this.showFormStep2 = true;
      this.showFormStep3 = false;

      //   Form Button
      this.nextButton = true;
      this.previousButton = true;
      this.saveExitButton = true;
      this.cancelButton = false;
      this.saveButton = false;
    }
    if (parseInt(this.formStep) === 3) {
      this.showFormStep1 = false;
      this.showFormStep2 = false;
      this.showFormStep3 = true;
      //   Form Button
      this.nextButton = false;
      this.previousButton = true;
      this.saveExitButton = true;
      this.cancelButton = false;
      this.saveButton = true;
    }
  }

  handleNextButton() {
    this.formStep = (parseInt(this.formStep) + 1).toString();
    this.handleShowFormStep();
  }

  handlePreviousButton() {
    if (parseInt(this.formStep) > 1)
      this.formStep = (parseInt(this.formStep) - 1).toString();
    this.handleShowFormStep();
  }

  // Form Input Field OnChange Handler
  handleChange(event) {
    this[event.target.name] = event.target.value;
  }
  //   Handle Save Form
  async handleSaveForm() {
    if (!this.carName) {
      await LightningAlert.open({
        message: `Please enter name field`,
        theme: "error", // Options: 'success', 'error', 'warning', 'info'
        label: "Car Registration Form Error" // Header text
      });

      return;
    }

    try {
      await createCar({
        carName: this.carName,
        carPrice: this.carPrice,
        carBodyType: this.carBodyType,
        carFuel: this.carFuel,
        carTransmission: this.carTransmission,
        carModelYear: this.carModelYear,
        isDraft: true
      });

      await LightningAlert.open({
        message: `Car has been saved as draft successfully!`,
        theme: "success", // Options: 'success', 'error', 'warning', 'info'
        label: "Car Resgistration" // Header text
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

  // Submit Form Handler to Create New Car Records
  async handleSubmit() {
    // Field validation
    if (!this.carName || this.carPrice == null || !this.carBodyType) {
      await LightningAlert.open({
        message: `All required fields must be filled`,
        theme: "error", // Options: 'success', 'error', 'warning', 'info'
        label: "Car Registration Form Error" // Header text
      });

      return;
    }

    try {
      await createCar({
        carName: this.carName,
        carPrice: this.carPrice,
        carBodyType: this.carBodyType,
        carFuel: this.carFuel,
        carTransmission: this.carTransmission,
        carModelYear: this.carModelYear,
        isDraft: false
      });

      await LightningAlert.open({
        message: `Car registered successfully!`,
        theme: "success", // Options: 'success', 'error', 'warning', 'info'
        label: "Car Resgistration" // Header text
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
