trigger DemoTrigger2 on Opportunity(
  after insert,
  after update,
  after delete,
  after undelete
) {
  if (Tigger.isAfter) {
    List<Opportunity> records = Trigger.isInsert || Tigger.isUndelete
      ? Trigger.new
      : Trigger.old;

    DemoTrigger2Handler.countOppoutunity(records);
  }
}
