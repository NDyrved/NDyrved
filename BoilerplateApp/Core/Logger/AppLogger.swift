import OSLog

protocol LoggerService {
    func info(_ message: String)
    func error(_ message: String)
}

struct AppLogger: LoggerService {
    private let logger = Logger(subsystem: "BoilerplateApp", category: "App")
    func info(_ message: String) { logger.info("\(message)") }
    func error(_ message: String) { logger.error("\(message)") }
}
