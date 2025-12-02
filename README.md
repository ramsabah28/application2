# PocketStore

A modern Flutter-based e-commerce application specializing in 3D printed products with Firebase backend integration.

## 📱 Application Screenshots

### Image Library

<div align="center">

<table>
  <tr>
    <td align="center" width="25%">
      <img src="App-Images/Screenshot%202025-12-02%20at%2011.33.47.png" width="200" alt="Home Screen"/>
      <br><b>Home Screen</b>
      <br><small>Modern home interface with featured products and intuitive navigation</small>
    </td>
    <td align="center" width="25%">
      <img src="App-Images/Screenshot%202025-12-02%20at%2011.33.59.png" width="200" alt="Product Search"/>
      <br><b>Product List View</b>
      <br><small>Product catalog showing items in card format</small>
    </td>
    <td align="center" width="25%">
      <img src="App-Images/Screenshot%202025-12-02%20at%2011.34.09.png" width="200" alt="Search Results"/>
      <br><b>Category View</b>
      <br><small>Product view in cards for selected category</small>
    </td>
    <td align="center" width="25%">
      <img src="App-Images/Screenshot%202025-12-02%20at%2011.34.20.png" width="200" alt="Product Details"/>
      <br><b>Product Details</b>
      <br><small>Comprehensive product information and specifications</small>
    </td>
  </tr>
  <tr>
    <td align="center" width="25%">
      <img src="App-Images/Screenshot%202025-12-02%20at%2011.35.01.png" width="200" alt="3D Model View"/>
      <br><b>Single Product View</b>
      <br><small>Detailed product view with specifications and pricing</small>
    </td>
    <td align="center" width="25%">
      <img src="App-Images/Screenshot%202025-12-02%20at%2011.35.15.png" width="200" alt="Shopping Cart"/>
      <br><b>Shopping Cart</b>
      <br><small>Smart cart system with quantity controls and pricing</small>
    </td>
    <td align="center" width="25%">
      <img src="App-Images/Screenshot%202025-12-02%20at%2011.35.44.png" width="200" alt="Cart Management"/>
      <br><b>Invoice Overview</b>
      <br><small>Bill overview of ordered products with details</small>
    </td>
    <td align="center" width="25%">
      <img src="App-Images/Screenshot%202025-12-02%20at%2011.35.56.png" width="200" alt="Checkout Process"/>
      <br><b>Order Overview</b>
      <br><small>Overview of orders showing payment status</small>
    </td>
  </tr>
  <tr>
    <td align="center" width="25%">
      <img src="App-Images/Screenshot%202025-12-02%20at%2011.36.07.png" width="200" alt="User Profile"/>
      <br><b>User Address Data</b>
      <br><small>User address information and delivery details</small>
    </td>
    <td align="center" width="25%">
      <img src="App-Images/Screenshot%202025-12-02%20at%2011.36.17.png" width="200" alt="Account Settings"/>
      <br><b>Account Settings</b>
      <br><small>Personal information and preferences management</small>
    </td>
    <td align="center" width="25%">
      <img src="App-Images/Screenshot%202025-12-02%20at%2011.36.26.png" width="200" alt="Order History"/>
      <br><b>Favorites Overview</b>
      <br><small>Overview of favorite products and wishlist</small>
    </td>
    <td align="center" width="25%">
      <img src="App-Images/Screenshot%202025-12-02%20at%2011.36.36.png" width="200" alt="Order Details"/>
      <br><b>Product Reviews Overview</b>
      <br><small>Overview of rated and reviewed products</small>
    </td>
  </tr>
  <tr>
    <td align="center" width="25%">
      <img src="App-Images/Screenshot%202025-12-02%20at%2011.36.46.png" width="200" alt="Favorites"/>
      <br><b>Written Reviews Overview</b>
      <br><small>Overview of reviews written by the user</small>
    </td>
    <td align="center" width="25%">
      <img src="App-Images/Screenshot%202025-12-02%20at%2011.36.58.png" width="200" alt="Wishlist Management"/>
      <br><b>Customer-Admin Chat</b>
      <br><small>Chat interface between customer and admin</small>
    </td>
    <td align="center" width="25%">
      <img src="App-Images/Screenshot%202025-12-02%20at%2011.37.12.png" width="200" alt="Chat System"/>
      <br><b>Search Overview</b>
      <br><small>Search interface with results display</small>
    </td>
    <td align="center" width="25%">
      <img src="App-Images/Screenshot%202025-12-02%20at%2011.38.32.png" width="200" alt="Live Chat"/>
      <br><b>Search Results View</b>
      <br><small>Search overview with different search terms</small>
    </td>
  </tr>
</table>

</div>

## 🚀 Key Features

