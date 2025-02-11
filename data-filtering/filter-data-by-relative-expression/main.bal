import ballerina/io;

type Customer record {|
    string name;
    string city;
    string phone;
    int age;
|};

function filterDataByRelativeExp(record {}[] dataSet, string fieldName, string operation, float value) returns [record {}[], record {}[]]|error {

    record {}[] matchedData = [];
    record {}[] nonMatchedData = [];

    function (float fieldValue, string relativeOperation, float comparisonValue) returns boolean|error evaluateCondition = function (float fieldValue, string relativeOperation, float comparisonValue) returns boolean|error {
        match operation {
            ">" => {
                return fieldValue > value;
            }
            "<" => {
                return fieldValue < value;
            }
            ">=" => {
                return fieldValue >= value;
            }
            "<=" => {
                return fieldValue <= value;
            }
            "==" => {
                return fieldValue == value;
            }
            "!=" => {
                return fieldValue != value;
            }
            _ => {
                return error("Unsupported operation for numeric values");
            }
        }
    };

    foreach record {} data in dataSet {
        boolean isNumericData = data[fieldName].toString().matches(re `^[0-9,\.]*$`);
        if data.hasKey(fieldName) && isNumericData {
            float fieldValue = <float>data[fieldName];
            boolean|error conditionResult = evaluateCondition(fieldValue, operation, value);

            if conditionResult is boolean {
                if conditionResult {
                    matchedData.push(data);
                } else {
                    nonMatchedData.push(data);
                }
            } else {
                return conditionResult;
            }
        } else if !isNumericData {
            return error("Provided field includes non-numeric values");
        } else {
            return error("Provided field deos not exist in the data");
        }
    }
    return [matchedData, nonMatchedData];
}

public function main() returns error? {

    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");

    string fieldName = "age";
    string operation = ">";
    float value = 21;

    [record {}[], record {}[]] [matchedCustomers, nonMatchedCustomers] = check filterDataByRelativeExp(customers, fieldName, operation, value);

    io:println(`Matched Data: ${matchedCustomers} ${"\n\n"}Non Matched Data: ${nonMatchedCustomers}${"\n"}`);

    check io:fileWriteCsv("./resources/matched_customers.csv", matchedCustomers);
    check io:fileWriteCsv("./resources/non_matched_customers.csv", nonMatchedCustomers);

}
