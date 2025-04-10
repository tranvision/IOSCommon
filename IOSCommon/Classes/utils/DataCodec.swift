//
//  DataCodec.swift
//  IOSCommon
//
//  Created by Tanglei on 2024/9/11.
//

import Foundation

fileprivate let TAG = "DataCodec"

public struct AnyDecodable: Decodable {
    public let value: Any

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else {
            // Handle other types as needed
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type")
        }
    }
}

public struct NSObjectDecodable: Decodable {
    public let value: NSObject

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            value = NSNumber(value: Int32(intValue))
        } else if let doubleValue = try? container.decode(Double.self) {
            value = NSNumber(value: doubleValue)
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue as NSString
        } else if let boolValue = try? container.decode(Bool.self) {
            value = NSNumber(value: boolValue)
        } else {
            // Handle other types as needed
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type")
        }
    }
}

public struct AnyEncodable: Encodable {
    let value: Any
    
    public init(_ value: Any) {
        self.value = value
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let intValue = value as? Int {
            try container.encode(intValue)
        } else if let floatVal = value as? Float {
            try container.encode(floatVal)
        } else if let doubleVal = value as? Double {
            try container.encode(doubleVal)
        } else if let boolVal = value as? Bool {
            try container.encode(boolVal)
        } else if let stringValue = value as? String {
            try container.encode(stringValue)
        } else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
}

public class DataCodec {
    public static func dict2jstr(_ map: [String: Any])-> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: map, options: .withoutEscapingSlashes)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                //return jsonString.replacingOccurrences(of: "\\\"", with: "\"")
                return jsonString
            }
        } catch {
            LogUtil.e(tag: TAG, "Error encoding JSON: \(error)")
        }
        return ""
    }
}
