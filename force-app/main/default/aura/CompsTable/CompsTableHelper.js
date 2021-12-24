({
	toString: function(field) {
		return field != null ? field.toString() : '';
	},

	toCurrency: function(field, round) {
		if (round) {
			return field != null ? '$' + field.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,').slice(0, -3) : '';
		}
		else {
			return field != null ? '$' + field.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,') : '';
		}
	},
})