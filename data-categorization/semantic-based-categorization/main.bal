import ballerina/io;
import ballerina/regex;
import ballerinax/openai.chat;

type Order record {|
    string order_id;
    string customer_name;
    string comments;
|};

configurable string openAIKey = ?;

function categorizeSemantic(record {}[] dataSet, string fieldName, string[] categories) returns record {}[][]|error {

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
        if (dataSet[i].hasKey(fieldName)) {
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
        } else {
            return error("Provided field deos not exist in the data");
        }
    }
    return categorizedData;
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
