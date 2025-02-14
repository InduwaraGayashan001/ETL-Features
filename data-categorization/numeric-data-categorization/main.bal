import ballerina/io;

type Customer record {|
    string name;
    string city;
    string phone;
    int age;
|};

# Categorizes a dataset based on a numeric field and specified ranges.
# ```ballerina
# record {}[] dataset = [{value: 10.5}, {value: 25.0}, {value: 5.3}];
# string fieldName = "value";
# float[][] rangeArray = [[0.0, 10.0], [10.0, 20.0]];
# record {}[][] categorized = check categorizeNumeric(dataset, fieldName, rangeArray);
# ```
# 
# + dataset - Array of records containing numeric values.
# + fieldName - Name of the numeric field to categorize.
# + rangeArray - Array of float ranges specifying category boundaries.
# + return - A nested array of categorized records or an error if categorization fails.
function categorizeNumeric(record {}[] dataset, string fieldName, float[][] rangeArray) returns record {}[][]|error {
    do {
        record {}[][] categorizedData = [];
        foreach int i in 0 ... rangeArray.length() {
            categorizedData.push([]);
        }
        foreach record {} data in dataset {
            float fieldValue = <float>data[fieldName];
            boolean isCategorized = false;
            foreach float[] range in rangeArray {
                if (fieldValue >= range[0] && fieldValue < range[1]) {
                    categorizedData[<int>rangeArray.indexOf(range)].push(data);
                    isCategorized = true;
                    break;
                }
            }
            if (!isCategorized) {
                categorizedData[rangeArray.length()].push(data);
            }
        }
        return categorizedData;
    } on fail error e {
        return e;
    }
}


public function main() returns error? {

    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");
    float[][] rangeArray = [[10, 20], [20, 30], [30, 40], [40, 50], [50, 60]];
    record {}[][] categorizedCustomers = check categorizeNumeric(customers, "age", rangeArray);
    
    io:println(`Category 1(Age 10-20) : ${categorizedCustomers[0]} ${"\n\n"}Category 2(Age 20-30) : ${categorizedCustomers[1]} ${"\n\n"}Category 3(Age 30-40) : ${categorizedCustomers[2]} ${"\n\n"}Category 4(Age 40-50) : ${categorizedCustomers[3]} ${"\n\n"}Category 5(Age 50-60) : ${categorizedCustomers[4]} ${"\n\n"}Category 6(Other) : ${categorizedCustomers[5]} ${"\n"}`);
    foreach int i in 0 ... rangeArray.length() {
        check io:fileWriteCsv(string `./resources/customers${i + 1}.csv`, categorizedCustomers[i]);
    }

}

