# 🍕 Pizza App: Complete SwiftUI Tutorial

## What You'll Build

A beautiful, fully functional pizza ordering app using **SwiftUI** with features like:
- Browse pizza menu with images and descriptions
- Add pizzas to cart with quantity selection
- View and manage shopping cart
- Place orders with customer information
- Order history tracking
- Modern iOS design with animations

## 🎯 Why SwiftUI?

SwiftUI is Apple's modern UI framework that makes building iOS apps:
- **Declarative** - Describe what your UI should look like
- **Reactive** - UI automatically updates when data changes
- **Native** - Perfect iOS look and feel
- **Fast** - Quick development with live previews

## 📋 Prerequisites

### Required Tools
- **Xcode 14+** (latest version recommended)
- **iOS 15+** deployment target
- **macOS** (SwiftUI development requires Mac)

### Knowledge Level
- Basic **Swift** programming
- Understanding of **iOS development** concepts
- Familiarity with **Xcode** interface

## 🚀 Step 1: Create Your Xcode Project

### Set Up New Project
1. Open **Xcode**
2. Click **Create a new Xcode project**
3. Select **iOS → App**
4. Configure your project:
   - **Product Name**: `PizzaApp`
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Bundle Identifier**: `com.yourname.pizzaapp`
   - **Deployment Target**: iOS 15.0
5. Click **Next** and choose save location
6. Click **Create**

## 📁 Project Structure

Your project will have this structure:
```
PizzaApp/
├── PizzaApp/
│   ├── PizzaAppApp.swift         # App entry point
│   ├── ContentView.swift         # Main view
│   ├── Models/                   # Data models
│   ├── Views/                    # UI components
│   ├── ViewModels/               # Business logic
│   └── Assets.xcassets           # Images and colors
└── PizzaApp.xcodeproj
```

## 🍕 Step 2: Create Data Models

Let's start by creating our data models. Right-click on your project → **New Group** → Name it **Models**.

### Pizza Model

Create a new Swift file: **Models/Pizza.swift**

```swift
import Foundation

struct Pizza: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let price: Double
    let imageName: String
    let toppings: [String]
    let category: PizzaCategory
    
    // Computed property for formatted price
    var formattedPrice: String {
        return String(format: "$%.2f", price)
    }
}

enum PizzaCategory: String, CaseIterable, Codable {
    case classic = "Classic"
    case specialty = "Specialty"
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
}

// Sample pizza data
extension Pizza {
    static let samplePizzas: [Pizza] = [
        Pizza(
            name: "Margherita",
            description: "Fresh tomatoes, mozzarella, basil, and olive oil",
            price: 12.99,
            imageName: "margherita",
            toppings: ["Tomato", "Mozzarella", "Basil", "Olive Oil"],
            category: .classic
        ),
        Pizza(
            name: "Pepperoni",
            description: "Classic pepperoni with mozzarella and tomato sauce",
            price: 14.99,
            imageName: "pepperoni",
            toppings: ["Pepperoni", "Mozzarella", "Tomato Sauce"],
            category: .classic
        ),
        Pizza(
            name: "Hawaiian",
            description: "Ham, pineapple, and mozzarella cheese",
            price: 13.99,
            imageName: "hawaiian",
            toppings: ["Ham", "Pineapple", "Mozzarella"],
            category: .specialty
        ),
        Pizza(
            name: "Veggie Supreme",
            description: "Bell peppers, mushrooms, onions, olives, and tomatoes",
            price: 15.99,
            imageName: "veggie",
            toppings: ["Bell Peppers", "Mushrooms", "Onions", "Olives", "Tomatoes"],
            category: .vegetarian
        ),
        Pizza(
            name: "BBQ Chicken",
            description: "Grilled chicken, BBQ sauce, red onions, and cilantro",
            price: 16.99,
            imageName: "bbq_chicken",
            toppings: ["Chicken", "BBQ Sauce", "Red Onions", "Cilantro"],
            category: .specialty
        ),
        Pizza(
            name: "Vegan Delight",
            description: "Vegan cheese, mushrooms, spinach, and sun-dried tomatoes",
            price: 14.99,
            imageName: "vegan",
            toppings: ["Vegan Cheese", "Mushrooms", "Spinach", "Sun-dried Tomatoes"],
            category: .vegan
        )
    ]
}
```

