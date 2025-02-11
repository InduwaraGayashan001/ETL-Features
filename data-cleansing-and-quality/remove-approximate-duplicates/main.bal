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

function removeApproximateDuplicates(record {}[] dataSet) returns record {}[]|error {

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
                                    - Input Dataset : ${dataSet.toString()}  
                                    Respond strictly with a plain string array (not JSON) where each record is labeled as 'unique' or 'duplicate'. 
                                    Mark the first occurrence of any duplicate as 'unique'.  
                                    Do not include any additional text, explanations, or variations.`
            }
        ]
    };

    chat:CreateChatCompletionResponse response = check chatClient->/chat/completions.post(request);

    string content = check response.choices[0].message?.content.ensureType();

    string[] contentArray = re `,`.split(regex:replaceAll(content, "\"|'|\\[|\\]", ""));

    foreach int i in 0 ... contentArray.length() - 1 {
        contentArray[i] = contentArray[i].trim();
    }

    return from record {} data in dataSet
        where contentArray[<int>dataSet.indexOf(data)] is "unique"
        select data;
}

public function main() returns error? {
    Customer[] customers = check io:fileReadCsv("./resources/customers.csv");
    record {}[] uniqueCustomers = check removeApproximateDuplicates(customers);
    io:println(`Unique Customers: ${uniqueCustomers}${"\n"}`);
    check io:fileWriteCsv("./resources/unique_customers.csv", uniqueCustomers);
}
