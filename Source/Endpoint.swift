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

    case url(URL)
    case template(URITemplate, VariableMap)
    case relationship(KeyPath<R, URITemplate>, VariableMap)
    case optionalRelationship(KeyPath<R, URITemplate?>, VariableMap)
    case rootRelationship(KeyPath<R.SessionConfigurationType, URITemplate>, VariableMap)
    case optionalRootRelationship(KeyPath<R.SessionConfigurationType, URITemplate?>, VariableMap)
}

extension EndpointT {
    var requiresVariables: Bool {
        switch self {
        case .url:
            return false
        case .template,
             .relationship,
             .optionalRelationship,
             .rootRelationship,
             .optionalRootRelationship:
            return true
        }
    }

    var variableMap: VariableMap? {
        switch self {
        case .url:
            return nil
        case .template(_, let variableMap),
             .relationship(_, let variableMap),
             .optionalRelationship(_, let variableMap),
             .rootRelationship(_, let variableMap),
             .optionalRootRelationship(_, let variableMap):
            return variableMap
        }
    }
}
