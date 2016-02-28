require 'nokogiri'
require 'redcarpet'

law = Nokogiri::XML(File.open("law.xml"))
markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new)

header = File.open("header.html").read

articulos = ''
law.css("articulo").each do |a|
	text = a.text.gsub(/^\t+/,'').gsub(/{{([^}]+)}}/,'<span class="tema">$1</span>')
	articulos += '<div class="articulo"><span class="nombre">'+
			"Artículo #{a.attributes['numero']}."+
		'</span>'+
		markdown.render( text )+
		'</div>'
end

File.open("law.html", "w+") do |f|
	f.puts header + articulos + '</body></html>'
end
