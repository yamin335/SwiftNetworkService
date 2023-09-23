//
//  MockURLSessionProtocol.swift
//  
//
//  Created by Md. Yamin on 15.08.23.
//

#if DEBUG
import Foundation

class MockURLSessionProtocol: URLProtocol {
    static var error: NetworkError?
    
    static var requestHandler: (() throws -> (HTTPURLResponse, Data?))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        defer {
            client?.urlProtocolDidFinishLoading(self)
        }
        
        if let error = MockURLSessionProtocol.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        
        guard let handler = MockURLSessionProtocol.requestHandler else {
            fatalError("Request handler not foud")
        }
        
        do {
            let (response, data) = try handler()
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        
    }
    
    override func stopLoading() {
        
    }
}
#endif
