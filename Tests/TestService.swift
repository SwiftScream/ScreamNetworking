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

@testable import ScreamNetworking

import Foundation
import URITemplate

struct GitHubSessionConfiguration: SessionConfiguration {
    public let description = "GitHub"
    public let keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase

    // Headers
    public static let requestHeaders: HeaderMap = ["Accept": \GitHubSessionConfiguration.accept,
                                                   "Accept-Charset": \GitHubSessionConfiguration.acceptCharset,
                                                   "ShouldNotAppear": \GitHubSessionConfiguration.nilHeaderValue]
    public let acceptCharset: String? = "utf-8"
    public let accept = "application/vnd.github.v3+json"
    public let nilHeaderValue: String? = nil

    // Template Variables
    public static let templateVariables: VariableMap = ["sessionID": \GitHubSessionConfiguration.sessionID,
                                                        "a": \GitHubSessionConfiguration.a,
                                                        "b": \GitHubSessionConfiguration.b]
    public let sessionID = "asd" //treated as VariableValue
    public let a: Bool? = true //treated as CustomStringConvertible
    public let b: String? = nil //testing nil removal

    // Relationships
    public let relationship: URITemplate = "https://api.github.com/orgs/{org}"
    public let optionalRelationship: URITemplate? = "https://api.github.com/orgs/{org}"
    public let nilRelationship: URITemplate? = nil
}

typealias GitHubSession = Session<GitHubSessionConfiguration>
extension Session where ConfigurationType == GitHubSessionConfiguration {
    convenience init() {
        self.init(configuration: GitHubSessionConfiguration())
    }
}

protocol GitHubRequest: Request where SessionConfigurationType == GitHubSessionConfiguration {
}

struct OrganizationRequest: GitHubRequest {
    public static let endpoint = Endpoint.url(URL(string: "https://api.github.com/orgs/SwiftScream")!)
    public typealias ResponseBodyType = OrganizationResponse
}

struct OrganizationResponse: Decodable {
    public let name: String
    public let description: String
    public let location: String
}

struct EmptyRequest: GitHubRequest {
    public static let endpoint = Endpoint.url(URL(string: "https://api.example.com/empty")!)
}

enum TestError: Swift.Error {
    case testErrorA
    case testErrorB
}
