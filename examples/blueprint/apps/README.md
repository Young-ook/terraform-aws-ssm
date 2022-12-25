[[English](README.md)] [[한국어](README.ko.md)]

# Applications
## EC2 Auto Scaling Warm Pools
A warm pool is a pool of pre-initialized EC2 instances that sits alongside the Auto Scaling group. Whenever your application needs to scale out, the Auto Scaling group can draw on the warm pool to meet its new desired capacity. A warm pool gives you the ability to decrease latency for your applications that have exceptionally long boot times, for example, because instances need to write massive amounts of data to disk. With warm pools, you no longer have to over-provision your Auto Scaling groups to manage latency in order to improve application performance. For more information and example configurations, see [Warm pools for Amazon EC2 Auto Scaling](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-warm-pools.html) in the Amazon EC2 Auto Scaling User Guide.

### Warm pool instance lifecycle
Instances in the warm pool maintain their own independent lifecycle to help you create the appropriate lifecycle actions for each transition. An Amazon EC2 instance transitions through different states from the moment it launches through to its termination. You can create lifecycle hooks to act on these event states, when an instance has transitioned from one state to another one.

The following diagram shows the transition between each state:

![aws-asg-wp-lifecycle](../../../images/aws-asg-wp-lifecycle.png)

### Verify
After terraform apply, you will see an instance in the warm pools. That instance will be launched to run the user-data script for application initialization when it is registered with the warm-pool. In this example, the user-data script waits for a while to simulate a long working time.

![aws-asg-wp-init-instance](../../../images/aws-asg-wp-init-instance.png)

After initialization, the instance state changes to 'Stopped' for waiting.

![aws-asg-wp-stopped](../../../images/aws-asg-wp-stopped.png)

To check the elpased time to initial configuration of the instance, run this script:
```
bash elapsedtime.sh
```
The output of this command shows the duration of the instance launch.
```
Launching a new EC2 instance into warm pool: i-0180961b460339ed3 Duration: 215s
```

### Launch a new instance from warm pool
Modify the *desired_capacity* value of *warmpools* in *node_groups* in [main.tf](https://github.com/Young-ook/terraform-aws-ssm/tree/main/examples/blueprint/main.tf) file to 1 to scale out the current autoscaling group. After terraform configuration file update, run again terraform apply.
```
terraform apply
```
The output of the change plan will be displayed. Check it, and enter *yes* to confirm. After a few minutes, run the script below to see the history of Autoscaling group activity and the elapsed time of each operation.
```
bash elapsedtime.sh
```
The output of this command shows the duration of the instance launch.
```
Launching a new EC2 instance from warm pool: i-0180961b460339ed3 Duration: 19s
Launching a new EC2 instance into warm pool: i-0180961b460339ed3 Duration: 215s
```

![aws-asg-activity-history](../../../images/aws-asg-activity-history.png)

### Connect
Move to the EC2 service page on the AWS Management Conosol and select Instances button on the left side menu. Find an instance that you launched. Select the instance and click 'Connect' button on top of the window. After then you will see three tabs EC2 Instance Connect, Session Manager, SSH client. Select Session Manager tab and follow the instruction on the screen.
