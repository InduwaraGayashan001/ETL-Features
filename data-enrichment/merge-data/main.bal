import ballerina/io;

type Customer record {|
    string name;
    string city;
    string phone;
|};

# Merges multiple datasets into a single dataset by flattening a nested array of records.
# ```ballerina
# record {}[][] dataSets = [
#     [{id: 1, name: "Alice"}, {id: 2, name: "Bob"}],
#     [{id: 3, name: "Charlie"}, {id: 4, name: "David"}]
# ];
# record {}[] mergedData = check mergeData(dataSets);
# ```
# 
# + dataSets - An array of datasets, where each dataset is an array of records.
# + return - A single merged dataset containing all records or an error if merging fails.
function mergeData(record {}[][] dataSets) returns record {}[]|error {
    do {
        return from record {}[] dataSet in dataSets
            from record {} data in dataSet
            select data;
    } on fail error e {
        return e;
    }
}


public function main() returns error? {

    Customer[] customers1 = check io:fileReadCsv("./resources/customers1.csv");
    Customer[] customers2 = check io:fileReadCsv("./resources/customers2.csv");
    Customer[] customers3 = check io:fileReadCsv("./resources/customers3.csv");
    record {}[] mergedCustomers = check mergeData([customers1, customers2, customers3]);

    io:println(`Merged Data : ${mergedCustomers}${"\n"}`);
    check io:fileWriteCsv("./resources/customers.csv", mergedCustomers);

}
