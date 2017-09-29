sudo cd /root
sudo bash /usr/local/aegis/uninstall.sh
sudo curl -sSL https://raw.githubusercontent.com/MeowLove/AlibabaCloud-CentOS7-Pure-and-safe/master/download/kill/quartz_uninstall.sh | sudo bash
sudo rm -rf /usr/local/aegis
sudo rm /usr/sbin/aliyun-service
sudo rm /lib/systemd/system/aliyun.service
