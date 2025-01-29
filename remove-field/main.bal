import ballerina/io;

type Customer record {|
    string name;
    string city;
    string phone;
    int? age?;
|};

function removeField(record{}[] dataSet, string fieldName) returns record{}[]{
    record{}[] updatedData = from record{} data in dataSet let var val = data.remove(fieldName) where val != () select data;
    return updatedData;
}
public function main() returns error?{

    Customer[]  customers = check io:fileReadCsv("./resources/customers.csv");
    record{}[] updatedCustomers = removeField(customers,"age");
    check io:fileWriteCsv("./resources/updated_customers.csv",updatedCustomers);
    
}
