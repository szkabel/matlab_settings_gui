# matlab_settings_gui
A small framework to simply ask input from users in a GUI. It can be considered as an extension to the built-in inputdlg of Matlab as it supports not only text input but many other types as well.

# Motivation
This small toolbox was designed to simplify parameter inqueries from users. It aims to eliminate the need of creating separate GUIs with customized layouts each and every time one needs to ask for parameters from users. Instead, by a unified parameter description interface it automatically generates the required GUI.

# Usage
The simplest usage of the toolbox is via the Settings_GUI function (GUIDE figure). You only need to create the appropriate parameter descirption variable (paramarray, see description in the doc of generateUIControls.m) and a modal figure is automatically created.

# Example
