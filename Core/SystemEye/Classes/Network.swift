//
//  Network.swift
//  Pods
//
//  Created by zixun on 17/1/20.
//
//

import Foundation
import CoreTelephony

open class Network: NSObject {
    
    //--------------------------------------------------------------------------
    // MARK: OPEN PROPERTY
    //--------------------------------------------------------------------------
    
    //--------------------------------------------------------------------------
    // MARK: CTCarrier
    //--------------------------------------------------------------------------
    
    /// mobile carrier name
    static var carrierName: String? {
        get {
            carrier?.carrierName
        }
    }
    
    /// mobile carrier country
    static var carrierCountry: String? {
        get {
            let currentCountry = Locale.current as NSLocale
            return currentCountry.object(forKey: NSLocale.Key.countryCode) as? String
        }
    }
    
    /// mobile carrier country code
    static var carrierMobileCountryCode: String? {
        get {
            carrier?.mobileCountryCode
        }
    }
    
    /// get the carrier iso country code
    static var carrierISOCountryCode: String? {
        get {
            carrier?.isoCountryCode
        }
    }
    /// get the carrier mobile network code
    static var carrierMobileNetworkCode: String? {
        get {
            carrier?.mobileNetworkCode
        }
    }
    
    static var carrierAllowVOIP: Bool {
        get {
            carrier?.allowsVOIP ?? false
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: WIFI
    //--------------------------------------------------------------------------
    
    static var isConnectedToWifi: Bool {
        get {
            guard let address = wifiIPAddress, address.count <= 0 else { return false }
            return true
        }
    }
    
    static var wifiIPAddress: String? {
        get {
           NetObjc.wifiIPAddress()
        }
    }
    
    static var wifiNetmaskAddress: String? {
        get {
            NetObjc.wifiNetmaskAddress()
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: CELL
    //--------------------------------------------------------------------------
    
    static var isConnectedToCell: Bool {
        get {
            guard let address = cellIPAddress, address.count <= 0 else { return false }
            return true
        }
    }
    
    static var cellIPAddress: String? {
        get {
            NetObjc.cellIPAddress()
        }
    }
    
    static var cellNetmaskAddress: String? {
        get {
            NetObjc.cellNetmaskAddress()
        }
    }
    //--------------------------------------------------------------------------
    // MARK: NETWORK FLOW
    //--------------------------------------------------------------------------
    static func flow() -> (wifiSend: UInt64,
                            wifiReceived: UInt64,
                                wwanSend: UInt64,
                            wwanReceived: UInt64) {
        let flow = NetObjc.flow()
        return (flow.wifiSend, flow.wifiReceived, flow.wwanSend, flow.wwanReceived)
    }
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE PROPERTY
    //--------------------------------------------------------------------------
    static var carrier: CTCarrier? {
        get {
            CTTelephonyNetworkInfo().subscriberCellularProvider
        }
    }
    
}
