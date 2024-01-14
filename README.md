# python3-installer

## 背景

对于混合部署的实例需要共存多个 Python 环境，为了避免依赖冲突本脚本使用了 virtualenv 管理虚拟环境，实现相互隔离。



### 脚本说明

该脚本默认是基于 OpenSSL-1.1.1 来安装 3.7.11 版本的 Python 。

源码包目录，默认位于执行脚本当前目录的 packages 中。（ 如有自定义路径需求，请修改脚本中 `packages_dir` 变量。 ）

安装目录，默认分别位于 `/usr/local/openssl-1.1.1k` 及 `/usr/local/python-3.7.11` 中。 （ 脚本内写死 ）

虚拟环境目录，默认位于 `/data1/virtualpython` 目录下。 （ 脚本内写死 ）



### 注意事项

- 对于环境变量的改变:
  - 安装完 Python 后，默认会将新版 OpenSSL 加载至系统环境中，加载配置文件 `/etc/ld.so.conf.d/openssl-1.1.1k-x86_64.conf` 。
  - 安装完 Python 后，默认会添加 `/usr/local/python3` 、 `/usr/bin/python3` 、 `/usr/bin/pip3` 三个软链。





---

## 使用方式

### 帮助说明

```bash
source <(curl -sL https://github.com/nestealin/python3-installer/releases/download/v1.0.0/py3_auto_install.sh) -h
```



### 只安装Python3及PiP3

```bash
source <(curl -sL https://github.com/nestealin/python3-installer/releases/download/v1.0.0/py3_auto_install.sh) -d
```



### 安装Python3并安装虚拟环境(virtualenv)

```bash
source <(curl -sL https://github.com/nestealin/python3-installer/releases/download/v1.0.0/py3_auto_install.sh) -v
```

