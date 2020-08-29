//
//  WebAPI.swift
//  SwiftTest
//
//  Created by sahil.khanna on 12/16/19.
//  Copyright © 2019 sahil.khanna. All rights reserved.
//

import Foundation

/*
 These are the HTTP Verbs. More verbs can be added, if required
 */
public enum HTTPMethod: String {
    case GET = "GET";
    case PUT = "PUT";
    case POST = "POST";
    case DELETE = "DELETE";
}

/*
 Indicates if the API request is of high or low priority. High priority requests will always be executed first. Currently executing low priority requests will be purged if any high priority request is added in the queue
 */
public enum Priority: Int {
    case HIGH = 1;
    case LOW = 2;
}

/*
 States of the currently executing requests
 */
public enum State: Int {
    case START = 1001;
    case RETRY = 1002;
    case END = 1003;
}

/*
 The payload for the API requests. Some defaukts have already been set
 */
public struct WebAPIPayload {
    
    var apiMethod: WebAPIMethod!;
    var timeoutInSec: Double? = 3;
    var httpMethod: HTTPMethod = .GET;
    var priority: Priority! = .LOW;
    var retryCount: Int! = 0;
    var data: NSDictionary?;
    var url: WebAPIURL = .URL1;
    var cachePolicy: URLRequest.CachePolicy! = .reloadIgnoringLocalAndRemoteCacheData;
    var headers: [String: String]? = [:];
    var callback: (([String: Any]) -> Void)!;
}

public class WebAPI {
    
    private struct Executing {
        public var payload: WebAPIPayload;
        public var dataTask: URLSessionDataTask?;
    }
    
    public static let shared = WebAPI();
    private var highQueue: [WebAPIPayload] = [];
    private var lowQueue: [WebAPIPayload] = [];
    private var currentlyExecuting: Executing?;
    private var currentTry = 1;
    
    private init() {}
    
    /*
     Push the request in the appropriate queue based on the priority
     */
    public func push(apiPayload: WebAPIPayload) {
        if (apiPayload.priority == .HIGH) {
            highQueue.append(apiPayload);
        }
        else {
            lowQueue.append(apiPayload);
        }
        
        process();
    }
    
    /*
     1) If any high priority request is being executed, it will continue executing
     2) If any low priority request is being executed, it will be purged in case there is a high priority request pending in the queue. If no high priority requests are pending, the low priority request will continue executing
     */
    private func process() {
        //No request is currently executing
        if (currentlyExecuting == nil) {
            //Do nothing
        }
        //High priority request is currently executing. Let it execute
        else if (currentlyExecuting?.payload.priority == .HIGH) {
            return;
        }
        //Low priority request is currently executing, but there is a high priority request pending. Abort the low priority request
        else if (currentlyExecuting?.payload.priority == .LOW && highQueue.count > 0) {
            currentlyExecuting?.dataTask?.cancel();
        }
        //Low priority request is currently executing and there are no high priority request pending.
        else if (currentlyExecuting?.payload.priority == .LOW) {
            return;
        }
        
        if (highQueue.count > 0) {   //Execute items in priorityQueue
            currentlyExecuting = Executing(payload: highQueue[0]);
        }
        else if (lowQueue.count > 0) {   //Execute items in generalQueue
            currentlyExecuting = Executing(payload: lowQueue[0]);
        }
        else {      //No request pending
            return;
        }
        
        if (currentlyExecuting?.payload.retryCount ?? 0 < 0) {
            currentlyExecuting?.payload.retryCount = 0;
        }
        
        execute();
    }
    
    private func clearState() {
        guard let payload = currentlyExecuting?.payload else {
            return;
        }
        
        if (payload.priority == .HIGH) {
            self.highQueue.remove(at: 0);
        }
        else {
            self.lowQueue.remove(at: 0);
        }
        
        currentTry = 1;
        self.currentlyExecuting = nil;
        self.process();
    }
    
    private func execute() {
        guard let payload = currentlyExecuting?.payload else {
            return;
        }
        
        payload.callback([
            "state": State.START
        ]);
        
        /*
         Check if internet connection is available
         */
        if (try! Reachability(hostname: "www.google.com").connection == .unavailable) {
            if (currentTry < payload.retryCount) {  // Retry after 2 seconds
                currentTry += 1;
                payload.callback([
                    "state": State.RETRY,
                    "response": [
                        "httpCode": "0",
                        "message": "Internet connection appears to be offline"
                    ]
                ]);
                
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
                    self.execute();
                }
            }
            else {
                payload.callback([
                    "state": State.END,
                    "response": [
                        "httpCode": "0",
                        "message": "Internet connection appears to be offline"
                    ]
                ]);
             
                self.clearState();
            }
            
            return;
        }
        
        var urlRequest: URLRequest;
        
        if (currentlyExecuting?.payload.httpMethod == .GET || currentlyExecuting?.payload.httpMethod == .DELETE) {
            urlRequest = URLRequest(url: URL(string: payload.url.rawValue + "/" + payload.apiMethod.rawValue + buildQueryString(data: payload.data))!);
        }
        else {
            urlRequest = URLRequest(url: URL(string: payload.url.rawValue + "/" + payload.apiMethod.rawValue)!);
            urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: payload.data as Any, options: []);
        }
        
        urlRequest.httpMethod = payload.httpMethod.rawValue;
        urlRequest.timeoutInterval = payload.timeoutInSec ?? 30;
        urlRequest.cachePolicy = payload.cachePolicy;
        urlRequest.allHTTPHeaderFields = payload.headers;
        
        currentlyExecuting?.dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, urlResponse, error) in
            if (error != nil) {
                payload.callback([
                    "state": State.END,
                    "response": [
                        "data": data as Any,
                        "message": error?.localizedDescription as Any
                    ]
                ]);
            }
            else {
                payload.callback([
                    "state": State.END,
                    "response": [
                        "data": data as Any,
                        "httpCode": urlResponse?.value(forKey: "statusCode") as Any,
                    ]
                ]);
            }
            
            self.clearState();
        }
        
        currentlyExecuting?.dataTask?.resume();
    }
    
    /*
     Iterate over the dictionary and create a keyValue pair or parameters
     */
    private func buildQueryString(data: NSDictionary?) -> String {
        if (data == nil) {
            return "";
        }
        
        var queryString = "";
        for key in (data?.allKeys)! {
            let value = data?.value(forKey: key as! String) as? String;
            if (value != nil) {
                queryString += "&" + (key as! String + "=" + value!);
            }
        }
        
        if (queryString.count > 0) {
            let index = queryString.index(queryString.startIndex, offsetBy: 1);
            return "?" + queryString[index...];
        }
        else {
            return "";
        }
    }
}
