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

type Review record {|
    string goodPoints;
    string badPoints;
    string improvements;
    int age;
|};

configurable string apiKey = ?;

function extractUnstructuredData(string[] dataSet, string[] fieldNames) returns record{}|error {

    string apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" + apiKey;

    json requestBody = {
        "contents": [
            {
                "parts": [
                    {
                        "text": "Extract the details from the given string array into the specified fields. Respond only with a single string where each extracted field's information is separated by '|'. Format the response as follows: 'Extracted details for the first field'|'Extracted details for the second field'|'Extracted details for the third field'. Use a deterministic approach to avoid variations in different executions."},
                    {
                        "text": dataSet.toString()
                    },
                    {
                        "text": fieldNames.toString()
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

    string[] correctArray = re `\|`.split(regex:replaceAll(output, "\"|'|\\[|\\]", ""));
    foreach int i in 0 ... correctArray.length() - 1 {
        correctArray[i] = correctArray[i].trim();
    }

    record{} extractDetails = {};

    foreach int i in 0...fieldNames.length()-1{
        extractDetails[fieldNames[i]] = correctArray[i];
    }
    

    return extractDetails;
}

public function main() returns error? {

    string[] reviews = check io:fileReadLines("./resources/Input.txt");

    string[] fields = ["Good Points", "Bad Points", "Improvements"];

    record{} extractedDetails = check extractUnstructuredData(reviews,fields);

    io:println(extractedDetails);

    check io:fileWriteJson("./resources/output.json",extractedDetails.toJson());

}