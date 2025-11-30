//
//  RequestDALLE.swift
//  AppSeed
//
//  Created by tunay alver on 11.01.2025.
//

import Alamofire

struct RequestDALLE: RequestGPTProtocol {
    // MARK: - Properties
    var baseUrl: String { BaseUrl.gpt.rawValue }
    var path: String { gptModel.rawValue }
    var gptModel: GPTModel = .dalle
    var method: HTTPMethod = .post
    var parameters: Parameters?
    var headers: HTTPHeaders?
    var encodingType: ParameterEncoding = JSONEncoding.default
    var showLoading: Bool = false

    private static let projectId: String? = ""

    // MARK: - Init
    init(elements: [String]? = nil, prompt: String? = nil) {
        self.headers = makeHeaders()
        let prompt = preparePrompt(elements: elements, prompt: prompt)
        self.parameters = makeParameters(prompt: prompt)
        log(.info, .network, "Dalle Prompt: \(prompt)")
    }
}

// MARK: - Builders
private extension RequestDALLE {
    func makeHeaders() -> HTTPHeaders {
        let apiKey = KeychainHelper.shared.read(key: .gptKey) ?? ""
        let projectId: String = ""
        let headers: [String: String] = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json",
            "OpenAI-Project": "\(projectId)"
        ]
        return HTTPHeaders(headers)
    }

    func makeParameters(
        prompt: String,
        n: Int = 1,
        size: String = "1024x1024",
        quality: String = "high",
        style: String = "natural",
        responseFormat: String? = nil // "b64_json" | "url"
    ) -> Parameters {
        var params: [String: Any] = [
            "prompt": prompt,
            "n": n,
            "size": size,
            "quality": quality,
            "style": style
        ]
        if let responseFormat { params["response_format"] = responseFormat }
        return params
    }

    func preparePrompt(elements: [String]? = nil, prompt: String? = nil) -> String {
        var final = ""
        if elements.isNotEmpty {
            let keywords = (elements?.joined(separator: ", "))?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            final = String(format: Localizable.dalle_prompt_general, keywords)
        } else if let prompt {
            final = prompt
        } else {
            log(.warning, .network, "You forgot adding prompt or elements for Dalle")
        }
        return final
    }
}
