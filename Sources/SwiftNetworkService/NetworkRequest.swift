//
//  NetworkRequest.swift
//  WorldOfPAYBACK
//
//  Created by Md. Yamin on 02.07.23.
//

import Foundation
/**
 `NetworkRequest` is a concrete implementation of `NetworkRequestProtocol` that canbe used
 to initiate a network request with `URLSession` network library.
 */
public final class NetworkRequest<ResponseType : Codable>: NetworkRequestProtocol {
    public var url: String?
    
    public var type: NetworkRequestType
    
    public var headers: Dictionary<String, String>?
    
    public var httpBodyParam: [String : Any]?
    
    public var queryParam: Dictionary<String, String?>?
    
    public typealias Response = ResponseType
    
    public init(url: String? = nil, type: NetworkRequestType = .get, headers: Dictionary<String, String>? = [:],
         httpBodyParam: [String : Any]? = [:], queryParam: Dictionary<String, String?>? = [:]) {
        
        self.url = url
        self.type = type
        self.headers = headers
        self.httpBodyParam = httpBodyParam
        self.queryParam = queryParam
    }
}
