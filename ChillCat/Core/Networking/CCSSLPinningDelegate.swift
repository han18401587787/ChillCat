//
//  CCSSLPinningDelegate.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//

import Foundation
import CommonCrypto

final class CCSSLPinningDelegate: NSObject, URLSessionDelegate {

    /// SHA256 hashes of pinned certificates (Base64 encoded)
    private let pinnedHashes: Set<String>

    init(pinnedHashes: Set<String>) {
        self.pinnedHashes = pinnedHashes
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        // 仅在 Release 构建中强制校验，Debug 允许通过
        #if DEBUG
        completionHandler(.performDefaultHandling, nil)
        #else
        if validate(serverTrust: serverTrust) {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
        #endif
    }

    private func validate(serverTrust: SecTrust) -> Bool {
        // 获取服务器证书链
        guard let certificates = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
              let serverCert = certificates.first else {
            return false
        }

        let hash = sha256(of: serverCert)
        return pinnedHashes.contains(hash)
    }

    private func sha256(of certificate: SecCertificate) -> String {
        let data = SecCertificateCopyData(certificate) as Data
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { ptr in
            _ = CC_SHA256(ptr.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash).base64EncodedString()
    }
}

extension CCSSLPinningDelegate {
    /// 从环境配置加载固定的证书哈希
    static func fromEnvironment() -> CCSSLPinningDelegate {
        CCSSLPinningDelegate(pinnedHashes: CCAppEnvironment.current.pinnedCertHashes)
    }
}
