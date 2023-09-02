# A Stable Diffusion prompt (EXIF metadata) reader made using Flutter

Basically the same thing as the "PNG Info" Tab in Automatic1111's Stable Diffusion WebUI.  
I made this because I didn't want to run the WebUI every time i wanted to check the prompt info (if any exists) etc of an AI image.
Currently only supports PNG.  
Simplified Dart version: <https://gist.github.com/DraconicDragon/86f15644c732370644dfa86475ad007c>

## How to install

Head over to the "Actions" tab on this repository and click on the latest successful run.  
Linux and android (apk) builds are automatically generated on each update to this repository.  
NOTE: The android app works but there's currently no way of putting in a file because the app currently works using drag and drop only.  
(also might consider horizontal image list for all platform as option)

## How To Use

Drag and drop one or multiple images into the application and then select an image.  

### TODO

uh...  
add windows build to actions
add file/folder picker for mainly android so it works on there
publish a release at some point
finish the TODOs in the code aka make UI cool and add helpful-ish functions (image list display settings and horizontal view)
use the project for learning Flutter/Dart and code style (maybe refactor to use MVVM style too?)
