import { LightningElement } from "lwc";

export default class Enroll360NewOnboarding extends LightningElement {
  nextButton = true;
  previousButton = false;
  saveExitButton = false;
  cancelButton = false;
  saveButton = false;

  showFormStep1 = true;
  showFormStep2 = false;
  showFormStep3 = false;
  showFormStep4 = false;

  loremIpsum =
    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.";

  formStep = "1";

  get termsConditionsOptions() {
    return [
      { label: "Read", value: "option1" },
      { label: "Accept", value: "option2" }
    ];
  }

  handleShowFormStep() {
    if (parseInt(this.formStep) === 1) {
      this.showFormStep1 = true;
      this.showFormStep2 = false;
      this.showFormStep3 = false;
      this.showFormStep4 = false;
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
      this.showFormStep4 = false;
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
      this.showFormStep4 = false;
      //   Form Button
      this.nextButton = true;
      this.previousButton = true;
      this.saveExitButton = true;
      this.cancelButton = false;
      this.saveButton = false;
    }
    if (parseInt(this.formStep) === 4) {
      this.showFormStep1 = false;
      this.showFormStep2 = false;
      this.showFormStep3 = false;
      this.showFormStep4 = true;
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
}
