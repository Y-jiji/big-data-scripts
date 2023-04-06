rm *.zip*    || echo ""
rm *.tar.gz* || echo ""
rm *.tar*    || echo ""

# get the dataset
wget https://github.com/ymcui/Chinese-Cloze-RC/archive/master.zip
# get the data set
unzip master.zip
unzip Chinese-Cloze-RC-master/people_daily/pd.zip
rm -r ~/input || echo "input folder already removed"
mkdir ~/input
mv pd/pd.train ~/input

# clean up
rm -r Chinese-Cloze-RC-master
rm -r pd 
rm *.zip
