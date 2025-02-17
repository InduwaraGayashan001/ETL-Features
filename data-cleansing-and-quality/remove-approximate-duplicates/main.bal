import ballerina/io;
import ballerina/regex;
import ballerinax/openai.chat;

type Customer record {
    string customerId;
    string customerName;
    string email;
    string phone;
    string address;
};

configurable string openAIKey = ?;

# Removes approximate duplicates from a dataset, keeping only the first occurrence of each duplicate record.
# ```ballerina
# record {}[] dataset = [
#     { "name": "Alice", "city": "New York" },
#     { "name": "Bob", "city": "New York" },
#     { "name": "Alice", "city": "new york" },
#     { "name": "Charlie", "city": "Los Angeles" }
# ];
# record {}[] uniqueData = check removeApproximateDuplicates(dataset);
# ```
# 
# + dataset - Array of records containing data that may have approximate duplicates.
# + return - A dataset with approximate duplicates removed, keeping only the first occurrence of each duplicate record.
function removeApproximateDuplicates(record {}[] dataset) returns record {}[]|error {
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
                    "content": string `Identify approximate duplicates in the dataset.
                                        - Input Dataset : ${dataset.toString()}  
                                        Respond strictly with a plain string array (not JSON) where each record is labeled as 'unique' or 'duplicate'. 
                                        Mark the first occurrence of any duplicate as 'unique'.  
                                        Do not include any additional text, explanations, or variations.`
                }
            ]
        };

        chat:CreateChatCompletionResponse response = check chatClient->/chat/completions.post(request);
        string content = check response.choices[0].message?.content.ensureType();
        string[] contentArray = re `,`.split(regex:replaceAll(content, "\"|'|\\[|\\]", "")).'map(element => element.trim());

        return from record {} data in dataset
            where contentArray[<int>dataset.indexOf(data)] is "unique"
            select data;
    } on fail error e {
        return e;
    }
}

public function main() returns error? {
    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");
    record {}[] uniqueCustomers = check removeApproximateDuplicates(customers);
    io:println(`Unique Customers: ${uniqueCustomers}${"\n"}`);
    check io:fileWriteCsv("./resources/unique_customers.csv", uniqueCustomers);
}
