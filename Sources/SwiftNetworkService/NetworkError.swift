//
//  HttpRequestErrorType.swift
//  WorldOfPAYBACK
//
//  Created by Md. Yamin on 01.07.23.
//

import Foundation

/// Defining error types with their messages for `NetworkRequest`.
public enum NetworkError: Error {
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
    case unknownError

    /// `Text` representation for each error type
    var localizedDescription: String {
        switch self {
        case .invalidRequest:
            return "Invalid request"
        case .encodingError:
            return "Failed to encode request parameters"
        case .decodingError:
            return "Failed to decode server response"
        case .serverError(let code):
            return "Server error with status code: \(code)"
        case .noInternetError:
            return "Failed to connect due to the network"
        case .unknownError:
            return "Unknown network error"
        }
    }
}
