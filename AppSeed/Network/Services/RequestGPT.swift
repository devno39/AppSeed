//
//  RequestGPT.swift
//  AppSeed
//
//  Created by tunay alver on 11.01.2025.
//

import Alamofire

struct RequestGPT: RequestGPTProtocol {
    // MARK: - Properties
    var baseUrl: String { BaseUrl.gpt.rawValue }
    var path: String { gptModel.rawValue }
    var gptModel: GPTModel = .chat
    var method: HTTPMethod
    var parameters: Parameters?
    var headers: HTTPHeaders?
    var encodingType: ParameterEncoding
    var showLoading: Bool = true
    
    // MARK: - Init
    init(message: String, role: String, method: HTTPMethod = .post) {
        self.method = method
        self.encodingType = (method == .get) ? URLEncoding.default : JSONEncoding.default
        // Headers
        self.headers = makeHeaders()
        // Prompt & model
        let plan = IAPHelper.shared.userPlan
        let fullMessage = preparePrompt(for: plan, message: message)
        let model = resolveModel(for: plan)
        
        // Parameters
        self.parameters = makeParameters(
            model: model,
            role: role,
            message: fullMessage,
            maxTokens: plan.gptMaxTokens,
            temperature: 0.5,
            topP: 1.0
        )
    }
}

// MARK: - Builders
private extension RequestGPT {
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
        model: String,
        role: String,
        message: String,
        maxTokens: Int,
        temperature: Double,
        topP: Double
    ) -> Parameters {
        let messages: [[String: String]] = [
            ["role": "system", "content": role],
            ["role": "user",   "content": message]
        ]
        
        return [
            "model": model,
            "messages": messages,
            "max_tokens": maxTokens,
            "temperature": temperature,
            "top_p": topP
        ]
    }
    
    func resolveModel(for plan: UserPlan) -> String {
        let key: RemoteConfigHelper.RemoteConfigKeys = (plan == .free) ? .gpt_model_free : .gpt_model_premium
        return RemoteConfigCacher.shared.getCached(key: key, as: String.self) ?? "gpt-4o"
    }
    
    func preparePrompt(for plan: UserPlan, message: String) -> String {
        let langCode = message.detectLanguage() ?? "tr"
        let languageName = langCode.displayNameForLanguage()
        let languageNote = String(format: Localizable.gpt_prompt_language, languageName)
        let reminder = Localizable.gpt_prompt_finalReminder
        let jsonFormat = Localizable.gpt_prompt_jsonFormat
        let more = ""
        
        switch plan {
        case .free, .monthly, .yearly:
            return """
            \(languageNote)
            \(more)
            \(message)
            \(reminder)
            \(jsonFormat)
            """
        }
    }
}
