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
import ScreamEssentials

internal class URLSessionTaskAutoCancellable: AutoCancellable {
    private let task: URLSessionTaskProtocol
    public var cancelOnDeinit: Bool

    init(task: URLSessionTaskProtocol) {
        self.task = task
        cancelOnDeinit = true
    }

    deinit {
        if cancelOnDeinit {
            cancel()
        }
    }

    public func cancel() {
        task.cancel()
    }
}
