import ballerina/io;

type Customer record {|
    string? name;
    string? city;
    string? phone;
|};

function removeNull(record {}[] dataSet) returns record {}[] {

    record {}[] cleanedData = from record {} data in dataSet
        where !isContainNull(data)
        select data;
    return cleanedData;

}

function isContainNull(record {} data) returns boolean {
    boolean containNull = false;
    foreach string key in data.keys() {
        if data[key] is null || data[key].toString().trim() == "" {
            containNull = true;
            break;
        }
    }
    return containNull;
}

public function main() returns error? {

    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");
    record {}[] cleanedCustomers = removeNull(customers);
    check io:fileWriteCsv("./resources/cleaned_customers.csv", cleanedCustomers);

}
