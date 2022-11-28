trigger User on User(after update) {
  if (Trigger.isAfter && Trigger.isUpdate) {
    UserHelper.afterUpdate(Trigger.New, Trigger.Old);
  }
}