public class TransactionLog {
  public static void logRequest(
    String method,
    String endpoint,
    String requestBody,
    Integer statusCode,
    String responseBody,
    Boolean isSuccess,
    String errorMessage,
    String logType,
    Long executionTime
  ) {
    try {
      Transaction_Log__c log = new Transaction_Log__c();
      log.Request_Method__c = method;
      log.Endpoint_URL__c = endpoint;
      log.Request_Body__c = requestBody;
      log.Status_Code__c = statusCode;
      log.Response_Body__c = responseBody;
      log.Is_Success__c = isSuccess;
      log.Error_Message__c = errorMessage;
      log.Log_Category__c = logType;
      log.Execution_Time__c = executionTime;

      insert log;
    } catch (Exception e) {
      System.debug('Logging Failed: ' + e.getMessage());
    }
  }
}
