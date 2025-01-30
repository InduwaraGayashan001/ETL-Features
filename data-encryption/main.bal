import ballerina/io;
import ballerina/crypto;
import ballerina/lang.array;


type Customer record {|
    string name;
    string city;
    string phone;
|};

configurable string key  = ?;

function encryptData(record{}[] dataSet, string[] fieldNames, string keyBase64) returns record{}[]|error {
    byte[] encrypt_key = check array:fromBase64(keyBase64);
    foreach record{} data in dataSet{
        foreach string fieldName in fieldNames{
            if data.hasKey(fieldName){
                byte[] dataByte = data[fieldName].toString().toBytes();
                byte[] cipherText = check crypto:encryptAesEcb(dataByte, encrypt_key);
                data[fieldName] = cipherText.toBase64();
            }else{
                return error("Invalid Field Name");
            }
        }   
    }
    return dataSet;
}

function decryptData(record{}[] dataSet , string[] fieldNames, string keyBase64) returns record{}[]|error{
     byte[] decrypt_key = check array:fromBase64(keyBase64);
    foreach record{} data in dataSet{
        foreach string fieldName in fieldNames{
            if data.hasKey(fieldName){
                byte[] dataByte = check array:fromBase64(data[fieldName].toString());
                byte[] plainText = check crypto:decryptAesEcb(dataByte, decrypt_key);
                data[fieldName] = check string:fromBytes(plainText);
            }else{
                return error("Invalid Field Name");
            }
        }
    }
    return dataSet;
}

public function main() returns error?{
    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");
    record{}[] encryptedCustomers = check encryptData(customers,["city","phone"] , key);
    check io:fileWriteCsv("./resources/encrypted_customers.csv", encryptedCustomers);
    record {}[] decryptedCustomers = check decryptData(customers,["city","phone"], key);
    check io:fileWriteCsv("./resources/decrypted_customers.csv", decryptedCustomers);
}
