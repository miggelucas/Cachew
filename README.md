# 🌰 Cachew

**Meet Cachew! It's a friendly, modern, and super safe framework for all your caching needs in Swift.**

Caching is the secret to a great user experience—it makes your app faster, saves network data, and even enables offline use. Cachew is a lightweight tool designed to make caching simple and safe, built from scratch with modern Swift features like `Actors` for concurrency-safety and a flexible, protocol-based design.

Whether you need to store something for a split second or for days, Cachew has you covered!

## ✨ Features

-   ✅ **Concurrency-Safe by Default:** Built on Swift `Actors`, Cachew handles all threading logic for you, preventing data races automatically.
    
-   📦 **Modular & Simple:** The code is neatly organized but bundled into a single library. You get a clean API without the clutter.
    
-   🧠 **`Stash` (In-Memory Cache):** A blazing-fast memory cache, perfect for frequently accessed data within a single app session.
    
-   💾 **`Silo` (Disk Cache):** A persistent disk cache that saves `Codable` objects to files, ensuring data isn't lost when the app closes.
    
-   🧪 **Highly Testable:** Designed with Dependency Injection, making it a breeze to write isolated unit tests for your own code.
    
-   **Modern Tooling:** Uses the `Swift-Testing` framework to ensure every piece of the library is reliable.
    

## 📋 Requirements

-   iOS 14.0+
    
-   macOS 11.0+
    
-   Swift 5.9+
    

## 🚀 Installation

Add Cachew to your project using the **Swift Package Manager**. In Xcode, go to **File > Add Packages...** and paste the repository URL:

```
https://github.com/miggelucas/Cachew

```

Next, select the `Cachew` library product and add it to your app's target.

## 💡 How to Use

The entire library is available with a single import. Both `Stash` and `Silo` conform to the `Storable` protocol for a consistent API.

```
import Cachew

```

### Defining Your Objects

To save objects to the `Silo` (disk cache), they must conform to `Codable` and `Sendable`. Most standard Swift types already work out of the box!

```
// Your data model just needs to conform to Codable and Sendable
struct User: Codable, Sendable, Equatable {
    let id: Int
    let name: String
}

```

### Using `Stash` (In-Memory Cache)

`Stash` is perfect for temporary data you need to access quickly.

```
// Create a Stash instance
let stash = Stash<String, User>()

// Store an object
let currentUser = User(id: 1, name: "Thom Yorke")
await stash.setValue(currentUser, forKey: "currentUser")

// Retrieve the object later
if let cachedUser = await stash.value(forKey: "currentUser") {
    print("User found in Stash: \(cachedUser.name)") // "Thom Yorke"
}

```

### Using `Silo` (Disk Cache)

`Silo` saves your `Codable` objects to disk, ensuring they persist between app launches.

```
// Create a Silo instance, giving it a unique name for its directory
do {
    let userSilo = try Silo<String, User>(cacheName: "RadioheadBand")

    // Store an object
    let userToSave = User(id: 42, name: "Jonny Greenwood")
    try await userSilo.setValue(userToSave, forKey: "user_42")

    // Retrieve the object, even after restarting the app
    if let savedUser = try await userSilo.value(forKey: "user_42") {
        print("User found in Silo: \(savedUser.name)") // "Jonny Greenwood"
    }
    
} catch {
    // It's important to handle errors for disk operations.
    print("A Silo error occurred: \(error)")
}

```

## 🛣️ Roadmap

Cachew is actively being developed! Here's what's next:

-   [ ] **Expiration Policies:** Set a Time-to-Live (TTL) for cached objects.
    
-   [ ] **Size Limits:** Implement count and memory cost limits for `Stash` and `Silo`.
    
-   [ ] **`HybridCache`:** A unified cache that automatically uses `Stash` and `Silo` together.
    
-   [ ] **`Vault`:** A secure cache using the iOS Keychain for sensitive data.
    

## ❤️ Contributing

Contributions are always welcome! Feel free to open an _Issue_ or a _Pull Request_.

## 📄 License

Cachew is available under the MIT license. See the [LICENSE.md](LICENSE.md "null") file for more info.