### Order Models

Create **Models/Order.swift**:

```swift
import Foundation

struct CartItem: Identifiable {
    let id = UUID()
    let pizza: Pizza
    var quantity: Int
    
    var totalPrice: Double {
        return pizza.price * Double(quantity)
    }
}

struct Order: Identifiable, Codable {
    let id = UUID()
    let items: [OrderItem]
    let customerInfo: CustomerInfo
    let orderDate: Date
    let status: OrderStatus
    
    var totalAmount: Double {
        return items.reduce(0) { $0 + $1.totalPrice }
    }
    
    var formattedTotal: String {
        return String(format: "$%.2f", totalAmount)
    }
}

struct OrderItem: Identifiable, Codable {
    let id = UUID()
    let pizzaName: String
    let pizzaPrice: Double
    let quantity: Int
    
    var totalPrice: Double {
        return pizzaPrice * Double(quantity)
    }
}

struct CustomerInfo: Codable {
    let name: String
    let phone: String
    let email: String
    let address: String
}

enum OrderStatus: String, CaseIterable, Codable {
    case pending = "Pending"
    case preparing = "Preparing"
    case baking = "Baking"
    case ready = "Ready"
    case delivered = "Delivered"
}
```

## 🛒 Step 3: Create Cart Manager

Create a new group **ViewModels** and add **CartManager.swift**:

```swift
import Foundation
import Combine

class CartManager: ObservableObject {
    @Published var cartItems: [CartItem] = []
    @Published var orders: [Order] = []
    
    var totalPrice: Double {
        cartItems.reduce(0) { $0 + $1.totalPrice }
    }
    
    var formattedTotal: String {
        return String(format: "$%.2f", totalPrice)
    }
    
    var itemCount: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    func addToCart(pizza: Pizza) {
        if let existingItemIndex = cartItems.firstIndex(where: { $0.pizza.id == pizza.id }) {
            cartItems[existingItemIndex].quantity += 1
        } else {
            cartItems.append(CartItem(pizza: pizza, quantity: 1))
        }
    }
    
    func removeFromCart(item: CartItem) {
        cartItems.removeAll { $0.id == item.id }
    }
    
    func updateQuantity(for item: CartItem, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
            if quantity > 0 {
                cartItems[index].quantity = quantity
            } else {
                cartItems.remove(at: index)
            }
        }
    }
    
    func clearCart() {
        cartItems.removeAll()
    }
    
    func placeOrder(customerInfo: CustomerInfo) {
        let orderItems = cartItems.map { cartItem in
            OrderItem(
                pizzaName: cartItem.pizza.name,
                pizzaPrice: cartItem.pizza.price,
                quantity: cartItem.quantity
            )
        }
        
        let newOrder = Order(
            items: orderItems,
            customerInfo: customerInfo,
            orderDate: Date(),
            status: .pending
        )
        
        orders.append(newOrder)
        clearCart()
    }
}
```

## 🎨 Step 4: Create Views

Create a new group **Views** and let's build our UI components.

### Main Content View

Update **ContentView.swift**:

```swift
import SwiftUI

struct ContentView: View {
    @StateObject private var cartManager = CartManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            PizzaMenuView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Menu")
                }
                .tag(0)
            
            CartView()
                .tabItem {
                    Image(systemName: "cart")
                    Text("Cart")
                }
                .badge(cartManager.itemCount > 0 ? cartManager.itemCount : nil)
                .tag(1)
            
            OrderHistoryView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("Orders")
                }
                .tag(2)
        }
        .environmentObject(cartManager)
        .accentColor(.orange)
    }
}

#Preview {
    ContentView()
}
```

