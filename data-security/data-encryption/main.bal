import ballerina/crypto;
import ballerina/io;
import ballerina/lang.array;

configurable string key = ?;

function encryptData(string[] dataSet, string keyBase64) returns string[]|error {
    byte[] encrypt_key = check array:fromBase64(keyBase64);
    foreach int i in 0 ... dataSet.length() - 1 {
        byte[] dataByte = dataSet[i].toBytes();
        byte[] cipherText = check crypto:encryptAesEcb(dataByte, encrypt_key);
        dataSet[i] = cipherText.toBase64();
    }
    return dataSet;
}

function decryptData(string[] dataSet, string keyBase64) returns string[]|error {
    byte[] decrypt_key = check array:fromBase64(keyBase64);
    foreach int i in 0 ... dataSet.length() - 1 {
        byte[] dataByte = check array:fromBase64(dataSet[i]);
        byte[] plainText = check crypto:decryptAesEcb(dataByte, decrypt_key);
        dataSet[i] = check string:fromBytes(plainText);
    }
    return dataSet;
}

public function main() returns error? {

    //Encrypt the data
    string[] customers = check io:fileReadLines("./resources/customers.csv");
    string[] encryptedCustomers = check encryptData(customers, key);
    check io:fileWriteLines("./resources/encrypted_customers.csv", encryptedCustomers);

    //Decrypt the data
    string[] encryptedData = check io:fileReadLines("./resources/encrypted_customers.csv");
    string[] decryptedData = check decryptData(encryptedData, key);
    check io:fileWriteLines("./resources/decrypted_customers.csv", decryptedData);

}
