Self learn

#iOS\
Supports iOS 13 and later\
Portrait mode only to change: ios/Runner/Info.plist\
Uncomment line 34,35 for iphone | line 40-42 for ipad\
To change iOS version support: ios/Flutter/AppFrameworkInfo.plist\
chnage value for line 24 under "MinimumOSVersion"

#Android\
Support midsdk 24 (android 7 and above)\
Portrait mode only to change: android/app/src/main/AndroidManifest.xml\
comment "android:screenOrientation="portrait" (line 8)\
To change midsdk version: android/app/build.gradle\
change value for line 55-56 under "defaultConfig"
