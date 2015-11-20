
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
    response.success("Hello world!");
    });

Parse.Cloud.define("transactionReview", function(request, response) {
    // this function get all transaction was did in the date between fromDate & toDate (fromDate <= transactionDate < toDate)
    var userId = request.params.userId;
    var language = request.params.language;
    if (language == null) {
        language = "VNName";
    }
    
    var fromDate = request.params.fromDate;
    var toDate = request.params.toDate;
    
    console.log("userID = " + userId + "/ with language = " + language 
    + "/ fromDate = " + fromDate 
	+ " / toDate = " + toDate);
    
    
    // period time
  
    
    var query = new Parse.Query("Transaction");
    query.equalTo("userId", userId);
    query.include("category");
    
    if (fromDate == undefined || toDate == undefined){
	   // get all transactions
    } else {
	    query.greaterThanOrEqualTo("transactionDate", new Date(fromDate));
	    query.lessThan("transactionDate", new Date(toDate));
    }
    
    
    query.find({
        success: function(results) {
            var group = {"income": {}, "expense": {}};
            
            for (var i = 0; i < results.length; i++) {
                var trans = results[i];
                
                var categoryId = trans.get("category").id;
                var amount = trans.get("amount");
                console.log("categoryId=" + categoryId + "/ amount = " + amount);
                
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
                        group.income[categoryId].amount += amount;
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