import XCResultKit

struct LogStoreManifest: Decodable {
    var dict: RootDict

    var lastXCResultFileName: String {
        dict.dict.dicts.last!.strings.first(where: { $0.hasSuffix(".xcresult") })!
    }
}

struct RootDict: Decodable {
    var dict: LogsDict
}

struct LogsDict: Decodable {
    var dicts: [LogDict]

    enum CodingKeys: String, CodingKey {
        case dicts = "dict"
    }
}

struct LogDict: Decodable {
    var strings: [String]

    enum CodingKeys: String, CodingKey {
        case strings = "string"
    }
}
