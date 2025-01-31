import ballerina/io;
import ballerina/lang.regexp;

type Customer record {|
    string name;
    string city;
    string phone;
|};

function splitDataByRegex(record {}[] dataSet, string fieldName, regexp:RegExp regexPattern) returns [record {}[], record{}[]]|error {

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

    [record {}[], record{}[]] [matchedCustomers, nonMatchedCustomers] = check splitDataByRegex(customers, fieldName, regexPattern);

    io:println(`Matched Data: ${matchedCustomers} ${"\n\n"}Non Matched Data: ${nonMatchedCustomers}${"\n"}`);

    check io:fileWriteCsv("./resources/matched_customers.csv", matchedCustomers);
    check io:fileWriteCsv("./resources/non_matched_customers.csv", nonMatchedCustomers);

}

