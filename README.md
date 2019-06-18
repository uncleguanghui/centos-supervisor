# 快速部署Supervisor

本项目用于以`root`身份在Centos快速部署supervisor

# 上手指南

## clone

```
git clone https://github.com/uncleguanghui/centos-supervisor.git
cd centos-supehvisor
```

进来后可以看到

```
.
├── README.md
├── deploy_centos.sh  # 部署脚本
├── supervisord.conf  # supervisor配置
└── supervisord.service  # 系统开机启动配置

0 directories, 4 files
```

在真正开始部署之前，先让我们了解一下配置。

## 配置说明

[参考文章](https://www.rddoc.com/doc/Supervisor/3.3.1/zh/configuration/)

supervisor配置文件通常命名为`supervisord.conf`。它被 supervisord 和 supervisorctl 使用。如果任一应用程序在没有 -c 选项（用于明确告知应用程序配置文件名的选项）的情况下启动，则应用程序将按照指定的顺序在以下位置中查找名为 supervisord.conf 的文件。它将使用它找到的第一个文件。

* $CWD/supervisord.conf
* $CWD/etc/supervisord.conf
* /etc/supervisord.conf
* /etc/supervisor/supervisord.conf （自Supervisor 3.3.0之后）
* ../etc/supervisord.conf （相对于可执行文件）
* ../supervisord.conf （相对于可执行文件）

在本项目的`supervisord.conf`文件中，保留了最基本的一些配置，下面稍微说明一下：
1. `[unix_http_server]`：可以不用管，会启动在UNIX域套接字上监听的HTTP服务器
1. `[inet_http_server]`：供外部访问，会启动在TCP（Internet）套接字上监听的HTTP服务器
    1. `port`：ip + 端口，设为`*:port`可以监听机器中的所有接口，在我的配置文件里端口为`8010`，因此可以通过，`http://服务器IP:8010/`来访问supervisor-web
    1. `username`&`password`：给web加个登陆验证
1. `[supervisord]`： 与supervisord 进程相关的全局设置，主要放了一些日志相关的参数，都是官方默认值，可以不用管，主要看`user`
    1. `user`：只能以该用户启动supervisor
1. `[rpcinterface:supervisor]`：可以不用管，但不能删除，用于让supervisor正常工作
1. `[supervisorctl]`：用于访问supervisor的URL，相关参数一定要与`[inet_http_server]`一致
1. `[include]`：用于搜索其他配置文件
    1. `files`：文件序列，文件模式为glob，可以是绝对路径或相对路径，多个文件用空格隔开。在我的配置里，需要用户把配置文件（以`.ini`后缀）全部写入`/etc/supervisor/config.d/`目录下

## 部署

```
sh deploy_centos.sh
```

# 其他命令

## 关闭supervisor

```
systemctl stop supervisord.service
```

## 重启supervisor

当你修改了`supervisord.conf`之后

```
supervisorctl reload
```

## 重启项目

当你修改了`config.d`下的配置文件之后

```
supervisorctl update 配置名称
```