#!/bin/bash

# Simple tool for creating new, working jruby + opencv projects for Mac OSX
# Command names ropencv (ruby opencv)

if [ -z $1 ]; then
   echo "No project name specified! Usage: ropencv [project_name]"
   exit 1
fi


export project_name=$1

echo "Creating main directory..."

mkdir ${project_name}
cd ${project_name}

echo "Creating subdirectories..."

mkdir src lib helpers helpers/org helpers/org/opencv

echo "Creating Library Loader..."

echo "
// This file exists to be compiled with a classpath pointing to the OpenCV jar
// Look at build.sh for further reference
// run.sh executes the JRuby file with a different library path, as would happen
// with a conventional java file

package org.opencv;

import org.opencv.core.Core;

public class LdLibraryLoader {
    static {
        java.lang.System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
    }
}" > helpers/org/opencv/LdLibraryLoader.java

echo "Creating buildfile..."

echo "#!/bin/sh

# This program ensures that the LdLibraryLoader file is compiled with the correct classpath containing the OpenCv jar

OPENCV_JAR=\"${HOME}/opencv-3.1.0/bin/opencv-310.jar\"
JAVA_FILE=\"helpers/org/opencv/LdLibraryLoader.java\"
javac -cp \${OPENCV_JAR} \${JAVA_FILE}" > build.sh

echo "Creating main executable..."

echo "#!/bin/bash

# Main JRuby OpenCV project executable

# Ensure that build.sh is run before this program if it is the first time being executed, or if any changes have been made to build.sh

# This program ensures that JRuby can see the OpenCv .dylib file so LdLibraryLoader can run correctly.

# Specify -W0 before -J-D if you are getting a bunch of warnings from JRuby
# \"Ignored <gem-name> because its extensions are not built.  Try: gem pristine <gem-name> --version x.y.z\" is particularly prevalent in JRuby because of incompatible C gems

jruby -J-Djava.library.path=\${HOME}/opencv-3.1.0/lib/ main.rb \${1}" > run.sh

echo "Creating JRuby main file..."

echo "# Main JRuby OpenCV File
# Execute with run.sh
# As it contains the appropriate alterations to java.library.path

# If this file's name changes, ensure that it is also changed in run.sh

\$CLASSPATH << \"helpers\"
require '${HOME}/opencv-3.1.0/bin/opencv-310.jar'

Java::OrgOpencv::LdLibraryLoader" > main.rb

chmod 755 build.sh run.sh

echo "Creating readme..."

echo "# Jruby OpenCV Project Generator
## ropencv generated:
* Project directory
* \`src\` & \`lib\` directories
* directory structure \`helpers/org/opencv\`
* OpenCV java library loader \`helpers/org/opencv/LdLibraryLoader.java\`
* Buildfile \`build.sh\`
* Main executable \`run.sh\`
* Main JRuby file \`main.rb\`

### __Build file__
**NOTE:** this file must be executed as a final step of project generation - do so before executing \`run.sh\` or editing any other files
* Compiles \`LdLibraryLoader.java\` into a class file with a classpath pointing to the OpenCV jar
* **If this file is edited, ensure it is executed before running \`run.sh\`**

### __Main executable__
* Executes main.rb with the \`java.library.path\` set to the location of \`opencv-java310.dylib\`
**When executing the project, run \`./run.sh\` __NOT__ \`./main.rb\` or \`jruby main.rb\` so JRuby can load the library**

### __Main JRuby File__
* Area for all your project-central code - the main project file
* Other JRuby/Ruby files should be placed in \`src\`
* Do not delete the code that already exists within the file - this code loads in all the appropriate libraries correctly so OpenCV and JRuby will work nicely

### src directory
* Use this for other JRuby files to be required within the main

### lib directory
* Use this for other external \`.jar\` libraries

### Library Loader
* This loads the OpenCV java library so you don't have to go through the pain in the JRuby file execution
* Located within \`helpers/org/opencv\` so can be loaded as a java package of the same name when helpers is in the classpath

## Troubleshooting
* Firstly, ensure that the variables in \`build.sh\` point to the correct installation and variables of OpenCV
* If the version number is incorrect, you will have to change the version number in main.rb and run.sh also" > readme.md

echo "Project ${project_name} created successfully!"
echo "Before usage, copy the complete contents of {opencv directory}/lib directory into ${project_name}/lib"
