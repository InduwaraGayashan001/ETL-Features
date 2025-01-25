import ballerina/io;
import ballerina/random;

type Customer record {|
    string name;
    string city;
    string phone;
    int age;
|};

function splitDataByRatio(record{}[] data, float ratio) returns record{}[][]|error {

    int dataLength = data.length();
    int splittingPoint = <int>(dataLength * ratio);
    io:println(splittingPoint);

    record{}[] shuffledData = check shuffle(data);

    record{}[] splittedData1 = shuffledData.slice(0,splittingPoint);
    record{}[] splittedData2 = shuffledData.slice(splittingPoint);

    return [splittedData1, splittedData2];

}

function shuffle(record{}[] data) returns record{}[]|error {

    int dataLength = data.length();

    foreach int i in 0 ... dataLength - 1 {
        int|random:Error randomIndex = random:createIntInRange(i, dataLength - 1);
        if randomIndex is int {
            record{} temp = data[i];
            data[i] = data[randomIndex];
            data[randomIndex] = temp;
        }else{
            return error("Error occurred during the randomization process");
        }
    }
    return data;
}

public function main() returns error? {
    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");
    record{}[][] splittedCustomers = check splitDataByRatio(customers, 0.7);
    io:println(`First Dataset : ${splittedCustomers[0]} ${"\n\n"}Second Dataset : ${splittedCustomers[1]}${"\n"}`);
    check io:fileWriteCsv("./resources/customers_1.csv",splittedCustomers[0]);
    check io:fileWriteCsv("./resources/customers_2.csv",splittedCustomers[1]);    
}
