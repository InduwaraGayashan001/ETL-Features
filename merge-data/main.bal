import ballerina/io;

type Customer record {|
    string name;
    string city;
    string phone;
|};

function mergeData(record{}[][] dataSets) returns record{}[] {
    record {}[]mergedData = [];
    foreach record{}[] dataSet in dataSets{
        foreach record{} data in dataSet{
            mergedData.push(data);
        }
    }
    return mergedData;
}


public function main() returns error? {
    Customer[] customers1 = check io:fileReadCsv("./resources/customers1.csv");
    Customer[] customers2 = check io:fileReadCsv("./resources/customers2.csv");
    Customer[] customers3 = check io:fileReadCsv("./resources/customers3.csv");
    record{}[] mergedCustomers = mergeData([customers1, customers2, customers3]);
    io:println(`Merged Data : ${mergedCustomers}${"\n"}`);

    check io:fileWriteCsv("./resources/customers.csv",mergedCustomers);

}
