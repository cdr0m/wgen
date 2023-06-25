#!/usr/bin/env ruby

$site_name = "test website"
$site_url = ""
$source = "https://codeberg.org/ssr7/wgen"

def get_title(f)
	title = File.basename(f, ".*")
	return title
end

def insert_links(f)
	links = f.scan(/(?<=\{).*?(?=\})/) # https://stackoverflow.com/a/56334915
	puts "links[]: " + links.inspect
	return links
end

def get_content(f)
	content = File.read("inc/#{f}")
	links = content.scan(/\{.*?\}/)

	i = 0
	links.each do |link|
		# Very messy
		title = link.scan(/(?<=\{).*?(?=\})/)
		title = title[0].downcase
		title.sub!(/\s/, "_")

		a_link = link.sub(/^\{/, "<a href='#{links[i]}.html'>")
		a_link = link.sub(/(\{).*?(\})/, title)
		a_link = link.sub(/\}$/, "</a>")
		puts "a_link: " + a_link
		content.gsub!(links[i], a_link)
		i += 1
	end
	tags = []
	puts "links[]: " + links.inspect
	puts "tags[]: " + tags.inspect

	return content
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
	pages = Dir.children("inc")
	puts "Pages: " + pages.inspect

	i = 0
	pages.each do |page|
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
