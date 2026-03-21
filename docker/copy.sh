#!/bin/sh

# 复制项目的文件到对应docker路径，便于一键生成镜像。
usage() {
	echo "Usage: sh copy.sh"
	exit 1
}


# copy sql
echo "begin copy sql "
cp ../sql/hospital_20250523.sql ./mysql/db
cp ../sql/hospital-config_20260311.sql ./mysql/db

# copy html
echo "begin copy html "
cp -r ../hospital-ui/dist/** ./nginx/html/dist


# copy jar
echo "begin copy hospital-gateway "
cp ../hospital-gateway/target/hospital-gateway.jar ./hospital/gateway/jar

echo "begin copy hospital-auth "
cp ../hospital-auth/target/hospital-auth.jar ./hospital/auth/jar

echo "begin copy hospital-visual "
cp ../hospital-visual/hospital-monitor/target/hospital-visual-monitor.jar  ./hospital/visual/monitor/jar

echo "begin copy hospital-modules-system "
cp ../hospital-modules/hospital-system/target/hospital-modules-system.jar ./hospital/modules/system/jar

echo "begin copy hospital-modules-file "
cp ../hospital-modules/hospital-file/target/hospital-modules-file.jar ./hospital/modules/file/jar

echo "begin copy hospital-modules-job "
cp ../hospital-modules/hospital-job/target/hospital-modules-job.jar ./hospital/modules/job/jar

echo "begin copy hospital-modules-gen "
cp ../hospital-modules/hospital-gen/target/hospital-modules-gen.jar ./hospital/modules/gen/jar

