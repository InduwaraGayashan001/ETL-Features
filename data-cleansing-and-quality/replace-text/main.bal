import ballerina/io;
import ballerina/lang.regexp;

type Customer record {|
    string name;
    string city;
    string phone;
|};

function repalaceText(record {}[] dataSet, string fieldName, regexp:RegExp searchValue, string replaceValue) returns record {}[]|error {

    foreach record {} data in dataSet {

        if data.hasKey(fieldName) {
            string newData = searchValue.replace(data[fieldName].toString(), replaceValue);
            data[fieldName] = newData;
        } else {
            return error("Provided field does not exit in the data");
        }
    }

    return dataSet;
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
