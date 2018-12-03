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
import ScreamNetworking
import ScreamEssentials

private let session = ReqResSession()
private var loginRequest: AutoCancellable?

public func runResReqExample() {
    let credentials = ReqResCredentials(email: "swiftscream@example.com", password: "swordfish")
    loginRequest = session.enqueue(ReqResLogin(credentials: credentials)) { response in
        do {
            switch try response.unwrap() {
            case .error(let e):
                print("Domain Error: \(e.error)")
            case .success(let object):
                print("Auth Token: \(object.token)")
            }
        } catch let e {
            print("Networking Error: \(e)")
        }
    }

}
