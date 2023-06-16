//
//  ContentView.swift
//  shopping basket
//
//  Created by Fatima Amantay on 10.06.2023.
//

import SwiftUI

// Data Models
struct Sneaker: Identifiable {
    let id: Int
    let name: String
    let price: Double
    // Add more properties as needed
}

struct User {
    var name: String
    var email: String
    // Add more properties as needed
}

// Main App

struct SneakerShopApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// ContentView (Entry Point)
struct ContentView: View {
    @AppStorage("isOnboardingViewPresented") var isOnboardingViewPresented: Bool = true
    @StateObject var userViewModel = UserViewModel()
    
    var body: some View {
        Group {
            if isOnboardingViewPresented {
                OnboardingView(isOnboardingViewPresented: $isOnboardingViewPresented)
            } else if userViewModel.isLoggedIn {
                MainView(userViewModel: userViewModel)
            } else {
                AuthenticationView(userViewModel: userViewModel)
            }
        }
    }
}

// Onboarding View
struct OnboardingView: View {
    @Binding var isOnboardingViewPresented: Bool
    
    var body: some View {
        // Implement your onboarding view content here
        Button(action: {
            isOnboardingViewPresented = false
        }) {
            Text("Get Started")
        }
    }
}

// Authentication Views
struct AuthenticationView: View {
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        // Implement your authentication views (Login and Sign Up)
        VStack {
            TextField("Email", text: $userViewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("Password", text: $userViewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button(action: {
                userViewModel.login()
            }) {
                Text("Log In")
            }
            Button(action: {
                userViewModel.signup()
            }) {
                Text("Sign Up")
            }
        }
    }
}

// Profile View
struct ProfileView: View {
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        // Implement your profile view content here
        Text("Name: \(userViewModel.user.name)")
        Text("Email: \(userViewModel.user.email)")
    }
}

// Main View
struct MainView: View {
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            ProfileView(userViewModel: userViewModel)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

// Home View
struct HomeView: View {
    var sneakers: [Sneaker] = [
        Sneaker(id: 1, name: "Sneaker 1", price: 99.99),
        Sneaker(id: 2, name: "Sneaker 2", price: 129.99),
        Sneaker(id: 3, name: "Sneaker 3", price: 149.99)
    ]
    
    var body: some View {
        // Implement your home view content here
        List(sneakers) { sneaker in
           
            SneakerItemView(sneaker: sneaker)
        }
    }
}

// Sneaker Item View
struct SneakerItemView: View {
    let sneaker: Sneaker
    
    var body: some View {
        // Implement your sneaker item view content here
        VStack {
            Image("sneakerImage") // Replace with actual image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 200)
            
            Text(sneaker.name)
                .font(.title)
                .padding()
            
            Text("$\(sneaker.price)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding()
            
            Button(action: {
                // Handle adding to cart
            }) {
                Text("Add to Cart")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}

// User ViewModel
class UserViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var user = User(name: "", email: "")
    var isLoggedIn: Bool {
        // Implement your login check logic here
        return !user.name.isEmpty && !user.email.isEmpty
    }
    
    func login() {
        // Implement login functionality
        // Authenticate user and update user properties
        user = User(name: "John Doe", email: email)
    }
    
    func signup() {
        // Implement signup functionality
        // Create a new user with provided details
        user = User(name: "Jane Smith", email: email)
    }
}
// Shopping Cart View
struct ShoppingCartView: View {
    @ObservedObject var cartViewModel: CartViewModel
    
    var body: some View {
        // Implement your shopping cart view content here
        VStack {
            List {
                ForEach(cartViewModel.cartItems) { cartItem in
                    HStack {
                        Text(cartItem.sneaker.name)
                        Spacer()
                        Text("\(cartItem.quantity)")
                    }
                }
                .onDelete(perform: deleteCartItem)
            }
            
            Text("Total: $\(cartViewModel.totalPrice)")
            
            Button(action: {
                // Implement checkout functionality
                cartViewModel.checkout()
            }) {
                Text("Checkout")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
    
    func deleteCartItem(at indexSet: IndexSet) {
        // Implement logic to delete a cart item at the given index
        cartViewModel.deleteCartItem(at: indexSet)
    }
}

// Cart Item Model
struct CartItem: Identifiable {
    let id = UUID()
    let sneaker: Sneaker
    var quantity: Int
}

// Cart ViewModel
class CartViewModel: ObservableObject {
    @Published var cartItems: [CartItem] = []
    
    var totalPrice: Double {
        return cartItems.reduce(0) { $0 + ($1.sneaker.price * Double($1.quantity)) }
    }
    
    func addSneakerToCart(_ sneaker: Sneaker) {
        if let existingIndex = cartItems.firstIndex(where: { $0.sneaker.id == sneaker.id }) {
            cartItems[existingIndex].quantity += 1
        } else {
            cartItems.append(CartItem(sneaker: sneaker, quantity: 1))
        }
    }
    
    func deleteCartItem(at indices: IndexSet) {
        cartItems.remove(atOffsets: indices)
    }
    
    func checkout() {
        // Implement checkout functionality
        // Clear the cart and perform payment processing
        cartItems.removeAll()
    }
}
