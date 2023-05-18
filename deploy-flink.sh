name="slave-1 slave-2 client master"
pkgs="http://archive.apache.org/dist/flink/flink-1.12.1/flink-1.12.1-bin-scala_2.12.tgz https://downloads.lightbend.com/scala/2.12.2/scala-2.12.2.tgz"

sudo apt install axel

# download all packages to tmp dir
sudo -u ubuntu mkdir ~/tmp
for p in $(echo $pkgs)
do
    # download only if the package doesn't exist
    cat /home/ubuntu/tmp/"$p" > /dev/null || \
    axel "$p" -P /home/ubuntu/tmp/
done

# download
for n in $(echo $name)
do
    # stop all running java process; clear flink
    sudo -u ubuntu ssh ubuntu@$n '
    pids=( $(jps | awk "{print $1}") )
    for pid in "${pids[@]}"; do
        kill -9 $pid || echo ""
    done;
    rm -r -f ~/flink*
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
    # install flink
    sudo -u ubuntu scp -r ~/tmp/flink-1.12.1-bin-scala_2.12.tgz ubuntu@$n:~
    sudo -u ubuntu ssh ubuntu@$n "tar -xzf ~/flink-1.12.1-bin-scala_2.12.tgz"
    # configure flink
    sudo -u ubuntu scp -r flink/conf ubuntu@$n:~/flink-1.12.1
    sudo -u ubuntu ssh ubuntu@$n "sudo chown -R ubuntu ~/flink-1.12.1"
done

source ~/.bashrc
sudo -u ubuntu chown -R ubuntu ~/flink-1.12.1