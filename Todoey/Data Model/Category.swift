import Foundation
import RealmSwift

class Category: Object{
    @objc dynamic var name: String = ""
    ///** Intializating a relationship to other Data/Tabel --- Forward Relationship
    let items = List<Item>()
}
