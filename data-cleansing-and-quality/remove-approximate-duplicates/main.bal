import ballerina/io;
import ballerina/http;
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

type  Customer record{
    string customerId;
    string customerName;
    string email;
    string phone;
    string address;
};



configurable string apiKey = ?;

function removeApproximateDuplicates(record{}[] dataSet) returns record{}[]|error{

    string apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" + apiKey;

    json requestBody = {
        "contents": [
            {
                "parts": [
                    {
                        "text": "Identify approximate duplicates in the dataset. Respond strictly with a plain string array (not JSON) where each record is labeled as 'unique' or 'duplicate'. Mark the first occurrence of any duplicate as 'unique'."
                    },
                    {
                        "text": dataSet.toString()
                    }
                ]
            }
        ]
    };

    http:Client apiClient = check new http:Client(apiUrl);

    record {} response = check apiClient->post("", requestBody);

    Content[] result = check response["candidates"].cloneWithType();

    string output = result[0].content.parts[0].text;

    io:println(output);

    string[] correctArray = re `,`.split(regex:replaceAll(output, "\"|'|\\[|\\]", ""));

    foreach int i in 0 ... correctArray.length() - 1 {
        correctArray[i] = correctArray[i].trim();
    }

    return from record{} data in dataSet where correctArray[<int>dataSet.indexOf(data)] is "unique" select data;
    
}
public function main() returns error?{
    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");
    record {}[] uniqueCusstomers = check removeApproximateDuplicates(customers);
    io:println(uniqueCusstomers);

    check io:fileWriteCsv("./resources/unique_customers.csv", uniqueCusstomers);
}
