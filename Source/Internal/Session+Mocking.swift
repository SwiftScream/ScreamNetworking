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

import Foundation
import Dispatch

internal protocol URLSessionTaskProtocol {
    func resume()
    func cancel()
}

internal protocol URLSessionDataTaskProtocol: URLSessionTaskProtocol {
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {
}

internal protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
}

extension URLSession: URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        let task: URLSessionDataTask = dataTask(with: request, completionHandler: completionHandler)
        return task as URLSessionDataTaskProtocol
    }
}

internal class MockURLSession<ConfigurationType: SessionConfiguration>: URLSessionProtocol {
    internal let mockResponseStore: MockResponseStore<ConfigurationType>
    private let sessionDelegateQueue: DispatchQueue

    init(session: Session<ConfigurationType>, urlSession: URLSession) {
        mockResponseStore = MockResponseStore(session: session)
        sessionDelegateQueue = urlSession.delegateQueue.underlyingQueue ?? DispatchQueue(label: "mockSessionDelegateQueue")
    }

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        let mockResponse = mockResponseStore.mockResponse(forRequest: request)
        return MockURLSessionDataTask(sessionDelegateQueue: self.sessionDelegateQueue, response: mockResponse, completionHandler: completionHandler)
    }
}

internal class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    let sessionDelegateQueue: DispatchQueue
    let response: MockResponse?
    let completion: (Data?, URLResponse?, Error?) -> Void
    var cancellable: AutoCancellable?

    init(sessionDelegateQueue: DispatchQueue, response: MockResponse?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.sessionDelegateQueue = sessionDelegateQueue
        self.response = response
        self.completion = completionHandler
    }

    func resume() {
        guard let response = response else {
            cancellable = sessionDelegateQueue.asyncCancellable {
                self.completion(nil, nil, nil)
            }
            return
        }
        cancellable = sessionDelegateQueue.asyncAfterCancellable(deadline: .now() + response.latency) {
            self.completion(response.body, response.response, response.error)
        }
    }

    func cancel() {
        guard let cancellable = self.cancellable else {
            return
        }
        cancellable.cancel()
        self.cancellable = nil
    }
}
