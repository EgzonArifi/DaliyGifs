import Vapor

final class Wishlist: Model {

    var id: Node?
    var exists: Bool = false

    var itemid: String
    var itemurl: String
    var tiluserId: Node?

    init(itemId: String, itemUrl: String, tiluserId: Node? = nil) {
        self.id = nil
        self.itemid = itemId
        self.itemurl = itemUrl
        self.tiluserId = tiluserId
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        itemid = try node.extract("itemid")
        itemurl = try node.extract("itemurl")
        tiluserId = try node.extract("tiluser_id")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "itemid": itemid,
            "itemurl": itemurl,
            "tiluser_id": tiluserId
            ])
    }

    static func prepare(_ database: Database) throws {
        try database.create("wishlists") { users in
            users.id()
            users.string("itemid")
            users.string("itemurl")
            users.parent(TILUser.self, optional: false)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete("wishlists")
    }
    
}

extension Wishlist {
    func tiluser() throws -> TILUser? {
        return try parent(tiluserId, nil, TILUser.self).get()
    }
}






