#!/usr/bin/env ruby
$name = "Seabreeze"
$url = "https://seabreeze.neocities.org"
$source = "https://codeberg.org/ssr7/wgen"
$input_dir = "inc"
$output_dir = "../site"
$links = "../links" # stylesheet, favicon, etc

def parse(f)
  content = File.read("#$input_dir/#{f}")
  tags = content.scan(/\{\/?[^\/].*?\}/)
  tags.each do |tag|
    filename = tag.tr("{/}", "")
    filename.gsub!(/\s/, "_")
    linkname = filename
    filename = "#{filename.downcase}.html"
    
    if tag.match?(/\{\/.*?\}/)
      if File.exists?("#$input_dir/#{filename}")
        content.sub!(/#{tag}/,
          "<h2 class='cap'><a href='#{filename}'>#{linkname}</a></h2>" +
          File.read("#$input_dir/#{filename}"))
      else
        puts "Missing file: #{filename} embedded on #{f}"
        content.sub!(/#{tag}/, "<div class='error'>Missing file: #{filename}</div>")
      end
    else
      a_tag = tag.sub(/^\{/, "<a href='#{filename}'>")
      a_tag.sub!(/\}$/, "</a>")
      content.sub!(/#{tag}/, a_tag)
    end
  end

  return content
end

def build()
  files = Dir.children("inc").sort
  files.keep_if {|file| file =~ /^[^.]+\.html$/}

  if files.empty?
    abort("No files found in .\/#$input_dir")
  end

  puts "Files found: #{files.inspect}"

  i = 0
  files.each do |file|
    File.open("#$output_dir/#{file}", "w") do |f|
      modified = File.mtime("#$input_dir/#{file}")
      title = File.basename(file, ".html").capitalize()
      nav = parse("meta.nav.html")
      content = parse(file)

      if file == "index.html"
        content = "<ul>"
        files.each do |file|
          content += "<li><a href='#{file}' class='cap'>#{file.split(/\s|\./)[0]}</a></li>\n"
        end
        content += "</ul>"
      end

      f.puts "<!DOCTYPE html><html lang='en-gb'>"
      f.puts "<head><meta charset='UTF=8'>"
      f.puts "<meta name='viewport' content='width=device-width, initial-scale=1.0'>"
      f.puts "<title>#$name - #{title}</title>"
      f.puts "<link href='#$links/style.css' rel='stylesheet'>"
      f.puts "<link href='#$links/icon.svg' rel='icon'>"
      f.puts "</head><body>"
      f.puts "<header><a href='home.html'><img src='#$links/icon.svg'><span>#$name</span></a></header>"
      f.puts "<div class='flex'><nav>#{nav}</nav>"
      f.puts "<main><h1>#{title}</h1>"
      f.puts "#{content}"
      f.puts "</main></div>"
      f.puts "<footer>"
      f.puts "<span>ssr7 &copy; 2023</span>"
      f.puts "<span>Last modified: #{modified.strftime("%T %Z %A, %-d %B %Y")}"
      f.puts "<a href='#$source/_edit/master/src/inc/#{file}' target='_blank'>[edit]</a></span>"
      f.puts "</footer>"
      f.puts "</body></html>"
      f.close
      puts "Generated: #{file}"
    end

    i += 1
  end

  puts "#{i} files generated"
end

build()
