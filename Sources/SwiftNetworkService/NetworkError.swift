//
//  HttpRequestErrorType.swift
//  WorldOfPAYBACK
//
//  Created by Md. Yamin on 01.07.23.
//

import Foundation

/// Defining error types with their messages for `NetworkRequest`.
public enum NetworkError: Error, Equatable {
    /// `NetworkRequest` is not valid
    case invalidRequest
    /// `Error` occurred encoding `NetworkRequest` paarameters
    case encodingError
    /// `Error` occurred decoding `Response` of `NetworkRequest`
    case decodingError
    /// `Error` emmited from server with a  response `Code`
    case serverError(Int)
    /// `NetworkRequest` got cancelled due to the `Network` unavailability
    case noInternetError
    /// `Error` that does not match any specified error types.
    case unknownError(String)

    /// `Text` representation for each error type
    var localizedDescription: String {
        switch self {
        case .invalidRequest:
            "Invalid request"
        case .encodingError:
            "Failed to encode request parameters"
        case .decodingError:
            "Failed to decode server response"
        case .serverError(let code):
            "Server error with status code: \(code)"
        case .noInternetError:
            "Failed to connect due to the network"
        case .unknownError(let description):
            "Unknown Error: \"\(description)\""
        }
    }
}
