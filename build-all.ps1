# Build script for TalaqqiHub
# Compiles all Java source files with proper classpath

$JAVAC = "javac"
$ENCODING = "-encoding UTF-8"
$SERVLET_JAR = "C:\xampp\tomcat\lib\servlet-api.jar"
$SOURCE_DIR = "src"
$OUTPUT_DIR = "WEB-INF\classes"
$LIB_DIR = "WEB-INF\lib"

# Create output directory if it doesn't exist
if (-not (Test-Path $OUTPUT_DIR)) {
    New-Item -ItemType Directory -Path $OUTPUT_DIR | Out-Null
}

# Get all Java files
$javaFiles = Get-ChildItem -Path $SOURCE_DIR -Recurse -Filter "*.java" | Select-Object -ExpandProperty FullName

if ($javaFiles.Count -eq 0) {
    Write-Host "No Java files found!"
    exit 1
}

# Build classpath with all JAR files explicitly included
$libJars = Get-ChildItem -Path $LIB_DIR -Filter "*.jar" | Select-Object -ExpandProperty FullName
$classpathItems = @($SERVLET_JAR) + $libJars
$classpath = $classpathItems -join ";"

Write-Host "Compiling $($javaFiles.Count) Java files..."
Write-Host "Classpath: $classpath"

# Compile
& $JAVAC $ENCODING.Split()[0] $ENCODING.Split()[1] -cp "$classpath" -d $OUTPUT_DIR -sourcepath $SOURCE_DIR $javaFiles

if ($LASTEXITCODE -eq 0) {
    Write-Host "Compilation successful!"
} else {
    Write-Host "Compilation failed with error code $LASTEXITCODE"
    exit 1
}
