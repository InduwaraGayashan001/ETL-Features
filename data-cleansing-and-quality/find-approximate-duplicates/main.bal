import ballerina/http;
import ballerina/io;
import ballerina/regex;

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

function standardizeData(record {}[] dataSet, string fieldName, string searchValue) returns record {}[]|error {

    string[] valueArray = from record {} data in dataSet
        select data[fieldName].toString();

    string apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" + apiKey;

    json requestBody = {
        "contents": [
            {
                "parts": [
                    {
                        "text": "Determine whether each text in the given array is an approximate duplicate of the provided search value. Respond only with an array of 'yes' or 'no'."
                    },
                    {
                        "text": valueArray.toString()
                    },
                    {
                        "text": searchValue
                    }
                ]
            }
        ]
    };

    http:Client apiClient = check new http:Client(apiUrl);

    record {} response = check apiClient->post("", requestBody);

    Content[] result = check response["candidates"].cloneWithType();

    string output = result[0].content.parts[0].text;
    string[] correctArray = re `,`.split(regex:replaceAll(output, "\"|'|\\[|\\]", ""));
    foreach int i in 0 ... correctArray.length() - 1 {
        correctArray[i] = correctArray[i].trim();
    }

    foreach int i in 0 ... dataSet.length() - 1 {
        if correctArray[i] is "yes" {
            dataSet[i][fieldName] = searchValue;
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
