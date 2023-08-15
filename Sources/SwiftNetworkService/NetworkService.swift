//
//  NetworkService.swift
//  WorldOfPAYBACK
//
//  Created by Md. Yamin on 01.07.23.
//

import Foundation
import Combine

/// `NetworkServiceProtocol` is a set of methods to define the actions of `NetworkService`
@available(iOS 13.0, *)
public protocol NetworkServiceProtocol {

    /**
     Performs a specified network request with the provided request properties
     - Parameter request: A network request property that contains all information about the network call
     - Returns: `AnyPublisher` with the specified response `Type` and `NetworkError` if there is any
     */
    func perform<T: NetworkRequestProtocol>(_ request: T) -> AnyPublisher<T.Response, NetworkError>
    /**
     Performs a specified network request with the provided request properties
     - Parameter request: A network request property that contains all information about the network call
     - Returns: `Response` with the specified response `Type`
     - Throws: `NetworkError` if there is any
     */
    func perform<T: NetworkRequestProtocol>(_ request: T) async throws -> T.Response
}

/// Protocol that helps `URLSession` to retturn a `AnyPublisher` wrapping all properties e. g. `Response`, `Error`.
@available(iOS 13.0, *)
public protocol URLSessionProtocol {
    /**
     This methos is responsible for helping a `URLSession` object to provide `Response` via `AnyPublisher`
     - Parameter request: A `URLRequest` object
     - Returns: `AnyPublisher` wrapping  `Data` object with `Response` and `NetworkError`
     */
    func sessionDataTaskPublisher(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
    /**
     This methos is responsible for helping a `URLSession` object to provide `Response` via `AnyPublisher`
     - Parameter request: A `URLRequest` object
     - Returns: `AnyPublisher` wrapping  `Data` object with `Response` and `NetworkError`
     */
    func sessionDataAsyncTask(for request: URLRequest) async throws -> (data: Data, response: URLResponse)
}

/// Extension that provides `URLSession` object by a concrete implementation of `URLSessionProtocol`.
@available(iOS 13.0, *)
extension URLSession: URLSessionProtocol {
    public func sessionDataTaskPublisher(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        return self.dataTaskPublisher(for: request)
            .map { ($0.data, $0.response) }
            .eraseToAnyPublisher()
    }
    
    public func sessionDataAsyncTask(for request: URLRequest) async throws -> (data: Data, response: URLResponse) {
        return try await self.data(for: request)
    }
}

/**
 `NetworkService` is a solid implementation of `NetworkServiceProtocol` that performs the actual network request.
 */
@available(iOS 13.0, *)
public final class NetworkService: NetworkServiceProtocol {

    private let urlSession: URLSessionProtocol

    /**
     Initializes a `NetworkService` with an instance of `URLSession`
     - Parameter urlSession: The `URLSsession` object responsible for the actual network request. Defaults to `URLSession.shared`
     */
    public init(urlSession: URLSessionProtocol = URLSession.shared) {
        self.urlSession = urlSession
    }

    /**
     Performs a network call with the specified `NetworkRequest` and returns the response data wrapped with a publisher or propagate errors if there is any
     - Parameter request: An object of `NetworkRequest`
     */
    public func perform<T>(_ request: T) -> AnyPublisher<T.Response, NetworkError> where T : NetworkRequestProtocol {
        
        guard let stringUrl = request.url, var urlComponents = URLComponents(string: stringUrl) else {
            return Fail(error: NetworkError.invalidRequest).eraseToAnyPublisher()
        }
        
        var queryItems = [URLQueryItem]()
        
        if let queryParams = request.queryParam {
            for item in queryParams {
                queryItems.append(URLQueryItem(name: item.key, value: item.value))
            }
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            return Fail(error: NetworkError.invalidRequest).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = request.type.rawValue
        
        if let headers = request.headers {
            for (key, value) in headers {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let parameters = request.httpBodyParam {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
                urlRequest.httpBody = jsonData
            } catch {
                return Fail(error: NetworkError.encodingError).eraseToAnyPublisher()
            }
        }
        
        return urlSession.sessionDataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                    throw NetworkError.serverError((response as? HTTPURLResponse)?.statusCode ?? 500)
                }
                return data
            }
            .retry(1)
            .decode(type: T.Response.self, decoder: JSONDecoder())
            .mapError { error in
                if let urlError = error as? URLError, urlError.code == URLError.notConnectedToInternet {
                    return NetworkError.noInternetError
                } else if error is DecodingError {
                    return NetworkError.decodingError
                } else {
                    return NetworkError.unknownError(error.localizedDescription)
                }
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    /**
     Performs a network call with the specified `NetworkRequest` and returns the response data or throws errors if there is any
     - Parameter request: An object of `NetworkRequest`
     */
    public func perform<T>(_ request: T) async throws -> T.Response where T : NetworkRequestProtocol {
        
        guard let stringUrl = request.url, var urlComponents = URLComponents(string: stringUrl) else {
            throw NetworkError.invalidRequest
        }
        
        var queryItems = [URLQueryItem]()
        
        if let queryParams = request.queryParam {
            for item in queryParams {
                queryItems.append(URLQueryItem(name: item.key, value: item.value))
            }
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidRequest
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = request.type.rawValue
        
        if let headers = request.headers {
            for (key, value) in headers {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let parameters = request.httpBodyParam {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
                urlRequest.httpBody = jsonData
            } catch {
                throw NetworkError.encodingError
            }
        }
        
        do {
            let (data, response) = try await urlSession.sessionDataAsyncTask(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                throw NetworkError.serverError((response as? HTTPURLResponse)?.statusCode ?? 500)
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let res = try decoder.decode(T.Response.self, from: data)
            return res
        } catch {
            if let urlError = error as? URLError, urlError.code == URLError.notConnectedToInternet {
                throw NetworkError.noInternetError
            } else if error is DecodingError {
                throw NetworkError.decodingError
            } else {
                throw NetworkError.unknownError(error.localizedDescription)
            }
        }
    }
}
