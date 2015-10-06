
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

Parse.Cloud.define("transactionReview", function(request, response) {
	
	var userId = request.params.userId;
	var timePeriod = request.params.timePeriod;
	var language = request.params.language;
	if (language == null) {
		language = "VNName";
	}
	
	console.log("userID = " + userId + "/ with language = " + language);
	
	var query = new Parse.Query("Transaction");
	query.equalTo("userId", userId);
	query.include("category");
	
	query.find({
	  success: function(results) {
		  var group = {"income": {}, "expense": {}};
		
		  for (var i = 0; i < results.length; i++) {
			  var trans = results[i];
			  
			  var categoryId = trans.get("category").id;
			  var amount = trans.get("amount");
			  
			  if (trans.get("type") == 0) { // Expense group
				  if (group.expense[categoryId] == null) {
					  group.expense[categoryId] = {"amount": amount, "name":""};
					  group.expense[categoryId].name = trans.get("category").get(language);

				  } else {
					  group.expense[categoryId].amount += amount;
				  }
				  
			  } else { // Income group
				  if (group.income[categoryId] == null) {
					  group.income[categoryId] = {"amount": amount, "name":""};
					  group.income[categoryId].name = trans.get("category").get(language);
					  
				  } else {
					  group.expense[categoryId].amount += amount;
				  }
			  }
		  }
		  response.success(group);
	  },
	  error: function(error) {
		  response.error("Error: " + error.code + " " + error.message);
	  }
	});
});