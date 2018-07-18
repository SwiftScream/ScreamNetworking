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

import UIKit
import ScreamNetworking

class ViewController: UIViewController {
    let session: Session
    var rootRequest: AutoCancellable?
    var orgRequest: AutoCancellable?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        session = Session(description: "GitHubSession")
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        rootRequest = session.enqueue(GitHubService.Root()) { [weak self] response in
            do {
                switch try response.unwrap() {
                case .error(let e):
                    print("Domain Error: \(e.message)")
                case .success(let root):
                    print("\(root.endpoints.count) Endpoints")
                }
            } catch let e {
                print("Networking Error: \(e)")
            }
            self?.rootRequest = nil
        }

        orgRequest = session.enqueue(GitHubService.Organization(name: "SwiftScream")) { [weak self] response in
            do {
                switch try response.unwrap() {
                case .error(let e):
                    print("Domain Error: \(e.message)")
                case .success(let org):
                    print(org.name)
                    print(org.description)
                    print(org.location)
                }
            } catch let e {
                print("Networking Error: \(e)")
            }
            self?.orgRequest = nil
        }
    }

}
