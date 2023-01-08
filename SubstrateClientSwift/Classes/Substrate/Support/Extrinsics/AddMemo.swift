import Foundation

struct AddMemo: Codable {
    let index: UInt32
    let memo: Data
}

class AddMemoCall: Call<AddMemo> {
    init(value: AddMemo) {
        super.init(moduleName: "crowdloan", name: "add_memo", value: value)
    }
}
