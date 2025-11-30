//
//  RequestFalaiQueue.swift
//  AppSeed
//
//  Created by tunay alver on 30.11.2025.
//

import Alamofire

struct RequestFalaiQueue: RequestGPTProtocol {
    // MARK: - Properties
    var baseUrl: String { BaseUrl.falai.rawValue }
    var path: String { GPTModel.falai_nano_banana.rawValue }
    var gptModel: GPTModel = .falai_nano_banana
    var method: HTTPMethod = .post
    var parameters: Parameters?
    var headers: HTTPHeaders?
    var encodingType: ParameterEncoding = JSONEncoding.default
    var showLoading: Bool = false

    // MARK: - Init
    init(mainElements: [String]?) {
        let finalPrompt = Self.preparePrompt(mainElements: mainElements)
        let token = KeychainHelper.shared.read(key: .falaiKey) ?? ""
        self.headers = [
            "Authorization": "Key \(token)",
            "Content-Type": "application/json"
        ]

        self.parameters = [
            "prompt": finalPrompt,
            "image_size": [
                "width": 1024,
                "height": 1024
            ]
        ]
    }

    // MARK: - Prompt Builder
    private static func preparePrompt(mainElements: [String]?) -> String {
        // TODO: - Prepare prompt here
        let payload = ""
        let final = ""
        if let jsonString = payload.encodeToString() {
            log(.info, .network, "Fal.ai Payload JSON: \(payload)")
            debugPrint("🧾 Fal.ai Payload JSON:", jsonString)
        }
        
        log(.info, .network, "Fal.ai Prompt: \(final)")
        return final
    }
}
