import ballerina/io;

type SalesOrder record {|
    string itemId;
    string customerId;
    string itemName;
    int quantity;
    int date;
|};

# Removes duplicate records from the dataset based on their exact content.
# ```ballerina
# record {}[] dataset = [
#     { "name": "Alice", "city": "New York" },
#     { "name": "Bob", "city": "Los Angeles" },
#     { "name": "Alice", "city": "New York" }
# ];
# record {}[] uniqueData = check removeDuplicates(dataset);
# ```
#
# + dataset - Array of records that may contain duplicates.
# + return - A dataset with duplicates removed.

function removeDuplicates(record {}[] dataset) returns record {}[]|error {
    do {
        return from var data in dataset
            group by data
            select data;
    } on fail error e {
        return e;
    }
}

public function main() returns error? {

    SalesOrder[] orders = check io:fileReadCsv("./resources/orders.csv");
    record {}[] uniqueOrders = check removeDuplicates(orders);
    
    io:println(`Unique Orders: ${uniqueOrders}${"\n"}`);
    check io:fileWriteCsv("./resources/unique_orders.csv", uniqueOrders);
}
