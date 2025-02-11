import ballerina/io;

type Customer record {|
    string? name;
    string? city;
    string? phone;
|};

function removeNull(record {}[] dataSet) returns record {}[]|error {

    do {
        function (record {} data) returns boolean isContainNull = function(record {} data) returns boolean {
            boolean containNull = false;
            foreach string key in data.keys() {
                if data[key] is null || data[key].toString().trim() == "" {
                    containNull = true;
                    break;
                }
            }
            return containNull;
        };

        return from record {} data in dataSet
            where !isContainNull(data)
            select data;
    } on fail error e {
        return e;
    }

}

public function main() returns error? {

    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");
    record {}[] cleanedCustomers = check removeNull(customers);
    io:println(`Updated Customers: ${cleanedCustomers}${"\n"}`);
    check io:fileWriteCsv("./resources/cleaned_customers.csv", cleanedCustomers);

}
