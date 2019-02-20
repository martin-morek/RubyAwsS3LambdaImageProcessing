require 'uploaded_file'

class ImageHandler
  def self.process(event:, context:)
    event = event["Records"].first
    bucket_name = event["s3"]["bucket"]["name"]
    object_name = event["s3"]["object"]["key"]

    puts "Processing image: #{object_name}"

    file = UploadedFile.from_s3(bucket_name, object_name)
    file.resize
    file.upload_file(event["s3"]["object"]["key"])
  end
end