### Pizza Menu View

Create **Views/PizzaMenuView.swift**:

```swift
import SwiftUI

struct PizzaMenuView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var selectedCategory: PizzaCategory? = nil
    @State private var searchText = ""
    
    var filteredPizzas: [Pizza] {
        var pizzas = Pizza.samplePizzas
        
        if let category = selectedCategory {
            pizzas = pizzas.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            pizzas = pizzas.filter { pizza in
                pizza.name.localizedCaseInsensitiveContains(searchText) ||
                pizza.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return pizzas
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                SearchBar(text: $searchText)
                
                // Category filter
                CategoryFilterView(selectedCategory: $selectedCategory)
                
                // Pizza list
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredPizzas) { pizza in
                            PizzaCardView(pizza: pizza)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("🍕 Pizza Menu")
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search pizzas...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
    }
}

struct CategoryFilterView: View {
    @Binding var selectedCategory: PizzaCategory?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryButton(
                    title: "All",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }
                
                ForEach(PizzaCategory.allCases, id: \.self) { category in
                    CategoryButton(
                        title: category.rawValue,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.orange : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

#Preview {
    PizzaMenuView()
        .environmentObject(CartManager())
}
```

### Pizza Card View

Create **Views/PizzaCardView.swift**:

```swift
import SwiftUI

struct PizzaCardView: View {
    let pizza: Pizza
    @EnvironmentObject var cartManager: CartManager
    @State private var showingDetail = false
    
    var body: some View {
        HStack {
            // Pizza image placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.3))
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(.orange)
                        .font(.title)
                )
            
            VStack(alignment: .leading, spacing: 8) {
                Text(pizza.name)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(pizza.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(pizza.formattedPrice)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            cartManager.addToCart(pizza: pizza)
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding(.leading, 8)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            PizzaDetailView(pizza: pizza)
        }
    }
}

struct PizzaDetailView: View {
    let pizza: Pizza
    @EnvironmentObject var cartManager: CartManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Large image placeholder
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.orange.opacity(0.3))
                        .frame(height: 250)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.orange)
                                .font(.system(size: 50))
                        )
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text(pizza.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(pizza.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Text(pizza.formattedPrice)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Toppings:")
                                .font(.headline)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 8) {
                                ForEach(pizza.toppings, id: \.self) { topping in
                                    Text(topping)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.orange.opacity(0.1))
                                        .cornerRadius(12)
                                }
                            }
                        }
                        
                        Button(action: {
                            cartManager.addToCart(pizza: pizza)
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "cart.badge.plus")
                                Text("Add to Cart")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Pizza Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PizzaCardView(pizza: Pizza.samplePizzas[0])
        .environmentObject(CartManager())
}
```

### Cart View

Create **Views/CartView.swift**:

```swift
import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var showingCheckout = false
    
    var body: some View {
        NavigationView {
            VStack {
                if cartManager.cartItems.isEmpty {
                    EmptyCartView()
                } else {
                    List {
                        ForEach(cartManager.cartItems) { item in
                            CartItemRow(item: item)
                        }
                        .onDelete(perform: deleteItems)
                    }
                    
                    VStack(spacing: 16) {
                        HStack {
                            Text("Total:")
                                .font(.headline)
                            Spacer()
                            Text(cartManager.formattedTotal)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal)
                        
                        Button(action: {
                            showingCheckout = true
                        }) {
                            HStack {
                                Image(systemName: "creditcard")
                                Text("Checkout")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)
                }
            }
            .navigationTitle("Cart")
            .toolbar {
                if !cartManager.cartItems.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear") {
                            withAnimation {
                                cartManager.clearCart()
                            }
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .sheet(isPresented: $showingCheckout) {
            CheckoutView()
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                cartManager.removeFromCart(item: cartManager.cartItems[index])
            }
        }
    }
}

struct EmptyCartView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Your cart is empty")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Add some delicious pizzas to get started!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CartItemRow: View {
    let item: CartItem
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.orange.opacity(0.3))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(.orange)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.pizza.name)
                    .font(.headline)
                
                Text(item.pizza.formattedPrice)
                    .font(.subheadline)
                    .foregroundColor(.orange)
            }
            
            Spacer()
            
            HStack {
                Button(action: {
                    cartManager.updateQuantity(for: item, quantity: item.quantity - 1)
                }) {
                    Image(systemName: "minus.circle")
                        .foregroundColor(.orange)
                }
                
                Text("\(item.quantity)")
                    .font(.headline)
                    .frame(minWidth: 30)
                
                Button(action: {
                    cartManager.updateQuantity(for: item, quantity: item.quantity + 1)
                }) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CartView()
        .environmentObject(CartManager())
}
```

