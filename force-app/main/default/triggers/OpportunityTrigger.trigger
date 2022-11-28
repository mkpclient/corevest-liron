trigger OpportunityTrigger on Opportunity(before insert, before update) {
    for (Opportunity opp : Trigger.new) {
  
        //For LOC_Commitment_In_Words__c
        if (opp.LOC_Commitment__c != null && opp.LOC_Commitment__c >= 0) {
          opp.LOC_Commitment_In_Words__c = ConvertCurrencyToWords.getCurrencyInWords(opp.LOC_Commitment__c, ' ', ' ','', '' ,'UpperCase');
        } else {
          opp.LOC_Commitment_In_Words__c = null;
        }
    
        
        
        //For opp.Interest_Rate_In_Words__c
        if (opp.Rate__c != null && opp.Rate__c >= 0) {
            System.debug(opp.Rate__c);
            opp.Interest_Rate_In_Words__c = ConvertCurrencyToWords.getPercentageInWords(opp.Rate__c.setScale(2), '', '', '', 'part1', '');
            //New changes
            String amountString=String.valueOf(opp.Rate__c);
            System.debug(amountString);
            if(amountString.contains('.')) {
                String part2 = amountString.split('\\.')[1];
                Decimal DecimalData = Decimal.ValueOf(part2.substring(0,2));
                System.debug(decimalData);
                if(decimalData == 0) {
                    opp.Interest_Rate_In_Words__c += ' percent';
                }
                if(decimalData == 25) {
                    opp.Interest_Rate_In_Words__c +=' and Twenty-Five percent';
                
                }if(decimalData == 50) {
                    opp.Interest_Rate_In_Words__c +=' and Fifty percent percent';
                }
                if(decimalData == 75) {
                    opp.Interest_Rate_In_Words__c +=' and Seventy-Five percent';
                }
                if(decimalData == 99) {
                    opp.Interest_Rate_In_Words__c +=' and Ninety-Nine percent';
                }
            }
        } 
        else {
            opp.Interest_Rate_In_Words__c = null;
        }
    
        
        //For Opp.Broker_Fees_In_Words__c
        if (opp.Broker_Fees__c != null && opp.Broker_Fees__c >= 0){
            opp.Broker_Fees_In_Words__c = ConvertCurrencyToWords.getPercentageInWords(opp.Broker_Fees__c.setScale(2), '', '', '', 'part1', '');
        
            //New changes
            String amountString=String.valueOf(opp.Broker_Fees__c);
            if(amountString.contains('.')) {
                string part2=amountString.split('\\.')[1];
                Decimal DecimalData = Decimal.ValueOf(part2.substring(0,2));
                if(decimalData == 0) {
                    opp.Broker_Fees_In_Words__c += ' percent';
                }
                if(decimalData == 25) {
                    opp.Broker_Fees_In_Words__c +=' and Twenty-Five percent';
                
                }if(decimalData == 50) {
                    opp.Broker_Fees_In_Words__c +=' and Fifty percent';
                }
                if(decimalData == 75) {
                    opp.Broker_Fees_In_Words__c +=' and Seventy-Five percent';
                }
                if(decimalData == 99) {
                    opp.Broker_Fees_In_Words__c +=' and Ninety-Nine percent';
                }
            }
        } else {
            opp.Broker_Fees_In_Words__c = null;
        }
        
        
        //For opp.CAF_Upfront_Fee_In_Words__c
        if (opp.CAF_Upfront_Fee__c != null && opp.CAF_Upfront_Fee__c >= 0){
            opp.Origination_Fee_In_Words__c  = ConvertCurrencyToWords.getPercentageInWords(opp.CAF_Upfront_Fee__c.setScale(2), '', '', '', 'part1', '');
          
            //New changes
            String amountString=String.valueOf(opp.CAF_Upfront_Fee__c);
            if(amountString.contains('.')) {
                string part2 = amountString.split('\\.')[1];
                Decimal DecimalData = Decimal.ValueOf(part2.substring(0,2));
                if(decimalData == 0) {
                    opp.Origination_Fee_In_Words__c += ' percent';
                }
                if(decimalData == 25) {
                    opp.Origination_Fee_In_Words__c +=' and Twenty-Five percent';
                
                }if(decimalData == 50) {
                    opp.Origination_Fee_In_Words__c +=' and Fifty percent';
                }
                if(decimalData == 75) {
                    opp.Origination_Fee_In_Words__c +=' and Seventy-Five percent';
                }
                if(decimalData == 99) {
                    opp.Origination_Fee_In_Words__c +=' and Ninety-Nine percent';
                }
            }
        } else {
            opp.Origination_Fee_In_Words__c = null;
        } 
        
        //changes for field history tracking
        if(Trigger.isUpdate){
        
            
            if(opp.Loan_Documents_Received__c != Trigger.oldMap.get(opp.Id).Loan_Documents_Received__c)
            { 
                String loanDocumentsReceivedOld=Trigger.oldMap.get(opp.Id).Loan_Documents_Received__c !=null ?  Datetime.newInstance(Trigger.oldMap.get(opp.Id).Loan_Documents_Received__c.year(), Trigger.oldMap.get(opp.Id).Loan_Documents_Received__c.month(),Trigger.oldMap.get(opp.Id).Loan_Documents_Received__c.day()).format('yyyy-MM-dd') : null;
                String loanDocumentsReceivedNew=opp.Loan_Documents_Received__c !=null ? Datetime.newInstance(opp.Loan_Documents_Received__c.year(), opp.Loan_Documents_Received__c.month(),opp.Loan_Documents_Received__c.day()).format('yyyy-MM-dd') : null;
            
               opp.Deal_Field_History__c=opp.Deal_Field_History__c!=null ? (opp.Deal_Field_History__c+'\nLoan Documents Received Date: ' +UserInfo.getName()+ ' changed Date from ' +loanDocumentsReceivedOld+' to '+loanDocumentsReceivedNew+ ' on ' +Datetime.now().format('yyyy-MM-dd')) : ('Loan Documents Received Date: '+UserInfo.getName()+' changed Date from ' +loanDocumentsReceivedOld+' to '+loanDocumentsReceivedNew+ ' on ' +Datetime.now().format('yyyy-MM-dd')); 
            } 
            
            if(opp.Custodial_File_Sent_to_Custodian__c != Trigger.oldMap.get(opp.Id).Custodial_File_Sent_to_Custodian__c)
            { 
                String custodialFileOld=Trigger.oldMap.get(opp.Id).Custodial_File_Sent_to_Custodian__c !=null ?  Datetime.newInstance(Trigger.oldMap.get(opp.Id).Custodial_File_Sent_to_Custodian__c.year(), Trigger.oldMap.get(opp.Id).Custodial_File_Sent_to_Custodian__c.month(),Trigger.oldMap.get(opp.Id).Custodial_File_Sent_to_Custodian__c.day()).format('yyyy-MM-dd') : null;
                String custodialFileNew=opp.Custodial_File_Sent_to_Custodian__c !=null ? Datetime.newInstance(opp.Custodial_File_Sent_to_Custodian__c.year(), opp.Custodial_File_Sent_to_Custodian__c.month(),opp.Custodial_File_Sent_to_Custodian__c.day()).format('yyyy-MM-dd') : null;
                
                opp.Deal_Field_History__c=opp.Deal_Field_History__c!=null ? (opp.Deal_Field_History__c+'\nCustodial File Sent to Custodian Date: ' +UserInfo.getName()+ ' changed Date from ' +custodialFileOld+' to '+custodialFileNew+ ' on ' +Datetime.now().format('yyyy-MM-dd')) : ('Custodial File Sent to Custodian Date: '+UserInfo.getName()+' changed Date from ' +custodialFileOld+' to '+custodialFileNew+ ' on ' +Datetime.now().format('yyyy-MM-dd'));  
            } 
            if(opp.Assignments_Sent_to_Title__c != Trigger.oldMap.get(opp.Id).Assignments_Sent_to_Title__c)
            { 
                String assignmentsSentOld=Trigger.oldMap.get(opp.Id).Assignments_Sent_to_Title__c !=null ?  Datetime.newInstance(Trigger.oldMap.get(opp.Id).Assignments_Sent_to_Title__c.year(), Trigger.oldMap.get(opp.Id).Assignments_Sent_to_Title__c.month(),Trigger.oldMap.get(opp.Id).Assignments_Sent_to_Title__c.day()).format('yyyy-MM-dd') : null;
                String assignmentsSentNew=opp.Assignments_Sent_to_Title__c !=null ? Datetime.newInstance(opp.Assignments_Sent_to_Title__c.year(), opp.Assignments_Sent_to_Title__c.month(),opp.Assignments_Sent_to_Title__c.day()).format('yyyy-MM-dd') : null;
            
                opp.Deal_Field_History__c=opp.Deal_Field_History__c!=null ? (opp.Deal_Field_History__c+'\nAssignments Sent to Title Date: ' +UserInfo.getName()+ ' changed Date from ' +assignmentsSentOld+' to '+assignmentsSentNew+ ' on ' +Datetime.now().format('yyyy-MM-dd')) : ('Assignments Sent to Title Date: '+UserInfo.getName()+' changed Date from ' +assignmentsSentOld+' to '+assignmentsSentNew+ ' on ' +Datetime.now().format('yyyy-MM-dd'));
            } 
            if(opp.Onboarding_File_Sent_to_Servicer__c != Trigger.oldMap.get(opp.Id).Onboarding_File_Sent_to_Servicer__c)
            { 
                String onboardingFileOld=Trigger.oldMap.get(opp.Id).Onboarding_File_Sent_to_Servicer__c !=null ?  Datetime.newInstance(Trigger.oldMap.get(opp.Id).Onboarding_File_Sent_to_Servicer__c.year(), Trigger.oldMap.get(opp.Id).Onboarding_File_Sent_to_Servicer__c.month(),Trigger.oldMap.get(opp.Id).Onboarding_File_Sent_to_Servicer__c.day()).format('yyyy-MM-dd') : null;
                String onboardingFileNew=opp.Onboarding_File_Sent_to_Servicer__c !=null ? Datetime.newInstance(opp.Onboarding_File_Sent_to_Servicer__c.year(), opp.Onboarding_File_Sent_to_Servicer__c.month(),opp.Onboarding_File_Sent_to_Servicer__c.day()).format('yyyy-MM-dd') : null;
                
                opp.Deal_Field_History__c=opp.Deal_Field_History__c!=null ? (opp.Deal_Field_History__c+'\nOnboarding File Sent to Servicer Date: ' +UserInfo.getName()+ ' changed Date from ' +onboardingFileOld+' to '+onboardingFileNew+ ' on ' +Datetime.now().format('yyyy-MM-dd')) : ('Onboarding File Sent to Servicer Date: '+UserInfo.getName()+' changed Date from ' +onboardingFileOld+' to '+onboardingFileNew+ ' on ' +Datetime.now().format('yyyy-MM-dd'));  
            } 
            if(opp.Onboarded_at_Servicer__c != Trigger.oldMap.get(opp.Id).Onboarded_at_Servicer__c)
            { 
                String onboardingat_ServicerOld=Trigger.oldMap.get(opp.Id).Onboarded_at_Servicer__c !=null ?  Datetime.newInstance(Trigger.oldMap.get(opp.Id).Onboarded_at_Servicer__c.year(), Trigger.oldMap.get(opp.Id).Onboarded_at_Servicer__c.month(),Trigger.oldMap.get(opp.Id).Onboarded_at_Servicer__c.day()).format('yyyy-MM-dd') : null;
                String onboardingat_ServicerNew=opp.Onboarded_at_Servicer__c !=null ? Datetime.newInstance(opp.Onboarded_at_Servicer__c.year(), opp.Onboarded_at_Servicer__c.month(),opp.Onboarded_at_Servicer__c.day()).format('yyyy-MM-dd') : null;
                
                opp.Deal_Field_History__c=opp.Deal_Field_History__c!=null ? (opp.Deal_Field_History__c+'\nOnboarded at Servicer Date: ' +UserInfo.getName()+ ' changed Date from ' +onboardingat_ServicerOld+' to '+onboardingat_ServicerNew+ ' on ' +Datetime.now().format('yyyy-MM-dd')) : ('Onboarded at Servicer Date: '+UserInfo.getName()+' changed Date from ' +onboardingat_ServicerOld+' to '+onboardingat_ServicerNew+ ' on ' +Datetime.now().format('yyyy-MM-dd'));  
            } 
            
        }
    }
}