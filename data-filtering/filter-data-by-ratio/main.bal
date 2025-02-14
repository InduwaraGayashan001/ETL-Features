import ballerina/io;
import ballerina/random;

type Customer record {|
    string name;
    string city;
    string phone;
    int age;
|};

function filterDataByRatio(record {}[] dataSet, float ratio) returns [record {}[], record {}[]]|error {
    do {
        function (record {}[] data) returns record {}[]|error shuffle = function(record {}[] data) returns record {}[]|error {
            int dataLength = data.length();
            foreach int i in 0 ... dataLength - 1 {
                int randomIndex = check random:createIntInRange(i, dataLength);
                record {} temp = data[i];
                data[i] = data[randomIndex];
                data[randomIndex] = temp;
            }
            return data;
        };
        int dataLength = dataSet.length();
        int splittingPoint = <int>(dataLength * ratio);
        record {}[] shuffledData = check shuffle(dataSet);
        return [shuffledData.slice(0, splittingPoint), shuffledData.slice(splittingPoint)];
    } on fail error e {
        return e;
    }

}

public function main() returns error? {

    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");
    [record {}[], record {}[]] [customers1, customers2] = check filterDataByRatio(customers, 0.7);

    io:println(`First Dataset : ${customers1} ${"\n\n"}Second Dataset : ${customers2}${"\n"}`);
    check io:fileWriteCsv("./resources/customers_1.csv", customers1);
    check io:fileWriteCsv("./resources/customers_2.csv", customers2);
}
