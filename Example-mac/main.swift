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

let session = GitHubSession()

func requestRepos(org: GitHubOrganizationResponse) -> AutoCancellable {
    return session.enqueue(GitHubOrganizationRepos(organization: org)) { response in
        do {
            switch try response.unwrap() {
            case .error(let e):
                print("Domain Error: \(e.message)")
            case .success(let repos):
                print("Repositories: \(repos.count)")
            }
        } catch let e {
            print("Networking Error: \(e)")
        }
    }
}

let rootRequest = session.enqueue(GitHubRoot()) { response in
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
}

var reposRequest: AutoCancellable?
let orgRequest = session.enqueue(GitHubOrganization(name: "SwiftScream")) { response in
    do {
        switch try response.unwrap() {
        case .error(let e):
            print("Domain Error: \(e.message)")
        case .success(let org):
            print(org.name)
            print(org.description)
            print(org.location)
            reposRequest = requestRepos(org: org)
        }
    } catch let e {
        print("Networking Error: \(e)")
    }
}

RunLoop.current.run(until: Date(timeIntervalSinceNow: 10))
