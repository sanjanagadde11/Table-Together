import SwiftUI

@main
struct DeliveryAppApp: App {
    @StateObject private var foodController = FoodOrderController()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(foodController)
        }
    }
}


struct RootView: View {
    @EnvironmentObject var foodController: FoodOrderController
    
    var body: some View {
        if foodController.isLoggedIn {
            HomePageView()
        } else {
            AuthFlowView()
        }
    }
}

#Preview {
    RootView()
        .environmentObject(FoodOrderController())
}

