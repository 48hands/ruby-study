download_dir = "/usr/local/lib"
download_file = "spark-2.2.0-bin-hadoop2.7.tgz"
download_path = "#{download_dir}/#{download_file}"

spark_path = "#{download_dir}/#{File.basename(download_file,'.tgz')}"
symbolic_path = "#{download_dir}/spark"

%w(java-1.8.0-openjdk java-1.8.0-openjdk-devel).each do |name|
  package name
end

execute "Download Apache Spark 2.2.0" do
  cwd download_dir
  command "curl -O https://d3kbcqa49mib13.cloudfront.net/spark-2.2.0-bin-hadoop2.7.tgz"
  not_if "test -e #{download_path}"
end

execute "Archive Apache Spark 2.2.2" do
  cwd download_dir
  command "tar xvfz #{download_file}"
  not_if "test -e #{spark_path}"
end

link "/usr/local/lib/spark" do
  to spark_path
end

template "/etc/profile.d/spark.sh"