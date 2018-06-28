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
import Dispatch
import ScreamNetworking

class EssentialsTests: XCTestCase {

    func test_DispatchAsyncCancellable_NoCancel() {
        let expectation = self.expectation(description: "block completion")
        var cancellable = DispatchQueue.main.asyncCancellable {
            expectation.fulfill()
        }
        cancellable.cancelOnDeinit = true
        self.waitForExpectations(timeout: 0.01)
    }

    func test_DispatchAsyncCancellable_Cancel() {
        let expectation = self.expectation(description: "block completion")
        expectation.isInverted = true
        let cancellable = DispatchQueue.main.asyncCancellable {
            expectation.fulfill()
        }
        cancellable.cancel()
        self.waitForExpectations(timeout: 0.01)
    }

    func test_DispatchAsyncCancellable_AutoCancel() {
        let expectation = self.expectation(description: "block completion")
        expectation.isInverted = true
        var cancellable: AutoCancellable? = DispatchQueue.main.asyncCancellable {
            expectation.fulfill()
        }
        XCTAssertTrue(cancellable!.cancelOnDeinit)
        cancellable = nil
        self.waitForExpectations(timeout: 0.01)
    }


    func test_DispatchAsyncAfterCancellable_NoCancel() {
        let expectation = self.expectation(description: "block completion")
        var cancellable = DispatchQueue.main.asyncAfterCancellable(deadline: .now() + 0.01) {
            expectation.fulfill()
        }
        cancellable.cancelOnDeinit = true
        self.waitForExpectations(timeout: 0.02)
    }

    func test_DispatchAsyncAfterCancellable_Cancel() {
        let expectation = self.expectation(description: "block completion")
        expectation.isInverted = true
        let cancellable = DispatchQueue.main.asyncAfterCancellable(deadline: .now() + 0.01) {
            expectation.fulfill()
        }
        cancellable.cancel()
        self.waitForExpectations(timeout: 0.02)
    }

    func test_DispatchAsyncAfterCancellable_AutoCancel() {
        let expectation = self.expectation(description: "block completion")
        expectation.isInverted = true
        var cancellable: AutoCancellable? = DispatchQueue.main.asyncAfterCancellable(deadline: .now() + 0.01) {
            expectation.fulfill()
        }
        XCTAssertTrue(cancellable!.cancelOnDeinit)
        cancellable = nil
        self.waitForExpectations(timeout: 0.02)
    }

}
