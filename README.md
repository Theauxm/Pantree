# Pantree
**Senior Design Capstone Project Spring 2021**

Creators: Trey Lavery, Theaux Masquelier, Ben Perez, Brandon Wong

### Summary
As food delivery becomes increasingly popular, there is less of a focus on individually cooking and organizing food. A few problems arise from food delivery services like DoorDash or HelloFresh, such as an increase in cost per food item as well as a decreased emphasis on nutrition. It is well known how easy these services are to use, and the inconveniences they cut out of everyday life, so this app aims to bridge the gap between the rising cost of food consumption and the problem of food waste as a result of inefficient kitchen management.

Pantree is an application designed to assist in the reduction of food waste and provide nutritional insight for everyday consumers. It will provide a way to manage and track the food in your pantry, generating recipe ideas based on what you have in your kitchen and prioritizing foods that are nearing expiration. You will be able to share your pantry with friends to allow for an easy way to cook with others.

This application has a wide potential user base, targeting audiences who actively cook to ensure they utilize all purchased ingredients in home prepared meals. This app aims to encourage a healthy rotation in the fridge or pantry while minimizing the amount of food wasted due to reaching the expiration date to , all while providing exciting and fresh options to cook!


### Installation
**Linux:**
The following is mostly copied from [this link](https://developer.android.com/studio/install). **IMPORTANT:** Java SDK 8 is required for a correct installation.

1. Download the Android studio tar.gz file from [here](https://developer.android.com/studio) and place the extracted files in the ```/usr/local/``` directory.

2. Install required dependencies:
```
sudo apt update
sudo apt install libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386 clang cmake ninja-build pkg-config libgtk-3-dev
sudo snap install flutter --classic
flutter sdk-path
flutter doctor --android-licenses
flutter upgrade
```

3. Extract the downloaded file:
```
sudo tar -xvzf ./android-studio-2020.3.1.23-linux.tar.gz -C /usr/local/
```

4. Run the application:
```
/usr/local/android-studio/bin/studio.sh
```

5. Go through initial setup instructions. Once finished, click File -> Open

6. Navigate to this repo's folder and open ```Pantree/android/build.gradle```. Android Studio should install any required dependencies and automatically work as expected.

