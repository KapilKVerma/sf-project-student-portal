import { LightningElement } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class Enroll360Sidebar extends LightningElement {
  navigationButtons = {
    dashboard: true,
    profile: false,
    settings: false
  };

  navigationButtonsList = [
    {
      key: 101,
      label: "Dashboard",
      name: "dashboard",
      iconName: "utility:clock"
    },
    {
      key: 102,
      label: "Profile",
      name: "profile",
      iconName: "utility:user"
    },
    {
      key: 103,
      label: "Settings",
      name: "settings",
      iconName: "utility:setup"
    }
  ];

  selectedNavItem = "dashboard";

  get isDashboard() {
    return this.selectedNavItem === "dashboard";
  }

  get isProfile() {
    return this.selectedNavItem === "profile";
  }

  get isSettings() {
    return this.selectedNavItem === "settings";
  }

  handleNavigation(event) {
    const clickedButtonName = event.target.name;
    this.selectedNavItem = clickedButtonName;

    const updatedButtons = {};

    Object.keys(this.navigationButtons).forEach((key) => {
      updatedButtons[key] = key === clickedButtonName;
    });

    this.navigationButtons = updatedButtons;
  }

  handleLogout() {
    this[NavigationMixin.Navigate]({
      type: "comm__loginPage",
      attributes: {
        actionName: "logout"
      },
      state: {
        startURL: "/"
      }
    });
  }
}
