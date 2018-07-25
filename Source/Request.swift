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
import URITemplate

public struct EmptyResponse: Decodable {
}

public protocol Request {
    associatedtype SessionConfigurationType: SessionConfiguration = DefaultSessionConfiguration
    associatedtype ResponseBodyType: Decodable = EmptyResponse
    typealias Endpoint = EndpointT<Self>
    typealias HeaderMap = [String: PartialKeyPath<Self>]

    static var endpoint: Endpoint { get }
    static var method: String { get }
    static var headers: HeaderMap { get }
}

extension Request {
    public static var method: String {
        return "GET"
    }
    public static var headers: HeaderMap {
        return [:]
    }
}

public enum RequestError: Error {
    case invalidEndpoint
}

extension Request {
    internal func createURLRequest() throws -> URLRequest {
        let url = try generateURL()
        var r = URLRequest(url: url)
        r.httpMethod = Self.method
        r.allHTTPHeaderFields = generateHeaders()
        return r
    }

    internal func generateURL() throws -> URL {
        switch Self.endpoint {
        case .url(let u):
            return u
        case .template(let template, let variableMap):
            let variables = variableMap.mapValues { (keyPath) -> VariableValue in
                let value = self[keyPath: keyPath]
                switch value {
                case let variableValue as VariableValue:
                    return variableValue
                case let stringValue as CustomStringConvertible:
                    return stringValue.description
                default:
                    return String(describing: value)
                }
            }
            let expandedTemplate = try template.process(variables: variables)
            guard let url = URL(string: expandedTemplate) else {
                throw RequestError.invalidEndpoint
            }
            return url
        }
    }

    internal func generateHeaders() -> [String: String] {
        let variables = Self.headers.compactMapValues { (keyPath) -> String? in
            let value: Any = self[keyPath: keyPath]
            switch value {
            case let stringValue as CustomStringConvertible:
                return stringValue.description
            case let any as Any? where any == nil:
                return nil
            default:
                assertionFailure("Failed to render request header value")
                return nil
            }
        }
        return variables
    }
}
