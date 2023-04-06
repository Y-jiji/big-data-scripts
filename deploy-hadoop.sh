name="slave-1 slave-2 client master"

# mkdir tmp
mkdir ~/tmp

# download hadoop package if it doesn't exist
cat ~/tmp/hadoop-2.10.1.tar.gz > /dev/null || \
wget https://archive.apache.org/dist/hadoop/common/hadoop-2.10.1/hadoop-2.10.1.tar.gz -P ~/tmp

for n in $(echo $name)
do
	echo $n;
    sudo -u ubuntu ssh ubuntu@$n '
        pids=( $(jps | awk "{print $1}") )
        for pid in "${pids[@]}"; do
            kill -9 $pid || echo ""
        done;
        sudo apt install -y openjdk-8-jdk
        rm -r -f ~/hadoop*
    '
	sudo -u ubuntu scp ~/tmp/hadoop-2.10.1.tar.gz ubuntu@$n:~
	sudo -u ubuntu ssh ubuntu@$n "tar -xzf ~/hadoop-2.10.1.tar.gz"
	sudo -u ubuntu scp -r hadoop/etc ubuntu@$n:~/hadoop-2.10.1
	sudo -u ubuntu ssh ubuntu@$n "sudo chown -R ubuntu ~/hadoop-2.10.1"
done

# format namenode and run hdfs
sudo -u ubuntu rm ~/hadoop-2.10.1/tmp || echo ""
sudo -u ubuntu ~/hadoop-2.10.1/bin/hdfs namenode -format
sudo chown -R ubuntu ~/hadoop-2.10.1