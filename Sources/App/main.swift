import Vapor
import HTTP
import VaporPostgreSQL
import Foundation
import Fluent

let drop = Droplet()
try drop.addProvider(VaporPostgreSQL.Provider)
drop.preparations += Wishlist.self
drop.preparations += TILUser.self

let tilusers = TILUserController()
tilusers.addRoutes(drop: drop)

let wishlist = WishlistsController()
wishlist.addRoutes(drop: drop)


drop.get("version") { request in
    if let db = drop.database?.driver as? PostgreSQLDriver {
        let version = try db.raw("SELECT version()")
        return try JSON(node: version)
    } else {
        return "No db connection"
    }
}

drop.get("password") { request in
    let input: Valid<EmailValidator> = try request.data["input"].validated()
    return "Validated \(input.value)"
}

drop.get("trending") { request in
    let response = try drop.client.get("http://api.giphy.com/v1/gifs/trending?api_key=dc6zaTOxFJmzC")

    guard let arr = response.data["data"] else {
        throw Abort.badRequest
    }
   // let data = response.json.flatMap { try Data() }
    let data = try Data(node: response.json?["data"])
    guard
        response.status == .ok,
        let gifsJson = response.data["data"] as? JSON
        else {
            throw Abort.serverError
    }
    return try JSON(node: data.makeNode())
}

drop.get { req in
    return try drop.view.make("welcome", [
        "message": drop.localization[req.lang, "welcome", "title"]
        ])
}

drop.run()
