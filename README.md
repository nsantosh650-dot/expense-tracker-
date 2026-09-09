# खर्च ट्र्याकर — Flutter App

यो एउटा साधारण daily expense tracker Android app हो। Data फोनमै (local storage) save हुन्छ।

## 0. सबैभन्दा सजिलो तरिका — Computer मा केही install नगरिकनै APK पाउने

यदि तपाईं आफ्नो computer मा Flutter/Android Studio install गर्न चाहनुहुन्न भने, यो तरिका प्रयोग गर्नुहोस् — GitHub ले free मा आफैं build गरिदिन्छ, तपाईंले फोनमा install गर्न मिल्ने APK मात्र download गर्नुपर्छ।

**Steps:**

1. https://github.com मा free account बनाउनुहोस् (नभए)।
2. "New repository" थिचेर नयाँ repo बनाउनुहोस् (नाम जे पनि राख्नुहोस्, जस्तै `expense-tracker`), **Public** राख्नुहोस्।
3. Repo खोलेर "Add file" → "Upload files" थिच्नुहोस्।
4. यो सम्पूर्ण `expense_tracker` फोल्डर भित्रका सबै फाइल/फोल्डर (`.github` फोल्डर सहित — यो नदेखिन सक्छ, "Show hidden files" गरेर देखाउनुहोस्) drag-drop गरेर upload गर्नुहोस्। **फोल्डर संरचना उस्तै रहनुपर्छ** (जस्तै `lib/main.dart`, `.github/workflows/build-apk.yml`)।
5. "Commit changes" थिच्नुहोस्।
6. Repo माथि "Actions" tab मा जानुहोस् — त्यहाँ build आफैं सुरु भइरहेको देख्नुहुन्छ (५-१० मिनेट लाग्छ)। हरियो ✅ नदेखिएसम्म कुर्नुहोस्।
7. Build पूरा भएपछि, त्यही page मा तल **"expense-tracker-apk"** भन्ने artifact देखिन्छ — त्यसमा click गरेर download गर्नुहोस् (यो एउटा .zip file आउँछ, भित्र APK हुन्छ)।
8. Zip extract गर्नुहोस्, `app-release.apk` फाइल फोनमा पठाउनुहोस् (WhatsApp/email/USB जुनसुकै तरिकाले)।
9. फोनमा त्यो APK file थिचेर install गर्नुहोस् — पहिलो पटक "install from unknown sources" allow गर्न सोध्न सक्छ, allow गर्नुहोस्।

यति गरेपछि app सिधै तपाईंको फोनमा चल्न थाल्छ — Play Store मा नराखिकनै test गर्न मिल्छ।

---

## 1. Setup (कम्प्युटरमा आफैं build गर्ने हो भने — वैकल्पिक)

1. **Flutter SDK install** गर्नुहोस्: https://docs.flutter.dev/get-started/install
2. **Android Studio install** गर्नुहोस्: https://developer.android.com/studio
3. Terminal मा जाँच गर्नुहोस्:
   ```
   flutter doctor
   ```
   यसले के-के थप चाहिन्छ भनेर देखाउँछ (जस्तै Android licenses accept गर्ने)।

## 2. Project चलाउने (टेस्ट गर्न)

**महत्त्वपूर्ण:** यो फोल्डरमा `lib/main.dart` र `pubspec.yaml` मात्र दिइएको छ — Android/iOS platform फाइलहरू (जुन Play Store build को लागि चाहिन्छ) छैनन्। ती auto-generate गर्न:

1. यो `expense_tracker` फोल्डर आफ्नो computer मा राख्नुहोस्।
2. Terminal मा फोल्डर भित्र गएर, पहिले platform फाइलहरू बनाउनुहोस् (यसले `android/`, `ios/` फोल्डर बनाइदिन्छ, तर हाम्रो `lib/main.dart` र `pubspec.yaml` लाई छुँदैन):
   ```
   flutter create .
   ```
3. अनि dependencies तान्नुहोस् र चलाउनुहोस्:
   ```
   flutter pub get
   flutter run
   ```
4. यसले phone (USB जोडेको) वा emulator मा app खोल्छ।

## 3. Play Store मा राख्नको लागि Build गर्ने

