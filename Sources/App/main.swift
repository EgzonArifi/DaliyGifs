import Vapor
import HTTP
import VaporPostgreSQL
import Foundation

let drop = Droplet(
    providers: [VaporPostgreSQL.Provider.self]
)

drop.get("version") { request in
    if let db = drop.database?.driver as? PostgreSQLDriver {
        let version = try db.raw("SELECT version()")
        return try JSON(node: version)
    } else {
        return "No db connection"
    }
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
