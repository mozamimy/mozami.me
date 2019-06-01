require 'aws-sdk-ec2'
require 'time'

module WorkbenchHelper
  SUBNETS = {
    az_1a_public: 'subnet-342e687d',
    az_1c_public: 'subnet-47b80a1c',
    az_1d_public: 'subnet-ba84a292',
  }
  @ec2 = Aws::EC2::Client.new
  @logger = Logger.new($stdout)

  def launch
    request_spot_fleet_resp = @ec2.request_spot_fleet(
      spot_fleet_request_config: {
        allocation_strategy: 'lowestPrice',
        fulfilled_capacity: 1.0,
        iam_fleet_role: 'arn:aws:iam::123456789012:role/aws-ec2-spot-fleet-tagging-role',
        launch_specifications: [
          launch_specification('m5d.xlarge', SUBNETS.fetch(:az_1a_public)),
          launch_specification('m5d.xlarge', SUBNETS.fetch(:az_1c_public)),
          launch_specification('m5d.xlarge', SUBNETS.fetch(:az_1d_public)),
          launch_specification('m5a.xlarge', SUBNETS.fetch(:az_1a_public)),
          launch_specification('m5a.xlarge', SUBNETS.fetch(:az_1d_public)),
          launch_specification('m5.xlarge', SUBNETS.fetch(:az_1a_public)),
          launch_specification('m5.xlarge', SUBNETS.fetch(:az_1c_public)),
          launch_specification('m5.xlarge', SUBNETS.fetch(:az_1d_public)),
          launch_specification('t3.xlarge', SUBNETS.fetch(:az_1a_public)),
          launch_specification('t3.xlarge', SUBNETS.fetch(:az_1c_public)),
          launch_specification('t3.xlarge', SUBNETS.fetch(:az_1d_public)),
          launch_specification('z1d.large', SUBNETS.fetch(:az_1a_public)),
          launch_specification('z1d.large', SUBNETS.fetch(:az_1c_public)),
          launch_specification('z1d.large', SUBNETS.fetch(:az_1d_public)),
          launch_specification('c5.xlarge', SUBNETS.fetch(:az_1a_public)),
          launch_specification('c5.xlarge', SUBNETS.fetch(:az_1c_public)),
          launch_specification('c5.xlarge', SUBNETS.fetch(:az_1d_public)),
          launch_specification('c5d.xlarge', SUBNETS.fetch(:az_1a_public)),
          launch_specification('c5d.xlarge', SUBNETS.fetch(:az_1c_public)),
          launch_specification('c5d.xlarge', SUBNETS.fetch(:az_1d_public)),
          launch_specification('c5n.xlarge', SUBNETS.fetch(:az_1a_public)),
          launch_specification('c5n.xlarge', SUBNETS.fetch(:az_1d_public)),
          launch_specification('r5.xlarge', SUBNETS.fetch(:az_1a_public)),
          launch_specification('r5.xlarge', SUBNETS.fetch(:az_1c_public)),
          launch_specification('r5.xlarge', SUBNETS.fetch(:az_1d_public)),
          launch_specification('r5a.xlarge', SUBNETS.fetch(:az_1a_public)),
          launch_specification('r5a.xlarge', SUBNETS.fetch(:az_1d_public)),
          launch_specification('r5d.xlarge', SUBNETS.fetch(:az_1a_public)),
          launch_specification('r5d.xlarge', SUBNETS.fetch(:az_1c_public)),
          launch_specification('r5d.xlarge', SUBNETS.fetch(:az_1d_public)),
        ],
        target_capacity: 1.0,
        type: 'maintain',
        instance_interruption_behavior: 'stop',
      },
    )

    File.write('tmp/workbench-sfr', request_spot_fleet_resp.spot_fleet_request_id)
    @logger.info("Created a spot fleet request '#{request_spot_fleet_resp.spot_fleet_request_id}'.")
  end

  def terminate
    create_image_resp = @ec2.create_image(
      instance_id: active_instance_id,
      name: "arch-usagoya-workbench-#{Time.now.strftime('%Y%m%d%H%M')}",
    )
    @ec2.wait_until(
      :image_available,
      {
        image_ids: [create_image_resp.image_id],
      },
      {
        before_wait: -> (_, _) { @logger.info("Waiting to finish create AMI '#{create_image_resp.image_id}'...") },
      },
    )
    @ec2.create_tags(
      resources: [create_image_resp.image_id],
      tags: [
        {
          key: 'Role',
          value: 'workbench',
        },
      ],
    )
    @logger.info("Create a tag for AMI '#{create_image_resp.image_id}'.")

    @ec2.cancel_spot_fleet_requests(
      spot_fleet_request_ids: [active_spot_fleet_request_id],
      terminate_instances: true,
    )
    @logger.info("Spot fleet request '#{active_spot_fleet_request_id}' has been canceled.")
  end

  def latest_image_id
    return @latest_image_id if @latest_image_id

    images_by_role = @ec2.describe_images(
      filters: [
        {
          name: 'tag:Role',
          values: [
            'base',
            'workbench',
          ],
        },
        {
          name: 'state',
          values: ['available'],
        },
      ],
      owners: ['self'],
    ).images.group_by { |a|
       a.tags.find { |t| t.key == 'Role' }.value
    }

    @latest_image_id = unless images_by_role['workbench'].nil?
      images_by_role['workbench'].sort_by { |i| Time.parse(i.creation_date) }.reverse[0].image_id
    else
      images_by_role['base'].sort_by { |i| Time.parse(i.creation_date) }.reverse[0].image_id
    end
  end

  def launch_specification(instance_type, subnet_id)
    {
      image_id: latest_image_id,
      instance_type: instance_type,
      key_name: 'id_rsa.private',
      weighted_capacity: 1.0,
      block_device_mappings: [
        device_name: '/dev/sda1',
        ebs: {
          delete_on_termination: true,
          volume_type: 'gp2',
          volume_size: 32,
        },
      ],
      iam_instance_profile: {
        arn: 'arn:aws:iam::123456789012:instance-profile/EC2Workbench',
      },
      network_interfaces: [
        {
          device_index: 0,
          subnet_id: subnet_id,
          delete_on_termination: true,
          associate_public_ip_address: true,
          groups: [
            'sg-b04bf3d7', # default
            'sg-0f3eea55d27a96cf1', # workbench
          ],
        },
      ],
      tag_specifications: [
        {
          resource_type: 'instance',
          tags: [
            {
              key: 'Name',
              value: 'workbench-001',
            },
            {
              key: 'Role',
              value: 'workbench',
            },
          ],
        },
      ],
    }
  end

  def active_spot_fleet_request_id
    @active_spot_fleet_request_id ||= File.read('tmp/workbench-sfr')
  end

  def active_instance_id
    @active_instance_id ||= @ec2.describe_spot_fleet_instances(
      spot_fleet_request_id: active_spot_fleet_request_id,
    ).flat_map(&:active_instances)[0].instance_id
  end

  module_function :launch, :terminate, :latest_image_id, :launch_specification, :active_spot_fleet_request_id, :active_instance_id
end

namespace :workbench do
  desc '#'
  task :launch do
    WorkbenchHelper.launch
  end

  desc '#'
  task :terminate do
    WorkbenchHelper.terminate
  end
end
