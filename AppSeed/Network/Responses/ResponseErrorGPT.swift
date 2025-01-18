//
//  ResponseErrorGPT.swift
//  AppSeed
//
//  Created by tunay alver on 18.01.2025.
//

public struct ResponseErrorGPT: Codable {
    let error: Detail?
    
    struct Detail: Codable {
        let message: String?
        let type: String?
        let param: String?
        let code: String?
        
        init(message: String?, type: String? = nil, param: String? = nil, code: String? = nil) {
            self.message = message
            self.type = type
            self.param = param
            self.code = code
        }
    }
}
