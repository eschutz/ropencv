# ROpenCV
---
__(Ruby-OpenCV)__

ROpenCV is a script that enables the creation of JRuby projects that utilise OpenCV, [such as this one](https://github.com/eschutz/emojify).

ROpenCV bypasses all the trouble of manually creating a Java library workaround and creates a main executable shell script that adds the required files to the classpath.

## Usage
`ropencv [project-name]`

For further usage, look at the `README.md` generated after executing `ropencv`.

## Installation
```
git clone https://github.com/eschutz/ropencv ropencv
cd ropencv
./configure
```