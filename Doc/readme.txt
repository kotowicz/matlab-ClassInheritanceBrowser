CLASS INHERITANCE BROWSER - version 0.4.1

Copyright Clayton Ernst, Andrew Hagen, Eric Lee and Andreas Kotowicz 2010.
Written for Engineering 177 Spring 2010, Final Project. Professor: Andy Packard, UC Berkeley.

INTRODUCTION

The class inheritance browser searches a given directory and displays a visual representation
of class inheritance in the form of a tree diagram. Additionally, a browser window is created
showing information about classes in the given directory, as well as inherited classes. Information
displayed includes name, properties, methods, and superclasses for each class.

INSTRUCTIONS

To use the class inheritance browser, call it using the syntax 'classInheritance.browse('path-to-directory')',
replacing 'path-to-directory' with the path to the desired directory. The path can specify the directory either
relative to the current directory or be an absolute path. A zero-argument call will search the current directory.
The directory containing the +classInheritance package must be on the Matlab path, or be the current directory. 
See the included example.m file for an example.

FEATURES
[version 0.1 - May 2010]
- Selecting a class name in the browser window highlights the class in the tree diagram.
- Class names can be searched for using the search box. Results are for any partial match to the class name.
- The directory can be changed via the directory input box. Directories can be relative or absolute with respect
  to the current directory.
[version 0.2 - updated 8th August 2010]
- Numerous bugs fixed, speed improved
- Show number of properties and method in current class
- Use the 'Browse' button to jump to a new directory
- Right clicking on a method name opens the proper file to the proper line where the method is defined
- Right clicking on a property name prints property help to the console, if available
[version 0.3 - updated 10th August 2010]
- clean up code
- try harder to find user supplied class name
- catch classInheritance.iTree errors in classInheritance.browse
- made package +inex out of inheritanceexample directory.
[version 0.4 - updated 12th August 2010]
- check if bioinformatics toolbox is available. If it's not available, 
  then ignore the biograph part.
[version 0.41 - updated 18th August 2010]
- check also if network license for bioinformatics toolbox is available.

NOTES

- This tool makes use of the biograph function from the Bioinformatics toolbox. If this toolbox is not 
  installed, the class inheritance browser will not be able to display the tree diagram.

LICENSE

Class Inheritance Browser Copyright Clayton Ernst, Andrew Hagen, Eric Lee and Andreas Kotowicz, 2010. 
This work is licensed under the Creative Commons Attribution 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/ or 
send a letter to Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
