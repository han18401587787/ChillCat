//
//  CCMemberViewModel.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class CCMemberViewModel {
    var memberInfo: CCMemberInfo?
    var products: [CCMemberProduct] = []
    var privileges: [CCMemberPrivilege] = []
    var isLoading = false
    var errorMessage: String?
    var showConfirmSheet = false
    var showSuccessAlert = false
    var showFailureAlert = false
    var showLoadErrorAlert = false
    var selectedProduct: CCMemberProduct?
    private let orderTracker = CCOrderTrackingViewModel()

    private let fetchMemberInfoUseCase: CCFetchMemberInfoUseCase
    private let purchaseMemberUseCase: CCPurchaseMemberUseCase

    init(
        fetchMemberInfoUseCase: CCFetchMemberInfoUseCase,
        purchaseMemberUseCase: CCPurchaseMemberUseCase
    ) {
        self.fetchMemberInfoUseCase = fetchMemberInfoUseCase
        self.purchaseMemberUseCase = purchaseMemberUseCase
    }

    var isMember: Bool {
        memberInfo?.isValid ?? false
    }

    var statusDescription: String {
        memberInfo?.statusDescription ?? "开通会员享受更多权益"
    }

    var remainingText: String {
        guard let info = memberInfo else { return "" }
        if let days = info.remainingDays {
            return "剩余 \(days) 天"
        }
        return "永久有效"
    }

    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            memberInfo = try await fetchMemberInfoUseCase.execute()
        } catch {
            errorMessage = "会员信息加载失败"
            LogW("[Member] API failed: \(error)", module: .network, category: "Member")
        }
        products = CCMemberViewModel.defaultProducts()
        privileges = CCMemberViewModel.defaultPrivileges()

        isLoading = false
    }

    func requestPurchase(product: CCMemberProduct) {
        selectedProduct = product
        showConfirmSheet = true
    }

    func confirmPurchase() async {
        guard let product = selectedProduct else { return }
        let transaction = CCTransaction(
            productType: product.type,
            amount: product.price,
            status: .pending
        )
        orderTracker.addTransaction(transaction)
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let info = try await purchaseMemberUseCase.execute(product: product)
            memberInfo = info
            orderTracker.updateTransaction(id: transaction.id, status: .completed)
            showConfirmSheet = false
            showSuccessAlert = true
        } catch {
            errorMessage = error.localizedDescription
            orderTracker.updateTransaction(id: transaction.id, status: .failed)
            showConfirmSheet = false
            showFailureAlert = true
        }
    }

    static func defaultProducts() -> [CCMemberProduct] {
        [
            CCMemberProduct(id: "monthly", type: .monthly, price: 15, originalPrice: nil, displayPrice: "¥15.00", discountTag: nil),
            CCMemberProduct(id: "quarterly", type: .quarterly, price: 40, originalPrice: 45, displayPrice: "¥40.00", discountTag: "省¥5"),
            CCMemberProduct(id: "yearly", type: .yearly, price: 128, originalPrice: 180, displayPrice: "¥128.00", discountTag: "省¥52"),
            CCMemberProduct(id: "permanent", type: .permanent, price: 298, originalPrice: 398, displayPrice: "¥298.00", discountTag: "限时优惠")
        ]
    }

    static func defaultPrivileges() -> [CCMemberPrivilege] {
        [
            CCMemberPrivilege(id: "1", title: "高清画质", description: "享受1080P高清画质", iconName: "healing_scan", isHighlight: true, availableTypes: CCMemberType.allCases),
            CCMemberPrivilege(id: "2", title: "离线下载", description: "随时随地离线观看", iconName: "other_download", isHighlight: false, availableTypes: CCMemberType.allCases),
            CCMemberPrivilege(id: "3", title: "专属客服", description: "VIP专属客服通道", iconName: "profile_user", isHighlight: false, availableTypes: CCMemberType.allCases),
            CCMemberPrivilege(id: "4", title: "免广告", description: "畅享无广告体验", iconName: "common_close", isHighlight: true, availableTypes: CCMemberType.allCases),
            CCMemberPrivilege(id: "5", title: "专属标识", description: "尊贵VIP身份标识", iconName: "emotion_hopeful", isHighlight: false, availableTypes: CCMemberType.allCases),
            CCMemberPrivilege(id: "6", title: "提前观看", description: "抢先看最新内容", iconName: "common_more", isHighlight: false, availableTypes: CCMemberType.allCases)
        ]
    }
}
