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

internal extension CodingUserInfoKey {
    internal static let response: CodingUserInfoKey = CodingUserInfoKey(rawValue: "ScreamNetworking.HTTPURLResponse")!
}

extension Decoder {
    public var response: HTTPURLResponse? { return userInfo[.response] as? HTTPURLResponse }
}

public enum SessionError: Error {
    //swiftlint:disable identifier_name superfluous_disable_command
    case requestEncoding(embeddedError: Swift.Error)
    case network(embeddedError: Swift.Error?)
    case responseDecoding(embeddedError: Swift.Error)
    //swiftlint:enable identifier_name superfluous_disable_command
}

typealias DefaultSession = Session<DefaultSessionConfiguration>
extension Session where ConfigurationType == DefaultSessionConfiguration {
    convenience init() {
        self.init(configuration: DefaultSessionConfiguration())
    }
}

public class Session<ConfigurationType: SessionConfiguration> {
    private let session: URLSession
    private let configuration: ConfigurationType
    private let requestEncodingQueue: DispatchQueue
    private let callbackQueue: DispatchQueue
    private var mockSession: MockURLSession<ConfigurationType>?

    public init(configuration: ConfigurationType) {
        self.configuration = configuration
        var sessionDelegateQueue: OperationQueue? = nil
        if let responseDecodingQueue = configuration.responseDecodingQueue {
            sessionDelegateQueue = OperationQueue()
            sessionDelegateQueue?.underlyingQueue = responseDecodingQueue
        }
        let session = URLSession(configuration: configuration.urlSessionConfiguration, delegate: nil, delegateQueue: sessionDelegateQueue)
        let sessionDescription = "com.swiftscream.networking.\(configuration.description)"
        session.sessionDescription = sessionDescription
        self.session = session

        self.requestEncodingQueue = configuration.requestEncodingQueue ?? DispatchQueue(label: sessionDescription + ".encoding-queue")
        self.callbackQueue = configuration.callbackQueue ?? DispatchQueue.main
    }

    public func enqueue<R: Request>(_ request: R, completion: @escaping (Response<R.ResponseBodyType>) -> Void) -> AutoCancellable where R.SessionConfigurationType == ConfigurationType {
        let cancellableAggregator = AutoCancellableAggregator()
        let encodingCancellable = requestEncodingQueue.asyncCancellable {
            let urlRequest: URLRequest
            do {
                urlRequest = try request.createURLRequest()
            } catch let error {
                let c = self.callbackQueue.asyncCancellable {
                    completion(.error(.requestEncoding(embeddedError: error)))
                }
                _ = cancellableAggregator.add(c)
                return
            }

            let session: URLSessionProtocol = self.mockSession ?? self.session
            let task = session.dataTask(with: urlRequest) { (data, response, error) in
                let result = Response<R.ResponseBodyType> {
                    try self.processResponse(response, data: data, error: error)
                }
                self.callbackQueue.async {
                    completion(result)
                }
            }
            if cancellableAggregator.add(URLSessionTaskAutoCancellable(task: task)) {
                task.resume()
            }
            return
        }
        _ = cancellableAggregator.add(encodingCancellable)
        return cancellableAggregator
    }

    private func processResponse<ResponseBodyType: Decodable>(_ response: URLResponse?, data: Data?, error: Swift.Error?) throws -> ResponseBodyType {
        if let error = error {
            throw SessionError.network(embeddedError: error)
        }
        guard let response = response as? HTTPURLResponse else {
            throw SessionError.network(embeddedError: nil)
        }

        let result: ResponseBodyType
        do {
            let data = data ?? "{}".data(using: .utf8)!
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = configuration.keyDecodingStrategy
            decoder.dateDecodingStrategy = configuration.dateDecodingStrategy
            decoder.dataDecodingStrategy = configuration.dataDecodingStrategy
            decoder.nonConformingFloatDecodingStrategy = configuration.nonConformingFloatDecodingStrategy
            decoder.userInfo[.response] = response
            result = try decoder.decode(ResponseBodyType.self, from: data)
        } catch let error {
            throw SessionError.responseDecoding(embeddedError: error)
        }

        return result
    }

}

extension Session {
    internal typealias MockResponseStoreType = MockResponseStore<ConfigurationType>

    internal func startMocking() -> MockResponseStoreType {
        if let mockSession = self.mockSession {
            return mockSession.mockResponseStore
        }
        let mockSession = MockURLSession(session: self, urlSession: session)
        self.mockSession = mockSession
        return mockSession.mockResponseStore
    }

    internal func stopMocking() {
        self.mockSession = nil
    }
}
