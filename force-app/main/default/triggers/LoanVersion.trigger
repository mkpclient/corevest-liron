trigger LoanVersion on Loan_Version__c (before insert) {
    if(Trigger.isBefore && Trigger.isInsert){
        LoanVersionHelper.beforeInsert(Trigger.New);
    }
}