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

private class Empty: Decodable {
}

class RequestTests: XCTestCase {

    func testMinimalRequestBuild() {
        struct TestRequest: Request {
            public static let endpoint = Endpoint.url(URL(string: "https://api.example.com")!)
            typealias ResponseBodyType = Empty
        }

        guard let request = try? TestRequest().createURLRequest() else {
            XCTFail("Fail to build request")
            return
        }
        XCTAssertEqual(request.url, URL(string: "https://api.example.com"))
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertNil(request.httpBody)
        XCTAssertEqual(request.allHTTPHeaderFields?.count, 0)
    }

    func testPostRequestBuild() {
        struct TestRequest: Request {
            public static let endpoint = Endpoint.url(URL(string: "https://api.example.com")!)
            public static let method = "POST"
            typealias ResponseBodyType = Empty
        }

        guard let request = try? TestRequest().createURLRequest() else {
            XCTFail("Fail to build request")
            return
        }
        XCTAssertEqual(request.url, URL(string: "https://api.example.com"))
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertNil(request.httpBody)
        XCTAssertEqual(request.allHTTPHeaderFields?.count, 0)
    }

    func testTemplateRequestBuild() {
        struct TestRequest: Request {
            public static let endpoint = Endpoint.template("https://api.example.com{/path}{?a,b}", [
                "path": \TestRequest.path,
                "a": \TestRequest.a,
                "b": \TestRequest.b,
                ])
            typealias ResponseBodyType = Empty

            let path: String //treated as VariableValue
            let a: Bool //treated as CustomStringConvertible
            let b: CGPoint // neither VariableValue or CustomStringConvertible so treated as fallback
        }

        guard let request = try? TestRequest(path: "foo", a: true, b: CGPoint(x: 10, y: 20)).createURLRequest() else {
            XCTFail("Fail to build request")
            return
        }
        XCTAssertEqual(request.url, URL(string: "https://api.example.com/foo?a=true&b=%2810.0%2C%2020.0%29"))
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertNil(request.httpBody)
        XCTAssertEqual(request.allHTTPHeaderFields?.count, 0)
    }

}
