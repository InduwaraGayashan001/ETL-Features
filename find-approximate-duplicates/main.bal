import ballerina/http;
import ballerina/io;

type Message record {
    string text;
};

type Item record {
    Message[] parts;
};

type Content record {
    Item content;
};

type Customer record {|
    string name;
    string city;
    string phone;
    int age;
|};

configurable string apiKey = ?;

function checkDuplicates(string searchValue, string dataValue) returns boolean|error {
    // Define the API URL with the configurable API key
    string apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" + apiKey;

    // Create the JSON body for the request
    json requestBody = {
        "contents": [
            {
                "parts": [
                    {
                        "text": "Determine whether the following texts are approximate duplicates. Please respond with 'yes' or 'no' only."
                    },
                    {
                        "text": searchValue
                    },
                    {
                        "text": dataValue
                    }
                ]
            }
        ]
    };

    // Create the HTTP client
    http:Client apiClient = check new http:Client(apiUrl);

    record {} response = check apiClient->post("", requestBody);

    Content[] result = check response["candidates"].cloneWithType();

    string output = result[0].content.parts[0].text;

    if output == "yes\n" {
        return true;
    } else {
        return false;
    }
}

function standardizeData(record {}[] dataSet, string fieldName, string searchValue) returns record {}[]|error {
    foreach record {} data in dataSet {
        if data.hasKey(fieldName) {
            boolean isDuplicate = check checkDuplicates(searchValue, data[fieldName].toString());
            if isDuplicate {
                data[fieldName] = searchValue;
            }
        }
    }

    return dataSet;
}

public function main() returns error? {

    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");
    record {}[] updatedCustomers = check standardizeData(customers, "city", "New York");
    io:println(`Updated Customers: ${updatedCustomers}`);
    check io:fileWriteCsv("./resources/updated_customers.csv", updatedCustomers);

}
