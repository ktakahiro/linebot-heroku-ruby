require 'sinatra'
require 'line/bot'
require 'json'

def client
  @client ||= Line::Bot::Client.new do |config|
    config.channel_secret = 'b5b2790170b5d8650c57ffb65b2a51e3'
    config.channel_token = 'PAtJGMFyV7L2PNR4WZmRVjfXnTSZIQnY24c5bIEL0Y6qRqe9eYi8ZG0rFwe7LUZJyN4JOuhVxpgLvcb/aN49ztrlFlxwcjZUWR2BHTbxblwHDInGfAKgVGNJcc5is1Ixwp+tOne1DkRFChUIS0P/8gdB04t89/1O/w1cDnyilFU='
  end
end

post '/' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do
      'Bad Request'
    end
  end

  events = client.parse_events_from(body)
  events.each do |event|
    if event['type'] == 'beacon'
      profile = client.get_profile(event['source']['userId'])
      displayName = JSON.parse(profile.body)['displayName']

      message = [
        {
          type: 'sticker',
          packageId: 1,
          stickerId: 17
        },
        {
          type: 'text',
          text: 'ようこそ奥多摩へ！' + displayName + 'さん'
        },
        {
          type: 'text',
          text: 'https://www.youtube.com/watch?v=c8qvbu11fps'
        }
      ]
      client.reply_message(event['replyToken'], message)
    else
      message = [
        {
          type: 'text',
          text: 'さようなら！'
        },
        {
          type: 'sticker',
          packageId: 1,
          stickerId: 4
        }
      ]
      client.reply_message(event['replyToken'], message)
    end
  end
  'OK'
end
