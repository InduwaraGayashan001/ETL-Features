import ballerina/io;
import ballerina/regex;
import ballerinax/openai.chat;

configurable string openAIKey = ?;

type ReviewSummary record {|
    string goodPoints;
    string badPoints;
    string improvements;
|};

# Extracts unstructured data from a string array and maps it to the specified fields.
# ```ballerina
# string[] reviews = ["The product is great, but it could be improved.", "Not bad, but needs some updates."];
# string[] fields = ["goodPoints", "badPoints", "improvements"];
# record {} extractedDetails = check extractUnstructuredData(reviews, fields);
# ```
# 
# + dataset - Array of unstructured string data (e.g., reviews or comments).
# + fieldNames - Array of field names to map the extracted details.
# + return - A record with extracted details mapped to the specified field names or an error if extraction fails.
function extractUnstructuredData(string[] dataset, string[] fieldNames) returns record {}|error {
    do {
        chat:Client chatClient = check new ({
            auth: {
                token: openAIKey
            }
        });

        chat:CreateChatCompletionRequest request = {
            model: "gpt-4o",
            messages: [
                {
                    "role": "user",
                    "content": string `Extract relevant details from the given string array and map them to the specified fields. 
                                    - Input Data : ${dataset.toString()} 
                                    - Fields to extract: ${fieldNames.toString()}
                                    Respond with a single string, where extracted field values are separated by '|'
                                    Use the exact format: detail1, detail2, detail3,...|detail1, detail2, detail3,...|detail1, detail2, detail3,...  
                                    Do not include field names or any additional text, explanations, or variations.`
                }
            ]
        };

        chat:CreateChatCompletionResponse result = check chatClient->/chat/completions.post(request);
        string content = check result.choices[0].message?.content.ensureType();
        string[] contentArray = re `\|`.split(regex:replaceAll(content, "\"|'|\\[|\\]", "")).'map(element => element.trim());

        record {} extractDetails = {};
        foreach int i in 0 ... fieldNames.length() - 1 {
            extractDetails[fieldNames[i]] = contentArray[i];
        }
        return extractDetails;

    } on fail error e {
        return e;
    }
}


public function main(string[] arg) returns error? {

    string[] reviews = check io:fileReadLines("./resources/Input.txt");
    string[] fields = ["goodPoints", "badPoints", "improvements"];
    record {} extractedDetails = check extractUnstructuredData(reviews, fields);
    io:println(`Extracted Details : ${extractedDetails.cloneWithType(ReviewSummary)}`);
    check io:fileWriteJson("./resources/output.json", extractedDetails.toJson());
}
