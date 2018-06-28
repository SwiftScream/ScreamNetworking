//
//  SessionTests+ResponseData.swift
//  ScreamNetworking
//
//  Created by Deem, Alex on 5/7/18.
//  Copyright © 2018 SwiftScream. All rights reserved.
//

import Foundation

extension SessionTests {
    struct ResponseData {
        static let organization = """
        {
            "login": "SwiftScream",
            "id": 29154082,
            "node_id": "MDEyOk9yZ2FuaXphdGlvbjI5MTU0MDgy",
            "url": "https://api.github.com/orgs/SwiftScream",
            "repos_url": "https://api.github.com/orgs/SwiftScream/repos",
            "events_url": "https://api.github.com/orgs/SwiftScream/events",
            "hooks_url": "https://api.github.com/orgs/SwiftScream/hooks",
            "issues_url": "https://api.github.com/orgs/SwiftScream/issues",
            "members_url": "https://api.github.com/orgs/SwiftScream/members{/member}",
            "public_members_url": "https://api.github.com/orgs/SwiftScream/public_members{/member}",
            "avatar_url": "https://avatars0.githubusercontent.com/u/29154082?v=4",
            "description": "Scream (noun): a group of swifts",
            "name": "Swift Scream",
            "company": null,
            "blog": "",
            "location": "Sydney, Australia",
            "email": "",
            "has_organization_projects": true,
            "has_repository_projects": true,
            "public_repos": 4,
            "public_gists": 0,
            "followers": 0,
            "following": 0,
            "html_url": "https://github.com/SwiftScream",
            "created_at": "2017-06-02T23:06:32Z",
            "updated_at": "2018-05-09T23:46:07Z",
            "type": "Organization"
        }
    """.data(using: .utf8)!
    }
}
