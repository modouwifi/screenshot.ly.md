require "sinatra"

post '/screenshot' do
  File.open(File.expand_path('../tmp/tmp.dat', __FILE__), 'wb') do |file|
    file.write(params[:data][:tempfile].read)
  end

  `yes | ffmpeg -vcodec rawvideo -f rawvideo -pix_fmt rgb565 -s 320x240 -i tmp/tmp.dat -f image2 -vcodec png tmp/screenshot.png`

  send_file 'tmp/screenshot.png'
end
