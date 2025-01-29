import ballerina/io;
import ballerina/lang.regexp;

type Customer record {|
    string name;
    string city;
    string phone;
|};

function splitDataByRegex(record {}[] dataSet, string fieldName, regexp:RegExp regexPattern) returns record {}[][]|error {

    record {}[] matchedData = from record {} data in dataSet
        where regexPattern.isFullMatch((data[fieldName].toString()))
        select data;
    record {}[] nonMatchedData = from record {} data in dataSet
        where !regexPattern.isFullMatch((data[fieldName].toString()))
        select data;

    return [matchedData, nonMatchedData];
}

public function main() returns error? {
    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");
    regexp:RegExp regexPattern = re `^\(\+94.*`;
    string fieldName = "phone";

    record {}[][] splittedCustomers = check splitDataByRegex(customers, fieldName, regexPattern);

    io:println(`Matched Data: ${splittedCustomers[0]} ${"\n\n"}Non Matched Data: ${splittedCustomers[1]}${"\n"}`);

    check io:fileWriteCsv("./resources/matched_customers.csv", splittedCustomers[0]);
    check io:fileWriteCsv("./resources/non_matched_customers.csv", splittedCustomers[1]);

}

