const String userManualMarkdown = '''
# Vinayak SmartLoad - Complete Operations Handbook

This manual explains the complete mobile app in easy English. Follow it from top to bottom when learning the app for the first time. Use it later as a reference when an unusual situation occurs.

> Important: The app stores operational records such as wagons, vehicles, layers, item quantities, photos, corrections and reports. Always check information before saving. Use correction tools with a clear reason. Do not load demo data on a phone containing real work.

## Contents

1. Purpose and complete workflow
2. Important words and data hierarchy
3. Login, startup and logout
4. Wagon Control Center
5. Creating a wagon and item manifest
6. Wagon inventory and availability
7. Registering and editing a vehicle
8. Truck loading session
9. AI camera counting
10. Manual counting
11. Reviewing and correcting a layer
12. Mixed-item layers
13. Layer history, editing and removal
14. Completing and archiving a truck
15. Completing and archiving a wagon
16. Digital Register
17. PDF and Excel reports
18. Search, filters and refresh
19. Demo data
20. Data safety, audit and corrections
21. Common mistakes and troubleshooting
22. Complete worked example
23. Supervisor closing checklist

---

## 1. Purpose and complete workflow

SmartLoad records cartons moving from one wagon into one or more vehicles. It answers four important questions:

- What items and how many cartons arrived in the wagon?
- Which vehicle received each carton?
- Which layer contained each item?
- How many cartons are loaded and how many remain in the wagon?

### Normal workflow

`Login` -> `Create Wagon` -> `Enter Item Manifest` -> `Add Vehicle` -> `Start Loading` -> `Capture or Manually Enter Layer` -> `Review Items` -> `Save Layer` -> `Complete Vehicle` -> `Repeat for Other Vehicles` -> `Complete Wagon` -> `Open Digital Register` -> `Generate PDF or Excel` -> `Archive`

The app works wagon first. A vehicle belongs to a wagon, and a layer belongs to a vehicle. Item totals are calculated from saved layers. Reports are generated from the latest saved records.

---

## 2. Important words and data hierarchy

### Wagon

The source shipment. A wagon has a number, origin, destination, loading date, remarks and an item manifest.

### Item manifest

The supervisor's declared inventory at wagon creation. Each line contains an item name and its total cartons.

Example:

- Item A: 500 cartons
- Item B: 300 cartons
- Item C: 200 cartons
- Wagon manifest total: 1,000 cartons

### Vehicle

The receiving truck. The vehicle number entered during creation is the number shown in operational screens and reports.

### Loading session

The active work period for one vehicle. A session collects its saved layers and recalculates totals.

### Layer

One photographed or manually entered physical row or stack of cartons inside a vehicle. Every layer has a layer number, cartons, item allocation, defects, operator, time and optional notes or photo.

### Mixed-item layer

A layer containing more than one item. Example: Item A 40 cartons plus Item B 24 cartons equals 64 cartons.

### Defect

A carton marked defective in a layer. Defects are tracked separately from cartons and are summarized in vehicle, wagon and report totals.

### Digital Register

The consolidated historical view of one wagon, all its vehicles, all layers, item reconciliation, corrections, remarks and exports.

---

## 3. Login, startup and logout

### Login

1. Open SmartLoad.
2. Enter your employee ID or configured login identifier.
3. Enter your password.
4. Tap Login.
5. Wait for the Wagon Control Center.

The signed-in user's name is used as the operator and supervisor identity in new records. One logged-in session should therefore show one operator name for work performed in that session.

### Startup

The app prepares the shared AI counting engine during startup. It reuses the same engine for later layer captures. If the phone was closed during an active loading session, the app may offer Continue Loading. Choose Continue to return to that vehicle. Choose Discard only when the unfinished session should be cancelled.

### Logout

1. Open the menu in the upper-right of the Wagon Control Center.
2. Tap Logout.
3. Read the warning.
4. Confirm logout.

Logout ends the signed-in session. It does not delete operational data. Never share a signed-in phone with another operator without logging out first.

---

## 4. Wagon Control Center

This is the home screen.

### Summary cards

- Active Wagons: wagons currently being planned or loaded.
- Total Trucks: vehicles connected to current wagon records.
- Total Cartons: cartons recorded in vehicle layers.

### Wagon cards

Each card shows the wagon number, status, vehicle count, carton information and inventory progress. Tap a card to open Wagon Details.

### Search and filters

- Search by wagon information using the search field.
- All shows every available wagon.
- Planning shows created wagons whose loading has not started.
- Loading shows active wagon operations.
- Completed shows finalized wagon operations.
- Pull down to refresh totals after an edit.

### Main menu

- Digital Registers: historical wagon register and exports.
- Documentation: this English and Hindi handbook.
- Load Demo Data: deletes current operational test data and creates enterprise training data.
- Logout: ends the current user session.

---

## 5. Creating a wagon and item manifest

Tap Create Wagon on the Wagon Control Center.

### Wagon fields

- Wagon Number: required operational wagon identity. Use the number on the physical wagon.
- Scan button: opens the wagon-number camera. Confirm the detected value before saving.
- Origin: where the wagon came from. Use NIL only when genuinely unavailable.
- Destination: receiving location or route destination.
- Loading Date: date on which unloading or loading begins.
- Remarks: special instructions, seal information, condition or operational note.

### Item manifest

Add one row for every item present in the wagon.

For each row:

1. Enter a clear item name, such as `Soap 100g Blue`.
2. Enter its carton quantity as a positive whole number.
3. Use Add Item for another item.
4. Remove an unused blank row before saving.
5. Check that there are no duplicate names or spelling variations.

Good example:

- `Item A` - 120 cartons
- `Item B` - 80 cartons
- Total inventory - 200 cartons

Bad example:

- `Item A` - 120
- `item a` - 20

These may be treated as two different items. Use exactly one spelling.

### Save behavior

After saving, the wagon begins in Planning. Adding the first vehicle moves it into Loading. The manifest becomes the upper limit used when allocating items to layers.

### Editing a wagon later

Use the pencil icon in Wagon Details or Digital Register. You may change wagon information and manifest totals, but:

- An item total cannot be reduced below cartons already loaded.
- A loaded item cannot be removed from the manifest.
- Increasing an item total is allowed when the original manifest was too low and the supervisor has verified the change.

---

## 6. Wagon inventory and availability

The Wagon Item Inventory card shows:

- Total: declared manifest cartons.
- Loaded: cartons assigned through saved layers in all vehicles.
- Remaining: Total minus Loaded.

Example:

- Item A Total 120, Loaded 75, Remaining 45
- Item B Total 80, Loaded 50, Remaining 30
- Wagon Total 200, Loaded 125, Remaining 75

Inventory changes only after a layer is successfully saved, corrected or removed. A captured photo that is not saved does not change inventory.

If a layer correction changes Item A from 20 to 15 and Item B from 10 to 15, the layer remains 30 cartons, while item-wise totals are recalculated.

The app blocks an operator from assigning more of an item than is currently available. When correcting an existing layer, that layer's current cartons are temporarily returned to availability before the new values are checked.

---

## 7. Registering and editing a vehicle

Open Wagon Details and tap Add Truck or Register Truck.

### Vehicle fields

- Vehicle Number: required. Enter the registration number used during creation. This is displayed in the Digital Register and reports.
- Scan icon: photographs and reads the number plate. Always compare the result with the physical plate.
- Driver Name: optional, but recommended.
- Driver Mobile Number: optional contact number.
- Carrier Company: optional transport company.
- Warehouse Facility: optional receiving warehouse.
- Notes: route, gate pass, seal or other vehicle-specific information.

### Example

- Vehicle Number: RJ14GB4521
- Driver: Ramesh Kumar
- Mobile: 9876543210
- Carrier: Vinayak Transport
- Warehouse: Jaipur Central

### Editing

Open Truck Details and tap the pencil icon. The same details may be corrected. Archived vehicles can be corrected through Digital Register -> Truck Details. Historical edits should be made only by an authorized supervisor.

### Removing a vehicle

The delete action removes the vehicle and its layers from active views and future reports. A strict confirmation is required. Use it only for a duplicate or invalid vehicle. For a valid completed historical record, prefer archive instead of delete.

---

## 8. Truck loading session

Open a vehicle from Wagon Details.

### Truck Details shows

- Vehicle identity and status
- Driver, carrier and warehouse
- Wagon inventory information
- Total layers, cartons and defects
- Layer History with photos, items, operator and time

### Starting work

1. Tap Start Loading Session.
2. Check that this is the correct vehicle.
3. Tap Capture Layer.
4. Choose AI or Manual mode from the capture workspace.

Only one active workflow should be used for the physical vehicle being loaded. If the app offers to resume another active session, resolve it before capturing new work.

---

## 9. AI camera counting

AI mode counts visible cartons from a captured layer image.

### Before capture

- Clean the camera lens.
- Stand squarely in front of the layer.
- Keep the complete layer inside the frame.
- Avoid strong glare, deep shadow and motion blur.
- Do not include workers or unrelated carton piles where possible.
- Wait until the preview is ready.

### Capture procedure

1. Select AI mode.
2. Align the layer in the guide.
3. Use flash only when necessary.
4. Hold the phone steady.
5. Tap Capture Layer.
6. Wait for analysis and the Review Layer Scan screen.

The active engine uses the packaged segmentation model to find carton shapes. AI is an assistant, not the final authority. The operator must inspect every result.

### If the camera is interrupted

The app may show Preparing Camera after screen lock, app switching or a system overlay. Wait for the live preview. Use Retry Camera if offered. Do not save a layer when the image is missing or incorrect.

---

## 10. Manual counting

Use Manual mode when AI capture is unsuitable, the camera view is difficult, or a verified physical count is already available.

1. Switch from AI to Manual using the mode selector or horizontal swipe.
2. Capture a reference photo. Retake it if the layer is unclear.
3. Enter total cartons.
4. Enter defects.
5. Enter optional notes.
6. Enter the item breakdown when the wagon has a manifest.
7. Confirm that item quantities equal total cartons.
8. Tap Save Layer.

The reference photo supports later audit. Manual count does not mean unverified count. Physically count the cartons before saving.

---

## 11. Reviewing and correcting a layer

The Review Layer Scan screen is the final checkpoint before saving.

### What to inspect

- Reference photo
- AI boxes or outlines
- Number labels
- AI count
- Corrected final count
- Defect count
- Item breakdown
- Notes

### Correcting detection

If AI missed a carton, add the missing carton marker or increase the verified count using the available correction controls. If AI counted an object twice, remove the incorrect detection. Use reset or undo when a correction was accidental.

### Save rules

- Final cartons must be a valid non-negative count.
- Item allocations must total exactly the final cartons.
- Each item can appear only once in the breakdown.
- Item quantities cannot exceed wagon availability.
- A failed final verification requires a retake.

Tap Save only after the photo, count and items agree. A successful save creates the next layer number and updates vehicle and wagon totals.

---

## 12. Mixed-item layers

A single layer may contain several wagon items.

Example:

- Item A: 40 cartons
- Item B: 24 cartons
- Total layer cartons: 64

### Correct entry

1. Open Layer Item Breakdown.
2. Enter 40 beside Item A.
3. Enter 24 beside Item B.
4. Leave unused items blank or zero.
5. Confirm Assigned Items shows 64 cartons.
6. Apply the breakdown and save.

Never choose only one category for a mixed physical layer. Doing so makes wagon inventory incorrect even if the total carton count is correct.

If Item A has only 30 remaining, the app will not allow 40. Recheck earlier layers, the physical layer and the wagon manifest before changing any value.

---

## 13. Layer history, editing and removal

Every saved layer appears in Layer History.

It contains:

- Sequential layer number
- Total cartons
- Item-wise quantities
- Defects
- Reference photo
- Operator notes
- Operator identity and timestamp

### Correct an existing layer

Open the edit action for that layer. You can change:

- Carton count
- Mixed-item allocation
- Defect count
- Notes

For a wagon with items, carton count is calculated from item quantities. Enter a meaningful correction reason whenever cartons, defects or items change. Example: `Physical recount found 2 additional Item B cartons.`

### Remove a layer

Use Remove Layer only if the entire saved layer is invalid or duplicated. Type the requested layer number to confirm. Removal recalculates truck totals, wagon item inventory and reports. The audit trail keeps the action.

Do not remove a valid layer merely to hide a counting mistake. Correct it and record the reason.

---

## 14. Completing and archiving a truck

### Complete a truck

When no more layers will be loaded:

1. Review every layer.
2. Compare physical cartons with the app total.
3. Check mixed-item totals and remaining wagon inventory.
4. Check defects and notes.
5. Tap Complete Loading Session.
6. Review the confirmation summary.
7. Confirm Complete.

Completed means operational loading is finished. Corrections may still be made before archive when permitted.

### Archive a truck

Archive after the completed vehicle has left the active workflow and its record is accepted. Archived vehicles disappear from active loading controls but remain in Digital Registers. Controlled corrections are available through the register and require a correction reason.

---

## 15. Completing and archiving a wagon

The Complete Wagon action becomes available when the wagon is Loading, at least one vehicle exists and every connected vehicle is completed.

Before completing:

- Confirm all intended vehicles are present.
- Confirm all vehicle sessions are completed.
- Check manifest, loaded and remaining quantities.
- Investigate unexpected remaining cartons.
- Confirm defects and operational remarks.

Tap Complete Wagon and review the final summary. Completion makes the wagon ready for its Digital Register.

Archive the wagon after reports and operational checks are accepted. Archived records remain available in Digital Registers, while normal loading actions are locked.

---

## 16. Digital Register

Open the menu and select Digital Registers. The register is a live consolidated record, not a separate manual copy.

### Header and summary

- Wagon number, route, loading date, supervisor and status
- Vehicles, layers, cartons and defects
- Loading duration and operational remarks

### Item reconciliation

For each item it shows Manifest, Loaded and Remaining. It detects:

- Loaded quantity above manifest
- Item loaded totals not matching total layer cartons
- Truck totals not matching its layers
- Mixed-item allocations not matching layer cartons

### Truck and Layer Register

Expand a vehicle to see all its layers. Tap Truck Details to inspect or correct the historical vehicle. Archived loading controls stay locked, but authorized corrections remain possible.

### Correction history

Historical corrections show the layer, time, operator, before value, after value and reason. This protects accountability.

### Remarks

Use Edit Remarks for delay, shortage, weather, seal, damage or handover information.

---

## 17. PDF and Excel reports

Use the report icon on Wagon Details, Truck Details or Digital Register.

### Truck report

Contains vehicle details, layers, cartons, item breakdown, defects, notes, operator, timestamps, corrections, totals and signatures.

### Wagon report

Contains wagon information, item inventory and a summary of all connected vehicles.

### Digital Register PDF

The opening landscape section lists each vehicle with Cartons and Item for every layer. If there are many layers, it continues onto additional landscape pages and repeats the table headings. After the final row it shows a bordered summary for Vehicles, Layers, Cartons and Defects, followed by Supervisor and Remarks.

Detailed portrait pages then show executive summary, item reconciliation, vehicle summary, layer details, correction history and signatures.

### Excel report

Use Excel for sorting and analysis. It includes Register Summary, Item Inventory, Truck Summary, Layer Details, Corrections and the register grid.

### Sharing

After generation, choose an available Android sharing destination. Check the report before sending. If generation fails, refresh data and try again. Report generation does not alter saved operations.

---

## 18. Search, filters and refresh

- Use Wagon Control Center filters to focus on Planning, Loading or Completed records.
- Use Digital Register search for historical wagon information.
- Pull down to refresh after changes made on another screen.
- If a total looks old, return to the previous screen and reopen the record.

Search changes only what is displayed. It never deletes hidden records.

---

## 19. Demo data

Load Demo Data creates enterprise training records with multiple wagon statuses, vehicles, many layers, mixed items, defects and correction history.

### Critical warning

Loading demo data first removes existing local operational data. This is intentional so test results are clean. Do not use it on a production phone or before making an approved backup.

Use demo data to test:

- Search and filters
- Inventory reconciliation
- Six-vehicle wagon cases
- Fifteen or more layers
- Mixed items
- Corrections and deleted records
- PDF and Excel exports

The demo operator name uses the currently logged-in user so records remain realistic.

---

## 20. Data safety, audit and corrections

### Safe actions

- Review before Save, Complete, Archive or Delete.
- Use correction reason for historical changes.
- Keep item names consistent.
- Generate a final report after corrections.
- Use archive for valid finished history.

### Destructive actions

- Delete Wagon removes the wagon and associated vehicles and layers from future active views and reports.
- Delete Vehicle removes its connected layers.
- Remove Layer recalculates all totals.
- Load Demo Data replaces current local operational data.

Strict confirmation fields exist to prevent accidental deletion. Read the target carefully before typing confirmation.

### Automatic recalculation

Saving, correcting or removing a layer recalculates:

- Vehicle layer count
- Vehicle cartons and defects
- Wagon loaded and remaining items
- Digital Register reconciliation
- Future PDF and Excel content

---

## 21. Common mistakes and troubleshooting

### Wrong vehicle number in report

Edit Truck Details and correct Vehicle Number. New reports use the saved vehicle number.

### Item total is correct but remaining inventory is wrong

Inspect mixed-item breakdowns. A layer may have been assigned completely to one item instead of being split.

### Cannot allocate more cartons

The item has insufficient remaining inventory. Review earlier layers and manifest totals. Do not increase the manifest until the physical document is verified.

### Cannot complete wagon

At least one connected vehicle is not completed, or there is no vehicle. Complete each vehicle first.

### Camera is black or preparing

Wait for preview recovery, return and reopen capture, or use Retry Camera. Use Manual mode with a reference photo if the camera remains unsuitable.

### AI count is wrong

Do not save immediately. Add missing cartons, remove false detections, verify the final count, or retake with better angle and lighting.

### Report has many layers

The landscape grid continues over multiple pages. Table headers repeat. Totals appear after the final layer row.

### Report generation error

Refresh the record, confirm vehicles have valid layer data, and retry. If it continues, note the wagon number and exact error text for support.

### App reopened during loading

Use Continue Loading when the unfinished session belongs to the same physical vehicle. Use Discard only when that session should be cancelled.

---

## 22. Complete worked example

### Incoming wagon

- Wagon: BCNHL-2026-0142
- From: Delhi Plant
- To: Jaipur Hub
- Item A: 120 cartons
- Item B: 80 cartons
- Total: 200 cartons

### Vehicle 1

- Vehicle: RJ14GB4521
- Layer 1: Item A 40 + Item B 20 = 60 cartons
- Layer 2: Item A 35 = 35 cartons
- Vehicle total: 95 cartons

Wagon after Vehicle 1:

- Item A loaded 75, remaining 45
- Item B loaded 20, remaining 60
- Total loaded 95, remaining 105

### Vehicle 2

- Vehicle: RJ27GC1180
- Layer 1: Item A 45 + Item B 15 = 60 cartons
- Layer 2: Item B 45 = 45 cartons
- Vehicle total: 105 cartons

Final wagon:

- Item A loaded 120, remaining 0
- Item B loaded 80, remaining 0
- Total loaded 200, remaining 0

Complete both vehicles, complete the wagon, open Digital Register, confirm reconciliation, enter final remarks, generate PDF and Excel, review them, then archive the wagon.

---

## 23. Supervisor closing checklist

- Correct wagon number, route and date
- Manifest matches source document
- Every physical vehicle is registered with correct number
- Every physical layer is saved exactly once
- Layer carton totals equal item allocations
- Mixed layers are split item-wise
- Defects and notes are recorded
- Vehicle totals match physical handover
- All vehicles are completed
- Remaining wagon inventory is understood
- Digital Register shows no unexplained reconciliation issue
- Correction reasons are meaningful
- PDF and Excel are reviewed
- Supervisor name and remarks are correct
- Final records are archived only after acceptance

---

For safe operation, remember: **Capture, verify, allocate items, save, reconcile, then complete.**
''';

