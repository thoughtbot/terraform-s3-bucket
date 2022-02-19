# Terraform S3 Bucket

This Terraform module will create a secure S3 bucket suitable for application
blob storage. Each bucket is encrypted with a unique KMS key. Bucket and key
policies are set to allow access only by the configured principals. Public
access blocks are enabled to prevent anything in the bucket from accidentally
becoming public.

Example:

``` terraform
module "bucket" {
  source = "github.com/thoughtbot/aws-s3-bucket?ref=v0.1.0"

  name            = "my-unique-bucket-name"
  trust_principal = aws_iam_role.myservice.arn
}
```

The outputs include `policy_json`, which you can attach to an IAM policy or role
to permit reading and writing the bucket.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Development

Please see [CONTRIBUTING.md](./CONTRIBUTING.md).

## License

This project is Copyright © 2022 Joe Ferris and thoughtbot. It is free
software, and may be redistributed under the terms specified in the [LICENSE]
file.

[LICENSE]: ./LICENSE

About thoughtbot
----------------

![thoughtbot](https://thoughtbot.com/brand_assets/93:44.svg)

This project is maintained and funded by thoughtbot, inc. The names and logos
for thoughtbot are trademarks of thoughtbot, inc.

We love open source software! See [our other projects][community] or [hire
us][hire] to design, develop, and grow your product.

[community]: https://thoughtbot.com/community?utm_source=github
[hire]: https://thoughtbot.com/hire-us?utm_source=github
