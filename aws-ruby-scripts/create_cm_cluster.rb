#require 'rubygems'
require 'aws-sdk'

AWS_ACCESS_KEY_ID="AKIAIV4DS254Y3ZEOOKA"
AWS_SECRET_ACCESS_KEY="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"
AWS_REGION="eu-central-1"

credentials = Aws::Credentials.new(AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY);

# client constructors
ec2 = Aws::EC2::Client.new(region:AWS_REGION, 
    credentials: credentials)

ec2_resources = Aws::EC2::Resource.new(region:AWS_REGION, 
    credentials: credentials)

s3 = Aws::S3::Client.new(region:AWS_REGION, 
    credentials: credentials)

ops = Aws::OpsWorks::Client.new( region: "us-east-1", #Only available in us-east-1 (as of June 5th 2015)
  credentials: credentials)


 
ami_id              = 'ami-accff2b1'  # Ubuntu Server 14.04 LTS (HVM), SSD Volume Type - 
key_pair_name       = 'shadoopCluster'              # key pair name
private_key_file    = "id_rsa" 						# path to your private key
security_group_name = 'cloudera-manager'            # security group name
instance_type       = 'm3.large' 					# machine instance type (must be approriate for chosen AMI)
ssh_username        = 'ubuntu'						# default user name for ssh'ing

cluster_filter = [
				{name: "image-id", values: [ami_id]}
			];	

#instance = ec2_resources.create_instances(  
#    :image_id => 'ami-accff2b1',
#    :min_count => 1,
#    :max_count => 1,
#    :key_name => 'shadoopCluster',
#    :security_groups => ['cloudera-manager'],
#    :instance_type => 'm3.large',
#    :block_device_mappings => [
#      :device_name => '/dev/sda1',
#      :ebs => {:volume_size => 500}
#    ]
#);

SH_CLOUDERA_STACK_ID = "20bc2dd4-eca7-4616-b8ff-49d6e763c4a6"
DATA_NODES_LAYER_ID = "bd4eb3d8-55d0-4d73-bb55-7649c7a68e12"
MASTERS_LAYER_ID = "b920e3bb-9cf5-4804-abde-ed7a81b173a6" 
COUNT = 1
INSTANCE_TYPE = "t2.medium"
VOLUME_SIZE = 100
CREATE_MASTER = false

# Create Data nodes
for i in 1..COUNT
  response = ops.create_instance(  
    :stack_id => SH_CLOUDERA_STACK_ID,
    :layer_ids => [DATA_NODES_LAYER_ID], # Data Nodes
    :instance_type => INSTANCE_TYPE,    
    :ssh_key_name => 'shadoopCluster',
    availability_zone: "eu-west-1a",
    subnet_id: "subnet-16678861",
    :block_device_mappings => [
      :device_name => '/dev/sda1',      
      :ebs => {
      	:volume_size => VOLUME_SIZE,
      	:delete_on_termination => true
      }
    ]

  );
end

# Create master node

if(CREATE_MASTER)
  response = ops.create_instance(  
    :stack_id => SH_CLOUDERA_STACK_ID,
    :layer_ids => [MASTERS_LAYER_ID], # Data Nodes
    :instance_type => 'm3.xlarge',    
    :ssh_key_name => 'shadoopCluster',
    availability_zone: "eu-west-1a",
    subnet_id: "subnet-16678861",
    :block_device_mappings => [
      :device_name => '/dev/sda1',      
      :ebs => {
      	:volume_size => 500,
      	:delete_on_termination => true
      }
    ]

  );
end

response.each do |instance|
	puts instance
end



 
