({
	calculateFields : function(component) {

		var cf = component.get('v.calculatorFields');

		console.log(cf.asIsValue);

		cf.asIsValue = $A.util.isUndefinedOrNull(cf.asIsValue) || $A.util.isEmpty(cf.asIsValue) ? 0 : parseFloat(cf.asIsValue);
		cf.afterRehabValue = $A.util.isUndefinedOrNull(cf.afterRehabValue) || $A.util.isEmpty(cf.afterRehabValue) ? 0 : parseFloat(cf.afterRehabValue);
		cf.purchasePrice = $A.util.isUndefinedOrNull(cf.purchasePrice) || $A.util.isEmpty(cf.purchasePrice) ? 0 : parseFloat(cf.purchasePrice);
		cf.rehabBudget = $A.util.isUndefinedOrNull(cf.rehabBudget) || $A.util.isEmpty(cf.rehabBudget) ? 0 : parseFloat(cf.rehabBudget);
		cf.interestRate = $A.util.isUndefinedOrNull(cf.interestRate) || $A.util.isEmpty(cf.interestRate) ? 0 : parseFloat(cf.interestRate);
		cf.maxInitialLTVLTC = $A.util.isUndefinedOrNull(cf.maxInitialLTVLTC) || $A.util.isEmpty(cf.maxInitialLTVLTC) ? 0 : parseFloat(cf.maxInitialLTVLTC);
		cf.totalARVLTV = $A.util.isUndefinedOrNull(cf.totalARVLTV) || $A.util.isEmpty(cf.totalARVLTV) ? 0 : parseFloat(cf.totalARVLTV);
		cf.rehabHoldbackLimit = $A.util.isUndefinedOrNull(cf.rehabHoldbackLimit) || $A.util.isEmpty(cf.rehabHoldbackLimit) ? 0 : parseFloat(cf.rehabHoldbackLimit);
		cf.totalLoanLTC = $A.util.isUndefinedOrNull(cf.totalLoanLTC) || $A.util.isEmpty(cf.totalLoanLTC) ? 0 : parseFloat(cf.totalLoanLTC);
		//console.log(cf.rehabBudget);
		//console.log(cf.purchasePrice);


		//Initial Advance section
		//as is value reference
		//as is limit reference
		cf.asIsLimitor = cf.maxInitialLTVLTC/100;
		cf.asIsMaxPotentialAdvance = cf.asIsValue * cf.asIsLimitor;
		//purchase price reference	
		//purchase Limitor reference
		cf.purchaseLimitor = cf.maxInitialLTVLTC/100;
		cf.purchasePotentialAdvance = cf.purchasePrice * cf.maxInitialLTVLTC/100;
		cf.maxInitialLoanAmount = Math.min(cf.asIsMaxPotentialAdvance, cf.purchasePotentialAdvance);

		//total loan advance amount
		cf.afterRepairValue = cf.afterRehabValue;
		cf.afterRepairLimitors = cf.totalARVLTV/100;
		cf.afterRepairPotentialAdvance = cf.afterRepairValue * cf.afterRepairLimitors;
		cf.totalCostBasisValue = cf.purchasePrice + cf.rehabBudget;
		cf.totalCostBasisLimitors = cf.totalLoanLTC/100;
		cf.totalCostBasisPotentialAdvance = cf.totalCostBasisValue * cf.totalCostBasisLimitors;
		cf.maxTotalLoanAmount = Math.min(cf.afterRepairPotentialAdvance, cf.totalCostBasisPotentialAdvance); 

		//Holdback Advance
		cf.maxAvailableForRehabBasedOnARVLTCLimitors = cf.maxTotalLoanAmount - cf.maxInitialLoanAmount;
		cf.maxAllowableRehabBasedOnHoldbackLimit = cf.maxTotalLoanAmount * cf.rehabHoldbackLimit/100;
		cf.totalLoanAmountLimitor = cf.maxInitialLoanAmount / (1 - cf.rehabHoldbackLimit/100) * cf.rehabHoldbackLimit/100;
		cf.borrowerRehabBudget = cf.rehabBudget;
		cf.approvedHoldback = Math.min(cf.maxAvailableForRehabBasedOnARVLTCLimitors, cf.maxAllowableRehabBasedOnHoldbackLimit, cf.totalLoanAmountLimitor, cf.borrowerRehabBudget);

		//final output
		cf.initialAdvance = cf.maxInitialLoanAmount;
		cf.holdbackAdvance = cf.approvedHoldback;
		cf.totalLoanAmount = cf.maxInitialLoanAmount + cf.approvedHoldback;

		//summary loan metrics
		cf.asIsLTV = (cf.asIsValue != null && cf.asIsValue != 0) ? (cf.initialAdvance / cf.asIsValue) : 0;
		cf.asIsLTC = (cf.purchasePrice != null && cf.purchasePrice != 0) ? (cf.initialAdvance / cf.purchasePrice) : 0; 
		cf.totalLoanARVLTV = (cf.afterRehabValue != null && cf.afterRehabValue != 0) ? (cf.totalLoanAmount / cf.afterRehabValue) : 0;
		//cf.totalLoanLTC = ((cf.)

		cf.totalLoanLTCSummary = (cf.purchasePrice != null && cf.rehabBudget != null && cf.purchasePrice != 0 && cf.rehabBudget != 0) 
													? (cf.totalLoanAmount / (cf.purchasePrice + cf.rehabBudget)) : 0;

		cf.perInitialAdvance = (cf.totalLoanAmount != null && cf.totalLoanAmount != 0) ? cf.initialAdvance / cf.totalLoanAmount : 0;

		cf.perHoldback = (cf.totalLoanAmount != null && cf.totalLoanAmount != 0) ? cf.holdbackAdvance / cf.totalLoanAmount : 0;

		//liquidity test - single asset
		cf.unfundedAcquisition = cf.purchasePrice - cf.maxInitialLoanAmount;
		cf.twentyOfRehab  = cf.rehabBudget * .2;
		cf.threeMonthsInterest = cf.totalLoanAmount * cf.interestRate * 90/360/100;
		cf.totalCurrentLiquidityNeeded = cf.unfundedAcquisition + cf.twentyOfRehab + cf.threeMonthsInterest;

		component.set('v.calculatorFields', cf);

		console.log(cf);

	}
})