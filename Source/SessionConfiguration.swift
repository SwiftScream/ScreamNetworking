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

public protocol SessionConfiguration {
    var urlSessionConfiguration: URLSessionConfiguration { get }
    var description: String { get }
    var requestEncodingQueue: DispatchQueue? { get }
    var responseDecodingQueue: DispatchQueue? { get }
    var callbackQueue: DispatchQueue? { get }

    var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { get }
    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { get }
    var dataDecodingStrategy: JSONDecoder.DataDecodingStrategy { get }
    var nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy { get }
}

extension SessionConfiguration {
    public var urlSessionConfiguration: URLSessionConfiguration { return URLSessionConfiguration.default }
    public var requestEncodingQueue: DispatchQueue? { return nil }
    public var responseDecodingQueue: DispatchQueue? { return nil }
    public var callbackQueue: DispatchQueue? { return nil }

    public var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { return .useDefaultKeys }
    public var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { return .deferredToDate }
    public var dataDecodingStrategy: JSONDecoder.DataDecodingStrategy { return .base64 }
    public var nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy { return .throw }
}

public struct DefaultSessionConfiguration: SessionConfiguration {
    public let description = "Default"
}
