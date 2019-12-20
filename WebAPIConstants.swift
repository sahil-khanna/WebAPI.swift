//
//  WebAPIMethod.swift
//  SwiftTest
//
//  Created by sahil.khanna on 12/16/19.
//  Copyright © 2019 sahil.khanna. All rights reserved.
//

import Foundation

/*
 Add the API methods here
 */
public enum WebAPIMethod: String {
    case WEATHER = "weather";
    case POST = "posts";
}

/*
 Add the API URLs here
 */
public enum WebAPIURL: String {
    case URL1 = "https://api.openweathermap.org/data/2.5";
    case URL2 = "https://jsonplaceholder.typicode.com/";
}
