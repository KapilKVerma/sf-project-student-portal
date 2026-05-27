public with sharing class PracticeLWCController {
  @AuraEnabled
  public static Id createCar(
    String carName,
    Integer carPrice,
    String carBodyType,
    Boolean isDraft
  ) {
    try {
      List<Car__c> cars = [
        SELECT Id
        FROM Car__c
        WHERE Name = :carName
        LIMIT 1
      ];

      if (!cars.isEmpty()) {
        return cars[0].Id;
      }

      Car__c newCar = new Car__c(
        Name = carName,
        Price__c = carPrice,
        BodyType__c = carBodyType,
        Draft__c = isDraft
      );

      insert newCar;

      return newCar.Id;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<Car__c> getCarsList() {
    try {
      List<Car__c> carsList = [
        SELECT
          Id,
          Name,
          Price__c,
          BodyType__c,
          Description__c,
          Fuel__c,
          Model_Year__c,
          Transmission__c,
          Draft__c
        FROM Car__c
        ORDER BY CreatedDate DESC
      ];
      return carsList;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<Car__c> searchCars(String searchKey) {
    try {
      String searchTerm = '%' + searchKey + '%';

      return [
        SELECT
          Id,
          Name,
          Price__c,
          BodyType__c,
          Description__c,
          Fuel__c,
          Model_Year__c,
          Transmission__c
        FROM Car__c
        WHERE Name LIKE :searchTerm OR BodyType__c LIKE :searchTerm
        ORDER BY CreatedDate DESC
      ];
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static void deleteCar(Id carId) {
    try {
      Car__c deleteCarRecord = [SELECT Id FROM Car__c WHERE Id = :carId];
      delete deleteCarRecord;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
