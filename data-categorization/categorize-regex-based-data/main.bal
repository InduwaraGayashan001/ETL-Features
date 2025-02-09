import ballerina/io;
import ballerina/lang.regexp;

type Customer record {|
    string name;
    string city;
    string phone;
|};

function categorizeRegexData(record {}[] dataset, string fieldName, regexp:RegExp[] regexArray) returns record {}[][]|error {

    record {}[][] categorizedData = [];
    foreach int i in 0 ... regexArray.length() {
        categorizedData.push([]);
    }

    foreach record {} data in dataset {
        if data.hasKey(fieldName)  {
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

        } else {
            return error("Provided field deos not exist in the data");

        }
    }

    return categorizedData;
}

public function main() returns error? {

    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");
    regexp:RegExp[] regexArray = [re `^\(\+90.*`, re `^\(\+91.*`, re `^\(\+92.*`, re `^\(\+93.*`, re `^\(\+94.*`];

    record {}[][] categorizedCustomers = check categorizeRegexData(customers, "phone", regexArray);

    io:println(`Category 1(Phone (+90)) : ${categorizedCustomers[0]} ${"\n\n"}Category 2(Phone (+91)) : ${categorizedCustomers[1]} ${"\n\n"}Category 3(Phone (+92)) : ${categorizedCustomers[2]} ${"\n\n"}Category 4(Phone (+93)) : ${categorizedCustomers[3]} ${"\n\n"}Category 5(Phone (+94)) : ${categorizedCustomers[4]} ${"\n\n"}Category 6(Other) : ${categorizedCustomers[5]} ${"\n"}`);

    foreach int i in 0...regexArray.length() {
        check io:fileWriteCsv(string `./resources/customers${i+1}.csv`, categorizedCustomers[i]);
  
    }

    
}
