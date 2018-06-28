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

internal struct MockResponse {
    let body: Data?
    let response: URLResponse?
    let error: Error?
    let latency: TimeInterval

    static func failure(error: Error, latency: TimeInterval = 0) -> MockResponse {
        return self.init(body: nil, response: nil, error: error, latency: latency)
    }

    static func success(body: Data?, response: URLResponse, latency: TimeInterval = 0) -> MockResponse {
        return self.init(body: body, response: response, error: nil, latency: latency)
    }

    static func success(body: Data?, url: URL, statusCode: Int = 200, latency: TimeInterval = 0) -> MockResponse {
        let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        return self.init(body: body, response: response, error: nil, latency: latency)
    }
}

internal protocol MockResponseStore: class {
    func mock<R: Request>(request: R, withResponse: MockResponse)
}
