import ballerina/crypto;
import ballerina/io;
import ballerina/lang.array;
import ballerina/random;

configurable string key = ?;

type Customer record {
    string name;
    string city;
    string phone;
    int age;
};

function encryptData(record {}[] dataSet, string keyBase64) returns string[]|error {
    byte[] encrypt_key = check array:fromBase64(keyBase64);
    string[] encryptedDataSet = [];

    foreach int i in 0 ... dataSet.length() - 1 {
        byte[] dataByte = dataSet[i].toString().toBytes();
        byte[] cipherText = check crypto:encryptAesEcb(dataByte, encrypt_key);
        encryptedDataSet[i] = cipherText.toBase64();
    }
    return encryptedDataSet;
}

function decryptData(string[] dataSet, string keyBase64, typedesc<record{}> dataType) returns record {}[]|error {
    byte[] decrypt_key = check array:fromBase64(keyBase64);
    record {}[] decryptededDataSet = [];

    foreach int i in 0 ... dataSet.length() - 1 {
        byte[] dataByte = check array:fromBase64(dataSet[i]);
        byte[] plainText = check crypto:decryptAesEcb(dataByte, decrypt_key);
        string plainTextString = check string:fromBytes(plainText);
        decryptededDataSet[i] = check (check plainTextString.fromJsonString()).cloneWithType(dataType);
    }
    return decryptededDataSet;
}

public function main() returns error? {

    // Generate a new key
    byte[16] aesKey = [];
    foreach var i in 0 ... 15 {
        aesKey[i] = <byte>(check random:createIntInRange(0, 255));
    }
    // Copy and save this key value in the Config.toml
    string newKey = aesKey.toBase64();
    io:println(newKey);

    // Encrypt the data
    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");

    string[] encryptedCustomers = check encryptData(customers, key);
    check io:fileWriteLines("./resources/encrypted_customers.csv", encryptedCustomers);

    // Decrypt the data
    string[] encryptedData = check io:fileReadLines("./resources/encrypted_customers.csv");
    record {}[] decryptedData = check decryptData(encryptedData, key, Customer);

    check io:fileWriteCsv("./resources/decrypted_customers.csv", decryptedData);
}
