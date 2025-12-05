import SwiftUI

// For sheet routing
enum ActiveSheet: Identifiable {
    case profile
    case location
    
    var id: Int { self.hashValue }
}

// MARK: - Home Page

struct HomePageView: View {
    
    @EnvironmentObject var foodController: FoodOrderController
    @State private var selectedTab: String = "home2"
    @State private var activeSheet: ActiveSheet?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Light pastel background for the whole app
                LinearGradient(
                    colors: [
                        Color.white,
                        Color("pink").opacity(0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // Scrollable content area
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            
                            AppBarView {
                                activeSheet = .profile
                            }
                            
                            LocationBar {
                                activeSheet = .location
                            }
                            
                            // Hello Name (cursive / light)
                            Text("Hello \(foodController.userName.isEmpty ? "Guest" : foodController.userName) 👋")
                                .font(.title2)
                                .italic()
                                .foregroundStyle(.black.opacity(0.8))
                                .padding(.horizontal)
                                .padding(.bottom, 8)
                            
                            // Card-like white background for the rest
                            VStack(spacing: 20) {
                                
                                if selectedTab == "home2" {
                                    // Offers only on HOME tab
                                    OffersCarouselView()
                                    CategoriesListView(foodController: foodController)
                                    PopularFood(foodController: foodController)
                                } else if selectedTab == "heart" {
                                    FavoritesView(foodController: foodController)
                                } else if selectedTab == "bell" {
                                    NotificationsView()
                                } else if selectedTab == "cart2" {
                                    CartView(foodController: foodController)
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                            .padding(.horizontal)
                            .padding(.bottom, 16)
                        }
                        .padding(.top, 12)
                    }
                    
                    BottomTabBar(selectedTab: $selectedTab)
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .profile:
                    ProfileView()
                        .environmentObject(foodController)
                case .location:
                    LocationSheetView()
                        .environmentObject(foodController)
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    HomePageView()
        .environmentObject(FoodOrderController())
}

// MARK: - Top App Bar with profile avatar

struct AppBarView: View {
    
    let onProfileTapped: () -> Void
    @EnvironmentObject var foodController: FoodOrderController
    
    var body: some View {
        HStack(spacing: 16) {
            
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 26))
                .foregroundStyle(Color("pink"))
                .padding(10)
                .background(Color("pink").opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Delivery address")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                if let addr = foodController.currentAddress {
                    Text(addr.label)
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(.black)
                        .lineLimit(1)
                } else {
                    Text("Add address")
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(Color("pink"))
                }
            }
            
            Spacer()
            
            Button(action: onProfileTapped) {
                Image("profile")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color("pink"), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

// MARK: - Location bar (Add / Change address)

struct LocationBar: View {
    
    let onChangeLocation: () -> Void
    @EnvironmentObject var foodController: FoodOrderController
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let addr = foodController.currentAddress {
                    Text("Deliver to")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    Text("\(addr.line1), \(addr.city)")
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(.black)
                        .lineLimit(1)
                } else {
                    Text("No address added")
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(.black)
                }
            }
            
            Spacer()
            
            Button(action: onChangeLocation) {
                Text(foodController.currentAddress == nil ? "Add address" : "Change / add")
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color("pink"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 4)
    }
}

// MARK: - Offers carousel (auto scroll every 3 seconds, HOME only)

struct Offer: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
}

struct OffersCarouselView: View {
    
    private let offers: [Offer] = [
        Offer(title: "20% OFF on Burgers",
              subtitle: "Use code BURGER20 on orders above $20.",
              icon: "hamburger",
              color: Color("pink").opacity(0.12)),
        Offer(title: "Free Fries Friday",
              subtitle: "Free fries with any pizza every Friday.",
              icon: "pizza3",
              color: Color.orange.opacity(0.12)),
        Offer(title: "Dessert Delight",
              subtitle: "Buy 2 cupcakes, get 1 free.",
              icon: "cupcake",
              color: Color.purple.opacity(0.12))
    ]
    
    @State private var currentIndex: Int = 0
    @State private var timer: Timer?
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(offers.indices, id: \.self) { index in
                let offer = offers[index]
                
                HStack(spacing: 16) {
                    Image(offer.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(offer.title)
                            .font(.headline)
                        Text(offer.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                    Spacer()
                }
                .padding()
                .background(offer.color)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 6)
                .tag(index)
            }
        }
        .frame(height: 130)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % offers.count
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Bottom Tab Bar

struct BottomTabBar: View {
    
    @Binding var selectedTab: String
    let icons = ["home2", "heart", "bell", "cart2"]
    
    var body: some View {
        HStack(spacing: 70) {
            ForEach(icons, id: \.self) { icon in
                Button {
                    withAnimation(.spring()) {
                        selectedTab = icon
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(icon)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(selectedTab == icon ? Color("pink") : .gray)
                        
                        Circle()
                            .fill(selectedTab == icon ? Color("pink") : Color.clear)
                            .frame(width: 6, height: 6)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .background(
            Color.white
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: -2)
        )
    }
}

// MARK: - Categories

struct CategoriesListView: View {
    
    @ObservedObject var foodController: FoodOrderController
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Categories")
                .font(.system(size: 22, weight: .bold))
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(foodController.Categories, id: \.self) { category in
                        let isSelected = (foodController.selectedCategory == category)
                        
                        VStack(spacing: 6) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(isSelected ? Color("pink") : Color.gray.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                
                                Image(category.imagePath)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                            }
                            
                            Text(category.name)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(isSelected ? Color("pink") : .gray)
                                .frame(width: 80)
                        }
                        .onTapGesture {
                            withAnimation(.spring()) {
                                foodController.selectedCategory = category
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 4)
    }
}

// MARK: - Popular + View All

struct PopularFood: View {
    
    @ObservedObject var foodController: FoodOrderController
    
    private var filteredFoods: [Food] {
        foodController.foodList.filter { $0.category == foodController.selectedCategory.name }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Popular Now")
                    .font(.system(size: 22, weight: .bold))
                
                Spacer()
                
                NavigationLink {
                    AllMenuView(foodController: foodController)
                } label: {
                    HStack(spacing: 4) {
                        Text("View All")
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.pink)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(filteredFoods, id: \.self) { food in
                        NavigationLink {
                            FoodDetailsPage(foodController: foodController, food: food)
                        } label: {
                            PopularCard(food: food)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 4)
    }
}

struct PopularCard: View {
    let food: Food
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                Image(food.imagePath)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 170, height: 110)
                    .clipped()
                
                Text(String(format: "$%.2f", food.price))
                    .font(.caption)
                    .bold()
                    .padding(6)
                    .background(Color.black.opacity(0.6))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(6)
            }
            
            Text(food.name)
                .font(.headline)
            
            Text(food.subtiltle)
                .font(.subheadline)
                .foregroundStyle(.gray)
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                    Text("4.8")
                        .font(.caption)
                }
                .foregroundStyle(.yellow)
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.pink)
            }
            .padding(.top, 4)
        }
        .padding(10)
        .frame(width: 180)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 3)
    }
}

