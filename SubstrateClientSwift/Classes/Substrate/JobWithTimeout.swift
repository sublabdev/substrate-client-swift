import Foundation

class JobWithTimeout {
    let job: () -> Void
    let timeout: TimeInterval
    private var lastUpdateDate: Date? = nil
    
    init(timeout: TimeInterval, job: @escaping () -> Void) {
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
            job()
            lastUpdateDate = now
        }
    }
}
