//
//  RequestReplicate.swift
//  AppSeed
//
//  Created by tunay alver on 30.08.2025.
//

import Alamofire

import Alamofire

struct RequestReplicate: RequestGPTProtocol {
    // MARK: - Properties
    var baseUrl: String { BaseUrl.replicate.rawValue }
    var path: String { gptModel.rawValue }
    var gptModel: GPTModel = .flux_schnell
    var method: HTTPMethod = .post
    var parameters: Parameters?
    var headers: HTTPHeaders?
    var encodingType: ParameterEncoding = JSONEncoding.default
    var showLoading: Bool = false
    
    // MARK: - Init
    init(elements: [String]? = nil, prompt: String? = nil) {
        let prompt = preparePrompt(elements: elements, prompt: prompt)
        self.headers = makeHeaders()
        self.parameters = makeParameters(prompt: prompt)
        log(.info, .network, "Replicate Prompt: \(prompt)")
    }
}

// MARK: - Builders
private extension RequestReplicate {
    func makeHeaders() -> HTTPHeaders {
        let token = KeychainHelper.shared.read(key: .replicateKey) ?? ""
        let headers = HTTPHeaders([
            "Authorization": "Token \(token)",
            "Content-Type": "application/json",
            "Prefer": "wait"
        ])
        return headers
    }
    
    func makeParameters(prompt: String) -> Parameters {
        [
            "input": [
                "prompt": prompt,
                "go_fast": true,
                "megapixels": "1",
                "num_outputs": 1,
                "aspect_ratio": "1:1",
                "output_format": "webp",
                "output_quality": 80,
                "num_inference_steps": 4
            ]
        ]
    }
    
    func preparePrompt(elements: [String]? = nil, prompt: String? = nil) -> String {
        var final = ""
        if elements.isNotEmpty {
            let keywords = (elements?.joined(separator: ", "))?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            final = String(format: Localizable.dalle_prompt_general, keywords)
        } else if let prompt {
            final = prompt
        } else {
            log(.warning, .network, "You forgot adding prompt or elements for Replicate")
        }
        return final
    }
}
