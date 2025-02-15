import Foundation
import RealmSwift

class Data : Object {
    
    ///** dynamic keyword is use for Realm can monitor the changes in the value of this property, this is allowed us to do it while the application is running.
    @objc dynamic var name: String = ""
    @objc dynamic var age: Int = 0
}