### 📱 Core Functionality
- **Modern Home Interface**: Clean and intuitive design with easy navigation
- **Product Catalog**: Browse products in card format by categories
- **Advanced Search**: Search products by name, brand, and category with live results
- **Product Details**: Comprehensive single product view with specifications

### 🛒 Shopping & Order Management
- **Smart Cart System**: Add products to cart with quantity management
- **Invoice Management**: Detailed bill overview of ordered products
- **Order Overview**: Track orders and view payment status
- **Order History**: Complete purchase tracking and status updates

### 👤 User Management & Profile
- **Address Management**: Manage user delivery addresses and contact information
- **Account Settings**: Personal information and preferences management
- **Favorites System**: Save favorite products and manage wishlists
- **Review System**: Write and manage product reviews and ratings

### 💬 Communication & Reviews
- **Customer Support Chat**: Real-time chat between customers and admin
- **Review Management**: Overview of written reviews and product ratings
- **Search Interface**: Advanced search functionality with multiple search terms
- **User Feedback**: Comprehensive review and rating system

## 🛠 Technical Stack

### Frontend
- **Flutter**: Cross-platform mobile development
- **Dart**: Programming language
- **Material Design**: Modern UI components
- **State Management**: Stateful widgets and providers

### Backend & Services
- **Firebase Authentication**: Secure user authentication
- **Cloud Firestore**: Real-time NoSQL database
- **Firebase Functions**: Serverless backend functions
- **Firebase Storage**: File and image storage

### Key Dependencies
```yaml
dependencies:
  flutter: sdk: flutter
  firebase_core: ^4.2.0
  firebase_auth: ^6.1.1
  cloud_firestore: ^6.0.3
  cloud_functions: ^6.0.3
  image_picker: ^1.2.0
  uuid: ^4.5.1
  in_app_purchase: ^3.2.1
  printing: ^5.13.4
  webview_flutter: ^4.10.1
```

## 📱 Supported Platforms

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 15.0+)
- ✅ **Web** (Progressive Web App)
- ✅ **macOS** (Desktop support)

## 🚦 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Firebase project setup
- Android Studio / Xcode for device testing

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/ramsabah28/application2.git
   cd application2
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Add your `google-services.json` (Android) to `android/app/`
   - Add your `GoogleService-Info.plist` (iOS) to `ios/Runner/`
   - Update `lib/firebase_options.dart` with your Firebase configuration

4. **Run the application**
   ```bash
   flutter run
   ```

## 🏗 Project Structure

```
lib/
├── main.dart                 # Application entry point
├── firebase_options.dart     # Firebase configuration
├── src/
    ├── component/           # UI components
    │   ├── features/       # Feature-specific widgets
    │   ├── profile/        # Profile-related screens
    │   └── homeScreenFeatures/ # Home screen components
    ├── data/               # Data layer and utilities
    ├── models/             # Data models
    ├── repository/         # Data repositories
    ├── services/           # Business logic services
    └── payment/            # Payment processing
```

## 🔑 Key Features Implementation

### 3D Model Integration
- Interactive 3D product visualization
- Multiple viewing angles and zoom capabilities
- Cross-platform 3D rendering support

### Real-time Features
- Live search with instant results
- Real-time stock updates
- Live chat support
- Push notifications for order updates

### E-commerce Functionality
- Secure payment processing
- Inventory management
- Order tracking system
- Multi-currency support
- Tax calculation

### User Experience
- Offline capability
- Dark/Light theme support
- Multi-language support (German interface)
- Accessibility features
- Responsive design

## 🔒 Security Features

- **Firebase Authentication**: Multi-factor authentication support
- **Secure Payments**: PCI DSS compliant payment processing
- **Data Encryption**: End-to-end encryption for sensitive data
- **Input Validation**: Comprehensive input sanitization
- **Session Management**: Secure session handling

## 📊 Performance Optimizations

- **Image Optimization**: Compressed images with lazy loading
- **Caching Strategy**: Smart caching for better performance
- **Database Optimization**: Efficient Firestore queries
- **Code Splitting**: Modular code architecture
- **State Management**: Optimized state updates

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Generate coverage report
flutter test --coverage
```

## 📈 Future Enhancements

- [ ] AI-powered product recommendations
- [ ] Augmented Reality (AR) product preview
- [ ] Voice search functionality
- [ ] Advanced analytics dashboard
- [ ] Multi-vendor marketplace support
- [ ] Subscription-based services

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- 📧 Email: support@pocketstore.com
- 💬 Live Chat: Available in the app
- 📚 Documentation: [Wiki](https://github.com/ramsabah28/application2/wiki)

## 📝 Changelog

### Version 1.0.0
- Initial release with core e-commerce functionality
- 3D model integration
- Firebase backend integration
- Cross-platform support

---

**Made with ❤️ using Flutter and Firebase**
