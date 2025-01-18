//
//  RequestGPT.swift
//  AppSeed
//
//  Created by tunay alver on 11.01.2025.
//

import Alamofire

struct RequestGPT: RequestGPTProtocol {
    // MARK: - System
    var model = "gpt-4"
    var systemMessage: RequestGPTSystemMessage
    
    // MARK: - Properties
    var path: String { gptModel.rawValue }
    var gptModel: GPTModel = .chat
    var method: HTTPMethod
    var parameters: Parameters?
    var headers: HTTPHeaders?
    var encodingType: ParameterEncoding
    
    // MARK: - Init
    init(userMessage: String, systemMessage: RequestGPTSystemMessage = .empty, method: HTTPMethod = .post) {
        self.method = method
        self.systemMessage = systemMessage
        self.encodingType = method == .get ? URLEncoding.default : JSONEncoding.default
        
        self.headers = [
            "Authorization": "Bearer \(RequestManager.apiKey)",
            "Content-Type": "application/json"
        ]
        self.parameters = [
            "model": model,
            "messages": [
                ["role": "system", "content": systemMessage.rawValue],
                ["role": "user", "content": userMessage]
            ],
            "max_tokens": 100
        ]
    }
}
