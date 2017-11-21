#/bin/sh
yum update -y
yum install wget git -y
yum install epel-release -y
yum install libsodium -y
yum install python-setuptools easy_install pip -y
yum -y groupinstall “Development Tools”
wget https://bootstrap.pypa.io/get-pip.py
if [ ! -d "/usr/bin/pip" ]; then
  python get-pip.py
fi
rm -rf get-pip.py
#配置pypi源
if [ ! -d "/root/.pip" ]; then
  mkdir /root/.pip
fi
echo "[global]
index-url=https://mirror-ord.pypi.io/simple

[install]
trusted-host=mirror-ord.pypi.io" > ~/.pip/pip.conf

echo "[easy_install]
index-url=https://mirror-ord.pypi.io/pypi/simple/" > ~/.pydistutils.cfg

#下载后端
pip install cymysql
cd
rm -rf shadowsocks
git clone -b manyuser https://github.com/glzjin/shadowsocks.git
cd shadowsocks

chmod +x *.sh
pip  install -r requirements.txt
cp apiconfig.py userapiconfig.py
#加入自启动
chmod +x /etc/rc.d/rc.local
echo "bash /root/shadowsocks/run.sh" >> /etc/rc.d/rc.local

#对接面板
echo
read -p "Please input your node_id: " node_id
echo
read -p "Please input your mysql host: " sqlhost
echo
read -p "Please input your mysql username: " sqluser
echo
read -p "Please input your mysql password: " sqlpass
echo
read -p "Please input your mysql dbname: " sqldbname

sed -i "2s/1/$node_id/g" /root/shadowsocks/userapiconfig.py
sed -i "15s/modwebapi/glzjinmod/1"  /root/shadowsocks/userapiconfig.py
sed -i "24s/127.0.0.1/$sqlhost/g" /root/shadowsocks/userapiconfig.py
sed -i "26s/ss/$sqluser/g" /root/shadowsocks/userapiconfig.py
sed -i "27s/ss/$sqlpass/g" /root/shadowsocks/userapiconfig.py
sed -i "28s/shadowsocks/$sqldbname"/g /root/shadowsocks/userapiconfig.py

#配置supervisor
pip install supervisor
wget -O /etc/supervisord.conf https://raw.githubusercontent.com/nya-static/src/master/etc/supervisord.conf
wget -O /etc/init.d/supervisord https://raw.githubusercontent.com/nya-static/src/master/etc/init.d/supervisord
chmod +x /etc/init.d/supervisord
if [ ! -d "/var/log/supervisor" ]; then
  mkdir /var/log/supervisor
fi
sudo service supervisord stop
sudo service supervisord start
sudo supervisorctl reload

#iptables
systemctl stop firewalld.service
systemctl disable firewalld.service
yum install iptables -y
iptables -F
iptables -X
iptables -I INPUT -p tcp --dport 3306 -j ACCEPT

# 取消文件数量限制
sed -i '$a * hard nofile 512000\n* soft nofile 512000' /etc/security/limits.conf

#aliyun service
wget https://raw.githubusercontent.com/nya-static/src/master/sh/rm-aliyun-service.sh
if [ -f /usr/sbin/aliyun-service ]
then
    bash rm-aliyun-service.sh;
fi
cd
cd sha*
bash run.sh
echo done.....
