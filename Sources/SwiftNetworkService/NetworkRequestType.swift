//
//  RequestType.swift
//  WorldOfPAYBACK
//
//  Created by Md. Yamin on 01.07.23.
//

import Foundation

/// Type of the URLSession request
public enum NetworkRequestType: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}
