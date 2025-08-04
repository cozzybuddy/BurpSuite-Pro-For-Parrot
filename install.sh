#!/bin/bash

# Installing Dependencies
echo "Installing required tools..."
sudo apt update
sudo apt install -y git wget unzip

# Download and setup Oracle JDK 21
echo "Downloading and setting up Oracle JDK 21..."
cd ~
wget -O jdk-21_linux-x64_bin.tar.gz https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz
mkdir -p ~/jdk-21
tar -xzf jdk-21_linux-x64_bin.tar.gz -C ~/jdk-21 --strip-components=1
rm jdk-21_linux-x64_bin.tar.gz

# Export Java environment variables for this script
export JAVA_HOME=~/jdk-21
export PATH="$JAVA_HOME/bin:$PATH"

# Clone the BurpSuite repo
echo "Cloning BurpSuite Professional loader..."
git clone https://github.com/xiv3r/Burpsuite-Professional.git 
cd Burpsuite-Professional || { echo "Repo not found."; exit 1; }

# Download Burp Suite Professional jar
echo "Downloading Burp Suite Professional..."
version=2025
url="https://portswigger.net/burp/releases/download?product=pro&type=Jar"
wget -O "burpsuite_pro_v$version.jar" "$url"

# Start the key loader
echo "Starting Key loader.jar..."
("$JAVA_HOME/bin/java" -jar loader.jar) &

# Create launcher script
echo "Creating launcher script for Burpsuite..."
cat <<EOF > burpsuitepro
#!/bin/bash
JAVA_HOME=\$HOME/jdk-21
\$JAVA_HOME/bin/java \\
--add-opens=java.desktop/javax.swing=ALL-UNNAMED \\
--add-opens=java.base/java.lang=ALL-UNNAMED \\
--add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED \\
--add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED \\
--add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED \\
-javaagent:\$(pwd)/loader.jar -noverify -jar \$(pwd)/burpsuite_pro_v$version.jar &
EOF

chmod +x burpsuitepro
sudo cp burpsuitepro /usr/local/bin/burpsuitepro

# Launch Burp Suite
./burpsuitepro
