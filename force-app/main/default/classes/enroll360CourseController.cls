public with sharing class enroll360CourseController {
  @AuraEnabled(cacheable=true)
  public static List<Course__c> getCourses() {
    try {
      return [
        SELECT ID, Name, Course_Code__c, Duration__c
        FROM Course__c
        ORDER BY Name
      ];
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
