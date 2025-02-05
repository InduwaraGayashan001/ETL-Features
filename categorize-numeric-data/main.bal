import ballerina/io;

type Customer record {|
    string name;
    string city;
    string phone;
    int age;
|};

function categorizeData(record {}[] dataset, string fieldName, float[][] rangeArray) returns record {}[][]|error {

    record {}[][] categorizedData = [];
    foreach int i in 0 ... rangeArray.length() {
        categorizedData.push([]);
    }

    foreach record {} data in dataset {
        boolean isNumericData = data[fieldName].toString().matches(re `^[0-9,\.]*$`);
        if (data.hasKey(fieldName) && isNumericData) {
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
        } else if !isNumericData {
            return error("Provided field includes non-numeric values");

        } else {
            return error("Provided field deos not exist in the data");

        }
    }

    return categorizedData;
}

public function main() returns error? {

    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");
    float[][] rangeArray = [[10, 20], [20, 30], [30, 40], [40, 50], [50, 60]];

    record {}[][] categorizedCustomers = check categorizeData(customers, "age", rangeArray);

    io:println(`Category 1(Age 10-20) : ${categorizedCustomers[0]} ${"\n\n"}Category 2(Age 20-30) : ${categorizedCustomers[1]} ${"\n\n"}Category 3(Age 30-40) : ${categorizedCustomers[2]} ${"\n\n"}Category 4(Age 40-50) : ${categorizedCustomers[3]} ${"\n\n"}Category 5(Age 50-60) : ${categorizedCustomers[4]} ${"\n\n"}Category 6(Other) : ${categorizedCustomers[5]} ${"\n"}`);

    foreach int i in 0...rangeArray.length() {
        check io:fileWriteCsv(string `./resources/customers${i+1}.csv`, categorizedCustomers[i]);
  
    }

    
}

