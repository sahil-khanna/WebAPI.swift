### INTRODUCTION
Almost every app developed for a smartphone interacts with the backend REST APIs. There are several ways to communicate with the APIs. This repository demonstrates an elegant way to communicate with the backend APIs. ***The code can be used as a reference for other languages (Android, Java, .Net, etc.) as well***

### SOURCE CODE

 - **WebAPI.swift**: This file does all the hard work. One should not need to change any code in this file.
 - **WebAPIConstants.swift**: This file has the URL's and the Method's of the backend systems. It acommodates multiple URL's of different backend systems. Users will have to change the contents of this file as required
 - **Reachability.swift**: This is picked from https://github.com/ashleymills/Reachability.swift. It is used to check if the device is connected to the internet

### WHAT'S INTERESTING?
1. **Queue**: API requests are queued and are executed serially one after the other
2. **Priority's**: Each API request can be categorised as high and low priority. A high priority request will be executed first and the low priority request will be executed later on. Below are a few examples
	- High priority: Book an order of the items in cart.
	- Low priority: Dispatch the error logs to backend. These are not required to be sent immediately
3. **Retry**: If a request fails because of internet connectivity, the request can be retried for the specified number of times

### WHERE TO CHANGE?
The users of this code will mostly have to add methods and URLs in **WebAPIConstants.swift**. The other files will never have to be changed

### USAGE
```swift
var payload1 = WebAPIPayload();
payload1.apiMethod = .POST;
payload1.httpMethod = .POST;
payload1.priority = .HIGH;
payload1.data = ["id": 1, "title": "Hello", "body": "World", "userId": 1];
payload1.url = .URL2;
payload1.callback = { (response) in
    print(response.description);
};

var payload2 = WebAPIPayload();
payload2.apiMethod = .WEATHER;
payload2.timeoutInSec = 10;
payload2.httpMethod = .GET;
payload2.priority = .LOW;
payload2.retryCount = 3;
payload2.data = ["lon": "139", "lat": "35"];
payload2.url = .URL1;
payload2.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData;
payload2.headers = nil;
payload2.callback = { (response) in
    print(response.description);
};

WebAPI.shared.push(apiPayload: payload1);
WebAPI.shared.push(apiPayload: payload2);
```

The details of the code is available on [Medium.com](https://medium.com/@sahil__khanna/abstraction-writing-code-for-others-41a956ad9532)
