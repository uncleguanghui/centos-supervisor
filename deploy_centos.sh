# 先登陆服务器，切换到root用户再操作

# ########################## 配置项 ##########################
# 配置文件
dir_parent=$(cd `dirname $0`;pwd)
conf_supervisor=$dir_parent/supervisord.conf
conf_start=$dir_parent/supervisord.service
conf_start_new=$dir_parent/supervisord_new.service

# etc目录
dir_conf=/etc/supervisor/config.d
target_conf=/etc/supervisor/supervisord.conf

# 系统启动
target_start=/usr/lib/systemd/system/supervisord.service

# ########################## 关闭服务 ##########################

# 若服务启动，则杀死
if [ -f "$target_start" ]; then
    systemctl stop supervisord.service
fi
for pid in $(pidof -x supervisord); do
    if [ $pid != $$ ]; then
        echo "[$(date)] : supervisord : 程序正在运行， PID $pid"
        kill -9 $pid
    fi
done

# ########################## 安装并配置 ##########################

# 安装
if [ ! -f "/bin/supervisord" ]; then
    pip install supervisor
fi

# 创建配置目录，并修改权限为767（方便其他用户往里添加）
if [ ! -f "$dir_conf" ]; then
    mkdir -p $dir_conf
fi
chmod 767 $dir_conf

# 复制配置
if [ -f "$target_conf" ]; then
    rm -rf $target_conf
fi
cp $conf_supervisor  $target_conf

# ########################## 设置启动 ##########################

# 设置开机自启动
supervisord=$(which supervisord)
supervisorctl=$(which supervisorctl)
if [ -f "$target_start" ]; then
    rm -rf $target_start
fi
# 替换字符串
sed -i -e 's#=supervisord#='${supervisord}'#g' $conf_start > $conf_start_new
sed -i -e 's#=supervisorctl#='${supervisorctl}'#g' $conf_start_new
mv $conf_start_new $target_start
chmod 644 $target_start
systemctl daemon-reload
systemctl enable supervisord.service
systemctl start supervisord.service

# 其他命令1：重新加载配置
# systemctl daemon-reload
# systemctl reload supervisord.service
# 其他命令2：关闭进程
# systemctl stop supervisord.service

IP=$(hostname -I | awk '{ print $1 }')
echo "All done!"
echo "Supervisor URL: $IP:8010"