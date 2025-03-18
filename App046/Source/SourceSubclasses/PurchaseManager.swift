//
//  PurchaseManager.swift
//  AiKiss
//
//  Created by Владимир Кацап on 10.12.2024.
//

import Foundation
import StoreKit
import Combine
import ApphudSDK
import Alamofire

class PurchaseManager: NSObject {
    
    let paywallID = "main"
    let paywallID1 = "Tokens"
    var productsApphud: [ApphudProduct] = []
    var productsApphud1: [ApphudProduct] = []
    
    var hasUnlockedPro: Bool {
        return Apphud.hasPremiumAccess()
    }
    
    @MainActor
    func returnPrice(product: ApphudProduct) -> String {
        return product.skProduct?.price.stringValue ?? ""
    }

    @MainActor
    func returnPriceSign(product: ApphudProduct) -> String {
        return product.skProduct?.priceLocale.currencySymbol ?? ""
    }
    
    @MainActor
    func returnName(product: ApphudProduct) -> String {
        guard let subscriptionPeriod = product.skProduct?.subscriptionPeriod else { return "" }
        
        switch subscriptionPeriod.unit {
        case .day:
            return "Weekly"
        case .week:
            return "Weekly"
        case .month:
            return "Monthly"
        case .year:
            return "Yearly"
        @unknown default:
            return "Unknown"
        }
    }

    @MainActor
    func dateSubscribe() -> String {
        if let subscription = Apphud.subscription() {
            let expirationDate = subscription.expiresDate // Здесь используется напрямую

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM dd, yyyy"
            let formattedDate = dateFormatter.string(from: expirationDate)
            
            return "until \(formattedDate)"
        }
        
        return "No active subscription"
    }

    
    @MainActor func startPurchase(produst: ApphudProduct, escaping: @escaping(Bool) -> Void) {
        let selectedProduct = produst
        Apphud.purchase(selectedProduct) { result in
            if let error = result.error {
                debugPrint("Ошибка покупки: \(error.localizedDescription)")
                escaping(false)
            } else if result.success {
                if let nonRenewingPurchase = result.nonRenewingPurchase {
                    debugPrint("покупка успешна: \(nonRenewingPurchase.productId)")
                    escaping(true)
                } else {
                    debugPrint("Покупка успешна, но покупка не обнаружена")
                    escaping(false)
                }
            } else {
                debugPrint("Покупка не прошла")
                escaping(false)
            }
        }
    }
    


    
    @MainActor
    func loadPaywalls(escaping: @escaping() -> Void) {

        Apphud.paywallsDidLoadCallback { paywalls, arg in
           
            if let paywall = paywalls.first(where: { $0.identifier == self.paywallID}) {
                Apphud.paywallShown(paywall)
                
                let products = paywall.products
                self.productsApphud = products
                
                print(products, "Proddd")
                for i in products {
                    print(i.productId, "ID")
                }
                escaping()
            }
        }
    }
    
    @MainActor
    func loadPaywalls1(escaping: @escaping() -> Void) {
        Apphud.paywallsDidLoadCallback { paywalls, arg in
            if let paywall = paywalls.first(where: { $0.identifier == self.paywallID1}) {
                Apphud.paywallShown(paywall)
                
                let products = paywall.products
                self.productsApphud1 = products
                
                print(products, "Proddd")
                for i in products {
                    print(i.productId, "ID")
                }
                escaping()
            }
        }
    }
    
    
    @MainActor func restorePurchase(escaping: @escaping(Bool) -> Void) {
        print("restore")
        Apphud.restorePurchases {  subscriptions, _, error in
            if let error = error {
                debugPrint(error.localizedDescription)
                escaping(false)
                return
            }
            if subscriptions?.first?.isActive() ?? false {
                escaping(true)
                return
            }
            
            if Apphud.hasActiveSubscription() {
                escaping(true)
                return
            }
            
            escaping(false)
        }
    }
    
}
