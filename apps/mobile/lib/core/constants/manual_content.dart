const String userManualMarkdown = '''
# Vinayak SmartLoad - Comprehensive User Manual

Welcome to the **Vinayak SmartLoad** User Manual! This document provides an in-depth, step-by-step guide to everything you need to know to operate the system effectively.

SmartLoad prepares one shared AI counting engine during signed-in startup. The
same engine is reused for every truck and layer, so camera screens do not reload
the model repeatedly. During this one-time preparation, the splash screen keeps
the clean SmartLoad branding visible without a loading circle or status text.

---

## 1. What is Vinayak SmartLoad?

**Vinayak SmartLoad** is an enterprise-grade mobile application designed for Vinayak Logistics. Its primary purpose is to completely digitize the warehouse loading dock operations.

Historically, warehouse operators had to manually count cartons, track trucks on clipboards, and write paper "Wagon Registers" at the end of the day. SmartLoad fixes this by using:
- **Centralized Digital Dashboards**: Tracking Wagons and Trucks in real time.
- **AI-Powered Vision (YOLOv8)**: Using the device camera to automatically count "layers" of cartons loaded into trucks with extreme accuracy.
- **Automated Digital Registers**: Generating a final, exportable report (PDF/Excel) automatically once loading is completed.
- **Web Admin Dashboard**: A separate web portal for managers to securely manage employee accounts and monitor the system.

---

## 2. Core Concepts & Terminology

Before using the app, it's crucial to understand the three main tiers of the workflow:

1. **Wagon**: The highest level of operation. A Wagon represents the bulk shipment that has arrived and is being unloaded into trucks for delivery to a warehouse.
2. **Truck (Vehicle)**: Trucks are the receiving vehicles that take cartons from the arrived Wagon to the warehouse. Each Truck requires multiple *Layers* of cartons to fill.
3. **Layer**: A physical stack/row of cartons placed into the back of a Truck. Instead of counting individual boxes by hand, the operator snaps a photo of each "Layer" using the AI Camera, which counts the cartons instantly.

**The Workflow:**
`Register Arrived Wagon` ➡️ `Add Receiving Truck` ➡️ `Start Loading Session` ➡️ `Capture AI Layers for Truck` ➡️ `Complete Truck` ➡️ `Send Truck to Warehouse` ➡️ `Complete Wagon` ➡️ `Generate Digital Register`

---

## 3. Understanding Status Tags

Throughout the app, you will see various colored tags or "chips" indicating the current state of a Wagon, Truck, or Loading Session. Here is exactly what each means:

### Wagon Status Tags
- **PLANNING (Grey)**: The wagon has arrived and been registered. Trucks are being assigned, but physical loading has not started yet.
- **LOADING (Blue)**: Active loading is happening right now. At least one truck assigned to this wagon is currently being loaded.
- **COMPLETED (Green)**: All cartons have been transferred from the arrived wagon, and all expected trucks have been loaded and finalized. The Wagon is now locked and ready for digital register generation.

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

### A. Authentication & Security
- **Secure Login**: Enter your Employee ID and password.
- **Kill-Switch Security**: If an administrator disables your account from the Web Admin Dashboard, the mobile app will instantly detect it, lock the screen, and purge your security token.
- **Saved Login Session**: Closing and reopening the app keeps you signed in on this device. You only need to log in again after choosing **Logout** or if an administrator revokes your access.
- **Logout Safely**: Open the app drawer and tap **Logout**. SmartLoad first shows a warning. Tap **Cancel** to stay signed in, or tap **Log out** to end the current login session and return to the login screen. Logging out does not delete wagons, trucks, layers, photos, or reports saved on the device.

### B. The App Drawer & Global Navigation
Tap the **Vinayak Logistics Logo** in the top-left corner of the dashboard, or swipe from the left edge of the screen, to open the **App Navigation Drawer**. This drawer contains:
- **Digital Registers**: View wagon history, including planning, loading, completed, and archived records, and generate PDF/Excel reports.
- **Documentation**: Open this user manual and workflow guidance.
- **Load Demo Data**: Replace current local data with mock data for training and testing. Use this only when you intentionally want to clear the current test records.
- **Logout**: End the current user session after confirming the warning.

### C. The Wagon Control Center (Dashboard)
This is your main operational hub.
- **View Loading Summary**: The dashboard shows the current wagon list and loading status. Open a wagon to see its trucks, layers, carton totals, defects, and history.
- **Filter**: Use the chips (`All`, `Planning`, `Loading`, `Completed`) to filter the list of Wagons.
- **Create a New Wagon**: Tap the large floating `+ Create Wagon` button at the bottom. Enter the Wagon Number (e.g., `W-1002-IND`), Origin, Destination, and Expected Trucks.

### D. Managing a Wagon & Adding Trucks
Tap on any Wagon in the dashboard to open its details.
- **Add a Truck**: Tap the `+ Add Truck` button. Enter the Vehicle Number, Driver details, and Carrier Company.
- **Delete Wagon**: If a mistake was made, tap the red trash can icon in the top right. *Warning: You will be required to manually type the Wagon Number to confirm deletion.*

### E. The Truck Loading Workspace
Tap a Truck in the list to open its Loading Workspace. 
1. Tap **Start Loading Session** to lock the truck into an active state. 
2. Tap **Capture Next Layer** to launch the AI Camera.
3. *Auto-Resume feature: If your app crashes or you close it by accident while a session is active, the app will instantly prompt you to resume your session the next time you open the dashboard!*

### F. The AI Camera Experience
This is the flagship feature of SmartLoad. You use this screen while standing at the loading dock.
1. Align the back of the truck within the **blue dashed alignment guide**.
2. Wait for the `Quality Indicator` (top left) to turn green (`EXCELLENT`).
3. Tap the large **Capture Layer** button (bottom right).
4. If the count looks correct, tap **Confirm & Save**. If the AI missed a box, tap **Reject & Retake**.
5. Every confirmed layer is permanently logged to the truck, and the total carton count goes up automatically!

If Android temporarily interrupts the camera—for example during screen lock,
app switching, or a system overlay—SmartLoad may briefly show **Preparing
camera...** while it reconnects automatically. Keep the app open and do not
tap Capture until the live picture returns. The startup analysis stream closes
after the first valid frame, leaving a lighter Preview + ImageCapture camera
session. If two automatic recovery attempts fail, use **Retry Camera**.

### G. Completing the Process
1. **Complete the Truck**: Once the truck is fully packed, go back to the Truck Workspace and tap **Complete Loading Session**. It will show you a strict summary of your layers and cartons before locking the truck. The truck is then ready to be sent to the warehouse.
2. **Send the Truck to the Warehouse**: Move the completed truck to the destination warehouse according to your transport process. SmartLoad keeps the loading record and carton count for that truck.
3. **Complete the Wagon**: Once all expected trucks for a Wagon are Complete, go back to the Wagon Details and tap **Complete Wagon**. If you try to complete a wagon before the expected trucks are loaded, the app will issue a strict warning!
4. **Digital Registers**: Once the Wagon is completed, it automatically generates a professional exportable report of the Wagon, listing every single Truck, Driver, Time, and exact Carton counts—ready to be printed or emailed. No paper required!

---
*End of User Manual. Property of Vinayak Logistics.*
''';