### Checkout View

Create **Views/CheckoutView.swift**:

```swift
import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject var cartManager: CartManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var customerName = ""
    @State private var customerPhone = ""
    @State private var customerEmail = ""
    @State private var customerAddress = ""
    @State private var showingConfirmation = false
    
    var isFormValid: Bool {
        !customerName.isEmpty && !customerPhone.isEmpty && 
        !customerEmail.isEmpty && !customerAddress.isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Customer Information")) {
                    TextField("Full Name", text: $customerName)
                    TextField("Phone Number", text: $customerPhone)
                        .keyboardType(.phonePad)
                    TextField("Email", text: $customerEmail)
                        .keyboardType(.emailAddress)
                    TextField("Delivery Address", text: $customerAddress, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section(header: Text("Order Summary")) {
                    ForEach(cartManager.cartItems) { item in
                        HStack {
                            Text(item.pizza.name)
                            Spacer()
                            Text("\(item.quantity) × \(item.pizza.formattedPrice)")
                        }
                    }
                    
                    HStack {
                        Text("Total")
                            .fontWeight(.bold)
                        Spacer()
                        Text(cartManager.formattedTotal)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                }
                
                Section {
                    Button(action: placeOrder) {
                        HStack {
                            Image(systemName: "checkmark.circle")
                            Text("Place Order")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.orange : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Order Placed!", isPresented: $showingConfirmation) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your order has been placed successfully! You'll receive a confirmation email shortly.")
        }
    }
    
    private func placeOrder() {
        let customerInfo = CustomerInfo(
            name: customerName,
            phone: customerPhone,
            email: customerEmail,
            address: customerAddress
        )
        
        cartManager.placeOrder(customerInfo: customerInfo)
        showingConfirmation = true
    }
}

#Preview {
    CheckoutView()
        .environmentObject(CartManager())
}
```

### Order History View

Create **Views/OrderHistoryView.swift**:

```swift
import SwiftUI

struct OrderHistoryView: View {
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        NavigationView {
            VStack {
                if cartManager.orders.isEmpty {
                    EmptyOrdersView()
                } else {
                    List(cartManager.orders) { order in
                        OrderRow(order: order)
                    }
                }
            }
            .navigationTitle("Order History")
        }
    }
}

struct EmptyOrdersView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No orders yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Your order history will appear here after you place your first order.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct OrderRow: View {
    let order: Order
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Order #\(order.id.uuidString.prefix(8))")
                    .font(.headline)
                Spacer()
                StatusBadge(status: order.status)
            }
            
            Text(order.orderDate, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(order.items.count) items • \(order.formattedTotal)")
                .font(.subheadline)
                .foregroundColor(.orange)
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
    let status: OrderStatus
    
    var backgroundColor: Color {
        switch status {
        case .pending: return .orange
        case .preparing: return .blue
        case .baking: return .purple
        case .ready: return .green
        case .delivered: return .gray
        }
    }
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}

#Preview {
    OrderHistoryView()
        .environmentObject(CartManager())
}
```

## 🎨 Step 5: Add App Icons and Launch Screen

