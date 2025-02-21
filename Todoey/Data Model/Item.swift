import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var Title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date = Date()
    // UI Colors
    //@objc dynamic var color: String = ""
    ///** Intializating a relationship to other Data/Tabel --- Inverse Relationship
    /// We used Linkingobjects method
    var parentCategory = LinkingObjects<Category>(fromType: Category.self, property: "items")
}
