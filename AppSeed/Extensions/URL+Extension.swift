//
//  URL+Extension.swift
//  AppSeed
//
//  Created by tunay alver on 11.01.2025.
//

import Foundation

// QueryParameters lives in the Network layer (Network/Protocols/QueryParameters.swift)

extension URL {
    var queryParameters: QueryParameters { return QueryParameters(url: self) }
}
