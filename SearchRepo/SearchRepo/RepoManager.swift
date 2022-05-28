//
//  RepoManager.swift
//  SearchRepo
//
//  Created by Sumit Joshi on 2022/05/26.
//

import Foundation

extension URL {
    static let searchRepoUrl = "https://api.github.com/search/repositories?"
    static let sortOrder = "&sort=stars&order=desc"
}

enum HTTPMethod: String {
    case GET
}

enum APIError: Error {
    case emptyBody
    case unexpectedResponseType
}

enum APIResult {
    case success(SearchResult)
    case failure(Error)
}

protocol Endpoint {
    var url: URL { get }
    var method: HTTPMethod { get }
    var query: String { get }
}

extension Endpoint {
    fileprivate var urlRequest: URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        return request
    }
}

class SearchRepo: Endpoint {
    var url: URL
    var method: HTTPMethod
    var query: String
    
    init(query: String) {
        guard let url = URL(string: URL.searchRepoUrl + "q=\(query)" + URL.sortOrder) else {
            fatalError("URL failed")
        }
        self.url = url
        self.method = .GET
        self.query = query
    }
    
    func request(callback: @escaping (APIResult) -> Void) {
        URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if let error = error {
                callback(.failure(error))
            } else if let data = data {
                let decoder = JSONDecoder()
                do {
                    guard let decodedData = try? decoder.decode(SearchResult.self, from: data) else {
                        throw APIError.unexpectedResponseType
                    }
                    callback(.success(decodedData))
                } catch {
                    callback(.failure(error))
                }
            } else {
                callback(.failure(APIError.emptyBody))
            }
        }).resume()
    }
}
