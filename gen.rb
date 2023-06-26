#!/usr/bin/env ruby

$site_name = "test website"
$site_url = ""
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

	page = [
		"<!DOCTYPE html><html lang='en-gb'>",
		"<head><meta charset='UTF=8'>",
		"<title>#{title} - #$site_name</title>",
		"<link href='#$site_url/style.css' rel='stylesheet'>",
		"<link href='#$site_url/favicon.ico' rel='icon'>",
		"</head><body>",
		"<nav>#{nav}</nav>",
		"<!-- Generated file -->",
		"<main><h1>#{title}</h1>#{content}</main>",
		"<footer>",
		"<div class='copy'>ssr7 &copy; 2023 - ",
		"<a href='https://creativecommons.org/licenses/by-nc-sa/4.0/' target='_blank'>BY-NC-SA</a></div>",
		"<div class='modified'>Last modified: #{modified.strftime("Last modified: %T %Z %A, %B %Y")}",
		"[<a href='#$source/_edit/master/inc/#{file}' target='_blank'>edit</a>]</div>",
		"</footer>",
		"</body></html>"
	]

	return page
end

def generate
	files = Dir.children("inc")
	puts "Files found: " + files.inspect

	i = 0
	files.each do |page|
		next if page.include?("meta")
			File.open("site/#{page}", "w") { |file|
				title = get_title(page)
				content = assemble(page, title)
				content.each { |line| file.puts line }
				puts "Generated: #{page}"
			}
		i += 1
	end

	puts "Page(s) generated: #{i}"
end

generate()
