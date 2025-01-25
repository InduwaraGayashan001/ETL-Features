import ballerina/io;

type Customer record {|
    string name;
    string city;
    string phone;
|};

function handleWhiteSpaces(record {}[] dataSet) returns record {}[] {

    foreach record {} data in dataSet {
        foreach string key in data.keys() {
            string:RegExp extraSpaces = re `\s+`;
            string dataWithoutExtraSpaces = extraSpaces.replaceAll(data[key].toString(), " ");
            data[key] = dataWithoutExtraSpaces.trim();
        }
    }
    return dataSet;
}

public function main() returns error? {

    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");

    Customer[] cleanedCustomers = <Customer[]>handleWhiteSpaces(customers);

    io:println(cleanedCustomers);
    check io:fileWriteCsv("./resources/cleaned_customers.csv", cleanedCustomers);

}
