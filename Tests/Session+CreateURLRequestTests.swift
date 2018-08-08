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
import URITemplate

private class Empty: Decodable {
}

class SessionCreateURLRequestTests: XCTestCase {
    var defaultSession: DefaultSession!
    var gitHubSession: GitHubSession!

    override func setUp() {
        defaultSession = DefaultSession()
        gitHubSession = GitHubSession()
    }

    func testMinimalRequestBuild() {
        struct TestRequest: Request {
            public static let endpoint = Endpoint.url(URL(string: "https://api.example.com")!)
            typealias ResponseBodyType = Empty
        }

        guard let request = try? defaultSession.createURLRequest(request: TestRequest()) else {
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

        guard let request = try? defaultSession.createURLRequest(request: TestRequest()) else {
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
            let b: String? //testing nil removal
        }

        guard let request = try? defaultSession.createURLRequest(request: TestRequest(path: "foo", a: true, b: nil)) else {
            XCTFail("Fail to build request")
            return
        }
        XCTAssertEqual(request.url, URL(string: "https://api.example.com/foo?a=true"))
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertNil(request.httpBody)
        XCTAssertEqual(request.allHTTPHeaderFields?.count, 0)
    }

    func testRequestWithHeadersBuild() {
        struct TestRequest: Request {
            public static let endpoint = Endpoint.url(URL(string: "https://api.example.com")!)
            typealias ResponseBodyType = Empty
            public static let headers: HeaderMap = ["Accept": \TestRequest.accept]
            public let accept = "accept header value"
        }

        guard let request = try? defaultSession.createURLRequest(request: TestRequest()) else {
            XCTFail("Fail to build request")
            return
        }
        XCTAssertEqual(request.url, URL(string: "https://api.example.com"))
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertNil(request.httpBody)
        XCTAssertEqual(request.allHTTPHeaderFields?.count, 1)
        XCTAssertEqual(request.allHTTPHeaderFields?["Accept"], "accept header value")
    }

    func testRequestWithNilHeadersBuild() {
        struct TestRequest: Request {
            public static let endpoint = Endpoint.url(URL(string: "https://api.example.com")!)
            typealias ResponseBodyType = Empty
            public static let headers: HeaderMap = ["Accept": \TestRequest.accept]
            public let accept: String? = nil
        }

        guard let request = try? defaultSession.createURLRequest(request: TestRequest()) else {
            XCTFail("Fail to build request")
            return
        }
        XCTAssertEqual(request.url, URL(string: "https://api.example.com"))
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertNil(request.httpBody)
        XCTAssertEqual(request.allHTTPHeaderFields?.count, 0)
        XCTAssertNil(request.allHTTPHeaderFields?["Accept"])
    }

    func testRequestWithSessionHeadersBuild() {
        guard let request = try? gitHubSession.createURLRequest(request: EmptyRequest()) else {
            XCTFail("Fail to build request")
            return
        }
        XCTAssertEqual(request.url, URL(string: "https://api.example.com/empty"))
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertNil(request.httpBody)
        XCTAssertEqual(request.allHTTPHeaderFields?.count, 1)
        XCTAssertEqual(request.allHTTPHeaderFields?["Accept"], "application/vnd.github.v3+json")
    }

    func testRequestWithRequestHeaderOverrideSessionHeaderBuild() {
        struct TestRequest: GitHubRequest {
            public static let endpoint = Endpoint.url(URL(string: "https://api.example.com")!)
            typealias ResponseBodyType = Empty
            public static let headers: HeaderMap = ["Accept": \TestRequest.accept]
            public let accept = "accept header value"
        }

        guard let request = try? gitHubSession.createURLRequest(request: TestRequest()) else {
            XCTFail("Fail to build request")
            return
        }
        XCTAssertEqual(request.url, URL(string: "https://api.example.com"))
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertNil(request.httpBody)
        XCTAssertEqual(request.allHTTPHeaderFields?.count, 1)
        XCTAssertEqual(request.allHTTPHeaderFields?["Accept"], "accept header value")
    }

    func testRequestWithSessionVariablesBuild() {
        struct TestRequest: GitHubRequest {
            public static let endpoint = Endpoint.template("https://api.example.com{/path}{?sessionID}", [
                "path": \TestRequest.path
                ])
            typealias ResponseBodyType = Empty

            let path: String
        }

        guard let request = try? gitHubSession.createURLRequest(request: TestRequest(path: "foo")) else {
            XCTFail("Fail to build request")
            return
        }
        XCTAssertEqual(request.url, URL(string: "https://api.example.com/foo?sessionID=asd"))
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertNil(request.httpBody)
    }

    func testRequestWithRequestVariableOverrideSessionVariableBuild() {
        struct TestRequest: GitHubRequest {
            public static let endpoint = Endpoint.template("https://api.example.com{/path}{?sessionID}", [
                "path": \TestRequest.path,
                "sessionID": \TestRequest.sessionID
                ])
            typealias ResponseBodyType = Empty

            let path: String
            let sessionID: String
        }

        guard let request = try? gitHubSession.createURLRequest(request: TestRequest(path: "foo", sessionID: "123")) else {
            XCTFail("Fail to build request")
            return
        }
        XCTAssertEqual(request.url, URL(string: "https://api.example.com/foo?sessionID=123"))
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertNil(request.httpBody)
    }

    func testRequestWithRelationshipBuild() {
        struct TestRequest: Request {
            public static let endpoint = Endpoint.relationship(\.relationship, [
                "path": \TestRequest.path,
                ])
            typealias ResponseBodyType = Empty

            let relationship: URITemplate
            let path: String //treated as VariableValue
        }

        guard let request = try? defaultSession.createURLRequest(request: TestRequest(relationship: "https://api.example.com{/path}", path: "foo")) else {
            XCTFail("Fail to build request")
            return
        }
        XCTAssertEqual(request.url, URL(string: "https://api.example.com/foo"))
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertNil(request.httpBody)
        XCTAssertEqual(request.allHTTPHeaderFields?.count, 0)
    }

    func testRequestWithOptionalRelationshipBuild() {
        struct TestRequest: Request {
            public static let endpoint = Endpoint.optionalRelationship(\.relationship, [
                "path": \TestRequest.path,
                ])
            typealias ResponseBodyType = Empty

            let relationship: URITemplate?
            let path: String //treated as VariableValue
        }

        guard let request = try? defaultSession.createURLRequest(request: TestRequest(relationship: "https://api.example.com{/path}", path: "foo")) else {
            XCTFail("Fail to build request")
            return
        }
        XCTAssertEqual(request.url, URL(string: "https://api.example.com/foo"))
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertNil(request.httpBody)
        XCTAssertEqual(request.allHTTPHeaderFields?.count, 0)
    }

    func testRequestWithNilRelationshipBuild() {
        struct TestRequest: Request {
            public static let endpoint = Endpoint.optionalRelationship(\.relationship, [
                "path": \TestRequest.path,
                ])
            typealias ResponseBodyType = Empty

            let relationship: URITemplate?
            let path: String //treated as VariableValue
        }

        do {
            _ = try defaultSession.createURLRequest(request: TestRequest(relationship: nil, path: "foo"))
        } catch RequestError.endpointUnavailable {
            return
        } catch {
            XCTFail("Request build failed with unexpected error")
        }
        XCTFail("Request build passed unexpectedly")
    }

    func testRequestWithRootRelationshipBuild() {
        struct TestRequest: GitHubRequest {
            public static let endpoint = Endpoint.rootRelationship(\.relationship, [
                "org": \TestRequest.org,
                ])
            typealias ResponseBodyType = Empty

            let org: String
        }

        guard let request = try? gitHubSession.createURLRequest(request: TestRequest(org: "foo")) else {
            XCTFail("Fail to build request")
            return
        }
        XCTAssertEqual(request.url, URL(string: "https://api.github.com/orgs/foo"))
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertNil(request.httpBody)
    }

    func testRequestWithOptionalRootRelationshipBuild() {
        struct TestRequest: GitHubRequest {
            public static let endpoint = Endpoint.optionalRootRelationship(\.optionalRelationship, [
                "org": \TestRequest.org,
                ])
            typealias ResponseBodyType = Empty

            let org: String
        }

        guard let request = try? gitHubSession.createURLRequest(request: TestRequest(org: "foo")) else {
            XCTFail("Fail to build request")
            return
        }
        XCTAssertEqual(request.url, URL(string: "https://api.github.com/orgs/foo"))
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertNil(request.httpBody)
    }

    func testRequestWithNilRootRelationshipBuild() {
        struct TestRequest: GitHubRequest {
            public static let endpoint = Endpoint.optionalRootRelationship(\.nilRelationship, [
                "org": \TestRequest.org,
                ])
            typealias ResponseBodyType = Empty

            let org: String
        }

        do {
            _ = try gitHubSession.createURLRequest(request: TestRequest(org: "foo"))
        } catch RequestError.endpointUnavailable {
            return
        } catch {
            XCTFail("Request build failed with unexpected error")
        }
        XCTFail("Request build passed unexpectedly")
    }

}
