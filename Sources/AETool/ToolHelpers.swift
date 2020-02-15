/**
 *  https://github.com/tadija/AETool
 *  Copyright © 2020 Marko Tadić
 *  Licensed under the MIT license
 */

import Foundation

@dynamicMemberLookup
public protocol DynamicContent: CustomStringConvertible {
    var content: [String: Any] { get }
}

public extension DynamicContent {
    var description: String {
        content.description
    }

    subscript(dynamicMember key: String) -> Any? {
        content[key]
    }

    subscript(key: String) -> Any? {
        content[key]
    }
}

public struct FileConfig: DynamicContent {
    public let content: [String: Any]

    public init(_ filePath: String) {
        let fm = FileManager.default
        let path = fm.currentDirectoryPath.appending("/\(filePath)")
        let url = URL(fileURLWithPath: path)
        if
            fm.fileExists(atPath: path),
            let data = try? Data(contentsOf: url),
            let json = try? JSONSerialization
                .jsonObject(
                    with: data,
                    options: .allowFragments
                ) as? [String: Any] {
            content = json
        } else {
            content = [:]
        }
    }
}

public class ToolMemory: DynamicContent {
    public private(set) var content: [String: Any] = [:]

    public subscript(dynamicMember key: String) -> Any? {
        get { content[key] }
        set { content[key] = newValue }
    }

    public subscript(key: String) -> Any? {
        get { content[key] }
        set { content[key] = newValue }
    }
}

public enum ANSI {
    public enum Color: String {
        case black = "\u{001B}[0;30m"
        case red = "\u{001B}[0;31m"
        case green = "\u{001B}[0;32m"
        case yellow = "\u{001B}[0;33m"
        case blue = "\u{001B}[0;34m"
        case magenta = "\u{001B}[0;35m"
        case cyan = "\u{001B}[0;36m"
        case white = "\u{001B}[0;37m"
        case `default` = "\u{001B}[0;0m"
    }
}

extension String {
    func ansi(_ color: ANSI.Color) -> String {
        "\(self, color: color)"
    }

    func ansiStripped() -> String {
        guard starts(with: "\u{001B}") else {
            return self
        }
        let start = index(startIndex, offsetBy: 7)
        let end = index(endIndex, offsetBy: -6)
        return String(self[start..<end])
    }
}

private extension DefaultStringInterpolation {
    mutating func appendInterpolation<T: CustomStringConvertible>(_ value: T, color: ANSI.Color) {
        appendInterpolation("\(color.rawValue)\(value)\(ANSI.Color.default.rawValue)")
    }
}
