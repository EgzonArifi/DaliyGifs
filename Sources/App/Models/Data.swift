import Foundation
import Vapor

final class Data: Model {

    var exist: Bool = false
    var id: Node?

    var embedUrl : String!
    var bitlyUrl : String!
    var contentUrl : String!
    //var images : Image!
    var importDatetime : String!
    var isIndexable : Int!
    var rating : String!
    var slug : String!
    var source : String!
    var sourcePostUrl : String!
    var sourceTld : String!
    var trendingDatetime : String!
    var type : String!
    var url : String!
    //var user : User!
    var username : String!

    init(embedUrl: String, bitlyUrl: String) {
         self.embedUrl = embedUrl
        self.bitlyUrl = bitlyUrl
    }

    init(node: Node, in context: Context) throws {
        //id = try node.extract("id")
        embedUrl = try node.extract("embedUrl")
        bitlyUrl = try node.extract("bitlyUrl")
    }


    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "embedUrl" : embedUrl,
            "bitlyUrl": bitlyUrl
            ])
    }
    static func prepare(_ database: Database) throws {
        try database.create("acronyms") { users in
            users.id()
            users.string("embedUrl")
            users.string("embedUrl")
        }
    }
    static func revert(_ database: Database) throws {
        try database.delete("acronyms")
    }
}
