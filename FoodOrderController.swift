import Foundation

// MARK: - Models

public struct SavedAddress: Identifiable, Hashable {
    public let id = UUID()
    public var label: String        // e.g., "Home", "Work"
    public var state: String
    public var line1: String
    public var apt: String
    public var city: String
    public var zip: String
}

public class FoodOrderController: ObservableObject {
    
    // MARK: - User / Session
    
    @Published var isLoggedIn: Bool = false
    
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var userPhone: String = ""
    
    // MARK: - Saved Addresses
    
    @Published var savedAddresses: [SavedAddress] = []
    @Published var selectedAddressID: UUID? = nil
    
    var currentAddress: SavedAddress? {
        savedAddresses.first { $0.id == selectedAddressID }
    }
    
    func addAddress(
        label: String,
        state: String,
        line1: String,
        apt: String,
        city: String,
        zip: String
    ) {
        let addr = SavedAddress(
            label: label,
            state: state,
            line1: line1,
            apt: apt,
            city: city,
            zip: zip
        )
        savedAddresses.append(addr)
        selectedAddressID = addr.id
    }
    
    func selectAddress(_ address: SavedAddress) {
        selectedAddressID = address.id
    }
    
    // MARK: - Categories (only relevant ones, with valid images)
    
    @Published var selectedCategory: Category = Category(name: "Burger Meals", imagePath: "burger2")
    
    @Published var Categories: [Category] = [
        Category(name: "Burger Meals",     imagePath: "burger2"),
        Category(name: "Pizza",            imagePath: "pizza3"),
        Category(name: "Sandwiches",       imagePath: "sandwich"),
        Category(name: "Cupcakes & Cakes", imagePath: "cupcake"),
        Category(name: "Fries & Sides",    imagePath: "bur3")
    ]
    
    // MARK: - Menu data (each uses a reasonable image you actually have)
    
    @Published var foodList: [Food] = [
        // ----- Burgers -----
        Food(
            name: "Beef Burger",
            category: "Burger Meals",
            subtiltle: "Cheesy beef",
            price: 6.15,
            imagePath: "bur1",
            description: "Juicy grilled beef patty with melted cheese and fresh vegetables."
        ),
        Food(
            name: "Double Burger",
            category: "Burger Meals",
            subtiltle: "Double beef",
            price: 7.80,
            imagePath: "bur2",
            description: "Two beef patties, double cheese, pickles and our house sauce."
        ),
        Food(
            name: "Crispy Chicken Burger",
            category: "Burger Meals",
            subtiltle: "Fried chicken",
            price: 7.20,
            imagePath: "burger1",
            description: "Crispy fried chicken burger with lettuce and mayo."
        ),
        Food(
            name: "House Hamburger",
            category: "Burger Meals",
            subtiltle: "House classic",
            price: 6.99,
            imagePath: "hamburger",
            description: "Classic hamburger with toasted bun and fresh veggies."
        ),
        
        // ----- Pizza -----
        Food(
            name: "Pepperoni Pizza",
            category: "Pizza",
            subtiltle: "12\" pepperoni",
            price: 10.99,
            imagePath: "pizza3",
            description: "Crispy crust pizza topped with pepperoni and mozzarella."
        ),
        Food(
            name: "Veggie Delight Pizza",
            category: "Pizza",
            subtiltle: "Loaded with veggies",
            price: 9.99,
            imagePath: "pizza1",
            description: "Pizza with bell peppers, onions, olives and mushrooms."
        ),
        Food(
            name: "Cheese Lovers Pizza",
            category: "Pizza",
            subtiltle: "Extra cheese",
            price: 11.49,
            imagePath: "pizza2-1",
            description: "Three-cheese blend on a crispy thin crust."
        ),
        
        // ----- Sandwiches -----
        Food(
            name: "Grilled Cheese Sandwich",
            category: "Sandwiches",
            subtiltle: "Cheesy & crispy",
            price: 5.99,
            imagePath: "sandwich",
            description: "Grilled sandwich with melted cheese and toasted bread."
        ),
        Food(
            name: "Veggie Sandwich",
            category: "Sandwiches",
            subtiltle: "Light & fresh",
            price: 5.49,
            imagePath: "sandwich",
            description: "Sandwich with fresh vegetables and house sauce."
        ),
        
        // ----- Cupcakes & Cakes -----
        Food(
            name: "Chocolate Cupcake",
            category: "Cupcakes & Cakes",
            subtiltle: "Rich chocolate",
            price: 3.50,
            imagePath: "cup3",
            description: "Moist chocolate cupcake with creamy frosting."
        ),
        Food(
            name: "Vanilla Cupcake",
            category: "Cupcakes & Cakes",
            subtiltle: "Light & fluffy",
            price: 3.00,
            imagePath: "cup1",
            description: "Classic vanilla cupcake with buttercream frosting."
        ),
        
        // ----- Fries & Sides -----
        Food(
            name: "Golden Fries",
            category: "Fries & Sides",
            subtiltle: "Crispy & hot",
            price: 4.25,
            imagePath: "bur3",
            description: "Crispy golden fries with house seasoning."
        )
    ]
    
    // MARK: - Cart & Favorites
    
    @Published var cartItems: [CartItem] = []
    @Published var favoriteFoods: Set<Food> = []
    
    func addToCart(food: Food, quantity: Int = 1) {
        if let index = cartItems.firstIndex(where: { $0.food == food }) {
            cartItems[index].quantity += quantity
        } else {
            cartItems.append(CartItem(food: food, quantity: quantity))
        }
    }
    
    func removeFromCart(_ item: CartItem) {
        cartItems.removeAll { $0.id == item.id }
    }
    
    func clearCart() {
        cartItems.removeAll()
    }
    
    var totalCartQuantity: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    var totalCartPrice: Double {
        cartItems.reduce(0) { $0 + Double($1.quantity) * $1.food.price }
    }
    
    func isFavorite(_ food: Food) -> Bool {
        favoriteFoods.contains(food)
    }
    
    func toggleFavorite(_ food: Food) {
        if favoriteFoods.contains(food) {
            favoriteFoods.remove(food)
        } else {
            favoriteFoods.insert(food)
        }
    }
    
    // MARK: - Profile
    
    func updateProfile(name: String, email: String, phone: String) {
        userName = name
        userEmail = email
        userPhone = phone
    }
}

