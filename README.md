### Ruby AWS S3 Lambda Image Processing

## Description
Simple ruby script running as AWS lambda. Serves as image processing service. After upload image into `upload bucket`  script process image and upload result into `destination bucket`.

It verifies if :
- image is width oriented, if not stop processing
- image has the desired ratio, if not fix ratio to desired
- image's size is not larger the maximal defined size, if it is lower quality to match the maximal size
Processing images uploaded into S3

Based on https://github.com/maartenvanvliet/serverless_ruby_image_resizer

## Deployment

### Set ruby version
```rbenv install 2.5.0```
```rbenv local 2.5.0```

### Vendorize the dependencies
```bundle install --path vendor/bundle```

### Deploy
```sls deploy```

### Revert deploy
```sls remove```
