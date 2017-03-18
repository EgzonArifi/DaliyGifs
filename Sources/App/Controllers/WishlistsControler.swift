import Vapor
import HTTP

final class WishlistsController {

    func addRoutes(drop: Droplet) {
        let basic = drop.grouped("wishlists")
        basic.get(handler: index)
        basic.post(handler: create)
        basic.get(Wishlist.self, handler: show)
        basic.patch(Wishlist.self, handler: update)
        basic.delete(Wishlist.self, handler: delete)
        basic.get(Wishlist.self, "user", handler: userShow)
    }

    func index(request: Request) throws -> ResponseRepresentable {
        return try JSON(node: Wishlist.all().makeNode())
    }

    func create(request: Request) throws -> ResponseRepresentable {
        var acronym = try request.acronym()
        try acronym.save()
        return acronym
    }

    func show(request: Request, acronym: Wishlist) throws -> ResponseRepresentable {
        return acronym
    }

    func update(request: Request, acronym: Wishlist) throws -> ResponseRepresentable {
        let new = try request.acronym()
        var acronym = acronym
        acronym.itemid = new.itemid
        acronym.itemurl = new.itemurl
        try acronym.save()
        return acronym
    }

    func delete(request: Request, acronym: Wishlist) throws -> ResponseRepresentable {
        try acronym.delete()
        return JSON([:])
    }

    func userShow(request: Request, acronym: Wishlist) throws -> ResponseRepresentable {
        let tiluser = try acronym.tiluser()
        return try JSON(node: tiluser?.makeNode())
    }

}

extension Request {
    func acronym() throws -> Wishlist {
        guard let json = json else { throw Abort.badRequest }
        return try Wishlist(node: json)
    }
}