const String userManualHindiMarkdown = '''
# विनायक स्मार्टलोड - संपूर्ण उपयोगकर्ता मैनुअल (User Manual)

**विनायक स्मार्टलोड** उपयोगकर्ता मैनुअल में आपका स्वागत है! यह दस्तावेज़ आपको सिस्टम को प्रभावी ढंग से संचालित करने के लिए चरण-दर-चरण मार्गदर्शन प्रदान करता है।

SmartLoad साइन-इन स्टार्टअप के दौरान साझा AI गिनती इंजन को केवल एक बार तैयार
करता है। बाद में हर ट्रक और लेयर के लिए उसी इंजन का उपयोग होता है, इसलिए कैमरा
स्क्रीन मॉडल को बार-बार लोड नहीं करती। इस एक बार की तैयारी के दौरान स्प्लैश
स्क्रीन बिना लोडिंग गोले या स्टेटस टेक्स्ट के साफ SmartLoad ब्रांडिंग दिखाती है।

---

## 1. विनायक स्मार्टलोड क्या है?

**विनायक स्मार्टलोड** विनायक लॉजिस्टिक्स के लिए डिज़ाइन किया गया एक एंटरप्राइज़-ग्रेड मोबाइल एप्लिकेशन है। इसका मुख्य उद्देश्य वेयरहाउस लोडिंग डॉक संचालन को पूरी तरह से डिजिटल बनाना है।

ऐतिहासिक रूप से, वेयरहाउस ऑपरेटरों को मैन्युअल रूप से डिब्बों (कार्टन) की गिनती करनी पड़ती थी, क्लिपबोर्ड पर ट्रकों को ट्रैक करना पड़ता था, और दिन के अंत में पेपर "वैगन रजिस्टर" लिखना पड़ता था। स्मार्टलोड इसे निम्नलिखित का उपयोग करके ठीक करता है:
- **केंद्रीकृत डिजिटल डैशबोर्ड**: वास्तविक समय (real-time) में वैगन और ट्रकों को ट्रैक करना।
- **AI-पावर्ड विजन (YOLOv8)**: ट्रकों में लोड किए गए डिब्बों की "लेयर्स" (परतों) को अत्यधिक सटीकता के साथ स्वचालित रूप से गिनने के लिए डिवाइस कैमरे का उपयोग करना।
- **स्वचालित डिजिटल रजिस्टर**: लोडिंग पूरी होने के बाद स्वचालित रूप से एक अंतिम, निर्यात योग्य रिपोर्ट (PDF/Excel) उत्पन्न करना।
- **वेब एडमिन डैशबोर्ड**: प्रबंधकों (मैनेजर्स) के लिए कर्मचारी खातों को सुरक्षित रूप से प्रबंधित करने और सिस्टम की निगरानी के लिए एक अलग वेब पोर्टल।

---

## 2. मूल अवधारणाएँ और शब्दावली

ऐप का उपयोग करने से पहले, वर्कफ़्लो के तीन मुख्य स्तरों को समझना महत्वपूर्ण है:

1. **वैगन (Wagon)**: संचालन का उच्चतम स्तर। वैगन वह थोक शिपमेंट है जो आ चुका है और जिसके कार्टन ट्रकों में लोड किए जा रहे हैं, ताकि उन्हें वेयरहाउस भेजा जा सके।
2. **ट्रक (वाहन)**: ट्रक वे प्राप्त करने वाले वाहन हैं जो आए हुए वैगन से कार्टन लेकर वेयरहाउस तक जाते हैं। प्रत्येक ट्रक को भरने के लिए कार्टन की कई *लेयर्स* (परतों) की आवश्यकता होती है।
3. **लेयर (Layer)**: ट्रक के पीछे रखे गए डिब्बों का एक भौतिक स्टैक/पंक्ति। डिब्बों को हाथ से गिनने के बजाय, ऑपरेटर AI कैमरे का उपयोग करके प्रत्येक "लेयर" की एक तस्वीर लेता है, जो तुरंत डिब्बों की गिनती कर लेता है।

**वर्कफ़्लो:**
`आया हुआ वैगन रजिस्टर करें` ➡️ `प्राप्त करने वाला ट्रक जोड़ें` ➡️ `लोडिंग सत्र शुरू करें` ➡️ `ट्रक के लिए AI लेयर्स कैप्चर करें` ➡️ `ट्रक को पूरा करें` ➡️ `ट्रक को वेयरहाउस भेजें` ➡️ `वैगन को पूरा करें` ➡️ `डिजिटल रजिस्टर जनरेट करें`

---

## 3. स्टेटस टैग्स (Status Tags) को समझना

पूरे ऐप में, आप विभिन्न रंगीन टैग या "चिप्स" देखेंगे जो वैगन, ट्रक या लोडिंग सत्र की वर्तमान स्थिति का संकेत देते हैं। यहां बताया गया है कि प्रत्येक का क्या अर्थ है:

### वैगन स्टेटस टैग्स
- **PLANNING (ग्रे)**: वैगन आ चुका है और रजिस्टर हो गया है। ट्रकों को सौंपा जा रहा है, लेकिन अभी तक भौतिक लोडिंग शुरू नहीं हुई है।
- **LOADING (नीला)**: वर्तमान में सक्रिय लोडिंग हो रही है। इस वैगन को सौंपा गया कम से कम एक ट्रक वर्तमान में लोड किया जा रहा है।
- **COMPLETED (हरा)**: आए हुए वैगन से सभी कार्टन ट्रकों में स्थानांतरित कर दिए गए हैं और सभी अपेक्षित ट्रकों को लोड करके अंतिम रूप दे दिया गया है। वैगन अब लॉक है और डिजिटल रजिस्टर जनरेशन के लिए तैयार है।

### ट्रक स्टेटस टैग्स
- **LOADING (नीला)**: ट्रक में सक्रिय रूप से माल प्राप्त हो रहा है। AI कैमरे का उपयोग नई लेयर्स को स्कैन करने के लिए किया जा सकता है।
- **COMPLETED (हरा)**: ट्रक पूरी तरह से पैक हो गया है। ऑपरेटर ने स्पष्ट रूप से ट्रक सत्र को लॉक कर दिया है, जिससे किसी भी अन्य लेयर को जोड़ने से रोका जा सके।
- **ARCHIVED (ग्रे)**: ट्रक का रिकॉर्ड ऐतिहासिक उद्देश्यों के लिए डेटाबेस में सुरक्षित रूप से संग्रहीत है लेकिन सक्रिय परिचालन दृश्यों (views) से पूरी तरह से छिपा हुआ है।

### सत्र (Session) स्टेटस टैग्स
- **WAITING**: AI इंजन खाली है, ऑपरेटर द्वारा स्कैन शुरू करने की प्रतीक्षा कर रहा है।
- **LOADING**: कैमरा सक्रिय है और सिस्टम डिब्बों को गिनने के लिए शिकार कर रहा है।
- **PAUSED**: सक्रिय सत्र को रोक दिया गया है, आमतौर पर इसलिए क्योंकि ऑपरेटर ने स्क्रीन बदल दी थी या ऐप सत्र के बीच में बंद हो गया था।
- **REVIEW**: AI ने एक फ्रेम कैप्चर कर लिया है और इसे डेटाबेस में सहेजने से पहले मानव पुष्टि की प्रतीक्षा कर रहा है।

---

## 4. चरण-दर-चरण उपयोग गाइड

### A. प्रमाणीकरण और सुरक्षा (Authentication & Security)
- **सुरक्षित लॉगिन**: अपनी एम्प्लॉई आईडी और पासवर्ड दर्ज करें।
- **किल-स्विच सुरक्षा (Kill-Switch)**: यदि कोई व्यवस्थापक वेब एडमिन डैशबोर्ड से आपका खाता अक्षम कर देता है, तो मोबाइल ऐप तुरंत इसका पता लगा लेगा, स्क्रीन को लॉक कर देगा और आपके सुरक्षा टोकन को शुद्ध (purge) कर देगा।

### B. ऐप ड्रावर और नेविगेशन (App Drawer)
डैशबोर्ड के ऊपरी-बाएँ कोने में **विनायक लॉजिस्टिक्स लोगो** पर टैप करें, या स्क्रीन के बाएँ किनारे से स्वाइप करें, **ऐप नेविगेशन ड्रावर** खोलने के लिए। इस ड्रावर में शामिल हैं:
- **वैगन कंट्रोल सेंटर**: मुख्य डैशबोर्ड।
- **डिजिटल रजिस्टर्स**: पूर्ण, निर्यात योग्य पीडीएफ रिपोर्ट तक पहुंचें।
- **डेटा रीफ्रेश करें**: डेटाबेस के साथ सिंक्रनाइज़ करने के लिए ऐप को बाध्य करें।
- **डेटासेट डेवलपर मोड**: इंजीनियरों के लिए कच्चे छवि कैप्चर की समीक्षा करने का एक उपकरण।
- **डेमो डेटा लोड करें**: प्रशिक्षण और परीक्षण के लिए मॉक डेटा इंजेक्ट करता है।

### C. वैगन कंट्रोल सेंटर (डैशबोर्ड)
यह आपका मुख्य परिचालन केंद्र है।
- **सक्रिय ऑपरेशन्स देखें**: शीर्ष कार्ड आपको दिखाते हैं कि कितने वैगन सक्रिय हैं, सिस्टम में कितने ट्रक हैं, और आज लोड किए गए कार्टन की कुल संख्या कितनी है।
- **फ़िल्टर (Filter)**: वैगनों की सूची को फ़िल्टर करने के लिए चिप्स (`सभी`, `प्लानिंग`, `लोडिंग`, `पूर्ण`) का उपयोग करें।
- **एक नया वैगन बनाएँ**: सबसे नीचे बड़े फ्लोटिंग `+ Create Wagon` बटन पर टैप करें। वैगन नंबर (उदा., `W-1002-IND`), मूल स्थान (Origin), गंतव्य (Destination) और अपेक्षित ट्रकों की संख्या दर्ज करें।

### D. वैगन का प्रबंधन करना और ट्रक जोड़ना
इसके विवरण खोलने के लिए डैशबोर्ड में किसी भी वैगन पर टैप करें।
- **एक ट्रक जोड़ें**: `+ Add Truck` बटन पर टैप करें। वाहन संख्या, ड्राइवर का विवरण और कैरियर कंपनी दर्ज करें।
- **वैगन हटाएँ (Delete)**: यदि कोई गलती हो गई है, तो ऊपर दाईं ओर लाल ट्रैश कैन आइकन पर टैप करें। *चेतावनी: हटाने की पुष्टि करने के लिए आपको मैन्युअल रूप से वैगन नंबर टाइप करना होगा।*

### E. ट्रक लोडिंग वर्कस्पेस
ट्रक का लोडिंग वर्कस्पेस खोलने के लिए सूची में किसी ट्रक पर टैप करें।
1. ट्रक को सक्रिय स्थिति में लॉक करने के लिए **Start Loading Session** पर टैप करें।
2. AI कैमरा लॉन्च करने के लिए **Capture Next Layer** पर टैप करें।
3. *ऑटो-रिज्यूम (Auto-Resume) सुविधा: यदि आपका ऐप क्रैश हो जाता है या आप एक सक्रिय सत्र के दौरान इसे गलती से बंद कर देते हैं, तो ऐप अगली बार डैशबोर्ड खोलने पर आपको तुरंत अपने सत्र को फिर से शुरू करने के लिए संकेत देगा!*

### F. AI कैमरा अनुभव (AI Camera)
यह स्मार्टलोड की प्रमुख विशेषता है। लोडिंग डॉक पर खड़े होने पर आप इस स्क्रीन का उपयोग करते हैं।
1. **नीले डैश वाले संरेखण गाइड (alignment guide)** के भीतर ट्रक के पिछले हिस्से को संरेखित करें।
2. गुणवत्ता संकेतक (Quality Indicator, ऊपर बाएँ) के हरा होने (`EXCELLENT`) की प्रतीक्षा करें।
3. बड़े **Capture Layer** बटन (नीचे दाएँ) पर टैप करें।
4. यदि गिनती सही दिखती है, तो **Confirm & Save** पर टैप करें। यदि AI ने एक बॉक्स को याद किया (छोड़ दिया), तो **Reject & Retake** पर टैप करें।
5. प्रत्येक पुष्ट लेयर स्थायी रूप से ट्रक में लॉग इन हो जाती है, और कुल कार्टन गिनती स्वचालित रूप से बढ़ जाती है!

यदि स्क्रीन लॉक, ऐप बदलने या किसी सिस्टम ओवरले के कारण Android कैमरे को
अस्थायी रूप से रोकता है, तो SmartLoad अपने-आप दोबारा कनेक्ट होते समय थोड़ी देर
**Preparing camera...** दिखा सकता है। लाइव तस्वीर वापस आने तक ऐप खुला रखें और
Capture बटन न दबाएँ। पहला सही फ्रेम मिलने के बाद स्टार्टअप एनालिसिस स्ट्रीम बंद
हो जाती है। यदि दो ऑटोमैटिक प्रयास असफल हों, तो **Retry Camera** दबाएँ।

### G. प्रक्रिया को पूरा करना (Completing the Process)
1. **ट्रक को पूरा करें**: एक बार जब ट्रक पूरी तरह से पैक हो जाता है, तो ट्रक वर्कस्पेस पर वापस जाएं और **Complete Loading Session** पर टैप करें। यह आपको ट्रक को लॉक करने से पहले आपकी लेयर्स और डिब्बों का एक सख्त सारांश दिखाएगा। इसके बाद ट्रक को वेयरहाउस भेजा जा सकता है।
2. **ट्रक को वेयरहाउस भेजें**: पूरा हुआ ट्रक आपकी परिवहन प्रक्रिया के अनुसार गंतव्य वेयरहाउस भेजें। SmartLoad उस ट्रक का लोडिंग रिकॉर्ड और कार्टन की संख्या सुरक्षित रखता है।
3. **वैगन को पूरा करें**: वैगन के लिए सभी अपेक्षित ट्रकों के पूरा हो जाने के बाद, वैगन विवरण पर वापस जाएं और **Complete Wagon** पर टैप करें। यदि आप अपेक्षित ट्रकों के लोड होने से पहले एक वैगन को पूरा करने का प्रयास करते हैं, तो ऐप एक सख्त चेतावनी जारी करेगा!
4. **डिजिटल रजिस्टर**: वैगन पूरा हो जाने के बाद, यह स्वचालित रूप से वैगन की एक पेशेवर निर्यात योग्य रिपोर्ट उत्पन्न करता है, जिसमें प्रत्येक ट्रक, ड्राइवर, समय और सटीक कार्टन की गिनती सूचीबद्ध होती है - जो प्रिंट करने या ईमेल करने के लिए तैयार होती है। किसी कागज की आवश्यकता नहीं!

---
*उपयोगकर्ता मैनुअल का अंत। विनायक लॉजिस्टिक्स की संपत्ति।*
''';
