//
//  Target+Plist.swift
//
//
//  Created by Yume on 2022/8/27.
//

import Foundation
import PathKit
import RuleBuilder
import XCode

/// plist_file
extension Target {
    // MARK: Internal

    var plist_file: String? {
        if let _ = plistContent {
            return ":plist_file"
        }
        return nil
    }


    func generatePlistFile(_ builder: inout Build.Builder, _: Kit) {
        builder.load(loadableRule: RulesPlist.plist_fragment)
        if let plist = plistContent {
            builder.add(RulesPlist.plist_fragment.rawValue) {
                "name" => "plist_file"
                "extension" => "plist"
                "template" => Starlark.custom("""
                '''
                \(plist)
                '''
                """)
                StarlarkProperty.Visibility.private
            }
        }
    }

    // MARK: Private

    private var plistContent: String? {
        if let plistPath = prefer(\.infoPlist) {
            let path: Path = project.workspacePath + plistPath
            return try? path.read()
        } else {
            return nil
        }
    }
}

/// plist_auto
extension Target {
    // MARK: Internal

    var plist_auto: String? {
        isGeneratePlistAuto ? ":plist_auto" : nil
    }

    func generatePlistAuto(_ builder: inout Build.Builder) {
        builder.load(loadableRule: RulesPlist.plist_fragment)
        if isGeneratePlistAuto {
            let plist = prefer(\.plist) ?? []
            builder.add(RulesPlist.plist_fragment.rawValue) {
                "name" => "plist_auto"
                "extension" => "plist"
                "template" => Starlark.custom("""
                '''
                \(plist.withNewLine)
                '''
                """)
                StarlarkProperty.Visibility.private
            }
        }
    }

    // MARK: Private

    private var isGeneratePlistAuto: Bool {
        let isAutoGen = prefer(\.generateInfoPlist) ?? false
        let isEmptyPlist = (prefer(\.plist) ?? []).isEmpty
        return isAutoGen && !isEmptyPlist
    }
}


/// plist_default
extension Target {
    // MARK: Internal

    var plist_default: String? {
        isGeneratePlistDefault ? ":plist_default" : nil
    }

    func generatePlistDefault(_ builder: inout Build.Builder) {
        if isGeneratePlistDefault {
            builder.load(loadableRule: RulesPlist.plist_fragment)
            let plist = prefer(\.defaultPlist) ?? []
            builder.add(RulesPlist.plist_fragment.rawValue) {
                "name" => "plist_default"
                "extension" => "plist"
                "template" => Starlark.custom("""
                '''
                \(plist.withNewLine)
                '''
                """)
                StarlarkProperty.Visibility.private
            }
        }
    }

    // MARK: Private

    private var isGeneratePlistDefault: Bool {
        let plist = prefer(\.defaultPlist) ?? []
        return !plist.isEmpty
    }
}
