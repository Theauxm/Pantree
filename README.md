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


---
####**MacOS:**

The following has been adapted from https://flutter.dev/docs/get-started/install/macos

1. Download and Install the Flutter SDK from https://flutter.dev/docs/get-started/install/macos

2. Extract the at desired location 
  ```
  $ cd ~/development
  $ unzip ~/Downloads/flutter_macos_2.2.3-stable.zip
  ```
3. Add the Flutter SDK as a path variable to your rc file.  
  ```
  $ export PATH="$PATH:[PATH_OF_FLUTTER_GIT_DIRECTORY]/bin"
  ```

4. Alternative Download with HomeBrew
  ```
   $ brew install --cask flutter
  ```
5. Flutter requires Android Studio, click the following link to download https://developer.android.com/studio

6. Run flutter doctor to ensure that flutter had downloaded successfully, and Android Studio dependency is satisfied
  ```
  $ flutter doctor
  ```
7. Accept the Android Licenses 
  ``` 
  $ flutter doctor --android-licenses
  ```
8. Download the Flutter and Dart plugins for Android Studio

  - Open plugin preferences (Preferences > Plugins as of v3.6.3.0 or later).
  - Select the Flutter plugin and click Install.
  - Click Yes when prompted to install the Dart plugin.
  - Click Restart when prompted.

9. Update Languages & Frameworks option to point to Flutter SDK

- Open Language & Frameworks preferences (Preferences > Language & Framework > Flutter/Dart)
- Update Flutter SDK path to the installation destination defined earlier
- Update Dart SDK path within the Flutter SDK installation destination, then '...bin/cache/dart-sdk'

10. Clone the pantree repository 

- git clone https://github.com/Theauxm/Pantree.git

11. Navigate to the repository's folder, open ```Pantree/android/build.gradle```, wait for the gradle to finish building

12.  run main.dart to begin the application

