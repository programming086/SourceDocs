//
//  SwiftDocDictionary.swift
//  sourcekitten
//
//  Created by Eneko Alonso on 10/3/17.
//

import Foundation
import SourceKittenFramework
import MarkdownGenerator

typealias SwiftDocDictionary = [String: Any]

extension Dictionary where Key == String, Value == Any {
    func get<T>(_ key: SwiftDocKey) -> T? {
        return self[key.rawValue] as? T
    }

    var hasPublicACL: Bool {
        return self["key.accessibility"] as? String == "source.lang.swift.accessibility.public" ||
            self["key.accessibility"] as? String == "source.lang.swift.accessibility.open"
    }

    func isKind(_ kind: SwiftDeclarationKind) -> Bool {
        return SwiftDeclarationKind(rawValue: get(.kind) ?? "") == kind
    }

    func isKind(_ kinds: [SwiftDeclarationKind]) -> Bool {
        guard let value: String = get(.kind), let kind = SwiftDeclarationKind(rawValue: value) else {
            return false
        }
        return kinds.contains(kind)
    }
}

protocol SwiftDocDictionaryInitializable {
    var dictionary: SwiftDocDictionary { get }

    init?(dictionary: SwiftDocDictionary)
}

extension SwiftDocDictionaryInitializable {
    var name: String {
        return dictionary.get(.name) ?? "[NO NAME]"
    }

    var comment: String {
        let abstract = dictionary.get(.docAbstract) ?? ""
        // TODO fix this
        let discussion: [String: SourceKitRepresentable]? = dictionary.get(.docDiscussion)
        guard let comments = discussion?.compactMap({ return $0.key == "Para" ? $0.value as? String : nil }), !comments.isEmpty else {
            return abstract
        }
        return abstract + "\n" + comments.joined(separator: "\n")
    }

    // TODO
    var comments: String  {
        return "TODO"
    }

    var declaration: String {
        guard let declaration: String = dictionary.get(.docDeclaration) else {
            return ""
        }
        return MarkdownCodeBlock(code: declaration, style: .backticks(language: "swift")).markdown
    }

    func collectionOutput(title: String, collection: [MarkdownConvertible]) -> String {
        return collection.isEmpty ? "" : """
        \(title)
        \(collection.markdown)
        """
    }
}
