//
//  AppPaths.swift
//  Pods
//
//  Created by zixun on 16/9/24.
//
//

import Foundation

//AppPaths用来简化对app目录的检索，
//改写自Facebook大神jverkoey的Objective-C项目Nimbus 中的NIPaths
//(https://github.com/jverkoey/nimbus/blob/master/src/core/src/NIPaths.m)
//因语法关系有略微不同 并且增加了ApplicationSupportDirectory的检索

/**
 * Create a path with the given bundle and the relative path appended.
 *
 * @param bundle        The bundle to append relativePath to. If nil, [NSBundle mainBundle]
 *                           will be used.
 * @param relativePath  The relative path to append to the bundle's path.
 *
 * @returns The bundle path concatenated with the given relative path.
 */
func AppPathForBundleResource(bundle: Bundle?, relativePath: String) -> String {
    guard let resourcePath = (bundle == nil ? Bundle.main : bundle)?.resourcePath else { return "" }

    return (resourcePath as NSString).appendingPathComponent(relativePath)
}

/**
 * Create a path with the documents directory and the relative path appended.
 *
 * @returns The documents path concatenated with the given relative path.
 */
func AppPathForDocumentsResource(relativePath: String) -> String {
    documentsPath.appendingPathComponent(relativePath)
}

/**
 * Create a path with the Library directory and the relative path appended.
 *
 * @returns The Library path concatenated with the given relative path.
 */
func AppPathForLibraryResource(relativePath: String) -> String {
    libraryPath.appendingPathComponent(relativePath)
}

/**
 * Create a path with the caches directory and the relative path appended.
 *
 * @returns The caches path concatenated with the given relative path.
 */
func AppPathForCachesResource(relativePath: String) -> String {
    cachesPath.appendingPathComponent(relativePath)
}


/**
 * Create a path with the ApplicationSupport directory and the relative path appended.
 *
 * @returns The caches path concatenated with the given relative path.
 */
func AppPathForApplicationSupportResource(relativePath: String) -> String {
    applicationSupportPath.appendingPathComponent(relativePath)
}

/// 将document目录作为常量保存起来，提高访问性能
private let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                .userDomainMask,
                                                                true).first! as NSString

/// 将library目录作为常量保存起来，提高访问性能
private let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory,
                                                              .userDomainMask,
                                                              true).first! as NSString

/// 将caches目录作为常量保存起来，提高访问性能
private let cachesPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                             .userDomainMask,
                                                             true).first! as NSString

/// 将applicationSupport目录作为常量保存起来，提高访问性能
private let applicationSupportPath = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory,
                                                                         .userDomainMask,
                                                                         true).first! as NSString
