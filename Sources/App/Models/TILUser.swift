import Vapor
import Fluent
import Turnstile
import TurnstileCrypto
import Auth

final class TILUser: Model, User {
    var exists: Bool = false
    var id: Node?
    var name: Valid<NameValidator>
    var email: Valid<EmailValidator>
    var password: String

    init(name: String, email: String, rawPassword: String) throws {
        self.name = try name.validated()
        self.email = try email.validated()
        let validatedPassword: Valid<PasswordValidator> = try rawPassword.validated()
        self.password = BCrypt.hash(password: validatedPassword.value)
    }

    init(node: Node, in context: Context) throws {
        id = node["id"]
        let nameString = try node.extract("name") as String
        name = try nameString.validated()
        let emailString = try node.extract("email") as String
        email = try emailString.validated()
        let passwordString = try node.extract("password") as String
        password = passwordString
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name.value,
            "email": email.value,
            "password": password,
            ])
    }

    static func prepare(_ database: Database) throws {
        try database.create("tilusers") { users in
            users.id()
            users.string("name")
            users.string("email")
            users.string("password")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete("tilusers")
    }

    static func register(name: String, email: String, rawPassword: String) throws -> TILUser {
        var newUser = try TILUser(name: name, email: email, rawPassword: rawPassword)
        if try TILUser.query().filter("email", newUser.email.value).first() == nil {
            try newUser.save()
            return newUser
        } else {
            throw AccountTakenError()
        }
    }

}

extension TILUser {
    func wishlist() throws -> [Wishlist] {
        return try children(nil, Wishlist.self).all()
    }

}

extension TILUser: Authenticator {

    static func authenticate(credentials: Credentials) throws -> User {
        var user: TILUser?

        switch credentials {
        case let credentials as UsernamePassword:
            let fetchedUser = try TILUser.query()
                .filter("email", credentials.username)
                .first()
            if let password = fetchedUser?.password,
                password != "",
                (try? BCrypt.verify(password: credentials.password, matchesHash: password)) == true {
                user = fetchedUser
            }
        case let credentials as Identifier:
            user = try TILUser.find(credentials.id)
        default:
            throw UnsupportedCredentialsError()
        }
        
        if let user = user {
            return user
        } else {
            throw IncorrectCredentialsError()
        }
    }
    
    static func register(credentials: Credentials) throws -> User {
        throw Abort.badRequest
    }
}