// MARK: - All Menu (View All)

struct AllMenuView: View {
    
    @ObservedObject var foodController: FoodOrderController
    
    var body: some View {
        List {
            ForEach(foodController.Categories, id: \.self) { category in
                Section(category.name) {
                    ForEach(foodController.foodList.filter { $0.category == category.name }, id: \.self) { food in
                        NavigationLink {
                            FoodDetailsPage(foodController: foodController, food: food)
                        } label: {
                            HStack {
                                Image(food.imagePath)
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                VStack(alignment: .leading) {
                                    Text(food.name)
                                        .font(.headline)
                                    Text(food.subtiltle)
                                        .font(.subheadline)
                                        .foregroundStyle(.gray)
                                }
                                
                                Spacer()
                                
                                Text(String(format: "$%.2f", food.price))
                                    .bold()
                                    .foregroundStyle(.pink)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("All Menu")
    }
}

// MARK: - Favorites

struct FavoritesView: View {
    
    @ObservedObject var foodController: FoodOrderController
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Favorites")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            if foodController.favoriteFoods.isEmpty {
                Text("You don't have any favorites yet.")
                    .foregroundStyle(.gray)
                    .padding(.horizontal)
            } else {
                ForEach(Array(foodController.favoriteFoods), id: \.self) { food in
                    NavigationLink {
                        FoodDetailsPage(foodController: foodController, food: food)
                    } label: {
                        HStack(spacing: 16) {
                            Image(food.imagePath)
                                .resizable()
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            VStack(alignment: .leading) {
                                Text(food.name)
                                    .font(.headline)
                                Text(food.subtiltle)
                                    .font(.subheadline)
                                    .foregroundStyle(.gray)
                            }
                            
                            Spacer()
                            
                            Text(String(format: "$%.2f", food.price))
                                .bold()
                                .foregroundStyle(.pink)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.top)
    }
}

// MARK: - Cart -> Payment flow

struct CartView: View {
    
    @ObservedObject var foodController: FoodOrderController
    @State private var goToPayment: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            NavigationLink(
                destination: PaymentMethodView(foodController: foodController),
                isActive: $goToPayment
            ) {
                EmptyView()
            }
            .hidden()
            
            Text("My Cart")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            if foodController.cartItems.isEmpty {
                Text("Your cart is empty. Add something tasty!")
                    .foregroundStyle(.gray)
                    .padding(.horizontal)
            } else {
                ForEach(foodController.cartItems) { item in
                    HStack(spacing: 16) {
                        Image(item.food.imagePath)
                            .resizable()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(alignment: .leading) {
                            Text(item.food.name)
                                .font(.headline)
                            Text("x\(item.quantity)")
                                .foregroundStyle(.gray)
                        }
                        
                        Spacer()
                        
                        Text(String(format: "$%.2f", Double(item.quantity) * item.food.price))
                            .bold()
                            .foregroundStyle(.pink)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                
                Divider()
                    .padding(.horizontal)
                
                HStack {
                    Text("Total")
                        .font(.headline)
                    Spacer()
                    Text(String(format: "$%.2f", foodController.totalCartPrice))
                        .font(.title3)
                        .bold()
                        .foregroundStyle(.pink)
                }
                .padding(.horizontal)
                
                Button {
                    goToPayment = true
                } label: {
                    Text("Order Now")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                        .padding(.top, 8)
                }
            }
        }
        .padding(.top)
    }
}

// Payment method selection

struct PaymentMethodView: View {
    
    @ObservedObject var foodController: FoodOrderController
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Choose Payment Method")
                .font(.title2)
                .bold()
                .padding(.top)
            
            NavigationLink {
                CardDetailsView(paymentType: "Credit Card")
            } label: {
                HStack {
                    Image(systemName: "creditcard")
                    Text("Credit Card")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            NavigationLink {
                CardDetailsView(paymentType: "Debit Card")
            } label: {
                HStack {
                    Image(systemName: "banknote")
                    Text("Debit Card")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Payment")
    }
}

// Card details + final payment
//  - uses EnvironmentObject
//  - clears cart after successful payment

struct CardDetailsView: View {
    
    let paymentType: String
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var foodController: FoodOrderController
    
    @State private var cardNumber: String = ""
    @State private var cardHolder: String = ""
    @State private var expDate: String = ""
    @State private var cvv: String = ""
    @State private var showCongrats: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text(paymentType)) {
                TextField("Card Number", text: $cardNumber)
                    .keyboardType(.numberPad)
                TextField("Name on Card", text: $cardHolder)
                TextField("Exp Date (MM/YY)", text: $expDate)
                    .keyboardType(.numbersAndPunctuation)
                SecureField("CVV", text: $cvv)
                    .keyboardType(.numberPad)
            }
            
            Section {
                Button {
                    // Very simple validation
                    guard !cardNumber.isEmpty, !cardHolder.isEmpty else { return }
                    // Clear cart when payment is "done"
                    foodController.clearCart()
                    showCongrats = true
                } label: {
                    HStack {
                        Spacer()
                        Text("PAYMENT")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Spacer()
                    }
                }
                .listRowBackground(Color.pink)
            }
        }
        .navigationTitle("Card Details")
        .alert("🎉 CONGRATULATIONS!!! 🎉", isPresented: $showCongrats) {
            Button("OK") {
                dismiss()   // Go back; cart is now empty
            }
        } message: {
            Text("YOUR ORDER HAS BEEN PLACED.\nYour delicious food is on the way! 😋")
        }
    }
}

// MARK: - Notifications

struct NotificationsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Notifications")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Circle().frame(width: 10, height: 10).foregroundStyle(.pink)
                    Text("Welcome to DeliveryApp! 🎉")
                }
                HStack {
                    Circle().frame(width: 10, height: 10).foregroundStyle(.pink)
                    Text("Add items to your cart to see offers here.")
                }
            }
            .font(.subheadline)
            .padding(.horizontal)
            
            Spacer(minLength: 0)
        }
        .padding(.top)
    }
}

// MARK: - Profile

struct ProfileView: View {
    
    @EnvironmentObject var foodController: FoodOrderController
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                }
                
                Section("Account") {
                    Button("Log out", role: .destructive) {
                        foodController.isLoggedIn = false
                    }
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        foodController.updateProfile(name: name, email: email, phone: phone)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear {
                name = foodController.userName
                email = foodController.userEmail
                phone = foodController.userPhone
            }
        }
    }
}

