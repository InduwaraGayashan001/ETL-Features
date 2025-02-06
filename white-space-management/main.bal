import ballerina/io;

type Customer record {|
    string name;
    string city;
    string phone;
|};

function handleWhiteSpaces(record {}[] dataSet) returns record {}[] {

    foreach record {} data in dataSet{ 
        foreach string key in data.keys(){  
            data[key] = re `\s+`.replaceAll(data[key].toString(), " ").trim();
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
