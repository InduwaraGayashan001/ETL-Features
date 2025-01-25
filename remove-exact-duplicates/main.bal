import ballerina/io;

type SalesOrder record {|
    string itemId;
    string customerId;
    string itemName;
    int quantity;
    int date;
|};

function removeDuplicates(record{}[] dataWithDuplicates) returns record{}[]{
    record{}[] dataWithoutDuplicates = [];
    foreach record{} data in dataWithDuplicates{
        if dataWithoutDuplicates.indexOf(data) == (){
            dataWithoutDuplicates.push(data);
        }
    }
    return dataWithoutDuplicates;
}

public function main() returns error? {
    
    SalesOrder[] orders = check io:fileReadCsv("./resources/orders.csv");

    record{}[] uniqueOrders = removeDuplicates(orders);
    io:println(uniqueOrders);

    check io:fileWriteCsv("./resources/unique_orders.csv", uniqueOrders);
}
