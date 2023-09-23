import XCTest
@testable import SwiftNetworkService

// Naming Convention: test_UnitOfWork_StateUnderTest_ExpectedBehaviour
// Testing Behaviour: Given, When, Then
final class SwiftNetworkServiceTests: XCTestCase {
    struct TestData: Codable, Equatable { let data: String }
    
    private var urlSession: URLSession!
    private var data: Data?
    
    
    override func setUp() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLSessionProtocol.self]
        urlSession = URLSession(configuration: configuration)
        data = Data("{\"data\":\"Test data\"}".utf8)
    }
    
    override func tearDown() {
        urlSession = nil
        data = nil
    }
    
    func test_NetworkService_NetworkError_shouldBe_invalidRequest() async throws {
        // Given
        let invalidRequestError: NetworkError = .invalidRequest
        let successStatusCode = 200
        let request = NetworkRequest<TestData>()
        
        // When
        request.url = "" // Invalid empty URL!
        MockURLSessionProtocol.requestHandler = {
            let response = HTTPURLResponse(url: URL(string: request.url!)!,
                                           statusCode: successStatusCode,
                                           httpVersion: nil,
                                           headerFields: nil)
            return (response!, self.data)
        }
        
        // Then
        await XCTAssertThrowsError(
            try await NetworkService(urlSession: urlSession).perform(request)
        ) {
            XCTAssertEqual($0 as? NetworkError, invalidRequestError)
        }
    }
    
    func test_NetworkService_NetworkError_shouldBe_decodingError() async throws {
        // Given
        let decodingError: NetworkError = .decodingError
        let successStatusCode = 200
        let request = NetworkRequest<TestData>()
        request.url = "https://example.com"
        
        // When
        self.data = Data("{\"data\":\"Test data\"".utf8) // Invalid data format!
        MockURLSessionProtocol.requestHandler = {
            let response = HTTPURLResponse(url: URL(string: request.url!)!,
                                           statusCode: successStatusCode,
                                           httpVersion: nil,
                                           headerFields: nil)
            return (response!, self.data)
        }
        
        // Then
        await XCTAssertThrowsError(
            try await NetworkService(urlSession: urlSession).perform(request)
        ) {
            XCTAssertEqual($0 as? NetworkError, decodingError)
        }
    }
    
    func test_NetworkService_NetworkError_shouldBe_serverError() async throws {
        // Given
        let serverError: NetworkError = .serverError(500)
        
        // When
        let serverErrorCode = 500
        
        let request = NetworkRequest<TestData>()
        request.url = "https://example.com"
        MockURLSessionProtocol.requestHandler = {
            let response = HTTPURLResponse(url: URL(string: request.url!)!,
                                           statusCode: serverErrorCode,
                                           httpVersion: nil,
                                           headerFields: nil)
            return (response!, self.data)
        }
        
        // Then
        await XCTAssertThrowsError(
            try await NetworkService(urlSession: urlSession).perform(request)
        ) {
            XCTAssertEqual($0 as? NetworkError, serverError)
        }
    }
    
    func test_NetworkService_NetworkRequest_shouldReturn_SuccessResponse() async throws {
        // Given
        let successStatusCode = 200
        let request = NetworkRequest<TestData>()
        request.url = "https://example.com"
        
        // When
        let expectedResponse = TestData(data: "Test data")
        MockURLSessionProtocol.requestHandler = {
            let response = HTTPURLResponse(url: URL(string: request.url!)!,
                                           statusCode: successStatusCode,
                                           httpVersion: nil,
                                           headerFields: nil)
            return (response!, self.data)
        }
        
        // Then
        let networkResponse = try await NetworkService(urlSession: urlSession).perform(request)
        XCTAssertEqual(expectedResponse, networkResponse)
    }
    
    func test_NetworkService_NetworkRequest_shouldReturn_EmptyResponse() async throws {
        // Given
        let decodingError: NetworkError = .decodingError
        let successStatusCode = 200
        let request = NetworkRequest<TestData>()
        request.url = "https://example.com"
        
        // When
        MockURLSessionProtocol.requestHandler = {
            let response = HTTPURLResponse(url: URL(string: request.url!)!,
                                           statusCode: successStatusCode,
                                           httpVersion: nil,
                                           headerFields: nil)
            return (response!, nil) // Invalid data found as nil!
        }
        
        // Then
        await XCTAssertThrowsError(
            try await NetworkService(urlSession: urlSession).perform(request)
        ) {
            XCTAssertEqual($0 as? NetworkError, decodingError)
        }
    }
}
