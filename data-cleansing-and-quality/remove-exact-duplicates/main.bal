import ballerina/io;

type SalesOrder record {|
    string itemId;
    string customerId;
    string itemName;
    int quantity;
    int date;
|};

function removeDuplicates(record {}[] dataWithDuplicates) returns record {}[]|error {
    return from var data in dataWithDuplicates
        group by data
        select data;
}

public function main() returns error? {

    SalesOrder[] orders = check io:fileReadCsv("./resources/orders.csv");
    record {}[] uniqueOrders = check removeDuplicates(orders);
    io:println(`Unique Orders: ${uniqueOrders}${"\n"}`);
    check io:fileWriteCsv("./resources/unique_orders.csv", uniqueOrders);
}
