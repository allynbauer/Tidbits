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

def output_status
  branch = get_current_branch_name
  git_dir = get_git_dir
  puts "# On branch #{branch}"
  puts "# Git Root in #{git_dir}"
  messages = ContextMessage.load_messages(DefaultMessageFile)
  matching_message = messages.find do |message|
    message.context_equals?(git_dir, branch)
  end
  if matching_message.nil?
    puts "No context message set."
  else
    puts "Context message: #{matching_message.context_message}"
  end
end

def output_list(file)
  branch = get_current_branch_name
  git_dir = get_git_dir

  messages = ContextMessage.load_messages(file)
  if messages.empty?
    puts "No messages found in file: #{file}"
    return
  end

  titles = ["   ", "Git Root", "Branch", "Message"]
  s2 = messages.collect { |m| m.git_dir.length }.max
  s3 = messages.collect { |m| m.branch.length }.max
  s4 = messages.collect { |m| m.context_message.length }.max

  padding = 2
  s2 = [s2, titles[1].length].max + padding
  s3 = [s3, titles[2].length].max + padding
  s4 = [s4, titles[3].length].max + padding

  print titles.shift
  titles.zip([s2, s3, s4]).each do |g|
    print g[0].ljust(g[1])
  end
  print "\n"
  messages.each do |m|
    output = m.context_equals?(git_dir, branch) ? " * " : "   "
    output << m.git_dir.ljust(s2)
    output << m.branch.ljust(s3)
    output << m.context_message.ljust(s4)
    puts output
  end

end

def output_help
  puts "Sets a messages that git c(ommit) will use as the second -m. Relevant in a 'context' defined by the git root and branch."
  puts "git context <command> <arg>"
  puts ""
  puts "git context\t\t\toutput status of current context."
  puts "git context list\t\toutput list of all statuses globally."
  puts "git context + 'message'\t\tadd 'message' as the current context's message, replacing any existing one"
  puts "git context -\t\t\tremove the current context's message, if there was one"
  puts "git context help\t\tthis menu"
end

DefaultMessageFile = File.join('~', '.gitcontext_global')

def perform_add(text, file_name)
  branch = get_current_branch_name
  git_dir = get_git_dir
  puts "# On branch #{branch}"
  puts "# Git Root in #{git_dir}"
  file_name = File.expand_path(file_name)
  messages = ContextMessage.load_messages(file_name)
  messages = messages.reject do |message|
    message.context_equals?(git_dir, branch)
  end
  new_message = ContextMessage.new(git_dir, branch, text)
  messages << new_message
  FasterCSV.open(file_name, "w") do |csv|
    messages.each do |message|
      csv << message.to_ary
    end
  end
  puts "Added context message: '#{text}'"
end

def perform_remove(file_name)
  branch = get_current_branch_name
  git_dir = get_git_dir
  puts "# On branch #{branch}"
  puts "# Git Root is #{git_dir}"
  file_name = File.expand_path(file_name)
  messages = ContextMessage.load_messages(file_name)
  messages = messages.reject do |message|
    message.context_equals?(git_dir, branch)
  end
  FasterCSV.open(file_name, "w") do |csv|
    messages.each do |message|
      csv << message.to_ary
    end
  end
  puts "Context message reset."
end

if ARGV.length == 0
  output_status
elsif ARGV.first == '-' && ARGV.length == 1 && ARGV.first.length == 1
  perform_remove(DefaultMessageFile)
elsif ARGV.first == '+' && ARGV.length == 2 && ARGV.first.length == 1
  perform_add(ARGV[1], DefaultMessageFile)
elsif ARGV.first == 'list'
  output_list(DefaultMessageFile)
else
  puts "?"
  output_help
end
