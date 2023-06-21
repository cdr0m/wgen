#!/usr/bin/env ruby

$site_name = "test website"
$site_url = "//"
$source = "//codeberg.org/ssr7/wgen"

def get_title(f)
	puts "Title: " + File.basename("inc/#{f}", ".*").capitalize
	title = File.basename("inc/#{f}", ".*").capitalize
	return title
end

def build(f, title)
	nav = File.read("inc/meta.nav.html")
	# title = String.capitalize(File.basename("inc/#{f}", ".*"))

	content = File.read("inc/#{f}")
	modified = File.mtime("inc/#{f}")

	open("site/#{f}", "w") { |file|
		file.puts "<!DOCTYPE html><html lang='en-gb'>"
		file.puts "<head><meta charset='UTF=8'>"\
			"<title>#{title} - #$site_name</title>"\
			"<link href='#$site_url/style.css' rel='stylesheet'>"\
			"<link href='#$site_url/favicon.ico' rel='icon'>"\
			"</head><body>"
		file.puts "<nav>#{nav}"\
			"</nav>"
		file.puts "<!-- Generated file -->"
		file.puts "<main><h1>#{title}</h1>#{content}</main>"
		file.puts "<footer>"\
			"<div class='copy'>ssr7 &copy; 2023 - "\
			"<a href='https://creativecommons.org/licenses/by-nc-sa/4.0/' target='_blank'>BY-NC-SA</a></div>"\
			"<div class='modified'>Last modified: #{modified.strftime("Last modified: %T %Z %A, %B %Y")}"\
			"[<a href='#$source/edit/master/#{f}' target='_blank'>edit</a>]</div>"\
			"</footer>"
		file.puts "</body></html>"
		file.close
	}
end

def generate()
	pages = Dir.children("inc")
	puts pages.inspect

	pages.each do |i|
		next if i.include?("meta")
			title = get_title(i)
			build(i, title)
		end
	end

generate()
