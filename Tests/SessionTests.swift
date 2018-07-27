//   Copyright 2018 Alex Deem
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.

import XCTest
@testable import ScreamNetworking
import URITemplate

class SessionTests: XCTestCase {
    var session: GitHubSession!
    var mockResponseStore: GitHubSession.MockResponseStoreType!

    override func setUp() {
        session = GitHubSession()
        mockResponseStore = session.startMocking()
    }

    func testStartMockingTwice() {
        let secondMockResponseStore = session.startMocking()
        XCTAssert(mockResponseStore === secondMockResponseStore)
    }

    func testStopStartMocking() {
        session.stopMocking()
        let secondMockResponseStore = session.startMocking()
        XCTAssert(mockResponseStore !== secondMockResponseStore)
    }

    func testNoMock() {
        let expectation = self.expectation(description: "requestCompletion")
        let request = OrganizationRequest()
        var requestToken = session.enqueue(request) { response in
            do {
                _ = try response.unwrap()
                XCTFail("Request Should Error")
            } catch SessionError.network(let embeddedError) where embeddedError == nil {
            } catch {
                XCTFail("Request Errored in unexpected way")
            }
            expectation.fulfill()
        }
        requestToken.cancelOnDeinit = false
        self.waitForExpectations(timeout: 1)
    }

    func testSuccessMock() throws {
        let expectation = self.expectation(description: "requestCompletion")
        let request = OrganizationRequest()
        let responseData: Data = ResponseData.organization
        let mockResponse = MockResponse.success(body: responseData, url: try request.generateURL())
        mockResponseStore.mock(request: request, withResponse: mockResponse)
        var requestToken = session.enqueue(request) { response in
            do {
                let org = try response.unwrap()
                XCTAssertEqual(org.name, "Swift Scream")
                XCTAssertEqual(org.description, "Scream (noun): a group of swifts")
                XCTAssertEqual(org.location, "Sydney, Australia")
            } catch {
                XCTFail("Request Should Not Error")
            }
            expectation.fulfill()
        }
        requestToken.cancelOnDeinit = false
        self.waitForExpectations(timeout: 1)
    }

    func testSuccessMockResponse() throws {
        let expectation = self.expectation(description: "requestCompletion")
        let request = OrganizationRequest()
        let responseData: Data = ResponseData.organization
        guard let response = HTTPURLResponse(url: try request.generateURL(), statusCode: 200, httpVersion: nil, headerFields: nil) else {
            XCTFail("Error producing reponse")
            return
        }
        let mockResponse = MockResponse.success(body: responseData, response: response)
        mockResponseStore.mock(request: request, withResponse: mockResponse)
        var requestToken = session.enqueue(request) { response in
            do {
                let org = try response.unwrap()
                XCTAssertEqual(org.name, "Swift Scream")
                XCTAssertEqual(org.description, "Scream (noun): a group of swifts")
                XCTAssertEqual(org.location, "Sydney, Australia")
            } catch {
                XCTFail("Request Should Not Error")
            }
            expectation.fulfill()
        }
        requestToken.cancelOnDeinit = false
        self.waitForExpectations(timeout: 1)
    }

    func testRequestEncodingFailure_ExpandedTemplateNotURL() {
        struct TestRequest: GitHubRequest {
            public static let endpoint = Endpoint.template("{a}", [
                "a": \TestRequest.a,
                ])

            let a: String
        }

        let expectation = self.expectation(description: "requestCompletion")
        let request = TestRequest(a: "")
        let mockResponse = MockResponse.failure(error: TestError.testErrorA)
        mockResponseStore.mock(request: request, withResponse: mockResponse)
        var requestToken = session.enqueue(request) { response in
            do {
                _ = try response.unwrap()
                XCTFail("Request Should Error")
            } catch SessionError.requestEncoding(let embeddedError) where embeddedError as? RequestError == .invalidEndpoint {
            } catch {
                XCTFail("Request Errored in unexpected way")
            }
            expectation.fulfill()
        }
        requestToken.cancelOnDeinit = false
        self.waitForExpectations(timeout: 1)
    }

    func testRequestEncodingFailure_FailedTemplateExpansion() {
        struct NotSupported: VariableValue {
        }

        struct TestRequest: GitHubRequest {
            public static let endpoint = Endpoint.template("{unsupported}", [
                "unsupported": \TestRequest.unsupported,
                ])

            let unsupported: NotSupported
        }

        let expectation = self.expectation(description: "requestCompletion")
        let request = TestRequest(unsupported: NotSupported())
        var requestToken = session.enqueue(request) { response in
            do {
                _ = try response.unwrap()
                XCTFail("Request Should Error")
            } catch SessionError.requestEncoding(let embeddedError) {
                guard let e = embeddedError as? URITemplate.Error else {
                    XCTFail("Unexpected requestEncoding embeddedError")
                    return
                }
                switch e {
                case .expansionFailure(_, let reason):
                    XCTAssertEqual(reason, "Failed expanding variable \"unsupported\": Invalid Value Type")
                default:
                    XCTFail("Unexpected URITemplate.Error")
                }
            } catch let e {
                XCTFail("Request Errored in unexpected way: \(e)")
            }
            expectation.fulfill()
        }
        requestToken.cancelOnDeinit = false
        self.waitForExpectations(timeout: 1)
    }

