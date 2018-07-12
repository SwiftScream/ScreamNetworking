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

private let queueMarkerKey: DispatchSpecificKey<String> = DispatchSpecificKey()

struct SessionQueueTestsService {
    public struct SessionQueueTest: Request {
        public static let endpoint = Endpoint.url(URL(string: "https://api.example.com/sessionQueueTest")!)
        typealias ResponseBodyType = SessionQueueMarkerResponse
    }

    public struct SessionQueueMarkerResponse: Decodable {
        public let responseDecodingQueueMarker: String?

        init(from decoder: Decoder) {
            responseDecodingQueueMarker = DispatchQueue.getSpecific(key: queueMarkerKey)
        }
    }
}


class SessionQueuesTests: XCTestCase {

    override func setUp() {
        DispatchQueue.main.setSpecific(key: queueMarkerKey, value: nil)
    }

    func test_CallbackQueue_NotSpecifiedUsesMainQueue() throws {
        DispatchQueue.main.setSpecific(key: queueMarkerKey, value: "main")
        let session = Session()
        let mockResponseStore = session.startMocking()
        let expectation = self.expectation(description: "requestCompletion")
        let request = GitHubService.Empty()
        let mockResponse = MockResponse.success(body: nil, url: try request.generateURL())
        mockResponseStore.mock(request: request, withResponse: mockResponse)
        var requestToken = session.enqueue(request) { response in
            XCTAssertEqual(DispatchQueue.getSpecific(key: queueMarkerKey), "main")
            expectation.fulfill()
        }
        requestToken.cancelOnDeinit = false
        self.waitForExpectations(timeout: 1)
    }

    func test_CallbackQueue_Specified() throws {
        let callbackQueue = DispatchQueue(label: "callbackQueue")
        callbackQueue.setSpecific(key: queueMarkerKey, value: "callback")
        let session = Session(callbackQueue: callbackQueue)
        let mockResponseStore = session.startMocking()
        let expectation = self.expectation(description: "requestCompletion")
        let request = GitHubService.Organization()
        let mockResponse = MockResponse.success(body: nil, url: try request.generateURL())
        mockResponseStore.mock(request: request, withResponse: mockResponse)
        var requestToken = session.enqueue(request) { response in
            XCTAssertEqual(DispatchQueue.getSpecific(key: queueMarkerKey), "callback")
            expectation.fulfill()
        }
        requestToken.cancelOnDeinit = false
        self.waitForExpectations(timeout: 1)
    }

    func test_ResponseDecodingQueue_NotSpecifiedDoesNotUseMainQueue() throws {
        DispatchQueue.main.setSpecific(key: queueMarkerKey, value: "main")
        let session = Session()
        let mockResponseStore = session.startMocking()
        let expectation = self.expectation(description: "requestCompletion")
        let request = SessionQueueTestsService.SessionQueueTest()
        let mockResponse = MockResponse.success(body: "{}".data(using: .utf8), url: try request.generateURL())
        mockResponseStore.mock(request: request, withResponse: mockResponse)
        var requestToken = session.enqueue(request) { response in
            do {
                let queueMarker = try response.unwrap()
                XCTAssertNil(queueMarker.responseDecodingQueueMarker)
             } catch {
                XCTFail("Request Should Not Error")
            }
            expectation.fulfill()
        }
        requestToken.cancelOnDeinit = false
        self.waitForExpectations(timeout: 1)
    }

    func test_ResponseDecodingQueue_Specified() throws {
        let responseDecodingQueue = DispatchQueue(label: "responseDecodingQueue")
        responseDecodingQueue.setSpecific(key: queueMarkerKey, value: "responseDecoding")
        let session = Session(responseDecodingQueue: responseDecodingQueue)
        let mockResponseStore = session.startMocking()
        let expectation = self.expectation(description: "requestCompletion")
        let request = SessionQueueTestsService.SessionQueueTest()
        let mockResponse = MockResponse.success(body: "{}".data(using: .utf8), url: try request.generateURL())
        mockResponseStore.mock(request: request, withResponse: mockResponse)
        var requestToken = session.enqueue(request) { response in
            do {
                let queueMarker = try response.unwrap()
                XCTAssertEqual(queueMarker.responseDecodingQueueMarker, "responseDecoding")
            } catch {
                XCTFail("Request Should Not Error")
            }
            expectation.fulfill()
        }
        requestToken.cancelOnDeinit = false
        self.waitForExpectations(timeout: 1)
    }
}
