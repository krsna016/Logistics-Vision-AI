const String userManualMarkdown = '''
# Vinayak SmartLoad - Comprehensive User Manual

Welcome to the **Vinayak SmartLoad** User Manual! This document provides an in-depth, step-by-step guide to everything you need to know to operate the system effectively.

---

## 1. What is Vinayak SmartLoad?

**Vinayak SmartLoad** is an enterprise-grade mobile application designed for Vinayak Logistics. Its primary purpose is to completely digitize the warehouse loading dock operations.

Historically, warehouse operators had to manually count cartons, track trucks on clipboards, and write paper "Wagon Registers" at the end of the day. SmartLoad fixes this by using:
- **Centralized Digital Dashboards**: Tracking Wagons and Trucks in real time.
- **AI-Powered Vision (YOLOv8)**: Using the device camera to automatically count "layers" of cartons loaded into trucks with extreme accuracy.
- **Automated Digital Registers**: Generating a final, exportable report (PDF/Excel) automatically once loading is completed.

---

## 2. Core Concepts & Terminology

Before using the app, it's crucial to understand the three main tiers of the workflow:

1. **Wagon**: The highest level of operation. A Wagon represents a massive bulk shipment heading to a destination. For example, a train wagon or a massive freight order. It requires multiple trucks to fill it.
2. **Truck (Vehicle)**: Trucks are the individual vehicles that carry goods from the warehouse out to the Wagon. Each Truck requires multiple *Layers* of cartons to fill.
3. **Layer**: A physical stack/row of cartons placed into the back of a Truck. Instead of counting individual boxes by hand, the operator snaps a photo of each "Layer" using the AI Camera, which counts the cartons instantly.

**The Workflow:**
`Create Wagon` ➡️ `Add Truck to Wagon` ➡️ `Capture AI Layers for Truck` ➡️ `Complete Truck` ➡️ `Complete Wagon` ➡️ `Generate Digital Register`

---

## 3. Understanding Status Tags

Throughout the app, you will see various colored tags or "chips" indicating the current state of a Wagon, Truck, or Loading Session. Here is exactly what each means:

### Wagon Status Tags
- **PLANNING (Grey)**: The wagon has been created, and trucks are being assigned, but no physical loading has commenced yet.
- **LOADING (Blue)**: Active loading is happening right now. At least one truck assigned to this wagon is currently being loaded.
- **COMPLETED (Green)**: The wagon is completely full. All expected trucks have been loaded and finalized. The Wagon is now locked and ready for digital register generation.

### Truck Status Tags
- **LOADING (Blue)**: The truck is actively receiving goods. The AI camera can be used to scan new layers.
- **COMPLETED (Green)**: The truck is fully packed. The operator has explicitly locked the truck session, preventing any further layers from being added.
- **ARCHIVED (Grey)**: The truck record is stored securely in the database for historical purposes but is completely hidden from active operational views.

### Session Status Tags
- **WAITING**: The AI engine is idling, waiting for the operator to initiate a scan.
- **LOADING**: The camera is active and the system is hunting for cartons to count.
- **PAUSED**: The active session has been paused, usually because the operator switched screens or the app was closed mid-session.
- **REVIEW**: The AI has captured a frame and is waiting for human confirmation before saving it to the database.

---

## 4. Step-by-Step Usage Guide

### A. The App Drawer & Global Navigation
Tap the **Vinayak Logistics Logo** in the top-left corner of the dashboard, or swipe from the left edge of the screen, to open the **App Navigation Drawer**. This drawer contains:
- **Wagon Control Center**: The main dashboard.
- **Digital Registers**: Access the completed, exportable PDF reports.
- **Refresh Data**: Force the app to synchronize with the database.
- **Dataset Developer Mode**: A tool for engineers to review raw image captures.
- **Load Demo Data**: Injects mock data for training and testing.

### B. The Wagon Control Center (Dashboard)
This is your main operational hub.
- **View Active Operations**: The top cards show you exactly how many Wagons are active, how many Trucks are in the system, and the total number of Cartons loaded today.
- **Filter**: Use the chips (`All`, `Planning`, `Loading`, `Completed`) to filter the list of Wagons.
- **Create a New Wagon**: Tap the large floating `+ Create Wagon` button at the bottom. Enter the Wagon Number (e.g., `W-1002-IND`), Origin, Destination, and Expected Trucks.

### C. Managing a Wagon & Adding Trucks
Tap on any Wagon in the dashboard to open its details.
- **Add a Truck**: Tap the `+ Add Truck` button. Enter the Vehicle Number, Driver details, and Carrier Company.
- **Delete Wagon**: If a mistake was made, tap the red trash can icon in the top right. *Warning: You will be required to manually type the Wagon Number to confirm deletion.*

### D. The Truck Loading Workspace
Tap a Truck in the list to open its Loading Workspace. 
1. Tap **Start Loading Session** to lock the truck into an active state. 
2. Tap **Capture Next Layer** to launch the AI Camera.
3. *Auto-Resume feature: If your app crashes or you close it by accident while a session is active, the app will instantly prompt you to resume your session the next time you open the dashboard!*

### E. The AI Camera Experience
This is the flagship feature of SmartLoad. You use this screen while standing at the loading dock.
1. Align the back of the truck within the **blue dashed alignment guide**.
2. Wait for the `Quality Indicator` (top left) to turn green (`EXCELLENT`).
3. Tap the large **Capture Layer** button (bottom right).
4. If the count looks correct, tap **Confirm & Save**. If the AI missed a box, tap **Reject & Retake**.
5. Every confirmed layer is permanently logged to the truck, and the total carton count goes up automatically!

### F. Completing the Process
1. **Complete the Truck**: Once the truck is fully packed, go back to the Truck Workspace and tap **Complete Loading Session**. It will show you a strict summary of your layers and cartons before locking the truck.
2. **Complete the Wagon**: Once all expected trucks for a Wagon are Complete, go back to the Wagon Details and tap **Complete Wagon**. If you try to complete a wagon before the expected trucks are loaded, the app will issue a strict warning!
3. **Digital Registers**: Once the Wagon is completed, it automatically generates a professional exportable report of the Wagon, listing every single Truck, Driver, Time, and exact Carton counts—ready to be printed or emailed. No paper required!

---
*End of User Manual. Property of Vinayak Logistics.*
''';
