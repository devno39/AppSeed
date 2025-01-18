//
//  RequestDALLE.swift
//  AppSeed
//
//  Created by tunay alver on 11.01.2025.
//

import Alamofire

struct RequestDALLE: RequestGPTProtocol {
    // MARK: - Properties
    var path: String { GPTModel.dalle.rawValue }
    var gptModel: GPTModel = .dalle
    var method: HTTPMethod = .post
    var parameters: Parameters?
    var headers: HTTPHeaders?
    var encodingType: ParameterEncoding = JSONEncoding.default

    // MARK: - Init
    init(prompt: String) {
        self.headers = [
            "Authorization": "Bearer \(RequestManager.apiKey)",
            "Content-Type": "application/json"
        ]
        self.parameters = [
            "prompt": prompt,
            "n": 1,
            "size": "256x256"
        ]
    }
}
