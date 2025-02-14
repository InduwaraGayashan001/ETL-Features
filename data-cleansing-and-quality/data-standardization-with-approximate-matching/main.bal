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

# Standardizes a dataset by replacing approximate matches in a string field with a specified search value.
# ```ballerina
# record {}[] dataset = [
#     { "name": "Alice", "city": "New York" },
#     { "name": "Bob", "city": "newyork-usa" },
#     { "name": "John", "city": "new york" },
#     { "name": "Charlie", "city": "Los Angeles" }
# ];
# string fieldName = "city";
# string searchValue = "New York";
# record {}[] standardizedData = check standardizeData(dataset, fieldName, searchValue);
# ```
# 
# + dataSet - Array of records containing string values to be standardized.
# + fieldName - Name of the string field to check for approximate matches.
# + searchValue - The exact value to replace approximate matches.
# + return - An updated dataset with standardized string values or an error if the operation fails.
function standardizeData(record {}[] dataSet, string fieldName, string searchValue) returns record {}[]|error {
    do {
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
    } on fail error e {
        return e;
    }
}

public function main() returns error? {

    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");
    record {}[] updatedCustomers = check standardizeData(customers, "city", "New York");
    
    io:println(`Updated Customers: ${updatedCustomers}${"\n"}`);
    check io:fileWriteCsv("./resources/updated_customers.csv", updatedCustomers);
}