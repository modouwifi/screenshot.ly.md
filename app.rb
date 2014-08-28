require "sinatra"
require "tzinfo"

configure :development do
  require "dotenv"
  Dotenv.load
end

configure :production do
  require "newrelic_rpm"
end

post '/screenshot' do
  time = TZInfo::Timezone.get('Asia/Shanghai').now.strftime('%Y%m%d%H%M%S')

  tempfile = "#{time}-#{SecureRandom.hex}"

  filepath = File.expand_path("../tmp/#{tempfile}.dat", __FILE__)

  File.open(filepath, 'wb') do |file|
    file.write(params[:data][:tempfile].read)
  end

  `yes | ffmpeg -vcodec rawvideo -f rawvideo -pix_fmt rgb565 -s 320x240 -i tmp/#{tempfile}.dat -f image2 -vcodec png tmp/#{tempfile}.png`

  `qboxrsctl login #{ENV['QINIU_ACCESS_KEY']} #{ENV['QINIU_SECRET_KEY']}`

  `qboxrsctl put #{ENV['QINIU_BUCKET']} #{tempfile}.png tmp/#{tempfile}.png`

  send_file "tmp/#{tempfile}.png"
end
