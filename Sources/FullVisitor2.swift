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
class FullVisitor: SyntaxVisitor {
    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        print("Struct:", node.name.text)
        return .visitChildren
    }
    
    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        print("Class:", node.name.text)
        return .visitChildren
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        print("Enum:", node.name.text)
        return .visitChildren
    }

    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        print("Protocol:", node.name.text)
        return .visitChildren
    }

//    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
//        print("Function:", node.name.text)
//        return .visitChildren
//    }

    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        print("Var:", node.bindings)
        return .visitChildren
    }
    
    
    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        print("────────────────────────────────────────")
        print("Function Name:", node.name.text)

        // 1️⃣ Parameters
        let params = node.signature.parameterClause.parameters.map { param -> String in
            let name = param.firstName.text
            let type = param.type.description.trimmingCharacters(in: .whitespacesAndNewlines)
            return "\(name): \(type)"
        }
        print("Parameters:", params.joined(separator: ", "))

        // 2️⃣ Return Type
        if let returnClause = node.signature.returnClause {
            let returnType = returnClause.type.description.trimmingCharacters(in: .whitespacesAndNewlines)
            print("Return Type:", returnType)
        } else {
            print("Return Type: Void")
        }

        // 3️⃣ Attributes (optional)
        if !node.attributes.isEmpty {
            print("Attributes:", node.attributes.description.trimmingCharacters(in: .whitespacesAndNewlines))
        }

        // 4️⃣ Generic parameters (optional)
        if let generics = node.genericParameterClause {
            print("Generics:", generics.description.trimmingCharacters(in: .whitespacesAndNewlines))
        }

        // 5️⃣ Body (statements inside function)
        if let body = node.body {
            let bodyText = body.statements
                .map { $0.description.trimmingCharacters(in: .whitespacesAndNewlines) }
                .joined(separator: "\n")
            print("Body:\n\(bodyText)")
        } else {
            print("No Body Found (maybe protocol requirement?)")
        }

        print("────────────────────────────────────────")
        return .skipChildren   // avoid re-entering the body
    }

}

struct FunctionInfo {
    let name: String
    var calls: [String]
}

class CallCollector: SyntaxVisitor {
    var calls: [String] = []

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        if let name = node.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text {
            calls.append(name)
        }
        return .visitChildren
    }
}

class GraphBuilderVisitor: SyntaxVisitor {
    // 🔥 STORE RESULTS HERE (no globals!)
    var functions: [String: FunctionInfo] = [:]

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        let functionName = node.name.text

        var callList: [String] = []

        if let body = node.body {
            let collector = CallCollector(viewMode: .sourceAccurate)
            collector.walk(body)
            callList = collector.calls
        }

        functions[functionName] = FunctionInfo(name: functionName, calls: callList)

        return .skipChildren
    }
}
