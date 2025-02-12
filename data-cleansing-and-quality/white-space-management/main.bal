import ballerina/io;

type Customer record {|
    string name;
    string city;
    string phone;
|};

function handleWhiteSpaces(record {}[] dataSet) returns record {}[] {

    foreach record {} data in dataSet {
        foreach string key in data.keys() {
            data[key] = re `\s+`.replaceAll(data[key].toString(), " ").trim();
        }
    }
    return dataSet;
}

public function main() returns error? {

    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");
    record{}[] cleanedCustomers = handleWhiteSpaces(customers);
    io:println(`Updated Customers: ${cleanedCustomers}${"\n"}`);
    check io:fileWriteCsv("./resources/cleaned_customers.csv", cleanedCustomers);
}
