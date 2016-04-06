I've written previously [about my misgivings with static sites on
AWS](/fragments/aws-static-hosting), and while some of those points are still
valid, there's no question that the maturity of the AWS product and the
incredible surface area that its products cover make it an excellent place to
host your content.

Until now I would have recommended a CloudFlare/other host hybrid so that you
could get free HTTPS support for a custom domain with automatic certificate
renewal, but the advent of AWS Certificate Manager (ACM) has changed that. By composing a few 

Keep in mind that although this article walks through setting up a static site
step-by-step, you can [look at the full source code][singularity] of a sample
project at any time.

## Building (#building)

I'll leave getting a static site built as an exercise to the reader. There are
_hundreds_ of static site frameworks out there and plenty of good choices.

In my own experience, I've found that assembling my own static site generation
script takes about the same amount of time as getting on-boarded with any of
the major site generation frameworks. This isn't as much a critique of them as
it is a nod to the inevitability of any general-purpose project to expand in
features until it takes a lot of documentation and false starts to get up to
speed. Writing your own script is a greater maintenance burden over the long
run, but this is offset by the greater flexibility that it gets you.

The [singularity][singularity] example site uses a Go build script and a small
standard library-based web server with fswatch (which watches for file changes)
to get a nice development workflow that's fast and easy.

## AWS Service Setup (#aws)

We'll be using the [AWS CLI][aws-cli]. If you're on Mac or Linux, you should be
able to install it as simply as:

```
$ pip install --user awscli
$ aws configure
```

Running `aws configure` will ask for an AWS access key and secret key which you
can get by logging into the [AWS Console][aws-console].

### S3 (#s3)

Amazon's storage system, S3, will be used to store the contents of our static
site. First create a bucket named according to the custom domain that you'll be
using for your site:

```
$ export S3_BUCKET=singularity.brandur.org
$ aws s3 mb s3://$S3_BUCKET
```

Next up, let's create a `Makefile` with a `deploy` target which will upload the
results of your build above:

``` make
# Makefile

deploy:
ifdef AWS_ACCESS_KEY_ID
	aws --version

	# Force text/html for HTML because we're not using an extension.
	aws s3 sync ./public/ s3://$(S3_BUCKET)/ \
        --acl public-read --delete --content-type text/html --exclude 'assets*'

	# Then move on to assets and allow S3 to detect content type.
	aws s3 sync ./public/assets/ s3://$(S3_BUCKET)/assets/ \
        --acl public-read --delete --follow-symlinks
else
	# No AWS access key. Skipping deploy.
endif
```

Normally assets uploaded to S3 are assigned a content type that's detected from
their file extension. Because I want to give my HTML documents "pretty URIs"
(i.e. extensionless like `/hello` instead of `/hello.html`) we play a trick
with content type that necessitates an upload in two steps:

* The first uploads your HTML assets and explicitly sets their content type to
  `text/html`.
* The second uploads all other assets. Here we allows the content type to be
  detected based on each file's extension.

Now try running the task:

``` sh
$ export $AWS_ACCESS_KEY_ID=access-key-from-aws-configure-above
$ export $AWS_SECRET_ACCESS_KEY=secret-key-from-aws-configure-above
$ make deploy
```

You can use the AWS credentials that you've configured AWS CLI with for now,
but we'll want to avoid the risk of exposing them as much as possible. We'll
address that problem momentarily.

### AWS Certificate Manager (#acm)

ACM is Amazon's certificate manager service. Using it we'll provision a
certificate for your custom domain which will then be attached to CloudFront.
After the certificate is issued, Amazon will automatically take care of its
renewal to keep your site accessible with perfect autonomy. You can even have
it issue you a wildcard certificate, and all for free!

Go to the [ACM control panel][acm-console] and choose **Request a
Certificate**. Follow the prompts through and verify your domain when they send
you an e-mail.

### CloudFront (#cloudfront)

CloudFront is Amazon's CDN service. We'll be using it to distribute our content
to Amazon edge locations across the world so that it's fast anywhere, and to
terminate TLS connections to our custom domain name (with a little help from
ACM).

Go to the [CloudFront control panel][cloudfront-console] and create a new
distribution. If it asks you to choose between **Web** and **RTMP**, choose
**Web**. Most options can be left default, but you should make a few changes:

* Under **Origin Domain Name** select your S3 bucket.
* Under **Viewer Protocol Policy** choose **Redirect HTTP to HTTPS"** As the
  name suggests, this will allow HTTP connections initially, but then force
  users onto HTTPS.
