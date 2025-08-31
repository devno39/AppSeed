//
//  RequestObjectProtocol.swift
//  AppSeed
//
//  Created by tunay alver on 11.01.2025.
//

import Foundation

protocol RequestObjectProtocol: RequestProtocol {
    associatedtype ResultObject: Codable
}

extension RequestObjectProtocol {
    func request(success: @escaping CodableAnyClosure<ResultObject>, failure: ResponseErrorClosure? = nil) {
        RequestManager.request(self, success: success, failure: failure)
    }
}
