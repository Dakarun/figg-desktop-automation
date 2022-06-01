#!/usr/bin/env zsh

set -e

function install_spark() {
  curl $SPARK_DOWNLOAD_URL -o /tmp/spark-${SPARK_VERSION}-bin-hadoop3.2.tgz
  mkdir -p $SPARK_HOME
  tar -xzf /tmp/spark-${SPARK_VERSION}-bin-hadoop3.2.tgz -C $SPARK_HOME --strip-components=1

  curl ${HADOOP_AWS_DOWNLOAD_URL} -o ${SPARK_HOME}/jars/hadoop-aws-${HADOOP_AWS_VERSION}.jar
  curl ${AWS_JAVA_SDK_DOWNLOAD_URL} -o ${SPARK_HOME}/jars/aws-java-sdk-bundle-${AWS_JAVA_SDK_VERSION}.jar
  echo -e '\n# spark variables' >> ~/.zshrc
  echo 'export PATH="$HOME/.spark/bin:$PATH"' >> ~/.zshrc
  echo "# spark variables end" >> ~/.zshrc
  rm /tmp/spark-${SPARK_VERSION}-bin-hadoop3.2.tgz

  cat > ${SPARK_HOME}/conf/core-site-test.xml << EOL
  <?xml version="1.0"?>
  <?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
  <configuration>
    <property>
      <name>fs.s3a.aws.credentials.provider</name>
      <value>org.apache.hadoop.fs.s3a.TemporaryAWSCredentialsProvider</value>
    </property>
  </configuration>
EOL
}

# Install pyenv
echo "Installing pyenv"
USER_HOME=/home/$(whoami)
if [[ -d "${USER_HOME}/.pyenv" ]]; then
  echo "pyenv is already installed, skipping"
else
  apt install build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python3-openssl python3-pip
  git clone https://github.com/pyenv/pyenv.git ~/.pyenv
  echo -e '\n# pyenv variables' >> ~/.zshrc
  echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
  echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
  echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n eval "$(pyenv init -)"\nfi' >> ~/.zshrc
  echo "# pyenv variables end" >> ~/.zshrc
  source ~/.zshrc
  pyenv install 3.7.13
fi

# Install spark
echo "Installing spark"
SPARK_VERSION=3.1.3
HADOOP_AWS_VERSION=3.2.3
AWS_JAVA_SDK_VERSION=1.12.227
SPARK_DOWNLOAD_URL=https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.2.tgz
HADOOP_AWS_DOWNLOAD_URL=https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_AWS_VERSION}/hadoop-aws-${HADOOP_AWS_VERSION}.jar
AWS_JAVA_SDK_DOWNLOAD_URL=https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_JAVA_SDK_VERSION}/aws-java-sdk-bundle-${AWS_JAVA_SDK_VERSION}.jar
SPARK_HOME=~"${USER_HOME}/.spark"

if [[ -d $SPARK_HOME ]]; then
  SPARK_INSTALLED_VERSION=$(head -1 ${SPARK_HOME}/RELEASE | cut -d ' ' -f2)
  if [[ $SPARK_INSTALLED_VERSION == $SPARK_VERSION ]]; then
    echo "Spark is already installed at the expected version, skipping"
  else
    read -p "Current spark is ${SPARK_INSTALLED_VERSION}, but ${SPARK_VERSION} is expected. This process will remove the old install and replace it with ${SPARK_VERSION}. Proceed? [y/n]" OVERWRITE_SPARK
    case $OVERWRITE_SPARK in
      [Yy]* ) echo "Overwriting spark";;
      [Nn]* ) echo "Exiting script"; break;;
      * ) echo "Didn't receive Y/y, exiting"; exit;;
    esac
    rm -rf $SPARK_HOME
    install_spark
  fi
  else
    install_spark
fi

# Install parquet-tools
echo "Installing parquet-tools"
pip install parquet-tools
