#!/usr/bin/env ruby
# coding: utf-8

require 'uri'
require 'net/http'

load 'alfred_feedback.rb'

query = Alfred.query

feedback = Feedback.new

def query_ip(args)
  api = "http://www.ip138.com/ips138.asp?ip=#{args}"
  response = Net::HTTP.get_response(URI(api)).body.encode('utf-8','gb2312').lines
  title = response.map{|x| $1 if x =~ /<h1>(.*)<\/h1>/}.compact.first
  title = $1 if title =~ /<font color="blue">(.*)<\/font>/
  item_line = response.map{|x| $1 if x =~ /<ul class="ul1">(.*)<\/ul>/ }.compact.first
  unless item_line.nil?
    items = item_line.split(/<li>|<\/li>/).delete_if{|x|x == ''}
    [title,items]
  else
    ['查询失败',['地址不正确或不存在。']]
  end
end

def query_no_arg
  api = "http://1111.ip138.com/ic.asp"
  response = Net::HTTP.get_response(URI(api)).body.encode('utf-8','gb2312')
  return $1 if response.lines.last.match(/<center>(.*)<\/center>/)
end

case query

when ''
  feedback.add_item({
    :title => '我的 IP 地址',
    :subtitle => query_no_arg,
    :arg => query_no_arg
  })

  puts feedback.to_xml

else
  title,items = query_ip(query)
  items.each.each do |item|
    feedback.add_item({
      :title  => title,
      :subtitle => item,
      :arg => item
    })
  end

  puts feedback.to_xml
end

