import SwiftUI

struct FoodDetailsPage: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var foodController: FoodOrderController
    var food: Food?

    @State private var quantity: Int = 1
    @State private var addedToCart: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Custom app bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.pink)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 2)
                }

                Spacer()

                Text("Details")
                    .font(.headline)

                Spacer()

                Image(systemName: "circle.grid.2x2")
                    .foregroundStyle(.pink)
                    .padding(8)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 2)
            }
            .padding([.horizontal, .top])

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // Image
                    Image(food?.imagePath ?? "bur1")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(radius: 4)
                        .padding(.top, 8)

                    // Name, favorite button & subtitle
                    HStack {
                        Text(food?.name ?? "Food item")
                            .font(.title)
                            .bold()

                        Spacer()

                        if let food = food {
                            Button {
                                foodController.toggleFavorite(food)
                            } label: {
                                Image(systemName: foodController.isFavorite(food) ? "heart.fill" : "heart")
                                    .foregroundStyle(.pink)
                            }
                        }
                    }

                    if let subtitle = food?.subtiltle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }

                    // Price
                    Text(String(format: "$%.2f", food?.price ?? 0))
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.pink)
                        .padding(.top, 4)

                    // Description
                    Text(food?.description ?? "Delicious food item.")
                        .font(.body)
                        .foregroundStyle(.gray)
                        .fixedSize(horizontal: false, vertical: true)

                    // Quantity selector
                    HStack(spacing: 16) {
                        Text("Quantity")
                            .font(.headline)

                        Spacer()

                        HStack(spacing: 16) {
                            Button {
                                if quantity > 1 { quantity -= 1 }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                            }

                            Text("\(quantity)")
                                .font(.headline)
                                .frame(width: 32)

                            Button {
                                if quantity < 20 { quantity += 1 }
                            } label: {
                                Image(systemName: "plus.circle    fill")
                            }
                        }
                        .font(.title2)
                        .foregroundStyle(.pink)
                    }
                    .padding(.top, 8)

                    // Add to cart button
                    Button {
                        if let food = food {
                            foodController.addToCart(food: food, quantity: quantity)
                            addedToCart = true
                        }
                    } label: {
                        Text("Add To Cart")
                            .font(.headline)
                            .bold()
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.pink)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .shadow(radius: 3)
                    }
                    .padding(.top, 16)

                    if addedToCart {
                        Text("Added to cart!")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                            .padding(.top, 4)
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    FoodDetailsPage(
        foodController: FoodOrderController(),
        food: Food(
            name: "Cheese Burger",
            category: "Burger",
            subtiltle: "With extra cheese",
            price: 9.99,
            imagePath: "bur1",
            description: "A tasty burger with fresh ingredients and melted cheese."
        )
    )
}