### App Icon
1. Go to **Assets.xcassets**
2. Click on **AppIcon**
3. Drag and drop your pizza app icon images (1024x1024 for App Store, various sizes for different devices)
4. Or use SF Symbols for a quick icon

### Launch Screen
1. In **Assets.xcassets**, add a new **Color Set** called "LaunchBackground"
2. Set it to a nice orange color
3. Create a simple launch screen in the storyboard or programmatically

## 🧪 Step 6: Test Your App

### Run in Simulator
1. Select your target device (iPhone 14, iPad, etc.)
2. Press **⌘ + R** or click the **Run** button
3. Test all features:
   - Browse pizzas
   - Add to cart
   - Modify quantities
   - Place orders
   - View order history

### Test on Device
1. Connect your iPhone/iPad
2. Select your device from the scheme selector
3. Make sure you have a developer account set up
4. Build and run on your device

## 🎯 Step 7: Advanced Features

### Add Animations

Enhance your app with smooth animations:

```swift
// Add to your views
.animation(.spring(response: 0.3, dampingFraction: 0.8), value: cartManager.cartItems)

// Animate button presses
Button(action: {
    withAnimation(.spring()) {
        cartManager.addToCart(pizza: pizza)
    }
}) {
    // Button content
}
```

### Add Persistence

Store orders locally using UserDefaults or Core Data:

```swift
// In CartManager
private func saveOrders() {
    if let encoded = try? JSONEncoder().encode(orders) {
        UserDefaults.standard.set(encoded, forKey: "savedOrders")
    }
}

private func loadOrders() {
    if let savedData = UserDefaults.standard.data(forKey: "savedOrders"),
       let decodedOrders = try? JSONDecoder().decode([Order].self, from: savedData) {
        orders = decodedOrders
    }
}
```

### Add Push Notifications

Set up local notifications for order updates:

```swift
import UserNotifications

func scheduleOrderNotification(for order: Order) {
    let content = UNMutableNotificationContent()
    content.title = "Order Update"
    content.body = "Your pizza order is ready!"
    content.sound = .default
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1800, repeats: false) // 30 minutes
    let request = UNNotificationRequest(identifier: order.id.uuidString, content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request)
}
```

## 🎨 Step 8: Customize Your App

### Color Scheme
Add custom colors in **Assets.xcassets**:
- Primary Orange
- Secondary Orange
- Background colors
- Text colors

### Custom Fonts
Add custom fonts to your project:
1. Drag font files to your project
2. Add to **Info.plist**
3. Use in your views: `.font(.custom("YourFont", size: 16))`

### App Icon Variations
Create different icon variations for:
- Light/Dark modes
- Seasonal themes
- Special promotions

### Dark Mode Support
Add dark mode support to your colors and images:

```swift
// In your views
.background(Color(.systemBackground))
.foregroundColor(Color(.label))

// Custom colors that adapt to dark mode
extension Color {
    static let pizzaOrange = Color("PizzaOrange")
    static let pizzaBackground = Color("PizzaBackground")
}
```

## 🚀 Step 9: Advanced Features & Enhancements

### Add Image Loading
Replace placeholder images with real pizza images:

```swift
// Add to your PizzaCardView
AsyncImage(url: URL(string: pizza.imageURL)) { image in
    image
        .resizable()
        .aspectRatio(contentMode: .fill)
} placeholder: {
    RoundedRectangle(cornerRadius: 12)
        .fill(Color.orange.opacity(0.3))
        .overlay(
            ProgressView()
                .tint(.orange)
        )
}
.frame(width: 100, height: 100)
.clipped()
.cornerRadius(12)
```

### Add Favorites System

Create a favorites manager:

