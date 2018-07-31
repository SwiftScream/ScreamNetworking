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

class RequestTests: XCTestCase {

    func test_generateVariables_WithURLReturnsNil() {
        struct TestRequest: GitHubRequest {
            public static let endpoint = Endpoint.url(URL(string: "http://www.example.com")!)
        }

        let request = TestRequest()
        let variables = request.generateVariables()
        XCTAssertNil(variables)

        XCTAssertNil(TestRequest.endpoint.variableMap)
    }

}
