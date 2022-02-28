# [2.0.0](https://github.com/andrewinci/kafka2sqs/compare/v1.10.1...v2.0.0) (2022-02-28)


### Features

* Add sqs queues ([81f427c](https://github.com/andrewinci/kafka2sqs/commit/81f427c9d205ee0d6ace47c55d0b82fb6f12ec84))
* Add VPC configuration for the lambda ([706e4cf](https://github.com/andrewinci/kafka2sqs/commit/706e4cffd259d29f7bd9e664db8da776c873b182))
* Forward parsed records to SQS ([816c427](https://github.com/andrewinci/kafka2sqs/commit/816c427165460a5fccc3f04cfb02b4175fcdbb16))


### BREAKING CHANGES

* Move Kafka VPC config into a single variabe

## [1.10.1](https://github.com/andrewinci/kafka2sqs/compare/v1.10.0...v1.10.1) (2022-02-27)


### Bug Fixes

* Return record after deserialization ([c5b68c4](https://github.com/andrewinci/kafka2sqs/commit/c5b68c462c9f5e1d192a4c49c908aa8956019264))

# [1.10.0](https://github.com/andrewinci/kafka2sqs/compare/v1.9.0...v1.10.0) (2022-02-27)


### Features

* Refactor lambda code ([80dfe6c](https://github.com/andrewinci/kafka2sqs/commit/80dfe6c611a055cf9f0a51aea531f2e1ff763418))

# [1.9.0](https://github.com/andrewinci/kafka2sqs/compare/v1.8.1...v1.9.0) (2022-02-27)


### Features

* Generate docs from make ([a18b8f6](https://github.com/andrewinci/kafka2sqs/commit/a18b8f6c863bad4723c908528b4a7576f2ac8e22))

## [1.8.1](https://github.com/andrewinci/kafka2sqs/compare/v1.8.0...v1.8.1) (2022-02-26)


### Bug Fixes

* invalid auth mapping ([bb5e171](https://github.com/andrewinci/kafka2sqs/commit/bb5e1711ce016caaa87e39ed40d9d618853bbd81))

# [1.8.0](https://github.com/andrewinci/kafka2sqs/compare/v1.7.1...v1.8.0) (2022-02-26)


### Bug Fixes

* lint ([e1dd7fc](https://github.com/andrewinci/kafka2sqs/commit/e1dd7fcb000c92d2fc2e40258cbe9b7d5968210f))


### Features

* Add sasl submodule ([d4a9de6](https://github.com/andrewinci/kafka2sqs/commit/d4a9de65861dba0e7fdcf5e8a72756552f8169c6))

## [1.7.1](https://github.com/andrewinci/kafka2sqs/compare/v1.7.0...v1.7.1) (2022-02-26)


### Bug Fixes

* mTLS typos ([e937ecc](https://github.com/andrewinci/kafka2sqs/commit/e937ecc55d1dba7315361d1a1f882ec6a3acf692))

# [1.7.0](https://github.com/andrewinci/kafka2sqs/compare/v1.6.0...v1.7.0) (2022-02-26)


### Features

* Add tls_secrets module ([d123a15](https://github.com/andrewinci/kafka2sqs/commit/d123a15302060e109c7a2f4483d1796c93a591d3))

# [1.6.0](https://github.com/andrewinci/kafka2sqs/compare/v1.5.0...v1.6.0) (2022-02-26)


### Features

* Inject schema registry credentials ([be86edd](https://github.com/andrewinci/kafka2sqs/commit/be86edd016713184452c503dcb403ecc59104426))
* Support avro deserialization from the lambda ([8e1d90e](https://github.com/andrewinci/kafka2sqs/commit/8e1d90eb823c9c02dd5736c021455a4b0372e14e))

# [1.5.0](https://github.com/andrewinci/kafka2sqs/compare/v1.4.0...v1.5.0) (2022-02-26)


### Features

* Support multiple topic serialization config ([9a589f6](https://github.com/andrewinci/kafka2sqs/commit/9a589f6d438da4b1e991e5b454ca2ee26be570fb))

# [1.4.0](https://github.com/andrewinci/kafka2sqs/compare/v1.3.0...v1.4.0) (2022-02-26)


### Features

* Deserialise string key/value ([014899c](https://github.com/andrewinci/kafka2sqs/commit/014899c13a934f8d3e2902dbf959fe5b1c932d09))

# [1.3.0](https://github.com/andrewinci/kafka2sqs/compare/v1.2.0...v1.3.0) (2022-02-26)


### Features

* Prevent user to not pass any credentials ([75e5eb4](https://github.com/andrewinci/kafka2sqs/commit/75e5eb450aa3d1e51624540b0517e6b303629a0b))

# [1.2.0](https://github.com/andrewinci/kafka2sqs/compare/v1.1.0...v1.2.0) (2022-02-26)


### Bug Fixes

* Re-deploy the lambda if the code changed ([9b485cb](https://github.com/andrewinci/kafka2sqs/commit/9b485cbf55e81a2f486d1d5f26098c767dc64278))


### Features

* Add support for basic auth ([a90f174](https://github.com/andrewinci/kafka2sqs/commit/a90f174ca276a6f283c9db6e0d5fd1429ec54967))

# [1.1.0](https://github.com/andrewinci/kafka2sqs/compare/v1.0.1...v1.1.0) (2022-02-26)


### Features

* Allow multiple sg and make mtls vars optional ([bf546a5](https://github.com/andrewinci/kafka2sqs/commit/bf546a5729ae23ad33ec8e6ad2a62addf79c72f8))

## [1.0.1](https://github.com/andrewinci/kafka2sqs/compare/v1.0.0...v1.0.1) (2022-02-26)


### Bug Fixes

* Lambda zip path ([90c5b4f](https://github.com/andrewinci/kafka2sqs/commit/90c5b4f4f063097aabb50808563629ade3f633ad))

# 1.0.0 (2022-02-26)


### Features

* First release ([2a1a694](https://github.com/andrewinci/kafka2sqs/commit/2a1a69447c4bad10391313121bf3cf58c0c1aa34))
