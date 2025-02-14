import ballerina/io;
import ballerina/lang.regexp;

type Customer record {|
    string name;
    string city;
    string phone;
|};

# Categorizes a dataset based on a string field using a set of regular expressions.
# ```ballerina
# import ballerina/regexp;
# record {}[] dataset = [
#     { "name": "Alice", "city": "New York" },
#     { "name": "Bob", "city": "newyork-usa" },
#     { "name": "John", "city": "new york" },
#     { "name": "Charlie", "city": "Los Angeles" }
# ];
# string fieldName = "name";
# regexp:RegExp[] regexArray = [re `A.*$`, re `^B.*$`, re `^C.*$`];
# record {}[][] categorized = check categorizeRegexData(dataset, fieldName, regexArray);
# ```
# 
# + dataset - Array of records containing string values.
# + fieldName - Name of the string field to categorize.
# + regexArray - Array of regular expressions for matching categories.
# + return - A nested array of categorized records or an error if categorization fails.
function categorizeRegexData(record {}[] dataset, string fieldName, regexp:RegExp[] regexArray) returns record {}[][]|error {
    do {
        record {}[][] categorizedData = [];
        foreach int i in 0 ... regexArray.length() {
            categorizedData.push([]);
        }
        foreach record {} data in dataset {

            boolean isCategorized = false;
            foreach regexp:RegExp regex in regexArray {
                if regex.isFullMatch((data[fieldName].toString())) {
                    categorizedData[<int>regexArray.indexOf(regex)].push(data);
                    isCategorized = true;
                    break;
                }
            }
            if (!isCategorized) {
                categorizedData[regexArray.length()].push(data);
            }
        }
        return categorizedData;
    } on fail error e {
        return e;
    }
}


public function main() returns error? {

    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");
    regexp:RegExp[] regexArray = [re `^\(\+90.*`, re `^\(\+91.*`, re `^\(\+92.*`, re `^\(\+93.*`, re `^\(\+94.*`];
    record {}[][] categorizedCustomers = check categorizeRegexData(customers, "phone", regexArray);

    io:println(`Category 1(Phone (+90)) : ${categorizedCustomers[0]} ${"\n\n"}Category 2(Phone (+91)) : ${categorizedCustomers[1]} ${"\n\n"}Category 3(Phone (+92)) : ${categorizedCustomers[2]} ${"\n\n"}Category 4(Phone (+93)) : ${categorizedCustomers[3]} ${"\n\n"}Category 5(Phone (+94)) : ${categorizedCustomers[4]} ${"\n\n"}Category 6(Other) : ${categorizedCustomers[5]} ${"\n"}`);
    foreach int i in 0 ... regexArray.length() {
        check io:fileWriteCsv(string `./resources/customers${i + 1}.csv`, categorizedCustomers[i]);
    }
}
