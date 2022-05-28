//
//  RepoData.swift
//  SearchRepo
//
//  Created by Sumit Joshi on 2022/05/26.
//

import Foundation

struct SearchResult: Decodable {
    let items: [Repository]
    
    enum CodingKeys: String, CodingKey {
        case items
    }
}

struct Repository: Decodable {
    let htmlUrl: URL
    let fullName: String
    let language: String?
    
    enum CodingKeys: String, CodingKey {
        case htmlUrl = "html_url"
        case fullName = "full_name"
        case language
    }
}
