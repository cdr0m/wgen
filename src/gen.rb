#!/usr/bin/env ruby
$name = "Cave of Birds"
$url = "https://caveofbirds.neocities.org"
$source = "https://codeberg.org/ssr7/wgen"

def parse(f)
	c = File.read("inc/#{f}")

	# Replace embed tags with content
	i = 0
	embeds = c.scan(/\{[^\/].*?\}/)
	embeds.each do |embed|
		unless embeds.empty?
			f_name = embed.scan(/(?<=\{\/).*?(?=\})/)
			f_name = f_name[0].downcase
			f_name.sub!(/\s/, "_")

			content = File.read("inc/#{f}")
			c.sub!(/#{embeds[i]}/, content)
			i += 1
		end
	end

	# Replace link tags with <a> tags
	i = 0
	links = c.scan(/\{.*?\}/)
	links.each do |link|
		f_name = link.scan(/(?<=\{).*?(?=\})/)
		f_name = f_name[0].downcase
		f_name.sub!(/\s/, "_")

		a_link = link.sub(/^\{/, "<a href='#{f_name}.html'>")
		a_link = a_link.sub(/\}$/, "</a>")

		c.sub!(/#{links[i]}/, a_link)
		i += 1
	end

	puts "embeds: " + embeds.inspect
	puts "links: " + embeds.inspect

	return c
end

def assemble(f)
	nav = File.read("inc/meta.nav.html")
	content = parse(f)
	modified = File.mtime("inc/#{f}")
	title = File.basename(f, ".html").capitalize()

	output = [
		"<!DOCTYPE html><html lang='en-gb'>",
		"<head><meta charset='UTF=8'>",
		"<title>#$name - #{title}</title>",
		"<link href='../links/style.css' rel='stylesheet'>",
		"<link href='../links/icon.svg' rel='icon'>",
		"</head><body>",
    "<header><img src='../links/icon.svg'><span>#$name</span></header>",
		"<div class='flex'><nav>#{nav}</nav>",
		"<!-- Generated file -->",
		"<main><h1>#{title}</h1>",
		"#{content}</main></div>",
		"<footer>",
		"<span>ssr7 &copy; 2023</span>",
		"<span>#{modified.strftime("Last modified: %T %Z %A, %-d %B %Y")}",
		"[<a href='#$source/_edit/master/src/inc/#{f}' target='_blank'>edit</a>]</span>",
		"</footer>",
		"</body></html>"
	]

	return output
end

def main
	files = Dir.children("inc")
	puts "Files found: " + files.inspect

	i = 0
	files.each do |file|
		next if file.include?("meta")
		File.open("../site/#{file}", "w") { |f|
			content = assemble(file)
			content.each { |line| f.puts line }
			puts "Generated: #{file}"
		}
		i += 1
	end

	puts "Files generated: #{i}"
end

main()
