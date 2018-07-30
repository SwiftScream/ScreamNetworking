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
import URITemplate

public enum EndpointT<R: Request> {
    public typealias VariableMap = [String: PartialKeyPath<R>]

    //swiftlint:disable identifier_name superfluous_disable_command
    case url(URL)
    case template(URITemplate, VariableMap)
    //swiftlint:enable identifier_name superfluous_disable_command
}

extension EndpointT {
    var requiresVariables: Bool {
        switch self {
        case .url:
            return false
        case .template:
            return true
        }
    }

    var variableMap: VariableMap? {
        switch self {
        case .url:
            return nil
        case .template(_, let variableMap):
            return variableMap
        }
    }
}
