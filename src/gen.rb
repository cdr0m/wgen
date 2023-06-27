#!/usr/bin/env ruby

$name = "Cave of Birds"
$url = "https://caveofbirds.neocities.org"
$source = "https://codeberg.org/ssr7/wgen"

def get_title(f)
	title = File.basename(f, ".*")
	return title
end

def insert_links(c)
	links = c.scan(/\{.*?\}/)

	i = 0
	links.each do |l|
		f_name = l.scan(/(?<=\{).*?(?=\})/)
		f_name = f_name[0].downcase
		f_name.sub!(/\s/, "_")

		a_link = l.sub(/^\{/, "<a href='#{f_name}.html'>")
		a_link = a_link.sub(/\}$/, "</a>")

		c.sub!(/#{links[i]}/, a_link)
		i += 1
	end

	return c
end

def get_content(f)
	c = File.read("inc/#{f}")
	insert_links(c)

	return c
end

def assemble(file, title)
	nav = File.read("inc/meta.nav.html")
	content = get_content(file)
	modified = File.mtime("inc/#{file}")
	title = title.capitalize()

	page = [
		"<!DOCTYPE html><html lang='en-gb'>",
		"<head><meta charset='UTF=8'>",
		"<title>#$name - #{title}</title>",
		"<link href='../links/style.css' rel='stylesheet'>",
		"<link href='../links/favicon.ico' rel='icon'>",
		"</head><body>",
		"<div class='flex'><nav>#{nav}</nav>",
		"<!-- Generated file -->",
		"<main><h1>#{title}</h1>",
		"#{content}</main></div>",
		"<footer>",
		"<div class='copy'>ssr7 &copy; 2023</div>",
		"<div class='modified'>Last modified: #{modified.strftime("Last modified: %T %Z %A, %-d %B %Y")}",
		"[<a href='#$source/_edit/master/src/inc/#{file}' target='_blank'>edit</a>]</div>",
		"</footer>",
		"</body></html>"
	]

	return page
end

def generate
	files = Dir.children("inc")
	puts "Files found: " + files.inspect

	i = 0
	files.each do |file|
		next if file.include?("meta")
			File.open("../site/#{file}", "w") { |f|
				title = get_title(file)
				content = assemble(file, title)
				content.each { |line| f.puts line }
				puts "Generated: #{file}"
			}
		i += 1
	end

	puts "Files generated: #{i}"
end

generate()
