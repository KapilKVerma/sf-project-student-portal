import { LightningElement, wire } from "lwc";
import getCarsList from "@salesforce/apex/PracticeLWCController.getCarsList";

export default class CarsGalleryLWC extends LightningElement {
  carsList;
  wiredCarSlist;
  error;
  showList = true;

  @wire(getCarsList) wiredCars(result) {
    this.wiredCarSlist = result;
    if (result.data) {
      this.carsList = result.data;
      this.error = undefined;
    } else if (result.error) {
      this.error = result.error;
      this.carsList = undefined;
    }
  }

  handleTileAction(event) {
    alert(event.target.name);
  }
}
