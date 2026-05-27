import { LightningElement, wire } from "lwc";
import FilterModal from "c/filterModal";
import getCarsList from "@salesforce/apex/PracticeLWCController.getCarsList";
import searchCars from "@salesforce/apex/PracticeLWCController.searchCars";
import deleteCar from "@salesforce/apex/PracticeLWCController.deleteCar";
import { NavigationMixin } from "lightning/navigation";
import { refreshApex } from "@salesforce/apex";

const actions = [
  { label: "Show details", name: "show_details" },
  { label: "Delete", name: "delete" }
];

const columns = [
  { label: "Name", fieldName: "Name" },
  { label: "Body type", fieldName: "BodyType__c" },
  { label: "Fuel", fieldName: "Fuel__c" },
  { label: "Transmission", fieldName: "Transmission__c" },
  { label: "Model year", fieldName: "Model_Year__c" },
  { label: "Price", fieldName: "Price__c" },
  { label: "Draft", fieldName: "Draft__c" },
  {
    type: "action",
    typeAttributes: { rowActions: actions }
  }
];

export default class BasicPractice1LWC extends NavigationMixin(
  LightningElement
) {
  data = []; //Holds the list of all cars record
  columns = columns;
  showList = true;
  isLoading = false;
  isFilterVisible = false;
  selectedCar;
  error;
  wiredResult;

  handleToggleFilter() {
    this.isFilterVisible = !this.isFilterVisible;
  }

  handleSelectCar(car) {
    const carId = car.Id;
    this.selectedCar = this.data.find((car) => car.Id == carId);
  }

  @wire(getCarsList) wiredCars(result) {
    this.wireResult = result;
    if (result.data) {
      this.data = result.data;
      this.error = undefined;
    } else if (result.error) {
      this.error = result.error;
      this.data = undefined;
    }
  }

  // Search the cars by name or body type
  handleRecordSearch(event) {
    const value = event.target.value;

    searchCars({ searchKey: value })
      .then((data) => {
        this.data = data;
      })
      .catch((error) => {
        this.error = error.body.message;
        this.cars = [];
      });
  }

  // Handler for datatable record row actions
  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    this.handleAction(actionName, row);
  }

  // Hanlder for record tile actions
  handleTileAction(event) {
    const actionName = event.target.name;
    const row = event.target.data;

    this.handleAction(actionName, row);
  }

  // Handler for actions
  handleAction(actionName, row) {
    switch (actionName) {
      case "delete":
        this.deleteRecord(row);
        break;

      case "show_details":
        // this.showRecordDetails(row);
        // this.handleSelectCar(row);

        const recordId = row.Id;

        this[NavigationMixin.Navigate]({
          type: "standard__recordPage",
          attributes: {
            recordId: recordId,
            objectApiName: "Car__c",
            actionName: "view"
          }
        });
        break;

      default:
    }
  }

  //  Good Logic - Practice Latter
  deleteRecord(row) {
    const { Id } = row;
    deleteCar({ carId: Id })
      .then(() => {
        return refreshApex(this.wireResult);
      })
      .catch((error) => {
        console.log(error);
      });
  }

  // Helper function for deleteRecord
  findRowIndexById(id) {
    let ret = -1;
    this.data.some((row, index) => {
      if (row.id === id) {
        ret = index;
        return true;
      }
      return false;
    });
    return ret;
  }

  // Modal to show record details
  async showRecordDetails(row) {
    await FilterModal.open({
      size: "small",
      description: "Car details",
      content: row
    });
  }

  // Handle view option : List view or tile view
  handleShowList(event) {
    this.showList = this.showList ? false : true;
  }

  // Hanlde navigate to Register new car app page
  handleNavigateToPage() {
    try {
      this[NavigationMixin.Navigate]({
        type: "standard__navItemPage",
        attributes: {
          apiName: "Register_New_Car"
        }
      });
    } catch (error) {
      console.log(error);
    }
  }
}
