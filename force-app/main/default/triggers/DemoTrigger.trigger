/* 
    Challenge: When an Account’s Phone field is updated, all 
    related Contacts should have their Phone field updated to 
    match the Account’s new phone.
*/
/*
trigger DemoTrigger on Account(before delete) {
  if (Trigger.isAfter && Trigger.isUpdate) {
    // Collection to store changed phone number with Acc iD
    Map<Id, String> updatedPhoneNo = new Map<Id, String>();

    for (Account acc : Trigger.new) {
      if (acc.Phone != Trigger.oldMap.get(acc.Id).Phone) {
        updatedPhoneNo.put(acc.Id, acc.Phone);
      }
    }

    if (updatedPhoneNo.isEmpty())
      return;

    // Collection for store udpated Contacts
    List<Contact> updatedContacts = new List<Contact>();

    for (Contact con : [
      SELECT Id, Phone, AccountId
      FROM Contact
      WHERE AccountId IN :updatedPhoneNo.keySet()
    ]) {
      con.Phone = updatedPhoneNo.get(con.AccountId);

      updatedContacts.add(con);
    }

    if (!updatedContacts.isEmpty())
      update updatedContacts;
  }
}
*/

/* 
    Challenge: Cascade Account Status change to all open opportunities
*/
/*
trigger CascadeAcctStatus on Account(after update) {
  if (Trigger.isAfter && Trigger.isUpdate) {
    Map<Id, String> acctStatus = new Map<Id, String>();

    for (Account acc : Trigger.new) {
      acctStatus.put(acc.Id, acc.Status__c);
    }

    List<Opportunity> oppsToUpdate = new List<Opportunity>();

    for (Opportunity opp : [
      SELECT Id, Status, AccountId
      FROM Opportunity
      WHERE AccountId IN :acctStatus.keySet() AND IsClosed = FALSE
    ]) {
      opp.Account_Status__c = acctStatus.get(opp.AccountId);
      oppsToUpdate.add(opp);
    }

    if (!oppsToUpdate.isEmpty()) {
      update oppsToUpdate;
    }
  }
}
*/

/* 
    Challenge: You must prevent deletion of Accounts if they have any 
    related Opportunities that are NOT Closed Won 
*/

/*
trigger DemoTrigger on Account(before delete) {
  if (Trigger.isBefore && Trigger.isDelete) {
    Set<Id> AcctIds = Trigger.oldMap.keySet();

    // Get Accounts that have at least one none-closed won
    Set<Id> blockedAcctIds = new Set<Id>();

    for (OppOpportunity opp : [
      SELECT Id, AccountId, StageName
      FROM Opportunity
      WHERE AccountId IN :AcctIds AND StageName != 'Closed Won'
    ]) {
      blockedAcctIds.add(opp.AccountId);
    }

    for (Account acc : Trigger.old) {
      if (blockedAcctIds.contains(acc.Id)) {
        acc.addError('error');
      }
    }
  }
}
*/

/*
    Challenge: Rollup total Opportunity Amount onto Account
    Similar Challenge: Count related Contacts on Account
*/
/*
trigger OpportunityAmount on Opportunity(
  after insert,
  after update,
  after delete,
  after undelete
) {
  Set<Id> accountIds = new Set<Id>();

  //   if (Trigger.isDelete) {
  //     for (Opportunity opp : Trigger.old) {
  //       if (opp.AccountId != null)
  //         AccountIds.add(opp.AccountId);
  //     }
  //   } else {
  //     for (Opportunity opp : Trigger.new) {
  //       if (opp.AccountId != null)
  //         AccountIds.add(opp.AccountId);
  //     }
  //     if (Trigger.isUpdate) {
  //       for (Opportunity opp : Trigger.old) {
  //         if (opp.AccountId != null)
  //           AccountIds.add(opp.AccountId);
  //       }
  //     }
  //   }

  List<Opportunity> records = Trigger.isDelete || Trigger.isUpdate
    ? Trigger.old
    : Trigger.new;

  for (Opportunity opp : records) {
    if (opp.AccountId != null)
      AccountIds.add(opp.AccountId);
  }

  if (accountIds.isEmpty())
    return;

  Map<Id, Decimal> sumMap = new Map<Id, Decimal>();

  for (AggregateResult ar : [
    SELECT AccountId, SUM(Amount) total
    FROM Opportunity
    WHERE AccountId IN :accountIds
    GROUP BY AccountId
  ]) {
    sumMap.put((Id) ar.get('AccountId'), (Decimal) ar.get('total'));
  }

  List<Account> toUpdate = new List<Account>();

  for (Id accId : accountIds) {
    toUpdate.add(
      new Account(
        Id = accId,
        Total_Opportunity_Amount__c = sumMap.containsKey(accId)
          ? sumMap.get(accId)
          : 0
      )
    );
  }

  if (!toUpdate.isEmpty()) {
    update toUpdate;
  }

}
*/

/*
    Challenge: Validate that Opportunity Amount does not exceed 
    Account Credit Limit
*/

/*
    Challenge: Copy Billing Address from Account to Opportunity on insert
*/

/*
trigger DemoTrigger on Opportunity(before insert) {
  if (Trigger.isBefore && Trigger.isInsert) {
    Set<Id> accountIds = new Set<Id>();

    for (Opportunity oop : Trigger.new) {
      if (opp.AccountId)
        accountIds.add(opp.AccountId);
    }

    if (accountIds.isEmpty())
      return;

    Map<Id, Account> accountsList = new Map<Id, Account>();

    for (Account acc : [
      SELECT Id, BillingState, BillingCountry
      FROM Account
      WHERE Id IN :accountIds
    ]) {
      accountsList.put(acc.Id, acc);
    }

    List<Opportunity> oppToUdate = new List<Opportunity>();

    for (Opportunity opp : Trigger.new) {
      if (accountsList.containsKey(opp.AcountId)) {
        Account acc = accountsList.get(opp.AcountId);

        opp.BillingState = acc.BillingState;
        opp.BillingCountry = acc.BillingCountry;

        oppToUdate.add(app);
      }
    }

    if (!oppToUdate.isEmpty()) {
      update oppToUdate;
    }
  }
}
*/

trigger DemoTrigger2 on Account(after update) {
  if (Trigger.isAfter && Trigger.isUpdate) {
    DemoTriggerHandler.updatePhone(Trigger.new);
  }
}
