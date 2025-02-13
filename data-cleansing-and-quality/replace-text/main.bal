import ballerina/io;
import ballerina/lang.regexp;

type Customer record {|
    string name;
    string city;
    string phone;
|};

function repalaceText(record {}[] dataSet, string fieldName, regexp:RegExp searchValue, string replaceValue) returns record {}[]|error {
    do {
        foreach record {} data in dataSet {
            string newData = searchValue.replace(data[fieldName].toString(), replaceValue);
            data[fieldName] = newData;
        }
        return dataSet;
    } on fail error e {
        return e;
    }
}

public function main() returns error? {
    
    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");
    regexp:RegExp regexPattern = re `^0+\d`;
    string fieldName = "phone";
    string replacement = "(+94) ";
    record {}[] updatedCustomers = check repalaceText(customers, fieldName, regexPattern, replacement);

    io:println(`Data after replacement: ${updatedCustomers}${"\n"}`);
    check io:fileWriteCsv("./resources/customers_after_replacement.csv", updatedCustomers);

}
