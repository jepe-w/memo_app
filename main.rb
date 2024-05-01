# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'cgi'

FILE_PATH = 'public/memos.json'
File.new('public/memos.json', 'w') if !File.exist?(FILE_PATH)

def read_memos
  File.open(FILE_PATH) { |item| JSON.parse(item.read) } unless File.zero?(FILE_PATH)
end

def write_memos(memos)
  File.open(FILE_PATH, 'w') { |item| JSON.dump(memos, item) }
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  @memos = read_memos
  erb :index
end

get '/memos/new' do
  erb :new_memo
end

get '/memos/:id' do
  memos = read_memos
  @title = memos[params[:id]]['title']
  @content = memos[params[:id]]['content']
  erb :memo
end

post '/memos' do
  title = params[:title]
  content = params[:content]

  memos = read_memos
  if memos.nil? || memos.empty?
    memos = {}
    id = '1'
  else
    id = (memos.keys.map(&:to_i).max + 1).to_s
  end
  memos[id] = { 'title' => title, 'content' => content }
  write_memos(memos)

  redirect '/memos'
end

get '/memos/:id/edit' do
  memos = read_memos
  @title = memos[params[:id]]['title']
  @content = memos[params[:id]]['content']
  erb :edit
end

patch '/memos/:id' do
  title = params[:title]
  content = params[:content]

  memos = read_memos
  memos[params[:id]] = { 'title' => title, 'content' => content }
  write_memos(memos)

  redirect "/memos/#{params[:id]}"
end

delete '/memos/:id' do
  memos = read_memos
  memos.delete(params[:id])
  write_memos(memos)

  redirect '/memos'
end
