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

public struct EmptyResponse: Decodable {
}

public protocol Request {
    associatedtype ResponseBodyType: Decodable = EmptyResponse

    static var endpoint: Endpoint { get }
    static var method: String { get }
}

extension Request {
    public static var method: String {
        return "GET"
    }
}

extension Request {
    internal func createURLRequest() throws -> URLRequest {
        let url = generateURL()
        var r = URLRequest(url: url)
        r.httpMethod = Self.method
        return r
    }

    internal func generateURL() -> URL {
        switch Self.endpoint {
        case .url(let u):
            return u
        }
    }
}
