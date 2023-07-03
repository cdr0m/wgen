#!/usr/bin/env ruby
$name = "Cave of Birds"
$url = "https://caveofbirds.neocities.org"
$source = "https://codeberg.org/ssr7/wgen"
$input_dir = "inc"
$output_dir = "../site"
$links = "../links" # stylesheet, favicon, etc

def main
  files = Dir.children("inc")
  puts "Files found: #{files.inspect}"

  i = 0
  files.each do |file|
    next if file.start_with?("meta.") || !file.end_with?(".html")
    File.open("#$output_dir/#{file}", "w") do |f|
      content = build_page(file)
      content.each { |line| f.puts line }
      puts "Generated: #{file}"
    end
    i += 1
  end

  puts "Files generated: #{i}"
end

def build_page(f)
  modified = File.mtime("#$input_dir/#{f}")
  title = File.basename(f, ".html").capitalize()
  nav = parse("meta.nav.html")
  content = parse(f)

  if f == "index.html"
    files = Dir.children("inc").sort
    content = "<ul>"
    files.each do |file|
      content += "<li><a href='#{file}' class='cap'>#{file.split(/\s|\./)[0]}</a></li>\n"
    end
    content += "</ul>"
  end

  output = [
    "<!DOCTYPE html><html lang='en-gb'>",
    "<head><meta charset='UTF=8'>",
    "<title>#$name - #{title}</title>",
    "<link href='#$links/style.css' rel='stylesheet'>",
    "<link href='#$links/icon.svg' rel='icon'>",
    "</head><body>",
    "<header><img src='#$links/icon.svg'><span>#$name</span></header>",
    "<div class='flex'><nav>#{nav}</nav>",
    "<!-- Generated file -->",
    "<main><h1>#{title}</h1>",
    "#{content}</main></div>",
    "<footer>",
    "<span>ssr7 &copy; 2023</span>",
    "<span>Last modified: #{modified.strftime("%T %Z %A, %-d %B %Y")}",
    "<a href='#$source/_edit/master/src/inc/#{f}' target='_blank'>edit</a>]</span>",
    "</footer>",
    "</body></html>"
  ]

  return output
end

def parse(f)
  content = File.read("inc/#{f}")
  tags = content.scan(/\{\/?[^\/].*?\}/)
  tags.each do |tag|
    filename = tag.scan(/(?<=\{).*?(?=\})/)
    filename = filename[0].sub(/\s/, "_")

    if tag.match?(/\{\/.*?\}/)
      content.sub!(/#{tag}/, File.read("#$input_dir/#{filename.downcase}.html"))
    else
      a_tag = tag.sub(/^\{/, "<a href='#{filename.downcase}.html'>")
      a_tag = a_tag.sub(/\}$/, "</a>")
      content.sub!(/#{tag}/, a_tag)
    end
  end

  return content
end

main()
