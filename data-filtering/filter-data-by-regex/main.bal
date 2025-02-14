import ballerina/io;
import ballerina/lang.regexp;

type Customer record {|
    string name;
    string city;
    string phone;
|};

# Filters a dataset into two subsets based on a regex pattern match.
# ```ballerina
# record {}[] dataset = [
#     { "id": 1, "city": "New York" },
#     { "id": 2, "city": "Los Angeles" },
#     { "id": 3, "city": "Newark" },
#     { "id": 4, "city": "San Francisco" }
# ];
# string fieldName = "city";
# regexp:RegExp regexPattern = re `^New.*$`;
# [record {}[] matched, record {}[] nonMatched] = check filterDataByRegex(dataset, fieldName, regexPattern);
# ```
#
# + dataSet - Array of records to be filtered.
# + fieldName - Name of the field to apply the regex filter.
# + regexPattern - Regular expression to match values in the field.
# + return - A tuple with two subsets: matched and non-matched records.
function filterDataByRegex(record {}[] dataSet, string fieldName, regexp:RegExp regexPattern) returns [record {}[], record {}[]]|error {
    do {
        record {}[] matchedData = from record {} data in dataSet
            where regexPattern.isFullMatch((data[fieldName].toString()))
            select data;
        record {}[] nonMatchedData = from record {} data in dataSet
            where !regexPattern.isFullMatch((data[fieldName].toString()))
            select data;
        return [matchedData, nonMatchedData];
    } on fail error e {
        return e;
    }
}

public function main() returns error? {
    
    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");
    regexp:RegExp regexPattern = re `^\(\+94.*`;
    string fieldName = "phone";
    [record {}[], record {}[]] [matchedCustomers, nonMatchedCustomers] = check filterDataByRegex(customers, fieldName, regexPattern);

    io:println(`Matched Data: ${matchedCustomers} ${"\n\n"}Non Matched Data: ${nonMatchedCustomers}${"\n"}`);
    check io:fileWriteCsv("./resources/matched_customers.csv", matchedCustomers);
    check io:fileWriteCsv("./resources/non_matched_customers.csv", nonMatchedCustomers);
}

