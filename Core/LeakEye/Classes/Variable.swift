//
//  Variable.swift
//  Pods
//
//  Created by zixun on 16/12/12.
//
//

import Foundation

//--------------------------------------------------------------------------
// MARK: - Variable
// DESCRIPTION: light wrap of the property of runtime
//--------------------------------------------------------------------------
class Variable: NSObject {
    
    init(property: objc_property_t) {
        self.property = property
        super.init()
    }
    
    //--------------------------------------------------------------------------
    // MARK: INTERNAL FUNCTION
    //--------------------------------------------------------------------------
    
    /// is a strong property
    func isStrong() -> Bool {
        attr.contains("&")
    }
    
    /// name of the property
    func name() -> String {
        String(cString: property_getName(property))
    }
    
    /// type of the property
    func type() -> AnyClass? {
        let t = attr.components(separatedBy: ",").first
        guard let type = t?.between("@\"", "\"") else { return nil }
        return NSClassFromString(type)
    }
    //--------------------------------------------------------------------------
    // MARK: PRIVATE PROPERTY
    //--------------------------------------------------------------------------
    private let property: objc_property_t

    private var attr: String {
        property_getAttributes(property).map { String(cString: $0) } ?? ""
    }
}

