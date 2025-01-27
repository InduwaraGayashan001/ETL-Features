import ballerina/io;

type Customer record {|
    string name;
    string city;
    string phone;
    int age;
|};

function splitDataByOperation(record {}[] dataSet, string fieldName, string operation, float value) returns record {}[][]|error {

    record {}[] matchedData = [];
    record {}[] nonMatchedData = [];

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

function evaluateCondition(float fieldValue, string operation, float value) returns boolean|error {

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
}

public function main() returns error? {

    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");

    string fieldName = "age";
    string operation = ">";
    float value = 21;

    record {}[][] splittedCustomers = check splitDataByOperation(customers, fieldName, operation, value);

    io:println(`Matched Data: ${splittedCustomers[0]} ${"\n\n"}Non Matched Data: ${splittedCustomers[1]}${"\n"}`);

    check io:fileWriteCsv("./resources/matched_customers.csv", splittedCustomers[0]);
    check io:fileWriteCsv("./resources/non_matched_customers.csv", splittedCustomers[1]);
}

