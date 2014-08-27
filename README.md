# 魔豆路由器屏幕云截图服务

## How-To

SSH into your modou wireless router and run:

    $ cat /dev/fb0 > tmp.dat

And then

    $ curl -F "data=@./tmp.dat" http://screenshot.ly.md/screenshot -o screenshot.png

Then the file `screenshot.png` is what you want.