1. **App ID राख्नुहोस्** — `android/app/build.gradle` फाइलमा `applicationId` लाई आफ्नो unique नाम दिनुहोस् (जस्तै `com.yourname.expensetracker`)।
2. **Signing key बनाउनुहोस्** (Google ले माग्छ):
   ```
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
3. `android/key.properties` फाइल बनाएर keystore को details राख्नुहोस् (Flutter को official guide हेर्नुहोस्: https://docs.flutter.dev/deployment/android)
4. **Release build बनाउनुहोस्**:
   ```
   flutter build appbundle
   ```
   यसले `build/app/outputs/bundle/release/app-release.aab` फाइल बनाउँछ — यही Play Store मा upload गर्ने फाइल हो।

## 4. Google Play Console मा Publish गर्ने

1. https://play.google.com/console मा जानुहोस्, $25 one-time fee तिरेर account खोल्नुहोस्।
2. "Create app" थिच्नुहोस् — नाम, भाषा, free/paid छान्नुहोस्।
3. Store listing भर्नुहोस्:
   - App description
   - Screenshots (कम्तिमा 2 वटा — emulator/phone बाट लिन सकिन्छ)
   - App icon (512x512 px)
   - Privacy policy link (एउटा साधारण page बनाएर link दिनुपर्छ)
4. "Production" section मा गएर `app-release.aab` upload गर्नुहोस्।
5. Content rating, target audience जस्ता प्रश्नहरू भर्नुहोस्।
6. Review को लागि पठाउनुहोस् — Google ले सामान्यतया १-७ दिन लिन्छ।

## 5. App Icon लगाउने (Design तयार छ)

`assets/app_icon.svg` मा एउटा wallet-themed icon design दिइएको छ (हरियो background, सेतो wallet, रु. coin)।

**Steps:**
1. SVG लाई PNG मा convert गर्नुहोस् (कम्तिमा 512x512 px) — free online tool प्रयोग गर्नुहोस्: https://cloudconvert.com/svg-to-png (SVG file upload गरेर 512x512 size दिनुहोस्)
2. Convert भएको PNG लाई `assets/app_icon.png` नामले save गर्नुहोस् (यही folder path मा, `expense_tracker/assets/` भित्र)
3. Terminal मा यी command चलाउनुहोस्:
   ```
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```
4. यसले Android/iOS दुवैको लागि आवश्यक सबै size मा icon auto-generate गरिदिन्छ — अरू केही गर्नुपर्दैन।

Design आफैं फेर्न चाहनुभयो भने `assets/app_icon.svg` लाई कुनै text editor वा Figma/Canva मा खोलेर रङ/design बदल्न सकिन्छ।

## 6. Privacy Policy Online राख्ने (Play Store अनिवार्य माग्छ)

`privacy_policy.html` तयार छ। Play Store ले यसको **public link** माग्छ (फाइल मात्र भए हुँदैन)। सबैभन्दा सजिलो free तरिका — **GitHub Pages**:

1. https://github.com मा free account बनाउनुहोस् (नभए)
2. नयाँ repository बनाउनुहोस् (जस्तै `expense-tracker-privacy`)
3. `privacy_policy.html` लाई `index.html` नाम दिएर upload गर्नुहोस्
4. Repository Settings → Pages मा गएर "Enable" गर्नुहोस्
5. केही मिनेटमा यस्तो link पाउनुहुन्छ: `https://yourusername.github.io/expense-tracker-privacy/`
6. यही link Play Console को store listing मा राख्नुहोस्

फाइल भित्र `[यहाँ मिति राख्नुहोस्]` र `[यहाँ आफ्नो email राख्नुहोस्]` ठाउँमा आफ्नो जानकारी भर्न नबिर्सनुहोस्।

## App का Features

- खर्च थप्ने (विवरण, रकम, category)
- Category अनुसार रंगीन tag
- आजको र जम्मा खर्च देखाउने
- खर्च मेटाउन मिल्ने
- Data phone मै save हुने (app बन्द गरेर खोल्दा पनि रहन्छ)

## अझ थप्न सकिने Features (पछि)

- Category अनुसार filter/chart
- Monthly summary
- Export गर्ने (CSV/PDF)
- Multiple currency support