* Under **Alternate Domain Names (CNAMEs)** add the custom domain you'd like to
  host.
* Under **SSL Certificate** choose **Custom SSL Certificate** and then in the
  dropdown find the certificate that was issued by ACM above.

After it's created, you'll get a domain name for your new CloudFront
distribution with a name like `da48dchlilyg8.cloudfront.net`. It may take a few
minutes for the distribution to become available. You'll need this to set up
your DNS.

### Route53 (or Any Other DNS) (#dns)

Use Route53 or any other DNS provide of your choice to CNAME your custom domain
to the domain name of your new CloudFront distribution (once again, those look
like `da48dchlilyg8.cloudfront.net`). 

### IAM (#iam)

Now that the basic static site is working, it's time to lock down the
deployment flow so that you're not using your root IAM credentials to deploy.

#### Create User (#create-iam-user)

Go to the [IAM web console][iam-console], and create a new user. Put in a new
name for the user and leave the "Generate an access key for each user" option
checked. On the next page, copy out the new AWS access key and secret key;
we'll need them for the next section.

#### Create Policy (#create-iam-policy)

Now create a new policy (also from the IAM web console). When prompted, choose
the **Create Your Own Policy** option. Put in a name that you can remember and
then the following JSON blob as the policy document. You will need to change
the "Resource" field to contain the name of the S3 bucket that you created
above.

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

After the policy's been created, look at your policies index and select it,
then under the submenu of the **Policy Actions** button, select **Attach**.
Find the user that you created in the previous step and assign the policy to
them.

The policy and user combination that you've just created scopes access to just
the S3 bucket containing your static site. If the worst should happen and this
user's credentials are leaked, an attacker may be able to take down this one
static site, but won't be able to probe any further into your Amazon account.

## Automating Contribution (#automating)

### Travis (#travis)

By putting file sychronization to our S3 bucket into a Make task, we've made
deployments pretty easy, but we can do even better. By running that same task
in a Travis build for the project, we can make sure that anytime new code gets
merged into master, our static site will update accordingly with complete
autonomy.

We start by giving installing AWS CLI into the build's container and running
our Make task as the build's main target. That's accomplished by putting this
into `.travis.yml`:

``` yaml
# travis.yml

# magic word to use faster/newer container-based architecture
sudo: false

install:
  - pip install --user awscli

script:
  - make deploy
 ```

That gets us pretty close, but the build will need valid AWS credentials in
order to properly deploy. We don't want to compromise our credentials by
putting them into our public repository's `.travis.yml` as plaintext, but
luckily Travis provides a facility for [encrypted environment
variables][encrypted-variables]. Get the Travis CLI and use it to secure the
IAM credentials for deployment that you generated above:

```
$ gem install travis
$ travis encrypt AWS_ACCESS_KEY=access-key-from-iam-step-above
$ travis encrypt AWS_SECRET_KEY=secret-key-from-iam-step-above
```

After encrypting your AWS keys, add those values to your `.travis.yml`. under
the `env` section (make sure to use the special `secure:` prefix) so that our
build can pick them up:

``` yaml
# travis.yml

env:
  global:
    - S3_BUCKET=singularity.brandur.org

    # $AWS_ACCESS_KEY_ID (use the encrypted result from the command above)
    - secure: HR577...

    # $AWS_SECRET_ACCESS_KEY (use the encrypted result from the command above)
    - secure: svmpm...
```

Note that the plaintext values of these secure keys are only available to
builds that are happening on the master branch of your repository. If someone
forks your repository and builds their own branch, these values will not be
available and upload to S3 will occur.

[See a complete Travis configuration here][travis-yml].

### GitHub (#github)

Once you accept a pull request into master, a build on those changes will
happen and the results will be available live.

## Summary (#summary)

[acm-console]: https://console.aws.amazon.com/acm/home
[aws-cli]: https://aws.amazon.com/cli/
[aws-console]: https://aws.amazon.com/console/
[cloudfront-console]: https://console.aws.amazon.com/cloudfront/home
[encrypted-variables]: https://docs.travis-ci.com/user/environment-variables/#Encrypted-Variables
[iam-console]: https://console.aws.amazon.com/iam/home
[singularity]: https://github.com/brandur/singularity
[travis-yml]: https://github.com/brandur/singularity/blob/master/.travis.yml
