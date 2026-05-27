public with sharing class DemoTriggerHandlerService {
  public void updateStatus(
    List<Account> newAcctsList,
    Map<Id, Account> oldAcctsMap
  ) {
    Map<Id, Account> acctMap = new Map<Id, Account>();

    for (Account acc : newAcctsList) {
      acctMap.put(acc.Id, acc);
    }

    if (acctMap.isEmpty())
      return;

    List<Opportunity> oppsToUpdate = new List<Opportunity>();

    for (Opportunity opp : [
      SELECT Id, AccountId, Status__c
      FROM Opportunity
      WHERE Status__c = 'Open' AND AccountId IN :acctMap.keySet(acctMap)
    ]) {
      opp.Status__c = acctMap.get(opp.AccountId).Status__c;

      oppsToUpdate.add(opp);
    }

    if (!oppsToUpdate.isEmpty()) {
      update oppsToUpdate;
    }
  }
}
