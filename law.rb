require 'nokogiri'
require 'redcarpet'

law = Nokogiri::XML(File.open("law.xml"))
markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new)

header = File.open("header.html", "r:UTF-8").read
toc = File.open("toc.md", "r:UTF-8").read.gsub(/\* (.*)$/,'* <div>\1</div>')

toc = '<div id="toc">'+markdown.render(toc)+'</div>'

numerales = %w(Cero Primero Segundo Tercero Cuarto Quinto Sexto Séptimo Octavo Noveno Décimo)

def fetch el, attr
	keyVal = el.attributes[attr]
	keyVal && keyVal.value
end

html = '<div id="law">'
law.css("titulo").each do |t|
	tNumero = fetch(t, 'numero')
	tNombre = fetch(t, 'nombre')
	html += "<h1><span class=\"numero\">Título #{tNumero && numerales[tNumero.to_i]}</span>#{tNombre ? '<span class="nombre">'+tNombre+'</span>' : ''}</h1>"

	t.css("capitulo").each do |c|
		cNumero = fetch(c, 'numero')
		cNombre = fetch(c, 'nombre')
		h = cNumero.to_i == 0 ? '1' : '2'
		html += "<h#{h}><span class=\"numero\">Capítulo #{cNumero.to_i == 0 ? 'Único' : cNumero}</span>#{cNombre ? '<span class="nombre">'+cNombre+'</span>' : ''}</h#{h}>"

		c.css("seccion").each do |s|
			sNumero = fetch(s, 'numero')
			sNombre = fetch(s, 'nombre')
			h = cNumero.to_i == 0 ? '1' : '2'
			html += "<h#{h}><span class=\"numero\">Capítulo #{sNumero.to_i == 0 ? 'Único' : sNumero}</span>#{sNombre ? '<span class="nombre">'+sNombre+'</span>' : ''}</h#{h}>"

			s.css("articulo").each do |a|
				numero = a.attributes['numero']
				text = a.text.gsub(/^\t+/,'').
								gsub(/{{([^}]+)}}/,'<span class="tema">\1</span>').
								gsub(/{([^}]+)}/,'<span class="imperativo">\1</span>').
								gsub(/\[\[\[/, '<ul class="lista tres"><li>').
								gsub(/\[\[\#/, '<ul class="lista nested"><li>').
								gsub(/\[\[/, '<ul class="lista dos"><li>').
								gsub(/\]\]\]?/, '</li></ul>').
								gsub(/\[([^\]]+)\]/) { list = $1 
									if list.match(/\|/)
										'<ul class="lista"><li>'+list+'</li></ul>'
									else
										'['+list+']'
									end
								}.
								gsub(/\|{1,3}/,'</li><li>')
				
				text = markdown.render( text ).gsub(/<p>/,'<div class="p">').
								gsub(/<\/p>/,'</div>').
								gsub(/<ul>/,'<ul class="bulleted">')
				html += '<div class="articulo"><span class="nombre" id="/articulo/'+numero+'">'+
						"Artículo #{numero}."+
					'</span>'+text+'</div>'
			end
		end
	end
end
html += '</div>'

File.open("law.html", "w+:UTF-8") do |f|
	f.puts header + toc + html + '</body></html>'
end
