import Foundation

class JobWithTimeout {
    let job: () async throws -> Void
    let timeout: TimeInterval
    private var lastUpdateDate: Date? = nil
    
    init(timeout: TimeInterval, job: @escaping () async throws -> Void) {
        self.job = job
        self.timeout = timeout
    }
    
    func performIfNeeded() {
        let now = Date()
        
        var updateNeeded = lastUpdateDate == nil
        
        if let lastUpdateDate = lastUpdateDate, now.timeIntervalSince(lastUpdateDate) > timeout {
            updateNeeded = true
        }
        
        if updateNeeded {
            Task { [weak self] in
                try await self?.job()
                self?.lastUpdateDate = now
            }
        }
    }
}
