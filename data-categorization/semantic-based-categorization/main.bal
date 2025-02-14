import ballerina/io;
import ballerina/regex;
import ballerinax/openai.chat;

type Order record {|
    string order_id;
    string customer_name;
    string comments;
|};

configurable string openAIKey = ?;

# Categorizes a dataset based on a string field using semantic classification via OpenAI's GPT model.
# ```ballerina
# record {}[] dataset = [
#     {id: 1,comment: "Great service!"},
#     {id: 2,comment: "Terrible experience"}];
# string fieldName = "comment";
# string[] categories = ["Positive", "Negative"];
# record {}[][] categorized = check categorizeSemantic(dataset, fieldName, categories);
# ```
# 
# + dataSet - Array of records containing textual data.
# + fieldName - Name of the field to categorize.
# + categories - Array of category names for classification.
# + return - A nested array of categorized records or an error if classification fails.
function categorizeSemantic(record {}[] dataSet, string fieldName, string[] categories) returns record {}[][]|error {
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
                    "content": string `Classify each text in the array into one of the given category names.
                                        - Data array : ${valueArray.toString()} 
                                        - Category Names : ${categories.toString()}
                                        Respond only the results as an array of category names corresponding to each text.
                                        If a text does not match any of the provided categories, give the category name as 'Other' in the array.`
                }
            ]
        };

        chat:CreateChatCompletionResponse result = check chatClient->/chat/completions.post(request);
        string content = check result.choices[0].message?.content.ensureType();
        string[] contentArray = re `,`.split(regex:replaceAll(content, "\"|'|\\[|\\]", "")).'map(element => element.trim());

        record {}[][] categorizedData = [];
        foreach int i in 0 ... categories.length() {
            categorizedData.push([]);
        }

        foreach int i in 0 ... dataSet.length() - 1 {
            boolean isCategorized = false;
            foreach string category in categories {
                if (category.equalsIgnoreCaseAscii(contentArray[i])) {
                    categorizedData[<int>categories.indexOf(category)].push(dataSet[i]);
                    isCategorized = true;
                    break;
                }
            }
            if (!isCategorized) {
                categorizedData[categories.length()].push(dataSet[i]);
            }
        }
        return categorizedData;
    } on fail error e {
        return e;
    }
}


public function main() returns error? {

    Order[] orders = check io:fileReadCsv("./resources/orders.csv");
    string[] categoryArray = ["Excellent", "Normal", "Worst"];
    record {}[][] categorizedOrders = check categorizeSemantic(orders, "comments", categoryArray);

    io:println(`Category 1(Excellent) : ${categorizedOrders[0]} ${"\n\n"}Category 2(Normal) : ${categorizedOrders[1]} ${"\n\n"}Category 3(Worst) : ${categorizedOrders[2]} ${"\n\n"}Category 4(Other) : ${categorizedOrders[3]} ${"\n"}`);
    foreach int i in 0 ... categorizedOrders.length() - 1 {
        check io:fileWriteCsv(string `./resources/orders${i + 1}.csv`, categorizedOrders[i]);
    }
}
