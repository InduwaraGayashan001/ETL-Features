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

function joinData(record {}[] dataSet1, record {}[] dataSet2, string primaryKey) returns record{}[]|error {

    record{}[] updatedCustomers =[];

    record {}[][] similarCustomers = from record{} data1 in dataSet1 join record{} data2 in dataSet2 on data1[primaryKey] equals data2[primaryKey] select [data1,data2];
    foreach record{}[] similarCustomer in similarCustomers{
        foreach string key in similarCustomer[1].keys(){
            if similarCustomer[0].hasKey(primaryKey) && similarCustomer[1].hasKey(primaryKey){
                similarCustomer[0][key] = similarCustomer[1][key];

            }else{
                return error("Invalid Primary key");
            }
            
        }
        updatedCustomers.push(similarCustomer[0]);          
    }
    return updatedCustomers;   
}

public function main() returns error? {

    Customers[] customers = check io:fileReadCsv("./resources/customers.csv");
    ContactDetails[] contactDetails = check io:fileReadCsv("./resources/contact_details.csv");

    record {}[] customerDetails = check joinData(customers, contactDetails, "customerId");

    io:println(`Updated Customer Details: ${customerDetails}${"\n"}`);
    check io:fileWriteCsv("./resources/customer_details.csv",customerDetails);
}

