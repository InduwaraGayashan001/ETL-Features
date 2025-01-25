import ballerina/io;
import ballerina/lang.regexp;

type Customer record {|
    string name;
    string city;
    string phone;
|};

function splitDataByRegex(record{}[] dataSet, string fieldName, regexp:RegExp regexPattern) returns record{}[][]|error {

    record{}[] matchedData = [];
    record{}[] nonMatchedData = [];

    foreach record{} data in dataSet {
        if data.hasKey(fieldName) {
            if regexPattern.isFullMatch(data[fieldName].toString()) {
                matchedData.push(data);
            } else {
                nonMatchedData.push(data);
            }       
        } else {
            return error("Provided field does not exit in the data");
        }  
    }
    return [matchedData, nonMatchedData];
}


public function main() returns error? {
    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");
    regexp:RegExp regexPattern = re `^\(\+94.*`;
    string fieldName = "phone"; 

    record{}[][] splittedCustomers = check splitDataByRegex(customers, fieldName, regexPattern);

    io:println(`Matched Data: ${splittedCustomers[0]} ${"\n\n"}Non Matched Data: ${splittedCustomers[1]}${"\n"}`);

    check io:fileWriteCsv("./resources/matched_customers.csv", splittedCustomers[0]);
    check io:fileWriteCsv("./resources/non_matched_customers.csv", splittedCustomers[1]);

}

