import ballerina/io;

type SalesOrder record {|
    string itemId;
    string customerId;
    string itemName;
    int quantity;
    int date;
|};

function removeDuplicates(record {}[] dataSet) returns record {}[]|error {
    do {
        return from var data in dataSet
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