const String userManualHindiMarkdown = '''
# विनायक स्मार्टलोड - संपूर्ण संचालन पुस्तिका

यह मैनुअल ऐप की पूरी प्रक्रिया आसान हिंदी में समझाता है। पहली बार ऐप सीखते समय इसे शुरू से अंत तक पढ़ें। काम के दौरान किसी विशेष स्थिति में इसे संदर्भ के रूप में खोलें।

> महत्वपूर्ण: ऐप वैगन, वाहन, लेयर, आइटम मात्रा, फोटो, सुधार और रिपोर्ट जैसे संचालन रिकॉर्ड सुरक्षित करता है। सेव करने से पहले हर जानकारी जांचें। सुधार करते समय स्पष्ट कारण लिखें। वास्तविक डेटा वाले फोन पर डेमो डेटा लोड न करें।

## विषय सूची

1. ऐप का उद्देश्य और पूरी प्रक्रिया
2. महत्वपूर्ण शब्द और डेटा का संबंध
3. लॉगिन, स्टार्टअप और लॉगआउट
4. वैगन कंट्रोल सेंटर
5. वैगन और आइटम मैनिफेस्ट बनाना
6. वैगन इन्वेंटरी और उपलब्ध मात्रा
7. वाहन जोड़ना और बदलना
8. ट्रक लोडिंग सेशन
9. AI कैमरा गिनती
10. मैनुअल गिनती
11. लेयर की जांच और सुधार
12. मिश्रित आइटम वाली लेयर
13. लेयर हिस्ट्री, सुधार और हटाना
14. ट्रक पूरा करना और आर्काइव करना
15. वैगन पूरा करना और आर्काइव करना
16. डिजिटल रजिस्टर
17. PDF और Excel रिपोर्ट
18. सर्च, फिल्टर और रिफ्रेश
19. डेमो डेटा
20. डेटा सुरक्षा, ऑडिट और सुधार
21. सामान्य गलतियां और समाधान
22. पूरा उदाहरण
23. सुपरवाइजर की अंतिम चेकलिस्ट

---

## 1. ऐप का उद्देश्य और पूरी प्रक्रिया

SmartLoad एक वैगन से एक या अधिक वाहनों में जाने वाले कार्टन का रिकॉर्ड रखता है। यह चार मुख्य सवालों का उत्तर देता है:

- वैगन में कौन से आइटम और कितने कार्टन आए?
- कौन से वाहन में कौन से कार्टन लोड हुए?
- किस लेयर में कौन सा आइटम था?
- कितना माल लोड हुआ और कितना वैगन में बाकी है?

### सामान्य प्रक्रिया

`लॉगिन` -> `वैगन बनाएं` -> `आइटम मैनिफेस्ट भरें` -> `वाहन जोड़ें` -> `लोडिंग शुरू करें` -> `AI फोटो या मैनुअल लेयर दर्ज करें` -> `आइटम जांचें` -> `लेयर सेव करें` -> `वाहन पूरा करें` -> `अन्य वाहन दोहराएं` -> `वैगन पूरा करें` -> `डिजिटल रजिस्टर खोलें` -> `PDF या Excel बनाएं` -> `आर्काइव करें`

ऐप में सबसे ऊपर वैगन होता है। वाहन वैगन से जुड़ा होता है और लेयर वाहन से जुड़ी होती है। आइटम की लोडेड मात्रा सेव की गई लेयर से निकलती है। रिपोर्ट हमेशा नवीनतम सेव डेटा से बनती है।

---

## 2. महत्वपूर्ण शब्द और डेटा का संबंध

### वैगन

माल का मूल स्रोत। इसमें वैगन नंबर, कहां से, कहां तक, लोडिंग तारीख, टिप्पणी और आइटम मैनिफेस्ट होता है।

### आइटम मैनिफेस्ट

वैगन बनाते समय सुपरवाइजर द्वारा दर्ज की गई घोषित इन्वेंटरी। हर लाइन में आइटम का नाम और उसके कुल कार्टन होते हैं।

उदाहरण:

- आइटम A: 500 कार्टन
- आइटम B: 300 कार्टन
- आइटम C: 200 कार्टन
- कुल: 1,000 कार्टन

### वाहन

माल लेने वाला ट्रक। वाहन बनाते समय दर्ज किया गया वाहन नंबर स्क्रीन और रिपोर्ट में दिखता है।

### लोडिंग सेशन

एक वाहन के लिए सक्रिय कार्य अवधि। इसमें उसकी सेव की गई लेयर और कुल मात्रा जुड़ती है।

### लेयर

वाहन के अंदर कार्टन की एक वास्तविक पंक्ति या स्टैक। इसे फोटो से या मैनुअल तरीके से दर्ज किया जाता है। हर लेयर में नंबर, कुल कार्टन, आइटम बांट, डिफेक्ट, ऑपरेटर, समय, नोट और वैकल्पिक फोटो होता है।

### मिश्रित लेयर

एक ही लेयर में एक से अधिक आइटम। उदाहरण: आइटम A के 40 और आइटम B के 24, कुल 64 कार्टन।

### डिफेक्ट

लेयर में खराब चिन्हित कार्टन। डिफेक्ट की संख्या कार्टन से अलग रखी जाती है और वाहन, वैगन तथा रिपोर्ट में जोड़ी जाती है।

### डिजिटल रजिस्टर

एक वैगन, उसके सभी वाहन, सभी लेयर, आइटम मिलान, सुधार, टिप्पणी और रिपोर्ट का संयुक्त ऐतिहासिक रिकॉर्ड।

---

## 3. लॉगिन, स्टार्टअप और लॉगआउट

### लॉगिन

1. SmartLoad खोलें।
2. कर्मचारी ID या दिया गया लॉगिन पहचान दर्ज करें।
3. पासवर्ड दर्ज करें।
4. Login दबाएं।
5. Wagon Control Center खुलने दें।

लॉगिन किए हुए उपयोगकर्ता का नाम नई लेयर में ऑपरेटर और रिपोर्ट में सुपरवाइजर के रूप में उपयोग होता है। इसलिए एक ही लॉगिन से किए काम में उसी व्यक्ति का नाम होना चाहिए।

### स्टार्टअप

ऐप शुरू होते समय साझा AI इंजन तैयार करता है और बाद की सभी लेयर में उसी इंजन का उपयोग करता है। यदि फोन सक्रिय लोडिंग के बीच बंद हुआ था, तो Continue Loading संदेश आ सकता है। वही वाहन हो तो Continue चुनें। सेशन वास्तव में रद्द करना हो तभी Discard चुनें।

### लॉगआउट

1. Wagon Control Center के ऊपर दाएं मेनू खोलें।
2. Logout दबाएं।
3. चेतावनी पढ़ें।
4. लॉगआउट की पुष्टि करें।

लॉगआउट केवल उपयोगकर्ता सेशन बंद करता है। यह वैगन, वाहन, लेयर या रिपोर्ट नहीं मिटाता। दूसरे ऑपरेटर को फोन देने से पहले लॉगआउट जरूर करें।

---

## 4. वैगन कंट्रोल सेंटर

यह ऐप की मुख्य स्क्रीन है।

### ऊपर के सारांश कार्ड

- Active Wagons: अभी योजना या लोडिंग में चल रहे वैगन।
- Total Trucks: वर्तमान रिकॉर्ड से जुड़े वाहन।
- Total Cartons: वाहन की सेव लेयर में दर्ज कार्टन।

### वैगन कार्ड

कार्ड में वैगन नंबर, स्थिति, वाहन संख्या, कार्टन और इन्वेंटरी प्रगति दिखती है। Wagon Details खोलने के लिए कार्ड दबाएं।

### सर्च और फिल्टर

- सर्च बॉक्स से वैगन खोजें।
- All सभी रिकॉर्ड दिखाता है।
- Planning में बने हुए लेकिन शुरू न हुए वैगन दिखते हैं।
- Loading सक्रिय लोडिंग दिखाता है।
- Completed पूरा किया हुआ काम दिखाता है।
- नीचे खींचकर डेटा रिफ्रेश करें।

### मुख्य मेनू

- Digital Registers: वैगन इतिहास और रिपोर्ट।
- Documentation: यह अंग्रेजी और हिंदी पुस्तिका।
- Load Demo Data: वर्तमान लोकल डेटा हटाकर प्रशिक्षण डेटा बनाता है।
- Logout: वर्तमान उपयोगकर्ता सेशन बंद करता है।

---

## 5. वैगन और आइटम मैनिफेस्ट बनाना

Wagon Control Center पर Create Wagon दबाएं।

### वैगन फील्ड

- Wagon Number: जरूरी। भौतिक वैगन पर लिखा सही नंबर भरें।
- Scan बटन: कैमरे से वैगन नंबर पढ़ता है। सेव करने से पहले परिणाम मिलाएं।
- Origin: वैगन कहां से आया। जानकारी सच में न हो तभी NIL लिखें।
- Destination: माल का गंतव्य।
- Loading Date: लोडिंग शुरू होने की तारीख।
- Remarks: सील, हालत, विशेष निर्देश या संचालन टिप्पणी।

### आइटम मैनिफेस्ट

वैगन में मौजूद हर आइटम की अलग पंक्ति जोड़ें।

1. साफ आइटम नाम लिखें, जैसे `Soap 100g Blue`।
2. पॉजिटिव पूर्ण संख्या में कार्टन मात्रा लिखें।
3. दूसरे आइटम के लिए Add Item दबाएं।
4. खाली लाइन हटाएं।
5. एक ही आइटम की अलग स्पेलिंग न बनाएं।

सही उदाहरण:

- Item A - 120 कार्टन
- Item B - 80 कार्टन
- कुल - 200 कार्टन

गलत उदाहरण:

- Item A - 120
- item a - 20

ऐप इन्हें अलग आइटम मान सकता है। एक ही नाम और स्पेलिंग रखें।

### सेव होने के बाद

वैगन Planning स्थिति में बनता है। पहला वाहन जोड़ने पर Loading स्थिति शुरू होती है। मैनिफेस्ट में दी मात्रा लेयर में आइटम बांटने की अधिकतम सीमा होती है।

### बाद में बदलाव

Wagon Details या Digital Register में पेंसिल दबाएं। आप जानकारी और मैनिफेस्ट बदल सकते हैं, लेकिन:

- कुल मात्रा पहले से लोड मात्रा से कम नहीं की जा सकती।
- जिस आइटम के कार्टन लोड हो चुके हैं उसे हटाया नहीं जा सकता।
- दस्तावेज जांचने के बाद जरूरत हो तो कुल मात्रा बढ़ाई जा सकती है।

---

## 6. वैगन इन्वेंटरी और उपलब्ध मात्रा

Wagon Item Inventory कार्ड हर आइटम के लिए दिखाता है:

- Total: मैनिफेस्ट में घोषित कार्टन।
- Loaded: सभी वाहनों की सेव लेयर में बांटे गए कार्टन।
- Remaining: Total में से Loaded घटाकर बची मात्रा।

उदाहरण:

- Item A Total 120, Loaded 75, Remaining 45
- Item B Total 80, Loaded 50, Remaining 30
- कुल 200, Loaded 125, Remaining 75

इन्वेंटरी सफलतापूर्वक लेयर सेव, सुधार या हटाने के बाद बदलती है। केवल फोटो लेने से मात्रा नहीं बदलती।

ऐप उपलब्ध मात्रा से अधिक आइटम सेव नहीं करने देता। पुरानी लेयर सुधारते समय उस लेयर की वर्तमान मात्रा पहले उपलब्धता में वापस जोड़ी जाती है, फिर नई मात्रा जांची जाती है।

---

## 7. वाहन जोड़ना और बदलना

Wagon Details खोलें और Add Truck या Register Truck दबाएं।

### वाहन फील्ड

- Vehicle Number: जरूरी। वाहन बनाते समय उपयोग किया सही रजिस्ट्रेशन नंबर।
- Scan आइकन: नंबर प्लेट पढ़ता है। भौतिक प्लेट से जरूर मिलाएं।
- Driver Name: वैकल्पिक, लेकिन भरना बेहतर है।
- Driver Mobile Number: संपर्क नंबर।
- Carrier Company: ट्रांसपोर्ट कंपनी।
- Warehouse Facility: माल लेने वाला वेयरहाउस।
- Notes: रूट, गेट पास, सील या अन्य जानकारी।

उदाहरण:

- Vehicle Number: RJ14GB4521
- Driver: Ramesh Kumar
- Mobile: 9876543210
- Carrier: Vinayak Transport
- Warehouse: Jaipur Central

### सुधार

Truck Details में पेंसिल दबाकर जानकारी बदलें। आर्काइव वाहन को Digital Register -> Truck Details से नियंत्रित तरीके से सुधारा जा सकता है।

### वाहन हटाना

Delete वाहन और उसकी लेयर को सक्रिय स्क्रीन और भविष्य की रिपोर्ट से हटाता है। केवल डुप्लिकेट या गलत वाहन के लिए उपयोग करें। सही पूरा रिकॉर्ड Delete करने के बजाय Archive करें।

---

## 8. ट्रक लोडिंग सेशन

Wagon Details से वाहन खोलें।

Truck Details में वाहन, ड्राइवर, कैरियर, वेयरहाउस, वैगन इन्वेंटरी, कुल लेयर, कार्टन, डिफेक्ट और Layer History दिखती है।

### काम शुरू करना

1. Start Loading Session दबाएं।
2. सही वाहन नंबर जांचें।
3. Capture Layer दबाएं।
4. AI या Manual मोड चुनें।

एक समय में वही सेशन चलाएं जिस भौतिक वाहन में माल जा रहा है। पुराना सेशन Resume करने का संदेश आए तो पहले उसे सही तरीके से हल करें।

---

## 9. AI कैमरा गिनती

AI मोड फोटो में दिख रहे कार्टन गिनता है।

### फोटो से पहले

- कैमरा लेंस साफ करें।
- लेयर के सामने सीधा खड़े हों।
- पूरी लेयर फ्रेम में रखें।
- तेज चमक, अंधेरा और हिलती फोटो से बचें।
- संभव हो तो व्यक्ति और दूसरी कार्टन ढेरी फ्रेम से हटाएं।
- Preview तैयार होने दें।

### प्रक्रिया

1. AI मोड चुनें।
2. लेयर को गाइड में रखें।
3. जरूरत पर ही Flash उपयोग करें।
4. फोन स्थिर रखें।
5. Capture Layer दबाएं।
6. विश्लेषण के बाद Review Layer Scan देखें।

AI केवल सहायक है। अंतिम जिम्मेदारी ऑपरेटर की है। हर बॉक्स और गिनती जांचें।

स्क्रीन लॉक या ऐप बदलने के बाद Preparing Camera दिख सकता है। लाइव Preview आने दें। जरूरत पर Retry Camera उपयोग करें। गलत या गायब फोटो सेव न करें।

---

## 10. मैनुअल गिनती

AI के लिए कठिन दृश्य, कैमरा समस्या या पहले से सत्यापित भौतिक गिनती होने पर Manual मोड उपयोग करें।

1. मोड स्विच या क्षैतिज स्वाइप से Manual चुनें।
2. Reference Photo लें। साफ न हो तो Retake करें।
3. कुल कार्टन दर्ज करें।
4. डिफेक्ट दर्ज करें।
5. वैकल्पिक Notes लिखें।
6. मैनिफेस्ट हो तो आइटम बांट दर्ज करें।
7. आइटम मात्रा और कुल कार्टन समान जांचें।
8. Save Layer दबाएं।

मैनुअल का मतलब बिना जांच के संख्या नहीं है। सेव से पहले कार्टन भौतिक रूप से गिनें।

---

## 11. लेयर की जांच और सुधार

Review Layer Scan सेव से पहले अंतिम जांच है।

जांचें:

- Reference Photo
- AI बॉक्स या आउटलाइन
- नंबर लेबल
- AI Count
- Corrected Final Count
- Defects
- Item Breakdown
- Notes

AI कार्टन छोड़ दे तो उपलब्ध कंट्रोल से मिस हुआ कार्टन जोड़ें। दो बार गिना हो तो गलत डिटेक्शन हटाएं। गलती होने पर Undo या Reset उपयोग करें।

### सेव नियम

- अंतिम कार्टन वैध संख्या होनी चाहिए।
- आइटम मात्रा का योग अंतिम कार्टन के बिल्कुल बराबर होना चाहिए।
- एक आइटम एक ही बार आना चाहिए।
- आइटम उपलब्ध मात्रा से अधिक नहीं होना चाहिए।
- Final verification fail हो तो फोटो दोबारा लें।

सफल सेव अगला लेयर नंबर बनाता है और वाहन तथा वैगन कुल अपडेट करता है।

---

## 12. मिश्रित आइटम वाली लेयर

एक लेयर में कई आइटम हो सकते हैं।

उदाहरण:

- Item A: 40 कार्टन
- Item B: 24 कार्टन
- कुल: 64 कार्टन

### सही तरीका

1. Layer Item Breakdown खोलें।
2. Item A के सामने 40 लिखें।
3. Item B के सामने 24 लिखें।
4. बाकी आइटम खाली या शून्य रखें।
5. Assigned Items में 64 जांचें।
6. Apply करके सेव करें।

मिश्रित लेयर को केवल एक आइटम में सेव न करें। कुल कार्टन सही होने पर भी वैगन इन्वेंटरी गलत हो जाएगी।

यदि Item A केवल 30 बाकी है तो ऐप 40 सेव नहीं करेगा। पहले पुरानी लेयर, भौतिक माल और मैनिफेस्ट जांचें।

---

## 13. लेयर हिस्ट्री, सुधार और हटाना

हर सेव लेयर में नंबर, कार्टन, आइटम मात्रा, डिफेक्ट, फोटो, नोट, ऑपरेटर और समय दिखता है।

### पुरानी लेयर सुधारना

लेयर का Edit खोलें। आप कार्टन, मिश्रित आइटम, डिफेक्ट और Notes बदल सकते हैं। मैनिफेस्ट होने पर कार्टन आइटम मात्रा से अपने आप निकलता है। संख्या या आइटम बदलने पर साफ कारण लिखें।

अच्छा कारण: `भौतिक दोबारा गिनती में Item B के 2 अतिरिक्त कार्टन मिले।`

### लेयर हटाना

पूरी लेयर गलत या डुप्लिकेट हो तभी Remove Layer करें। मांगा गया लेयर नंबर टाइप करके पुष्टि करें। इससे वाहन कुल, वैगन इन्वेंटरी और रिपोर्ट फिर से गणना होती है। ऑडिट में कार्रवाई रहती है।

गलती छिपाने के लिए सही लेयर न हटाएं। उसे कारण के साथ सुधारें।

---

## 14. ट्रक पूरा करना और आर्काइव करना

### ट्रक पूरा करना

1. सभी लेयर जांचें।
2. भौतिक कार्टन और ऐप कुल मिलाएं।
3. मिश्रित आइटम और वैगन Remaining जांचें।
4. डिफेक्ट और नोट जांचें।
5. Complete Loading Session दबाएं।
6. सारांश पढ़ें।
7. Complete पुष्टि करें।

Completed का मतलब वाहन की सामान्य लोडिंग खत्म है। अनुमति होने पर Archive से पहले सुधार किया जा सकता है।

### आर्काइव

वाहन सक्रिय प्रक्रिया से निकल जाने और रिकॉर्ड स्वीकार होने के बाद Archive करें। आर्काइव वाहन सक्रिय कंट्रोल से हटता है, लेकिन Digital Register में रहता है। वहां नियंत्रित सुधार के लिए कारण जरूरी होता है।

---

## 15. वैगन पूरा करना और आर्काइव करना

Complete Wagon तभी उपलब्ध होता है जब वैगन Loading में हो, कम से कम एक वाहन हो और सभी जुड़े वाहन Completed हों।

पूरा करने से पहले:

- सभी भौतिक वाहन ऐप में हैं।
- सभी वाहन सेशन Completed हैं।
- Manifest, Loaded और Remaining जांचे गए हैं।
- अनपेक्षित बाकी मात्रा का कारण समझा गया है।
- डिफेक्ट और Remarks सही हैं।

Complete Wagon दबाकर अंतिम सारांश जांचें। रिपोर्ट स्वीकार होने के बाद वैगन Archive करें। आर्काइव रिकॉर्ड Digital Register में रहता है और सामान्य लोडिंग लॉक हो जाती है।

---

## 16. डिजिटल रजिस्टर

मेनू से Digital Registers खोलें। यह अलग कॉपी नहीं, बल्कि वर्तमान सेव डेटा का संयुक्त रिकॉर्ड है।

### इसमें क्या दिखता है

- वैगन नंबर, रूट, तारीख, सुपरवाइजर और स्थिति
- वाहन, लेयर, कार्टन और डिफेक्ट
- लोडिंग अवधि और टिप्पणी
- हर आइटम का Manifest, Loaded और Remaining
- हर वाहन की सभी लेयर
- Correction History

### मिलान जांच

यह पहचानता है:

- Loaded मात्रा Manifest से अधिक
- आइटम Loaded और कुल लेयर कार्टन में अंतर
- वाहन कुल और उसकी लेयर में अंतर
- मिश्रित आइटम और लेयर कार्टन में अंतर

वाहन खोलकर Truck Details से ऐतिहासिक रिकॉर्ड देखा या सुधारा जा सकता है। आर्काइव में सामान्य लोडिंग बंद रहती है, लेकिन अधिकृत सुधार कारण के साथ किया जा सकता है।

Correction History में लेयर, समय, ऑपरेटर, पहले की मात्रा, बाद की मात्रा और कारण दिखता है। Edit Remarks से देरी, कमी, मौसम, सील, नुकसान या हैंडओवर जानकारी लिखें।

---

## 17. PDF और Excel रिपोर्ट

Wagon Details, Truck Details या Digital Register में Report आइकन दबाएं।

### Truck Report

वाहन जानकारी, लेयर, कार्टन, आइटम बांट, डिफेक्ट, नोट, ऑपरेटर, समय, सुधार, कुल और हस्ताक्षर।

### Wagon Report

वैगन जानकारी, आइटम इन्वेंटरी और सभी जुड़े वाहन का सारांश।

### Digital Register PDF

शुरुआती Landscape भाग में हर वाहन के लिए हर लेयर का Cartons और Item दिखता है। ज्यादा लेयर होने पर टेबल अगले Landscape पेज पर जारी रहती है और हेडिंग दोहरती है। अंतिम लेयर के बाद Vehicles, Layers, Cartons और Defects का बॉक्स आता है। उसके नीचे Supervisor और Remarks आते हैं।

बाद के Portrait पेज में Executive Summary, Item Reconciliation, Vehicle Summary, Layer Details, Correction History और Signatures आते हैं।

### Excel

विश्लेषण के लिए Register Summary, Item Inventory, Truck Summary, Layer Details, Corrections और Register Grid शीट मिलती हैं।

रिपोर्ट बनने के बाद Android Share विकल्प चुनें। भेजने से पहले रिपोर्ट खोलकर जांचें। रिपोर्ट बनाने से सेव डेटा नहीं बदलता।

---

## 18. सर्च, फिल्टर और रिफ्रेश

- Wagon Control Center में Planning, Loading और Completed फिल्टर उपयोग करें।
- पुराने रिकॉर्ड के लिए Digital Register सर्च उपयोग करें।
- दूसरी स्क्रीन पर बदलाव के बाद नीचे खींचकर Refresh करें।
- पुराना कुल दिखे तो पीछे जाकर रिकॉर्ड दोबारा खोलें।

सर्च केवल दिखाई देने वाली सूची बदलता है। छिपे रिकॉर्ड मिटते नहीं हैं।

---

## 19. डेमो डेटा

Load Demo Data कई स्थिति वाले वैगन, वाहन, बहुत सी लेयर, मिश्रित आइटम, डिफेक्ट और Correction History बनाता है।

### बहुत महत्वपूर्ण चेतावनी

डेमो डेटा लोड करने से पहले वर्तमान लोकल संचालन डेटा हटता है। साफ परीक्षण के लिए यह जानबूझकर होता है। उत्पादन फोन पर या स्वीकृत बैकअप से पहले इसका उपयोग न करें।

डेमो से सर्च, फिल्टर, इन्वेंटरी मिलान, छह वाहन, पंद्रह से अधिक लेयर, मिश्रित आइटम, सुधार, हटाए रिकॉर्ड, PDF और Excel जांचें। डेमो ऑपरेटर के लिए वर्तमान लॉगिन उपयोगकर्ता का नाम लिया जाता है।

---

## 20. डेटा सुरक्षा, ऑडिट और सुधार

### सुरक्षित अभ्यास

- Save, Complete, Archive या Delete से पहले जांचें।
- ऐतिहासिक बदलाव का कारण लिखें।
- आइटम नाम एक जैसा रखें।
- सुधार के बाद नई अंतिम रिपोर्ट बनाएं।
- सही पूरा इतिहास Delete नहीं, Archive करें।

### डेटा बदलने वाली कार्रवाई

- Delete Wagon वैगन और उसके वाहन तथा लेयर भविष्य की सक्रिय स्क्रीन और रिपोर्ट से हटाता है।
- Delete Vehicle उसकी लेयर हटाता है।
- Remove Layer सभी संबंधित कुल दोबारा गणना करता है।
- Load Demo Data वर्तमान लोकल डेटा बदल देता है।

Strict confirmation गलती से हटाने से बचाता है। पुष्टि टाइप करने से पहले लक्ष्य नंबर ध्यान से पढ़ें।

लेयर Save, Correct या Remove होने पर वाहन की लेयर, कार्टन, डिफेक्ट, वैगन Loaded, Remaining, Digital Register और भविष्य की रिपोर्ट अपने आप अपडेट होती है।

---

## 21. सामान्य गलतियां और समाधान

### रिपोर्ट में वाहन नंबर गलत

Truck Details में Vehicle Number सुधारें। नई रिपोर्ट सेव वाहन नंबर उपयोग करेगी।

### कुल कार्टन सही लेकिन Remaining गलत

मिश्रित लेयर का Item Breakdown जांचें। पूरी लेयर गलती से एक आइटम में गई हो सकती है।

### अधिक मात्रा सेव नहीं हो रही

आइटम की Remaining मात्रा कम है। पुरानी लेयर और Manifest जांचें। दस्तावेज सत्यापन के बिना Manifest न बढ़ाएं।

### Wagon Complete नहीं हो रहा

कोई वाहन अभी Completed नहीं है या वाहन मौजूद नहीं है। पहले सभी वाहन पूरा करें।

### कैमरा काला या Preparing

Preview आने दें, Capture स्क्रीन दोबारा खोलें या Retry Camera उपयोग करें। जरूरत पर Reference Photo के साथ Manual मोड उपयोग करें।

### AI गिनती गलत

तुरंत सेव न करें। छूटे कार्टन जोड़ें, गलत डिटेक्शन हटाएं या बेहतर रोशनी और एंगल से Retake करें।

### रिपोर्ट में बहुत लेयर

Landscape टेबल कई पेज पर जारी रहती है। हेडिंग दोहरती है और कुल अंतिम लेयर के बाद आता है।

### रिपोर्ट बनाने में त्रुटि

डेटा Refresh करें और फिर प्रयास करें। समस्या जारी हो तो वैगन नंबर और पूरा Error संदेश सहायता टीम को दें।

### लोडिंग के बीच ऐप फिर खुला

वही भौतिक वाहन हो तो Continue Loading चुनें। सेशन रद्द करना हो तभी Discard करें।

---

## 22. पूरा उदाहरण

### आया हुआ वैगन

- Wagon: BCNHL-2026-0142
- From: Delhi Plant
- To: Jaipur Hub
- Item A: 120 कार्टन
- Item B: 80 कार्टन
- कुल: 200 कार्टन

### वाहन 1

- Vehicle: RJ14GB4521
- Layer 1: Item A 40 + Item B 20 = 60
- Layer 2: Item A 35 = 35
- वाहन कुल: 95

इसके बाद:

- Item A Loaded 75, Remaining 45
- Item B Loaded 20, Remaining 60
- कुल Loaded 95, Remaining 105

### वाहन 2

- Vehicle: RJ27GC1180
- Layer 1: Item A 45 + Item B 15 = 60
- Layer 2: Item B 45 = 45
- वाहन कुल: 105

अंतिम वैगन:

- Item A Loaded 120, Remaining 0
- Item B Loaded 80, Remaining 0
- कुल Loaded 200, Remaining 0

दोनों वाहन Complete करें, वैगन Complete करें, Digital Register में Reconciliation जांचें, अंतिम Remarks लिखें, PDF और Excel बनाकर जांचें, फिर वैगन Archive करें।

---

## 23. सुपरवाइजर की अंतिम चेकलिस्ट

- वैगन नंबर, रूट और तारीख सही
- Manifest स्रोत दस्तावेज से मिलता है
- हर भौतिक वाहन सही नंबर से दर्ज
- हर भौतिक लेयर केवल एक बार सेव
- लेयर कार्टन और Item Allocation समान
- मिश्रित लेयर आइटम अनुसार बांटी गई
- डिफेक्ट और Notes दर्ज
- वाहन कुल भौतिक हैंडओवर से मिलता है
- सभी वाहन Completed
- वैगन Remaining का कारण समझा गया
- Digital Register में अनसुलझी गलती नहीं
- Correction Reason स्पष्ट
- PDF और Excel जांचे गए
- Supervisor और Remarks सही
- स्वीकृति के बाद ही Archive

---

सुरक्षित प्रक्रिया याद रखें: **फोटो लें, जांचें, आइटम बांटें, सेव करें, मिलान करें, फिर पूरा करें।**
''';
