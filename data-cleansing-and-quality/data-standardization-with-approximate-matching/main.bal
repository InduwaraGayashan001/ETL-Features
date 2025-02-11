import ballerina/io;
import ballerina/regex;
import ballerinax/openai.chat;

type Customer record {|
    string name;
    string city;
    string phone;
    int age;
|};

configurable string openAIKey = ?;

function standardizeData(record {}[] dataSet, string fieldName, string searchValue) returns record {}[]|error {

    string[] valueArray = from record {} data in dataSet
        select data[fieldName].toString();

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
                "content": string `Determine whether each text in the given array is an approximate duplicate of the provided search value.
                                    - Input Dataset : ${valueArray.toString()}
                                    - Search Value : ${searchValue}
                                    Respond only with an array of 'yes' or 'no'.  
                                    Do not include any additional text, explanations, or variations.`
            }
        ]
    };

    chat:CreateChatCompletionResponse result = check chatClient->/chat/completions.post(request);
    string content = check result.choices[0].message?.content.ensureType();
    string[] contentArray = re `,`.split(regex:replaceAll(content, "\"|'|\\[|\\]", "")).'map(element => element.trim());

    foreach int i in 0 ... dataSet.length() - 1 {
        if contentArray[i] is "yes" {
            dataSet[i][fieldName] = searchValue;
        }
    }
    return dataSet;
}

public function main() returns error? {

    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");
    record {}[] updatedCustomers = check standardizeData(customers, "city", "New York");
    io:println(`Updated Customers: ${updatedCustomers}${"\n"}`);
    check io:fileWriteCsv("./resources/updated_customers.csv", updatedCustomers);
}
