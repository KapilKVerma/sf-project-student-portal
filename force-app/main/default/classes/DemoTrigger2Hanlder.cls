// public class DemoTrigger2Handler {
//   public void updatePhone(List<Account> acctList) {
//     Map<Id, String> updatedString = new Map<Id, String>();

//     for (Account acc : acctList) {
//       if (acc.Phone) {
//         updatedString.put(acc.Id, acc.Phone);
//       }
//     }

//     if (updatedString.isEmpty())
//       return;

//     List<Contact> contactToUpdate = new List<Contact>();

//     for (Contact con : [
//       SELECT Id, Phone, AccountId
//       FROM Contact
//       WHERE AccountId IN :updatedString.keySet()
//     ]) {
//       con.Phone = updatedString.get(con.AccountId);

//       contactToUpdate.add(con);
//     }

//     if (!contactToUpdate.isEmpty()) {
//       update contactToUpdate;
//     }
//   }

//   public void countOppoutunity(List<Opportunity> oppsList) {
//     Set<Id> accountIds = new Set<Id>();

//     for (Opportunity opp : oppsList) {
//       if (opp.AccountId)
//         accountIds.add(opp.AccountId);
//     }

//     if (accountIds.isEmpty())
//       return;

//     Map<Id, Integer> acctIdOppCount = new Map<Id, Integer>();

//     for (AggregateResult opp : [
//       SELECT AccoutId, COUNT(Id) totalNumber
//       FROM Opportunity
//       WHERE AccountId IN :accountIds
//     ]) {
//       acctIdOppCount.put((Id) opp.AccountId, (Integer) opp.totalNumber);
//     }

//     List<Account> accountToUpdate = new List<Account>();

//     for (Id acctId : accountIds) {
//       accountToUpdate.put(
//         new Account(
//           Id = accountIds,
//           Opportunity_Count__c = acctIdOppCount.containsKey(acctId)
//             ? acctIdOppCount.get(acctId)
//             : 0
//         )
//       );
//     }

//     if (!accountToUpdate.isEmpty()) {
//       Database.update(accountToUpdate, false);
//     }
//   }
// }

// Batch Job Syntax
// public class NewBatchAccJob implements Database.Batchable<SObject>, Database.AllowsCallouts {
//   public Database.QueryLocator start(Database.BatchableContext bc) {
//     return Database.getQueryLocator([SELECT Id, Name FROM Account]);
//   }

//   public void execute(Database.BatachableContext bc, List<Account> scope) {
//     List<Account> accToProcess = scope;

//     // Business logic
//   }

//   public void finish(Database.BatchableContext bc) {
//     System.debug('Job Finished');
//   }
// }

public class NewQueJob implements Queueable, Database.AllowsCallouts {
  private Set<Id> accountIds;

  public NewQueJob(List<Id> acctIds) {
    this.accountIds = acctIds;
  }

  public void execute(QueueableContext context) {
    List<Account> accList = [
      SELECT Id, Name
      FROM Account
      WHERE Id IN :accountIds
    ];

    for (Account acc : accList) {
      acc.Name = acc.Name + ' - Queueable Updated';
    }

    update accList;

    Http http = new Http();
    HttpRequest req = new HttpRequest();

    req.setEndpoint('https://api.example.com/data');
    req.setMethod('POST');
    req.setBody(JSON.serialize(accList));

    HttpResponse res = http.send(req);

    System.debug(res.getBody());
  }
}

System.enqueueJob(new NewQueJob());