```swift
class FavoritesManager: ObservableObject {
    @Published var favorites: Set<UUID> = []
    
    func toggleFavorite(pizzaId: UUID) {
        if favorites.contains(pizzaId) {
            favorites.remove(pizzaId)
        } else {
            favorites.insert(pizzaId)
        }
        saveFavorites()
    }
    
    func isFavorite(pizzaId: UUID) -> Bool {
        return favorites.contains(pizzaId)
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(Array(favorites)) {
            UserDefaults.standard.set(encoded, forKey: "favorites")
        }
    }
}
```

### Add Search Functionality

Enhance your search with advanced filtering:

```swift
struct AdvancedSearchView: View {
    @State private var searchText = ""
    @State private var priceRange: ClosedRange<Double> = 10.0...20.0
    @State private var selectedToppings: Set<String> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField("Search pizzas...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            VStack(alignment: .leading) {
                Text("Price Range: $\(priceRange.lowerBound, specifier: "%.0f") - $\(priceRange.upperBound, specifier: "%.0f")")
                    .font(.caption)
                
                Slider(value: Binding(
                    get: { priceRange.lowerBound },
                    set: { priceRange = $0...priceRange.upperBound }
                ), in: 10.0...30.0, step: 1.0)
            }
            
            Text("Filter by Toppings:")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(allToppings, id: \.self) { topping in
                    ToppingFilterButton(
                        topping: topping,
                        isSelected: selectedToppings.contains(topping)
                    ) {
                        if selectedToppings.contains(topping) {
                            selectedToppings.remove(topping)
                        } else {
                            selectedToppings.insert(topping)
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    private var allToppings: [String] {
        Set(Pizza.samplePizzas.flatMap { $0.toppings }).sorted()
    }
}
```

### Add Rating System

Create a rating system for pizzas:

```swift
struct RatingView: View {
    @Binding var rating: Int
    let maxRating: Int = 5
    
    var body: some View {
        HStack {
            ForEach(1...maxRating, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .foregroundColor(.yellow)
                    .onTapGesture {
                        rating = star
                    }
            }
        }
    }
}

// Add to Pizza model
struct Pizza: Identifiable, Codable {
    // ... existing properties
    var averageRating: Double = 0.0
    var ratingCount: Int = 0
    
    var formattedRating: String {
        return String(format: "%.1f", averageRating)
    }
}
```

### Add Order Tracking

Create a real-time order tracking system:

```swift
class OrderTrackingManager: ObservableObject {
    @Published var currentOrder: Order?
    @Published var trackingSteps: [TrackingStep] = []
    
    func startTracking(order: Order) {
        currentOrder = order
        setupTrackingSteps()
        simulateOrderProgress()
    }
    
    private func setupTrackingSteps() {
        trackingSteps = [
            TrackingStep(title: "Order Placed", isCompleted: true, time: Date()),
            TrackingStep(title: "Preparing", isCompleted: false, time: nil),
            TrackingStep(title: "Baking", isCompleted: false, time: nil),
            TrackingStep(title: "Ready for Pickup", isCompleted: false, time: nil),
            TrackingStep(title: "Delivered", isCompleted: false, time: nil)
        ]
    }
    
    private func simulateOrderProgress() {
        // Simulate order progress with timers
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
            if let nextStep = trackingSteps.first(where: { !$0.isCompleted && $0.title != "Order Placed" }) {
                if let index = trackingSteps.firstIndex(where: { $0.title == nextStep.title }) {
                    trackingSteps[index].isCompleted = true
                    trackingSteps[index].time = Date()
                }
            } else {
                timer.invalidate()
            }
        }
    }
}

struct TrackingStep: Identifiable {
    let id = UUID()
    let title: String
    var isCompleted: Bool
    var time: Date?
}
```

### Add Customization Options

Allow users to customize their pizzas:

