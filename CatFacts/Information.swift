//
//  Information.swift
//  CatFacts
//
//  Created by carl on 8/17/20.
//  Copyright © 2020 Catalyst Art. All rights reserved.
//

import Foundation
import UIKit

//
// system and device information gathering elements
//

class Information {

    //
    // Swift version of the Obj-C code used elsewhere
    // machineMirror magic to return a string
    //

    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }()


    //
    // from developer.apple.com
    //  https://developer.apple.com/forums/thread/64665
    //  should not be used in prodction code
    //  (thanks Quinn!)
    //
    class func mach_task_self() -> task_t {
        return mach_task_self_
    }

    class func megabytesUsed() -> String {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: info) / MemoryLayout<integer_t>.size)
        let kerr = withUnsafeMutablePointer(to: &info) { infoPtr in
            return infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { (machPtr: UnsafeMutablePointer<integer_t>) in
                return task_info(
                    mach_task_self(),
                    task_flavor_t(MACH_TASK_BASIC_INFO),
                    machPtr,
                    &count
                )
            }
        }
        guard kerr == KERN_SUCCESS else {
            return ""
        }
        return String(format: "%.3f MB", Float(info.resident_size) / (1024 * 1024) )
    }

    class func osVersion() -> String {
        return UIDevice.current.systemName + " " + UIDevice.current.systemVersion
    }

    class func appVersion() -> String {
        let info  = Bundle.main.infoDictionary
        let name  = info?["CFBundleName"] ?? "unknown"
        let short = info?["CFBundleShortVersionString"] ?? "1.0"
        let build = info?["CFBundleVersion"] ?? "0"
        return "\(name) \(short) (\(build))"
    }


}

