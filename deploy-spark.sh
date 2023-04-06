name="slave-1 slave-2 client master"
pkgs="https://downloads.lightbend.com/scala/2.12.2/scala-2.12.2.tgz https://archive.apache.org/dist/spark/spark-2.4.7/spark-2.4.7-bin-without-hadoop.tgz"

# download all packages to tmp dir
sudo -u ubuntu mkdir ~/tmp
for p in $(echo $pkgs)
do
    # download only if the package doesn't exist
    cat /home/ubuntu/tmp/"$p" > /dev/null || \
    wget "$p" -P /home/ubuntu/tmp/
done

# download
for n in $(echo $name)
do
    # stop all running java process; clear spark
    sudo -u ubuntu ssh ubuntu@$n '
    pids=( $(jps | awk "{print $1}") )
    for pid in "${pids[@]}"; do
        kill -9 $pid || echo ""
    done;
    rm -r -f ~/spark*
    '
    # install java 8 jdk
    sudo -u ubuntu ssh ubuntu@$n "sudo apt install -y openjdk-8-jdk"
    # install scala 2.12.2
    sudo -u ubuntu scp -r ~/tmp/scala-2.12.2.tgz ubuntu@$n:~
    sudo -u ubuntu ssh ubuntu@$n "tar -xzf scala-2.12.2.tgz"
    sudo -u ubuntu ssh ubuntu@$n "sudo chown -R ubuntu scala-2.12.2"
    sudo -u ubuntu ssh ubuntu@$n "sudo mv scala-2.12.2 /usr/local/scala-2.12.2"
    sudo -u ubuntu ssh ubuntu@$n "echo 'export TERM=xterm-color' >> ~/.bashrc"
    sudo -u ubuntu ssh ubuntu@$n "source ~/.bashrc"
    # install spark
    sudo -u ubuntu scp -r ~/tmp/spark-2.4.7-bin-without-hadoop.tgz ubuntu@$n:~
    sudo -u ubuntu ssh ubuntu@$n "tar -xzf ~/spark-2.4.7-bin-without-hadoop.tgz"
    sudo -u ubuntu ssh ubuntu@$n "mv ~/spark-2.4.7-bin-without-hadoop ~/spark-2.4.7"
    # configure spark
    sudo -u ubuntu scp -r spark/conf ubuntu@$n:~/spark-2.4.7
    sudo -u ubuntu scp -r spark/sbin ubuntu@$n:~/spark-2.4.7
    sudo -u ubuntu ssh ubuntu@$n "sudo chown -R ubuntu ~/spark-2.4.7"
done

source ~/.bashrc
sudo -u ubuntu chown -R ubuntu ~/spark-2.4.7

sudo -u ubuntu ~/hadoop-2.10.1/sbin/start-dfs.sh && \
sudo -u ubuntu ~/hadoop-2.10.1/bin/hdfs dfs -mkdir -p /tmp/spark_history && \
sudo -u ubuntu ~/hadoop-2.10.1/sbin/stop-dfs.sh