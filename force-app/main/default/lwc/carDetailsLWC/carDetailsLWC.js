import { LightningElement, api } from "lwc";

export default class CarDetailsLWC extends LightningElement {
  @api carId;
  @api carName;
  @api carPrice;
  @api carBodytype;
}
