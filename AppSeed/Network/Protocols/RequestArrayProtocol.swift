//
//  RequestArrayProtocol.swift
//  AppSeed
//
//  Created by tunay alver on 11.01.2025.
//

import Foundation

protocol RequestArrayProtocol: RequestProtocol {
    associatedtype ResultObject: Codable
}

extension RequestArrayProtocol {
    func request(success: @escaping CodableArrayClosure<[ResultObject]>, failure: ResponseErrorClosure? = nil) {
        RequestManager.request(self, success: success, failure: failure)
    }
}
