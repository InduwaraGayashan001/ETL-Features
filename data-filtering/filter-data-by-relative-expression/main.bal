import ballerina/io;

type Customer record {|
    string name;
    string city;
    string phone;
    int age;
|};

function filterDataByRelativeExp(record {}[] dataSet, string fieldName, string operation, float value) returns [record {}[], record {}[]]|error {
    do {
        record {}[] matchedData = [];
        record {}[] nonMatchedData = [];

        function (float fieldValue, string relativeOperation, float comparisonValue) returns boolean|error evaluateCondition = function(float fieldValue, string relativeOperation, float comparisonValue) returns boolean|error {
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
            float fieldValue = <float>data[fieldName];
            boolean conditionResult = check evaluateCondition(fieldValue, operation, value);
            if conditionResult {
                matchedData.push(data);
            } else {
                nonMatchedData.push(data);
            }
        }
        return [matchedData, nonMatchedData];
    } on fail error e {
        return e;
    }
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
