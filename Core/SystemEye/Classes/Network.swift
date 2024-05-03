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
    public static var carrierName: String? {
        get {
            carrier?.carrierName
        }
    }
    
    /// mobile carrier country
    public static var carrierCountry: String? {
        get {
            let currentCountry = Locale.current as NSLocale
            return currentCountry.object(forKey: NSLocale.Key.countryCode) as? String
        }
    }
    
    /// mobile carrier country code
    public static var carrierMobileCountryCode: String? {
        get {
            carrier?.mobileCountryCode
        }
    }
    
    /// get the carrier iso country code
    public static var carrierISOCountryCode: String? {
        get {
            carrier?.isoCountryCode
        }
    }
    /// get the carrier mobile network code
    public static var carrierMobileNetworkCode: String? {
        get {
            carrier?.mobileNetworkCode
        }
    }
    
    public static var carrierAllowVOIP: Bool {
        get {
            carrier?.allowsVOIP ?? false
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: WIFI
    //--------------------------------------------------------------------------
    
    public static var isConnectedToWifi: Bool {
        get {
            guard let address = wifiIPAddress, address.count <= 0 else { return false }
            return true
        }
    }
    
    public static var wifiIPAddress: String? {
        get {
           NetObjc.wifiIPAddress()
        }
    }
    
    public static var wifiNetmaskAddress: String? {
        get {
            NetObjc.wifiNetmaskAddress()
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: CELL
    //--------------------------------------------------------------------------
    
    public static var isConnectedToCell: Bool {
        get {
            guard let address = cellIPAddress, address.count <= 0 else { return false }
            return true
        }
    }
    
    public static var cellIPAddress: String? {
        get {
            NetObjc.cellIPAddress()
        }
    }
    
    public static var cellNetmaskAddress: String? {
        get {
            NetObjc.cellNetmaskAddress()
        }
    }
    //--------------------------------------------------------------------------
    // MARK: NETWORK FLOW
    //--------------------------------------------------------------------------
    public static func flow() -> (wifiSend: UInt32,
                            wifiReceived: UInt32,
                                wwanSend: UInt32,
                            wwanReceived: UInt32) {
        let flow = NetObjc.flow()
        return (flow.wifiSend, flow.wifiReceived, flow.wwanSend, flow.wwanReceived)
    }
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE PROPERTY
    //--------------------------------------------------------------------------
    private static var carrier: CTCarrier? {
        get {
            CTTelephonyNetworkInfo().subscriberCellularProvider
        }
    }
    
}