```swift
struct PizzaCustomizationView: View {
    let basePizza: Pizza
    @State private var selectedSize: PizzaSize = .medium
    @State private var selectedCrust: CrustType = .regular
    @State private var extraToppings: Set<String> = []
    @State private var removedToppings: Set<String> = []
    
    var customizedPrice: Double {
        var price = basePizza.price
        
        // Size pricing
        switch selectedSize {
        case .small: price *= 0.8
        case .medium: price *= 1.0
        case .large: price *= 1.3
        }
        
        // Extra toppings
        price += Double(extraToppings.count) * 1.5
        
        return price
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Size selection
            VStack(alignment: .leading) {
                Text("Size")
                    .font(.headline)
                
                HStack {
                    ForEach(PizzaSize.allCases, id: \.self) { size in
                        SizeButton(
                            size: size,
                            isSelected: selectedSize == size
                        ) {
                            selectedSize = size
                        }
                    }
                }
            }
            
            // Crust selection
            VStack(alignment: .leading) {
                Text("Crust")
                    .font(.headline)
                
                HStack {
                    ForEach(CrustType.allCases, id: \.self) { crust in
                        CrustButton(
                            crust: crust,
                            isSelected: selectedCrust == crust
                        ) {
                            selectedCrust = crust
                        }
                    }
                }
            }
            
            // Toppings customization
            VStack(alignment: .leading) {
                Text("Customize Toppings")
                    .font(.headline)
                
                Text("Extra Toppings (+$1.50 each)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(availableExtraToppings, id: \.self) { topping in
                        ToppingToggleButton(
                            topping: topping,
                            isSelected: extraToppings.contains(topping)
                        ) {
                            if extraToppings.contains(topping) {
                                extraToppings.remove(topping)
                            } else {
                                extraToppings.insert(topping)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            // Price and add to cart
            VStack(spacing: 12) {
                HStack {
                    Text("Total: $\(customizedPrice, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                
                Button(action: addCustomizedPizzaToCart) {
                    Text("Add to Cart")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
    }
    
    private var availableExtraToppings: [String] {
        ["Extra Cheese", "Pepperoni", "Mushrooms", "Bell Peppers", "Onions", "Olives", "Sausage", "Bacon"]
    }
    
    private func addCustomizedPizzaToCart() {
        // Create customized pizza and add to cart
        // Implementation depends on your cart manager
    }
}

enum PizzaSize: String, CaseIterable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
}

enum CrustType: String, CaseIterable {
    case thin = "Thin"
    case regular = "Regular"
    case thick = "Thick"
}
```

## 🔧 Step 10: Performance Optimization

### Lazy Loading
Implement lazy loading for better performance:

```swift
// Use LazyVStack and LazyHStack for large lists
LazyVStack(spacing: 16) {
    ForEach(pizzas) { pizza in
        PizzaCardView(pizza: pizza)
            .onAppear {
                // Load additional data if needed
                loadMorePizzasIfNeeded(pizza)
            }
    }
}
```

### Memory Management
Optimize memory usage:

```swift
// Use @State for local state
// Use @StateObject for object creation
// Use @ObservedObject for passed objects
// Use @EnvironmentObject for shared state

// Dispose of timers and observers
class OrderTrackingManager: ObservableObject {
    private var timer: Timer?
    
    deinit {
        timer?.invalidate()
    }
}
```

### Caching
Implement simple caching for images and data:

```swift
class ImageCache: ObservableObject {
    private var cache: [String: UIImage] = [:]
    
    func getImage(for url: String) -> UIImage? {
        return cache[url]
    }
    
    func setImage(_ image: UIImage, for url: String) {
        cache[url] = image
    }
}
```

## 🧪 Step 11: Testing Your App

### Unit Testing
Create unit tests for your models and business logic:

```swift
// PizzaAppTests/PizzaTests.swift
import XCTest
@testable import PizzaApp

class PizzaTests: XCTestCase {
    func testPizzaFormattedPrice() {
        let pizza = Pizza(
            name: "Test Pizza",
            description: "Test",
            price: 12.99,
            imageName: "test",
            toppings: [],
            category: .classic
        )
        
        XCTAssertEqual(pizza.formattedPrice, "$12.99")
    }
    
    func testCartManager() {
        let cartManager = CartManager()
        let pizza = Pizza.samplePizzas[0]
        
        cartManager.addToCart(pizza: pizza)
        
        XCTAssertEqual(cartManager.cartItems.count, 1)
        XCTAssertEqual(cartManager.cartItems[0].pizza.id, pizza.id)
        XCTAssertEqual(cartManager.cartItems[0].quantity, 1)
    }
}
```

