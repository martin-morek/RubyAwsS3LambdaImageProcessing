require 'yaml'
require 'aws-sdk-s3'
require 'mini_magick'

class UploadedFile
  class << self
    def width_orientated?(image)
      image[:width].to_f / image[:height].to_f > 1
    end

    def has_expected_ratio?(image, desired_ratio)
      (image[:width].to_f / image[:height].to_f).round(3) == desired_ratio
    end

    def fix_ratio(image, max_width, max_height, desired_ratio)
      if max_width / image[:width] > max_height / image[:height]
        n_height = image[:width] / desired_ratio
        image.crop "#{image[:width]}x#{n_height}+0+#{(image[:height] - n_height) / 2}"
      else
        n_width = image[:height] * desired_ratio
        image.crop "#{n_width}x#{image[:height]}+#{(image[:width] - n_width) / 2}+0"
      end
    end

    def from_s3(bucket_name, object_name)
      s3 = Aws::S3::Resource.new()
      object = s3.bucket(bucket_name).object(object_name)

      tmp_file_name = "/tmp/#{object_name}"
      object.get(response_target: tmp_file_name)

      UploadedFile.new(tmp_file_name)
    end
  end

  def initialize(tmp_file)
    @tmp_file = tmp_file

    config = YAML::load_file('config.yml')
    @destination_bucket = config["destination-bucket"]
    @max_width = config["image"]["max-width"].to_f
    @max_height = config["image"]["max-height"].to_f
    @max_size = config["image"]["max-size"]
    @desired_ratio = config["image"]["desired-ratio"]
  end

  def resize
    image = MiniMagick::Image.open(@tmp_file)

    if self.class.width_orientated?(image)
      if !self.class.has_expected_ratio?(image, @desired_ratio)
        image.resize(@max_width.to_s) if image[:width] > @max_width
        self.class.fix_ratio(image, @max_width, @max_height, @desired_ratio)
      end

      # Adjusting image quality if size of image is larger the maximial allowed size
      i = 10
      while image[:size] > @max_size
        image.quality (90 - i)
        i += 10
      end
      puts 'Processing is done!'

      image.format 'jpg'
      @resized_tmp_file = "/tmp/resized.jpg"
      image.write @resized_tmp_file
    else
      puts 'Wrong image format!!!'
    end
  end

  def upload_file(target_object)
    s3 = Aws::S3::Resource.new()
    s3.bucket(@destination_bucket).object(target_object).upload_file(@resized_tmp_file, acl: 'public-read')
  end
end