    func testNetworkFailure() {
        let expectation = self.expectation(description: "requestCompletion")
        let request = OrganizationRequest()
        let mockResponse = MockResponse.failure(error: TestError.testErrorA)
        mockResponseStore.mock(request: request, withResponse: mockResponse)
        var requestToken = session.enqueue(request) { response in
            do {
                _ = try response.unwrap()
                XCTFail("Request Should Error")
            } catch SessionError.network(let embeddedError) where embeddedError as? TestError == .testErrorA {
            } catch {
                XCTFail("Request Errored in unexpected way")
            }
            expectation.fulfill()
        }
        requestToken.cancelOnDeinit = false
        self.waitForExpectations(timeout: 1)
    }

    func testResponseDecodingFailure() throws {
        let expectation = self.expectation(description: "requestCompletion")
        let request = OrganizationRequest()
        let responseData: Data = "{}".data(using: .utf8)!
        let mockResponse = MockResponse.success(body: responseData, url: try request.generateURL())
        mockResponseStore.mock(request: request, withResponse: mockResponse)
        var requestToken = session.enqueue(request) { response in
            do {
                _ = try response.unwrap()
                XCTFail("Request Should Error")
            } catch SessionError.responseDecoding(let embeddedError) where embeddedError as? DecodingError != nil {
                switch embeddedError as? DecodingError {
                case .keyNotFound?:
                    break
                default:
                    XCTFail("Request Errored in unexpected way")
                }
            } catch {
                XCTFail("Request Errored in unexpected way")
            }
            expectation.fulfill()
        }
        requestToken.cancelOnDeinit = false
        self.waitForExpectations(timeout: 1)
    }

    func testEmptyDataFailure() throws {
        let expectation = self.expectation(description: "requestCompletion")
        let request = OrganizationRequest()
        let mockResponse = MockResponse.success(body: nil, url: try request.generateURL())
        mockResponseStore.mock(request: request, withResponse: mockResponse)
        var requestToken = session.enqueue(request) { response in
            do {
                _ = try response.unwrap()
                XCTFail("Request Should Error")
            } catch SessionError.responseDecoding(let embeddedError) where embeddedError as? DecodingError != nil {
                switch embeddedError as? DecodingError {
                case .keyNotFound?:
                    break
                default:
                    XCTFail("Request Errored in unexpected way")
                }
            } catch {
                XCTFail("Request Errored in unexpected way")
            }
            expectation.fulfill()
        }
        requestToken.cancelOnDeinit = false
        self.waitForExpectations(timeout: 1)
    }

    func testEmptyDataSuccess() throws {
        let expectation = self.expectation(description: "requestCompletion")
        let request = EmptyRequest()
        let mockResponse = MockResponse.success(body: nil, url: try request.generateURL())
        mockResponseStore.mock(request: request, withResponse: mockResponse)
        var requestToken = session.enqueue(request) { response in
            do {
                let empty = try response.unwrap()
                XCTAssertNotNil(empty)
            } catch {
                XCTFail("Request Should Not Error")
            }
            expectation.fulfill()
        }
        requestToken.cancelOnDeinit = false
        self.waitForExpectations(timeout: 1)
    }

    func testImmediateCancel() throws {
        let expectation = self.expectation(description: "requestCompletion")
        expectation.isInverted = true
        let request = OrganizationRequest()
        let responseData: Data = ResponseData.organization
        let mockResponse = MockResponse.success(body: responseData, url: try request.generateURL(), latency: 0.02)
        mockResponseStore.mock(request: request, withResponse: mockResponse)
        let requestToken = session.enqueue(request) { _ in
            expectation.fulfill()
        }
        requestToken.cancel()
        self.waitForExpectations(timeout: 0.03)
    }

    func testCancel() throws {
        let expectation = self.expectation(description: "requestCompletion")
        expectation.isInverted = true
        let request = OrganizationRequest()
        let responseData: Data = ResponseData.organization
        let mockResponse = MockResponse.success(body: responseData, url: try request.generateURL(), latency: 0.02)
        mockResponseStore.mock(request: request, withResponse: mockResponse)
        let requestToken = session.enqueue(request) { _ in
            expectation.fulfill()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            requestToken.cancel()
        }
        self.waitForExpectations(timeout: 0.03)
    }

    //TODO: Test requestEncodingQueue is used when that's possible (currently we cannot inject anything into that process)
}
