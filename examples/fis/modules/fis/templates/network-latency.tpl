{
    "tags": {
        "Name": "NetworkLatency"
    },
    "description": "Run a Network latency fault injection on the specified instance",
    "targets": {
        "ec2-instances": {
            "resourceType": "aws:ec2:instance",
            "resourceTags": {
                "env": "prod"
            },
            "filters": [
                {
                    "path": "State.Name",
                    "values": ["running"]
                }
            ],
            "selectionMode": "ALL"
        }
    },
    "actions": {
        "NetworkLatency": {
            "actionId": "aws:ssm:send-command",
            "description": "run network latency using ssm",
            "parameters": {
                "duration": "PT2M",
                "documentArn": "arn:aws:ssm:${region}::document/AWSFIS-Run-Network-Latency",
                "documentParameters": "{\"DurationSeconds\": \"120\", \"InstallDependencies\": \"True\", \"DelayMilliseconds\": \"1000\"}"
            },
            "targets": {
                "Instances": "ec2-instances"
            }
        }
    },
    "stopConditions": [
        {
            "source": "aws:cloudwatch:alarm",
            "value": "${alarm}"
        }
    ],
    "roleArn": "${role}"
}
