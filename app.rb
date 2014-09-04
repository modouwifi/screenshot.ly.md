require "sinatra"
require "sinatra/json"
require "tzinfo"

configure :development do
  require "dotenv"
  Dotenv.load
end

configure :production do
  require "newrelic_rpm"

  require "qiniu"

  Qiniu.establish_connection! access_key: ENV['QINIU_ACCESS_KEY'], secret_key: ENV['QINIU_SECRET_KEY']
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

  `qboxrsctl put #{ENV['QINIU_BUCKET']} screenshots/#{tempfile}.png tmp/#{tempfile}.png`

  primitive_url = "http://#{ENV['QINIU_BUCKET']}.qiniudn.com/screenshots/#{tempfile}.png"

  status 201
  json status: 'OK', url: Qiniu::Auth.authorize_download_url(primitive_url)
end
