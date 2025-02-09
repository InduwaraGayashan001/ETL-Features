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

type Order record {|
    string order_id;
    string customer_name;
    string comments;
|};

configurable string apiKey = ?;

function categorizeSemantic(record {}[] dataSet, string fieldName, string[] categories) returns record {}[][]|error {

    string[] valueArray = from record {} data in dataSet
        select data[fieldName].toString();

    string apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" + apiKey;

    json requestBody = {
        "contents": [
            {
                "parts": [
                    {
                        "text": "Classify each text in the array into one of the given category names. Respond only the results as an array of category names corresponding to each text. If a text does not match any of the provided categories, give the category name as 'Other' in the array. "
                    },
                    {
                        "text": valueArray.toString()
                    },
                    {
                        "text": categories.toString()
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

    record {}[][] categorizedData = [];
    foreach int i in 0 ... categories.length() {
        categorizedData.push([]);
    }

    foreach int i in 0 ... dataSet.length() - 1 {
        if (dataSet[i].hasKey(fieldName)) {
            boolean isCategorized = false;

            foreach string category in categories {
                if (category.equalsIgnoreCaseAscii(correctArray[i])) {
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

    foreach int i in 0 ... categorizedOrders.length() - 1 {
        check io:fileWriteCsv(string `./resources/orders${i + 1}.csv`, categorizedOrders[i]);

    }

}
