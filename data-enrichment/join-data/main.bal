import ballerina/io;

type Customers record {
    string customerId;
    string name;
    int age;
};

type ContactDetails record {
    string customerId;
    string phone;
    string address;
    string country;
};

# Merges two datasets based on a common primary key, updating records from the first dataset with matching records from the second.
# ```ballerina
# record {}[] dataset1 = [{id: 1, name: "Alice"}, {id: 2, name: "Bob"}];
# record {}[] dataset2 = [{id: 1, age: 25}, {id: 2, age: 30}];
# string primaryKey = "id";
# record {}[] mergedData = check joinData(dataset1, dataset2, primaryKey);
# ```
# 
# + dataSet1 - First dataset containing base records.
# + dataSet2 - Second dataset with additional data to be merged.
# + primaryKey - The field used to match records between the datasets.
# + return - A merged dataset with updated records or an error if merging fails.
function joinData(record {}[] dataSet1, record {}[] dataSet2, string primaryKey) returns record {}[]|error {
    do {
        record {}[] updatedCustomers = [];
        record {}[][] similarCustomers = from record {} data1 in dataSet1
            join record {} data2 in dataSet2 on data1[primaryKey] equals data2[primaryKey]
            select [data1, data2];
        foreach record {}[] similarCustomer in similarCustomers {
            foreach string key in similarCustomer[1].keys() {
                similarCustomer[0][key] = similarCustomer[1][key];
            }
            updatedCustomers.push(similarCustomer[0]);
        }
        return updatedCustomers;
    } on fail error e {
        return e;
    }
}


public function main() returns error? {

    Customers[] customers = check io:fileReadCsv("./resources/customers.csv");
    ContactDetails[] contactDetails = check io:fileReadCsv("./resources/contact_details.csv");
    record {}[] customerDetails = check joinData(customers, contactDetails, "customerId");

    io:println(`Updated Customer Details: ${customerDetails}${"\n"}`);
    check io:fileWriteCsv("./resources/customer_details.csv", customerDetails);
}