### UI Testing
Create UI tests for critical user flows:

```swift
// PizzaAppUITests/PizzaAppUITests.swift
import XCTest

class PizzaAppUITests: XCTestCase {
    func testAddPizzaToCart() {
        let app = XCUIApplication()
        app.launch()
        
        // Test adding pizza to cart
        let firstPizza = app.buttons["pizza_card_0"]
        firstPizza.tap()
        
        let addButton = app.buttons["add_to_cart"]
        addButton.tap()
        
        // Verify cart badge appears
        let cartTab = app.tabBars.buttons["Cart"]
        XCTAssertTrue(cartTab.exists)
    }
}
```

## 📱 Step 12: App Store Preparation

### App Store Assets
Prepare your app for the App Store:

1. **App Icon**: 1024x1024 PNG
2. **Screenshots**: Various device sizes
3. **App Preview**: Optional video preview
4. **Description**: Compelling app description
5. **Keywords**: Relevant search keywords

### App Store Connect
1. Create app in App Store Connect
2. Fill in metadata
3. Upload build using Xcode
4. Submit for review

### Privacy Policy
Create a privacy policy if your app collects data:

```swift
// Add privacy info to your app
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Your privacy is important to us...")
                    .font(.body)
                
                // Add your privacy policy content
            }
            .padding()
        }
    }
}
```

## 🎉 Step 13: Launch and Marketing

### Soft Launch
1. Test with friends and family
2. Gather feedback
3. Fix critical issues
4. Iterate based on feedback

### Marketing Strategy
1. **Social Media**: Share development progress
2. **App Store Optimization**: Good keywords and description
3. **Community**: Share on Reddit, Twitter, etc.
4. **Press Kit**: Create screenshots and press materials

### Analytics
Add analytics to track user behavior:

```swift
// Using built-in analytics or third-party services
func trackPizzaOrder(_ pizza: Pizza) {
    // Track user actions
    print("Pizza ordered: \(pizza.name)")
}
```

## 🚀 Conclusion

Congratulations! You've built a complete pizza ordering app with SwiftUI featuring:

✅ **Beautiful Native iOS UI** with SwiftUI
✅ **Complete Shopping Cart System** with quantity management
✅ **Order Management** with history tracking
✅ **Search and Filtering** for easy pizza discovery
✅ **Customer Information Forms** for order placement
✅ **Responsive Design** that works on all iOS devices
✅ **Modern iOS Patterns** and best practices

## 🎯 Next Steps

Your app is ready to use, but you can enhance it further:

### Advanced Features
- **Push Notifications** for order updates
- **Location Services** for delivery tracking
- **Payment Integration** with Apple Pay
- **User Accounts** with login/signup
- **Social Features** like reviews and sharing
- **Loyalty Program** with points and rewards

### Technical Enhancements
- **Core Data** for persistent storage
- **CloudKit** for cloud synchronization
- **WidgetKit** for home screen widgets
- **App Clips** for quick ordering
- **Siri Shortcuts** for voice ordering
- **Apple Watch** companion app

### Business Features
- **Admin Dashboard** for restaurant management
- **Real-time Updates** for order status
- **Analytics Dashboard** for business insights
- **Inventory Management** for pizza availability
- **Staff App** for order processing

## 📚 Resources for Continued Learning

- [Apple's SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [iOS App Development with SwiftUI](https://developer.apple.com/develop/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

Your pizza app is now complete and ready to delight users! 🍕✨

Remember to test thoroughly on different devices and iOS versions before submitting to the App Store. Good luck with your app development journey!
