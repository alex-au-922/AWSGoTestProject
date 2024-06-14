project_prefix = "aws-go"

env = "dev"

vpc_config = {
  cidr = "10.0.0.0/16"
  network_acls_ports = {
    ingress = [
      "22", "80", "443"
    ],
    egress = [
      "80", "443"
    ]
  }
  subnets = {
    public = [
      {
        az   = "us-east-1a"
        cidr = "10.0.0.0/20"
      },
      {
        az   = "us-east-1b"
        cidr = "10.0.16.0/20"
      },
      {
        az   = "us-east-1c"
        cidr = "10.0.32.0/20"
      }
    ],
    private = [
      {
        az   = "us-east-1a"
        cidr = "10.0.48.0/20"
      },
      {
        az   = "us-east-1b"
        cidr = "10.0.64.0/20"
      },
      {
        az   = "us-east-1c"
        cidr = "10.0.80.0/20"
      }
    ]
  }
}
