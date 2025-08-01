import Vapor
import Fluent

struct User: @unchecked Sendable, Content, Authenticatable{
    
    var id: UUID
    var username: String
    var role: UserRole
    var city: String
    var country: String
    var dateOfBirth: Date
    var email: String
    var isVet: Bool
    var isBreeder: Bool
    var mobile: String
    var givenname: String
    var phone: String
    var street: String
    var streetNo: String
    var streetNoAddon: String
    var surname: String
    var zip: String
    var picture: UUID?
    let onboardingCompleted: Date
    let GTCAccepted: Date
    let GDPRAccepted: Date
    var created: Date?
    var updated: Date?
    var deleted: Date?
    var readPermissions: [UUID]
    var writePermissions: [UUID]
    
    init(id: UUID, username: String, role: UserRole, city: String, country: String, dateofBirth: Date, email: String, isVet: Bool, isBreeder: Bool, mobile: String, givenname: String, surname: String, phone: String, street: String, streetNo: String, streetNoAddon: String, zip: String, picture: UUID? = nil, onboardingCompleted: Date, GTCAccepted: Date, GDPRAccepted: Date, readPermissions: [UUID], writePermissions: [UUID]){
        self.id = id
        self.username = username
        self.role = role
        self.city = city
        self.country = country
        self.dateOfBirth = dateofBirth
        self.email = email
        self.isVet = isVet
        self.isBreeder = isBreeder
        self.mobile = mobile
        self.givenname = givenname
        self.surname = surname
        self.phone = phone
        self.street = street
        self.streetNo = streetNo
        self.streetNoAddon = streetNoAddon
        self.zip = zip
        self.picture = picture
        self.onboardingCompleted = onboardingCompleted
        self.GTCAccepted = GTCAccepted
        self.GDPRAccepted = GDPRAccepted
        self.readPermissions = readPermissions
        self.writePermissions = writePermissions
    }
}
