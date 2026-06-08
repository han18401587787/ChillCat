//
//  CCAPIClient.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

protocol CCAPIClientProtocol {
    func request<T: Decodable>(_ endpoint: CCAPIEndpoint) async throws -> T
    func request(_ endpoint: CCAPIEndpoint) async throws -> Data
    func upload<T: Decodable>(_ endpoint: CCAPIEndpoint, data: Data) async throws -> T
    func download(_ endpoint: CCAPIEndpoint, to url: URL) async throws -> URL
}

final class CCAPIClient: CCAPIClientProtocol {
    private let session: URLSession
    private let interceptor: CCRequestInterceptor?
    private let decoder: JSONDecoder
    private let logger: CCNetworkLogger?

    /// 创建带有 SSL Pinning 的 URLSession
    static func makeSession(pinnedHashes: Set<String>) -> URLSession {
        guard !pinnedHashes.isEmpty else { return .shared }
        let delegate = CCSSLPinningDelegate(pinnedHashes: pinnedHashes)
        return URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
    }

    init(
        session: URLSession = .shared,
        interceptor: CCRequestInterceptor? = nil,
        decoder: JSONDecoder = JSONDecoder(),
        logger: CCNetworkLogger? = CCNetworkLogger()
    ) {
        self.session = session
        self.interceptor = interceptor
        self.decoder = decoder
        self.logger = logger

        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
    }

    func request<T: Decodable>(_ endpoint: CCAPIEndpoint) async throws -> T {
        let data = try await request(endpoint)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            logger?.logError(error, request: (try? buildRequest(from: endpoint)) ?? URLRequest(url: endpoint.baseURL))
            throw CCAPIError.decodingFailure(error)
        }
    }

    func request(_ endpoint: CCAPIEndpoint) async throws -> Data {
        var request = try buildRequest(from: endpoint)

        request = try await interceptor?.intercept(request) ?? request

        logger?.logRequest(request)

        let (data, response): (Data, URLResponse)

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            logger?.logError(error, request: request)
            throw CCAPIError.networkFailure(error)
        }

        logger?.logResponse(response, data: data)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CCAPIError.invalidResponse
        }

        try validateResponse(httpResponse)

        try await interceptor?.handle(response: httpResponse, data: data)

        return data
    }

    func upload<T: Decodable>(_ endpoint: CCAPIEndpoint, data: Data) async throws -> T {
        var request = try buildRequest(from: endpoint)
        request.httpBody = data
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")

        request = try await interceptor?.intercept(request) ?? request

        let (responseData, response) = try await session.upload(for: request, from: data)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CCAPIError.invalidResponse
        }
        try validateResponse(httpResponse)

        return try decoder.decode(T.self, from: responseData)
    }

    func download(_ endpoint: CCAPIEndpoint, to url: URL) async throws -> URL {
        var request = try buildRequest(from: endpoint)
        request = try await interceptor?.intercept(request) ?? request

        let (tempURL, response) = try await session.download(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CCAPIError.invalidResponse
        }
        try validateResponse(httpResponse)

        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
        try FileManager.default.moveItem(at: tempURL, to: url)

        return url
    }

    // MARK: - Private

    private func buildRequest(from endpoint: CCAPIEndpoint) throws -> URLRequest {
        var components = URLComponents(
            url: endpoint.baseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: false
        )

        if let queryParameters = endpoint.queryParameters {
            components?.queryItems = queryParameters.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }

        guard let url = components?.url else {
            throw CCAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = endpoint.timeout
        request.cachePolicy = endpoint.cachePolicy
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if endpoint.body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        endpoint.headers?.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }

        if let body = endpoint.body {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(CCAnyEncodable(body))
        }

        return request
    }

    private func validateResponse(_ response: HTTPURLResponse) throws {
        switch response.statusCode {
        case 200...299:
            return
        case 301, 302, 307, 308:
            throw CCAPIError.redirection(response.statusCode)
        case 400:
            throw CCAPIError.badRequest
        case 401:
            throw CCAPIError.unauthorized
        case 403:
            throw CCAPIError.forbidden
        case 404:
            throw CCAPIError.notFound
        case 409:
            throw CCAPIError.conflict
        case 422:
            throw CCAPIError.unprocessableEntity
        case 429:
            throw CCAPIError.tooManyRequests
        case 500...599:
            throw CCAPIError.serverError(response.statusCode)
        default:
            throw CCAPIError.unexpectedStatusCode(response.statusCode)
        }
    }
}

// MARK: - AnyEncodable

struct CCAnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    init(_ wrapped: Encodable) {
        _encode = { encoder in
            try wrapped.encode(to: encoder)
        }
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
