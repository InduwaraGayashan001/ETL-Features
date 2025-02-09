import ballerina/io;

type Customer record {|
    string name;
    string city;
    string phone;
    int age;
|};

function sort(record {}[] dataSet, string fieldName, boolean isAscending = true) returns record {}[]|error {

    if isAscending {
        return from record {} data in dataSet
            order by data[fieldName].toString() ascending
            select data;
    }
    else {
        return from record {} data in dataSet
            order by data[fieldName].toString() descending
            select data;
    }
}

public function main() returns error? {

    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");
    record {}[] sortedCustomers = check sort(customers, "age");
    io:println(`Sorted Customers: ${sortedCustomers}${"\n"}`);
    check io:fileWriteCsv("./resources/sorted_customers.csv", sortedCustomers);
}
