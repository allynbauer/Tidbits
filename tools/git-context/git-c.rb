#!/usr/bin/env ruby
require 'rubygems'
require 'fastercsv'
require 'pathname'

class ContextMessage < Struct.new('ContextMessage', :branch, :git_dir, :context_message)
  def initialize(git_dir, branch, context_message)
    self.git_dir = git_dir
    self.branch = branch
    self.context_message = context_message
  end

  def to_s_formatted
    self.to_ary.join("\t")
  end

  def to_ary
    [self.git_dir, self.branch, self.context_message]
  end

  def to_csv
    self.to_ary.to_csv
  end

  def context_equals?(git_path, branch)
    self.git_dir.to_s == git_path.to_s && self.branch.to_s == branch.to_s
  end

  def self.load_messages(file_name)
    file_name = File.expand_path(file_name)
    messages = []
    return messages unless File.exists?(file_name)
    FasterCSV.foreach(file_name) do |line|
      messages << self.new(*line)
    end
    messages
  end
end

def get_current_branch_name
  `git branch | grep '*' | cut -f2 -d' '`.chop
end

def get_current_directory
  Dir.pwd
end

def get_git_dir
  git_root = nil
  dir = Pathname.new(Dir.pwd)
  dir.ascend do |path|
    git_path = path + '.git'
    git_root = path if git_path.exist?
  end
  git_root
end

branch = get_current_branch_name
git_dir = get_git_dir
message_string = ""
messages = ContextMessage.load_messages(File.join('~', '.gitcontext_global'))
  matching_message = messages.find do |message|
    message.context_equals?(git_dir, branch)
  end
  if matching_message.nil?
    puts "No context message set."
  else
    puts "Context message: #{matching_message.context_message}"
    message_string = "-m '#{matching_message.context_message}'"
  end
  args = ARGV
  args.collect! { |arg| arg.split(' ').count > 0 ? "'#{arg}'" : arg }
  args << message_string

  args = args.join(' ')
  puts `git commit #{args}`
