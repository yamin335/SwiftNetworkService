//
//  NetworkRequest.swift
//  WorldOfPAYBACK
//
//  Created by Md. Yamin on 01.07.23.
//

import Foundation

/// Protocol that specifies a `NetworkRequest`
public protocol NetworkRequestProtocol {
    
    /// Defining the type of expected response
    associatedtype Response: Codable

    /// A String representation of the `URL` for the `NetworkRequest`
    var url: String? { get }
    
    /// `Type` of `NetworkRequest` e.g. (GET, POST, PUT)
    var type: NetworkRequestType { get }
    
    /// The HTTP headers to include with the request.
    var headers: Dictionary<String, String>? { get }
    
    /// Set of parameters to include with the request body.
    var httpBodyParam: [String: Any]? { get }
    
    /// Set of parameters to include with the request's query params
    var queryParam: Dictionary<String, String?>? { get }
}
