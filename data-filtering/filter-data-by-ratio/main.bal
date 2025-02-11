import ballerina/io;
import ballerina/random;

type Customer record {|
    string name;
    string city;
    string phone;
    int age;
|};

function filterDataByRatio(record {}[] dataSet, float ratio) returns [record {}[], record {}[]]|error {

    function (record {}[] data) returns record {}[]|error shuffle = function (record {}[] data) returns record {}[]|error{
        int dataLength = data.length();
        foreach int i in 0 ... dataLength - 1 {
            int|random:Error randomIndex = random:createIntInRange(i, dataLength - 1);
            if randomIndex is int {
                record {} temp = data[i];
                data[i] = data[randomIndex];
                data[randomIndex] = temp;
            } else {
                return error("Error occurred during the randomization process");
            }
        }
        return data;
    };

    int dataLength = dataSet.length();
    int splittingPoint = <int>(dataLength * ratio);
    record {}[] shuffledData = check shuffle(dataSet);
    record {}[] splittedData1 = shuffledData.slice(0, splittingPoint);
    record {}[] splittedData2 = shuffledData.slice(splittingPoint);

    return [splittedData1, splittedData2];

}

public function main() returns error? {
    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");
    [record {}[], record {}[]] [customers1, customers2] = check filterDataByRatio(customers, 0.7);
    io:println(`First Dataset : ${customers1} ${"\n\n"}Second Dataset : ${customers2}${"\n"}`);
    check io:fileWriteCsv("./resources/customers_1.csv", customers1);
    check io:fileWriteCsv("./resources/customers_2.csv", customers2);
}
