import ballerina/io;

type Customer record {|
    string name;
    string city;
    string phone;
    int age;
|};

# Sorts a dataset based on a specific field in ascending or descending order.
# ```ballerina
# record {}[] dataset = [
#     { "name": "Alice", "age": 25 },
#     { "name": "Bob", "age": 30 },
#     { "name": "Charlie", "age": 22 }
# ];
# string fieldName = "age";
# boolean isAscending = true;
# record {}[] sortedData = check sort(dataset, fieldName, isAscending);
# ```
#
# + dataset - Array of records to be sorted.
# + fieldName - The field by which sorting is performed.
# + isAscending - Boolean flag to determine sorting order (default: ascending).
# + return - A sorted dataset based on the specified field.
function sort(record {}[] dataset, string fieldName, boolean isAscending = true) returns record {}[]|error {
    do{
        if isAscending {
            return from record {} data in dataset
                order by data[fieldName].toString() ascending
                select data;
        }
        else {
            return from record {} data in dataset
                order by data[fieldName].toString() descending
                select data;
        }
    } on fail error e{
        return e;
    }
}

public function main() returns error? {

    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");
    record {}[] sortedCustomers = check sort(customers, "age");
    
    io:println(`Sorted Customers: ${sortedCustomers}${"\n"}`);
    check io:fileWriteCsv("./resources/sorted_customers.csv", sortedCustomers);
}
