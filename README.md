# WebAPI.swift
A simple yet powerful Web API invocation class that can be integrated into any project iOS Swift app


####**INTRODUCTION**
Almost every app developed for a smartphone interacts with the backend REST APIs. There are several ways to communicate with the APIs. This repository demonstrates an elegant way to communicate with the backend APIs. The code can be used as a reference for other languages (Android, Java, .Net, etc.) as well

####**SOURCE CODE**
**WebAPI.swift**: This file does all the hard work. One should not need to change any code in this file.
**WebAPIConstants.swift**: This file has the URL's and the Method's of the backend systems. It acommodates multiple URL's of different backend systems. Users will have to change the contents of this file as required
**Reachability.swift**: This is picked from https://github.com/ashleymills/Reachability.swift. It is used to check if the device is connected to the internet

####**What's Interesting?**
1. **Queue's**: Each API request can be categorised as high and low priority. A high priority request will be executed first and the low priority request will be executed later on. Below are a few examples
	- High priority: Book an order of the items in cart.
	- Low priority: Dispatch the error logs to backend. These are not required to be sent immediately
2. **Retry**: If a request fails because of internet connectivity, the request can be retried for the specified number of times

####**Usage**
```swift
var payload = WebAPIPayload();
payload.apiMethod = .WEATHER;
payload.timeoutInSec = 10;
payload.httpMethod = .GET;
payload.priority = .HIGH;
payload.retryCount = 3;
payload.data = ["lon": "139", "lat": "35"];
payload.url = .URL1;
payload.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData;
payload.headers = ["header1": "value1", "header2": "value2"];
payload.callback = { (response) in
    print(response.description);
};

WebAPI.shared.push(apiPayload: payload);
```
