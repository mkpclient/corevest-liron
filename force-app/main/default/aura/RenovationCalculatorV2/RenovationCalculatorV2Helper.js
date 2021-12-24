({
	calculateFields : function(component) {

		var cf = component.get('v.calculatorFields');

		console.log(cf.asIsValue);

		cf.asIsValue = $A.util.isUndefinedOrNull(cf.asIsValue) || $A.util.isEmpty(cf.asIsValue) ? 0 : parseFloat(cf.asIsValue);
		cf.afterRenoValue = $A.util.isUndefinedOrNull(cf.afterRenoValue) || $A.util.isEmpty(cf.afterRenoValue) ? 0 : parseFloat(cf.afterRenoValue);
		cf.acquisitionPrice = $A.util.isUndefinedOrNull(cf.acquisitionPrice) || $A.util.isEmpty(cf.acquisitionPrice) ? 0 : parseFloat(cf.acquisitionPrice);
		cf.renoBudget = $A.util.isUndefinedOrNull(cf.renoBudget) || $A.util.isEmpty(cf.renoBudget) ? 0 : parseFloat(cf.renoBudget);
		cf.interestRate = $A.util.isUndefinedOrNull(cf.interestRate) || $A.util.isEmpty(cf.interestRate) ? 0 : parseFloat(cf.interestRate);
		cf.maxInitialLTV = $A.util.isUndefinedOrNull(cf.maxInitialLTV) || $A.util.isEmpty(cf.maxInitialLTV) ? 0 : parseFloat(cf.maxInitialLTV);
        cf.maxInitialLTC = $A.util.isUndefinedOrNull(cf.maxInitialLTC) || $A.util.isEmpty(cf.maxInitialLTC) ? 0 : parseFloat(cf.maxInitialLTC);
		cf.totalARVLTV = $A.util.isUndefinedOrNull(cf.totalARVLTV) || $A.util.isEmpty(cf.totalARVLTV) ? 0 : parseFloat(cf.totalARVLTV);
		//cf.rehabHoldbackLimit = $A.util.isUndefinedOrNull(cf.rehabHoldbackLimit) || $A.util.isEmpty(cf.rehabHoldbackLimit) ? 0 : parseFloat(cf.rehabHoldbackLimit);
		cf.totalLoanLTC = $A.util.isUndefinedOrNull(cf.totalLoanLTC) || $A.util.isEmpty(cf.totalLoanLTC) ? 0 : parseFloat(cf.totalLoanLTC);
        cf.RenoLimitofAcqCost = $A.util.isUndefinedOrNull(cf.RenoLimitofAcqCost) || $A.util.isEmpty(cf.RenoLimitofAcqCost) ? 0 : parseFloat(cf.RenoLimitofAcqCost);

		//console.log(cf.renoBudget);
		//console.log(cf.acquisitionPrice);

		//Initial Advance section
		//as is value reference
		//as is limit reference
		cf.asIsLimitor = cf.maxInitialLTV/100;
		cf.asIsMaxPotentialAdvance = cf.asIsValue * cf.asIsLimitor;
		//purchase price reference	
		//purchase Limitor reference
		cf.purchaseLimitor = cf.maxInitialLTC/100;
		cf.purchasePotentialAdvance = cf.purchasePrice * cf.maxInitialLTC/100;
		cf.maxInitialLoanAmount = Math.min(cf.asIsMaxPotentialAdvance, cf.purchasePotentialAdvance);

		//total loan advance amount
		cf.afterRepairValue = cf.afterRenoValue;
		cf.afterRepairLimitors = cf.totalARVLTV/100;
		cf.afterRepairPotentialAdvance = cf.afterRehabValue * cf.afterRepairLimitors;
		cf.totalCostBasisValue = cf.purchasePrice + cf.renoBudget;
		cf.totalCostBasisLimitors = cf.totalLoanLTC/100;
		cf.totalCostBasisPotentialAdvance = cf.totalCostBasisValue * cf.totalCostBasisLimitors;
		cf.maxTotalLoanAmount = Math.min(cf.afterRepairPotentialAdvance, cf.totalCostBasisPotentialAdvance); 

		//Holdback Advance
		cf.maxAvailableForRehabBasedOnARVLTCLimitors = cf.maxTotalLoanAmount - cf.maxInitialLoanAmount;
		cf.maxAllowableRehabBasedOnHoldbackLimit = cf.purchasePrice * cf.RenoLimitofAcqCost/100;
		cf.totalLoanAmountLimitor = cf.renoBudget * cf.maxRenoCostReimb/100;
		cf.borrowerRehabBudget = cf.renoBudget;
		cf.approvedHoldback = Math.min(cf.maxAvailableForRehabBasedOnARVLTCLimitors, cf.maxAllowableRehabBasedOnHoldbackLimit, cf.totalLoanAmountLimitor, cf.borrowerRehabBudget);

		//final output
		cf.initialAdvance = cf.maxInitialLoanAmount;
		cf.holdbackAdvance = cf.approvedHoldback;
		cf.totalLoanAmount = cf.maxInitialLoanAmount + cf.approvedHoldback;

		//summary loan metrics
		cf.asIsLTV = (cf.asIsValue != null && cf.asIsValue != 0) ? (cf.initialAdvance / cf.asIsValue) : 0;
		cf.asIsLTC = (cf.purchasePrice != null && cf.purchasePrice != 0) ? (cf.initialAdvance / cf.purchasePrice) : 0; 
		cf.totalLoanARVLTV = (cf.afterRenoValue != null && cf.afterRenoValue != 0) ? (cf.totalLoanAmount / cf.afterRenoValue) : 0;
		//cf.totalLoanLTC = ((cf.)

		cf.totalLoanLTCSummary = (cf.purchasePrice != null && cf.renoBudget != null && cf.purchasePrice != 0 && cf.renoBudget != 0) 
													? (cf.totalLoanAmount / (cf.purchasePrice + cf.renoBudget)) : 0;

		cf.perInitialAdvance = (cf.totalLoanAmount != null && cf.totalLoanAmount != 0) ? cf.initialAdvance / cf.totalLoanAmount : 0;

		cf.perHoldback = (cf.totalLoanAmount != null && cf.totalLoanAmount != 0) ? cf.holdbackAdvance / cf.totalLoanAmount : 0;

		//liquidity test - single asset
		cf.unfundedAcquisition = cf.purchasePrice - cf.maxInitialLoanAmount;
		cf.twentyOfRehab  = cf.renoBudget * .2;
		cf.threeMonthsInterest = cf.totalLoanAmount * cf.interestRate * 90/360/100;
		cf.totalCurrentLiquidityNeeded = cf.unfundedAcquisition + cf.twentyOfRehab + cf.threeMonthsInterest;

		component.set('v.calculatorFields', cf);

		console.log(cf);

	}
})