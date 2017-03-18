import Vapor
import HTTP
import Fluent

final class TILUserController {

    func addRoutes(drop: Droplet) {
        let basic = drop.grouped("users")
        basic.get(handler: index)
        basic.post(handler: create)
        basic.delete(TILUser.self, handler: delete)
        basic.get(TILUser.self, "wishlist", handler: wishlistIndex)
//        basic.post(handler: addUser)
    }

    func index(request: Request) throws -> ResponseRepresentable {
        return try JSON(node: TILUser.all().makeNode())
    }

    func addUser(request: Request) throws -> ResponseRepresentable {

        guard let name = request.data["name"]?.string,
            let email = request.data["email"]?.string,
            let password = request.data["password"]?.string else {

                throw Abort.badRequest
        }

        var user = try TILUser(name: name, email: email, rawPassword: password)
        try user.save()

        return user
    }
    func create(request: Request) throws -> ResponseRepresentable {
        var tiluser = try request.tiluser()
        try tiluser.save()
        return tiluser
    }

    func delete(request: Request, tiluser: TILUser) throws -> ResponseRepresentable {
        try tiluser.delete()
        return JSON([:])
    }

    func wishlistIndex(request: Request, tiluser: TILUser) throws -> ResponseRepresentable {
        let children = try tiluser.wishlist()
        return try JSON(node: children.makeNode())
    }

}

extension Request {
    func tiluser() throws -> TILUser {
        print(json ?? "errpp")
        guard let json = json else { throw Abort.badRequest }
        return try TILUser(node: json)
    }
}
