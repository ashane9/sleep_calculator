FILE_IGNORE_LIST = %w(. .. .svn)
@sleep_total = 0
def build_file_list_from_folder(folder_name, extension)
  list = []
  Dir.entries(folder_name).each_entry do |file_name|
    unless FILE_IGNORE_LIST.include?(file_name)
      file_name = "#{folder_name}/#{file_name}"
      if File.directory?(file_name)
        list << build_file_list_from_folder(file_name, extension)
      elsif file_name.downcase.include?(extension)
        list << file_name
      end
    end
  end
  list.flatten
end

def parse_through_files
  files = build_file_list_from_folder(Dir.getwd,".rb")

  files.each do |file_name|
    rb_file = File.open(file_name)
    rb_file.each_line{|line| add_to_sleep(capture_sleep_value(line)) if line.match(/sleep[\s|\(](([\d]*[.][\d]*)|\d*)/) and !line.match(/#/)}
  end
  puts "\nYour project contains #{@sleep_total.round(2)} seconds of known sleep time. \nThat's #{(@sleep_total/60).round(2)} minutes. Or #{(@sleep_total/3600).round(2)} hours."
end

def capture_sleep_value(line)
  line.slice(/sleep[\s|\(](([\d]*[.][\d]*)|\d*)/).gsub(/sleep[\s|\(]/,"")
end

def add_to_sleep(sleep_value)
  @sleep_total += sleep_value.to_f
end

parse_through_files


