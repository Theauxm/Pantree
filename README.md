# Pantree
**Senior Design Capstone Project Spring 2021**

Creators: Trey Lavery, Theaux Masquelier, Ben Perez, Brandon Wong

### Summary
As food delivery becomes increasingly popular, there is less of a focus on individually cooking and organizing food. A few problems arise from food delivery services like DoorDash or HelloFresh, such as an increase in cost per food item as well as a decreased emphasis on nutrition. It is well known how easy these services are to use, and the inconveniences they cut out of everyday life, so this app aims to bridge the gap between the rising cost of food consumption and the problem of food waste as a result of inefficient kitchen management.

Pantree is an application designed to assist in the reduction of food waste and provide nutritional insight for everyday consumers. It will provide a way to manage and track the food in your pantry, generating recipe ideas based on what you have in your kitchen and prioritizing foods that are nearing expiration. You will be able to share your pantry with friends to allow for an easy way to cook with others.

With a target audience of anyone who cooks food, this application has a very wide potential user base that it will help ensure to utilize all purchased ingredients in home prepared meals. This app aims to encourage a healthy rotation in the fridge or pantry while minimizing the amount of food wasted for not being used in time, all while providing exciting and fresh options to cook!


### Installation

First clone the repository or [click here](https://github.com/Theauxm/Pantree/archive/refs/heads/main.zip) to download a .zip of the files.

Then follow the instructions to install the necessary software for the relevant OS below.

##### **Linux:**

###### **Flutter & Dart**

[The install guide](https://flutter.dev/docs/get-started/install/linux) from flutter dev team outlines the installation steps better than we ever could so please go through this first.

###### **Android Studio**

The following is mostly copied from [this link](https://developer.android.com/studio/install). 

**IMPORTANT:** Java SDK 8 is required for a correct installation.

1. Download the Android Studio tar.gz file from [here](https://developer.android.com/studio) and place the extracted files in the ```/usr/local/``` directory.

2. Install required dependencies:
```
sudo apt update
sudo apt install libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386 clang cmake ninja-build pkg-config libgtk-3-dev android-sdk
sudo snap install flutter --classic
flutter sdk-path
flutter upgrade
flutter doctor --android-licenses
```

3. Extract the downloaded file:
```
sudo tar -xvzf ./android-studio-2020.3.1.23-linux.tar.gz -C /usr/local/
```

4. Add Android Studio to PATH and run the application:
```
/usr/local/android-studio/bin/studio.sh
```

5. Go through initial setup instructions. Once finished, click File -> Open

6. Navigate to the project folder you either cloned or downloaded and open ```Pantree/android/build.gradle```. Android Studio should install any required dependencies and automatically work as expected.

---

##### **Windows:**

###### **Flutter & Dart**

[The install guide](https://flutter.dev/docs/get-started/install/windows) from flutter dev team outlines the installation steps better than we ever could so please go through this first.

The following is a condensed version of [this link](https://developer.android.com/studio/install).

###### **Android Studio**

1. Download the Android Studio .exe file from [here](https://developer.android.com/studio).

2. Run the .exe and go through the initial setup instructions.

3. Start Android Studio and run flutter doctor in the terminal to ensure Flutter recognizes your installation of Android Studio.

4. Navigate to the project folder you either cloned or downloaded and open it

