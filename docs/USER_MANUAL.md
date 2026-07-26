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

## 3. Step-by-Step Usage Guide

### A. The Wagon Control Center (Dashboard)
When you open the app, you land on the **Wagon Control Center**. This is your main dashboard.

**What you can do here:**
- **View Active Operations**: The top cards show you exactly how many Wagons are active, how many Trucks are in the system, and the total number of Cartons loaded today.
- **Filter**: Use the chips (`All`, `Planning`, `Loading`, `Completed`) to filter the list of Wagons.
- **Create a New Wagon**: Tap the large floating `+ Create Wagon` button at the bottom.

**How to Create a Wagon:**
1. Tap `+ Create Wagon`.
2. A sleek bottom sheet will slide up.
3. Enter the **Wagon Number** (e.g., `W-1002-IND`).
4. Enter the Origin and Destination.
5. Set the expected number of Trucks needed to fill this Wagon.
6. Tap **Create Wagon**.
*The Wagon will now appear in your list with a "Planning" status.*

---

### B. Managing a Wagon (Wagon Details)
Tap on any Wagon in the dashboard to open its **Wagon Details Screen**.

**What you can do here:**
- **View Progress**: See a visual progress bar indicating how many trucks have been loaded versus how many are expected.
- **Add a Truck**: Tap the `+ Add Truck` button.
- **Manage Trucks**: You will see a list of all trucks assigned to this Wagon. Tap any truck to manage its loading session.
- **Delete Wagon**: If a mistake was made, tap the red trash can icon in the top right. *Warning: You will be required to manually type the Wagon Number to confirm deletion. This will also delete all associated trucks and layers!*

---

### C. Creating & Managing Trucks
When you tap `+ Add Truck` from the Wagon Details screen, you register a new vehicle for loading.

**How to Create a Truck:**
1. Enter the **Vehicle Number** (the license plate or internal fleet number, e.g., `V-101`).
2. Enter the **Driver Name** and **Driver Mobile Number** (optional, but recommended).
3. Enter the Carrier Company.
4. Tap **Register Truck**.

Once registered, tap the Truck in the list to open the **Truck Details Screen**. This acts as your "Loading Workspace".
From here, you can see the Driver Details and most importantly, tap **Open AI Camera** to begin the physical loading process.

---

### D. The AI Camera Experience
This is the flagship feature of SmartLoad. You use this screen while standing at the loading dock, pointing your device at the back of the truck.

**How to capture a Layer:**
1. Tap **Open AI Camera** from the Truck Details screen.
2. Align the back of the truck within the **blue dashed alignment guide**.
3. Wait for the `Quality Indicator` (top left) to turn green (`EXCELLENT`).
4. Look at the `AI Status Card` (floating on the right). It will say "Ready" when the AI model is stable.
5. Look at the `Live Counter Bar` (bottom). It shows the real-time AI detection count.
6. Tap the large **Capture Layer** button (bottom right).
7. The app will freeze the frame, draw bounding boxes around every detected carton, and ask you to confirm.
8. If the count looks correct, tap **Confirm & Save**. If the AI missed a box, tap **Reject & Retake**.

Every confirmed layer is permanently logged to the truck, and the total carton count goes up automatically!

---

### E. Completing the Process
1. **Complete the Truck**: Once the truck is fully packed with layers, go back to the Truck Details screen and tap the "Complete Session" button. Its status will change to `Completed`.
2. **Complete the Wagon**: Once all expected trucks for a Wagon are marked as Completed, the Wagon itself will transition to `Completed`.
3. **Digital Registers**: Tap the document icon in the top right of the main dashboard to view **Digital Registers**. This automatically generates a professional exportable report of the Wagon, listing every single Truck, Driver, Time, and exact Carton counts—ready to be printed or emailed. No paper required!

---

## 4. Troubleshooting & Developer Tools

- **Data Not Showing?**: Tap the **Refresh** icon in the top right of the dashboard, or simply pull down on the list. The app is offline-first, but this forces a strict UI recalculation.
- **Empty Screen?**: If you just installed the app and want to test it without typing everything manually, tap the **Bug Icon 🐞** in the top right of the dashboard. This will forcefully inject dummy demo data (Wagons, Trucks, and Layers) into your app so you can play around with the UI.
- **Dataset Mode**: Tap the Photo Library icon in the top right to access the "Dataset Developer Mode" (used by engineers to review raw images and AI bounding boxes for model retraining).

---
*End of User Manual. Property of Vinayak Logistics.*
