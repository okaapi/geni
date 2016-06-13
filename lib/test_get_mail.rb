
=begin
require 'net/pop'
require 'mail'

pop = Net::POP3.new "pop.gmail.com"
pop.enable_ssl
pop.start '', ''
pop.each_mail do |message|
  p message
  p message.delete
end 
pop.finish
=end

require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)

Mail.defaults do
  retriever_method :pop3, :address    => "pop.gmail.com",
                          :port       => 995,
                          :user_name  => '',
                          :password   => '',
                          :enable_ssl => true
end

marray = Mail.all
marray.each do |message|
  p message.from[0]
  puts "++++++++++++++++++++++++++++++++++++++++"
  p message.date
  puts "++++++++++++++++++++++++++++++++++++++++"
  p message.subject  
  puts "++++++++++++++++++++++++++++++++++++++++"
  p message.text_part.body.decoded
  puts "++++++++++++++++++++++++++++++++++++++++"
  p message.cc  
  puts "++++++++++++++++++++++++++++++++++++++++"
  p message.return_path
  puts "++++++++++++++++++++++++++++++++++++++++"
  p message.to  
  puts "++++++++++++++++++++++++++++++++++++++++"
  p message.message_id  
end
