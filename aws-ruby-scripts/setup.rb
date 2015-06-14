require 'aws-sdk'

AWS_ACCESS_KEY_ID="AKIAIV4DS254Y3ZEOOKA"
AWS_SECRET_ACCESS_KEY="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"
AWS_REGION="eu-central-1"

# client constructors
ec2 = Aws::EC2::Client.new(region:AWS_REGION, 
    credentials: Aws::Credentials.new(AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY))

ec2_resources = Aws::EC2::Resource.new(region:AWS_REGION, 
    credentials: Aws::Credentials.new(AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY))

s3 = Aws::S3::Client.new(region:AWS_REGION, 
    credentials: Aws::Credentials.new(AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY))


cluster_filter = [
				{name: "tag:cluster", values: ["spatialHadoop-cluster"]}, 
				{name: "instance-state-name", values: ["running"]} 
			];			

cluster_instances = ec2_resources.instances(cluster_filter)

master = nil
slaves = []

cluster_instances.each do |instance|
	
	tags = instance.tags.select{|t| t.key == 'role'}
	
	if tags.length > 0
		role = tags[0].value
		master = instance if role == "master"
		slaves << instance if role == "slave"
	end

end

puts "\nmaster : \n\t" + master.public_ip_address

puts "\nslaves : "
slaves.each{|slave| puts "\t" +slave.public_ip_address}
