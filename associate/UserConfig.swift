
import Foundation

struct defaultKeys {
    static let url = "URL"
    static let password = "PASSW"
    static let userConfig = "USER_CONFIG"
}



import UIKit


struct Page : Codable {
    var number : Int
    var title : String
    
    init(number: Int, title: String) {
        self.number = number
        self.title = title
    }
    
}

class UserConfig : Codable  {
    var url : String?
    var haAccessPassword : String?
    private var entityIds = [Int: String]()
    private var pages = [Int: Page]()
    private static var  _shared : UserConfig?
    
    
    static var shared : UserConfig {
        get {
            if (_shared == nil) {
                _shared = loadFromDefaults()
            }
            return _shared!
        }
    }
    
    
    private static func loadFromDefaults() -> UserConfig {
        let d = UserDefaults.standard
        let data = d.data(forKey: defaultKeys.userConfig)
        if (data == nil) {
            return UserConfig()
        }
        let jsonDecoder = JSONDecoder()
        do {
//            print (String.init(data: data!, encoding: .utf8)!)
            var output = try jsonDecoder.decode(UserConfig.self, from: data!)
            return output
        } catch {
            return UserConfig()
        }
    }
    
    private func heal() {
        
    }
    
    
    
    func saveToDefaults() throws {
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(self)
        let d = UserDefaults.standard
        d.set(jsonData, forKey: defaultKeys.userConfig)
    }
    
    func getOrCreatePage(pageNumber: Int) -> Page{
        let output = self.pages[pageNumber] ?? Page(number: pageNumber, title: String(format: "Page_ %d",pageNumber))
        pages[pageNumber] = output
        return output
    }
    
    func setPage (page: Page) {
        pages[page.number] = page
        try! saveToDefaults()
    }
    
    func locationFor (entityId : String) -> Int{
        var maxIndex = Int.min
        for e in self.entityIds {
            if (e.value == entityId) {
//                print ("\(entityId) --> \(e.key)")
                return e.key
            }
            maxIndex = max(e.key, maxIndex)
        }
        if (maxIndex == Int.min) {
            return 0
        }
        for i in 0...maxIndex {
            if (entityIds[i] == nil) {
                return i
            }
        }
        return maxIndex + 1
    }

    func registerThingLocation(entityId: String, index: Int) {
        for e in entityIds {
            if (e.value == entityId) {
                entityIds.removeValue(forKey: e.key)
            }
        }
        self.entityIds[index] = entityId
        try! saveToDefaults()
    }

}