// MARK: - Location Sheet (multiple saved addresses)

struct LocationSheetView: View {
    
    @EnvironmentObject var foodController: FoodOrderController
    @Environment(\.dismiss) var dismiss
    
    @State private var addressLabel: String = ""
    @State private var selectedState: String = ""
    @State private var address1: String = ""
    @State private var apt: String = ""
    @State private var city: String = ""
    @State private var zip: String = ""
    
    private let usStates: [String] = [
        "Alabama","Alaska","Arizona","Arkansas","California","Colorado","Connecticut",
        "Delaware","Florida","Georgia","Hawaii","Idaho","Illinois","Indiana","Iowa",
        "Kansas","Kentucky","Louisiana","Maine","Maryland","Massachusetts","Michigan",
        "Minnesota","Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire",
        "New Jersey","New Mexico","New York","North Carolina","North Dakota","Ohio",
        "Oklahoma","Oregon","Pennsylvania","Rhode Island","South Carolina","South Dakota",
        "Tennessee","Texas","Utah","Vermont","Virginia","Washington","West Virginia",
        "Wisconsin","Wyoming"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                if !foodController.savedAddresses.isEmpty {
                    Section("Saved addresses") {
                        ForEach(foodController.savedAddresses) { addr in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(addr.label)
                                        .font(.headline)
                                    Text("\(addr.line1), \(addr.city)")
                                        .font(.subheadline)
                                        .foregroundStyle(.gray)
                                }
                                Spacer()
                                if foodController.selectedAddressID == addr.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                foodController.selectAddress(addr)
                            }
                        }
                    }
                }
                
                Section("Add new address") {
                    TextField("Address name (e.g., Home, Work)", text: $addressLabel)
                    Picker("State", selection: $selectedState) {
                        ForEach(usStates, id: \.self) { state in
                            Text(state).tag(state)
                        }
                    }
                    TextField("Address line", text: $address1)
                    TextField("Apt / Suite (optional)", text: $apt)
                    TextField("City", text: $city)
                    TextField("ZIP Code", text: $zip)
                        .keyboardType(.numberPad)
                    
                    Button("Save address") {
                        guard !addressLabel.isEmpty,
                              !selectedState.isEmpty,
                              !address1.isEmpty,
                              !city.isEmpty,
                              !zip.isEmpty
                        else { return }
                        
                        foodController.addAddress(
                            label: addressLabel,
                            state: selectedState,
                            line1: address1,
                            apt: apt,
                            city: city,
                            zip: zip
                        )
                        
                        // Clear form
                        addressLabel = ""
                        selectedState = ""
                        address1 = ""
                        apt = ""
                        city = ""
                        zip = ""
                    }
                }
            }
            .navigationTitle("Delivery Address")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

