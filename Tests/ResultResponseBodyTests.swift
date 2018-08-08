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

struct TestSuccessObject: Decodable {
    let name: String
}

struct TestErrorObject: Decodable {
    let message: String
}

typealias TestResultResponseBody = ResultResponseBody<TestSuccessObject, TestErrorObject>

class ResultResponseBodyTests: XCTestCase {

    func testDefaultSuccess() {
        let successResponseBodyString = "{\"name\": \"SwiftScream\"}"
        guard let successResponseBody = successResponseBodyString.data(using: .utf8) else {
            XCTFail("Failed to encode string")
            return
        }

        let decoder = JSONDecoder()
        //No reponse object added to the decoder, success is assumed
        do {
            let response = try decoder.decode(TestResultResponseBody.self, from: successResponseBody)
            switch response {
            case .success(let s):
                XCTAssertEqual(s.name, "SwiftScream")
            default:
                XCTFail("Incorrect result case")
            }
        } catch {
            XCTFail("Unexpected throw")
        }

    }

    func testSuccess() {
        let responseBodyString = "{\"name\": \"SwiftScream\"}"
        guard let responseBody = responseBodyString.data(using: .utf8) else {
            XCTFail("Failed to encode string")
            return
        }

        let decoder = JSONDecoder()
        decoder.userInfo[.response] = HTTPURLResponse(url: URL(string: "http://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        do {
            let response = try decoder.decode(TestResultResponseBody.self, from: responseBody)
            switch response {
            case .success(let s):
                XCTAssertEqual(s.name, "SwiftScream")
            default:
                XCTFail("Incorrect result case")
            }
        } catch {
            XCTFail("Unexpected throw")
        }
    }

    func testError() {
        let responseBodyString = "{\"message\": \"Bad things happened\"}"
        guard let responseBody = responseBodyString.data(using: .utf8) else {
            XCTFail("Failed to encode string")
            return
        }

        let decoder = JSONDecoder()
        decoder.userInfo[.response] = HTTPURLResponse(url: URL(string: "http://example.com")!, statusCode: 500, httpVersion: nil, headerFields: nil)
        do {
            let response = try decoder.decode(TestResultResponseBody.self, from: responseBody)
            switch response {
            case .error(let e):
                XCTAssertEqual(e.message, "Bad things happened")
            default:
                XCTFail("Incorrect result case")
            }
        } catch {
            XCTFail("Unexpected throw")
        }
    }

}
