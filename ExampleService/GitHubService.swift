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

extension URL: ExpressibleByStringLiteral {
    public init(stringLiteral value: StaticString) {
        self.init(string: "\(value)")!
    }
}

public struct GitHubSessionConfiguration: SessionConfiguration {
}

typealias GitHubSession = Session<GitHubSessionConfiguration>

public struct GitHubErrorResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case message
        case documentationURL = "documentation_url"
    }
    let message: String
    let documentationURL: URL
}

public typealias GitHubResponseBody<SuccessType: Decodable> = ResultResponseBody<SuccessType, GitHubErrorResponse>

protocol GitHubRequest: Request where SessionConfigurationType == GitHubSessionConfiguration {
}

public struct GitHubRoot: GitHubRequest {
    public static let endpoint = Endpoint.url("https://api.github.com")
    public typealias ResponseBodyType = GitHubResponseBody<GitHubRootResponse>
}

public struct GitHubRootResponse: Decodable {
    public let endpoints: [String: String]

    public init(from decoder: Decoder) throws {
        endpoints = try Dictionary(from: decoder)
    }
}

public struct GitHubOrganization: GitHubRequest {
    public static let endpoint = Endpoint.template("https://api.github.com/orgs/{org}", [
        "org": \GitHubOrganization.name,
        ])
    public typealias ResponseBodyType = GitHubResponseBody<GitHubOrganizationResponse>

    let name: String
}

public struct GitHubOrganizationResponse: Decodable {
    public let name: String
    public let description: String
    public let location: String
}
