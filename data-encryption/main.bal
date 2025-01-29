import ballerina/io;
import ballerina/crypto;
import ballerina/lang.array;


type Customer record {|
    string name;
    string city;
    string phone;
|};

configurable byte[16] key  = ?;

function encryptData(record{}[] dataSet, string fieldName) returns record{}[]|error {
    foreach record{} data in dataSet{
        if data.hasKey(fieldName){
            byte[] dataByte = data[fieldName].toString().toBytes();
            byte[] cipherText = check crypto:encryptAesEcb(dataByte, key);
            data[fieldName] = cipherText.toBase64();
        }
    }
    return dataSet;
}


function decryptData(record{}[] dataSet , string fieldName) returns record{}[]|error{
    foreach record{} data in dataSet{
        if data.hasKey(fieldName){
            byte[] dataByte = check array:fromBase64(data[fieldName].toString());
            byte[] plainText = check crypto:decryptAesEcb(dataByte, key);
            data[fieldName] = check string:fromBytes(plainText);
        }
    }
    return dataSet;
}

public function main() returns error?{
    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");
    record{}[] encryptedCustomers = check encryptData(customers,"phone");
    check io:fileWriteCsv("./resources/encrypted_customers.csv", encryptedCustomers);
    record {}[] decryptedCustomers = check decryptData(customers,"phone");
    check io:fileWriteCsv("./resources/decrypted_customers.csv", decryptedCustomers);
}
