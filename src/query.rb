#!/usr/bin/env ruby
# coding: utf-8

require 'uri'
require 'net/http'

args = "{query}"

def output(title,response)
  ops = []
  i = 0
  response.each do |res|

    op = <<-EOF.gsub(/^\s+\|/,'')
      |        <item uid="#{i}" arg="#{title}&#10;#{res}" valid="YES" type="default">
      |            <title>#{title}</title>
      |            <subtitle>#{res}</subtitle>
      |            <icon>icon.png</icon>
      |        </item>

      EOF
    ops << op
    i += 1
  end
  op_header = <<-EOF.gsub(/^\s+\|/,'')
      |<?xml version="1.0"?>
      |    <items>
      EOF

  op_tail = <<-EOF.gsub(/^\s+\|/,'')
      |    </items>
      EOF

  op_header + ops.join + op_tail
end

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
  return [$1] if response.lines.last.match(/<center>(.*)<\/center>/)
end

if args == ''
  puts output('我的 IP',query_no_arg)
else
  puts output(*query_ip(args))
end
