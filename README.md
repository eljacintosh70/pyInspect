PyInspect is a program in Lazarus/Free Pascal
to inspect Python code using a VirtualTreeView.

It uses [Python4Delphi] (https://github.com/pyscripter/python4delphi) to evaluate Python code

and [VirtualTreeView-Lazarus] (https://github.com/blikblum/VirtualTreeView-Lazarus) to display it.

### Compiling with Lazarus 3 ###

* Install "VirtualTreeView/Source/virtualtreeview_package.lpk"
* Build "Source/LPR/PyInspect.lpi"

### Compiling with Delphi ###

* Python4Delphi has packages for Delphi 10.3 and 10.4+, to work with older versions you need the get an older commit.
  e5b2c0dc works with Delphi XE7, but you need to change
  
  the path: "..\..\python4delphi\Source"
  
  to: "..\..\python4delphi\PythonForDelphi\Components\Sources\Core"
  
  in the options of "Source\DPR\PyInspect.dpr"

* VirtualTreeView for Delphi can be obtained from:
  (https://github.com/Virtual-TreeView/Virtual-TreeView)
  and (https://github.com/JAM-Software/Virtual-TreeView.git)
  
  The branch V5_stable works with Delphi7 to DelphiXE7
  The commit 9437f677 from VirtualTreeView-Lazarus can be used too

* Install the VirtualTreeView packages for the version of Delphi you are using

* Build "Source/DPR/PyInspect.dpr"

### GUI ###

* This is how the GUI looks after loading Sample.py, and then pressing the buttons: "Execute script", "main" and "locals"
<img src="https://github.com/eljacintosh70/pyInspect/blob/main/doc/PyInspect.png?raw=true">

### Problems ###

The explore windows don't de-reference the python objects when they are closed...

so there are memory leaks every time you open and close one of them.

