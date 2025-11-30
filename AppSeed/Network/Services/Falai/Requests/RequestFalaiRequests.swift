//
//  RequestFalaiRequests.swift
//  AppSeed
//
//  Created by tunay alver on 30.11.2025.
//

import Alamofire

struct RequestFalaiRequests: RequestGPTProtocol {
    // MARK: - Properties
    var baseUrl: String { BaseUrl.falai.rawValue }
    var path: String {
        switch kind {
        case .response:
            return GPTModel.falai_nano_banana_requests.rawValue + "/\(requestID)"
        case .status:
            return GPTModel.falai_nano_banana_requests.rawValue + "/\(requestID)/status"
        }
    }
    var gptModel: GPTModel = .falai_nano_banana_requests
    var method: HTTPMethod = .get
    var parameters: Parameters?
    var headers: HTTPHeaders?
    var encodingType: ParameterEncoding = URLEncoding.default
    var showLoading: Bool = false
    
    private let requestID: String
    private let kind: FalaiRequestKind
    
    // MARK: - Init
    init(requestID: String, kind: FalaiRequestKind) {
        self.requestID = requestID
        self.kind = kind
        
        let token = KeychainHelper.shared.read(key: .falaiKey) ?? ""
        self.headers = [
            "Authorization": "Key \(token)",
            "Content-Type": "application/json"
        ]
        
        self.parameters = nil
    }
}

extension RequestFalaiRequests {
    enum FalaiRequestKind {
        case response
        case status
    }
}
