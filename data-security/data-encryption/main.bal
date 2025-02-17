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

# Encrypts a dataset using AES-ECB encryption with a given Base64-encoded key.
#
# ```ballerina
# record {}[] dataset = [
#     { "id": 1, "name": "Alice", "age": 25 },
#     { "id": 2, "name": "Bob", "age": 30 }
# ];
# string keyBase64 = "aGVsbG9zZWNyZXRrZXkxMjM0NTY=";
# string[] encryptedData = check encryptData(dataset, keyBase64);
# ```
#
# + dataset - The dataset containing records to be encrypted.
# + keyBase64 - The AES encryption key in Base64 format.
# + return - An array of Base64-encoded encrypted strings.
function encryptData(record {}[] dataset, string keyBase64) returns string[]|error {
    do {
        byte[] encryptkey = check array:fromBase64(keyBase64);
        string[] encryptedDataSet = [];

        foreach int i in 0 ... dataset.length() - 1 {
            byte[] dataByte = dataset[i].toString().toBytes();
            byte[] cipherText = check crypto:encryptAesEcb(dataByte, encryptkey);
            encryptedDataSet.push(cipherText.toBase64());
        }
        return encryptedDataSet;
    } on fail error e {
        return e;
    }
}

# Decrypts a dataset using AES-ECB decryption with a given Base64-encoded key and returns records of the specified type.
#
# ```ballerina
# string[] encryptedData = [
#     "sdfjsdlfjsdl==", 
#     "j34nkj23n4k3=="
# ];
# string keyBase64 = "aGVsbG9zZWNyZXRrZXkxMjM0NTY=";
# typedesc<record { string name; int age; }> dataType = record { string name; int age; };
# record {}[] decryptedData = check decryptData(encryptedData, keyBase64, dataType);
# ```
#
# + dataset - The dataset containing the Base64-encoded encrypted strings to be decrypted.
# + keyBase64 - The AES decryption key in Base64 format.
# + dataType - The type descriptor of the record to be returned after decryption.
# + return - An array of decrypted records in the specified `dataType`.
function decryptData(string[] dataset, string keyBase64, typedesc<record {}> dataType) returns record {}[]|error {
    do {
        byte[] decryptKey = check array:fromBase64(keyBase64);
        record {}[] decryptededDataSet = [];

        foreach int i in 0 ... dataset.length() - 1 {
            byte[] dataByte = check array:fromBase64(dataset[i]);
            byte[] plainText = check crypto:decryptAesEcb(dataByte, decryptKey);
            string plainTextString = check string:fromBytes(plainText);
            decryptededDataSet.push(check (check plainTextString.fromJsonString()).cloneWithType(dataType));
        }
        return decryptededDataSet;
    } on fail error e {
        return e;
    }
}

public function main() returns error? {

    // Generate a new key
    byte[16] aesKey = [];
    foreach var i in 0 ... 15 {
        aesKey[i] = <byte>(check random:createIntInRange(0, 255));
    }
    string newKey = aesKey.toBase64();
    io:println(`New Key: ${newKey}`); // Copy and save this printed New Key value in the Config.toml

    // Encrypt the data
    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");
    string[] encryptedCustomers = check encryptData(customers, key);
    check io:fileWriteLines("./resources/encrypted_customers.csv", encryptedCustomers);

    // Decrypt the data
    string[] encryptedData = check io:fileReadLines("./resources/encrypted_customers.csv");
    record {}[] decryptedData = check decryptData(encryptedData, key, Customer);
    check io:fileWriteCsv("./resources/decrypted_customers.csv", decryptedData);
}
