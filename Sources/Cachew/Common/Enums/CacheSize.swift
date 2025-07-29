    public enum CacheSize: Sendable {
        case small
        case medium
        case large
        case extraLarge
        case custom(Int)
        
        var countLimit: Int {
            switch self {
            case .small:
                return 10
            case .medium:
                return 100
            case .large:
                return 1000
            case .extraLarge:
                return 10000
                case .custom(let size):
                return size
            }
        }
    }