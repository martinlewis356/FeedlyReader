import Foundation

extension String {
    // 移除HTML标签
    var strippingHTML: String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
    
    // 分割长文本为段落
    func split(by length: Int) -> [String] {
        var startIndex = self.startIndex
        var results = [String]()
        
        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            results.append(String(self[startIndex..<endIndex]))
            startIndex = endIndex
        }
        
        return results
    }
}
