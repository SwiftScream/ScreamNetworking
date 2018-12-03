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
import URITemplate

public struct ReqResSessionConfiguration: SessionConfiguration {
    public let description = "ReqRes"
}

typealias ReqResSession = Session<ReqResSessionConfiguration>
extension Session where ConfigurationType == ReqResSessionConfiguration {
    convenience init() {
        self.init(configuration: ReqResSessionConfiguration())
    }
}


public struct ReqResErrorResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case error
    }
    let error: String
}

public typealias ReqResResponseBody<SuccessType: Decodable> = ResultResponseBody<SuccessType, ReqResErrorResponse>

protocol ReqResRequest: Request where SessionConfigurationType == ReqResSessionConfiguration {
}

public struct ReqResCredentials: Encodable {
    let email: String
    let password: String
}

public struct ReqResLogin: ReqResRequest {
    public static let endpoint = Endpoint.url("https://reqres.in/api/login")
    public typealias ResponseBodyType = ReqResResponseBody<ReqResLoginResponse>
    public static let method = "POST"
    public static let body = Optional(\ReqResLogin.credentials)

    public let credentials: ReqResCredentials

    public let loggingOptions: LoggingOptions = [.request, .response, .requestBody]
}

public struct ReqResLoginResponse: Decodable {
    public let token: String
}
