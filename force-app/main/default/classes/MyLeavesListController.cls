public class MyLeavesListController {
  @AuraEnabled(cacheable=true)
  public static List<LeaveMngSys_Employee__c> getEmployees() {
    return [
      SELECT Id, Name
      FROM LeaveMngSys_Employee__c
      LIMIT 10
    ];
  }

  @AuraEnabled(cacheable=true)
  public static User getUserDetails() {
    return [
      SELECT Id, Name, Email, Profile.Name
      FROM User
      WHERE Id = :UserInfo.getUserId()
      LIMIT 1
    ];
  }

  @AuraEnabled(cacheable=true)
  public static List<LeaveMngSys_Leave__c> getEmployeeLeaves() {
    try {
      User currentUser = [
        SELECT Id, Profile.Name
        FROM User
        WHERE Id = :UserInfo.getUserId()
        LIMIT 1
      ];

      if (currentUser.Profile.Name == 'System Administrator') {
        return [
          SELECT Id, Name, Leave_Type__c, Leave_Status__c, From__c, To__c
          FROM LeaveMngSys_Leave__c
          ORDER BY CreatedDate DESC
        ];
      } else {
        return [
          SELECT Id, Name, Leave_Type__c, Leave_Status__c, From__c, To__c
          FROM LeaveMngSys_Leave__c
          WHERE CreatedById = :UserInfo.getUserId()
          ORDER BY CreatedDate DESC
        ];
      }
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static Id createLeave(
    String leaveName,
    Id leaveEmployee,
    Date leaveFromDate,
    Date leaveToDate,
    String leaveType,
    String leaveStatus,
    String leaveReason
  ) {
    try {
      LeaveMngSys_Leave__c leave = new LeaveMngSys_Leave__c();
      leave.Name = leaveName;
      leave.Employee__c = leaveEmployee;
      leave.From__c = leaveFromDate;
      leave.To__c = leaveToDate;
      leave.Leave_Type__c = leaveType;
      leave.Leave_Reason__c = leaveReason;
      leave.Leave_Status__c = leaveStatus;

      insert leave;
      return leave.Id;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static Id deleteLeave(Id leaveId) {
    try {
      LeaveMngSys_Leave__c leave = [
        SELECT Id, Name
        FROM LeaveMngSys_Leave__c
        WHERE Id = :leaveId
      ];

      delete leave;
      return leave.Id;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
