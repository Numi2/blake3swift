import Foundation

public enum BLAKE3Error: Error, Equatable, CustomStringConvertible {
    case invalidKeyLength(expected: Int, actual: Int)
    case invalidOutputLength(Int)
    case fileOpenFailed(String)
    case fileStatFailed(String)
    case fileReadFailed(String)
    case memoryMapFailed(String)
    case metalUnavailable
    case metalCommandFailed(String)
    case invalidBufferRange

    public var description: String {
        switch self {
        case let .invalidKeyLength(expected, actual):
            return "BLAKE3 keys must be \(expected) bytes, got \(actual)."
        case let .invalidOutputLength(length):
            return "BLAKE3 output length must be non-negative, got \(length)."
        case let .fileOpenFailed(path):
            return "Unable to open file: \(path)"
        case let .fileStatFailed(path):
            return "Unable to stat file: \(path)"
        case let .fileReadFailed(path):
            return "Unable to read file: \(path)"
        case let .memoryMapFailed(path):
            return "Unable to memory-map file: \(path)"
        case .metalUnavailable:
            return "Metal is not available on this machine."
        case let .metalCommandFailed(message):
            return "Metal command failed: \(message)"
        case .invalidBufferRange:
            return "The requested buffer range is outside the Metal buffer."
        }
    }
}
