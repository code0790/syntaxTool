//
//  FullVisitor2.swift
//  syntaxTool
//
//  Created by navpreet on 07-12-2025.
//

import ArgumentParser
import Foundation
import SwiftSyntax
import SwiftParser

// MARK: - Visitor
final class FullVisitor: SyntaxVisitor {

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        print("Class: \(node.name.text)")
        return .visitChildren
    }

    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        if let binding = node.bindings.first {
            print("Property: \(binding.pattern.description.trimmingCharacters(in: .whitespacesAndNewlines))")
        }
        return .skipChildren
    }

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        print("Method: \(node.name.text)")
        return .visitChildren
    }
}
