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
import ScreamNetworking

public struct TestRequest: Request {
    public static let endpoint = Endpoint.url(URL(string: "https://api.github.com/orgs/SwiftScream")!)
    public typealias ResponseBodyType = ResultResponseBody<TestResponse, TestErrorResponse>
}

public struct TestResponse: Decodable {
    public let name: String
    public let description: String
    public let location: String
}

public struct TestErrorResponse: Decodable {
    let message: String
}

class Tests: XCTestCase {
    var session: Session?

    override func setUp() {
        session = Session(description: "TestSession")
    }

    func testExample() {
    }

}
