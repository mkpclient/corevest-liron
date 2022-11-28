public class dealswapRateUpdate implements Database.Batchable<sObject> {
  public Database.QueryLocator start(Database.BatchableContext BC) {
    String query = 'SELECT Int_Rate__c, Swap_Rate__c, RecordType__c, Rate_Locked__c, Floor__c, Index_Rate__c, Term_Loan_Type__c, StageName, Interest_Rate_Type__c, Index__c, Index_Margin__c, Other_Index__c, Rate__c, Other_Rate__c, Term_Sheet_Signed__c, Rate_Lock_Date__c ';
    query = query + ' FROM Opportunity';
   // query = query + ' where id = \'0065b00000v0CwUAAU\'';
    query =
      query +
      ' WHERE (RecordType__c = \'Term\' AND Rate_Locked__c = false AND StageName NOT IN (\'Withdrawn\', \'Rejected\', \'Paid Off\') AND Term_Loan_Type__c != NULL) OR ';
    query =
      query +
      ' (RecordType__c = \'Bridge\' AND StageName NOT IN (\'Withdrawn\', \'Rejected\', \'Paid Off\')AND Index__c IN (\'1M Term SOFR\',\'1M LIBOR\') AND Interest_Rate_Type__c = \'Floating\') ';
    query = query + ' order by RecordType__c';
    return Database.getQueryLocator(query);
  }

  public void execute(
    Database.BatchableContext BC,
    List<opportunity> processingDeals
  ) {
    List<opportunity> dealsToUpdate = new List<opportunity>();
    Boolean updateOpportunity = false;
    Boolean validFirstDayData = false;
    Swap_Rate__c swapRate = [
      SELECT
        Three_Year_Swap__c,
        Five_Year_Swap__c,
        Seven_Year_Swap__c,
        Ten_Year_Swap__c,
        Thirty_Year_Swap__c,
        OneM_LIBOR__c,
        OneM_SOFR__c,
        X1M_Term_SOFR_Floor__c,
        X3_Year_Treasury_Floor__c,
        X5_Year_Treasury_Floor__c,
        X7_Year_Treasury_Floor__c,
        X10_Year_Treasury_Floor__c,
        CreatedDateTime__c
      FROM Swap_Rate__c
      WHERE CreatedDateTime__c != NULL
      ORDER BY CreatedDateTime__c DESC
      LIMIT 1
    ];
    Integer mnth = System.Today().MOnth();
    Integer yr = System.Today().Year();
    List<Swap_Rate__c> swapRateMinForMonth = [
      SELECT ID, CreatedDateTime__c
      FROM Swap_Rate__c
      WHERE
        CreatedDateTime__c <= Today
        AND CALENDAR_MONTH(CreatedDate) = :mnth
        AND CALENDAR_YEAR(CreatedDate) = :yr
      ORDER BY CreatedDateTime__c ASC
      LIMIT 1
    ];
	List<Swap_Rate__c> swapRatePrevious = new List<Swap_Rate__c>();
    Decimal twoDaysold_OneMLIBOR;
    Decimal twoDaysold_OneMTermSOFRFloor;
    Decimal twoDaysold_OneMSOFR;    
      
    if (swapRateMinForMonth.size() > 0) {
      Date firstDateOfMonth = swapRateMinForMonth[0].CreatedDateTime__c.Date();
      Date currentProcessingRecordDate = swapRate.CreatedDateTime__c.Date();

      Datetime firsdateofMonthless2days = firstDateOfMonth - 2;
      System.debug('RS999 date firsdateofMonthless2days :' +firsdateofMonthless2days);
        
      if (firstDateOfMonth == currentProcessingRecordDate) {
        validFirstDayData = true;
		swapRatePrevious = [
      	SELECT
        Five_Year_Swap__c,
        Seven_Year_Swap__c,
        Ten_Year_Swap__c,
        Thirty_Year_Swap__c,
        OneM_LIBOR__c,
        OneM_SOFR__c,
        X1M_Term_SOFR_Floor__c,
        X3_Year_Treasury_Floor__c,
        X5_Year_Treasury_Floor__c,
        X7_Year_Treasury_Floor__c,
        X10_Year_Treasury_Floor__c,
        CreatedDateTime__c
      FROM Swap_Rate__c
      WHERE CreatedDateTime__c != NULL
           AND CreatedDateTime__c < :firstDateOfMonth
      ORDER BY CreatedDateTime__c DESC
    ];          
      }
     
     System.Debug('RS999 swapRatePrevious :' +swapRatePrevious);
     integer counter =0;
     Date previousProcessingDate = Null;
     for(Swap_Rate__c sr : swapRatePrevious)
     {
        System.Debug('RS999 previousProcessingDate :' +previousProcessingDate );
        System.Debug('RS999 sr.CreatedDateTime__c.Date() :' +sr.CreatedDateTime__c.Date());
        counter = counter + 1;
        if (counter > 1 && previousProcessingDate != Null && sr.CreatedDateTime__c.Date() < previousProcessingDate )
        {
        twoDaysold_OneMLIBOR = sr.OneM_LIBOR__c;
    	twoDaysold_OneMTermSOFRFloor = sr.X1M_Term_SOFR_Floor__c;
    	twoDaysold_OneMSOFR = sr.OneM_SOFR__c;
        Break;
        }
        previousProcessingDate = sr.CreatedDateTime__c.Date();         
     }
	System.Debug('RS999 twoDaysold_OneMLIBOR :' +twoDaysold_OneMLIBOR);
	System.Debug('RS999 twoDaysold_OneMTermSOFRFloor :' +twoDaysold_OneMTermSOFRFloor);
	System.Debug('RS999 twoDaysold_OneMSOFR :' +twoDaysold_OneMSOFR);        
    }

    for (opportunity Oppor : processingDeals) {
      if (Oppor.RecordType__c == 'Term') {
        decimal floor;
        if (Oppor.Floor__c != null)
          floor = Oppor.Floor__c;
        else
          floor = 0;

        switch on Oppor.Term_Loan_Type__c {
          when '3 Year' {
            if (
              swapRate.X3_Year_Treasury_Floor__c != null &&
              Oppor.Term_Sheet_Signed__c == null
            ) {
              Oppor.Floor__c = swapRate.X3_Year_Treasury_Floor__c;
              updateOpportunity = true;
            }

            if (swapRate.Three_Year_Swap__c != null) {
              if (swapRate.Three_Year_Swap__c > floor) {
                Oppor.Swap_Rate__c = swapRate.Three_Year_Swap__c;
                updateOpportunity = true;
              } else {
                Oppor.Swap_Rate__c = floor;
                updateOpportunity = true;
              }
            }
          }
          when '5 Year' {
            //CIP-2526.RS.9/21/22.Begin

            if (
              swapRate.X5_Year_Treasury_Floor__c != null &&
              Oppor.Term_Sheet_Signed__c == null
            ) {
              Oppor.Floor__c = swapRate.X5_Year_Treasury_Floor__c;
              updateOpportunity = true;
            }
            //CIP-2526.RS.9/21/22.End

            if (swapRate.Five_Year_Swap__c != null) {
              if (swapRate.Five_Year_Swap__c > floor) {
                Oppor.Swap_Rate__c = swapRate.Five_Year_Swap__c;
                updateOpportunity = true;
              } else {
                Oppor.Swap_Rate__c = floor;
                updateOpportunity = true;
              }
            }
          } 
          when '7 Year' {
            //CIP-2526.RS.9/21/22.Begin
            if (
              swapRate.X7_Year_Treasury_Floor__c != null &&
              Oppor.Term_Sheet_Signed__c == null
            ) {
              Oppor.Floor__c = swapRate.X7_Year_Treasury_Floor__c;
              updateOpportunity = true;
            }
            //CIP-2526.RS.9/21/22.End

            if (swapRate.Seven_Year_Swap__c != null) {
              if (swapRate.Seven_Year_Swap__c > floor) {
                Oppor.Swap_Rate__c = swapRate.Seven_Year_Swap__c;
                updateOpportunity = true;
              } else {
                Oppor.Swap_Rate__c = floor;
                updateOpportunity = true;
              }
            }
          }
          when '10 Year' {
            //CIP-2526.RS.9/21/22.Begin

            if (
              swapRate.X10_Year_Treasury_Floor__c != null &&
              Oppor.Term_Sheet_Signed__c == null
            ) {
              Oppor.Floor__c = swapRate.X10_Year_Treasury_Floor__c;
              updateOpportunity = true;
            }
            //CIP-2526.RS.9/21/22.End
            if (swapRate.Ten_Year_Swap__c != null) {
              if (swapRate.Ten_Year_Swap__c > floor) {
                Oppor.Swap_Rate__c = swapRate.Ten_Year_Swap__c;
                updateOpportunity = true;
              } else {
                Oppor.Swap_Rate__c = floor;
                updateOpportunity = true;
              }
            }
          }
          when '30 Year' {
            if (swapRate.Thirty_Year_Swap__c != null) {
              if (swapRate.Thirty_Year_Swap__c > floor) {
                Oppor.Swap_Rate__c = swapRate.Thirty_Year_Swap__c;
                updateOpportunity = true;
              } else {
                Oppor.Swap_Rate__c = floor;
                updateOpportunity = true;
              }
            }
          }
        } //switch
      } //term if

      if (Oppor.RecordType__c == 'Bridge') {
        if (
          Oppor.Rate_Lock_Date__c != null &&
          Oppor.Index__c == '1M Term SOFR'
        ) {
          if (swapRate.X1M_Term_SOFR_Floor__c != null) {
            Oppor.Floor__c = swapRate.X1M_Term_SOFR_Floor__c;
            updateOpportunity = true;
          }
        }

        if (Oppor.StageName != 'Closed Won') {
          if (Oppor.Index__c == '1M Term SOFR') {
            Oppor.Index_Rate__c = swapRate.OneM_SOFR__c;
            updateOpportunity = true;
          }
          if (Oppor.Index__c == '1M LIBOR') {
            Oppor.Index_Rate__c = swapRate.OneM_LIBOR__c;
            updateOpportunity = true;
          }
        } else {
          if (Oppor.StageName == 'Closed Won' && validFirstDayData) {
            if (Oppor.Index__c == '1M Term SOFR') {
              //CIP-2526.RS.9/21/22.Begin
              if (swapRate.X1M_Term_SOFR_Floor__c != null) {
                Oppor.Floor__c = twoDaysold_OneMTermSOFRFloor;
                updateOpportunity = true;
              }
              //CIP-2526.RS.9/21/22.End
              Oppor.Index_Rate__c = twoDaysold_OneMSOFR;
              updateOpportunity = true;
            }
            if (Oppor.Index__c == '1M LIBOR') {
              Oppor.Index_Rate__c = twoDaysold_OneMLIBOR;
              updateOpportunity = true;
            }
          }
        }

        if (Oppor.Interest_Rate_Type__c == 'Floating') {
          Decimal indexMargin;
          Decimal indexFloor;
          Decimal otherRate;
          if (Oppor.Floor__c != null) {
            indexFloor = Oppor.Floor__c;
          } else {
            indexFloor = 0;
          }

          if (Oppor.Index_Rate__c != null) {
            otherRate = Oppor.Index_Rate__c;
          } else {
            otherRate = 0;
          }

          if (Oppor.Index_Margin__c != null) {
            indexMargin = Oppor.Index_Margin__c;
          } else {
            indexMargin = 0;
          }

          if (otherRate >= indexFloor) {
            Oppor.Int_Rate__c = otherRate + indexMargin;
            updateOpportunity = true;
          } else {
            Oppor.Int_Rate__c = indexFloor + indexMargin;
            updateOpportunity = true;
          }
        }
      } //Bridge if

      if (updateOpportunity) {
        dealsToUpdate.add(Oppor);
        updateOpportunity = false;
      }
    } //for

    system.debug('dealsToUpdate :' + dealsToUpdate);

    if (dealsToUpdate.size() > 0) {
      try {
        update dealsToUpdate;
        database.update(dealsToUpdate, false);
      } catch (DmlException e) {
        System.debug('Error updating Swap Rates on deal' + e.getMessage());
      }
    }
  } //method

  public void finish(Database.BatchableContext BC) {
    system.debug('finish:');
  }
}