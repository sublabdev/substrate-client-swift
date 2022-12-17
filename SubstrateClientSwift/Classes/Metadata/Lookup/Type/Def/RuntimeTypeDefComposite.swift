import Foundation

/// Composite runtime type
public class RuntimeTypeDefComposite: Codable {
    let fields: [RuntimeTypeDefField]
    
    init(fields: [RuntimeTypeDefField]) {
        self.fields = fields
    }
}
