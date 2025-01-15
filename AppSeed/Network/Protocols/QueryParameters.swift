//
//  QueryParameters.swift
//  AppSeed
//
//  Created by tunay alver on 11.01.2025.
//

import Foundation

struct QueryParameters {
    // MARK: - Properties
    let queryItems: [URLQueryItem]
    
    //MARK: - Init
    init(url: URL?) {
        queryItems = URLComponents(string: url?.absoluteString ?? "")?.queryItems ?? []
    }
    
    subscript(name: String) -> String? {
        return queryItems.first(where: { $0.name == name })?.value
    }
}
