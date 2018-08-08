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

class URLSessionTaskAutoCancellableTests: XCTestCase {

    func testAutoCancel() {
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
        let task = session.dataTask(with: URL(string: "http://example.com")!)
        var cancellable: URLSessionTaskAutoCancellable? = URLSessionTaskAutoCancellable(task: task)
        guard let cancelOnDeinit = cancellable?.cancelOnDeinit else {
            XCTFail("unexpected nil")
            return
        }
        XCTAssertTrue(cancelOnDeinit)
        XCTAssertEqual(task.state, .suspended)
        cancellable = nil
        XCTAssertEqual(task.state, .canceling)
    }

    func testNoAutoCancel() {
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
        let task = session.dataTask(with: URL(string: "http://example.com")!)
        var cancellable: URLSessionTaskAutoCancellable? = URLSessionTaskAutoCancellable(task: task)
        cancellable?.cancelOnDeinit = false
        XCTAssertEqual(task.state, .suspended)
        cancellable = nil
        XCTAssertEqual(task.state, .suspended)
    }

}
