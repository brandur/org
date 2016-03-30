

## Building

## AWS Services

### S3

### IAM

#### Create User

#### Create Policy

``` json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::singularity.brandur.org"
        },
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::singularity.brandur.org/*"
        }
    ]
}
```

### DNS

### CloudFront

CloudFront is Amazon's CDN service. We'll be using it along with AWS
Certificate Manager (ACM) to distribute our content to Amazon edge locations
across the world so that it's fast anywhere, and to terminate TLS connections
to our custom domain name.

Go to the [CloudFront control panel][cloudfront] and create a new distribution.
If it asks you to choose between "Web" and "RTMP", choose "Web". Most options
can be left default, but you should make a few changes:

* Under "Origin Domain Name" select your S3 bucket.
* Under "Viewer Protocol Policy" choose "Redirect HTTP to HTTPS". As the name
  suggests, this will allow HTTP connections initially, but then force users
  onto HTTPS.
* Under "Alternate Domain Names (CNAMEs)" add the custom domain you'd like to
  host.

### AWS Certificate Manager

## Automating Contribution

### GitHub

### Travis

```
travis encrypt AWS_ACCESS_KEY=access-key-from-iam-step-above
travis encrypt AWS_SECRET_KEY=secret-key-from-iam-step-above
```

``` yaml
env:
  global:
    - S3_BUCKET=singularity.brandur.org

    # $AWS_ACCESS_KEY_ID (use the encrypted result from the command above)
    - secure: HR577...

    # $AWS_SECRET_ACCESS_KEY (use the encrypted result from the command above)
    - secure: svmpm...
```
